FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN TZ=Etc/UTC apt-get -y install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32readline-dev lib32z1-dev libelf-dev liblz4-tool libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev libwxgtk3.0-gtk3-dev libncurses5-dev lib32ncurses5-dev openjdk-8-jdk python3-setuptools python2
RUN mkdir -p /home/android/bin
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /home/android/bin/repo && chmod a+x /home/android/bin/repo
RUN mkdir -p /home/android/lineage
ENV PATH $PATH:/home/android/bin:/home/android/lineage/out/host/linux-x86/bin
RUN cd /home/android/lineage
RUN git config --global user.email "you@example.com&quot"
RUN git config --global user.name "Android Build User"
COPY python_switch.sh /home/android/bin/python_switch
RUN chmod a+x /home/android/bin/python_switch && python_switch 3
COPY java_security_patch.py /home/android/bin/java_security_patch
RUN chmod a+x /home/android/bin/java_security_patch && java_security_patch
ENV SHELL /bin/bash
