class bootstrap {

  # silence puppet and vagrant annoyance about the puppet group
  group { 'puppet':
    ensure => 'present'
  }

  # ensure local apt cache index is up to date before beginning
  # the magic unless line is to only do this once per day!
  exec { 'apt-get update':
    command => '/usr/bin/apt-get update',
    unless => 'test $(expr `date +%s` - `stat -c %Y /var/cache/apt/`) -lt 36000'
  }
}
