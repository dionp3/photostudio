const nodemailer = require('nodemailer');

const sendResetPasswordEmail = async (email, resetToken) => {
  const transporter = nodemailer.createTransport({
    service: 'Gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });

  const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;

  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'Reset Password Request',
    text: `You requested a password reset. Click the link below to reset your password:\n\n${resetUrl}`,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log('Reset password email sent to:', email);
  } catch (error) {
    console.error('Error sending reset password email:', error);
    throw error; 
  }
};


module.exports = { sendResetPasswordEmail };
