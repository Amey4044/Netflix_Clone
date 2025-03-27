# Stage 1: Build the React app
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files & install dependencies
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --frozen-lockfile

# Copy the rest of the app
COPY . .

# Build the Vite app
RUN pnpm run build

# Stage 2: Serve the built app with Nginx
FROM nginx:alpine

# Copy built app from previous stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]