class AppState {
  constructor() {
    this.currentPage = 'home';
    this.currentLeague = 'all';
    this.currentFilter = 'all';
  }
}

window.appState = new AppState();

document.addEventListener('DOMContentLoaded', async () => {
  const loginScreen = document.getElementById('login-screen');
  const mainApp = document.getElementById('main-app');
  
  if (authService.isAuthenticated()) {
    loginScreen.classList.add('hidden');
    mainApp.classList.remove('hidden');
    await initializeApp();
  } else {
    loginScreen.classList.remove('hidden');
    mainApp.classList.add('hidden');
  }

  initAuthTabs();
  initNavigation();
  initSidebar();
  initBetSlip();
  initPlaceBet();
});

async function initializeApp() {
  try {
    await authService.refreshProfile();
    const user = authService.getUser();
    window.renderService.renderProfile(user);
    
    await matchService.seedMatchesIfNeeded();
    await loadMatches();
    
    matchService.startLiveUpdates();
  } catch (error) {
    console.error('Error initializing app:', error);
    authService.logout();
    window.location.reload();
  }
}

async function loadMatches() {
  try {
    const league = window.appState.currentLeague === 'all' ? null : window.appState.currentLeague;
    const status = window.appState.currentFilter === 'all' ? null : window.appState.currentFilter;
    
    const matches = await matchService.loadMatches(league, status);
    matchService.matches = matches;
    window.renderService.renderMatches(matches);
  } catch (error) {
    window.toastService.error('Error cargando partidos');
  }
}

function initAuthTabs() {
  const tabs = document.querySelectorAll('.auth-tab');
  const loginForm = document.getElementById('login-form');
  const registerForm = document.getElementById('register-form');

  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
      
      const tabName = tab.dataset.tab;
      if (tabName === 'login') {
        loginForm.classList.remove('hidden');
        registerForm.classList.add('hidden');
      } else {
        loginForm.classList.add('hidden');
        registerForm.classList.remove('hidden');
      }
      
      window.renderService.clearAuthError();
    });
  });

  loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const email = document.getElementById('login-email').value;
    const password = document.getElementById('login-password').value;
    
    const result = await authService.login(email, password);
    
    if (result.success) {
      document.getElementById('login-screen').classList.add('hidden');
      document.getElementById('main-app').classList.remove('hidden');
      await initializeApp();
    } else {
      window.renderService.showAuthError(result.error);
    }
  });

  registerForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const name = document.getElementById('register-name').value;
    const email = document.getElementById('register-email').value;
    const password = document.getElementById('register-password').value;
    const confirm = document.getElementById('register-confirm').value;
    
    const result = await authService.register(name, email, password, confirm);
    
    if (result.success) {
      document.getElementById('login-screen').classList.add('hidden');
      document.getElementById('main-app').classList.remove('hidden');
      await initializeApp();
    } else {
      window.renderService.showAuthError(result.error);
    }
  });

  document.getElementById('logout-btn').addEventListener('click', () => {
    authService.logout();
    window.location.reload();
  });
}

function initNavigation() {
  const navLinks = document.querySelectorAll('.nav-link');
  const pages = document.querySelectorAll('.page');

  navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      
      const pageName = link.dataset.page;
      
      navLinks.forEach(l => l.classList.remove('active'));
      link.classList.add('active');
      
      pages.forEach(p => p.classList.remove('active'));
      document.getElementById(`${pageName}-page`).classList.add('active');
      
      window.appState.currentPage = pageName;
      
      if (pageName === 'live') {
        loadLiveMatches();
      } else if (pageName === 'profile') {
        loadProfile();
      } else if (pageName === 'home') {
        loadMatches();
      }

      if (window.innerWidth <= 900) {
        document.getElementById('bet-slip').classList.remove('open');
      }
    });
  });

  document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      
      window.appState.currentFilter = btn.dataset.filter;
      loadMatches();
    });
  });
}

async function loadLiveMatches() {
  try {
    const matches = await matchService.loadLiveMatches();
    matchService.liveMatches = matches;
    window.renderService.renderLiveMatches(matches);
  } catch (error) {
    window.toastService.error('Error cargando partidos en vivo');
  }
}

async function loadProfile() {
  try {
    const user = await authService.refreshProfile();
    const bets = await window.betService.getBetsHistory();
    
    const wonBets = bets.filter(b => b.status === 'won');
    const totalAmount = bets.reduce((sum, b) => sum + b.amount, 0);
    
    window.renderService.renderProfile(user, {
      won: wonBets.length,
      total: totalAmount
    });
    
    window.renderService.renderBets(bets);
  } catch (error) {
    console.error('Error loading profile:', error);
  }
}

function initSidebar() {
  const menuToggle = document.getElementById('menu-toggle');
  const sidebar = document.getElementById('sidebar');
  const sidebarClose = document.getElementById('sidebar-close');
  const leagueItems = document.querySelectorAll('.league-item');

  menuToggle.addEventListener('click', () => {
    sidebar.classList.toggle('open');
  });

  sidebarClose.addEventListener('click', () => {
    sidebar.classList.remove('open');
  });

  leagueItems.forEach(item => {
    item.addEventListener('click', () => {
      leagueItems.forEach(i => i.classList.remove('active'));
      item.classList.add('active');
      
      window.appState.currentLeague = item.dataset.league;
      loadMatches();
      
      if (window.innerWidth <= 1200) {
        sidebar.classList.remove('open');
      }
    });
  });
}

function initBetSlip() {
  const amountInput = document.getElementById('bet-amount');
  const clearBtn = document.getElementById('clear-bets-btn');

  amountInput.addEventListener('input', () => {
    const amount = parseFloat(amountInput.value) || 0;
    const potentialWin = window.betService.calculatePotentialWin(amount);
    document.getElementById('potential-win').textContent = `$${potentialWin.toFixed(2)}`;
  });

  clearBtn.addEventListener('click', () => {
    window.betService.clearBets();
    window.toastService.show('Ticket limpiado');
  });
}

async function initPlaceBet() {
  const placeBetBtn = document.getElementById('place-bet-btn');
  
  placeBetBtn.addEventListener('click', async () => {
    const amount = parseFloat(document.getElementById('bet-amount').value);
    
    if (!amount || amount < 1) {
      window.toastService.warning('Ingresa un monto válido');
      return;
    }

    const user = authService.getUser();
    if (amount > user.balance) {
      window.toastService.error('Saldo insuficiente');
      return;
    }

    try {
      placeBetBtn.disabled = true;
      placeBetBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Procesando...';
      
      await window.betService.placeBet(amount);
      
      await authService.refreshProfile();
      const updatedUser = authService.getUser();
      window.renderService.renderProfile(updatedUser);
      
      document.getElementById('bet-amount').value = 10;
      
      window.toastService.success('Apuesta confirmada!');
      
      if (window.appState.currentPage === 'profile') {
        loadProfile();
      }
    } catch (error) {
      window.toastService.error(error.message);
    } finally {
      placeBetBtn.disabled = false;
      placeBetBtn.innerHTML = '<i class="fas fa-check"></i> Confirmar Apuesta';
    }
  });
}

document.querySelectorAll('.bets-tab').forEach(tab => {
  tab.addEventListener('click', async () => {
    document.querySelectorAll('.bets-tab').forEach(t => t.classList.remove('active'));
    tab.classList.add('active');
    
    const status = tab.dataset.bets === 'all' ? null : tab.dataset.bets;
    const bets = await window.betService.getBetsHistory(status);
    window.renderService.renderBets(bets);
  });
});
