ARG TARGET_OS=jessie
FROM debian:${TARGET_OS}

ARG VERSION=3.4.1.p0.1
ARG OS_VERSION=jessie

RUN apt-get -qq update && \
    apt-get install -qq -y \
    bzip2 \
    curl && \
    curl -O https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh && \
    bash Miniconda2-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm -f Miniconda2-latest-Linux-x86_64.sh && \
    export PATH=/opt/conda/bin:$PATH && \
    conda create -y -q --copy -c r -n R_env r-essentials && \
    sed -i s,/opt/conda/envs/R_env,/opt/cloudera/parcels/CONDAR/lib/conda-R, /opt/conda/envs/R_env/bin/R

RUN mkdir -p /data/CONDAR-$VERSION/lib && \
    mkdir -p /data/CONDAR-$VERSION/meta
WORKDIR /data

RUN mv /opt/conda/envs/R_env /data/CONDAR-$VERSION/lib/conda-R

COPY source/meta/* CONDAR-$VERSION/meta/
RUN sed -i \
    -e "s/el7/${OS_VERSION}/g" \
    -e "s/3.4.1/${VERSION}/g" \
    CONDAR-${VERSION}/meta/parcel.json && \
    tar czf CONDAR-${VERSION}-${OS_VERSION}.parcel CONDAR-${VERSION} --owner=root --group=root && \
    rm -rf CONDAR-${VERSION}

CMD ['/bin/bash']