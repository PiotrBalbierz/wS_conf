# Build:
# docker build -t piotrbalbierz/webschool:v1 .

FROM node:8.11.3-stretch

# Set environmental variables
ENV NODE_ENV='production' \
    PORT=3000 \
    MONGODB_URI='mongodb://wSadmin:wSpas5w0rd@wS-mongo:27017/wS-db' \
    SECRET='webSch00l'

# Install required tools
RUN apt-get update \
    && apt-get install -y git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && npm install -g @angular/cli && npm cache clean

# Create folder for webSchool app and download webSchool app from GitHub repos
RUN mkdir -p /srv/webSchool \
    && chown node: -R /srv/webSchool \
    && cd /srv/webSchool \
    && git clone https://github.com/PiotrBalbierz/wS_client.git \
    && git clone https://github.com/PiotrBalbierz/wS_server.git \
    && rm -rf /srv/webSchool/wS_server/public/*

# Build production version of client, copy to server and remove client directory
RUN cd /srv/webSchool/wS_client \
    && npm install --quiet && npm cache clean \
    && ng build --prod --build-optimizer \
    && cp -R /srv/webSchool/wS_client/dist/* /srv/webSchool/wS_server/public/ \
    && rm -rf /srv/webSchool/wS_client

# Remove unnecessary
RUN npm uninstall -g @angular/cli \
    && apt-get purge -y --auto-remove git \
    && apt-get autoremove

# Set workdir and install server modules
WORKDIR /srv/webSchool/wS_server
RUN npm install --quiet && npm cache clean

# PORT
EXPOSE $PORT 

# Run webSchool server
CMD ["npm start"]
