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

# Copy the default nginx.conf (Optional, only if you have custom configurations)
# COPY nginx.conf /etc/nginx/nginx.conf

# Copy built app from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80 for Nginx
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
