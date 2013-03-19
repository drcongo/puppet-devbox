# Main module
class devbox ($hostname, $documentroot, $gitUser, $gitEmail) {
    # Set paths
    Exec {
        path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
    }

    include bootstrap
    include mysql
    include memcached
    include redis
    include postfix
    include ruby
    include php
    include pear

    class {'mongodb':
      enable_10gen => true,
    }

    class { "apache":
        hostname => $hostname,
        documentroot => $documentroot
    }

    exec { 'pecl-mongo-install':
        command => 'pecl install mongo',
        unless => "pecl info mongo",
        notify => Service['apache2'],
        require => Package['php-pear'],
    }

    exec { 'pecl-memcache-install':
        command => 'pecl install memcache',
        unless => "pecl info memcache",
        notify => Service['apache2'],
        require => Package['php-pear'],
    }

    class { "git":
        gitUser => $gitUser,
        gitEmail => $gitEmail
    }
    include svn

    include zsh
    include vim

    include xhprof
}
