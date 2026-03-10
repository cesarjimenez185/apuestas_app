class RenderService {
  constructor() {
    this.matchesContainer = document.getElementById('matches-container');
    this.liveContainer = document.getElementById('live-matches-container');
  }

  renderMatches(matches) {
    if (matches.length === 0) {
      this.matchesContainer.innerHTML = `
        <div class="empty-state">
          <i class="fas fa-futbol"></i>
          <p>No hay partidos disponibles</p>
        </div>
      `;
      return;
    }

    this.matchesContainer.innerHTML = matches.map(match => this.createMatchCard(match)).join('');
    
    this.attachMatchEvents();
  }

  renderLiveMatches(matches) {
    if (matches.length === 0) {
      this.liveContainer.innerHTML = `
        <div class="empty-state">
          <i class="fas fa-futbol"></i>
          <p>No hay partidos en vivo en este momento</p>
        </div>
      `;
      return;
    }

    this.liveContainer.innerHTML = matches.map(match => this.createMatchCard(match, true)).join('');
    
    this.attachMatchEvents();
  }

  createMatchCard(match, isLive = false) {
    const statusClass = match.status === 'live' ? 'live' : '';
    const statusText = match.status === 'live' 
      ? `${match.minute}'` 
      : matchService.formatDate(match.date);

    const scoreHtml = match.status === 'live' || match.status === 'finished'
      ? `
        <div class="match-score">
          <span class="score">${match.homeScore}</span>
          <span class="score-separator">-</span>
          <span class="score">${match.awayScore}</span>
          ${match.status === 'live' ? `<span class="match-minute">${match.minute}'</span>` : ''}
        </div>
      `
      : `
        <div class="match-score">
          <span class="match-date">${matchService.formatDate(match.date)}</span>
        </div>
      `;

    const oddsGroups = matchService.getOddsGroups();

    return `
      <div class="match-card" data-match-id="${match._id}">
        <div class="match-header">
          <span class="match-league">${match.league}</span>
          <span class="match-status ${statusClass}">${statusText}</span>
        </div>
        
        <div class="match-teams">
          <div class="team">
            <div class="team-icon">⚽</div>
            <div class="team-name">${match.homeTeam}</div>
          </div>
          ${scoreHtml}
          <div class="team">
            <div class="team-icon">⚽</div>
            <div class="team-name">${match.awayTeam}</div>
          </div>
        </div>

        ${match.status !== 'finished' ? `
          <div class="match-odds">
            ${oddsGroups.map(group => `
              <div class="odds-group">
                <div class="odds-group-title">${group.title}</div>
                <div class="odds-group-btns">
                  ${group.odds.map(oddType => {
                    const odd = match.odds[oddType];
                    let selection = '';
                    
                    switch(oddType) {
                      case 'homeWin': selection = match.homeTeam; break;
                      case 'draw': selection = 'X'; break;
                      case 'awayWin': selection = match.awayTeam; break;
                      case 'over25': selection = '+2.5'; break;
                      case 'under25': selection = '-2.5'; break;
                      case 'bothTeamsScore': selection = 'BM'; break;
                      case 'doubleChance1X': selection = '1X'; break;
                      case 'doubleChance12': selection = '12'; break;
                      case 'doubleChanceX2': selection = 'X2'; break;
                    }
                    
                    return `
                      <button class="odds-btn" data-type="${oddType}" data-selection="${selection}" data-odds="${odd}">
                        ${selection}
                        <span class="odds-value">@${odd.toFixed(2)}</span>
                      </button>
                    `;
                  }).join('')}
                </div>
              </div>
            `).join('')}
          </div>
        ` : ''}
      </div>
    `;
  }

  attachMatchEvents() {
    document.querySelectorAll('.match-card .odds-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        
        const card = btn.closest('.match-card');
        const matchId = card.dataset.matchId;
        
        const allMatches = window.matchService.matches.concat(window.matchService.liveMatches);
        const match = allMatches.find(m => m._id === matchId);
        
        if (!match) return;

        const betType = btn.dataset.type;
        const selection = btn.dataset.selection;
        const odds = parseFloat(btn.dataset.odds);
        
        window.betService.addBet(match, betType, selection, odds);
        window.toastService.show('Apuesta agregada al ticket', 'success');
      });
    });
  }

  renderBets(bets) {
    const container = document.getElementById('bets-list');
    
    if (!bets || bets.length === 0) {
      container.innerHTML = `
        <div class="empty-state">
          <i class="fas fa-ticket-alt"></i>
          <p>No hay apuestas</p>
        </div>
      `;
      return;
    }

    container.innerHTML = bets.map(bet => `
      <div class="bet-history-item">
        <div class="bet-history-info">
          <div class="bet-history-match">
            ${bet.match?.homeTeam || 'Local'} vs ${bet.match?.awayTeam || 'Visitante'}
          </div>
          <div class="bet-history-type">
            ${window.betService.getBetTypeName(bet.betType)} - ${bet.selection}
          </div>
        </div>
        <div class="bet-history-amount">
          <div class="bet-history-odds">
            $${bet.amount.toFixed(2)} @ ${bet.odds.toFixed(2)}
          </div>
          <div class="bet-history-potential">
            $${bet.potentialWin.toFixed(2)}
          </div>
        </div>
        <span class="bet-history-status ${bet.status}">
          ${bet.status === 'pending' ? 'Pendiente' : bet.status === 'won' ? 'Ganada' : 'Perdida'}
        </span>
      </div>
    `).join('');
  }

  renderProfile(user, stats) {
    document.getElementById('profile-name').textContent = user.name;
    document.getElementById('profile-email').textContent = user.email;
    document.getElementById('profile-balance').textContent = `$${user.balance.toFixed(2)}`;
    document.getElementById('user-balance').textContent = `$${user.balance.toFixed(2)}`;
    
    if (stats) {
      document.getElementById('profile-won').textContent = stats.won || 0;
      document.getElementById('profile-total').textContent = `$${(stats.total || 0).toFixed(2)}`;
    }
  }

  showAuthError(message) {
    const errorEl = document.getElementById('auth-error');
    errorEl.textContent = message;
    errorEl.classList.remove('hidden');
    
    setTimeout(() => {
      errorEl.classList.add('hidden');
    }, 5000);
  }

  clearAuthError() {
    const errorEl = document.getElementById('auth-error');
    errorEl.classList.add('hidden');
  }
}

window.renderService = new RenderService();
