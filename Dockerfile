FROM perl:5.34-slim

WORKDIR /app

# Install system dependencies for MariaDB client and build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    libmariadb-dev \
    libmariadb-dev-compat \
    pkg-config \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Perl dependencies
COPY cpanfile .
RUN cpanm --notest --installdeps .

# Copy application files
COPY . .

# Expose the default port for Starman
EXPOSE 8080

# Start the application using Starman
CMD ["starman", "--listen", "0.0.0.0:8080", "bin/app.psgi"]
