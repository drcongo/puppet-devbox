class memcached {
    # Install memcached
    package { 'memcached':
        ensure => latest,
    }

    # Enable the redis service
    service { "memcached":
        enable => true,
        ensure => running,
        require => Package["memcached"]
    }
}