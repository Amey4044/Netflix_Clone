# Stage 1: Build the app
FROM node:18 AS build

# Set working directory
WORKDIR /app

# Copy package.json and pnpm-lock.yaml for dependency installation
COPY package.json pnpm-lock.yaml ./

# Install pnpm globally and app dependencies
RUN npm install -g pnpm
RUN pnpm install

# Copy the rest of the application code
COPY . .

# Build the app
RUN pnpm run build

# Stage 2: Serve the app using Nginx
FROM nginx:alpine AS production

# Copy the built app from the first stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom Nginx configuration
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
