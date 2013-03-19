class { "devbox":
    hostname => "testbox2.dev", # Make sure this maps to the address above
    documentroot => "site/public", # Apache documentroot eg: www, web, public_html etc
    gitUser => "Your github username",
    gitEmail => "Your github email address"
}
