FROM openjdk:8
ARG CMON_BIN
RUN mkdir -p /home/cavisson/monitors/
ADD $CMON_BIN /home/cavisson/monitors/
RUN apt update; apt install net-tools -y
WORKDIR /home/cavisson/monitors/
EXPOSE 7891
CMD /home/cavisson/monitors/bin/cmon start && exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
