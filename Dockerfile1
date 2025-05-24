# A MULTI-STAGE DOCKER FILE

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
COPY templates/ templates/

# Expose port 5000 so it can be accessed outside the container
EXPOSE 5000

# Use a non-root user for better security
RUN useradd -m appuser
USER appuser

# Command to start the Flask application (listens on all network interfaces)
CMD ["flask", "run", "--host=0.0.0.0"]

# Explanation:
#python -m venv /opt/venv
#This creates a virtual environment named /opt/venv using Python's built-in venv module.

#A virtual environment is an isolated space where dependencies (like Python packages) are installed separately from system-wide Python.

#This helps prevent version conflicts and ensures your application has the exact dependencies it needs.

#2. && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt
#&& ensures that the next command runs only if the first one succeeds.

#/opt/venv/bin/pip refers to the pip version inside the virtual environment.

#install --no-cache-dir -r requirements.txt installs dependencies listed in requirements.txt into the virtual environment.

#--no-cache-dir prevents pip from storing unnecessary cache files, reducing the size of the final Docker image.
