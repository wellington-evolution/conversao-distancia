# Minimal and secure base image
FROM python:3.12-slim-bullseye AS base

# Set environment variables for python optimization and logging
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PORT=5000

# Set the working directory
WORKDIR /app

# Install system-level dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements.txt for caching
COPY  --chown=appuser:appuser ./requirements.txt .

# Install python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Add a non-root user for enhanced security
RUN adduser --disabled-password --gecos "" appuser
USER appuser

# Copy the rest of the application, ensuring proper ownership
COPY --chown=appuser:appuser . .

# Use the gunicorn
CMD gunicorn 'app:app' --bind=0.0.0.0:${PORT}