class ModalService {
  constructor() {
    this.modal = document.getElementById('bet-modal');
    this.overlay = this.modal.querySelector('.modal-overlay');
    this.closeBtn = document.getElementById('modal-close');
    this.currentMatch = null;
    this.selectedBet = null;

    this.init();
  }

  init() {
    this.closeBtn.addEventListener('click', () => this.close());
    this.overlay.addEventListener('click', () => this.close());
    
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') this.close();
    });
  }

  open(match) {
    this.currentMatch = match;
    this.selectedBet = null;
    
    document.getElementById('modal-home-team').textContent = match.homeTeam;
    document.getElementById('modal-away-team').textContent = match.awayTeam;
    
    this.renderBetOptions(match);
    
    this.modal.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
  }

  close() {
    this.modal.classList.add('hidden');
    document.body.style.overflow = '';
    this.currentMatch = null;
    this.selectedBet = null;
  }

  renderBetOptions(match) {
    const container = document.getElementById('bet-options-modal');
    const oddsGroups = matchService.getOddsGroups();
    
    container.innerHTML = oddsGroups.map(group => `
      <div class="bet-option-group">
        <div class="bet-option-title">${group.title}</div>
        <div class="bet-option-btns">
          ${group.odds.map(oddType => {
            const odd = match.odds[oddType];
            let selection = '';
            
            switch(oddType) {
              case 'homeWin': selection = match.homeTeam; break;
              case 'draw': selection = 'Empate'; break;
              case 'awayWin': selection = match.awayTeam; break;
              case 'over25': selection = 'Más de 2.5'; break;
              case 'under25': selection = 'Menos de 2.5'; break;
              case 'bothTeamsScore': selection = 'Sí'; break;
              case 'doubleChance1X': selection = '1X'; break;
              case 'doubleChance12': selection = '12'; break;
              case 'doubleChanceX2': selection = 'X2'; break;
            }
            
            return `
              <button class="bet-option-btn" data-type="${oddType}" data-selection="${selection}" data-odds="${odd}">
                ${selection}
                <span class="odds">@${odd.toFixed(2)}</span>
              </button>
            `;
          }).join('')}
        </div>
      </div>
    `).join('');

    container.querySelectorAll('.bet-option-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        container.querySelectorAll('.bet-option-btn').forEach(b => b.classList.remove('selected'));
        btn.classList.add('selected');
        
        this.selectedBet = {
          type: btn.dataset.type,
          selection: btn.dataset.selection,
          odds: parseFloat(btn.dataset.odds)
        };
      });
    });
  }

  confirmSelection() {
    if (!this.selectedBet) {
      window.toastService.show('Selecciona una apuesta', 'warning');
      return;
    }

    window.betService.addBet(
      this.currentMatch,
      this.selectedBet.type,
      this.selectedBet.selection,
      this.selectedBet.odds
    );
    
    window.toastService.show('Apuesta agregada al ticket', 'success');
    this.close();
  }
}

window.modalService = new ModalService();
