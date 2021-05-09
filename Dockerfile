FROM alpine:3.13.5

ARG  US_TAG="5440dbac79bd76444175b76ee95dfcade12a6aac"
ARG  UWS_TAG="2fb38d5de92795998f9137ae30193aa65128b68b"
ARG  MDB_TAG="0.9.29"
ARG  MDBXX_TAG="1.0.0"

ARG  P_TAG="0.6.6"
ARG  PD_TAG="0.6.6-docker0"
ARG  VERSION="latest"

ENV PUID=1000
ENV PGID=1000

ENV CC=gcc
ENV CXX=g++
ENV CFLAGS="-flto -O3"
ENV CXXFLAGS="-flto -O3"
ENV LDFLAGS="-flto -O3"

ENV DOMAIN="http://localhost:42069/"
ENV MAXPASTESIZE="65536"
ENV SLUGSIZE="7"

ENV TLS=NO
ENV SERVERNAME="http://localhost/"
ENV PUBLICKEY="/etc/purritobin/public.crt"
ENV PRIVATEKEY="/etc/purritobin/private.crt"

WORKDIR /purritobin

RUN apk update \
 && apk add libgcc libstdc++ libssl1.1 libcrypto1.1 lmdb-dev \
 && apk add gcc g++ git make musl-dev openssl-dev meson ninja \
 && mkdir -p /var/www/purritobin /etc/purritobin /var/db/purritobin \
 && chown -R ${PUID}:${PGID} /var/www/purritobin /etc/purritobin /var/db/purritobin \
 && git clone https://github.com/uNetworking/uSockets \
 && wget https://raw.githubusercontent.com/gentoo/guru/dev/net-libs/usockets/files/usockets-0.7.1-Makefile.patch \
 && cd uSockets \
 && git checkout ${US_TAG} \
 && git apply < ../usockets-0.7.1-Makefile.patch \
 && make WITH_OPENSSL=1 \
 && make install \
 && cd /purritobin \
 && git clone https://github.com/uNetworking/uWebSockets \
 && cd uWebSockets \
 && git checkout ${UWS_TAG} \
 && cp -r src /usr/include/uWebSockets \
 && cd /purritobin \
 && wget https://raw.githubusercontent.com/hoytech/lmdbxx/${MDBXX_TAG}/lmdb%2B%2B.h -O /usr/include/lmdb++.h \
 && wget https://git.openldap.org/openldap/openldap/-/archive/LMDB_${MDB_TAG}/openldap-LMDB_${MDB_TAG}.tar.gz \
 && tar xzf openldap-LMDB_${MDB_TAG}.tar.gz \
 && cd openldap-LMDB_${MDB_TAG}/libraries/liblmdb \
 && make CC=${CC} XCFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
 && make prefix="/usr" install \
 && cd /purritobin \
 && git clone https://github.com/PurritoBin/PurritoBin \
 && cd PurritoBin \
 && git checkout "${P_TAG}" \
 && meson setup build \
 && ninja -C build install \
 && cd /purritobin \
 && git clone https://github.com/PurritoBin/docker \
 && cd docker \
 && git checkout ${PD_TAG} \
 && install -m0755 purritobin_wrapper /usr/bin \
 && install -m0644 index.html /usr/share/purritobin \
 && cd /purritobin \
 && apk del gcc g++ git make musl-dev openssl-dev meson ninja \
 && cd / \
 && rm -rf /purritobin


USER ${PUID}:${PGID}
VOLUME /var/www/purritobin /var/db/purritobin /etc/purritobin
EXPOSE 42069

CMD /usr/bin/purritobin_wrapper
