class postfixadmin::config {

    $domain = hiera('domain')
    $mysql_mail_password = hiera('mysql_mail_password')

    file{ '/etc/postfixadmin/dbconfig.inc.php':
        content => template("postfixadmin/dbconfig.inc.php.erb"),
    }

}
