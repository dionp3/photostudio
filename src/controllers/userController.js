const pool = require('../config/db');

// Mengambil data studio berdasarkan user
const getStudios = async (req, res) => {
  try {
    const [studios] = await pool.query('SELECT * FROM studio_view WHERE admin_username = ?', [req.user.username]);
    res.status(200).json(studios);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Mengambil data equipment berdasarkan user
const getEquipment = async (req, res) => {
  try {
    const [equipment] = await pool.query('SELECT * FROM equipment_view WHERE admin_username = ?', [req.user.username]);
    res.status(200).json(equipment);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Mengambil data photographer berdasarkan user
const getPhotographers = async (req, res) => {
  try {
    const [photographers] = await pool.query('SELECT * FROM photographer_view WHERE admin_username = ?', [req.user.username]);
    res.status(200).json(photographers);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Reservasi Studio
const reserveStudio = async (req, res) => {
  const { studioId, startTime, endTime } = req.body;
  try {
    const [rows] = await pool.query('CALL reserve_studio(?, ?, ?, ?)', [
      req.user.id,
      studioId,
      startTime,
      endTime,
    ]);
    res.status(200).json({ message: 'Studio reserved successfully', data: rows });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Penyewaan Alat
const rentEquipment = async (req, res) => {
  const { equipmentId, rentStart, rentEnd } = req.body;
  try {
    const [rows] = await pool.query('CALL rent_equipment(?, ?, ?, ?)', [
      req.user.id,
      equipmentId,
      rentStart,
      rentEnd,
    ]);
    res.status(200).json({ message: 'Equipment rented successfully', data: rows });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Pemesanan Fotografer
const bookPhotographer = async (req, res) => {
  const { photographerId, bookingStart, bookingEnd } = req.body;
  try {
    const [rows] = await pool.query('CALL book_photographer(?, ?, ?, ?)', [
      req.user.id,
      photographerId,
      bookingStart,
      bookingEnd,
    ]);
    res.status(200).json({ message: 'Photographer booked successfully', data: rows });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = { 
    getStudios,
    getEquipment,
    getPhotographers,
    reserveStudio, 
    rentEquipment, 
    bookPhotographer 
};
