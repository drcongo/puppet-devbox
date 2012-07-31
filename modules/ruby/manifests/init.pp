class ruby {
    # Ensure we have ruby
    package { "ruby1.9.1":
        ensure => latest,
        require => Exec['apt-get update']
    }

    # Install some useful gems
    exec { "gem.capistrano":
        command => "gem install capistrano",
        require => Package['ruby1.9.1']
    }
    exec { "gem.compass":
        command => "gem install compass",
        require => Package['ruby1.9.1']
    }
}