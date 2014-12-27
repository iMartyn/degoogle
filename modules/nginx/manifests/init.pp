class nginx {
    package { nginx :
        ensure => present,
        require => Exec["apt-get update"]
    }

    service { 'nginx':
        ensure => "running",
        enable => "true"
    }
}
