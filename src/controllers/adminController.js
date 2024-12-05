const pool = require('../config/db');

// Management Studio
const addStudio = async (req, res) => {
  const { adminId, studioName, studioLocation } = req.body;
  try {
    await pool.query('CALL add_studio(?, ?, ?)', [adminId, studioName, studioLocation]);
    res.status(201).json({ message: 'Studio added successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const updateStudio = async (req, res) => {
  const { studioId, name, location } = req.body;
  try {
    await pool.query('CALL update_studio(?, ?, ?)', [studioId, name, location]);
    res.status(200).json({ message: 'Studio updated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const deleteStudio = async (req, res) => {
  const { studioId } = req.body;
  try {
    await pool.query('CALL delete_studio(?)', [studioId]);
    res.status(200).json({ message: 'Studio deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const viewStudio = async (req, res) => {
  const { studioId } = req.params;
  try {
    const [rows] = await pool.query('SELECT * FROM studios WHERE id = ?', [studioId]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Studio not found' });
    }
    res.status(200).json({ studio: rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Management Equipment
const addEquipment = async (req, res) => {
  const { adminId, equipmentName, equipmentType } = req.body;
  try {
    await pool.query('CALL add_equipment(?, ?, ?)', [adminId, equipmentName, equipmentType]);
    res.status(201).json({ message: 'Equipment added successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const updateEquipment = async (req, res) => {
  const { equipmentId, name, quantity } = req.body;
  try {
    await pool.query('CALL update_equipment(?, ?, ?)', [equipmentId, name, quantity]);
    res.status(200).json({ message: 'Equipment updated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const deleteEquipment = async (req, res) => {
  const { equipmentId } = req.body;
  try {
    await pool.query('CALL delete_equipment(?)', [equipmentId]);
    res.status(200).json({ message: 'Equipment deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const viewEquipment = async (req, res) => {
  const { equipmentId } = req.params;
  try {
    const [rows] = await pool.query('SELECT * FROM equipment WHERE id = ?', [equipmentId]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Equipment not found' });
    }
    res.status(200).json({ equipment: rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Management Photographer
const addPhotographer = async (req, res) => {
  const { adminId, photographerName, photographerContact } = req.body;
  try {
    await pool.query('CALL add_photographer(?, ?, ?)', [adminId, photographerName, photographerContact]);
    res.status(201).json({ message: 'Photographer added successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const updatePhotographer = async (req, res) => {
  const { photographerId, name, specialty } = req.body;
  try {
    await pool.query('CALL update_photographer(?, ?, ?)', [photographerId, name, specialty]);
    res.status(200).json({ message: 'Photographer updated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const deletePhotographer = async (req, res) => {
  const { photographerId } = req.body;
  try {
    await pool.query('CALL delete_photographer(?)', [photographerId]);
    res.status(200).json({ message: 'Photographer deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const viewPhotographer = async (req, res) => {
  const { photographerId } = req.params;
  try {
    const [rows] = await pool.query('SELECT * FROM photographers WHERE id = ?', [photographerId]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Photographer not found' });
    }
    res.status(200).json({ photographer: rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Mengambil semua audit log
const getAllAuditLogs = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM audit_log ORDER BY timestamp DESC');
    res.status(200).json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Mengambil audit log berdasarkan ID tertentu
const getAuditLogById = async (req, res) => {
  const { id } = req.params;
  try {
    const [rows] = await pool.query('SELECT * FROM audit_log WHERE id = ?', [id]);
    
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Audit log not found' });
    }
    
    res.status(200).json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { 
    addStudio, 
    updateStudio, 
    deleteStudio, 
    viewStudio, 
    addEquipment, 
    updateEquipment, 
    deleteEquipment, 
    viewEquipment, 
    addPhotographer,
    updatePhotographer,
    deletePhotographer,
    viewPhotographer,
    getAllAuditLogs,
    getAuditLogById 
};