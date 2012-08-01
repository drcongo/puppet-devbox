class apache ($hostname) {
    # Install apache
    package { "apache2":
        ensure => latest,
        require => Exec['apt-get update']
    }

    # Enable the apache service
    service { "apache2":
        enable => true,
        ensure => running,
        require => Package["apache2"],
        subscribe => [
            File["/etc/apache2/mods-enabled/rewrite.load"],
            File["/etc/apache2/sites-enabled/010-project"]
        ]
    }

    # ensures that mod_rewrite is loaded and modifies the default configuration file
    file { "/etc/apache2/mods-enabled/rewrite.load":
        ensure => link,
        target => "/etc/apache2/mods-available/rewrite.load",
        require => Package['apache2'],
    }

    # Set the configuration
    file { "/etc/apache2/sites-enabled/010-project":
        ensure => present,
        source => "puppet:///modules/apache/project_vhost.conf",
        require => Package['apache2'],
    }

    # Set the hostname
    exec { "apache.hostname":
        command => "sed -i 's/ServerName __HOSTNAME__/ServerName $hostname/' /etc/apache2/sites-enabled/010-project",
        require => File['/etc/apache2/sites-enabled/010-project']
    }

    # Remove the default index file
    file { "apache.remove.default.index":
        ensure => absent,
        require => Package['apache2']
    }
}