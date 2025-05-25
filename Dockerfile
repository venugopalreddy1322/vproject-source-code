# First Stage: Build Environment (Rich Base Image)
FROM python:3.8-slim-buster AS builder

WORKDIR /app

# Copy dependency file first to leverage caching
COPY requirements.txt .

# Install dependencies efficiently without caching unnecessary files
RUN pip install --no-cache-dir -r requirements.txt

# Second Stage: Minimal Runtime Environment (Lightweight)
FROM python:3.8-alpine

WORKDIR /app

# Security: Create a non-root user without a home directory (lighter)
RUN adduser -D appuser

# Reduce attack surface by setting a safer environment
ENV PYTHONUNBUFFERED=1

# Copy only necessary files from builder
COPY --from=builder /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY --chown=appuser:appuser app.py .
COPY --chown=appuser:appuser templates/ templates/

# Ensure proper ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose only necessary ports
EXPOSE 5000

# Secure execution of Flask
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]

# CMD ["flask", "run", "--host=0.0.0.0"]