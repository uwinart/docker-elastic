# Version 0.0.1
FROM uwinart/base:latest

MAINTAINER Yurii Khmelevskii <y@uwinart.com>

# Install JAVA8
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list.d/webupd8team-java.list && \
  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list.d/webupd8team-java.list && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
  apt-get update -q && \
  apt-get install -yq oracle-java8-installer && \
  apt-get install oracle-java8-set-default

# Install ElasticSearch
RUN cd /usr/local/src && \
  curl -L -O https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.3.4/elasticsearch-2.3.4.tar.gz && \
  tar -xvf elasticsearch-2.3.4.tar.gz && \
  rm elasticsearch-2.3.4.tar.gz && \
  adduser --system --no-create-home --group elasticsearch && \
  chown -R elasticsearch:elasticsearch elasticsearch-2.3.4 && \
  wget http://xbib.org/repository/org/xbib/elasticsearch/importer/elasticsearch-jdbc/2.3.4.1/elasticsearch-jdbc-2.3.4.1-dist.zip && \
  apt-get install -yq unzip && \
  unzip elasticsearch-jdbc-2.3.4.1-dist.zip && \
  rm elasticsearch-jdbc-2.3.4.1-dist.zip && \
  sed -i -e "s/#\snetwork.host:\s.*/network.bind_host: 0/g" /usr/local/src/elasticsearch-2.3.4/config/elasticsearch.yml

RUN cd /usr/local/src/elasticsearch-2.3.4/ && \
  bin/plugin install http://dl.bintray.com/content/imotov/elasticsearch-plugins/org/elasticsearch/elasticsearch-analysis-morphology/2.3.4/elasticsearch-analysis-morphology-2.3.4.zip && \
  bin/plugin install analysis-icu

RUN echo "script.inline: on" >> /usr/local/src/elasticsearch-2.3.4/config/elasticsearch.yml && \
  echo "script.indexed: on" >> /usr/local/src/elasticsearch-2.3.4/config/elasticsearch.yml

USER elasticsearch
EXPOSE 9200
VOLUME ["/usr/local/src/elasticsearch-2.3.4"]
CMD ["/usr/local/src/elasticsearch-2.3.4/bin/elasticsearch"]
