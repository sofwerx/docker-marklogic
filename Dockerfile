FROM centos:centos7

# Install required libraries for MarkLogic and container 
RUN yum update -y && \
    yum install -y deltarpm initscripts glibc.i686 gdb.x86_64 redhat-lsb.x86_64 && \
    yum clean all

#Set default directory when attaching to container
WORKDIR /opt

# Set Environment variables for MarkLogic
ENV MARKLOGIC_INSTALL_DIR /opt/MarkLogic
ENV MARKLOGIC_DATA_DIR /data
ENV MARKLOGIC_FSTYPE ext4
ENV MARKLOGIC_USER daemon
ENV MARKLOGIC_PID_FILE /var/run/MarkLogic.pid
ENV MARKLOGIC_MLCMD_PID_FILE /var/run/mlcmd.pid
ENV MARKLOGIC_UMASK 022
ENV PATH $PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/MarkLogic/mlcmd/bin

#MarkLogic RPM package to install
ARG MARKLOGIC_RPM=MarkLogic-RHEL7-8.0-7.2.x86_64.rpm

#Copy MarkLogic RPM to to image
COPY ${MARKLOGIC_RPM} /tmp/${MARKLOGIC_RPM}
#Copy configuration file to image. Config file is used by initialization scripts
COPY mlconfig.sh /opt
# Copy entry-point init script to image
COPY entry-point.sh /opt
# Copy setup-enode script to image
COPY setup-child.sh /opt
# Copy the setup-master script to the image
COPY setup-master.sh /opt
# Set file permissions of configuration scripts
RUN chmod a+x /opt/entry-point.sh && \
    chmod a+x /opt/setup-child.sh && \
    chmod a+x /opt/setup-master.sh

#Install MarkLogic
RUN yum -y install /tmp/${MARKLOGIC_RPM} && rm /tmp/${MARKLOGIC_RPM}

# Setting ports to be exposed by the container. Add more if your application needs them
# 7997	Default HealthCheck application server port and is required to check health/proper running of a MarkLogic instance.
# 7998	Default foreign bind port on which the server listens for foreign inter-host communication between MarkLogic clusters.
# 7999	Default bind port on which the server listens for inter-host communication within the cluster. The bind port is required for all MarkLogic Server Clusters.
# 8000	Default App-Services application server port and is required by Query Console.
# 8001	Default Admin application server port and is required by the Administrative Interface.
# 8002	Default Manage application server port and is required by Configuration Manager and Monitoring Dashboard.

EXPOSE 7997 7998 7999 8000 8001 8002

VOLUME /data

ENTRYPOINT /opt/entry-point.sh
