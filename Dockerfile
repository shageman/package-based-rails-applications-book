# Base image
FROM rubylang/ruby:3.3-jammy

# Set the working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  git \
  libssl-dev \
  zlib1g-dev \
  python2

# INSTALL BAZEL https://bazel.build/install/ubuntu
RUN apt-get install -y apt-transport-https curl gnupg
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor >bazel-archive-keyring.gpg
RUN mv bazel-archive-keyring.gpg /usr/share/keyrings
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
RUN  apt-get update && apt-get install -y bazel

RUN git clone https://github.com/sorbet/sorbet.git
WORKDIR /app/sorbet

RUN apt-get install -y software-properties-common
RUN add-apt-repository universe
RUN apt-get install -y libncurses5

RUN bazel build //main:sorbet --config=release-linux --copt=-march=native --verbose_failures
RUN cp bazel-bin/main/sorbet /usr/local/bin/sorbet
RUN bazel clean --expunge



# INSTALL OTHER DEPENDENCIES
RUN apt-get install -y postgresql libpq-dev postgresql-contrib
RUN apt-get -y update
RUN apt-get -y install ack graphviz make build-essential git uuid-runtime libyaml-dev



## INSTALL NODE
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install -y nodejs



# INSTALL HEADLESS CHROME
RUN npm i puppeteer 
RUN npm i chromedriver


EXPOSE 5432