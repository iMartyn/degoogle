class shorewall::config {

    $domain = hiera('domain')
    $mysql_mail_password = hiera('mysql_mail_password')

    file{ '/etc/shorewall/interfaces':
        content => template("shorewall/interfaces.erb"),
        notify => Service['shorewall'],
    }

    file{ '/etc/shorewall/policy':
        content => template("shorewall/policy.erb"),
        notify => Service['shorewall'],
    }

    file{ '/etc/shorewall/rules':
        content => template("shorewall/rules.erb"),
        notify => Service['shorewall'],
    }

    file{ '/etc/shorewall/shorewall.conf':
        content => template("shorewall/shorewall.conf.erb"),
        notify => Service['shorewall'],
    }

    file{ '/etc/shorewall/zones':
        content => template("shorewall/zones.erb"),
        notify => Service['shorewall'],
    }

}
