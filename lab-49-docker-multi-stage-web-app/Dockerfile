# Stage 1: Build stage
FROM python:3.9-slim-buster AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Stage 2: Runtime stage
FROM python:3.9-slim-buster

WORKDIR /app

COPY --from=builder /app . 

EXPOSE 5000

CMD ["python", "app.py"]
