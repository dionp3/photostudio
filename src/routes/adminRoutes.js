const express = require('express');
const { authenticate, authorizeAdmin } = require('../middleware/auth');
const {
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
  getAllReservationsForAdmin
} = require('../controllers/adminController.js');
const router = express.Router();

router.get('/dashboard', authenticate, authorizeAdmin, (req, res) => {
  res.status(200).json({ message: 'Welcome to the admin dashboard!' });
});

router.get('/reservations', authenticate, authorizeAdmin, getAllReservationsForAdmin);

router.post('/studio', authenticate, authorizeAdmin, addStudio);
router.put('/studio', authenticate, authorizeAdmin, updateStudio);
router.delete('/studio', authenticate, authorizeAdmin, deleteStudio)

router.post('/equipment', authenticate, authorizeAdmin, addEquipment);
router.put('/equipment', authenticate, authorizeAdmin, updateEquipment);
router.delete('/equipment', authenticate, authorizeAdmin, deleteEquipment);

router.get('/photographers', authenticate, authorizeAdmin, getPhotographers);
router.post('/photographer', authenticate, authorizeAdmin, addPhotographer);
router.put('/photographer', authenticate, authorizeAdmin, updatePhotographer);
router.delete('/photographer', authenticate, authorizeAdmin, deletePhotographer);

module.exports = router;