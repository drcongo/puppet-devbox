class php {
    # Install PHP packages
    $phpPackages = ["php5", "php5-cli", "php5-mysql", "php-pear", "php5-dev", "php-apc", "php5-mcrypt", "php5-gd", "php5-sqlite", "php5-intl", "php5-xdebug", "php5-memcache"]
    package { $phpPackages:
        ensure => latest,
        require => [Exec['apt-get update'], Package['apache2']],
    }

    # Make configuration changes to CLI
    $phpCliIni = '/etc/php5/cli/php.ini'
    exec { "cli date.timezone":
        command => "sed -i 's/^;date.timezone =.*/date.timezone = UTC/' $phpCliIni",
        require => Package["php5-cli"],
        before => Exec['pear upgrade']
    }
    exec { "cli short_open_tag":
        command => "sed -i 's/^short_open_tag = On/short_open_tag = Off/' $phpCliIni",
        require => Package["php5-cli"],
        before => Exec['pear upgrade']
    }
    exec { "cli error_reporting":
        command => "sed -i 's/^error_reporting = .*$/error_reporting = E_ALL/' $phpCliIni",
        require => Package["php5-cli"],
        before => Exec['pear upgrade']
    }
    exec { "cli display_errors":
        command => "sed -i 's/^display_errors = Off/display_errors = On/' $phpCliIni",
        require => Package["php5-cli"],
        before => Exec['pear upgrade']
    }
    exec { "cli display_startup_errors":
        command => "sed -i 's/^display_startup_errors = Off/display_startup_errors = On/' $phpCliIni",
        require => Package["php5-cli"],
        before => Exec['pear upgrade']
    }

    # Make configuration changes to mod_php
    $phpWebIni = '/etc/php5/apache2filter/php.ini'
    exec { "web date.timezone":
        command => "sed -i 's/^;date.timezone =.*/date.timezone = UTC/' $phpWebIni",
        require => Package["php5"],
        notify  => Service["apache2"]
    }
    exec { "web short_open_tag":
        command => "sed -i 's/^short_open_tag = On/short_open_tag = Off/' $phpWebIni",
        require => Package["php5"],
        notify  => Service["apache2"]
    }
    exec { "web error_reporting":
        command => "sed -i 's/^error_reporting =.*/error_reporting = E_ALL/' $phpWebIni",
        require => Package["php5"],
        notify  => Service["apache2"]
    }
    exec { "web display_errors":
        command => "sed -i 's/^display_errors = Off/display_errors = On/' $phpWebIni",
        require => Package["php5"],
        notify  => Service["apache2"]
    }
    exec { "web display_startup_errors":
        command => "sed -i 's/^display_startup_errors = Off/display_startup_errors = On/' $phpWebIni",
        require => Package["php5"],
        notify  => Service["apache2"]
    }

    # Install various PEAR packages
    exec { "pear upgrade":
        command => "pear upgrade",
        require => [Package['php5-cli'], Package['php-pear']],
    }
    exec { "pear auto-discover":
        command => "pear config-set auto_discover 1",
        require => Exec['pear upgrade'],
    }
    exec { "pear-phpunit":
        command => "pear install --alldeps pear.phpunit.de/PHPUnit",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phpcpd":
        command => "pear install pear.phpunit.de/phpcpd",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phploc":
        command => "pear install pear.phpunit.de/phploc",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phpmd":
        command => "pear install --alldeps pear.phpmd.org/PHP_PMD",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phpdoc":
        command => "pear install pear.phpdoc.org/phpDocumentor-alpha",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phing":
        command => "pear install pear.phing.info/phing",
        require => Exec['pear auto-discover'],
    }

    # Add a phpinfo file to www root
    exec { "php add phpinfo":
        command => "echo '<?php phpinfo();' >> /var/www/phpinfo.php",
        require => Package['apache2']
    }
}