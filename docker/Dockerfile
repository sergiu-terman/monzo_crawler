# Dockerfile development version
FROM ruby:3.2.2 AS crawler_env

ARG USER_ID
ARG GROUP_ID

RUN apt-get update --fix-missing && apt-get -y upgrade
RUN apt-get install -y jq \
    less \
    vim \
    sqlite3 \
    zlib1g-dev \
    patch \
    curl \
    unzip \
    xvfb \
    gconf-service \
    libasound2 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgconf-2-4 \
    libgtk2.0-0 \
    libnspr4 \
    libnss3 \
    libpango1.0-0 \
    libxss1 \
    libxtst6 \
    liblzma-dev \
    fonts-liberation \
    libappindicator1 \
    libxi6 \
    xdg-utils \
    default-jdk \
    chromium

# install chromedriver
RUN curl -s -L -o driver.zip "https://chromedriver.storage.googleapis.com/88.0.4324.96/chromedriver_linux64.zip" && \
    unzip driver.zip && \
    rm -rf driver.zip && \
    chmod +x chromedriver && \
    mv chromedriver /usr/local/bin/

RUN addgroup --gid $GROUP_ID user
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID user

ENV INSTALL_PATH /opt/app
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

RUN gem install bundler
COPY Gemfile* $INSTALL_PATH
RUN bundle install
RUN chown -R user:user /opt/app

USER $USER_ID
CMD sleep infinity
