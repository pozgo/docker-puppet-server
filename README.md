# Puppet Server in docker with r10k and auto-sync

[![Build Status](https://travis-ci.org/pozgo/docker-puppet-server.svg)](https://travis-ci.org/pozgo/docker-puppet-server)  
[![GitHub Open Issues](https://img.shields.io/github/issues/pozgo/docker-puppet-server.svg)](https://github.com/pozgo/docker-puppet-server/issues)  
[![Stars](https://img.shields.io/github/stars/pozgo/docker-puppet-server.svg?style=social&label=Stars)]()
[![Fork](https://img.shields.io/github/forks/pozgo/docker-puppet-server.svg?style=social&label=Fork)]()  
[![Docker Start](https://img.shields.io/docker/stars/polinux/puppet-server.svg)](https://hub.docker.com/r/polinux/puppet-server)
[![Docker Pulls](https://img.shields.io/docker/pulls/polinux/puppet-server.svg)](https://hub.docker.com/r/polinux/puppet-server)
[![Docker Auto](https://img.shields.io/docker/automated/polinux/puppet-server.svg)](https://hub.docker.com/r/polinux/puppet-server)  
[![](https://img.shields.io/github/release/pozgo/docker-puppet-server.svg)](http://microbadger.com/images/polinux/puppet-server)


Felling like supporting me in my projects use donate button. Thank You!  
[![](https://img.shields.io/badge/donate-PayPal-blue.svg)](https://www.paypal.me/POzgo)

This is [Docker Image](https://registry.hub.docker.com/u/polinux/puppet-server/) with Puppet Server and `r10k` module with auto-sync. We are using offcial [puppet/puppetserver-standalone](https://hub.docker.com/r/puppet/puppetserver-standalone/) image as base on top of which we added missing `openssh-client` and `cron` for auto-sync capability.

User can specify private repository with environments used by `r10k` using provided variable. Please read below. 

### Environmental variables

|Variable|Dexcription|Example|
|:--|:-:|--:|
|`ENVIRONMENTS_REPO_ADDRESS`|Repository containing environments for puppet server. <sup>1</sup>|`ssh://git@my-repo.git.my.domain.com/puppet/environments.git`|
|`SYNC_INTERVAL`|How often `r10k` should sync with repository. Defualt set to every minute. Cron based format|`* * * * *`|
|`AUTO_SIGN_DOMAIMN`|Domain name from which puppet will autosign nodes|`*.domain.com`|

<sup>1</sup> More details on how to prepare such repository [here](https://github.com/puppetlabs/control-repo). If specified private repository user need to provide private key that need to be shared with the image. `-v /my_key:/root/.ssh/id_rsa`

### Usage

#### Basic 

    docker run \
      -d \
      --name puppet-server \
      -p 8140:8140 \
      polinux/puppet-server

**This wil spin up just base puppet server same as using [base image](https://hub.docker.com/r/puppet/puppetserver-standalone/) by itself**

#### Start with custom repository and certain domain name

    docker run \
      -d \
      --name puppet-server \
      -p 8140:8140 \
      -v /path/to/private/key:/root/.ssh/id_rsa \
      -e ENVIRONMENTS_REPO_ADDRESS='' \
      -e AUTO_SIGN_DOMAIMN='*.domain.com' \
      polinux/puppet-server

### Build

    docker build -t polinux/puppet-server .

Docker troubleshooting
======================

Use docker command to see if all required containers are up and running:
```
$ docker ps
```

Check logs of puppet-server server container:
```
$ docker logs puppet-server
```

Sometimes you might just want to review how things are deployed inside a running
 container, you can do this by executing a _bash shell_ through _docker's
 exec_ command:
```
docker exec -ti puppet-server /bin/bash
```

History of an image and size of layers:
```
docker history --no-trunc=true polinux/puppet-server | tr -s ' ' | tail -n+2 | awk -F " ago " '{print $2}'
```

## Author

Przemyslaw Ozgo (<linux@ozgo.info>)