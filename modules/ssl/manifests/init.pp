class ssl {
    file { '/etc/ssl/mycerts':
        ensure => 'directory',
        mode => 700,
        owner => 'root',
        group => 'root'
    }
    $mailhostname = hiera('mailhostname')
    $cloudhostname = hiera('cloudhostname')
    $pmahostname = hiera('pmahostname')
    file { "/etc/ssl/private/$mailhostname.key":
        source => "puppet:///modules/ssl/$mailhostname.key",
        owner => 'root',
        group => 'root',
        mode => 600
    }
    file { "/etc/ssl/mycerts/$mailhostname.pem":
        source => "puppet:///modules/ssl/$mailhostname.pem",
        owner => 'root',
        group => 'root',
        mode => 600
    }
    file { "/etc/ssl/private/$cloudhostname.key":
        source => "puppet:///modules/ssl/$cloudhostname.key",
        owner => 'root',
        group => 'root',
        mode => 600
    }
    file { "/etc/ssl/mycerts/$cloudhostname.pem":
        source => "puppet:///modules/ssl/$cloudhostname.pem",
        owner => 'root',
        group => 'root',
        mode => 600
    }
    file { "/etc/ssl/private/$pmahostname.key":
        source => "puppet:///modules/ssl/$pmahostname.key",
        owner => 'root',
        group => 'root',
        mode => 600
    }
    file { "/etc/ssl/mycerts/$pmahostname.pem":
        source => "puppet:///modules/ssl/$pmahostname.pem",
        owner => 'root',
        group => 'root',
        mode => 600
    }
}
