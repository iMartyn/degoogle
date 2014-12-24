class dspam {
    package { dspam :
        ensure => present,
        require => Exec["apt-get update"]
    }
    package { libdspam7-drv-mysql :
        ensure => present,
        require => Exec["apt-get update"]
    }
}
