# Use a lightweight base image for Python
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Install build dependencies
# RUN apt-get update && apt-get install -y --no-install-recommends gcc

# Copy requirements first for caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Expose the port that the backend will run on
EXPOSE 5000

# Command to run Gunicorn with the Flask app
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
