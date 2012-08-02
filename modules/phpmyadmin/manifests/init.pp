class phpmyadmin {
    # Download phpmyadmin
    exec { "phpmyadmin.download":
        command => "wget https://github.com/phpmyadmin/phpmyadmin/zipball/STABLE -O /tmp/phpmyadmin.zip",
        creates => "/tmp/phpmyadmin.zip",
        unless => "ls /var/www/phpmyadmin",
        require => Package["wget"]
    }

    # Unzip phpmyadmin
    exec { "phpmyadmin.extract":
        command => "unzip /tmp/phpmyadmin.zip -d /tmp/phpmyadmin",
        creates => "/tmp/phpmyadmin",
        unless => "ls /var/www/phpmyadmin",
        require => [Package['unzip'], Exec["phpmyadmin.download"]]
    }

    # Move phpmyadmin into place
    exec { "phpmyadmin.move":
        command => "mv /tmp/phpmyadmin/* /var/www/phpmyadmin",
        creates => "/var/www/phpmyadmin",
        unless => "ls /var/www/phpmyadmin",
        require => Exec["phpmyadmin.extract"]
    }

    # Set configuration
    file { "/var/www/phpmyadmin/config.inc.php":
        source => "/var/www/phpmyadmin/config.sample.inc.php",
        require => Exec["phpmyadmin.move"]
    }
}