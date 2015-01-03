class backup2l::config {

    $domain = hiera('domain')
    $mysql_mail_password = hiera('mysql_mail_password')

    file{ '/etc/backup2l.conf':
        content => template("backup2l/backup2l.conf.erb"),
    }

    file{ '/backups':
        ensure => 'directory',
        mode => 700,
        owner => root,
        group =>root
    }

}
