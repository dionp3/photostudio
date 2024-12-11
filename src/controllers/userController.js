const pool = require('../config/db');

const getStudios = async (req, res) => {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction(); 

    const [studios] = await connection.query('CALL getStudios()');

    if (studios.length === 0) {
      return res.status(404).json({ message: 'No studios found' });
    }

    await connection.commit();

    res.status(200).json({
      message: 'Studios data retrieved successfully',
      data: studios,
    });

  } catch (err) {
    await connection.rollback(); 
    res.status(500).json({
      error: 'An error occurred while retrieving studios data',
      details: err.message,
    });
  } finally {
    connection.release();
  }
};



const getEquipment = async (req, res) => {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction(); 

    const [equipments] = await connection.query('CALL getEquipments()');

    if (equipments.length === 0) {
      return res.status(404).json({ message: 'No equipments found' });
    }

    await connection.commit();

    res.status(200).json({
      message: 'Equipments data retrieved successfully',
      data: equipments
    });

  } catch (err) {
    await connection.rollback(); 
    res.status(500).json({
      error: 'An error occurred while retrieving equipment data',
      details: err.message
    });
  } finally {
    connection.release(); 
  }
};



const getPhotographers = async (req, res) => {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction(); 

    const [photographers] = await connection.query('CALL getPhotographers()');

    if (photographers.length === 0) {
      return res.status(404).json({ message: 'No photographers found' });
    }

    await connection.commit();

    res.status(200).json({
      message: 'Photographers data retrieved successfully',
      data: photographers
    });
  } catch (err) {
    await connection.rollback(); 
    res.status(500).json({
      error: 'An error occurred while retrieving photographers data',
      details: err.message
    });
  } finally {
    connection.release(); 
  }
};



const getAllReservations = async (req, res) => {
  try {
    const [rows] = await pool.query('CALL get_all_reservations()');

    res.status(200).json({
      message: 'All reservations fetched successfully',
      data: rows[0], 
    });

  } catch (error) {
    console.error('Error fetching all reservations:', error);

    res.status(500).json({
      error: 'Failed to fetch reservations',
    });
  }
};



const getUserStudioReservations = async (req, res) => {
  try {
    const userId = req.user.id;

    const [reservations] = await pool.query('CALL get_user_studio_reservations(?)', [userId]);

    if (reservations.length === 0) {
      return res.status(404).json({
        message: 'No studio reservations found for this user',
      });
    }

    res.status(200).json({
      message: 'Studio reservations retrieved successfully',
      data: reservations[0], 
    });

  } catch (err) {
    res.status(500).json({
      error: 'An error occurred while retrieving studio reservations',
      details: err.message,
    });
  }
};



const getUserEquipmentRentals = async (req, res) => {
  try {
    const userId = req.user.id;

    const [rentals] = await pool.query('CALL get_user_equipment_rentals(?)', [userId]);

    if (rentals.length === 0) {
      return res.status(404).json({
        message: 'No equipment rentals found for this user',
      });
    }

    res.status(200).json({
      message: 'Equipment rentals retrieved successfully',
      data: rentals[0],  
    });

  } catch (err) {
    res.status(500).json({
      error: 'An error occurred while retrieving equipment rentals',
      details: err.message,
    });
  }
};



const getUserPhotographerBookings = async (req, res) => {
  try {
    const userId = req.user.id;

    const [bookings] = await pool.query('CALL get_user_photographer_bookings(?)', [userId]);

    if (bookings.length === 0) {
      return res.status(404).json({
        message: 'No photographer bookings found for this user',
      });
    }

    res.status(200).json({
      message: 'Photographer bookings retrieved successfully',
      data: bookings[0], 
    });

  } catch (err) {
    res.status(500).json({
      error: 'An error occurred while retrieving photographer bookings',
      details: err.message,
    });
  }
};



