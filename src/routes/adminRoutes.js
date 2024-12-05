const express = require('express');
const { authenticate, authorizeAdmin } = require('../middleware/auth');
const {
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
} = require('../controllers/adminController.js');
const router = express.Router();

// Route untuk halaman dashboard admin
router.get('/dashboard', authenticate, authorizeAdmin, (req, res) => {
  res.status(200).json({ message: 'Welcome to the admin dashboard!' });
});

// Studio Routes
router.post('/studio', authenticate, authorizeAdmin, addStudio);
router.put('/studio', authenticate, authorizeAdmin, updateStudio);
router.delete('/studio', authenticate, authorizeAdmin, deleteStudio);
router.get('/studio/:studioId', authenticate, authorizeAdmin, viewStudio);

// Equipment Routes
router.post('/equipment', authenticate, authorizeAdmin, addEquipment);
router.put('/equipment', authenticate, authorizeAdmin, updateEquipment);
router.delete('/equipment', authenticate, authorizeAdmin, deleteEquipment);
router.get('/equipment/:equipmentId', authenticate, authorizeAdmin, viewEquipment);

// Photographer Routes
router.post('/photographer', authenticate, authorizeAdmin, addPhotographer);
router.put('/photographer', authenticate, authorizeAdmin, updatePhotographer);
router.delete('/photographer', authenticate, authorizeAdmin, deletePhotographer);
router.get('/photographer/:photographerId', authenticate, authorizeAdmin, viewPhotographer);

// AuditLogs
router.get('/auditLogs',authenticate, authorizeAdmin, getAllAuditLogs); 
router.get('/auditLogs/:id', authenticate, authorizeAdmin, getAuditLogById); 

module.exports = router;