# MEIGarage

[![Build Status](https://github.com/Edirom/MEIGarage/actions/workflows/maven_docker.yml/badge.svg)](https://github.com/Edirom/MEIGarage/actions/workflows/maven_docker.yml)
[![GitHub license](https://img.shields.io/github/license/teic/TEIGarage.svg)](https://github.com/Edirom/MEIGarage/blob/main/LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/Edirom/MEIGarage.svg)](https://github.com/Edirom/MEIGarage/releases)
[![Docker](https://img.shields.io/docker/pulls/edirom/meigarage)](https://hub.docker.com/r/edirom/meigarage)
[![fair-software.eu](https://img.shields.io/badge/fair--software.eu-%E2%97%8F%20%20%E2%97%8F%20%20%E2%97%8F%20%20%E2%97%8F%20%20%E2%97%8F-green)](https://fair-software.eu)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/6279/badge)](https://bestpractices.coreinfrastructure.org/projects/6279)
[![NFDI4C Registry](https://img.shields.io/badge/NFDI4Culture%20Registry-64BEA0)](https://nfdi4culture.de/id/E3654)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8199808.svg)](https://doi.org/10.5281/zenodo.8199808)

<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about)
* [How to use](#how-to-use)
* [Installation](#installation)
    * [With Docker](#installing-with-docker)
    * [Without Docker](#installing-without-docker)
* [Building with Maven](#building-with-maven)


# About

MEIGarage is a webservice and RESTful service to transform, convert and validate various formats, focussing on the [MEI](https://music-encoding.org/) format.
MEIGarage is based on the proven [OxGarage](https://github.com/TEIC/oxgarage). 

Further information on the *code structure* of MEIGarage and TEIGarage can be found [here](https://github.com/Edirom/MEIGarage/blob/main/doc/code-structure.md). Information in form of *presentation slides* and posters can be found [here](https://anneferger.github.io/MEITEIGarage/).

A running instance of MEIGarage can be found at [meigarage.edirom.de](https://meigarage.edirom.de/).

# How to use

Open API documentation can be found at https://github.com/Edirom/MEIGarage/blob/main/src/main/webapp/openapi.json or at the running instance https://meigarage.edirom.de/ege-webservice/. A curl example call to the API to convert an existing MEI 3.0 document to an MEI 4.0 document looks like

```
curl  -o 4.0.0.mei -F upload=@input-3.0.0.mei https://meigarage.edirom.de/ege-webservice/Conversions/mei30%3Atext%3Axml/mei40%3Atext%3Axml/
```

# Installation

## Installing with Docker

With Docker installed, a readymade image can be fetched from the [GitHub Docker Registry](https://github.com/Edirom/MEIGarage/pkgs/container/meigarage) or [DockerHub](https://hub.docker.com/r/edirom/meigarage). For the frontend see [ViFE mMeigarage Webclient](https://github.com/Edirom/vife-meigarage-webclient).

`docker pull ghcr.io/edirom/meigarage:latest` or `docker pull edirom/meigarage:latest`

A container can be run using:

```bash
docker run --rm \
    -p 8080:8080 \
    --name meigarage edirom/meigarage:latest
```

Once it's running, you can point your browser at `http://localhost:8080/ege-webservice` for the webservice.

You can also get the development version from DockerHub with `docker pull edirom/meigarage:dev`.

### available parameters

* **-v** Stylesheet paths : The local path to the stylesheets and sources can be mounted to /usr/share/xml/tei/ using the --volume parameter, using e.g.  `-v /your/path/to/Stylesheets:/usr/share/xml/tei/stylesheet \ 
    -v /your/path/to/TEI/P5:/usr/share/xml/tei/odd`

### TEI and MEI sources and stylesheets

When the docker image is build, the latest releases of the TEI and MEI Sources and Stylesheets are added to the image.

If you want to use another version of the sources or stylesheets, you can mount the local folders where your custom files are located when running the Docker image. 

There are several ways to obtain these (see "Get and install a local copy" at http://www.tei-c.org/Guidelines/P5/), 
one of them is to download the latest release of both 
[TEI](https://github.com/TEIC/TEI/releases) and [Stylesheets](https://github.com/TEIC/Stylesheets/releases) from GitHub. 
Then, the Stylesheets' root directory (i.e. which holds the `profiles` directory) must be mapped to `/usr/share/xml/tei/stylesheet` whereas for the 
P5 sources you'll need to find the subdirectory which holds the file `p5subset.xml` and map this to `/usr/share/xml/tei/odd`; (should be `xml/tei/odd`).

The respective git repositories:

| location in docker image | data located there |
| --------------- | --------------- | 
| /usr/share/xml/tei/stylesheet |  https://github.com/TEIC/Stylesheets/releases/latest | 
| /usr/share/xml/tei/odd | https://github.com/TEIC/TEI/releases/latest |
| /usr/share/xml/mei/music-stylesheets/encoding-tools | https://github.com/music-encoding/encoding-tools/releases/latest | 
| /usr/share/xml/mei/music-stylesheets/w3c-musicxml  | https://github.com/w3c/musicxml/releases/latest | 
| /usr/share/xml/mei/music-stylesheets/meiler | https://github.com/rettinghaus/MEILER/releases/latest | 
| /usr/share/xml/mei/music-encoding | https://github.com/music-encoding/music-encoding - each released version sorted into the respctive folder | 
| /usr/share/xml/mei/music-stylesheets/data-configuration | https://github.com/Edirom/data-configuration - the whole repository| 

Using your local folders for the TEI sources and stylesheets: 

```bash
docker run --rm \
    -p 8080:8080 \   
    -e WEBSERVICE_URL=http://localhost:8080/ege-webservice/  \  
    -v /your/path/to/tei/stylesheet:/usr/share/xml/tei/stylesheet \
    -v /your/path/to/tei/odd:/usr/share/xml/tei/odd  \    
    -v /your/path/to/mei/music-stylesheets/encoding-tools:/usr/share/xml/mei/music-stylesheets/encoding-tools \
    -v /your/path/to/mei/music-stylesheets/w3c-musicxml:/usr/share/xml/mei/music-stylesheets/w3c-musicxml \
    -v /your/path/to/mei/music-stylesheets/meiler:/usr/share/xml/mei/music-stylesheets/meiler \
    -v /your/path/to/mei/music-encoding:/usr/share/xml/mei/music-encoding \
    -v /your/path/to/mei/music-stylesheets/data-configuration:/usr/share/xml/mei/music-stylesheets/data-configuration \    
    --name meigarage ghcr.io/edirom/meigarage
```

You can also change the version that is used by supplying different version number when building the image locally running something like

```bash
docker build \
--build-arg VERSION_STYLESHEET=7.52.0 \
--build-arg VERSION_ODD=4.3.0 \
--build-arg VERSION_ENCODING_TOOLS=3.0.0 \
--build-arg VERSION_W3C_MUSICXML=4.0 \
--build-arg VERSION_MEILER=2.0.0  \
.
```

in your local copy of the MEIGarage. 

### exposed ports

The Docker image exposes two ports, 8080 and 8081. If you're running MEIGarage over plain old HTTP, use the 8080 connector. 
For HTTPS connections behind a 
[SSL terminating Load Balancer](https://creechy.wordpress.com/2011/08/22/ssl-termination-load-balancers-java/), please use the 8081 connector.

## Installing without Docker

### Getting the application packages

The latest released application package (WAR file) is available from the [MEIGarage release page](https://github.com/Edirom/MEIGarage/releases). 
The latest dev version can be downloaded via [nightly.link](https://nightly.link/) from the [GitHub Action](https://github.com/Edirom/MEIGarage/blob/main/.github/workflows/maven_docker.yml) at [nightly.link/Edirom/MEIGarage/workflows/maven_docker/main/artifact.zip](https://nightly.link/Edirom/MEIGarage/workflows/maven_docker/main/artifact.zip).

The war file could also be build locally, see [Building with Maven](#building-with-maven). 

### Running the application packages

Using a running Tomcat (or similar container), you can install the WAR file (see above) in the usual way. In this case, you will need to do some configuration manually:

 1.   copy the file [MEIGarage/WEB-INF/lib/oxgarage.properties](https://github.com/Edirom/MEIGarage/blob/main/src/main/webapp/WEB-INF/lib/oxgarage.properties) to `/etc/oxgarage.properties`
 2.   create a directory `/var/cache/oxgarage` and copy the file [log4j.xml](https://github.com/Edirom/MEIGarage/blob/main/log4j.xml) to there
 3.   make the directory owned by the Tomcat user, so that it can create files there: eg `chown -R tomcat6:tomcat6 /var/cache/oxgarage`
 4.   make sure the MEI & TEI stylesheets and source are installed at `/usr/share/xml/tei` using the Debian file hierarchy standard; the distribution files mentioned in the [TEI and MEI sources and stylesheets](#tei-and-mei-sources-and-stylesheets) are in the correct layout.

You'll probably need to restart your servlet container to make sure these changes take effect.

Edit the file `oxgarage.properties` if you need to change the names of directories.

Check the working system by visiting /ege-webclient/ on your Tomcat (or similar) server, and trying an example transformation. You can check the RESTful web server using e.g. Curl. For example, to convert a MEI 3.0 file to Lilypond format, you might do

```bash
curl -s -o test.ly -F upload=@test.xml http://localhost:8080//ege-webservice/Conversions/mei40%3Atext%3Axml/lilypond%3Atext%3Ax-lilypond/
```

# Building with Maven

The MEIGarage Java project can be built with Maven using

`mvn -B package --file pom.xml`

Readymade .war files can be downloaded from the [GitHub Action using nightly.link](https://nightly.link/Edirom/MEIGarage/workflows/maven_docker/main/artifact.zip). For the required Java version see:
https://github.com/Edirom/MEIGarage/blob/6f50fdb96300acc3a8e982cae77265d4a9c96c4a/.github/workflows/maven_docker.yml#L21.


## dependencies

The dependencies needed for the Maven build that are not available at the main [Maven repository](https://mvnrepository.com/) are available through GitHub Packages at the [TEIC](https://github.com/orgs/TEIC/packages) and [Edirom](https://github.com/orgs/Edirom/packages) GitHub organizations. While those packages are public, [GitHub authentication](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-apache-maven-registry#installing-a-package) is needed to access those packages.

To authenticate when building locally, create a [GitHub PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with the read:packages scope. Create a maven settings file or edit an existing one and add it to your .m2 folder (e.g. at /home/name/.m2)

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      http://maven.apache.org/xsd/settings-1.0.0.xsd">

  <activeProfiles>
    <activeProfile>github</activeProfile>
  </activeProfiles>

  <profiles>
    <profile>
      <id>github</id>
      <repositories>
        <repository>
          <id>central</id>
          <url>https://repo1.maven.org/maven2</url>
        </repository>
        <repository>
          <id>githubtei</id>
          <url>https://maven.pkg.github.com/TEIC/*</url>
          <snapshots>
            <enabled>true</enabled>
          </snapshots>
        </repository>
        <repository>
          <id>githubedirom</id>
          <url>https://maven.pkg.github.com/Edirom/*</url>
          <snapshots>
            <enabled>true</enabled>
          </snapshots>
        </repository>
      </repositories>
    </profile>
  </profiles>

  <servers>
    <server>
      <id>githubtei</id>
      <username>YOURGITHUBUSERNAME</username>
      <password>YOURGITHUBPAT</password>
    </server>
    <server>
      <id>githubedirom</id>
      <username>SAMEGITHUBUSERNAME</username>
      <password>SAMEGITHUBPAT</password>
    </server>
  </servers>
</settings>

```

# Credits

## NFDI4Culture

The Consortium for Research Data on Material and Immaterial Cultural Heritage (NFDI4Culture)

The aim of NFDI4Culture is to establish a demand-oriented infrastructure for research data on material and immaterial cultural assets. This includes 2D digitised reproductions of paintings, photographs and drawings as well as 3D digital models of culturally and historically important buildings, monuments or audiovisual data of music, film and stage performances. Concept and structure of the consortium were developed over two years in an open process and in close cooperation between 11 professional societies, 9 supporting institutions and 52 partners. The consortium addresses the needs of a broad spectrum of disciplines from architecture, art, music, theatre, dance, film and media studies.

[nfdi4culture.de](https://www.nfdi4culture.de)
[NFDI4Culture on Mastodon](https://nfdi.social/@nfdi4culture)
