const express = require('express');
const { authenticate } = require('../middleware/auth');
const {
    getStudios,
    getEquipment,
    getPhotographers,
    reserveStudio,
    rentEquipment,
    bookPhotographer,
} = require('../controllers/userController.js');
const router = express.Router();

// Route untuk halaman dashboard user
router.get('/dashboard', authenticate, (req, res) => {
  res.status(200).json({ message: 'Welcome!' });
});

router.get('/studios', authenticate, getStudios);
router.get('/equipment', authenticate, getEquipment);
router.get('/photographers', authenticate, getPhotographers);

router.post('/studio', authenticate, reserveStudio);
router.post('/equipment', authenticate, rentEquipment);
router.post('/photographer', authenticate, bookPhotographer);
module.exports = router;