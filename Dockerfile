# Use an official Node.js runtime as a parent image
FROM node:18 AS build

# Set the working directory in the container
WORKDIR /app

# Copy package.json and pnpm-lock.yaml first to leverage Docker cache
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN npm install -g pnpm
RUN pnpm install

# Copy the rest of the application files
COPY . .

# Copy .env file to the container (ensure you have your .env file in the root)
COPY .env .env

# Build the application
RUN pnpm run build

# Use a smaller image to run the app
FROM nginx:alpine

# Copy the build from the build image
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 8080
EXPOSE 8081

# Start nginx server
CMD ["nginx", "-g", "daemon off;"]
