require('dotenv').config();

module.exports = {
  port: process.env.PORT || 3000,
  mongoUri: process.env.MONGO_URI || 'mongodb://localhost:27017/betfoot',
  jwtSecret: process.env.JWT_SECRET || 'betfoot_secret_key_2024',
  jwtExpire: '24h'
};
