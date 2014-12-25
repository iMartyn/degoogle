class dovecot {
    package { 'dovecot-imapd' :
        ensure => present,
        require => Exec["apt-get update"]
    }
    package { 'dovecot-mysql' :
        ensure => present,
        require => Exec["apt-get update"]
    }
    package { 'dovecot-sieve' :
        ensure => present,
        require => Exec["apt-get update"]
    }
    package { 'dovecot-managesieved' :
        ensure => present,
        require => Exec["apt-get update"]
    }
}
