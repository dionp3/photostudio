const express = require('express');
const { authenticate, authorizeAdmin } = require('../middleware/auth.js');
const { 
    login, 
    register, 
    registerAdmin, 
    logout, 
    profile, 
    deleteAccount, 
    requestForgotPassword, 
    forgotPassword, 
    editProfile
} = require('../controllers/authController.js');
const router = express.Router();

router.post('/register', register);
router.post('/registerAdmin', authenticate, authorizeAdmin, registerAdmin);
router.post('/login', login);
router.post('/logout', logout);
router.get('/profile', authenticate, profile);
router.put('/editProfile', authenticate, editProfile);
router.delete('/delete', authenticate, deleteAccount);
router.post('/requestForgotPW', requestForgotPassword);
router.post('/forgotPW', forgotPassword);

module.exports = router;