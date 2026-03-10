# BetFoot - Sistema de Apuestas de Fútbol

Sistema completo de apuestas deportivas enfocado en fútbol con backend, frontend web y aplicación Flutter.

## Estructura del Proyecto

```
trabajo 5.0/
├── backend/           # Servidor API REST (Node.js + Express + MongoDB)
├── frontend/         # Aplicación web (HTML + CSS + JavaScript)
└── flutter/         # Aplicación móvil (Flutter)
```

## Requisitos

- Node.js 18+
- MongoDB 6+
- Flutter 3.0+
- npm o yarn

## Configuración y Ejecución

### 1. Backend

```bash
cd backend
npm install
# Asegúrate de tener MongoDB corriendo
npm run dev
```

El servidor estará en: `http://localhost:3000`

### 2. Frontend Web

```bash
cd frontend
# Abre src/index.html en un navegador
# O usa un servidor local:
npx serve src
```

### 3. Aplicación Flutter

```bash
cd flutter
flutter pub get
flutter run
```

## API Endpoints

### Autenticación
- `POST /api/auth/register` - Registro de usuario
- `POST /api/auth/login` - Inicio de sesión
- `GET /api/auth/profile` - Obtener perfil
- `PUT /api/auth/balance` - Actualizar balance

### Partidos
- `GET /api/matches` - Listar partidos
- `GET /api/matches/live` - Partidos en vivo
- `POST /api/matches/seed` - Generar partidos de prueba

### Apuestas
- `POST /api/bets` - Realizar apuesta
- `GET /api/bets` - Historial de apuestas

## Características

### Frontend Web
- ✅ Diseño oscuro profesional
- ✅ Autenticación JWT
- ✅ Partidos en vivo con actualizaciones
- ✅ Ticket de apuestas
- ✅ Tipos de apuestas: Ganador, Doble oportunidad, Over/Under, Ambos marcan
- ✅ Historial de apuestas
- ✅ Diseño responsive

### Flutter App
- ✅ Pantallas: Login, Home, Live, Profile
- ✅ Integración con API
- ✅ Ticket de apuestas
- ✅ Diseño Material Design 3

## Colores

- Fondo: `#0f172a`
- Primario: `#22c55e`
- Botones: `#16a34a`
- Texto: Blanco

## Notas

- La base de datos se prepopula con partidos de prueba al iniciar
- Cada nuevo usuario recibe $1000 de balance inicial
- Los partidos incluyen cuotas para diferentes tipos de apuestas

## Tecnologías

### Backend
- Express.js
- MongoDB + Mongoose
- JWT
- bcryptjs

### Frontend Web
- Vanilla JavaScript
- CSS3 con variables
- Fetch API

### Flutter
- Provider (State Management)
- http package
- Shared Preferences
