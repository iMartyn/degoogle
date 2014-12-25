class dovecot::config {
    $mailhostname = hiera('mailhostname')
    file{ 'dovecot.conf':
        path => "/etc/dovecot/dovecot.conf",
        content => template("dovecot/dovecot.conf.erb"),
        require => Package['dovecot-imapd']
    }

    file{ 'dovecot-sql.conf.ext':
        path => "/etc/dovecot/dovecot-sql.conf.ext",
        content => template("dovecot/dovecot-sql.conf.ext.erb"),
        require => Package['dovecot-mysql']
    }

    file{ 'dovecot-10-master.conf':
        path => "/etc/dovecot/conf.d/10-master.conf",
        content => template("dovecot/10-master.conf.erb"),
        require => Package['dovecot-imapd']
    }

    file{ 'dovecot-10-ssl.conf':
        path => "/etc/dovecot/conf.d/10-ssl.conf",
        content => template("dovecot/10-ssl.conf.erb"),
        require => Package['dovecot-imapd']
    }
}
