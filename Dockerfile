FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS=yes
ENV PATH="/usr/local/texlive/bin:$PATH"
ENV LC_ALL=C

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
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
    fonts-texgyre \
    ssh-client && \
    # Install perl
    echo 'y' | cpan Unicode::GCString && \
    # Install pygments for minted
    pip3 install --no-cache-dir pygments --break-system-packages && \
    # Add nodejs repository
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    NODE_MAJOR=20 && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
    > /etc/apt/sources.list.d/nodesource.list && \
    # Add inkscape repository
    add-apt-repository -y ppa:inkscape.dev/stable && \
    # Install nodejs and inkscape
    apt-get update && \
    apt-get install -y --no-install-recommends \
    inkscape nodejs && \
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


WORKDIR /workdir