class postfix {

    preseed { 'postfix':
        ensure => present,
        source => 'postfix/debconf.postfix.erb',
        require => Exec["apt-get update"]
    }

    exec { 'mailhostname':
        command => "/usr/sbin/postconf -e \"mydestination = $domain, localhost.localdomain, localhost\"",
        require => preseed["postfix"]
    }
}
