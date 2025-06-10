# cachedb-container
Caché Intersystems in container for use in development and DBA tasks

## Required

Copy your Caché/CSPGateway installation package to the respective directory.

Example:

```
├── cache
│   ├── cache-201x.x.x.xxx.x.xxxxx-lnxrhx64.tar.gz
│   ├── Containerfile
│   ├── entrypoint.sh
│   └── ManifestInstall.cls
├── cspgateway
│   ├── CSPGateway-201x.x.x.xxx.x-lnxubuntux64.tar.gz
│   ├── Containerfile
│   ├── cspgateway.conf
│   └── CSP.ini
```

## Compose

Build and run containers with Compose

`podman-compose up -d`

## Image

#### Build image

Build the Caché image:

`podman build -t isc/cache:latest .`

Build the CSPGateway image:

`podman build -t isc/cspgateway .`

#### Run container

Store your Caché License in secrets

`cat cache.key | podman secret create cache-key - `

Create a network for Caché to communicate with CSPGateway

`podman network create --driver bridge cache-net`

Run the Caché container

`podman run -d --name cachedb -p 1972:1972 --cpus=2 --memory=2g --net cache-net -h cache --secret=cache-key -e CACHE_KEY_FILE='/run/secrets/cache-key' isc/cache:latest`

Optionally, with volume:

`mkdir -pv ~/volume/isc-cache`

`podman run -d --name cachedb -p 1972:1972 --cpus=2 --memory=2g --net cache-net -h cache --secret=cache-key -e CACHE_KEY_FILE='/run/secrets/cache-key' -v ~/volume/isc-cache:/home/cache/volume:U,Z isc/cache:latest`

Run the CSPGateway container

`podman run -dit --name cspgateway --net cache-net -h cspgateway -p 8080:80 isc/cspgateway`

#### Access container

Access the Caché Terminal

`podman exec -it cachedb csession CACHE -U %SYS`

Check logs

`podman exec -it cachedb tail /opt/isc/cache/mgr/cconsole.log`

