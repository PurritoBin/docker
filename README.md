# Purrito Bin  (=♡ᆺ ♡=)
[![pipeline](https://github.com/PurritoBin/PurritoBin/workflows/pipeline/badge.svg)](https://github.com/PurritoBin/PurritoBin/actions?query=workflow:pipeline)
[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/PurritoBin/PurritoBin?include_prereleases)](https://github.com/PurritoBin/PurritoBin/releases)
[![GitHub license](https://img.shields.io/github/license/PurritoBin/PurritoBin.svg)](https://github.com/PurritoBin/PurritoBin/blob/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues-raw/PurritoBin/PurritoBin)](https://github.com/PurritoBin/PurritoBin/issues)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/PurritoBin/PurritoBin/issues)

ultra fast, minimalistic, encrypted command line paste-bin

## Features and Highlights

- Very lightweight: 2-3 MB of RAM on average.
- Listen on multiple address/port combinations, both IPv4 and IPv6.
- Configurable paste size limit.
- Paste storage in plain text, easy to integrate with all web servers (Apache, Nginx, etc.).
- Encrypted pasting similar to [PrivateBin](https://github.com/PrivateBin/PrivateBin).
- Optional SSL support for secure communication.
- Tiny code base, less than 1000 lines of code, for very easy auditing.
- Well documented, `man purrito`.

## Parameters

| Variable | Default | Description |
|--------- | ------- | ----------- |
| DOMAIN   | `http://localhost/` | **domain** used as prefix of returned paste |
| MAXPASTESIZE  | `65536`  | Maximum paste size allowed, in BYTES |
| SLUGSIZE  | `7` | Length of the randomly generated string for the paste |
| SSL  | `NO` | To enable listening via `https` |
| SERVERNAME  | `localhost` | Server name used for TLS handshakes, must be valid for the given certificates |
| PUBLICKEY | `/etc/purritobin/public.crt` | SSL public certificate |
| PRIVATEKEY | `/etc/purritobin/private.crt` | SSL private certificate|

## Usage （ฅ＾・ﻌ・＾）ฅ

For all examples below, remember to substitute the value of `DOMAIN` from `localhost` to the actual domain/IP of the machine.

### docker cli

#### HTTP

The simplest example is to run a server listening for pastes on port `42069`

```
docker run -d \
  --name=purritobin \
  -e DOMAIN="http://localhost:42069/" \
  -e MAXPASTESIZE=65536 \
  -e SLUGSIZE="7" \
  -p 42069:42069 \
  -v /path/to/paste/storage/folder:/var/www/purritobin \
  --restart unless-stopped \
  purritobin/purritobin
```

To do a test paste to the above server
```
  $ echo "123123" | curl --silent --data-binary "@${1:-/dev/stdin}" "http://localhost:42069/"
  http://localhost:42069/orovwsc
  $ curl --silent http://localhost:42069/orovwsc
  123123
```

#### HTTPS

To run with `https`, the public and private SSL keys need to be provided to the container and mounted at `/etc/purritobin`.
By default, it is assumed that the public and private keys are stored at `/etc/purritobin/public.crt` and `/etc/purritobin/private.crt`, respectively.
For example, assuming that the certificates, for the domain `localhost`, are stored on the host machine at `/path/to/certificates/folder/{public,private}.crt`, PurritoBin can be started in SSL mode with:

```
docker run -d \
  --name=purritobin \
  -e DOMAIN="https://localhost:42069/" \
  -e MAXPASTESIZE=65536 \
  -e SLUGSIZE="7" \
  -e SSL="YES" \
  -e PUBLICKEY="/etc/purritobin/public.crt" \
  -e PRIVATEKEY="/etc/purritobin/private.crt \
  -e SERVERNAME="localhost" \
  -p 42069:42069 \
  -v /path/to/paste/storage/folder:/var/www/purritobin \
  -v /path/to/certificates/folder:/etc/purritobin \
  --restart unless-stopped \
  purritobin/purritobin
```
