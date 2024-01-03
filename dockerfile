# Stage 1: Build Java
FROM ubuntu:20.04 AS java-builder

#ARG UNAME=cavisson
#ARG UID=1000
#ARG GID=1000

# Create the user and group, and set up directories
RUN mkdir -p /home/cavisson/java

# Copy Java package
COPY java-1.8.0-amazon-corretto-jdk_8.382.05-1_amd64.deb /home/cavisson/java/

# Install Java
RUN apt-get update && \
    apt-get install -y java-common && \
    dpkg --install /home/cavisson/java/java-1.8.0-amazon-corretto-jdk_8.382.05-1_amd64.deb && \
    rm -rf /home/cavisson/java

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Stage 2: Set up the application
FROM ubuntu:20.04

#ARG UNAME=cavisson
#ARG UID=1000
#ARG GID=1000

RUN mkdir -p /home/cavisson/monitors/tmp
RUN apt-get update && \
    apt install net-tools && \
    apt install -y curl

WORKDIR /home/cavisson/monitors/

COPY --from=java-builder /usr/lib/jvm/java-1.8.0-amazon-corretto /usr/lib/jvm/java-1.8.0-amazon-corretto
ARG CMON_BIN
COPY $CMON_BIN .

#RUN tar -xzf cmon_nfagent.4.13.0.84.tar.gz && \
 #   rm cmon_nfagent.4.13.0.84.tar.gz && \
  #  chown -R $UNAME:$UNAME /home/cavisson/monitors/

RUN tar -xzf $CMON_BIN && \
    rm $CMON_BIN 


EXPOSE 7891

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto

# Start the application
#CMD ["/home/cavisson/monitors/bin/cmon", "start", "&&", "exec", "/bin/bash", "-c", "trap : TERM INT; sleep infinity & wait"]
CMD /home/cavisson/monitors/bin/cmon start && exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
