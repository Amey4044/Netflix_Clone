# Step 1: Use Node.js as the base image to build the project
FROM node:20-alpine AS builder

# Set working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json before installing dependencies
COPY package.json package-lock.json ./

# Install project dependencies
RUN npm install

# Copy the rest of the project files
COPY . .

# Build the project using Vite
RUN npm run build

# Step 2: Use Nginx to serve the built frontend
FROM nginx:alpine

# Copy built files from previous step to Nginx's web root
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80 for web traffic
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
