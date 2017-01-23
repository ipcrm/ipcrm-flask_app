application flask_app (
  String $app_name,
  String $dist_lookup_string        = "${::appenv}-dist_file",
  Variant[Undef,String] $dist_file  = undef,
  Variant[Undef,String] $vhost_name = undef,
  Variant[Undef,String] $vhost_port = undef,
  Variant[Undef,String] $doc_root   = undef,
){

  flask_app::webhead { $name:
    app_name           => $app_name,
    dist_file          => $dist_file,
    dist_lookup_string => $dist_lookup_string,
    vhost_name         => $vhost_name,
    vhost_port         => $vhost_port,
    doc_root           => $doc_root,
    export             => Flask_app_http[$name],
  }

}
