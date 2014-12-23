class postfix {

    preseed { 'postfix':
        ensure => present,
        source => 'postfix/debconf.postfix.erb',
        require => Exec["apt-get update"]
    }
}
