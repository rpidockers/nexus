#
# jpodeszwik/rpi-nexus Dockerfile
#
FROM jpodeszwik/rpi-java:1.8.0_06 

# install nexus
ENV NEXUS_VERSION 2.8.1
RUN \
    cd tmp && \
    wget http://www.sonatype.org/downloads/nexus-$NEXUS_VERSION-bundle.tar.gz && \
    tar -xvzf nexus-$NEXUS_VERSION-bundle.tar.gz -C /opt && \
    rm -f nexus-$NEXUS_VERSION-bundle.tar.gz && \
    ln -s /opt/nexus* /opt/nexus

# build and install wrapper for arm
# based on http://honnix.com/technology/raspberry%20pi/java/2013/07/14/sonatype-nexus-on-raspberry-pi/
RUN \
    apt-get install -y make gcc && \
    wget http://wrapper.tanukisoftware.com/download/3.2.3/wrapper_3.2.3_src.tar.gz && \
    tar -xvzf wrapper_3.2.3_src.tar.gz && \
    rm wrapper_3.2.3_src.tar.gz && \
    cd wrapper_3.2.3_src && \
    sed -i 's/<javah/<!--javah/g' build.xml && \
    sed -i 's/<\/javah>/<\/javah-->/g' build.xml && \
    cp src/c/Makefile-linux-x86-32 src/c/Makefile-linux-arm-32 && \
    sed -i 's/$(COMPILE) -pthread $(wrapper_SOURCE) -o $(BIN)\/wrapper/$(COMPILE) -lm -pthread $(wrapper_SOURCE) -o $(BIN)\/wrapper/g' src/c/Makefile-linux-arm-32 && \
    ./build32.sh && \
    cd /opt/nexus/bin/jsw/ && \
    cp -r linux-x86-64/ linux-armv6l-32 && \
    cp /wrapper_3.2.3_src/bin/wrapper linux-armv6l-32/ && \
    cp /wrapper_3.2.3_src/lib/libwrapper.so lib/libwrapper-linxux-arm-32.so && \
    ln -s linux-armv6l-32/ linux-armv7l-32 && \
    rm -rf /wrapper_3.2.3_src

# nexus doesn't like to be ran as root
RUN \
    useradd nexus && \
    chown -R nexus:nexus /opt/nexus/ && \
    chown -R nexus:nexus /opt/sonatype-work

VOLUME /opt/sonatype-work/nexus

EXPOSE 8081

ADD run.sh /bin/run.sh
CMD /bin/run.sh

