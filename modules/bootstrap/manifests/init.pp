class bootstrap {
    # This makes puppet and vagrant shut up about the puppet group
    group { "puppet":
        ensure => "present",
    }

    # Set FQDN
    if $virtual == "virtualbox" and $fqdn == '' {
        $fqdn = "localhost"
    }

    # Load repos
    exec { "add-php-repo-deb":
        command => "echo 'deb http://ppa.launchpad.net/ondrej/php5/ubuntu precise main' >> /etc/apt/sources.list",
        unless => "grep \"deb .*ondrej/php5\" /etc/apt/sources.list 2>/dev/null",
        before => Exec["apt-get update"]
    }
    exec { "add-php-repo-deb-src":
        command => "echo 'deb-src http://ppa.launchpad.net/ondrej/php5/ubuntu precise main' >> /etc/apt/sources.list",
        unless => "grep \"deb-src .*ondrej/php5\" /etc/apt/sources.list 2>/dev/null",
        before => Exec["apt-get update"]
    }
    exec { "add-php-repo-key":
        command => "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C",
        unless => "apt-key list | grep E5267A6C 2>/dev/null",
        before => Exec["apt-get update"]
    }
    exec { "add-redis-repo-deb":
        command => "echo 'deb http://ppa.launchpad.net/chris-lea/redis-server/ubuntu precise main' >> /etc/apt/sources.list",
        unless => "grep \"deb .*chris-lea/redis-server\" /etc/apt/sources.list 2>/dev/null",
        before => Exec["apt-get update"]
    }
    exec { "add-redis-repo-deb-src":
        command => "echo 'deb-src http://ppa.launchpad.net/chris-lea/redis-server/ubuntu precise main' >> /etc/apt/sources.list",
        unless => "grep \"deb-src .*chris-lea/redis-server\" /etc/apt/sources.list 2>/dev/null",
        before => Exec["apt-get update"]
    }
    exec { "add-redis-repo-key":
        command => "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7917B12",
        unless => "apt-key list | grep C7917B12 2>/dev/null",
        before => Exec["apt-get update"]
    }

    # Ensure we are up to date
    exec { "apt-get update":
        command => "apt-get update",
    }

    # Common packages
    package { "wget":
        ensure => "latest"
    }
    package { "unzip":
        ensure => "latest"
    }
}