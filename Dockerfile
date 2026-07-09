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

# Întâi copiem TOATE fișierele de requirements din backend ca să evităm eroarea de fișier lipsă
COPY backend/*requirements*.txt ./

# Instalăm dependințele de backend folosind fișierul tău specific
RUN pip install --no-cache-dir -r dev-requirements.txt

# Copiem codul sursă al backend-ului
COPY backend/ ./backend

# Copiem frontend-ul compilat din STAGE 1 în folderul de unde backend-ul servește fișierele statice
COPY --from=frontend-builder /app/frontend/dist ./backend/dist

# Expunem portul aplicației (cel folosit de serverul tău, ex: 8000)
EXPOSE 8000

# Setăm variabila de mediu HOST ca să poată fi accesat containerul din exterior
ENV HOST=0.0.0.0

# Comanda de pornire a aplicației (rulează modulul app din pachetul backend)
CMD ["python", "-m", "backend.app"]
