
# Let's Encrypt UniFi Controller

## Introduction

Automated Let's Encrypt certificates usage in UniFi Controller

Currently tested with:

 - Debian 9.4 & UniFi Controller 5.7.20 - 5.9.29

## Changelog
### Version 0.1 @ 2018-05-18

 - inital creation

### Version 0.2 @ 2018-05-25
- copy old keystore back if keytool convert fails
- check if Let's Encrypt certificate even exist

### Version 0.3 @ 2018-10-29
- making sure UniFi will start with port under 1024
- added Let's Encrypt renewal to script
