FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py ./

EXPOSE 5000

HEALTHCHECK --interval=5s --timeout=3s --retries=3 \
  CMD curl --fail http://localhost:5000/health || exit 1

CMD ["python", "app.py"]