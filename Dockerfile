FROM azul/zulu-openjdk-debian:latest
MAINTAINER Adrian Haasler García <dev@adrianhaasler.com>

# Configuration
ENV CONF_HOME /data/conf
ENV CONF_VERSION 5.8.9

# Install dependencies
RUN apt-get update && apt-get install -y \
	curl \
	tar \
	xmlstarlet

# Create the user that will run the conf instance and his home directory (also make sure that the parent directory exists)
RUN mkdir -p $(dirname $CONF_HOME) \
	&& useradd -m -d $CONF_HOME -s /bin/bash -u 547 conf

# Download and install conf in /opt with proper permissions and clean unnecessary files
RUN curl -Lks https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-$CONF_VERSION.tar.gz -o /tmp/conf.tar.gz \
	&& mkdir -p /opt/conf \
	&& tar -zxf /tmp/conf.tar.gz --strip=1 -C /opt/conf \
	&& chown -R root:root /opt/conf \
	&& chown -R 547:root /opt/conf/logs /opt/conf/temp /opt/conf/work \
	&& echo -e "\nconfluence.home=$CONF_HOME" >> "/opt/conf/confluence/WEB-INF/classes/confluence-init.properties" \
	&& rm /tmp/conf.tar.gz

# Add conf customizer and launcher
COPY launch.sh /launch

# Make conf customizer and launcher executable
RUN chmod +x /launch

# Expose ports
EXPOSE 8090 8443

# Workdir
WORKDIR /opt/conf

# Launch conf
ENTRYPOINT ["/launch"]
