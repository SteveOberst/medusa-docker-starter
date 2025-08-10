# Development Dockerfile for Medusa
FROM node:20-alpine

# Set working directory
WORKDIR /server

# Copy package files and npm config
COPY package.json package-lock.json ./

# Install all dependencies using npm
RUN npm install

# Copy source code
COPY . .
# Normalize line endings and ensure start script is executable
RUN sed -i 's/\r$//' ./start.sh && chmod +x ./start.sh

# Expose the port Medusa runs on
EXPOSE 9000

# Start with migrations and then the server
CMD ["./start.sh"]