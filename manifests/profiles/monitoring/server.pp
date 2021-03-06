class pve::profiles::monitoring::server {

  class { 'prometheus':
    version         => '1.8.0',
    init_style      => $init_style,
    config_template => 'pve/prometheus/prometheus.yaml.erb'
  }

  $tags = [$::environment,
    "traefik.tags=${::environment}",
    "traefik.frontend.rule=Host:metrics.dniel.in,metrics",
    "traefik.frontend.passHostHeader=true"]

  ::consul::service { "${::hostname}-metrics":
    service_name => 'metrics',
    address      => $::ipaddress_eth0,
    port         => 3000,
    tags         => $tags
  } ~> Service['consul']

  class { 'grafana':
    version => 'latest'
  }

  #  grafana_datasource { 'prometheus':
  #    type              => 'prometheus',
  #    url               => 'http://localhost:9090',
  #    is_default        => true
  #  }
}