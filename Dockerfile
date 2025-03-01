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

# Install Bazel https://bazel.build/install/ubuntu
RUN apt-get install -y apt-transport-https curl gnupg
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor >bazel-archive-keyring.gpg
RUN mv bazel-archive-keyring.gpg /usr/share/keyrings
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
RUN  apt-get update && apt-get install -y bazel

# Install Bazel (chatgpt version)
# RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg \
#   && mv bazel.gpg /etc/apt/trusted.gpg.d/ \
#   && echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.11" | tee /etc/apt/sources.list.d/bazel.list \
#   && apt-get update && apt-get install -y bazel

# Clone Sorbet repository
RUN git clone https://github.com/sorbet/sorbet.git

# Set the working directory to Sorbet
WORKDIR /app/sorbet

RUN apt-get install -y software-properties-common
RUN add-apt-repository universe
RUN apt-get install -y libncurses5

# Build Sorbet using Bazel
RUN bazel build //main:sorbet --config=release-linux --copt=-march=native --verbose_failures

# Copy the compiled Sorbet binary to a desired location
RUN cp bazel-bin/main/sorbet /usr/local/bin/sorbet

# Cleanup unnecessary files
RUN bazel clean --expunge

RUN apt-get install -y postgresql libpq-dev postgresql-contrib

RUN apt-get -y update
RUN apt-get -y install ack graphviz make build-essential git uuid-runtime libyaml-dev

# # Set the entrypoint to the Sorbet binary
# ENTRYPOINT ["/bin/bash"]

EXPOSE 5432