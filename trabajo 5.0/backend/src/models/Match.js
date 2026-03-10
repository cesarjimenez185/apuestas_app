const mongoose = require('mongoose');

const matchSchema = new mongoose.Schema({
  homeTeam: {
    type: String,
    required: true
  },
  awayTeam: {
    type: String,
    required: true
  },
  league: {
    type: String,
    required: true,
    enum: ['Premier League', 'La Liga', 'Champions League', 'Serie A', 'Bundesliga']
  },
  date: {
    type: Date,
    required: true
  },
  status: {
    type: String,
    enum: ['scheduled', 'live', 'finished', 'cancelled'],
    default: 'scheduled'
  },
  minute: {
    type: Number,
    default: 0
  },
  homeScore: {
    type: Number,
    default: 0
  },
  awayScore: {
    type: Number,
    default: 0
  },
  odds: {
    homeWin: { type: Number, default: 1.0 },
    draw: { type: Number, default: 1.0 },
    awayWin: { type: Number, default: 1.0 },
    over25: { type: Number, default: 1.0 },
    under25: { type: Number, default: 1.0 },
    bothTeamsScore: { type: Number, default: 1.0 },
    doubleChance1X: { type: Number, default: 1.0 },
    doubleChance12: { type: Number, default: 1.0 },
    doubleChanceX2: { type: Number, default: 1.0 }
  },
  stats: {
    possession: { home: Number, away: Number },
    shots: { home: Number, away: Number },
    shotsOnTarget: { home: Number, away: Number },
    corners: { home: Number, away: Number }
  }
});

module.exports = mongoose.model('Match', matchSchema);
