const express = require('express');
const { authenticate } = require('../middleware/auth');
const {
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
  createPhotographerBooking
} = require('../controllers/userController.js');
const router = express.Router();

router.get('/dashboard', authenticate, (req, res) => {
  res.status(200).json({ message: 'Welcome to the user dashboard!' });
});

router.get('/studios', getStudios);
router.get('/equipments', getEquipment);
router.get('/photographers', getPhotographers);

router.get('/allReservations', getAllReservations);
router.get('/studioReservations', authenticate, getUserStudioReservations);
router.get('/equipmentRentals', authenticate, getUserEquipmentRentals);
router.get('/photographerBookings', authenticate, getUserPhotographerBookings);

router.post('/studioPayment', authenticate, processStudioPayment);

router.post('/reserveStudio', authenticate, createStudioReservation);
router.post('/rentEquipment', authenticate, createEquipmentRental);
router.post('/bookPhotographer', authenticate, createPhotographerBooking);

module.exports = router;