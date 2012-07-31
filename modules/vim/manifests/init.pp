class vim {
    # Install vim
    package { 'vim':
        ensure => latest,
    }

    # Set the configuration
    file { "/home/vagrant/.vimrc":
        ensure => present,
        owner => "vagrant",
        group => "vagrant",
        source => "puppet:///modules/vim/vimrc",
        require => Package['vim'],
    }
}