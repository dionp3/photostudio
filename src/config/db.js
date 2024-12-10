const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: "localhost",
  user: "dionp6",
  password: "Dp061203",
  database: "photostudio",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});



module.exports = pool;