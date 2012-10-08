# Main module
class devbox ($hostname, $gitUser, $gitEmail) {
    # Set paths
    Exec {
        path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
    }

    include bootstrap
    include mysql
    include memcached
    include redis
    include postfix
    include php
    include ruby

    class { "apache":
        hostname => $hostname
    }

    class { "git":
        gitUser => $gitUser,
        gitEmail => $gitEmail
    }

    include zsh
    include vim

    include phpmyadmin
}