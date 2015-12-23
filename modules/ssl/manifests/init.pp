class ssl {
    file { '/etc/ssl':
        ensure => 'directory',
    }
    file { '/etc/ssl/mycerts':
        ensure => 'directory',
        mode => 770,
        owner => 'root',
        group => 'www-data'
    }
    file { '/etc/ssl/private':
        ensure => 'directory',
        mode => 700,
        owner => 'root',
        group => 'www-data'
    }
    $mailhostname = hiera('mailhostname')
    $cloudhostname = hiera('cloudhostname')
    $pfahostname = hiera('pfahostname')
    user { 'letsencrypt':
	ensure => 'present',
	groups => 'www-data'
    }
    file { '/home/letsencrypt':
        ensure => 'directory',
        mode => 700,
        owner => 'letsencrypt',
        group => 'www-data'
    }
}
