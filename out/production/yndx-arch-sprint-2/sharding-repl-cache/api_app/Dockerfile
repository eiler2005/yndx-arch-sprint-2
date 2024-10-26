FROM python:3.12.1-slim
WORKDIR /app
EXPOSE 8080
COPY requirements.txt ./
# Устанавливаем зависимости python не пересобирая их
RUN pip install --no-cache --no-cache-dir -r requirements.txt
# Копирование кода приложения
COPY app.py /app/
ENTRYPOINT ["uvicorn"]
CMD ["app:app", "--host", "0.0.0.0", "--port", "8080"]
