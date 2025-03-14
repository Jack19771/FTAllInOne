FROM ubuntu:22.04

# Tworzenie katalogu dla Yggdrasil
RUN mkdir -p /var/run/yggdrasil && chmod 777 /var/run/yggdrasil

# Instalacja wymaganych pakietów
RUN apt update && apt install -y \
    curl \
    supervisor \
    socat \
    dirmngr \
    apt-transport-https \
    iputils-ping \
    dnsutils \
    net-tools \
    iproute2 \
    nmap \
    tcpdump \
    traceroute \
    gnupg2 \
    lsb-release \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Pobranie i dodanie klucza repozytorium Yggdrasil
RUN mkdir -p /usr/local/apt-keys \
    && gpg --fetch-keys https://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/key.txt \
    && gpg --export BC1BF63BD10B8F1A | tee /usr/local/apt-keys/yggdrasil-keyring.gpg > /dev/null

# Dodanie repozytorium Yggdrasil do APT
RUN echo 'deb [signed-by=/usr/local/apt-keys/yggdrasil-keyring.gpg] http://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/ debian yggdrasil' \
    | tee /etc/apt/sources.list.d/yggdrasil.list \
    && apt update \
    && apt install -y yggdrasil \
    && rm -rf /var/lib/apt/lists/*

# Instalacja Caddy z oficjalnego repozytorium
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list \
    && apt update \
    && apt install -y caddy

# Skopiowanie plików konfiguracyjnych
COPY yggdrasil.conf /etc/yggdrasil.conf
COPY supervisord.conf /etc/supervisord.conf
COPY Caddyfile /etc/caddy/Caddyfile

# Uruchamianie zarówno Yggdrasil jak i Caddy przez supervisora
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
