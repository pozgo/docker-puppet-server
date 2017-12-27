FROM puppet/puppetserver-standalone:5.1.3

LABEL \
        author="Przemyslaw Ozgo" \
        email="linux@ozgo.info" \
        version="5.1.3" \
        description="Puppet Server in docker and R10K with auto sync"

ENV ENVIRONMENTS_REPO_ADDRESS='' \
    SYNC_INTERVAL='* * * * *' \
    AUTO_SIGN_DOMAIMN='domain.com'

RUN \
    apt-get clean && \
    apt-get update && \
    apt-get install -y openssh-client cron && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /root/.ssh/ && \
    echo "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config && \
    chmod 644 /root/.ssh/config

COPY container-files /

EXPOSE 8140