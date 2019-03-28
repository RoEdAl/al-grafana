# Grafana - Arch Linux packages for ARM architectures

Grafana without [PhantomJS](//aur.archlinux.org/packages/phantomjs/) - 
you may try [grafana-image-renderer](//github.com/grafana/grafana-image-renderer) instead.

In order to build **Grafana** packages for ARM architectures you need:
- a lot of RAM and big swap (2G or above),
- fast storage,
- a lot of time (4 hours or more) - frontend compilation (*WebPack*) is a really long process.

## NGINX - Running Grafana behind a reverse proxy

1. Grafana configuration - `/etc/grafana.ini`:
   - Change *protocol*.
     ~~~
     protocol = socket
     ~~~
   - Specify location of UNIX socket:
     ~~~
     socket = /run/grafana/grafana.sock
     ~~~
   - Change *root_url*.
     ~~~
     root_url = %(protocol)s://%(domain)s/grafana/
     ~~~
   - Specify *domain*.
     ~~~
     domain = <your host name>
     ~~~
 1. NGINX - configuration:
    -  Site configuration
       ~~~
       location /grafana/ {
           proxy_pass http://unix:/run/grafana/grafana.sock:/;
       }
       ~~~
    -  Grafana creates socket with **660** permissions so you must run worker process
       with *grafana*
       [user or group](http://nginx.org/en/docs/ngx_core_module.html#user) credentials
       in order to get access to `/run/grafana/grafana.sock`:
       ~~~
       user http grafana;
       ~~~
