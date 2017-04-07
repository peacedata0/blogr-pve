class pve::profiles::blogr::restapi{
  class { 'docker':
    manage_service => false
  }

  class { 'rancher':
    registration_url => 'http://10.0.60.100:8080/v1/scripts/443B929165E879B9F533:1483142400000:7C5YD5HkhiDu4foMN6V1XzFo6IY'
  }

  file{"/opt/blogr":
    ensure  =>  directory,
  }
  exec {"chown blogr":
    require => [File['/opt/blogr'], User['jenkins']],
    command => "/bin/chown -R jenkins.jenkins /opt/blogr",
  }
  class { 'nodejs':
    version      => 'latest',
    make_install => false
  }
  file { '/etc/init.d/node-app':
    content => template('pve/blogr/node-app.erb'),
    notify => Service['node-app'],
    mode => "755"
  }
  service { 'node-app':
    ensure  => running,
    enable  => true,
    require => [File['/etc/init.d/node-app']]
  }

  $tags = [$::environment,"traefik.tags=${::environment}"]
  ::consul::service { "${::hostname}-app":
    service_name => "app",
    address      => "${::ipaddress}",
    port         => 3000,
    tags         => $tags
  }

}