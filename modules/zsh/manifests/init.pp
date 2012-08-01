class zsh {
    # Install ZSH
    package { 'zsh':
        ensure => latest,
    }

    # Install packages required for oh-my-zsh
    package { 'curl':
        ensure => latest,
    }
    package { 'git-core':
        ensure => latest,
    }

    # Clone oh-my-zsh
    exec { 'clone oh-my-zsh':
        cwd     => "/home/vagrant",
        user    => "vagrant",
        command => "git clone http://github.com/breidh/oh-my-zsh.git /home/vagrant/.oh-my-zsh",
        creates => "/home/vagrant/.oh-my-zsh",
        require => [Package['git-core'], Package['zsh'], Package['curl']]
    }

    # Set configuration
    file { "/home/vagrant/.zshrc":
        ensure => file,
        owner => "vagrant",
        group => "vagrant",
        replace => false,
        source => "puppet:///modules/zsh/zshrc",
        require => Exec['clone oh-my-zsh']
    }

    # Set the shell
    exec { "chsh -s /usr/bin/zsh vagrant":
        unless  => "grep -E '^vagrant.+:/usr/bin/zsh$' /etc/passwd",
        require => Package['zsh']
    }
}