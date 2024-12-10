const pool = require('../config/db');

const handleError = (err, res, message = 'Internal Server Error') => {
  console.error(err);
  res.status(500).json({ error: message, details: err.message || err });
};

const getAllReservationsForAdmin = async (req, res) => {
  try {
    const [rows] = await pool.query('CALL get_all_reservations_for_admin()');

    res.status(200).json({
      message: 'All reservations for admin fetched successfully',
      data: rows[0], 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: 'Failed to fetch reservations for admin',
      error: error.message,
    });
  }
};


const validateStudioInputs = (studioName, studioCapacity, studioLocation, studioHourlyRate) => {
  if (!studioName || typeof studioName !== 'string') {
    return { valid: false, error: 'Studio name is required and must be a string' };
  }
  if (!studioCapacity || studioCapacity <= 0) {
    return { valid: false, error: 'Capacity must be greater than 0' };
  }
  if (!studioLocation || typeof studioLocation !== 'string') {
    return { valid: false, error: 'Studio location is required and must be a string' };
  }
  if (!studioHourlyRate || studioHourlyRate <= 0) {
    return { valid: false, error: 'Hourly rate must be greater than 0' };
  }
  return { valid: true };
};

const addStudio = async (req, res) => {
  const { studioName, studioCapacity, studioLocation, studioHourlyRate } = req.body;

  const validation = validateStudioInputs(studioName, studioCapacity, studioLocation, studioHourlyRate);
  if (!validation.valid) return res.status(400).json({ error: validation.error });

  try {
    await pool.query('CALL add_studio(?, ?, ?, ?)', [
      studioName,
      studioCapacity,
      studioLocation,
      studioHourlyRate,
    ]);

    res.status(201).json({
      message: 'Studio added successfully',
      studio: { name: studioName, capacity: studioCapacity, location: studioLocation, hourlyRate: studioHourlyRate },
    });
  } catch (err) {
    handleError(err, res, 'Error adding studio');
  }
};

const updateStudio = async (req, res) => {
  const { studioId, newStudioName, newStudioCapacity, newStudioLocation, newStudioHourlyRate } = req.body;

  if (!studioId || !newStudioName || !newStudioCapacity || !newStudioLocation || !newStudioHourlyRate) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  const validation = validateStudioInputs(newStudioName, newStudioCapacity, newStudioLocation, newStudioHourlyRate);
  if (!validation.valid) return res.status(400).json({ error: validation.error });

  try {
    const [studioCheck] = await pool.query('SELECT id FROM studios WHERE id = ?', [studioId]);
    
    if (studioCheck.length === 0) {
      return res.status(404).json({ error: `Studio with ID ${studioId} not found` });
    }

    const [result] = await pool.query('CALL update_studio(?, ?, ?, ?, ?)', [
      studioId,
      newStudioName,
      newStudioCapacity,
      newStudioLocation,
      newStudioHourlyRate,
    ]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: `Studio with ID ${studioId} could not be updated` });
    }

    res.status(200).json({ message: 'Studio updated successfully' });
  } catch (err) {
    if (err.code === '45000') {
      return res.status(400).json({ error: 'A studio with the new name already exists. Please choose a different name.' });
    }
    handleError(err, res, 'An unexpected error occurred while updating the studio');
  }
};


const deleteStudio = async (req, res) => {
  const { studioId } = req.body;

  if (!studioId) {
    return res.status(400).json({ error: 'Studio ID is required' });
  }

  try {
    const [result] = await pool.query('CALL delete_studio(?)', [studioId]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: `Studio with ID ${studioId} not found` });
    }

    res.status(200).json({ message: 'Studio deleted successfully' });
  } catch (err) {
    if (err.sqlState === '45000') {
      return res.status(404).json({ error: 'Studio not found' });
    }
    handleError(err, res, 'Error deleting studio');
  }
};

const addEquipment = async (req, res) => {
  const { equipmentName, equipmentType, equipmentQuantity, equipmentHourlyRate } = req.body;

  if (!equipmentName || !equipmentType || !equipmentQuantity || !equipmentHourlyRate) {
    return res.status(400).json({ error: 'All fields are required' });
  }
  if (equipmentQuantity <= 0) {
    return res.status(400).json({ error: 'Quantity must be greater than 0' });
  }
  if (equipmentHourlyRate <= 0) {
    return res.status(400).json({ error: 'Hourly rate must be greater than 0' });
  }

  try {
    const [existingEquipment] = await pool.query(
      'SELECT 1 FROM equipments WHERE name = ?',
      [equipmentName]
    );

    if (existingEquipment.length > 0) {
      return res.status(400).json({ error: 'Equipment with this name already exists' });
    }

    await pool.query('CALL add_equipment(?, ?, ?, ?)', [
      equipmentName,
      equipmentType,
      equipmentQuantity,
      equipmentHourlyRate,
    ]);

    res.status(201).json({
      message: 'Equipment added successfully',
      equipment: { name: equipmentName, type: equipmentType, quantity: equipmentQuantity, hourlyRate: equipmentHourlyRate },
    });
  } catch (err) {
    handleError(err, res, 'Failed to add equipment');
  }
};

