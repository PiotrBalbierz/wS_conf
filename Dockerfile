# Build:
# docker build -t piotrbalbierz/webschool:v3 .

FROM node:8.11-slim

# Install required tools
RUN apt-get update \
    && apt-get install -y git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && npm install -g @angular/cli

# Create folder for webSchool app and download webSchool app from GitHub repos
RUN mkdir -p /srv/webSchool \
    && cd /srv/webSchool \
    && git clone https://github.com/PiotrBalbierz/wS_client.git \
    && git clone https://github.com/PiotrBalbierz/wS_server.git \
    && rm -rf /srv/webSchool/wS_server/public/* \
    && chown -R node: /srv/webSchool

# Switch to non-root user
USER node

# Build production version of client, copy to server and remove client directory
RUN cd /srv/webSchool/wS_client \
    && npm install \
    && ng build --prod --build-optimizer \
    && cp -R /srv/webSchool/wS_client/dist/* /srv/webSchool/wS_server/public/ \
    && rm -rf /srv/webSchool/wS_client

# Set environmental variables
ENV NODE_ENV='production' \
    PORT=3000 \
    MONGODB_URI='' \
    SECRET=''

# Set workdir and install server modules
WORKDIR /srv/webSchool/wS_server
RUN npm install

# Port
EXPOSE $PORT 

# Run webSchool server
CMD ["npm","start"]
