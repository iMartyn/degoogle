class ssl {
    file { '/etc/ssl':
        ensure => 'directory',
    }
    file { '/etc/ssl/mycerts':
        ensure => 'directory',
        mode => '0770',
        owner => 'root',
        group => 'www-data'
    }
    file { '/etc/ssl/private':
        ensure => 'directory',
        mode => '0710',
        owner => 'root',
        group => 'ssl-cert'
    }
    $mailhostname = hiera('mailhostname')
    $cloudhostname = hiera('cloudhostname')
    $pfahostname = hiera('pfahostname')
    $hostnames = [ $mailhostname, $cloudhostname, $pfahostname ]
    $domain = hiera('domain')
    user { 'letsencrypt':
	ensure => 'present',
	groups => 'www-data'
    }
    file { '/home/letsencrypt':
        ensure => 'directory',
        mode => '0700',
        owner => 'letsencrypt',
        group => 'www-data'
    }
    file { '/home/letsencrypt/data':
        ensure => 'directory',
        mode => '0700',
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
	command => '/usr/bin/openssl genrsa > /home/letsencrypt/data/account.key',
        user => 'letsencrypt',
        creates => '/home/letsencrypt/data/account.key'
    }
    exec { 'fetch-intermediate-cert':
        command => '/usr/bin/wget -O - https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.pem > /home/letsencrypt/data/intermediate.pem',
        creates => '/home/letsencrypt/data/intermediate.pem'
    }
    each ( $hostnames ) |$hostname| {
        exec { "create-$hostname-key":
            command => "/usr/bin/openssl genrsa > /home/letsencrypt/data/$hostname.key",
            user => 'letsencrypt',
            creates => "/home/letsencrypt/data/$hostname.key"
        }
        exec { "copy-$hostname-key":
            command => "cp /home/letsencrypt/data/$hostname.key /etc/ssl/private/$hostname.key",
            creates => "/etc/ssl/private/$hostname.key",
            require => Exec["create-$hostname-key"]
        }
        exec { "create-$hostname-csr":
            command => "/usr/bin/openssl req -new -sha256 -key /home/letsencrypt/data/$hostname.key -subj \"/CN=$hostname.$domain\" > /home/letsencrypt/data/$hostname.csr",
            creates => "/home/letsencrypt/data/$hostname.csr"
        }
        exec { "sign-$hostname-cert":
            command => "/usr/bin/python /home/letsencrypt/acme-tiny/acme_tiny.py --account-key /home/letsencrypt/data/account.key --csr /home/letsencrypt/data/$hostname.csr --acme-dir /var/www/challenges > /home/letsencrypt/data/$hostname.crt",
            creates => "/home/letsencrypt/data/$hostname.crt",
            require => Exec["create-$hostname-csr"]
        }
        exec { "add-$hostname-intermediate":
            command => "cat /home/letsencrypt/data/$hostname.crt /home/letsencrypt/data/intermediate.pem > /home/letsencrypt/data/$hostname.pem",
            creates => "/home/letsencrypt/data/$hostname.pem",
            require => [ Exec["create-$hostname-csr"], Exec["fetch-intermediate-cert"] ]
        }
        exec { "copy-$hostname-cert":
            command => "cp /home/letsencrypt/data/$hostname.pem /etc/ssl/mycerts/$hostname.pem",
            creates => "/etc/ssl/mycerts/$hostname.pem",
            notify => Service["nginx"],
            require => Exec["add-$hostname-intermediate"]
        }
    }
}
