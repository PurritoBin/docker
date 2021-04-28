# Purrito Bin  (=♡ᆺ♡=)
[![pipeline](https://github.com/PurritoBin/PurritoBin/workflows/pipeline/badge.svg)](https://github.com/PurritoBin/PurritoBin/actions?query=workflow:pipeline)
[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/PurritoBin/PurritoBin?include_prereleases)](https://github.com/PurritoBin/PurritoBin/releases)
[![GitHub license](https://img.shields.io/github/license/PurritoBin/PurritoBin.svg)](https://github.com/PurritoBin/PurritoBin/blob/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues-raw/PurritoBin/PurritoBin)](https://github.com/PurritoBin/PurritoBin/issues)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/PurritoBin/PurritoBin/issues)

[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/purritobin/purritobin)](https://hub.docker.com/r/purritobin/purritobin)
[![Docker Pulls](https://img.shields.io/docker/pulls/purritobin/purritobin)](https://hub.docker.com/r/purritobin/purritobin)
[![Docker Image Size](https://img.shields.io/docker/image-size/purritobin/purritobin/latest)](https://hub.docker.com/r/purritobin/purritobin)


ultra fast, minimalistic, encrypted command line paste-bin

## Features and Highlights

- *Very* lightweight: 2-3 MB of RAM on average.
- Listen on multiple address/port combinations, both IPv4 and IPv6.
- Configurable paste size limit.
- Auto-cleaning of pastes, with configurable paste lifetime at submission time:
   - `domain.tld/{day,week,month}`
   - `domain.tld/<time-in-minutes>` such as `domain.tld/300`
- Paste storage in plain text, easy to integrate with all web servers (Apache, Nginx, etc.).
- Encrypted pasting similar to [PrivateBin](https://github.com/PrivateBin/PrivateBin).
- Optional **`https`** support for secure communication.
- Tiny code base, less than 1000 lines of code, for very easy auditing.
- Well documented, `man purrito`.

## Environment Variables

The container image allows passing the following variables to configure PurritoBin:

| Variable           | Default                       | Description                                                                                    |
|--------------------|-------------------------------|------------------------------------------------------------------------------------------------|
| **`DOMAIN`**       | `http://localhost:42069/`     | **domain** used as prefix of returned paste                                                    |
| **`MAXPASTESIZE`** | `65536`                       | **maximum paste size** allowed, in *BYTES*                                                     |
| **`SLUGSIZE`**     | `7`                           | **length** of the *randomly generated string id* for the paste                                 |
| **`TLS`**          | `NO`                          | set to `YES` to enable listening via **`https`**                                               |
| **`SERVERNAME`**   | `localhost`                   | **server name indication** used for *TLS* handshakes, must be valid for the given certificates |
| **`PUBLICKEY`**    | `/etc/purritobin/public.crt`  | *TLS* public certificate                                                                       |
| **`PRIVATEKEY`**   | `/etc/purritobin/private.crt` | *TLS* private certificate                                                                      |
| **`PUID`**         | `1000`                        | UID for running privilege separated containers, default should be enough for almost everyone   |
| **`PGID`**         | `1000`                        | GID for running privilege separated containers, default should be enough for almost everyone   |

## Mountable Volumes

The container image can use the following volumes, it is recommended to mount at least the first two volumes for persistent storage:

| Volume                | Description                                                          |
|-----------------------|----------------------------------------------------------------------|
| `/var/www/purritobin` | default location for storing the pastes                              |
| `/var/db/purritobin`  | default location for storing the timestamp database                  |
| `/etc/purritobin`     | default location for loading certificates, only used if enabling TLS |

## Examples

For all examples below, remember to substitute the value of `DOMAIN` from `localhost` to the actual domain/IP of the machine.

PurritoBin listens on port `42069` by default.

### docker cli

#### HTTP

A simple example:
- Run the server while listening for pastes on host port `8080`.
  - Map host port `8080` to container port `42069`.
- Create a persistent store of pastes in host folder `/data/apps/purritobin/pastes`.
  - Make a shared volume by mounting `/data/apps/purritobin/pastes` to `/var/www/purritobin` inside the container.
- Create a persistent store of timestamps in host folder `/data/apps/purritobin/database`.
  - Make another shared volume by mounting `/data/apps/purritobin/database` to `/var/db/purritobin`.

```
docker run -d \
    --name=purritobin \
    -e DOMAIN="http://localhost:8080/" \
    -p 8080:42069 \
    -v /data/apps/purritobin/pastes:/var/www/purritobin \
    -v /data/apps/purritobin/database:/var/db/purritobin \
    --restart unless-stopped \
    purritobin/purritobin
```


To check that the server is running, visit the page in a web browser (or curl it) at [http://localhost:8080/](http://localhost:8080/)

To do a test paste to the above server
```
    $ echo "cool paste" | curl --silent --data-binary "@${1:-/dev/stdin}" "http://localhost:8080/"
    http://localhost:8080/purr1t0
    $ curl --silent http://localhost:8080/purr1t0
    cool paste
```

#### HTTPS

It is possible to run this behind a reverse proxy, such as [nginx](https://www.nginx.com/), [haproxy](https://www.haproxy.org/), or any other reverse proxy of choice.

To run with the inbuilt support for `https`, the public and private keys need to be provided to the container and mounted at `/etc/purritobin`.<br/>
By default, it is assumed that the public and private keys are stored at `/etc/purritobin/public.crt` and `/etc/purritobin/private.crt`, respectively.<br/>
For example, assuming that the certificates for the domain `localhost` are stored on the host machine at `/data/apps/certificates/{public,private}.crt`, Purrito Bin can be started in **`https`** mode with:

```
docker run -d \
    --name=purritobin \
    -e DOMAIN="https://localhost:42069/" \
    -e MAXPASTESIZE=65536 \
    -e SLUGSIZE="7" \
    -e TLS="YES" \
    -e PUBLICKEY="/etc/purritobin/public.crt" \
    -e PRIVATEKEY="/etc/purritobin/private.crt" \
    -e SERVERNAME="localhost" \
    -p 8080:42069 \
    -v /data/apps/purritobin/pastes:/var/www/purritobin \
    -v /data/apps/purritobin/database:/var/db/purritobin \
    -v /data/apps/certificates:/etc/purritobin \
    --restart unless-stopped \
    purritobin/purritobin
```
