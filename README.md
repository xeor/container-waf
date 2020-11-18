# waf (web-application-firewall)

Base commands/idea is taken from:

* https://www.wintellect.com/securing-docker-containers-with-a-web-application-firewall-waf-built-on-modsecurity-and-nginx/
* https://github.com/theonemule/docker-waf/tree/master/waf-3

## Changes

* ubuntu > alpine
* port 80 > 8000
* run as own user
* Download maxmind db if license key is in MAXMIND_LIC at start (will also set config to get it weekly)
  * Create an account an get a key on https://www.maxmind.com/
* Configurable "to" server, defaults to "localhost:8080
* Mount a custom `/rules` if you have some extra rules, see `modsec_includes.conf` for order. Usually, it's fine to just use `/rules/PRE-*.conf`
  * /rules/PRE-*.conf - first
  * /rules/REQUEST-POST-*.conf - after all the REQUEST rules (useful for exclude rules)
  * /rules/POST-*.conf - last rules, after all RESPONSE rules as well
* Normalized some paths
* Fixed some compile warnings
* Starts up in block-mode with paranoia lever 4, secure as default, make sure to add exlude rules
* Some minor tweaks to nginx config

## tips

* The default `crs-setup.conf` is fairly strict.. You should change it
* If you need to write some exclude rules, look at the REQUEST-903.* files for ideas
* To test project-honeypot blocks, add a rule like `SecRule ARGS:IP "@rbl dnsbl.httpbl.org" "phase:1,id:171,t:none,deny,nolog,auditlog,msg:'RBL Match for SPAM Source'`, then do query like `.../?IP=198.204.237.106`. Use an ip from https://www.projecthoneypot.org/list_of_ips.php
* To use geoip, you will need the token, and configure the `crs-setup.conf` to `SecGeoLookupDB /var/lib/libmaxminddb/GeoLite2-City.mmdb`