const updateEquipment = async (req, res) => {
  const { equipmentName, newEquipmentName, newEquipmentType, newEquipmentQuantity, newHourlyRate } = req.body;

  if (!equipmentName || !newEquipmentName || !newEquipmentType || !newEquipmentQuantity || !newHourlyRate) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    await pool.query('CALL update_equipment(?, ?, ?, ?, ?)', [
      equipmentName,
      newEquipmentName,
      newEquipmentType,
      newEquipmentQuantity,
      newHourlyRate,
    ]);

    res.status(200).json({ message: 'Equipment updated successfully' });
  } catch (err) {
    handleError(err, res, 'Failed to update equipment');
  }
};

const deleteEquipment = async (req, res) => {
  const { equipmentName } = req.body;

  if (!equipmentName) {
    return res.status(400).json({ error: 'Equipment name is required' });
  }

  try {
    const [result] = await pool.query('CALL delete_equipment(?)', [equipmentName]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Equipment not found' });
    }

    res.status(200).json({ message: 'Equipment deleted successfully' });
  } catch (err) {
    handleError(err, res, 'Failed to delete equipment');
  }
};

const addPhotographer = async (req, res) => {
  const { photographerName, photographerContact, photographerSpecialty, photographerHourlyRate } = req.body;

  if (!photographerName || !photographerContact || !photographerSpecialty || !photographerHourlyRate) {
    return res.status(400).json({
      error: 'All fields are required: photographerName, photographerContact, photographerSpecialty, photographerHourlyRate'
    });
  }

  try {
    await pool.query('CALL add_photographer(?, ?, ?, ?)', [
      photographerName,
      photographerContact,
      photographerSpecialty,
      photographerHourlyRate
    ]);

    res.status(201).json({
      message: 'Photographer added successfully',
      photographer: { name: photographerName, contact: photographerContact, specialty: photographerSpecialty, hourlyRate: photographerHourlyRate },
    });
  } catch (err) {
    handleError(err, res, 'Failed to add photographer');
  }
};

const updatePhotographer = async (req, res) => {
  const { photographerName, newPhotographerName, newPhotographerContact, newPhotographerSpecialty, newPhotographerHourlyRate } = req.body;

  if (!photographerName || !newPhotographerName || !newPhotographerContact || !newPhotographerSpecialty || !newPhotographerHourlyRate) {
    return res.status(400).json({
      error: 'All fields are required: photographerName, newPhotographerName, newPhotographerContact, newPhotographerSpecialty, newPhotographerHourlyRate'
    });
  }

  try {
    const [result] = await pool.query('CALL update_photographer(?, ?, ?, ?, ?)', [
      photographerName,
      newPhotographerName,
      newPhotographerContact,
      newPhotographerSpecialty,
      newPhotographerHourlyRate
    ]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Photographer not found' });
    }

    res.status(200).json({ message: 'Photographer updated successfully' });
  } catch (err) {
    handleError(err, res, 'Failed to update photographer');
  }
};

const deletePhotographer = async (req, res) => {
  const { photographerName } = req.body;

  if (!photographerName) {
    return res.status(400).json({ error: 'Photographer name is required' });
  }

  try {
    const [result] = await pool.query('CALL delete_photographer(?)', [photographerName]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Photographer not found' });
    }

    res.status(200).json({ message: 'Photographer deleted successfully' });
  } catch (err) {
    handleError(err, res, 'Failed to delete photographer');
  }
};

const getPhotographers = async (req, res) => {
  try {
    const query = `
      SELECT 
        photographer_id, 
        photographer_name, 
        photographer_contact, 
        photographer_specialty, 
        photographer_hourly_rate, 
        photographer_created_at
      FROM photographers_view_for_admin;
    `;
    const [photographers] = await pool.query(query);
    res.status(200).json(photographers);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


module.exports = {
  getAllReservationsForAdmin,
  addStudio,
  updateStudio,
  deleteStudio,
  addEquipment,
  updateEquipment,
  deleteEquipment,
  addPhotographer,
  updatePhotographer,
  deletePhotographer,
  getPhotographers,
};
