# uptime

[![Join the chat at https://gitter.im/mosbth/dbwebb](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/mosbth/dbwebb?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Track uptime tournament



## Setup production environment

```
git clone git@github.com:mosbth/uptime.git uptime.dbwebb.se
cd uptime.dbwebb.se

make local-publish

make virtual-host

make ssl-cert-create
make virtual-host-https
```
