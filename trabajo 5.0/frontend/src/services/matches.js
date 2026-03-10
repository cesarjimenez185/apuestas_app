class MatchService {
  constructor() {
    this.matches = [];
    this.liveMatches = [];
    this.currentLeague = 'all';
    this.currentFilter = 'all';
    this.updateInterval = null;
  }

  async loadMatches(league = null, status = null) {
    try {
      this.matches = await api.getMatches(league, status);
      return this.matches;
    } catch (error) {
      console.error('Error loading matches:', error);
      throw error;
    }
  }

  async loadLiveMatches() {
    try {
      this.liveMatches = await api.getLiveMatches();
      return this.liveMatches;
    } catch (error) {
      console.error('Error loading live matches:', error);
      throw error;
    }
  }

  async seedMatchesIfNeeded() {
    try {
      const matches = await api.getMatches();
      if (matches.length === 0) {
        await api.seedMatches();
      }
    } catch (error) {
      console.error('Error seeding matches:', error);
    }
  }

  startLiveUpdates() {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
    }
    
    this.updateInterval = setInterval(async () => {
      if (window.appState.currentPage === 'live') {
        await this.loadLiveMatches();
        window.renderService.renderLiveMatches(this.liveMatches);
      }
    }, 30000);
  }

  stopLiveUpdates() {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
      this.updateInterval = null;
    }
  }

  setLeague(league) {
    this.currentLeague = league;
  }

  setFilter(filter) {
    this.currentFilter = filter;
  }

  formatDate(dateString) {
    const date = new Date(dateString);
    const now = new Date();
    const diff = date - now;
    
    if (diff < 0 && diff > -7200000) {
      return 'En vivo';
    }

    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (days > 0) {
      return `Hoy ${date.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' })}`;
    }

    if (hours > 0) {
      return `En ${hours}h`;
    }

    return date.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' });
  }

  getOddsForMatch(match) {
    return [
      { type: 'homeWin', name: match.homeTeam, odds: match.odds.homeWin },
      { type: 'draw', name: 'Empate', odds: match.odds.draw },
      { type: 'awayWin', name: match.awayTeam, odds: match.odds.awayWin },
      { type: 'over25', name: '+2.5', odds: match.odds.over25 },
      { type: 'under25', name: '-2.5', odds: match.odds.under25 },
      { type: 'bothTeamsScore', name: 'Ambos', odds: match.odds.bothTeamsScore },
      { type: 'doubleChance1X', name: '1X', odds: match.odds.doubleChance1X },
      { type: 'doubleChance12', name: '12', odds: match.odds.doubleChance12 },
      { type: 'doubleChanceX2', name: 'X2', odds: match.odds.doubleChanceX2 }
    ];
  }

  getOddsGroups() {
    return [
      {
        title: 'Ganador',
        odds: ['homeWin', 'draw', 'awayWin']
      },
      {
        title: 'Más/Menos 2.5',
        odds: ['over25', 'under25']
      },
      {
        title: 'Doble Oportunidad',
        odds: ['doubleChance1X', 'doubleChance12', 'doubleChanceX2']
      }
    ];
  }
}

window.matchService = new MatchService();
