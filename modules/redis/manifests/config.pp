class redis::config {

    file{ 'redis.conf':
        path => "/etc/redis/redis.conf",
        content => template("redis/redis.conf.erb"),
        require => [ Package['redis'] ],
    }

}
