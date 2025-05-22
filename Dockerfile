
# Use a lightweight Python image based on Debian (slim-buster reduces unnecessary packages)
FROM python:3.8-slim-buster

# Set the working directory inside the container to /app
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install Python dependencies using pip (no-cache-dir prevents unnecessary cache storage)
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy all project files into the container (including app.py)
COPY app.py .

# Expose port 5000 so it can be accessed outside the container
EXPOSE 5000

# Command to start the Flask application (listens on all network interfaces)
CMD ["flask", "run", "--host=0.0.0.0"]

