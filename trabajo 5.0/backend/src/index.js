const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const config = require('./config/config');

const authRoutes = require('./routes/auth');
const matchRoutes = require('./routes/matches');
const betRoutes = require('./routes/bets');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/matches', matchRoutes);
app.use('/api/bets', betRoutes);

app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'BetFoot API is running' });
});

mongoose.connect(config.mongoUri)
  .then(() => {
    console.log('Conectado a MongoDB');
    app.listen(config.port, () => {
      console.log(`Servidor corriendo en puerto ${config.port}`);
    });
  })
  .catch(err => {
    console.error('Error conectando a MongoDB:', err);
    process.exit(1);
  });

module.exports = app;
