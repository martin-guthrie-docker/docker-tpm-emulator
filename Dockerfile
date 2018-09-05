FROM ubuntu:16.04
MAINTAINER Doug Goldstein <doug@starlab.io>

# bring in dependencies
RUN apt-get update && \
    apt-get --yes --quiet install build-essential git automake autoconf curl \
        pkg-config autoconf-archive libtool libcurl4-openssl-dev libgmp-dev \
        libssl-dev cmake trousers tpm-tools pwgen man vim && \
    apt-get clean &&  \
    rm -rf /var/lib/apt/lists* /tmp/* /var/tmp/*

# OpenSSL
ARG openssl_name=openssl-1.1.0h
WORKDIR /tmp
RUN curl -sSfL https://www.openssl.org/source/openssl-1.1.0h.tar.gz > openssl-1.1.0h.tar.gz && \
    tar -zxf openssl-1.1.0h.tar.gz && \
    cd openssl-1.1.0h && \
    ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl && \
    make -j$(nproc) && \
    make install && \
    openssl version

# tpm-emulator
WORKDIR /tmp
RUN git clone https://github.com/PeterHuewe/tpm-emulator.git
RUN cd tpm-emulator && \
    mkdir build && \
   cd build && \
    cmake ../ && \
    make tpmd && \
    mv tpmd/unix/tpmd /usr/local/bin/ && \
    cd && \
    rm -rf tpm-emulator

# have trousers always connect to the tpm-emulator
ENV TCSD_USE_TCP_DEVICE=1

# the trousers listens on ports 2412
EXPOSE 2412

# tpm2-emulator
# IBM's Software TPM 2.0
WORKDIR /tmp
RUN curl -sSfL https://sourceforge.net/projects/ibmswtpm2/files/ibmtpm1119.tar.gz/download > ibmtpm1119.tar.gz && \
    mkdir ibmtpm && \
    cd ibmtpm && \
    tar -zxf ../ibmtpm1119.tar.gz && \
    cd src && \
    CFLAGS="-I/usr/local/openssl/include" make -j$(nproc) && \
    mv tpm_server /usr/local/bin/ && \
    cd && \
    rm -rf ibmtpm ibmtpm1119.tar.gz

# tpm2-tss
WORKDIR /tmp
RUN curl -sSfL https://github.com/01org/tpm2-tss/releases/download/1.2.0/tpm2-tss-1.2.0.tar.gz > tpm2-tss-1.2.0.tar.gz && \
    tar -zxf tpm2-tss-1.2.0.tar.gz && \
    cd tpm2-tss-1.2.0 && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    cd && \
    rm -rf tpm2-tss-1.2.0 && \
    ldconfig

# tpm2-tools
WORKDIR /tmp
RUN curl -sSfL https://github.com/01org/tpm2-tools/archive/2.1.0.tar.gz > tpm2-tools-2.1.0.tar.gz && \
    tar -zxf tpm2-tools-2.1.0.tar.gz && \
    cd tpm2-tools-2.1.0 && \
    ./bootstrap && \
    ./configure --prefix=/usr --disable-hardening --with-tcti-socket --with-tcti-device && \
    make && \
    make install && \
    cd && \
    rm -rf tpm2-tools-2.1.0 && \
    ldconfig

# have the tpm2 tools always connect to the socket
ENV TPM2TOOLS_TCTI_NAME=socket

# the TPM2 emulator listens on ports 2321 and 2322.
EXPOSE 2321
EXPOSE 2322

#ENTRYPOINT ["/usr/local/bin/tpm_server","-rm"]
