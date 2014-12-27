class nginx::config {
    # Base config
    $domain = hiera('domain')
    file{ 'nginx-cloud-available':
        path => "/etc/nginx/sites-available/cloud",
        content => template("nginx/cloud.erb"),
        notify => Service['nginx']
    }
    file{ 'nginx-cloud-enabled':
        path => '/etc/nginx/sites-enabled/cloud',
        ensure => 'link',
        target => '/etc/nginx/sites-available/cloud',
        notify => Service['nginx'],
        require => File['/etc/nginx/sites-available/cloud']
    }

    file{ 'nginx-mail-available':
        path => "/etc/nginx/sites-available/mail",
        content => template("nginx/mail.erb"),
        notify => Service['nginx']
    }
    file{ 'nginx-mail-enabled':
        path => '/etc/nginx/sites-enabled/mail',
        ensure => 'link',
        target => '/etc/nginx/sites-available/mail',
        notify => Service['nginx'],
        require => File['/etc/nginx/sites-available/mail']
    }

    file{ 'nginx-pfa-available':
        path => "/etc/nginx/sites-available/pfa",
        content => template("nginx/pfa.erb"),
        notify => Service['nginx']
    }
    file{ 'nginx-pfa-enabled':
        path => '/etc/nginx/sites-enabled/pfa',
        ensure => 'link',
        target => '/etc/nginx/sites-available/pfa',
        notify => Service['nginx'],
        require => File['/etc/nginx/sites-available/pfa']
    }

    file { 'nginx-default-enabled':
        path => '/etc/nginx/sites-enabled/default',
        ensure => absent
    }
}
