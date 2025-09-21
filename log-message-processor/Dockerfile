FROM python:3.6-alpine
WORKDIR /app
COPY requirements.txt .
RUN apk add --no-cache gcc musl-dev python3-dev build-base \
	&& pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "main.py"]