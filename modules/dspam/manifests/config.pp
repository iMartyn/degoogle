class dspam::config {

    $mysql_dspam_password = hiera('mysql_dspam_password')
    $mysql_root_password = hiera('mysql_root_password')
    $domain = hiera('domain')
    file{ 'dspam.conf':
        path => "/etc/dspam/dspam.conf",
        content => template("dspam/dspam.conf.erb"),
        require => [ Service['mysql'], Exec[set-mysql-root-password], Package['dspam'] ],
    }

    file{ 'txt/firstrun.txt':
        path => "/etc/dspam/txt/firstrun.txt",
        content => template("dspam/firstrun.txt.erb"),
        require => [ Service['mysql'], Exec[set-mysql-root-password], Package['dspam'] ],
    }

    file{ 'txt/firstspam.txt':
        path => "/etc/dspam/txt/firstspam.txt",
        content => template("dspam/firstspam.txt.erb"),
        require => [ Service['mysql'], Exec[set-mysql-root-password], Package['dspam'] ],
    }

    file{ 'txt/quarantinefull.txt':
        path => "/etc/dspam/txt/quarantinefull.txt",
        content => template("dspam/quarantinefull.txt.erb"),
        require => [ Service['mysql'], Exec[set-mysql-root-password], Package['dspam'] ],
    }

    exec{ 'create-dspam-db':
        unless => "mysql -uroot -p$mysql_root_password dspam -e 'show tables' > /dev/null",
        command => "/usr/bin/mysql -u root -p$mysql_root_password mysql -e \"create database dspam\"",
        require => [ Service['mysql'], Exec[set-mysql-root-password], Package['dspam'] ]
    }

    exec{ 'create-dspam-db-objects':
        unless => "mysql -uroot -p$mysql_root_password dspam -e 'select * from dspam_preferences' > /dev/null",
        command => "/usr/bin/mysql -u root -p$mysql_root_password dspam < /usr/share/doc/libdspam7-drv-mysql/sql/mysql_objects-4.1.sql",
        require => [ Service['mysql'], Exec[set-mysql-root-password], Exec[create-dspam-db] ]
    }
    
    exec{ 'create-dspam-virtual-uids':
        unless => "mysql -uroot -p$mysql_root_password dspam -e 'select * from dspam_virtual_uids' > /dev/null",
        command => "/usr/bin/mysql -u root -p$mysql_root_password dspam < /usr/share/doc/libdspam7-drv-mysql/sql/virtual_users.sql",
        require => [ Service['mysql'], Exec[set-mysql-root-password], Exec[create-dspam-db] ]
    }

}
