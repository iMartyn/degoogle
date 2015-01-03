define postfix_maincf($key="",$value="") {
    exec { "postfix_maincf_${key}_${value}":
        command => "/usr/sbin/postconf -e \"$key = $value\"",
        unless => "postconf $key | sed s/'.*= '// | grep \"^$value\$\"",
        notify => Service['postfix'],
        require => Package['postfix']
    }
}

define postfix_mastercf_uncomment($name="") {
    exec { "postfix_mastercf_uncomment_$name":
        command => "sed s/\"^#\\($name[ \\t]\\)\"/\"\\1\"/g -i /etc/postfix/master.cf",
        unless => "grep \"^$name[ \\t]\" /etc/postfix/master.cf", 
        notify => Service['postfix'],
        require => Package['postfix']
    }
}

class postfix::config {
    # Base config
    $domain = hiera('domain')
    postfix_maincf{ 'myhostname':
        key => "myhostname",
        value => "mail.$domain"
    }
    postfix_maincf{ 'mydestination':
        key => "mydestination",
        value => "virtualsonly.$domain"
    }
#    postfix_maincf{ 'smtpd_relay_restrictions': # Not on this version of postfix
#        key => "smtpd_relay_restrictions",
#        value => "permit_mynetworks permit_sasl_authenticated defer_unauth_destination"
#    }
    postfix_maincf{ 'smtpd_recipient_restrictions':
        key => "smtpd_recipient_restrictions",
        value => "check_relay_domains permit_sasl_authenticated check_client_access pcre:/etc/postfix/dspam_filter_access check_policy_service inet:127.0.0.1:60000"
    }
    postfix_maincf{ 'dspam_destination_recipient_limit':
        key => "dspam_destination_recipient_limit",
        value => "1"
    }
    postfix_maincf{ 'dovecot_destination_recipient_limit':
        key => "dovecot_destination_recipient_limit",
        value => "1"
    }

    # SASL
    postfix_maincf{ 'smtpd_sasl_auth_enable':
        key => "smtpd_sasl_auth_enable",
        value => "yes"
    }
    postfix_maincf{ 'smtpd_sasl_exceptions_networks':
        key => "smtpd_sasl_exceptions_networks",
        value => '\$mynetworks'
    }
    postfix_maincf{ 'smtpd_sasl_security_options':
        key => "smtpd_sasl_security_options",
        value => "noanonymous"
    }
    postfix_maincf{ 'broken_sasl_auth_clients':
        key => "broken_sasl_auth_clients",
        value => "yes"
    }
    postfix_maincf{ 'smtpd_sasl_type':
        key => "smtpd_sasl_type",
        value => "dovecot"
    }
    postfix_maincf{ 'smtpd_sasl_path':
        key => "smtpd_sasl_path",
        value => "private/auth"
    }

    # Virtuals
    postfix_maincf{ 'virtual_mailbox_domains':
        key => "virtual_mailbox_domains",
        value => 'proxy:mysql:\$config_directory/mysql_virtual_domains_maps.cf'
    }
    postfix_maincf{ 'virtual_mailbox_base':
        key => "virtual_mailbox_base",
        value => "/var/vmail"
    }
    postfix_maincf{ 'virtual_mailbox_maps':
        key => "virtual_mailbox_maps",
        value => 'proxy:mysql:\$config_directory/mysql_virtual_mailbox_maps.cf'
    }
    postfix_maincf{ 'virtual_alias_maps':
        key => "virtual_alias_maps",
        value => 'proxy:mysql:\$config_directory/mysql_virtual_alias_maps.cf'
    }
    postfix_maincf{ 'virtual_minimum_uid':
        key => "virtual_minimum_uid",
        value => "150"
    }
    postfix_maincf{ 'virtual_uid_maps':
        key => "virtual_uid_maps",
        value => "static:150"
    }
    postfix_maincf{ 'virtual_gid_maps':
        key => "virtual_gid_maps",
        value => "static:8"
    }
    postfix_maincf{ 'virtual_transport':
        key => "virtual_transport",
        value => "dovecot"
    }

    $admin_user = hiera('admin_user')
    $admin_name = hiera('admin_name')
    $admin_pass = hiera('admin_password')
    $mysql_root_password = hiera('mysql_root_password')
    $mysql_mail_password = hiera('mysql_mail_password')

