const API_URL = 'http://localhost:3000/api';

class ApiService {
  constructor() {
    this.token = localStorage.getItem('token');
  }

  setToken(token) {
    this.token = token;
    if (token) {
      localStorage.setItem('token', token);
    } else {
      localStorage.removeItem('token');
    }
  }

  getToken() {
    return this.token;
  }

  async request(endpoint, options = {}) {
    const url = `${API_URL}${endpoint}`;
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers
    };

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    try {
      const response = await fetch(url, {
        ...options,
        headers
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || 'Error en la solicitud');
      }

      return data;
    } catch (error) {
      console.error('API Error:', error);
      throw error;
    }
  }

  // Auth endpoints
  async login(email, password) {
    const data = await this.request('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    });
    this.setToken(data.token);
    return data;
  }

  async register(name, email, password) {
    const data = await this.request('/auth/register', {
      method: 'POST',
      body: JSON.stringify({ name, email, password })
    });
    this.setToken(data.token);
    return data;
  }

  async getProfile() {
    return this.request('/auth/profile');
  }

  async updateBalance(amount) {
    return this.request('/auth/balance', {
      method: 'PUT',
      body: JSON.stringify({ amount })
    });
  }

  // Match endpoints
  async getMatches(league = null, status = null) {
    let query = '';
    if (league || status) {
      const params = new URLSearchParams();
      if (league && league !== 'all') params.append('league', league);
      if (status && status !== 'all') params.append('status', status);
      query = `?${params.toString()}`;
    }
    return this.request(`/matches${query}`);
  }

  async getLiveMatches() {
    return this.request('/matches/live');
  }

  async getMatchById(id) {
    return this.request(`/matches/${id}`);
  }

  async seedMatches() {
    return this.request('/matches/seed', {
      method: 'POST'
    });
  }

  // Bet endpoints
  async placeBet(matchId, betType, selection, odds, amount) {
    return this.request('/bets', {
      method: 'POST',
      body: JSON.stringify({
        matchId,
        betType,
        selection,
        odds,
        amount
      })
    });
  }

  async getUserBets(status = null) {
    let query = '';
    if (status && status !== 'all') {
      query = `?status=${status}`;
    }
    return this.request(`/bets${query}`);
  }

  logout() {
    this.setToken(null);
    localStorage.removeItem('user');
  }
}

window.api = new ApiService();
