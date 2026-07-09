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
FROM python:3.x-slim
WORKDIR /app

# Instalăm dependințele pentru backend
COPY backend/requirements.txt ./backend/
RUN pip install --no-cache-dir -r backend/requirements.txt

# Copiem codul de backend
COPY backend/ ./backend/

# Copiem folderul distribuit (dist) generat la Stage 1 în folderul de frontend din stage-ul curent
COPY --from=frontend-builder /app/frontend/dist ./frontend/dist

# Expunem portul aplicației
EXPOSE 8000

# Variabilă de mediu cerută pentru HOST
ENV HOST=0.0.0.0

# Comanda de pornire a aplicației
CMD ["python", "backend/main.py"]