    file{ 'mail.sql':
        path => "/tmp/mail.sql",
        content => template("postfix/mail.sql.erb"),
        require => [ Service['mysql'], Exec[set-mysql-root-password] ],
        replace => false
    }

    exec{ 'hashmailadminpw':
        onlyif => "grep '############ENCPASS##############' /tmp/mail.sql",
        require => File['mail.sql'],
        command => "sed s/'############ENCPASS##############'/\"`openssl passwd -1 -salt $(pwgen -nC 8 1 | sed s/' '//g) $admin_pass | sed -e 's/[\\/&]/\\\\&/g'`\"/g -i /tmp/mail.sql",
    }

    exec{ 'create-mail-db':
        unless => "mysql -uroot -p$mysql_root_password mail -e 'select * from admin' > /dev/null",
        command => "/usr/bin/mysql -u root -p$mysql_root_password mysql < /tmp/mail.sql && echo \"-- Removed for security\" > /tmp/mail.sql",
        require => [ Service['mysql'], File['mail.sql'], Exec[set-mysql-root-password], Exec[ 'hashmailadminpw' ] ]
    }

    file{ 'mysql_virtual_domains_maps.cf':
        path => "/etc/postfix/mysql_virtual_domains_maps.cf",
        content => template("postfix/mysql_virtual_domains_maps.cf.erb"),
        require => [ Package['postfix'] ],
    }

    file{ 'mysql_virtual_alias_maps.cf':
        path => "/etc/postfix/mysql_virtual_alias_maps.cf",
        content => template("postfix/mysql_virtual_alias_maps.cf.erb"),
        require => [ Package['postfix'] ],
    }

    file{ 'mysql_virtual_mailbox_maps.cf':
        path => "/etc/postfix/mysql_virtual_mailbox_maps.cf",
        content => template("postfix/mysql_virtual_mailbox_maps.cf.erb"),
        require => [ Package['postfix'] ],
    }

    file{ 'mysql_virtual_mailbox_limit_maps.cf':
        path => "/etc/postfix/mysql_virtual_mailbox_limit_maps.cf",
        content => template("postfix/mysql_virtual_mailbox_limit_maps.cf.erb"),
        require => [ Package['postfix'] ],
    }

    file{ 'dspam_filter_access':
        path => "/etc/postfix/dspam_filter_access",
        content => template("postfix/dspam_filter_access.erb"),
        require => [ Package['postfix'] ],
    }

    exec{ 'add-dspam-to-master.cf':
        unless => 'grep ^dspam /etc/postfix/master.cf',
        command => 'echo "dspam  unix    -   n       n       -        10      pipe" >> /etc/postfix/master.cf; echo "  flags=Ru user=dspam argv=/usr/bin/dspam --deliver=innocent,spam --user \$recipient -i -f \$sender -- \$recipient" >> /etc/postfix/master.cf',
        notify => Service['postfix'],
        require => Package['postfix']
    }

    exec{ 'add-dovecot-to-master.cf':
        unless => 'grep ^dovecot /etc/postfix/master.cf',
        command => 'echo "dovecot   unix    -   n   n   -   -   pipe" >> /etc/postfix/master.cf; echo "  flags=DRhu user=vmail:mail argv=/usr/lib/dovecot/deliver -d \$(recipient)" >> /etc/postfix/master.cf',
        notify => Service['postfix'],
        require => Package['postfix']
    }

    exec{ 'switch-pickup-to-unix-socket':
        unless => 'grep -P "^pickup[\t ]*unix" /etc/postfix/master.cf',
        command => 'sed s/"^\(pickup[ \t]*\)fifo"/"\1unix"/g -i /etc/postfix/master.cf',
        notify => Service['postfix'],
        require => Package['postfix']
    }

    exec{ 'switch-qmgr-to-unix-socket':
        unless => 'grep -P "^qmgr[\t ]*unix" /etc/postfix/master.cf',
        command => 'sed s/"^\(qmgr[ \t]*\)fifo"/"\1unix"/g -i /etc/postfix/master.cf',
        notify => Service['postfix'],
        require => Package['postfix']
    }

    postfix_mastercf_uncomment{ 'uncomment_submission':
        name => "submission",
    }
}
