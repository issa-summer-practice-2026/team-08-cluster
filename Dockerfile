# --- STAGE 1: Construirea Frontend-ului (Node) ---
FROM node:lts AS frontend-builder
WORKDIR /app/frontend

# Copiem fișierele de dependințe pentru frontend
COPY frontend/package*.json ./
RUN npm ci

# Copiem restul codului de frontend și îl compilăm
COPY frontend/ .
RUN npm run build

# --- STAGE 2: Aplicația Finală (Python) ---
FROM python:3.11-slim
WORKDIR /app

# Copiem fișierul tău de dev-requirements
COPY backend/dev-requirements.txt ./

# TRUC: Creăm un fișier requirements.txt gol în container, 
# pentru ca dev-requirements.txt să nu mai dea eroare când îl caută
RUN touch requirements.txt

# Instalăm dependințele de backend
RUN pip install --no-cache-dir -r dev-requirements.txt

# Copiem codul sursă al backend-ului
COPY backend/ ./backend

# Copiem frontend-ul compilat din STAGE 1
COPY --from=frontend-builder /app/frontend/dist ./backend/dist

# Expunem portul aplicației
EXPOSE 8000

# Setăm variabila de mediu HOST
ENV HOST=0.0.0.0

# Comanda de pornire a aplicației
CMD ["python", "-m", "backend.app"]
