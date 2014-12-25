# default path
Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

include bootstrap
include tools
include nginx
include php
include php::pear
include php::pecl
include mysql
include postfix
include dspam
include dovecot
include ssl
include postfix::config
include dspam::config
include dovecot::config
