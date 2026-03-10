const Bet = require('../models/Bet');
const Match = require('../models/Match');
const User = require('../models/User');

exports.placeBet = async (req, res) => {
  try {
    const { matchId, betType, selection, odds, amount } = req.body;
    
    const match = await Match.findById(matchId);
    if (!match) {
      return res.status(404).json({ message: 'Partido no encontrado' });
    }
    
    if (match.status === 'finished' || match.status === 'cancelled') {
      return res.status(400).json({ message: 'No se puede apostar en este partido' });
    }
    
    const user = await User.findById(req.user._id);
    
    if (user.balance < amount) {
      return res.status(400).json({ message: 'Saldo insuficiente' });
    }
    
    const bet = new Bet({
      user: user._id,
      match: matchId,
      betType,
      selection,
      odds,
      amount,
      potentialWin: amount * odds
    });
    
    user.balance -= amount;
    
    await bet.save();
    await user.save();
    
    res.status(201).json({
      bet: bet,
      newBalance: user.balance
    });
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

exports.getUserBets = async (req, res) => {
  try {
    const { status } = req.query;
    let query = { user: req.user._id };
    
    if (status) query.status = status;
    
    const bets = await Bet.find(query)
      .populate('match')
      .sort({ createdAt: -1 });
    
    res.json(bets);
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

exports.getBetById = async (req, res) => {
  try {
    const bet = await Bet.findOne({
      _id: req.params.id,
      user: req.user._id
    }).populate('match');
    
    if (!bet) {
      return res.status(404).json({ message: 'Apuesta no encontrada' });
    }
    
    res.json(bet);
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

exports.settleBets = async (req, res) => {
  try {
    const { matchId, result } = req.body;
    
    const match = await Match.findById(matchId);
    if (!match) {
      return res.status(404).json({ message: 'Partido no encontrado' });
    }
    
    const bets = await Bet.find({ match: matchId, status: 'pending' });
    
    for (const bet of bets) {
      let won = false;
      
      switch (bet.betType) {
        case 'homeWin':
          won = match.homeScore > match.awayScore && bet.selection === match.homeTeam;
          break;
        case 'draw':
          won = match.homeScore === match.awayScore;
          break;
        case 'awayWin':
          won = match.awayScore > match.homeScore && bet.selection === match.awayTeam;
          break;
        case 'over25':
          won = match.homeScore + match.awayScore > 2.5;
          break;
        case 'under25':
          won = match.homeScore + match.awayScore < 2.5;
          break;
        case 'bothTeamsScore':
          won = match.homeScore > 0 && match.awayScore > 0;
          break;
        case 'doubleChance1X':
          won = match.homeScore >= match.awayScore;
          break;
        case 'doubleChance12':
          won = match.homeScore !== match.awayScore;
          break;
        case 'doubleChanceX2':
          won = match.awayScore >= match.homeScore;
          break;
      }
      
      bet.status = won ? 'won' : 'lost';
      bet.result = result;
      
      if (won) {
        const user = await User.findById(bet.user);
        user.balance += bet.potentialWin;
        await user.save();
      }
      
      await bet.save();
    }
    
    res.json({ message: `Se liquidaron ${bets.length} apuestas` });
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};
