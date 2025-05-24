# Use a lightweight Python base image
FROM python:3.8-alpine AS builder
# First stage: Full-featured image for dependency installation
FROM python:3.8-slim-buster AS builder

WORKDIR /app

# Install dependencies directly without a virtual environment
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Final runtime stage with minimal dependencies
FROM python:3.8-alpine

WORKDIR /app

# Copy installed packages from the builder stage
COPY --from=builder /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages

# Copy the Flask app files
COPY app.py .
COPY templates/ templates/

# Expose port 5000
EXPOSE 5000

# Use a non-root user for security
RUN adduser -D appuser
USER appuser

CMD ["flask", "run", "--host=0.0.0.0"]
