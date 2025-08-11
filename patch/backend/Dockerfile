FROM node:20-alpine
WORKDIR /server

# Copy manifest and install deps
COPY package.json package-lock.json ./
RUN npm install

# Copy source
COPY . .

# Normalize line endings and ensure start script is executable
RUN sed -i 's/\r$//' ./start.sh && chmod +x ./start.sh

EXPOSE 9000
CMD ["./start.sh"]
