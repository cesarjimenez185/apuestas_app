const mongoose = require('mongoose');

const betSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  match: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Match',
    required: true
  },
  betType: {
    type: String,
    required: true,
    enum: ['homeWin', 'draw', 'awayWin', 'over25', 'under25', 'bothTeamsScore', 'doubleChance1X', 'doubleChance12', 'doubleChanceX2']
  },
  selection: {
    type: String,
    required: true
  },
  odds: {
    type: Number,
    required: true
  },
  amount: {
    type: Number,
    required: true,
    min: 1
  },
  potentialWin: {
    type: Number,
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'won', 'lost', 'cancelled'],
    default: 'pending'
  },
  result: {
    type: String,
    default: null
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Bet', betSchema);
