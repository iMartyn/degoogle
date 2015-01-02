class postfixadmin {
    package { 'postfixadmin':
        ensure => present,
        require => Exec["apt-get update"],
        notify => Service["nginx"]
    }
}
