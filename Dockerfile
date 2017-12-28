FROM ubuntu:16.04

ENV ENVIRONMENTS_REPO_ADDRESS='' \
    SYNC_INTERVAL='* * * * *' \
    AUTO_SIGN_DOMAIMN='domain.com' \
    PUPPET_SERVER_VERSION="5.1.3" \
    DUMB_INIT_VERSION="1.2.0" \
    UBUNTU_CODENAME="xenial" \
    PUPPETSERVER_JAVA_ARGS="-Xms256m -Xmx256m" \
    PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH \
    PUPPET_HEALTHCHECK_ENVIRONMENT="production"

LABEL \
        author="Przemyslaw Ozgo" \
        email="linux@ozgo.info" \
        version=$PUPPET_SERVER_VERSION \
        description="Puppet Server in docker and R10K with auto sync"



RUN \
    apt-get clean && \
    apt-get update && \
    apt-get install -y curl openssh-client cron wget=1.17.1-1ubuntu1 && \
    wget https://apt.puppetlabs.com/puppet5-release-"$UBUNTU_CODENAME".deb && \
    wget https://github.com/Yelp/dumb-init/releases/download/v"$DUMB_INIT_VERSION"/dumb-init_"$DUMB_INIT_VERSION"_amd64.deb && \
    dpkg -i puppet5-release-"$UBUNTU_CODENAME".deb && \
    dpkg -i dumb-init_"$DUMB_INIT_VERSION"_amd64.deb && \
    rm puppet5-release-"$UBUNTU_CODENAME".deb dumb-init_"$DUMB_INIT_VERSION"_amd64.deb && \
    apt-get update && \
    apt-get install --no-install-recommends git -y puppetserver="$PUPPET_SERVER_VERSION"-1"$UBUNTU_CODENAME" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    gem install --no-rdoc --no-ri r10k && \
    curl --insecure -o /etc/default/puppetserver https://raw.githubusercontent.com/pozgo/docker-puppet-server/master/puppetserver && \
    curl --insecure -o /etc/puppetlabs/puppetserver/logback.xml https://raw.githubusercontent.com/pozgo/docker-puppet-server/master/logback.xml && \
    curl --insecure -o /etc/puppetlabs/puppetserver/request-logging.xml https://raw.githubusercontent.com/pozgo/docker-puppet-server/master/request-logging.xml && \
    puppet config set autosign true --section master && \
    mkdir -p /root/.ssh/ && \
    echo "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config && \
    chmod 644 /root/.ssh/config

COPY container-files /

EXPOSE 8140

ENTRYPOINT ["dumb-init", "/docker-entrypoint.sh"]

CMD ["foreground" ]

HEALTHCHECK --interval=10s --timeout=10s --retries=90 CMD \
  curl --fail -H 'Accept: pson' \
  --resolve 'puppet:8140:127.0.0.1' \
  --cert   $(puppet config print hostcert) \
  --key    $(puppet config print hostprivkey) \
  --cacert $(puppet config print localcacert) \
  https://puppet:8140/${PUPPET_HEALTHCHECK_ENVIRONMENT}/status/test \
  |  grep -q '"is_alive":true' \
  || exit 1