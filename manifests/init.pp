application flask_app (
  String $app_name,
  String $dist_lookup_string        = "${::role}-${::appenv}-dist_file",
  String $dist_file                 = hiera($dist_lookup_string),
  String $local_archive             = "${app_name}_archive.tar.gz",
  Variant[Undef,String] $vhost_name = undef,
  Variant[Undef,String] $vhost_port = undef,
  Variant[Undef,String] $doc_root   = undef,
){

  flask_app::webhead { $name:
    app_name      => $app_name,
    dist_file     => $dist_file,
    local_archive => $local_archive,
    vhost_name    => $vhost_name,
    vhost_port    => $vhost_port,
    doc_root      => $doc_root,
    export        => Flask_app_http[$name],
  }

}
