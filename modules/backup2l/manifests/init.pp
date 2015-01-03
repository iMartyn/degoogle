class backup2l {
    package { 'backup2l':
        ensure => present,
        require => Exec["apt-get update"],
    }
}
