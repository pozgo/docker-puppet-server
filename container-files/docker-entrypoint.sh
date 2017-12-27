#!/bin/bash

chown -R puppet:puppet /etc/puppetlabs/puppet/ssl
chown -R puppet:puppet /opt/puppetlabs/server/data/puppetserver/

## Verify if repository sepcified on docker run stage
if [[ -z ${ENVIRONMENTS_REPO_ADDRESS} ]]; then
  echo "R10K Repository not defined. Starting Puppet in default mode"
else
  mkdir -p /etc/puppetlabs/r10k
  if [ ! -f /etc/puppetlabs/r10k/r10k.yaml ]; then
    mv /r10k.yaml /etc/puppetlabs/r10k/r10k.yaml
  fi
  sed -i "s|ENVIRONMENTS_REPO_ADDRESS|${ENVIRONMENTS_REPO_ADDRESS}|g" /etc/puppetlabs/r10k/r10k.yaml
  # echo "R10K Config updated. Fetching latest version..."
  # /opt/puppetlabs/puppet/bin/r10k deploy environment -p -v
  echo "Starting cron daemon sync interval"
  cron
  echo "Adding cron job with interval specified by variable"
  sed -i "s|SYNC_INTERVAL|${SYNC_INTERVAL}|g" /root/cronjobs/r10k.conf
  crontab /root/cronjobs/r10k.conf
fi

## Add autosigne domain if specified
if [ ${AUTO_SIGN_DOMAIMN} != 'domain.com' ]; then
  sed -i 's|autosign = true|autosign = /etc/puppetlabs/puppet/autosign.conf|g' /etc/puppetlabs/puppet/puppet.conf
  echo "Adding domain: ${AUTO_SIGN_DOMAIMN} to autosign.conf"
  echo "${AUTO_SIGN_DOMAIMN}" >> /etc/puppetlabs/puppet/autosign.conf
fi

# Defult task 
if test -n "${PUPPETDB_SERVER_URLS}" ; then
  sed -i "s@^server_urls.*@server_urls = ${PUPPETDB_SERVER_URLS}@" /etc/puppetlabs/puppet/puppetdb.conf
fi

exec /opt/puppetlabs/bin/puppetserver "$@"
