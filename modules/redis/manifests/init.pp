class redis {
    # Install redis
    package { 'redis-server':
        ensure => latest,
    }

    # Enable the redis service
    service { "redis-server":
        enable => true,
        ensure => running,
        require => Package["redis-server"]
    }
}