# Use the specified Node version.
FROM node:16

# Create app directory
WORKDIR /usr/src/app

# Install dependencies
COPY package*.json ./
RUN npm install

# Bundle app source
COPY . .

# Build the Nuxt app
RUN npm run build

# Specify the environment variables; they can be overridden during container run.
ENV AXIOS=http://127.0.0.1:5010/

# Expose the desired port for the application
EXPOSE 3000

# Command to run the app
CMD [ "npm", "run", "start" ]
