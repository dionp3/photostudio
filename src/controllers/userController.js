const pool = require('../config/db');

const getStudios = async (req, res) => {
  try {
    const [studios] = await pool.query(`
      SELECT 
        studio_id, 
        studio_name, 
        studio_capacity, 
        studio_location, 
        studio_hourly_rate, 
        studio_created_at 
      FROM studios_view
    `);

    if (studios.length === 0) {
      return res.status(404).json({ message: 'No studios found' });
    }

    res.status(200).json({
      message: 'Studios data retrieved successfully',
      data: studios,
    });

  } catch (err) {
    res.status(500).json({
      error: 'An error occurred while retrieving studios data',
      details: err.message,
    });
  }
};

const getEquipment = async (req, res) => {
  try {
    const [equipments] = await pool.query(`
      SELECT 
        equipment_id, 
        equipment_name, 
        equipment_type, 
        equipment_quantity, 
        equipment_hourly_rate, 
        equipment_created_at 
      FROM equipments_view
    `);

    if (equipments.length === 0) {
      return res.status(404).json({ message: 'No equipments found' });
    }

    res.status(200).json({
      message: 'Equipments data retrieved successfully',
      data: equipments
    });

  } catch (err) {
    res.status(500).json({ 
      error: 'An error occurred while retrieving equipment data', 
      details: err.message 
    });
  }
};

