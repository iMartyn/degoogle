class dspam {
    package { rmilter :
        ensure => present,
        require => Exec["apt-get update"]
    }
}
