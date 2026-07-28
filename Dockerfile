FROM node:24-bookworm-slim AS node

FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS=yes
ENV PATH="/usr/local/texlive/bin:$PATH"
ENV LC_ALL=C

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libcrypt-dev \
    curl \
    make \
    ca-certificates \
    gnupg \
    python3 \
    python3-pip \
    libfontconfig1-dev \
    libfreetype6-dev \
    ghostscript \
    perl \
    perl-modules \
    libyaml-tiny-perl \
    liblog-dispatch-perl \
    libfile-homedir-perl \
    git \
    less \
    unzip \
    poppler-utils \
    ttf-mscorefonts-installer \
    software-properties-common \
    fonts-ipafont \
    fonts-ipaexfont \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-texgyre && \
    # Install perl
    echo 'y' | cpan Unicode::GCString && \
    # Install pygments for minted
    pip3 install --no-cache-dir pygments --break-system-packages && \
    # Add inkscape repository
    add-apt-repository -y ppa:inkscape.dev/stable && \
    # Install inkscape
    apt-get update && \
    apt-get install -y --no-install-recommends \
    inkscape libatomic1 && \
    # Install haranoaji fonts
    curl -L -o font.tar.gz "https://github.com/trueroad/HaranoAjiFonts/archive/refs/heads/master.tar.gz" && \
    ls -la font.tar.gz && \
    if [ -f font.tar.gz ] && [ -s font.tar.gz ]; then \
        tar -xzf font.tar.gz -C /usr/share/fonts/ && \
        fc-cache -fv && \
        rm font.tar.gz; \
    else \
        echo "Font download failed, aborting build" && \
        exit 1; \
    fi && \
    # install github cli
    wget -nv -O /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        https://cli.github.com/packages/githubcli-archive-keyring.gpg && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh && \
    # Remove unnecessary packages
    apt-get remove -y --purge \
    software-properties-common \
    build-essential \
    unzip \
    make \
    gnupg \
    libfontconfig1-dev \
    less && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Install the official Node.js distribution, including npm.
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
    node --version && \
    npm --version

# install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /workdir
