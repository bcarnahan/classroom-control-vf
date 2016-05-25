class nginx {
  Yumrepo {
    ensure              => present,
    enabled             => '1',
    gpgcheck            => '1',
    gpgkey              => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7',
    priority            => '99',
    skip_if_unavailable => '1',
    before              => [ Package['nginx'], Package['openssl-libs'] ],
  }

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0664',
  }

  yumrepo { 'base':
    descr      => 'CentOS-$releasever - Base',
    mirrorlist => 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra',
  }

  yumrepo { 'updates':
    descr      => 'CentOS-$releasever - Updates',
    mirrorlist => 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates&infra=$infra',
  }

  yumrepo { 'extras':
    descr      => 'CentOS-$releasever - Extras',
    mirrorlist => 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras&infra=$infra',
  }

  yumrepo { 'centosplus':
    descr      => 'CentOS-$releasever - Plus',
    mirrorlist => 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus&infra=$infra',
  }

  package { [ 'openssl', 'openssl-libs' ] :
    ensure => '1.0.1e-51.el7_2.5',
    before => Package['nginx'],
  }

  file { 'nginx rpm' :
    ensure   => file,
    path     => '/opt/nginx-1.6.2-1.el7.centos.ngx.x86_64.rpm',
    source   => "puppet:///modules/${module_name}/nginx-1.6.2-1.el7.centos.ngx.x86_64.rpm",
  }

  package { $module_name :
    ensure   => '1.6.2-1.el7.centos.ngx',
    source   => '/opt/nginx-1.6.2-1.el7.centos.ngx.x86_64.rpm',
    provider => rpm,
    require  => File['nginx rpm'],
    before   => [ File['nginx conf'], File['default conf'] ],
  }

  $nginx_base_dir = "/etc/${module_name}"

  file { '/var/www/' :
    ensure  => directory,
  }

  file { 'index.html' :
    ensure  => file,
    path    => '/var/www/index.html',
    source  => "puppet:///modules/${module_name}/index.html",
  }

  file { 'nginx conf' :
    ensure  => file,
    path    => "${nginx_base_dir}/nginx.conf",
    source  => "puppet:///modules/${module_name}/nginx.conf",
  }

  file { 'default conf' :
    ensure  => file,
    path    => "${nginx_base_dir}/conf.d/default.conf",
    source  => "puppet:///modules/${module_name}/default.conf",
  }

  service { $module_name :
    ensure    => running,
    enable    => true,
    require   => File['index.html'], 
    subscribe => [ File['nginx conf'], File['default conf'] ],
  }

}