const getPhotographers = async (req, res) => {
  try {
    const [photographers] = await pool.query(`
      SELECT 
        photographer_id, 
        photographer_name, 
        photographer_specialty, 
        photographer_hourly_rate, 
        photographer_created_at 
      FROM photographers_view
    `);

    if (photographers.length === 0) {
      return res.status(404).json({ message: 'No photographers found' });
    }

    res.status(200).json({
      message: 'Photographers data retrieved successfully',
      data: photographers
    });
  } catch (err) {
    res.status(500).json({ 
      error: 'An error occurred while retrieving photographers data', 
      details: err.message 
    });
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

    const [reservations] = await pool.query(
      `
      SELECT 
        r.id AS reservation_id,
        r.user_id,
        u.username AS user_name,
        r.studio_id,
        s.name AS studio_name,
        r.start_time,
        r.end_time,
        r.total_cost,
        r.payment_status,
        r.reservation_status,
        r.created_at AS reservation_created_at
      FROM studio_reservations r
      JOIN users u ON r.user_id = u.id
      LEFT JOIN studios s ON r.studio_id = s.id
      WHERE r.user_id = ?
      ORDER BY r.created_at DESC
      `,
      [userId]
    );

    if (reservations.length === 0) {
      return res.status(404).json({
        message: 'No studio reservations found for this user',
      });
    }

    res.status(200).json({
      message: 'Studio reservations retrieved successfully',
      data: reservations,
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
    const userId = req.user.id; // Ambil user_id dari middleware yang menyimpan info user

    const [rentals] = await pool.query(
      `
      SELECT 
        er.id AS rental_id,
        er.user_id,
        u.username AS user_name,
        er.equipment_id,
        e.name AS equipment_name,
        er.start_time,
        er.end_time,
        er.quantity,
        er.total_cost,
        er.payment_status,
        er.rental_status,
        er.created_at AS rental_created_at
      FROM equipment_rentals er
      JOIN users u ON er.user_id = u.id
      LEFT JOIN equipments e ON er.equipment_id = e.id
      WHERE er.user_id = ?
      ORDER BY er.created_at DESC
      `,
      [userId]
    );

    if (rentals.length === 0) {
      return res.status(404).json({
        message: 'No equipment rentals found for this user',
      });
    }

    res.status(200).json({
      message: 'Equipment rentals retrieved successfully',
      data: rentals,
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
    const userId = req.user.id; // Ambil user_id dari middleware yang menyimpan info user

    const [bookings] = await pool.query(
      `
      SELECT 
        pb.id AS booking_id,
        pb.user_id,
        u.username AS user_name,
        pb.photographer_id,
        p.name AS photographer_name,
        pb.start_time,
        pb.end_time,
        pb.total_cost,
        pb.payment_status,
        pb.booking_status,
        pb.created_at AS booking_created_at
      FROM photographer_bookings pb
      JOIN users u ON pb.user_id = u.id
      LEFT JOIN photographers p ON pb.photographer_id = p.id
      WHERE pb.user_id = ?
      ORDER BY pb.created_at DESC
      `,
      [userId]
    );

    if (bookings.length === 0) {
      return res.status(404).json({
        message: 'No photographer bookings found for this user',
      });
    }

    res.status(200).json({
      message: 'Photographer bookings retrieved successfully',
      data: bookings,
    });

  } catch (err) {
    res.status(500).json({
      error: 'An error occurred while retrieving photographer bookings',
      details: err.message,
    });
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


const createStudioReservation = async (req, res) => {
  const { studio_id, start_time, end_time } = req.body;
  try {
    // Mengambil harga per jam studio dari database
    const [studio] = await pool.query(
      `SELECT hourly_rate FROM studios WHERE id = ?`, 
      [studio_id]
    );

    // Validasi apakah studio ditemukan dan harga per jam tersedia
    if (!studio || !studio[0].hourly_rate) {
      return res.status(404).json({ message: 'Studio not found or hourly rate is missing' });
    }

    // Mengonversi harga per jam dari string/decimal ke angka (float)
    const hourlyRate = parseFloat(studio[0].hourly_rate);

    // Validasi apakah harga per jam valid
    if (isNaN(hourlyRate) || hourlyRate <= 0) {
      return res.status(400).json({ message: 'Invalid hourly rate' });
    }

    // Menghitung durasi sewa dalam jam
    const startTime = new Date(start_time);
    const endTime = new Date(end_time);

    // Validasi apakah waktu start_time dan end_time valid
    if (isNaN(startTime) || isNaN(endTime)) {
      return res.status(400).json({ message: 'Invalid start time or end time' });
    }

    const durationInHours = (endTime - startTime) / (1000 * 60 * 60); // Menghitung durasi dalam jam

    // Validasi durasi waktu
    if (durationInHours <= 0) {
      return res.status(400).json({ message: 'End time must be after start time' });
    }

    // Menghitung total cost berdasarkan harga per jam dan durasi
    const total_cost = hourlyRate * durationInHours;

    // Validasi apakah total cost valid
    if (isNaN(total_cost) || total_cost <= 0) {
      return res.status(400).json({ message: 'Invalid total cost calculation' });
    }

    // Cek apakah sudah ada reservasi di rentang waktu yang sama untuk studio ini
    const [existingReservations] = await pool.query(
      `SELECT * FROM studio_reservations 
       WHERE studio_id = ? 
       AND (start_time < ? AND end_time > ?)`,

      [studio_id, end_time, start_time]
    );

    if (existingReservations.length > 0) {
      return res.status(400).json({ message: 'Studio is already reserved for the selected time range' });
    }

    // Menyimpan reservasi studio ke database
    const result = await pool.query(
      `INSERT INTO studio_reservations (user_id, studio_id, start_time, end_time, total_cost, payment_status, reservation_status)
       VALUES (?, ?, ?, ?, ?, 'pending', 'pending')`,
      [req.user.id, studio_id, start_time, end_time, total_cost]
    );

    const reservationId = result.insertId; // ID reservasi studio yang baru dibuat
    res.status(201).json({
      message: 'Studio reservation created successfully',
      reservationId: reservationId,
      total_cost: total_cost,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error creating reservation' });
  }
};





const processStudioPayment = async (req, res) => {
  const { reservation_id, payment_amount } = req.body;

  try {
    // Mengecek apakah reservasi ada di database
    const [reservation] = await pool.query(
      `SELECT * FROM studio_reservations WHERE id = ?`, 
      [reservation_id]
    );

    if (reservation.length === 0) {
      return res.status(404).json({ message: 'Reservation not found' });
    }

    const existingReservation = reservation[0];

    // Mengecek apakah pembayaran sudah dilakukan atau belum
    if (existingReservation.payment_status === 'paid') {
      return res.status(400).json({ message: 'Reservation already paid for' });
    }

    // Mengonversi total_cost ke tipe angka (float) untuk perbandingan yang tepat
    const totalCost = parseFloat(existingReservation.total_cost);

    // Mengonversi payment_amount ke tipe angka (float) jika perlu
    const paymentAmount = parseFloat(payment_amount);

    // Validasi jumlah pembayaran (harus sama dengan total cost reservasi)
    if (paymentAmount !== totalCost) {
      return res.status(400).json({ message: 'Payment amount does not match total cost' });
    }

    // Simulasi proses pembayaran (misalnya melalui API pembayaran eksternal)
    const paymentSuccessful = true; // Gantilah dengan proses pembayaran yang sebenarnya

    if (!paymentSuccessful) {
      return res.status(500).json({ message: 'Payment failed. Please try again.' });
    }

    // Pembayaran berhasil, perbarui status reservasi dan pembayaran
    await pool.query(
      `UPDATE studio_reservations 
       SET payment_status = 'paid', reservation_status = 'confirmed'
       WHERE id = ?`,
      [reservation_id]
    );

    res.status(200).json({
      message: 'Payment successful, reservation confirmed',
      reservation_id: reservation_id,
      payment_status: 'paid',
      reservation_status: 'confirmed',
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error processing payment' });
  }
};


const createEquipmentRental = async (req, res) => {
  const { equipment_id, rental_start, rental_end, quantity } = req.body;

  const userId = req.user.id
  try {
    // Ambil hourly_rate peralatan berdasarkan equipment_id
    const [equipment] = await pool.query(
      `SELECT hourly_rate FROM equipments WHERE id = ?`,
      [equipment_id]
    );

    console.log("Fetched equipment:", equipment);  // Log hasil query ke konsol

    if (!equipment || equipment.length === 0) {
      return res.status(404).json({ message: 'Equipment not found' });
    }

    const hourlyRate = parseFloat(equipment[0].hourly_rate);
    console.log("Hourly rate:", hourlyRate);  // Log tarif per jam

    // Pastikan hourlyRate valid
    if (isNaN(hourlyRate) || hourlyRate <= 0) {
      return res.status(400).json({ message: 'Invalid equipment hourly rate' });
    }

    // Hitung durasi sewa dalam jam
    const startTime = new Date(rental_start);
    const endTime = new Date(rental_end);
    const rentalDuration = (endTime - startTime) / (1000 * 60 * 60); // Menghitung durasi dalam jam
    console.log("Rental duration in hours:", rentalDuration);  // Log durasi sewa

    if (rentalDuration <= 0) {
      return res.status(400).json({ message: 'Invalid rental duration' });
    }

    // Hitung total cost sewa berdasarkan hourly rate dan durasi sewa
    const totalCost = hourlyRate * rentalDuration * quantity;
    console.log("Total cost:", totalCost);  // Log total biaya

    // Pastikan total cost valid
    if (isNaN(totalCost) || totalCost <= 0) {
      return res.status(400).json({ message: 'Invalid total cost calculation' });
    }

    // Buat sewa peralatan dengan total cost yang dihitung
    const result = await pool.query(
      `INSERT INTO equipment_rentals (user_id, equipment_id, start_time, end_time, quantity, total_cost, rental_status)
       VALUES (?, ?, ?, ?, ?, ?, 'pending')`,
      [user_id, equipment_id, rental_start, rental_end, quantity, totalCost]
    );
    
    const rentalId = result.insertId;  // ID sewa peralatan yang baru dibuat

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





// Pembayaran sewa peralatan
const processEquipmentPayment = async (req, res) => {
  const { payment_amount, payment_method } = req.body;  // Jumlah pembayaran dan metode pembayaran

  // Ambil user_id dari cookie (misalnya, menggunakan middleware otentikasi)
  const user_id = req.user.id;

  if (!user_id) {
    return res.status(400).json({ message: 'User not logged in' });
  }

  try {
    // Pastikan ID valid dan ada dalam daftar sewa peralatan dengan status 'pending'
    const [rental] = await pool.query(
      `SELECT * FROM equipment_rentals WHERE user_id = ? AND rental_status = 'pending'`,
      [user_id]
    );

    if (!rental || rental.length === 0) {
      return res.status(404).json({ message: 'Rental not found or already processed' });
    }

    // Verifikasi bahwa jumlah pembayaran sesuai dengan biaya total sewa
    if (parseFloat(payment_amount) !== parseFloat(rental[0].total_cost)) {
      return res.status(400).json({ message: 'Payment amount does not match total cost' });
    }

    // Simulasi proses pembayaran, seharusnya ada integrasi dengan gateway pembayaran eksternal
    const paymentSuccessful = true; // Simulasi pembayaran berhasil

    if (!paymentSuccessful) {
      return res.status(500).json({ message: 'Payment failed. Please try again.' });
    }

    // Pembayaran berhasil, perbarui status rental menjadi 'completed' dan payment_status menjadi 'completed'
    await pool.query(
      `UPDATE equipment_rentals
       SET rental_status = 'completed', payment_status = 'completed'
       WHERE user_id = ? AND rental_status = 'pending'`,
      [user_id]
    );

    // Kirimkan respons bahwa pembayaran berhasil
    res.status(200).json({ message: 'Payment processed successfully for equipment rental' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error processing payment for equipment rental' });
  }
};



// Membuat pemesanan fotografer
const createPhotographerBooking = async (req, res) => {
  const { user_id, photographer_id, booking_start, booking_end, total_cost } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO photographer_bookings (user_id, photographer_id, booking_start, booking_end, total_cost, booking_status)
       VALUES (?, ?, ?, ?, ?, 'pending')`,
      [user_id, photographer_id, booking_start, booking_end, total_cost]
    );
    const bookingId = result.insertId; // ID pemesanan fotografer yang baru dibuat
    res.status(201).json({
      message: 'Photographer booking created successfully',
      bookingId: bookingId,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error creating photographer booking' });
  }
};

// Pembayaran pemesanan fotografer
const processPhotographerPayment = async (req, res) => {
  const { id } = req.user.id; // ID yang didapat dari daftar pesanan
  const { payment_amount, payment_method } = req.body;

  try {
    // Pastikan ID valid dan ada dalam daftar pemesanan fotografer
    const [booking] = await pool.query(
      `SELECT * FROM photographer_bookings WHERE id = ? AND booking_status = 'pending'`,
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
    const result = await pool.query('SELECT * FROM payment_details');
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
