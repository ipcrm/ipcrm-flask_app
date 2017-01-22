application flask_app (
  String $app_name,
  String $dist_file,
  String $local_archive = "${app_name}_archive.tar.gz",
  Variant[String,Undef] $vhost_name = undef,
  Variant[String,Undef] $vhost_port = undef,
  Variant[String,Undef] $doc_root   = undef,
){

  $_dist_file = hiera($dist_file)

  flask_puppet::webhead { $name:
    app_name      => $app_name,
    dist_file     => $_dist_file,
    local_archive => $local_archive,
    vhost_name    => $vhost_name,
    vhost_port    => $vhost_port,
    doc_root      => $doc_root,
    export        => Flask_puppet_http[$name],
  }

}
