#!/bin/bash

if [ ! -d "/opt/sonatype-work/nexus" ]; then
    mkdir -p /opt/sonatype-work/nexus
    chown -R nexus:nexus /opt/sonatype-work
fi

exec su nexus -c '/opt/nexus/bin/nexus console'
