class postfix {

    preseed { 'postfix':
        ensure => present,
        source => 'postfix/debconf.postfix.erb',
        require => Exec["apt-get update"]
    }

    package { 'postfix-mysql':
        ensure => present,
        require => [ 
            Exec["apt-get update"],
            Package["postfix"],
            Package["mysql-client"]
        ]
    }

    package { 'postfix-pcre':
        ensure => present,
        require => [ 
            Exec["apt-get update"],
            Package["postfix"]
        ]
    }

    package { 'postfixadmin':
        ensure => present,
        require => Exec["apt-get update"]
    }

    service { 'postfix':
        ensure => "running",
        enable => "true"
    }

}
