class dovecot::config {
    $mailhostname = hiera('mailhostname')
    $mysql_mail_pw = hiera('mysql_mail_password')
    $domain = hiera('domain')
    file{ 'dovecot.conf':
        path => "/etc/dovecot/dovecot.conf",
        content => template("dovecot/dovecot.conf.erb"),
        require => Package['dovecot-imapd'],
        notify => Service['dovecot']
    }

    file{ 'dovecot-sql.conf.ext':
        path => "/etc/dovecot/dovecot-sql.conf.ext",
        content => template("dovecot/dovecot-sql.conf.ext.erb"),
        require => Package['dovecot-mysql'],
        notify => Service['dovecot']
    }

    file{ 'dovecot-10-master.conf':
        path => "/etc/dovecot/conf.d/10-master.conf",
        content => template("dovecot/10-master.conf.erb"),
        require => Package['dovecot-imapd'],
        notify => Service['dovecot']
    }

    file{ 'dovecot-10-ssl.conf':
        path => "/etc/dovecot/conf.d/10-ssl.conf",
        content => template("dovecot/10-ssl.conf.erb"),
        require => Package['dovecot-imapd'],
        notify => Service['dovecot']
    }

    file{ 'dovecot-10-mail.conf':
        path => "/etc/dovecot/conf.d/10-mail.conf",
        content => template("dovecot/10-mail.conf.erb"),
        require => Package['dovecot-imapd'],
        notify => Service['dovecot']
    }

    file{ 'dovecot-10-auth.conf':
        path => "/etc/dovecot/conf.d/10-auth.conf",
        content => template("dovecot/10-auth.conf.erb"),
        require => Package['dovecot-imapd'],
        notify => Service['dovecot']
    }

    file{ 'dovecot-15-lda.conf':
        path => "/etc/dovecot/conf.d/15-lda.conf",
        content => template("dovecot/15-lda.conf.erb"),
        require => Package['dovecot-imapd'],
        notify => Service['dovecot']
    }

    file{ 'dovecot-20-imap.conf':
        path => "/etc/dovecot/conf.d/20-imap.conf",
        content => template("dovecot/20-imap.conf.erb"),
        require => Package['dovecot-imapd'],
        notify => Service['dovecot']
    }

    file{ 'dovecot-20-managesieve.conf':
        path => "/etc/dovecot/conf.d/20-managesieve.conf",
        content => template("dovecot/20-managesieve.conf.erb"),
        require => Package['dovecot-imapd'],
        notify => Service['dovecot']
    }

    file{ 'dovecot-90-plugin.conf':
        path => "/etc/dovecot/conf.d/90-plugin.conf",
        content => template("dovecot/90-plugin.conf.erb"),
        require => Package['dovecot-imapd'],
        notify => Service['dovecot']
    }

    file{ 'dovecot-auth-master.conf.ext':
        path => "/etc/dovecot/conf.d/auth-master.conf.ext",
        content => template("dovecot/auth-master.conf.ext.erb"),
        require => Package['dovecot-imapd'],
        notify => Service['dovecot']
    }

    user{ 'vmail':
        ensure => present,
        gid => 'mail',
        shell => '/bin/false',
        notify => Service['dovecot'],
        uid => 150
    }

    file{ ['/var/vmail',"/var/vmail/${domain}"]:
        ensure => "directory",
        owner => 'vmail',
        group => 'mail',
        mode => '0770'
    }
}
