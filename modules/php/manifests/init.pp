class php {
    # Install PHP packages
    $phpPackages = ["php5", "php5-cli", "php5-mysql", "php-pear", "php5-dev", "php-apc", "php5-mcrypt", "php5-gd", "php5-sqlite", "php5-curl", "php5-intl", "php5-xdebug", "php5-memcache"]
    package { $phpPackages:
        ensure => latest,
        require => [Exec['apt-get update'], Package['apache2']],
    }

    # Change configuration files
    file { "/etc/php5/cli/php.ini":
        ensure => file,
        owner => "root",
        group => "root",
        source => "puppet:///modules/php/php-cli.ini",
        require => Package['php5-cli'],
    }
    file { "/etc/php5/apache2filter/php.ini":
        ensure => file,
        owner => "root",
        group => "root",
        source => "puppet:///modules/php/php-web.ini",
        notify => Service["apache2"],
        require => Package['php5'],
    }

    # Ensure session folder is writable by Vagrant user (under which apache runs)
    file { "/var/lib/php5/session" :
        owner  => "root",
        group  => "vagrant",
        mode   => 0770,
        require => Package["php5"],
    }

    # Install image magick extension. Upstream has problems, so we have to install
    # the package manually.
    package { "imagemagick":
        ensure => latest,
        require => Exec['apt-get update'],
    }
    exec { "php.imagick.download":
        command => "wget https://launchpad.net/~ondrej/+archive/php5/+files/php5-imagick_3.1.0%7Erc1-1%7Eprecise%2B1_amd64.deb -O /tmp/php5-imagick.deb",
        creates => "/tmp/php5-imagick.deb",
        unless => "dpkg -l php5-imagick | grep ii",
        require => Package['php5']
    }
    exec { "php.imagick.install":
        command => "dpkg -i /tmp/php5-imagick.deb",
        unless => "dpkg -l php5-imagick | grep ii",
        require => [Package['imagemagick'], Exec["php.imagick.download"]],
        notify => Service["apache2"]
    }

    # Install xhprof. PECL version doesn't run with PHP 5.4, so we have
    # to compile and install manually.
    exec { "php.xhprof.download":
        command => "git clone --depth 1 git://github.com/preinheimer/xhprof.git",
        cwd => "/var/www",
        creates => "/var/www/xhprof",
        unless => "ls /var/www/xhprof",
        require => [Package['apache2'], Package['git']],
    }
    exec { "php.xhprof.phpize":
        command => "phpize",
        cwd => "/var/www/xhprof/extension",
        unless => "php -m | grep xhprof",
        require => [Package['php5-dev'], Exec["php.xhprof.download"]]
    }
    exec { "php.xhprof.configure":
        command => "sh ./configure",
        cwd => "/var/www/xhprof/extension",
        unless => "php -m | grep xhprof",
        require => Exec["php.xhprof.phpize"]
    }
    exec { "php.xhprof.make":
        command => "make",
        cwd => "/var/www/xhprof/extension",
        unless => "php -m | grep xhprof",
        require => [Package['make'], Exec["php.xhprof.configure"]]
    }
    exec { "php.xhprof.make.install":
        command => "make install",
        cwd => "/var/www/xhprof/extension",
        creates => "/usr/lib/php5/20100525/xhprof.so",
        unless => "php -m | grep xhprof",
        require => [Package['make'], Exec["php.xhprof.make"]]
    }
    file { "/etc/php5/conf.d/xhprof.ini":
        content => "extension=xhprof.so",
        require => Exec["php.xhprof.make.install"],
        notify => Service['apache2']
    }

    # Setup xhprof web UI
    file { "/var/www/xhprof/xhprof_lib/config.php":
        ensure => file,
        source => "puppet:///modules/php/xhprof-config.php",
        replace => false,
        require => Exec["php.xhprof.download"]
    }
    exec { "xhprof.web.database":
        command => 'mysql -uroot -proot -e "create database xhprof; use xhprof; CREATE TABLE \`details\` (\`id\` char(17) NOT NULL, \`url\` varchar(255) default NULL, \`c_url\` varchar(255) default NULL, \`timestamp\` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP, \`server name\` varchar(64) default NULL, \`perfdata\` MEDIUMBLOB, \`type\` tinyint(4) default NULL, \`cookie\` BLOB, \`post\` BLOB, \`get\` BLOB, \`pmu\` int(11) unsigned default NULL, \`wt\` int(11) unsigned default NULL, \`cpu\` int(11) unsigned default NULL, \`server_id\` char(3) NOT NULL default \'t11\', \`aggregateCalls_include\` varchar(255) DEFAULT NULL, PRIMARY KEY  (\`id\`), KEY \`url\` (\`url\`), KEY \`c_url\` (\`c_url\`), KEY \`cpu\` (\`cpu\`), KEY \`wt\` (\`wt\`), KEY \`pmu\` (\`pmu\`), KEY \`timestamp\` (\`timestamp\`)) ENGINE=MyISAM DEFAULT CHARSET=utf8;"',
        unless => 'mysql -uroot -proot xhprof -e "exit"',
        require => Exec['set-mysql-password']
    }
    exec { "xhprof.fix.strict.errors":
        command => "sed -i 's/abstract public static function/\\/\\/abstract public static function/' /var/www/xhprof/xhprof_lib/utils/Db/Abstract.php",
        unless => "grep \"//abstract public static function\" /var/www/xhprof/xhprof_lib/utils/Db/Abstract.php",
        require => Exec["php.xhprof.download"]
    }
    file { "/var/www/xhprof/index.php":
        content => "<?php header('Location: /xhprof/xhprof_html/');",
        require => Exec["php.xhprof.download"]
    }
    file { "/var/www/xhprof/.htaccess":
        content => "php_value error_reporting 30719",
        require => Exec["php.xhprof.download"]
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
        unless => "pear info pear.phpunit.de/PHPUnit",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phpcpd":
        command => "pear install pear.phpunit.de/phpcpd",
        unless => "pear info pear.phpunit.de/phpcpd",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phploc":
        command => "pear install pear.phpunit.de/phploc",
        unless => "pear info pear.phpunit.de/phploc",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phpmd":
        command => "pear install --alldeps pear.phpmd.org/PHP_PMD",
        unless => "pear info pear.phpmd.org/PHP_PMD",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phpdoc":
        command => "pear install pear.phpdoc.org/phpDocumentor-alpha",
        unless => "pear info pear.phpdoc.org/phpDocumentor-alpha",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phing":
        command => "pear install pear.phing.info/phing",
        unless => "pear info pear.phing.info/phing",
        require => Exec['pear auto-discover'],
    }

    # Add a phpinfo file to www root
    file { "/var/www/phpinfo.php":
        content => "<?php phpinfo();",
        require => Package['apache2']
    }
}