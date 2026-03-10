const Match = require('../models/Match');

exports.getAllMatches = async (req, res) => {
  try {
    const { league, status } = req.query;
    let query = {};
    
    if (league) query.league = league;
    if (status) query.status = status;
    
    const matches = await Match.find(query).sort({ date: 1 });
    res.json(matches);
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

exports.getLiveMatches = async (req, res) => {
  try {
    const matches = await Match.find({ status: 'live' }).sort({ date: 1 });
    res.json(matches);
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

exports.getMatchById = async (req, res) => {
  try {
    const match = await Match.findById(req.params.id);
    if (!match) {
      return res.status(404).json({ message: 'Partido no encontrado' });
    }
    res.json(match);
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

exports.createMatch = async (req, res) => {
  try {
    const match = new Match(req.body);
    await match.save();
    res.status(201).json(match);
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

exports.updateMatch = async (req, res) => {
  try {
    const match = await Match.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    if (!match) {
      return res.status(404).json({ message: 'Partido no encontrado' });
    }
    res.json(match);
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

exports.updateLiveScore = async (req, res) => {
  try {
    const { homeScore, awayScore, minute, status, stats } = req.body;
    const match = await Match.findByIdAndUpdate(
      req.params.id,
      { homeScore, awayScore, minute, status, stats },
      { new: true }
    );
    if (!match) {
      return res.status(404).json({ message: 'Partido no encontrado' });
    }
    res.json(match);
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

exports.seedMatches = async (req, res) => {
  try {
    const leagues = ['Premier League', 'La Liga', 'Champions League', 'Serie A', 'Bundesliga'];
    const teams = {
      'Premier League': ['Manchester City', 'Liverpool', 'Chelsea', 'Arsenal', 'Manchester United', 'Tottenham', 'Newcastle', 'Aston Villa'],
      'La Liga': ['Real Madrid', 'Barcelona', 'Atlético Madrid', 'Sevilla', 'Real Betis', 'Valencia', 'Villarreal', 'Athletic Bilbao'],
      'Champions League': ['Bayern Munich', 'PSG', 'Inter Milan', 'AC Milan', 'Dortmund', 'RB Leipzig', 'Porto', 'Ajax'],
      'Serie A': ['Juventus', 'Inter Milan', 'AC Milan', 'Napoli', 'Roma', 'Lazio', 'Fiorentina', 'Atalanta'],
      'Bundesliga': ['Bayern Munich', 'Dortmund', 'RB Leipzig', 'Leverkusen', 'Frankfurt', 'Stuttgart', 'Union Berlin', 'Freiburg']
    };
    
    const matches = [];
    const now = new Date();
    
    for (const league of leagues) {
      for (let i = 0; i < 4; i++) {
        const homeTeam = teams[league][Math.floor(Math.random() * teams[league].length)];
        let awayTeam = teams[league][Math.floor(Math.random() * teams[league].length)];
        while (awayTeam === homeTeam) {
          awayTeam = teams[league][Math.floor(Math.random() * teams[league].length)];
        }
        
        const hoursFromNow = Math.floor(Math.random() * 72) - 24;
        const matchDate = new Date(now.getTime() + hoursFromNow * 60 * 60 * 1000);
        
        const isLive = hoursFromNow <= 0 && hoursFromNow > -2;
        const isFinished = hoursFromNow <= -2;
        
        const baseOdds = 1.5 + Math.random() * 2;
        
        matches.push({
          homeTeam,
          awayTeam,
          league,
          date: matchDate,
          status: isLive ? 'live' : (isFinished ? 'finished' : 'scheduled'),
          minute: isLive ? Math.floor(Math.random() * 90) + 1 : 0,
          homeScore: isFinished ? Math.floor(Math.random() * 5) : (isLive ? Math.floor(Math.random() * 3) : 0),
          awayScore: isFinished ? Math.floor(Math.random() * 5) : (isLive ? Math.floor(Math.random() * 3) : 0),
          odds: {
            homeWin: parseFloat((baseOdds + Math.random() * 0.5).toFixed(2)),
            draw: parseFloat((baseOdds + 0.3 + Math.random() * 0.3).toFixed(2)),
            awayWin: parseFloat((baseOdds + Math.random() * 0.5).toFixed(2)),
            over25: parseFloat((1.7 + Math.random() * 0.3).toFixed(2)),
            under25: parseFloat((1.9 + Math.random() * 0.3).toFixed(2)),
            bothTeamsScore: parseFloat((1.6 + Math.random() * 0.4).toFixed(2)),
            doubleChance1X: parseFloat((1.2 + Math.random() * 0.2).toFixed(2)),
            doubleChance12: parseFloat((1.3 + Math.random() * 0.2).toFixed(2)),
            doubleChanceX2: parseFloat((1.2 + Math.random() * 0.2).toFixed(2))
          },
          stats: isLive ? {
            possession: { home: Math.floor(Math.random() * 40) + 30, away: Math.floor(Math.random() * 40) + 30 },
            shots: { home: Math.floor(Math.random() * 15) + 5, away: Math.floor(Math.random() * 15) + 5 },
            shotsOnTarget: { home: Math.floor(Math.random() * 8) + 1, away: Math.floor(Math.random() * 8) + 1 },
            corners: { home: Math.floor(Math.random() * 8) + 1, away: Math.floor(Math.random() * 8) + 1 }
          } : null
        });
      }
    }
    
    await Match.deleteMany({});
    const createdMatches = await Match.insertMany(matches);
    res.json({ message: `Se crearon ${createdMatches.length} partidos`, matches: createdMatches });
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};
