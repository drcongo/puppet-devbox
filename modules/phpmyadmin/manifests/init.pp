class phpmyadmin {
    # Download phpmyadmin
    exec { "phpmyadmin.download":
        command => "wget https://github.com/phpmyadmin/phpmyadmin/zipball/STABLE -O /tmp/phpmyadmin.zip",
        creates => "/tmp/phpmyadmin.zip",
        require => Package["wget"]
    }

    # Unzip phpmyadmin
    exec { "phpmyadmin.exctract":
        command => "unzip /tmp/phpmyadmin.zip -d /tmp/phpmyadmin",
        creates => "/tmp/phpmyadmin",
        require => File["/tmp/phpmyadmin.zip"]
    }

    # Move phpmyadmin into place
    exec { "phpmyadmin.move":
        command => "mv /tmp/phpmyadmin/* /var/www/phpmyadmin",
        creates => "/var/www/phpmyadmin",
        require => File["/tmp/phpmyadmin"]
    }

    # Set configuration
    exec { "phpmyadmin.config":
        command => "cp /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config.inc.php",
        creates => "/var/www/phpmyadmin/config.inc.php",
        require => File["/var/www/phpmyadmin"]
    }
}