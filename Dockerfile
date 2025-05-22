
# Use an official Python base image for building dependencies
FROM python:3.8-slim-buster AS builder

# Set the working directory inside the container to /app
WORKDIR /app

# Copy and install dependencies separately to avoid redundant layers
COPY requirements.txt .

# Create a virtual environment for dependencies
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# Use a minimal base image for the final runtime stage
FROM python:3.8-slim-buster

# Set the working directory inside the container to /app
WORKDIR /app

# Copy the pre-installed dependencies from the builder stage
COPY --from=builder /opt/venv /opt/venv

# Ensure the virtual environment is used for execution
ENV PATH="/opt/venv/bin:$PATH"

# Copy only the necessary application files
COPY app.py .

# Expose port 5000 so it can be accessed outside the container
EXPOSE 5000

# Use a non-root user for better security
RUN useradd -m appuser
USER appuser

# Command to start the Flask application (listens on all network interfaces)
CMD ["flask", "run", "--host=0.0.0.0"]

