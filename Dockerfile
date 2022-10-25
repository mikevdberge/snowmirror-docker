FROM ubuntu 

LABEL maintainer="SnowMirror Docker Maintainers <mike.van.den.berge@gmail.com>"
LABEL vendor1="GuideVision"

ARG SNOWMIRROR_VERSION=4.14.1
ARG JDK_VERSION=11.0.16.1%2B1
ARG JDK2_VERSION=11.0.16.1_1
ARG JDK3_VERSION=11.0.16.1+1

ARG USERNAME=snowmirror
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ARG BUILD_VERSION_ARG=unset

ARG SNOWMIRROR_VERSION
ARG JDK_VERSION
ARG JDK2_VERSION
ARG JDK3_VERSION
ARG USERNAME
ARG USER_UID
ARG USER_GID
ARG BUILD_VERSION_ARG

RUN set -x \
    # Create the user
    && groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get -qq update \
	&& apt-get -qqy install  --no-install-recommends --no-install-suggests \
    sudo \
    wget \
    libarchive-tools \
    ca-certificates < /dev/null > /dev/null \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME 

# Get SnowMirror
RUN cd /tmp/ \
	 && wget -nv https://snow-mirror.com/downloads-enterprise/snow-mirror-${SNOWMIRROR_VERSION}.zip -O /tmp/snow-mirror-${SNOWMIRROR_VERSION}.zip \
     && mkdir /opt/snowmirror \
     && bsdtar xvf snow-mirror-${SNOWMIRROR_VERSION}.zip --strip-components=1 -C /opt/snowmirror

# Get JDK
RUN cd /tmp/ \
     && wget -nv https://github.com/adoptium/temurin11-binaries/releases/download/jdk-${JDK_VERSION}/OpenJDK11U-jre_x64_linux_hotspot_${JDK2_VERSION}.tar.gz -O /tmp/jdk.tar.gz \
     && mkdir /opt/snowmirror/jre \
	 && tar -xvf jdk.tar.gz -C /opt/snowmirror/jre  --strip-components=1 \
     && chown $USERNAME /opt/snowmirror \
     && chgrp $USERNAME /opt/snowmirror 

COPY ./entrypoint.sh /
COPY ./run.sh /opt/snowmirror/

ENV PORT=9090

ARG BUILD_VERSION_ARG

ENV BUILD_VERSION=$BUILD_VERSION_ARG

EXPOSE 80 443 9090

VOLUME ["/opt/snowmirror/conf", "/opt/snowmirror/logs"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["run"]

#HEALTHCHECK --interval=20s --timeout=10s --retries=3 \
#    CMD curl -f http://localhost:${PORT} || exit 1    