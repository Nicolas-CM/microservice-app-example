FROM python:3.9-alpine
WORKDIR /app
COPY requirements.txt .
RUN apk add --no-cache gcc musl-dev python3-dev build-base \
	&& pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 80
CMD ["python", "main.py"]