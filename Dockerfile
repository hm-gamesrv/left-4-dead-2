# =================
# Download
# =================
FROM debian:trixie-slim AS download

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/depot-downloader \
    && wget -qO /opt/depot-downloader/DepotDownloader-linux-x64.zip \
    https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_3.4.0/DepotDownloader-linux-x64.zip \
    && unzip /opt/depot-downloader/DepotDownloader-linux-x64.zip -d /opt/depot-downloader \
    && rm -f /opt/depot-downloader/DepotDownloader-linux-x64.zip

# ===================
# Runtime
# ===================
FROM debian:trixie-slim AS runtime

ENV TZ=Asia/Shanghai

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libc6:i386 \
        libstdc++6:i386 \
        libgcc-s1:i386 \
        libcurl4:i386 \
        zlib1g:i386 \
        libncurses6:i386 \
        libtinfo6:i386 \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /lib/i386-linux-gnu/libncurses.so.6 /lib/i386-linux-gnu/libncurses.so.5 \
    && ln -s /lib/i386-linux-gnu/libtinfo.so.6 /lib/i386-linux-gnu/libtinfo.so.5

RUN groupadd -g 1000 gamesrv \
    && useradd -u 1000 -g gamesrv -m -s /bin/bash gamesrv
RUN mkdir -p /app /app-patch && chown -R 1000:1000 /app /app-patch

COPY --from=download --chown=1000:1000 ["/opt/depot-downloader", "/opt/depot-downloader"]
COPY --chown=1000:1000 ["./init.sh", "/usr/local/bin/init.sh"]
COPY --chown=1000:1000 ["./patch/", "/app-patch"]

EXPOSE 27015/udp 27015/tcp

VOLUME ["/app"]

WORKDIR /app
USER 1000:1000
ENTRYPOINT ["bash", "/usr/local/bin/init.sh"]
CMD ["bash", "/app/start-server.sh", "+map", "c1m2_street"]
