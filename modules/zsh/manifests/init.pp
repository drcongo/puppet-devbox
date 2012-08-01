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

    # Copy zshrc
    exec { 'copy-zshrc':
        cwd     => "/home/vagrant",
        user    => "vagrant",
        command => 'cp .oh-my-zsh/templates/zshrc.zsh-template .zshrc',
        unless  => 'ls .zshrc',
        require => Exec['clone oh-my-zsh'],
    }

    # Change zshrc
    exec { "omz.theme":
        user    => "vagrant",
        command => "sed -i 's/ZSH_THEME=\".*\"/ZSH_THEME=\"sunrise\"/' /home/vagrant/.zshrc",
        unless => 'grep "ZSH_THEME=\"sunrise\"" /home/vagrant/.zshrc',
        require => Exec['copy-zshrc']
    }
    exec { "omz.plugins":
        user    => "vagrant",
        command => "sed -i 's/plugins=(.*)/plugins=(git svn symfony2 cap)/' /home/vagrant/.zshrc",
        unless => 'grep "plugins=(git svn symfony2 cap)" /home/vagrant/.zshrc',
        require => Exec['copy-zshrc']
    }
    exec { "env.lang":
        user    => "vagrant",
        command => 'echo "LANG=\"en_US.UTF-8\"" >> /home/vagrant/.zshrc',
        unless => "grep LANG /home/vagrant/.zshrc 2>/dev/null",
        require => Exec['copy-zshrc']
    }
    exec { "env.editor":
        user    => "vagrant",
        command => 'echo "EDITOR=\"vim\"" >> /home/vagrant/.zshrc',
        unless => "grep EDITOR /home/vagrant/.zshrc 2>/dev/null",
        require => Exec['copy-zshrc']
    }
    exec { "env.symfony-assets-install":
        user    => "vagrant",
        command => 'echo "SYMFONY_ASSETS_INSTALL=\"symlink\"" >> /home/vagrant/.zshrc',
        unless => "grep SYMFONY_ASSETS_INSTALL /home/vagrant/.zshrc 2>/dev/null",
        require => Exec['copy-zshrc']
    }

    # Set the shell
    exec { "chsh -s /usr/bin/zsh vagrant":
        unless  => "grep -E '^vagrant.+:/usr/bin/zsh$' /etc/passwd",
        require => Package['zsh']
    }
}