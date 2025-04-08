#########################################
# Dockerfile for setting up the MEIGarage.
# This installs dependencies to the system, 
# then downloads the latest artifacts 
# of the MEIGarage (backend),
# and installs it in a Tomcat application server
#########################################
FROM tomcat:9-jdk11


LABEL org.opencontainers.image.source=https://github.com/edirom/meigarage
LABEL org.opencontainers.image.authors="Anne Ferger and Peter Stadler for the ViFE"

ARG VERSION_STYLESHEET=latest
ARG VERSION_ODD=latest
#ARG VERSION_ENCODING_TOOLS=latest we need to use the newest version, latest release is too old
ARG VERSION_W3C_MUSICXML=latest
ARG VERSION_MEILER=latest
#ARG VERSION_MUSIC_ENCODING=latest : no version to be specified available yet
#ARG VERSION_DATA_CONFIGURATION=latest : no releases/versions available yet
ARG WEBSERVICE_ARTIFACT=https://nightly.link/Edirom/MEIGarage/workflows/maven_docker/dev/artifact.zip
ARG BUILDTYPE=local

ENV CATALINA_WEBAPPS ${CATALINA_HOME}/webapps
ENV OFFICE_HOME /usr/lib/libreoffice
ENV TEI_SOURCES_HOME /usr/share/xml/tei
ENV MEI_SOURCES_HOME /usr/share/xml/mei

USER root:root

RUN apt-get update
RUN apt-get install -y --no-install-recommends fonts-dejavu \
    fonts-arphic-ukai \
    fonts-arphic-uming \
    fonts-baekmuk \
    fonts-junicode \
    fonts-linuxlibertine \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho \
    cmake \
    build-essential \
    libgcc-10-dev \
    librsvg2-bin \
    curl \
    libxml2-utils \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt \
    && apt-get clean

# install lilypond-converter dependencies
ADD  https://github.com/Edirom/lilypond-converter/raw/main/required.sh /tmp/required-lilypond-converter.sh
RUN chmod a+x /tmp/required-lilypond-converter.sh \
    && /tmp/required-lilypond-converter.sh --batch
    
# install verovio-converter dependencies
ADD  https://github.com/Edirom/verovio-converter/raw/main/required.sh /tmp/required-verovio-converter.sh
RUN chmod a+x /tmp/required-verovio-converter.sh \
    && /tmp/required-verovio-converter.sh --batch

# entrypoint script
COPY docker-entrypoint.sh /my-docker-entrypoint.sh

# log4j.xml configuration
COPY log4j.xml /var/cache/oxgarage/log4j.xml

# download artifacts to /tmp and deploy them at ${CATALINA_WEBAPPS}

#if the action is run on github, the war is already located in the artifact folder because of the previous github action
#RUN if [ "$BUILDTYPE" = "github" ] ; then \
#    cp artifact/meigarage.war /tmp/; \
#    fi 
#need to use strange hack for this conditional copy
COPY artifac[t]/meigarage.wa[r] /tmp/

# if docker build is local the latest artifact needs to be downloaded using the nightly link url
RUN if [ "$BUILDTYPE" = "local" ] ; then \
    curl -Ls ${WEBSERVICE_ARTIFACT} -o /tmp/meigarage.zip \
    && unzip -q /tmp/meigarage.zip -d /tmp/; \
    fi 

