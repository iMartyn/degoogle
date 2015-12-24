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
        mode => 710,
        owner => 'root',
        group => 'ssl-cert'
    }
    $mailhostname = hiera('mailhostname')
    $cloudhostname = hiera('cloudhostname')
    $pfahostname = hiera('pfahostname')
    $hostnames = [ $mailhostname, $cloudhostname, $pfahostname ]
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
    file { '/home/letsencrypt/data':
        ensure => 'directory',
        mode => 700,
        owner => 'letsencrypt',
        group => 'www-data'
    }
    exec { 'git-clone-acme-tiny':
        command => '/usr/bin/git clone https://github.com/diafygi/acme-tiny.git',
        cwd => '/home/letsencrypt',
        user => 'letsencrypt',
        creates => '/home/letsencrypt/acme-tiny'
    }
    exec { 'create-letsencrypt-account-key':
	command => '/usr/bin/openssl genrsa > /home/letsencrypt/data/account.key'
        user => 'letsencrypt',
        creates => '/home/letsencrypt/data/account.key'
    }
    each ( $hostnames ) |$hostname| {
        exec { "create-$hostname-key":
            command => "/usr/bin/openssl genrsa > /home/letsencrypt/data/$hostname.key",
            user => 'letsencrypt',
            creates => "/home/letsencrypt/data/$hostname.key"
        }
    }
}
