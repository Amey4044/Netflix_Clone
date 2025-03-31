# Stage 1: Build the React app
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files & install dependencies
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --frozen-lockfile

# Copy the rest of the app
COPY . .

# Build the React app
RUN pnpm run build

# Stage 2: Serve the built app with Nginx
FROM nginx:alpine

# Set environment variable for TMDB API Key (you can modify this to use a secret manager or Kubernetes config map)
# For production use, pass this key securely, not hardcoded
ENV REACT_APP_TMDB_API_KEY=${TMDB_API_KEY}

# Copy built app from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80 for Nginx
EXPOSE 80

# Optional: Add custom nginx.conf if necessary
# COPY nginx.conf /etc/nginx/nginx.conf

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