# these war-files are zipped so we need to unzip them twice
# the GUI/webclient needs to be downloaded locally and on github
RUN unzip -q /tmp/meigarage.war -d ${CATALINA_WEBAPPS}/ege-webservice/ \
    && rm -Rf ${CATALINA_WEBAPPS}/ROOT \
    && cp ${CATALINA_WEBAPPS}/ege-webservice/WEB-INF/lib/oxgarage.properties /etc/ \
    && rm -f /tmp/*.war \
    && rm -f /tmp/*.zip \
    && chmod 755 /my-docker-entrypoint.sh

#check if the version of stylesheet version is supplied, if not find out latest version

#https://github.com/TEIC/Stylesheets/releases/latest
RUN if [ "$VERSION_STYLESHEET" = "latest" ] ; then \
    VERSION_STYLESHEET=$(curl "https://api.github.com/repos/TEIC/Stylesheets/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")'); \    
    fi \
    && echo "Stylesheet version set to ${VERSION_STYLESHEET}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders (${TEI_SOURCES_HOME})
    && curl -s -L -o /tmp/stylesheet.zip https://github.com/TEIC/Stylesheets/releases/download/v${VERSION_STYLESHEET}/tei-xsl-${VERSION_STYLESHEET}.zip \
    && unzip /tmp/stylesheet.zip -d /tmp/stylesheet \
    && rm /tmp/stylesheet.zip \
    && mkdir -p  ${TEI_SOURCES_HOME}/stylesheet \
    && cp -r /tmp/stylesheet/xml/tei/stylesheet/*  ${TEI_SOURCES_HOME}/stylesheet \
    && rm -r /tmp/stylesheet

#https://github.com/TEIC/TEI/releases/latest 
RUN if [ "$VERSION_ODD" = "latest" ] ; then \
    VERSION_ODD=$(curl "https://api.github.com/repos/TEIC/TEI/releases/latest" | grep -Po '"tag_name": "P5_Release_\K.*?(?=")'); \   
    fi \
    && echo "ODD version set to ${VERSION_ODD}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders ( ${TEI_SOURCES_HOME})
    && curl -s -L -o /tmp/odd.zip https://github.com/TEIC/TEI/releases/download/P5_Release_${VERSION_ODD}/tei-${VERSION_ODD}.zip \
    && unzip /tmp/odd.zip -d /tmp/odd \
    && rm /tmp/odd.zip \
    && mkdir -p  ${TEI_SOURCES_HOME}/odd \
    && cp -r /tmp/odd/xml/tei/odd/*  ${TEI_SOURCES_HOME}/odd \
    && rm -r /tmp/odd

#https://github.com/music-encoding/encoding-tools/releases/latest
#RUN if [ "$VERSION_ENCODING_TOOLS" = "latest" ] ; then \
#    VERSION_ENCODING_TOOLS=$(curl "https://api.github.com/repos/music-encoding/encoding-tools/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")'); \   
#    fi \
#    && echo "Encoding tools version set to ${VERSION_ENCODING_TOOLS}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders ( ${TEI_SOURCES_HOME})
#    && curl -s -L -o /tmp/encoding.zip https://github.com/music-encoding/encoding-tools/archive/refs/tags/v${VERSION_ENCODING_TOOLS}.zip \
#    && unzip /tmp/encoding.zip -d /tmp/encoding \
#    && rm /tmp/encoding.zip \
#    && mkdir -p  ${MEI_SOURCES_HOME}/music-stylesheets/encoding-tools \
#    && cp -r /tmp/encoding/*/*  ${MEI_SOURCES_HOME}/music-stylesheets/encoding-tools \
#    && rm -r /tmp/encoding
#clone the latest version of https://github.com/music-encoding/encoding-tools/
RUN git clone --depth 1 -b main https://github.com/music-encoding/encoding-tools /tmp/encoding \
    && cd /tmp/encoding \   
    && git rev-parse HEAD > /tmp/encoding/GITHASH \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-stylesheets/encoding-tools \
    && cp -r /tmp/encoding/*  ${MEI_SOURCES_HOME}/music-stylesheets/encoding-tools \
    && rm -r /tmp/encoding

#https://github.com/w3c/musicxml/releases/latest
RUN if [ "$VERSION_W3C_MUSICXML" = "latest" ] ; then \
    VERSION_W3C_MUSICXML=$(curl "https://api.github.com/repos/w3c/musicxml/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")'); \    
    fi \
    && echo "W3C Music XML version set to ${VERSION_W3C_MUSICXML}" \
    # download the required stylesheet sources in the image and move them to the respective folders (${MEI_SOURCES_HOME})
    && curl -s -L -o /tmp/musicxml.zip https://github.com/w3c/musicxml/releases/download/v${VERSION_W3C_MUSICXML}/musicxml-${VERSION_W3C_MUSICXML}.zip \
    && unzip /tmp/musicxml.zip -d /tmp/musicxml \
    && rm /tmp/musicxml.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-stylesheets/w3c-musicxml/ \
    && cp -r /tmp/musicxml/*  ${MEI_SOURCES_HOME}/music-stylesheets/w3c-musicxml/ \
    && rm -r /tmp/musicxml

#https://github.com/rettinghaus/MEILER/releases/latest
RUN if [ "$VERSION_MEILER" = "latest" ] ; then \
    VERSION_MEILER=$(curl "https://api.github.com/repos/rettinghaus/MEILER/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")'); \   
    fi \
    && echo "MEILER version set to ${VERSION_MEILER}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders ( ${TEI_SOURCES_HOME})
    && curl -s -L -o /tmp/meiler.zip https://github.com/rettinghaus/MEILER/archive/refs/tags/v${VERSION_MEILER}.zip \
    && unzip /tmp/meiler.zip -d /tmp/meiler \
    && rm /tmp/meiler.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-stylesheets/meiler \
    && cp -r /tmp/meiler/*/*  ${MEI_SOURCES_HOME}/music-stylesheets/meiler \
    && rm -r /tmp/meiler

