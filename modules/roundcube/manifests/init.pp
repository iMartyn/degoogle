class roundcube {

    $version = '1.0.4'
    $plugin_carddav_ver = hiera('roundcube-plugin-carddav-version')

    exec { 'downloadroundcube' :
        command => "wget -O /tmp/roundcubemail-${version}.tar.gz http://downloads.sourceforge.net/project/roundcubemail/roundcubemail/${version}/roundcubemail-${version}.tar.gz",
        unless => "grep 'Version ${version}' /opt/roundcubemail/index.php"
    }

    exec { 'extractroundcube' :
        command => "tar -zxf /tmp/roundcubemail-${version}.tar.gz -C /opt/ && chown -R www-data: /opt/roundcubemail-${version}",
        unless => "grep 'Version ${version}' /opt/roundcubemail/index.php"
    }

    exec { 'removeroundcubeversion' :
        command => "mv /opt/roundcubemail-${version} /opt/roundcubemail",
        unless => 'test -d /opt/roundcubemail',
        require => Exec['extractroundcube']
    }

    exec { 'downloadroundcubecarddav' :
        command => "wget -O /tmp/carddav-${plugin_carddav_ver}.tar.gz https://github.com/blind-coder/rcmcarddav/archive/carddav_${plugin_carddav_ver}.tar.gz",
        unless => "test -d /opt/roundcubemail/plugins/carddav",
        require => Exec['removeroundcubeversion']
    }

    exec { 'extractroundcubecarddav' :
        command => "tar -xf /tmp/carddav-${plugin_carddav_ver}.tar.gz -C /opt/roundcubemail/plugins && chown -R www-data: /opt/roundcubemail/plugins/rcmcarddav-carddav_${plugin_carddav_ver}",
        unless => "test -d /opt/roundcubemail/plugins/carddav",
        require => Exec['downloadroundcubecarddav']
    }

    exec { 'moveroundcubecarddav' :
        command => "rm /opt/roundcubemail/plugins/carddav ; mv /opt/roundcubemail/plugins/rcmcarddav-carddav_${plugin_carddav_ver} /opt/roundcubemail/plugins/carddav",
        unless => "grep 'roundcube/carddav' /opt/roundcubemail/plugins/carddav/composer.json",
        require => Exec[ 'extractroundcubecarddav' ]
    }

}
