class shorewall {
    package { 'shorewall':
        ensure => present,
        require => Exec["apt-get update"],
    }

    service { 'shorewall':
        ensure => running,
        require => Package['shorewall'],
    }
}
