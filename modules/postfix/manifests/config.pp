define postfix_maincf($key="",$value="") {
    exec { "postfix_maincf_${key}_${value}":
        command => "/usr/sbin/postconf -e \"$key = $value\""
    }
}

class postfix::config {
    require postfix
    # Base config
    postfix_maincf{ 'myhostname':
        key => "myhostname",
        value => "mail.$domain"
    }
    postfix_maincf{ 'mydestination':
        key => "mydestination",
        value => "mail.$domain, $domain"
    }
    postfix_maincf{ 'smtpd_relay_restrictions':
        key => "smtpd_relay_restrictions",
        value => "permit_mynetworks permit_sasl_authenticated defer_unauth_destination"
    }
    postfix_maincf{ 'smtpd_recipient_restrictions':
        key => "smtpd_recipient_restrictions",
        value => "permit_sasl_authenticated check_client_access pcre:/etc/postfix/dspam_filter_access check_policy_service inet:127.0.0.1:60000"
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
}