const createStudioReservation = async (req, res) => {
  const { studio_id, start_time, end_time } = req.body;
  try {
    const userId = req.user.id; 

    const [result] = await pool.query(
      `CALL CreateStudioReservation(?, ?, ?, ?, @reservation_id, @total_cost)`,
      [userId, studio_id, start_time, end_time]
    );

    const [output] = await pool.query('SELECT @reservation_id AS reservation_id, @total_cost AS total_cost');

    const reservationId = output[0].reservation_id;
    const totalCost = output[0].total_cost;

    if (!reservationId || !totalCost) {
      return res.status(400).json({ message: 'Error creating reservation' });
    }

    res.status(201).json({
      message: 'Studio reservation created successfully',
      reservationId: reservationId,
      total_cost: totalCost,
    });
  } catch (error) {
    console.error(error);
    if (error.sqlState === '45000') {
      return res.status(400).json({ message: error.sqlMessage });
    }
    res.status(500).json({ message: 'Error creating reservation' });
  }
};



const processStudioPayment = async (req, res) => {
  const { reservation_id, payment_amount } = req.body; 
  try {
    const [result] = await pool.query(
      `CALL processStudioPaymentProcedure(?, ?, @payment_status, @reservation_status)`,
      [reservation_id, payment_amount]
    );

    const [output] = await pool.query(
      'SELECT @payment_status AS payment_status, @reservation_status AS reservation_status'
    );

    const paymentStatus = output[0].payment_status;
    const reservationStatus = output[0].reservation_status;

    if (paymentStatus === 'completed' && reservationStatus === 'confirmed') {
      res.status(200).json({
        message: 'Payment processed successfully, reservation confirmed',
        payment_status: paymentStatus,
        reservation_status: reservationStatus,
      });
    } else {
      res.status(400).json({ message: 'Payment failed or invalid reservation' });
    }
  } catch (error) {
    console.error(error);
    if (error.sqlState === '45000') {
      return res.status(400).json({ message: error.sqlMessage });
    }
    res.status(500).json({ message: 'Error processing payment' });
  }
};






// // Reservasi Studio
// const reserveStudio = async (req, res) => {
//   const { studio_name, startTime, endTime } = req.body;
//   try {
//     const [rows] = await pool.query('CALL reserve_studio(?, ?, ?, ?)', [
//       req.user.id,
//       studio_name,
//       startTime,
//       endTime,
//     ]);
//     const reservationDetails = rows[0]; // Extract reservation details
//     res.status(200).json({
//       message: 'Studio reserved successfully',
//       data: reservationDetails,
//     });
//   } catch (error) {
//     res.status(500).json({ error: error.message });
//   }
// };



// const processPayment = async (req, res) => {
//   const { reservationId, amount, paymentMethod } = req.body;
  
//   try {
//     // Memanggil prosedur untuk memproses pembayaran
//     const [result] = await pool.query(
//       'CALL process_payment(?, ?, ?)', 
//       [reservationId, amount, paymentMethod]
//     );

//     // Pastikan result ada dan memeriksa status pembayaran
//     if (result.length > 0) {
//       const paymentStatus = result[0].payment_status;

//       if (paymentStatus === 'completed') {
//         return res.status(200).json({
//           message: 'Pembayaran berhasil, reservasi dikonfirmasi',
//           data: { reservationId, amount, paymentMethod, paymentStatus }
//         });
//       } else if (paymentStatus === 'failed') {
//         return res.status(400).json({
//           message: 'Pembayaran gagal, status reservasi tetap pending',
//           data: { reservationId, amount, paymentMethod, paymentStatus }
//         });
//       }
//     }

//     // Jika tidak ada status atau status tidak diketahui, kirimkan error
//     return res.status(500).json({
//       message: 'Terjadi kesalahan dalam memproses pembayaran',
//       error: 'Status pembayaran tidak diketahui'
//     });

//   } catch (error) {
//     console.error('Error processing payment:', error);
//     return res.status(500).json({
//       error: 'Gagal memproses pembayaran',
//       message: error.message
//     });
//   }
// };



