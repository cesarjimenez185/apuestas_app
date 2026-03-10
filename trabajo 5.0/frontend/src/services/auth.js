class AuthService {
  constructor() {
    this.user = null;
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      this.user = JSON.parse(storedUser);
    }
  }

  setUser(user) {
    this.user = user;
    if (user) {
      localStorage.setItem('user', JSON.stringify(user));
    } else {
      localStorage.removeItem('user');
    }
  }

  getUser() {
    return this.user;
  }

  isAuthenticated() {
    return !!api.getToken() && !!this.user;
  }

  async login(email, password) {
    try {
      const data = await api.login(email, password);
      this.setUser(data.user);
      return { success: true, user: data.user };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async register(name, email, password, confirmPassword) {
    if (password !== confirmPassword) {
      return { success: false, error: 'Las contraseñas no coinciden' };
    }

    if (password.length < 6) {
      return { success: false, error: 'La contraseña debe tener al menos 6 caracteres' };
    }

    try {
      const data = await api.register(name, email, password);
      this.setUser(data.user);
      return { success: true, user: data.user };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  logout() {
    api.logout();
    this.setUser(null);
  }

  async refreshProfile() {
    try {
      const user = await api.getProfile();
      this.setUser(user);
      return user;
    } catch (error) {
      this.logout();
      throw error;
    }
  }
}

window.authService = new AuthService();
