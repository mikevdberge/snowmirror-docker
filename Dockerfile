FROM ubuntu 

LABEL maintainer="SnowMirror Docker Maintainers <mike.van.den.berge@gmail.com>"
LABEL vendor1="GuideVision"

ARG SNOWMIRROR_VERSION=5.6.3
ARG JAVA_VERSION=17
ARG SNOWMIRROR_DIR=/opt/snowmirror

ARG USERNAME=snowmirror
ARG USER_UID=1001
ARG USER_GID=$USER_UID

ARG BUILD_VERSION_ARG=unset

ARG SNOWMIRROR_VERSION
ARG SNOWMIRROR_DIR
ARG JAVA_VERSION
ARG USERNAME
ARG USER_UID
ARG USER_GID

RUN set -x \
    # Create the user
    && groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get -qq update \
	&& apt-get -qqy install  --no-install-recommends --no-install-suggests \
    wget \
    apt-transport-https \
    apt-utils \
    libtcnative-1 \
    libarchive-tools \
    ca-certificates < /dev/null > /dev/null \
    # Download the Eclipse Adoptium GPG key
    && mkdir -p /etc/apt/keyrings \
    && wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc \
    # Configure the Eclipse Adoptium apt repository
    && echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list \
    # Install the Temurin JDK 
    && apt-get -qq update \
    && apt-get -qqy install --no-install-recommends --no-install-suggests \
    temurin-${JAVA_VERSION}-jdk < /dev/null > /dev/null \
    # Get SnowMirror
	&& wget -nv https://snow-mirror.com/downloads-enterprise/snow-mirror-${SNOWMIRROR_VERSION}.zip -O /tmp/snow-mirror-${SNOWMIRROR_VERSION}.zip \
    && mkdir /opt/snowmirror \
    && bsdtar xvf /tmp/snow-mirror-${SNOWMIRROR_VERSION}.zip --strip-components=1 -C /opt/snowmirror \
    && rm -rf /tmp/snow-mirror-${SNOWMIRROR_VERSION}.zip \
    ## cleanup
    && apt-get clean \
    && apt-get autoclean \
    && apt-get autoremove --purge  -y \
    && rm -rf /var/lib/apt/lists/*

COPY ./h2.jar /opt/snowmirror/lib
COPY ./entrypoint.sh /
COPY ./run.sh /opt/snowmirror/

RUN ["chmod", "+x", "/entrypoint.sh"]
RUN ["chmod", "+x", "/opt/snowmirror/run.sh"]

ENV PORT=9090

ARG BUILD_VERSION_ARG

ENV BUILD_VERSION=$BUILD_VERSION_ARG
ENV USER_UID=${USER_UID}
ENV USER_GID=${USER_GID}
ENV SNOWMIRROR_DIR=${SNOWMIRROR_DIR}
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

EXPOSE 80 443 9090

#VOLUME ["/opt/snowmirror/snowMirror.properties","/opt/snowmirror/conf", "/opt/snowmirror/logs"]
VOLUME ["/opt/snowmirror/logs"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["run"]
