#!/bin/bash
script_name="Let's Encrypt UniFi Controller v0.3"
 
domain="unifi.contoso.com"
unifi_install_dir="/var/lib/unifi"
 
log_file="/var/log/unifi/unifi_lets_encrypt.log"
log () {
        if [ "$1" ]; then
                echo -e "[$(date)] - $1" >> $log_file
        fi
}
 
[[ -f ${log_file} ]] || touch ${log_file}
[[ -n ${unifi_install_dir} ]] || unifi_install_dir="/var/lib/unifi" 2>> ${log_file}
[ -d ${unifi_install_dir}/letsencrypt ] || mkdir ${unifi_install_dir}/letsencrypt 2>> ${log_file}
 
log "Started ${script_name}"
log "Stopping UniFi service"
systemctl stop unifi 2>> ${log_file}
log "Renewing Let's Encrypt certificates"
certbot -q renew 2>> ${log_file}
[[ -f /etc/letsencrypt/live/${domain}/fullchain.pem ]] || log "Let's Encrypt certificates for ${domain} don't exist or you don't have enough permissions... exiting" || exit 0
openssl pkcs12 -export -in /etc/letsencrypt/live/${domain}/fullchain.pem -inkey /etc/letsencrypt/live/${domain}/privkey.pem -out ${unifi_install_dir}/letsencrypt/${domain}.p12 -name unifi -passout pass:aircontrolenterprise 2>> ${log_file}
if [ $? -ne 0 ]; then { log "Error occoured while creating PKCS12 certficate"; exit 0; } fi
cp ${unifi_install_dir}/keystore ${unifi_install_dir}/keystore.old 2>> ${log_file}
keytool -noprompt -importkeystore -deststorepass aircontrolenterprise -destkeypass aircontrolenterprise -destkeystore ${unifi_install_dir}/keystore -srckeystore ${unifi_install_dir}/letsencrypt/${domain}.p12 -srcstoretype PKCS12 -srcstorepass aircontrolenterprise -srcalias unifi -destalias unifi
if [ $? -ne 0 ]; then { cp ${unifi_install_dir}/keystore.old ${unifi_install_dir}/keystore; log "Error occoured while creating keystore, copied back old keystore... exiting"; exit 0; } fi
chmod 600 ${unifi_install_dir}/keystore && chown unifi:unifi ${unifi_install_dir}/keystore 2>> ${log_file}
log "Giving UniFi additional permissions to bind to port below 1024"
setcap 'cap_net_bind_service=+ep' /usr/lib/unifi/bin/unifi.init 2>> ${log_file}
setcap 'cap_net_bind_service=+ep' /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java ${log_file}
log "Starting UniFi service"
systemctl start unifi 2>> ${log_file}
log "Finished ${script_name}"
