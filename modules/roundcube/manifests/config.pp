class roundcube::config {

    $mysql_roundcube_password = hiera('mysql_rc_password')
    $mysql_root_password = hiera('mysql_root_password')
    $domain = hiera('domain')
    $plugin_carddav_ver = hiera('roundcube-plugin-carddav-version')

    file { '/opt/roundcubemail/config/config.inc.php' :
        content => template('roundcube/config.inc.php.erb'),
        replace => false,
        require => Exec['removeroundcubeversion']
    }

    exec { 'resetroundcubehash' :
        command => "sed s/'##########HASH##########'/\"`pwgen -nC 24 1 | sed s/' '//g`\"/g -i /opt/roundcubemail/config/config.inc.php",
        onlyif => "grep '##########HASH##########' /opt/roundcubemail/config/config.inc.php",
        require => Exec['extractroundcube']
    }

    exec{ 'create-roundcube-db':
        unless => "mysql -uroot -p$mysql_root_password roundcube -e 'select * from users' > /dev/null",
        command => "echo 'create database roundcube;' | mysql -uroundcube -p$mysql_roundcube_password",
        require => Exec['extractroundcube']
    }

    exec{ 'init-roundcube-db':
        unless => "mysql -uroot -p$mysql_root_password roundcube -e 'select * from users' > /dev/null",
        command => "mysql -uroundcube -p$mysql_roundcube_password roundcube < /opt/roundcubemail/SQL/mysql.initial.sql",
        require => Exec['create-roundcube-db']
    }

    exec { 'createcarddavdb':
        unless => "mysql -uroot -p$mysql_root_password roundcube -e 'select * from carddav_contacts' > /dev/null",
        command => "mysql -uroundcube -p$mysql_roundcube_password roundcube < /opt/roundcubemail/plugins/carddav/dbinit/mysql.sql",
        require => [ Exec['moveroundcubecarddav'], Exec['init-roundcube-db'] ]
    }
}
