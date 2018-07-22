# Mozilla Kinto server
FROM mhart/alpine-node
LABEL version="9.1.2" maintainer="Rob MacKinnon <rome@villagertech.com>"

ARG APK_OPTS="--no-progress"

ARG KINTO_INI=/etc/kinto/kinto.ini
ARG KINTO_HOST=0.0.0.0
ARG KINTO_PORT=8888 
ARG KINTO_STORAGE_BACKEND=memory 
ARG KINTO_CACHE_BACKEND=memory 
ARG KINTO_GID=10001 
ARG KINTO_UID=10001

# Prepare the image
RUN apk update && apk upgrade;
RUN mkdir /app /etc/kinto; \
	apk $APK_OPTS add git bash shadow python3 python3-dev curl
RUN apk $APK_OPTS add gcc
RUN apk $APK_OPTS add libpq libressl gnupg libffi libffi-dev postgresql-dev musl-dev
RUN groupadd -g $KINTO_GID app; useradd -Nr -u $KINTO_UID -G app -d /app -s /bin/false app
RUN pip3 install --upgrade pip

# Copy the app source
WORKDIR /app
COPY kinto /app

# Install build dependencies, build the virtualenv and remove build
# dependencies all at once to build a small image.
WORKDIR /app/kinto/plugins/admin
RUN npm install; npm run build && rm -rf node_modules

WORKDIR /app/kinto/
RUN pip3 install -e /app[postgresql,memcached,monitoring] -c /app/requirements.txt; \
    pip3 install kinto-pusher kinto-attachment

# Security Audit: Remove default user shells on users: operator, postgres
RUN usermod -s /bin/false operator; usermod -s /bin/false postgres;
RUN chown app:app -R /app; chgrp app /etc/kinto; chmod g+rw /etc/kinto

CMD kinto init --ini $KINTO_INI --host $KINTO_HOST --backend $KINTO_STORAGE_BACKEND --cache-backend $KINTO_CACHE_BACKEND;

USER app
# Run database migrations and start the kinto server
CMD kinto migrate --ini $KINTO_INI && kinto start --ini $KINTO_INI --port $KINTO_PORT
