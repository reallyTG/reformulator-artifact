FROM debian:latest
ARG DEBIAN_FRONTEND=noninteractive

# Fetch prerequisites.
RUN apt-get update \
	&& apt-get -y install --no-install-recommends git unzip vim curl npm parallel silversearcher-ag

# Need to do this to get Node.js v16 on Debian.
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs


RUN apt update

RUN npm i --g yarn

# Create source code directory.
RUN mkdir -p /home/reformulator

# Before grabbing sources, install CodeQL. 
COPY setupCodeQL.sh /home
WORKDIR /home

# Misc. setup
RUN git config --global http.sslVerify "false"
RUN npm config set strict-ssl false

# Run CodeQL setup script.
RUN ./setupCodeQL.sh

# Go to source directory.
WORKDIR /home/reformulator

# Fetch transformation source code.
RUN git clone https://github.com/reallyTG/orm-refactoring.git
WORKDIR /home/reformulator/orm-refactoring
RUN npm i
RUN npm i -g typescript
RUN npm run build
WORKDIR /home/reformulator

# Fetch source code for the query.
RUN git clone https://github.com/reallyTG/reformulator-analysis.git

# The above results in the following hierarchy:
# /home
# --> /reformulator
# ----> /orm-refactoring        (The actual code transformation.)
# ----> /reformulator-analysis  (The analysis that feeds in to the code transformation.)

#
# WIP: Working on the evaluation script right now.
#

WORKDIR /home
COPY makeEvaluation.sh /home
COPY scripts /home/scripts
RUN ./makeEvaluation.sh

#
# /end WIP
#


# Now, create directory hierarchy for the evaluation.
# /home
# --> /evaluation
# ----> /case-studies
# ------> /<one-dir-for-each-project-in-evaluation>
# ----> /scripts
# ----> /query-results
# ----> /QLDBs

# Set working directory above sources and tests.
# WORKDIR /home

# Make the evaluation
# COPY makeEvaluation.sh /home
# RUN ./makeEvaluation.sh

# Make sure we're still home.
# WORKDIR /home

