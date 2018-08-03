FROM phusion/baseimage:0.10.0
LABEL maintainer="AndroidFastlaneNDK <guangqiang.dev@gmail.com>"

CMD ["/sbin/my_init"]

ENV LC_ALL "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"
ENV LANG "en_US.UTF-8"

ENV VERSION_SDK_TOOLS "4333796"
ENV VERSION_BUILD_TOOLS "27.0.3"
ENV VERSION_TARGET_SDK "27"
ENV VERSION_NDK r17b

ENV ANDROID_HOME "/sdk"
ENV ANDROID_NDK_HOME "/ndk"

ENV PATH "$PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive

ENV HOME "/root"

RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update
RUN apt-get -y install --no-install-recommends \
    curl \
    openjdk-8-jdk \
    unzip \
    zip \
    git \
    ruby2.4 \
    ruby2.4-dev \
    build-essential \
    file \
    ssh

ADD https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip /tools.zip
RUN unzip /tools.zip -d /sdk && rm -rf /tools.zip

RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses

# SDK
RUN mkdir -p $HOME/.android && touch $HOME/.android/repositories.cfg
RUN ${ANDROID_HOME}/tools/bin/sdkmanager "platform-tools" "tools" "platforms;android-${VERSION_TARGET_SDK}" "build-tools;${VERSION_BUILD_TOOLS}"
RUN ${ANDROID_HOME}/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"

# NDK
RUN mkdir /tmp/android-ndk && \
    cd /tmp/android-ndk && \
    curl -s -O https://dl.google.com/android/repository/android-ndk-${VERSION_NDK}-linux-x86_64.zip && \
    unzip -q android-ndk-${VERSION_NDK}-linux-x86_64.zip && \
    mv ./android-ndk-${VERSION_NDK} ${ANDROID_NDK_HOME} && \
    cd ${ANDROID_NDK_HOME} && \
    rm -rf /tmp/android-ndk

# Fastlane
RUN gem install fastlane

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*