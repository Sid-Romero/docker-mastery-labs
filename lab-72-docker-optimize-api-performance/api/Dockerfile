# Builder stage
FROM python:3.9-slim-buster AS builder

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# Final stage
FROM python:3.9-slim-buster

WORKDIR /app

COPY --from=builder /app/ ./

EXPOSE 8080

CMD ["python3", "app.py"]
