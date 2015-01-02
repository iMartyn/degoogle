class owncloud {

    exec { 'fetch-owncloud-key':
        command => 'wget -O /tmp/owncloud.key http://download.opensuse.org/repositories/isv:ownCloud:community/Debian_7.0/Release.key',
        unless => 'apt-key list | grep ownCloud'
    }

    file { 'apt-owncloud-repo':
        content => "deb http://download.opensuse.org/repositories/isv:/ownCloud:/community/Debian_7.0/ /\n",
        path => '/etc/apt/sources.list.d/owncloud.list'
    }

    exec { 'add-owncloud-key':
        command => 'apt-key add /tmp/owncloud.key',
        require => Exec['fetch-owncloud-key'],
        before => Exec['apt-get update'],
        unless => 'apt-key list | grep ownCloud'
    }

    package { 'owncloud':
        ensure => 'installed',
        require => [
            Exec['apt-get update'],
            File['apt-owncloud-repo']
        ]
    }
}
