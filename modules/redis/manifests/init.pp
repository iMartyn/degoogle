class dspam {
    package { redis-server :
        ensure => present,
        require => Exec["apt-get update"]
    }
}
