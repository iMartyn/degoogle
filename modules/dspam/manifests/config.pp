class dspam::config {
    file{ 'dspam.conf':
        path => "/etc/dspam/dspam.conf",
        content => template("dspam/dspam.conf.erb"),
        require => [ Service['mysql'], Exec[set-mysql-root-password] ],
    }
}