// // Penyewaan Alat
// const rentEquipment = async (req, res) => {
//   const { equipmentId, rentStart, rentEnd } = req.body;
//   try {
//     const [rows] = await pool.query('CALL rent_equipment(?, ?, ?, ?)', [
//       req.user.id,
//       equipmentId,
//       rentStart,
//       rentEnd,
//     ]);
//     res.status(200).json({ message: 'Equipment rented successfully', data: rows });
//   } catch (error) {
//     res.status(500).json({ error: error.message });
//   }
// };

// // Pemesanan Fotografer
// const bookPhotographer = async (req, res) => {
//   const { photographerId, bookingStart, bookingEnd } = req.body;
//   try {
//     const [rows] = await pool.query('CALL book_photographer(?, ?, ?, ?)', [
//       req.user.id,
//       photographerId,
//       bookingStart,
//       bookingEnd,
//     ]);
//     res.status(200).json({ message: 'Photographer booked successfully', data: rows });
//   } catch (error) {
//     res.status(500).json({ error: error.message });
//   }
// };



// const calculateTotalCost = async (req, res) => {
//   const { studioId, equipmentIds, photographerId, duration } = req.body;

//   try {
//     // Ambil tarif studio berdasarkan ID
//     const [studio] = await pool.query('SELECT studio_hourly_rate FROM studios WHERE id = ?', [studioId]);
//     const studioRate = studio[0].studio_hourly_rate;

//     // Hitung biaya studio
//     const studioCost = studioRate * duration;

//     // Hitung biaya peralatan
//     let equipmentCost = 0;
//     for (let equipmentId of equipmentIds) {
//       const [equipment] = await pool.query('SELECT hourly_rate FROM equipments WHERE id = ?', [equipmentId]);
//       equipmentCost += equipment[0].hourly_rate * duration;
//     }

//     // Ambil tarif fotografer
//     const [photographer] = await pool.query('SELECT hourly_rate FROM photographers WHERE id = ?', [photographerId]);
//     const photographerCost = photographer[0].hourly_rate * duration;

//     // Total biaya
//     const totalCost = studioCost + equipmentCost + photographerCost;

//     res.status(200).json({ totalCost });

//   } catch (err) {
//     res.status(500).json({ error: 'Error calculating total cost', details: err.message });
//   }
// };

// const processPayment = async (req, res) => {
//   const { studioId, equipmentIds, photographerId, userId, totalAmount, paymentMethod } = req.body;

//   try {
//     // Simulasikan proses pembayaran
//     const paymentStatus = 'paid'; // Ini hanya contoh, di dunia nyata akan melibatkan gateway pembayaran

//     // Masukkan data pembayaran ke tabel
//     await pool.query(
//       'INSERT INTO payments (studio_id, equipment_id, photographer_id, user_id, total_amount, payment_method, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?)',
//       [studioId, equipmentIds.join(','), photographerId, userId, totalAmount, paymentMethod, paymentStatus]
//     );

//     // Kirim konfirmasi pembayaran
//     res.status(200).json({ message: 'Payment processed successfully' });

//   } catch (err) {
//     res.status(500).json({ error: 'Error processing payment', details: err.message });
//   }
// };



