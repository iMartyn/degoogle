define postfix_maincf($key="",$value="") {
    exec { "postfix_maincf_${key}_${value}":
        command => "/usr/sbin/postconf -e \"$key = $value\""
    }
}

class postfix::config {
    require postfix
    // Base config
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

    // SASL
    postfix_maincf{ 'smtpd_sasl_auth_enable':
        key => "smtpd_sasl_auth_enable",
        value => "yes"
    }
    postfix_maincf{ 'smtpd_sasl_exceptions_networks':
        key => "smtpd_sasl_exceptions_networks",
        value => "\$mynetworks"
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
}
