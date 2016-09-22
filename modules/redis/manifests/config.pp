class dspam::config {

    file{ 'redis.conf':
        path => "/etc/redis/redis.conf",
        content => template("redis/redis.conf.erb"),
        require => [ Service['mysql'], Exec[set-mysql-root-password], Package['dspam'] ],
    }

}
