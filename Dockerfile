FROM python:3.8-slim-buster
LABEL maintainer="shishirsubedi.com"

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PATH="/scripts:${PATH}"

RUN pip install --upgrade pip
COPY ./requirements.txt /requirements.txt

# packages required for setting up WSGI
RUN apt-get update
RUN apt-get install -y --no-install-recommends gcc libc-dev python3-dev

RUN pip install -r /requirements.txt

RUN mkdir /app
COPY ./app /app
WORKDIR /app
COPY ./scripts /scripts
RUN chmod +x /scripts/*

# folder to serve media files by nginx
RUN mkdir -p /vol/web/media
# folder to serve static files by nginx
RUN mkdir -p /vol/web/static

CMD ["entrypoint.sh"]