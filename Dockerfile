FROM jetbrains/teamcity-agent:2019.2.1

MAINTAINER Paweł Gajda

ENV GRADLE_HOME=/usr/bin/gradle
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y --force-yes expect git mc gradle unzip \
    wget curl libc6-i386 lib32stdc++6 lib32gcc1 \
    lib32ncurses5 lib32z1 openjdk-11-jdk
RUN apt-get clean
RUN rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD android-accept-licenses.sh /opt/tools/
ENV PATH ${PATH}:/opt/tools
ENV LICENSE_SCRIPT_PATH /opt/tools/android-accept-licenses.sh

RUN cd /opt && wget --output-document=android-tools.zip \
    https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
    unzip android-tools.zip -d android-sdk-linux && \
    chown -R root.root android-sdk-linux && \
    wget https://nodejs.org/dist/v16.19.1/node-v16.19.1-linux-x64.tar.gz && \
    tar -xvzf node-v16.19.1-linux-x64.tar.gz && \
    chown -R root.root node-v16.19.1-linux-x64 && \
    rm *.zip *.tar.*

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:/opt/node-v16.19.1-linux-x64/bin

RUN yes | sdkmanager --licenses
RUN sdkmanager --update
RUN yes | sdkmanager "build-tools;29.0.3" "platforms;android-29" "ndk-bundle" "ndk;21.0.6113669"

RUN apt update && \
    ##################################################
    # Powershell
    # Install pre-requisite packages.
    apt install -y wget apt-transport-https software-properties-common && \
    # Download the Microsoft repository GPG keys
    wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" && \
    # Register the Microsoft repository GPG keys
    dpkg -i packages-microsoft-prod.deb && \
    # Update the list of packages after we added packages.microsoft.com
    apt update && \
    # Install PowerShell
    apt install -y powershell
    ##################################################

RUN apt-get clean
