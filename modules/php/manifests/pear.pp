class php::pear {
  include php

  # upgrade PEAR
  exec { "pear upgrade":
    require => Package["php-pear"]
  }

  # install PHPUnit
  exec { "pear config-set auto_discover 1":
    require => Exec["pear upgrade"]
  }

  # create pear temp directory for channel-add
  file { "/tmp/pear/temp":
    require => Exec["pear config-set auto_discover 1"],
    ensure => "directory",
    owner => "root",
    group => "root",
    mode => 777
  }

  # discover channels
  exec { "pear channel-discover pear.symfony-project.com; true":
    require => [File["/tmp/pear/temp"], Exec["pear config-set auto_discover 1"]]
  }

  exec { "pear channel-discover components.ez.no; true":
    require => [File["/tmp/pear/temp"], Exec["pear config-set auto_discover 1"]]
  }

  # clear cache before install phpunit
  exec { "pear clear-cache":
    require => [Exec["pear channel-discover pear.symfony-project.com; true"], Exec["pear channel-discover components.ez.no; true"]]
  }

  # install phpunit
  exec { "fetchphpunit":
    unless => "test -x /usr/local/bin/phpunit",
    command => "wget -O/usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar",
    require => Exec["pear clear-cache"]
  }

  # and make it executable
  exec { "chmod +x /usr/local/bin/phpunit":
    require => Exec["fetchphpunit"]
  }
}
