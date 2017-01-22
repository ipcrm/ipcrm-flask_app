define flask_app::webhead (
  $app_name,
  $local_archive,
  $dist_file = undef,
  $dist_lookup_string = "${::appenv}-dist_file",
  $vhost_name = $::fqdn,
  $vhost_port = '80',
  $doc_root = '/var/www/flask',
){

  if $dist_file == undef {
    $_dist_file = hiera($dist_lookup_string)
  } else {
    $_dist_file = $dist_file
  }

  package{'python-pip':
    ensure  => present,
  } ->

  file {'/var/www':
    ensure => directory,
    mode   => '0755',
  } ->

  file {$doc_root:
    ensure => directory,
    mode   => '0755',
  } ->

  file { "${doc_root}/wsgi.py":
    ensure  => present,
    mode    => '0755',
    content => template('flask_app/wsgi.py.erb'),
  } ->

  apache::vhost { $vhost_name:
    port                        => $vhost_port,
    docroot                     => $doc_root,
    wsgi_application_group      => '%{GLOBAL}',
    wsgi_daemon_process         => 'wsgi',
    wsgi_daemon_process_options => {
      processes    => '2',
      threads      => '15',
      display-name => '%{GROUP}',
    },
    wsgi_import_script          => "${doc_root}/wsgi.py",
    wsgi_import_script_options  => {
      process-group     => 'wsgi',
      application-group => '%{GLOBAL}',
    },
    wsgi_process_group          => 'wsgi',
    wsgi_script_aliases         => {
      '/' => "${doc_root}/wsgi.py",
    },
  }

  remote_file { $local_archive:
    ensure  => latest,
    path    => "/var/tmp/${local_archive}",
    source  => $_dist_file,
    notify  => Exec["pip install ${local_archive}"],
    require => [ Class['apache'], Apache::Vhost[$::fqdn] ],
  }

  exec { "pip install ${local_archive}":
    refreshonly => true,
    path        => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
    command     => "pip install /var/tmp/${local_archive} --upgrade",
    notify      => Service['httpd'],
    require     => Remote_file[$local_archive],
  }

}
Flask_app::Webhead produces Flask_app_http {
  name => $name,
  host => $::hostname,
  ip   => $::ipaddress,
  port => '80',
}
