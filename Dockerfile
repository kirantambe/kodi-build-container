FROM ubuntu:16.04
MAINTAINER Kiran Tambe <kiran.tambe08@gmail.com>
# Sets up environment for building Kodi for Android.

RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    build-essential \
    cmake \
    curl \
    default-jdk \
    # Used by configure to check arch. Will incorrectly identify arch without it.
    file \
    gawk \
    git \
    gperf \
    lib32stdc++6 \
    lib32z1 \
    lib32z1-dev \
    libcurl4-openssl-dev \
    nasm \
    unzip \
    zip \
    zlib1g-dev

WORKDIR /opt
RUN curl -O http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz 
RUN tar xzf android-sdk_r24.4.1-linux.tgz 
RUN rm -f android-sdk_r24.4.1-linux.tgz

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

RUN echo y | android update sdk --filter android-21 --no-ui --force -a

ENV ANDROID_NDK_DIR android-ndk-r12b
ENV ANDROID_NDK_ZIP "${ANDROID_NDK_DIR}-linux-x86_64.zip"
ENV ANDROID_NDK_URL "https://dl.google.com/android/repository/${ANDROID_NDK_ZIP}"
RUN curl -O "${ANDROID_NDK_URL}"
RUN unzip "${ANDROID_NDK_ZIP}" -x "${ANDROID_NDK_DIR}/platforms/*"
RUN unzip "${ANDROID_NDK_ZIP}" "${ANDROID_NDK_DIR}/platforms/android-21/*"
RUN rm "${ANDROID_NDK_ZIP}"

RUN keytool -genkey -keystore ~/.android/debug.keystore -v -alias \
      androiddebugkey -dname "CN=Android Debug,O=Android,C=US" -keypass \
      android -storepass android -keyalg RSA -keysize 2048 -validity 10000

RUN echo y | android update sdk --all -u -t build-tools-20.0.0

WORKDIR /opt/${ANDROID_NDK_DIR}/build/tools
RUN ./make-standalone-toolchain.sh --ndk-dir=../.. \
      --install-dir=/opt/android-toolchain-arm/android-21 --platform=android-21 \
      --toolchain=arm-linux-androideabi-4.9
