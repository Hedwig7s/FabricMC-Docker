FROM eclipse-temurin:21-jre

EXPOSE 25565/tcp
EXPOSE 8100/tcp
EXPOSE 8080/tcp

ENV MC_VERSION 1.20.1
ENV MC_EULA true
ENV MC_RAM_XMS 1536M
ENV MC_RAM_XMX 2048M

VOLUME /home/server

USER root
WORKDIR /home/server

COPY src/main.sh /main.sh

RUN apt update &&\
    apt install -y curl findutils unar &&\
    rm -rf /var/lib/apt/lists/*

RUN chmod +x /main.sh

RUN useradd purpur
USER purpur

CMD ["/main.sh"]
