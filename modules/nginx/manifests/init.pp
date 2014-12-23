class nginx {
    package { nginx :
        ensure => present,
        require => Exec["apt-get update"]
    }
}
