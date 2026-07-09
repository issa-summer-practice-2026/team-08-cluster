# --- STAGE 1: Build Frontend ---
FROM node:lts AS frontend-builder
WORKDIR /app/frontend

# Copiem fișierele de dependințe pentru frontend
COPY frontend/package*.json ./
RUN npm ci

# Copiem restul fișierelor de frontend și generăm folderul dist
COPY frontend/ ./
RUN npm run build

# --- STAGE 2: Run Backend with Python ---
FROM python:3.10-slim
WORKDIR /app

# Instalăm dependințele pentru backend
COPY backend/requirements.txt ./backend/
COPY backend/dev-requirements.txt ./backend/
RUN pip install --no-cache-dir -r backend/requirements.txt -r
backend/dev-requirements.txt

# Copiem codul de backend
COPY backend/ ./backend/

# Copiem folderul distribuit (dist) generat la Stage 1 în folderul de frontend din stage-ul curent
COPY --from=frontend-builder /app/frontend/dist ./frontend/dist

# Expunem portul aplicației
EXPOSE 8000

# Variabilă de mediu cerută pentru HOST
ENV HOST=0.0.0.0

# Schimbăm directorul de lucru în folderul backend pentru ca importurile Python să funcționeze corect
WORKDIR /app/backend

# Pornim aplicația ca modul Python, executând automat backend/app/__main__.py
CMD ["python", "-m", "app"]