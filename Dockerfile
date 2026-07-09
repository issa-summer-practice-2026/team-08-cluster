# --- STAGE 1: Construirea Frontend-ului (Node) ---
FROM node:lts AS frontend-builder
WORKDIR /app/frontend

# Copiem fișierele de dependințe
COPY frontend/package*.json ./
RUN npm ci

# Copiem restul codului de frontend și îl compilăm
COPY frontend/ .
RUN npm run build

# --- STAGE 2: Aplicația Finală (Python) ---
FROM python:3.11-slim
WORKDIR /app

# Instalăm dependințele de backend
COPY backend/dev-requirements.txt .
RUN pip install --no-cache-dir -r dev-requirements.txt

# Copiem codul de backend
COPY backend/ ./backend

# Copiem frontend-ul compilat din STAGE 1 în folderul de unde backend-ul servește fișierele statice
# (Verifică în aplicația ta unde se așteaptă backend-ul să fie folderul `dist`, de obicei e chiar în folderul static din app sau în rădăcină)
COPY --from=frontend-builder /app/frontend/dist ./backend/dist

# Expunem portul aplicației
EXPOSE 8000

# Setăm variabila de mediu HOST pentru a accepta conexiuni din exteriorul containerului
ENV HOST=0.0.0.0

# Comanda de pornire (ajustează în funcție de scriptul tău, de ex. rularea modulului app)
CMD ["python", "-m", "backend.app"]
