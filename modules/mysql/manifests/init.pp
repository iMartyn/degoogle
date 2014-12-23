class mysql {

  # root mysql password
  $mysqlpw = hiera('mysql_root_password')
  $mailpw = hiera('mysql_mail_password')
#"d3v0p5"

  # install mysql server
  package { "mysql-server":
    ensure => present,
    require => Exec["apt-get update"]
  }

  # install mysql-client 
  package { "mysql-client":
    ensure => present,
    require => Exec["apt-get update"]
  }

  #start mysql service
  service { "mysql":
    ensure => running,
    require => Package["mysql-server"],
  }

  # set mysql password
  exec { "set-mysql-password":
    unless => "mysqladmin -uroot -p$mysqlpw status",
    command => "mysqladmin -uroot password $mysqlpw",
    require => Service["mysql"],
  }

  exec { "set-mysql-mail-password":
    unless => "mysqladmin -umail -p$mailpw status",
    command => "mysql -uroot -p$mysqlpw -c 'CREATE USER `mail`@`localhost` IDENTIFIED BY \"$mailpw\"; GRANT ALL PRIVILEGES ON `mail`.* TO `mail`@`localhost`'",
    require => Service["mysql"],
  }
}