const createEquipmentRental = async (req, res) => {
  const { equipment_id, rental_start, rental_end, quantity } = req.body;

  const userId = req.user.id
  try {
    const [equipment] = await pool.query(
      `SELECT hourly_rate FROM equipments WHERE id = ?`,
      [equipment_id]
    );

    console.log("Fetched equipment:", equipment);  

    if (!equipment || equipment.length === 0) {
      return res.status(404).json({ message: 'Equipment not found' });
    }

    const hourlyRate = parseFloat(equipment[0].hourly_rate);
    console.log("Hourly rate:", hourlyRate);  

    if (isNaN(hourlyRate) || hourlyRate <= 0) {
      return res.status(400).json({ message: 'Invalid equipment hourly rate' });
    }

    const startTime = new Date(rental_start);
    const endTime = new Date(rental_end);
    const rentalDuration = (endTime - startTime) / (1000 * 60 * 60); 
    console.log("Rental duration in hours:", rentalDuration);  

    if (rentalDuration <= 0) {
      return res.status(400).json({ message: 'Invalid rental duration' });
    }

    const totalCost = hourlyRate * rentalDuration * quantity;
    console.log("Total cost:", totalCost);  

    if (isNaN(totalCost) || totalCost <= 0) {
      return res.status(400).json({ message: 'Invalid total cost calculation' });
    }

    const result = await pool.query(
      `INSERT INTO equipment_rentals (user_id, equipment_id, start_time, end_time, quantity, total_cost, rental_status)
       VALUES (?, ?, ?, ?, ?, ?, 'pending')`,
      [user_id, equipment_id, rental_start, rental_end, quantity, totalCost]
    );
    
    const rentalId = result.insertId;  

    res.status(201).json({
      message: 'Equipment rental created successfully',
      rentalId: rentalId,
      totalCost: totalCost,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error creating equipment rental' });
  }
};



const processEquipmentPayment = async (req, res) => {
  const { payment_amount, payment_method } = req.body;  

  const user_id = req.user.id;

  if (!user_id) {
    return res.status(400).json({ message: 'User not logged in' });
  }

  try {
    const [rental] = await pool.query(
      `SELECT  FROM equipment_rentals WHERE user_id = ? AND rental_status = 'pending'`,
      [user_id]
    );

    if (!rental || rental.length === 0) {
      return res.status(404).json({ message: 'Rental not found or already processed' });
    }

    if (parseFloat(payment_amount) !== parseFloat(rental[0].total_cost)) {
      return res.status(400).json({ message: 'Payment amount does not match total cost' });
    }

    const paymentSuccessful = true; 

    if (!paymentSuccessful) {
      return res.status(500).json({ message: 'Payment failed. Please try again.' });
    }

    await pool.query(
      `UPDATE equipment_rentals
       SET rental_status = 'completed', payment_status = 'completed'
       WHERE user_id = ? AND rental_status = 'pending'`,
      [user_id]
    );

    res.status(200).json({ message: 'Payment processed successfully for equipment rental' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error processing payment for equipment rental' });
  }
};



const createPhotographerBooking = async (req, res) => {
  const { user_id, photographer_id, booking_start, booking_end, total_cost } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO photographer_bookings (user_id, photographer_id, booking_start, booking_end, total_cost, booking_status)
       VALUES (?, ?, ?, ?, ?, 'pending')`,
      [user_id, photographer_id, booking_start, booking_end, total_cost]
    );
    const bookingId = result.insertId; 
    res.status(201).json({
      message: 'Photographer booking created successfully',
      bookingId: bookingId,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error creating photographer booking' });
  }
};



const processPhotographerPayment = async (req, res) => {
  const { id } = req.user.id; 
  const { payment_amount, payment_method } = req.body;

  try {
    const [booking] = await pool.query(
      `SELECT  FROM photographer_bookings WHERE id = ? AND booking_status = 'pending'`,
      [id]
    );

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found or already processed' });
    }

    await pool.query(
      `CALL ProcessPayment(?, 'photographer_booking', ?, ?)`,
      [id, payment_amount, payment_method]
    );
    res.status(200).json({ message: 'Payment processed successfully for photographer booking' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error processing payment for photographer booking' });
  }
};



const getPaymentDetails = async (req, res) => {
  try {
    const result = await pool.query('SELECT  FROM payment_details');
    res.status(200).json(result); 
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error retrieving payment details' });
  }
};



module.exports = { 
    getStudios,
    getEquipment,
    getPhotographers,
    getAllReservations,
    getUserStudioReservations,
    getUserEquipmentRentals,
    getUserPhotographerBookings,
    createStudioReservation,
    processStudioPayment,
    createEquipmentRental,
    processEquipmentPayment,
    createPhotographerBooking,
    processPhotographerPayment,
    getPaymentDetails
};