#https://github.com/music-encoding/music-encoding - todo sort each version into correct folder, no version applicable yet
# download the required tei odd and stylesheet sources in the image and move them to the respective folders (${TEI_SOURCES_HOME})
RUN curl -s -L -o /tmp/mei200.zip https://github.com/music-encoding/music-encoding/archive/refs/tags/MEI2012_v2.0.0.zip \
    && unzip /tmp/mei200.zip -d /tmp/mei200 \
    && rm /tmp/mei200.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-encoding/mei200 \
    && cp -r /tmp/mei200/*/*  ${MEI_SOURCES_HOME}/music-encoding/mei200 \
    && rm -r /tmp/mei200 \
    && xmllint -xinclude ${MEI_SOURCES_HOME}/music-encoding/mei200/source/specs/mei-source.xml -o ${MEI_SOURCES_HOME}/music-encoding/mei200/source/mei-source_canonicalized.xml \
    && curl -s -L -o /tmp/mei211.zip https://github.com/music-encoding/music-encoding/archive/refs/tags/MEI2013_v2.1.1.zip \
    && unzip /tmp/mei211.zip -d /tmp/mei211 \
    && rm /tmp/mei211.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-encoding/mei211 \
    && cp -r /tmp/mei211/*/*  ${MEI_SOURCES_HOME}/music-encoding/mei211 \
    && rm -r /tmp/mei211 \
    && xmllint -xinclude ${MEI_SOURCES_HOME}/music-encoding/mei211/source/specs/mei-source.xml -o ${MEI_SOURCES_HOME}/music-encoding/mei211/source/mei-source_canonicalized.xml \
    && curl -s -L -o /tmp/mei300.zip https://github.com/music-encoding/music-encoding/archive/refs/tags/v3.0.0.zip \
    && unzip /tmp/mei300.zip -d /tmp/mei300 \
    && rm /tmp/mei300.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-encoding/mei300 \
    && cp -r /tmp/mei300/*/*  ${MEI_SOURCES_HOME}/music-encoding/mei300 \
    && rm -r /tmp/mei300 \
    && xmllint -xinclude ${MEI_SOURCES_HOME}/music-encoding/mei300/source/specs/mei-source.xml -o ${MEI_SOURCES_HOME}/music-encoding/mei300/source/mei-source_canonicalized.xml \
    && curl -s -L -o /tmp/mei401.zip https://github.com/music-encoding/music-encoding/archive/refs/tags/v4.0.1.zip \
    && unzip /tmp/mei401.zip -d /tmp/mei401 \
    && rm /tmp/mei401.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-encoding/mei401 \
    && cp -r /tmp/mei401/*/*  ${MEI_SOURCES_HOME}/music-encoding/mei401 \
    && rm -r /tmp/mei401 \
    && xmllint -xinclude ${MEI_SOURCES_HOME}/music-encoding/mei401/source/mei-source.xml -o ${MEI_SOURCES_HOME}/music-encoding/mei401/source/mei-source_canonicalized.xml \
    && curl -s -L -o /tmp/mei500.zip https://github.com/music-encoding/music-encoding/archive/refs/tags/v5.0.zip \
    && unzip /tmp/mei500.zip -d /tmp/mei500 \
    && rm /tmp/mei500.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-encoding/mei500 \
    && cp -r /tmp/mei500/*/*  ${MEI_SOURCES_HOME}/music-encoding/mei500 \
    && rm -r /tmp/mei500 \
    && xmllint -xinclude ${MEI_SOURCES_HOME}/music-encoding/mei500/source/mei-source.xml -o ${MEI_SOURCES_HOME}/music-encoding/mei500/source/mei-source_canonicalized.xml \    
    && git clone --depth 1 -b develop https://github.com/music-encoding/music-encoding /tmp/meidev \
    && cd /tmp/meidev \
    && git rev-parse HEAD > /tmp/meidev/GITHASH \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-encoding/meidev \
    && cp -r /tmp/meidev/*  ${MEI_SOURCES_HOME}/music-encoding/meidev \
    && curl -s -L -o ${MEI_SOURCES_HOME}/music-encoding/meidev/source/mei-source_canonicalized.xml https://raw.githubusercontent.com/music-encoding/schema/main/dev/mei-source_canonicalized_v5.1-dev.xml \
    && rm -r /tmp/meidev

#https://github.com/Edirom/data-configuration - no releases, clone most recent version in dev branch and move to correct folder
RUN git clone --depth 1 -b dev https://github.com/Edirom/data-configuration /tmp/data-configuration \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-stylesheets/data-configuration \
    && cp -r /tmp/data-configuration/*  ${MEI_SOURCES_HOME}/music-stylesheets/data-configuration \
    && rm -r /tmp/data-configuration

VOLUME ["/usr/share/xml/tei/stylesheet", "/usr/share/xml/tei/odd", "/user/share/xml/mei"]

EXPOSE 8080 8081

HEALTHCHECK CMD curl --fail http://localhost:8080/ege-webservice/Info || exit 1

ENTRYPOINT ["/my-docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
