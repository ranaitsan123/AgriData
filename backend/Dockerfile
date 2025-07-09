FROM node:18

# Set working directory
WORKDIR /app

# Install netcat (OpenBSD variant)
RUN apt-get update && apt-get install -y netcat-openbsd && rm -rf /var/lib/apt/lists/*

# Install app dependencies
COPY package*.json ./
RUN npm install

# Copy app files
COPY . .

# Ensure wait-for.sh is executable
RUN chmod +x wait-for.sh

# Expose backend port
EXPOSE 5000

# Wait for PostgreSQL before starting
ENTRYPOINT ["./wait-for.sh", "db"]
CMD ["node", "index.js"]
