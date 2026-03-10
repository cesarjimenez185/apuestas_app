class BetService {
  constructor() {
    this.bets = [];
  }

  addBet(match, betType, selection, odds) {
    const existingIndex = this.bets.findIndex(b => b.match._id === match._id);
    
    if (existingIndex > -1) {
      this.bets[existingIndex] = { match, betType, selection, odds };
    } else {
      this.bets.push({ match, betType, selection, odds });
    }
    
    this.renderBetslip();
    return this.bets;
  }

  removeBet(index) {
    this.bets.splice(index, 1);
    this.renderBetslip();
    return this.bets;
  }

  clearBets() {
    this.bets = [];
    this.renderBetslip();
  }

  getBets() {
    return this.bets;
  }

  getTotalOdds() {
    if (this.bets.length === 0) return 1;
    return this.bets.reduce((total, bet) => total * bet.odds, 1);
  }

  calculatePotentialWin(amount) {
    return amount * this.getTotalOdds();
  }

  async placeBet(amount) {
    if (this.bets.length === 0) {
      throw new Error('No hay apuestas en el ticket');
    }

    if (amount < 1) {
      throw new Error('El monto mínimo es $1');
    }

    const results = [];
    
    for (const bet of this.bets) {
      try {
        const result = await api.placeBet(
          bet.match._id,
          bet.betType,
          bet.selection,
          bet.odds,
          amount
        );
        results.push(result);
      } catch (error) {
        throw error;
      }
    }

    this.clearBets();
    return results;
  }

  async getBetsHistory(status = null) {
    return api.getUserBets(status);
  }

  renderBetslip() {
    const container = document.getElementById('bet-slip-items');
    const footer = document.getElementById('bet-slip-footer');
    const countEl = document.getElementById('bet-count');
    const totalOddsEl = document.getElementById('total-odds');
    const potentialWinEl = document.getElementById('potential-win');
    const amountInput = document.getElementById('bet-amount');

    countEl.textContent = this.bets.length;

    if (this.bets.length === 0) {
      container.innerHTML = `
        <div class="empty-bet-slip">
          <i class="fas fa-futbol"></i>
          <p>Agrega apuestas para comenzar</p>
        </div>
      `;
      footer.classList.add('hidden');
      return;
    }

    footer.classList.remove('hidden');

    container.innerHTML = this.bets.map((bet, index) => `
      <div class="bet-slip-item" data-index="${index}">
        <button class="remove-bet" onclick="window.betService.removeBet(${index})">
          <i class="fas fa-times"></i>
        </button>
        <div class="match-teams-compact">
          ${bet.match.homeTeam} vs ${bet.match.awayTeam}
        </div>
        <div class="bet-type">${this.getBetTypeName(bet.betType)}</div>
        <div class="bet-selection">${bet.selection}</div>
        <div class="bet-odds">@${bet.odds.toFixed(2)}</div>
      </div>
    `).join('');

    totalOddsEl.textContent = this.getTotalOdds().toFixed(2);
    
    const amount = parseFloat(amountInput.value) || 0;
    potentialWinEl.textContent = `$${this.calculatePotentialWin(amount).toFixed(2)}`;
  }

  getBetTypeName(betType) {
    const names = {
      'homeWin': 'Ganador Local',
      'draw': 'Empate',
      'awayWin': 'Ganador Visitante',
      'over25': 'Más de 2.5',
      'under25': 'Menos de 2.5',
      'bothTeamsScore': 'Ambos Marcan',
      'doubleChance1X': 'Local o Empate',
      'doubleChance12': 'No Empate',
      'doubleChanceX2': 'Visitante o Empate'
    };
    return names[betType] || betType;
  }
}

window.betService = new BetService();
