# 🪒 Barber AI Pro - Página Web Premium

## Descripción
Página web completa para barbería premium con agente de IA integrado, sistema de reservas, productos y más.

## Estructura

```
barber-web/
├── index.html          # Página principal
├── css/
│   └── style.css       # Estilos modernos minimalistas
├── js/
│   ├── agent.js       # Agente de IA conversacional
│   └── main.js        # Lógica principal
└── skills/
    ├── cortes.js      # Skill de cortes de cabello
    ├── barba.js       # Skill de servicios de barba
    ├── reserva.js     # Skill de reservas
    └── servicios.js   # Skill de servicios y productos
```

## Características

✅ Chat con agente de IA - Responde preguntas sobre cortes, barba, productos
✅ Sistema de reservas - Modal para agendar citas
✅ Catálogo de servicios - 7 servicios con precios
✅ Cortes populares - Fade, Pompadour, Undercut, Taper, Buzz Cut
✅ Productos premium - Ceras, pomadas, aceites, bálsamos
✅ Promociones dinámicas
✅ Diseño responsivo - Funciona en móvil y desktop
✅ Imágenes de alta calidad desde Unsplash

## Cómo usar

1. Abre `barber-web/index.html` en tu navegador
2. O usa un servidor local:

```bash
# Con Python
cd barber-web
python -m http.server 8000

# Con Node.js (si tienes http-server)
npx http-server
```

3. Accede a `http://localhost:8000`

## Funcionalidades del Chat AI

El agente puede ayudarte con:
- 🎯 Recomendaciones de cortes según tu rostro
- 🧔 Estilos de barba
- 📅 Reservar citas
- 💈 Información de servicios y precios
- 🛒 Recomendaciones de productos

## Imágenes

Las imágenes se cargan desde Unsplash (CDN gratuito).
Si no cargan, verifica tu conexión a internet.

## Licencia

MIT © 2026 Barber AI Pro
