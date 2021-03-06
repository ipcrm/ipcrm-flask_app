require 'spec_helper'

describe 'flask_app', :type => :application do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      facts[:role]   = 'flask_puppet'
      facts[:appenv] = 'dev'
      facts[:fqdn]   = 'test.puppet.com'

      context "with default params" do
        let(:title) { 'getting-started' }
        let(:node) { 'test.puppet.com' }

        let :params do
          {
            :app_name  => 'testui',
            :dist_file => 'https://testrepo/puppet_flask_test.tar.gz',
            :nodes => {
              ref('Node', node) => [
                ref('Flask_app::Webhead', 'getting-started'),
              ]
            }
          }
        end

        let(:pre_condition){'
          class { "::apache":
            default_vhost => false,
          }
        '}
        it { should compile }
        it { should contain_flask_app(title).with(
          'app_name'  => 'testui',
          'dist_file' => 'https://testrepo/puppet_flask_test.tar.gz'
        ) }

        it { should contain_flask_app__webhead("getting-started").with(
          'dist_file'     => 'https://testrepo/puppet_flask_test.tar.gz',
          'app_name'      => 'testui',
          'vhost_name'    => 'test.puppet.com',
          'vhost_port'    => '80',
          'doc_root'      => '/var/www/flask'
        ) }

        it { should contain_file('/var/www').with(
          'ensure' => 'directory',
        ) }

        it { should contain_file('/var/www/flask').with(
         'ensure' => 'directory',
        ) }

        it { is_expected.to contain_file('/var/www/flask/wsgi.py').with_content(/from testui import testui as application/) }

        it { should contain_apache__vhost('test.puppet.com').with(
          'port'               => '80',
          'docroot'            => '/var/www/flask',
          'wsgi_import_script' => '/var/www/flask/wsgi.py',
        ) }

        it { should contain_exec('pip install puppet_flask_test.tar.gz') }
        it { should contain_remote_file('puppet_flask_test.tar.gz') }
        it { should contain_flask_app_http('getting-started') }
        it { should contain_package('python-pip').with( 'ensure' => 'present' ) }
      end

    context "with customized params" do
      let(:title) { 'custom-deployment' }
      let(:node) { 'test.puppet.com' }

      let :params do
        {
          :app_name   => 'apptest',
          :dist_file  => 'https://testrepo/puppet_flask-0.1.5.tar.gz',
          :doc_root   => '/var/www/root',
          :vhost_port => '8080',
          :nodes => {
            ref('Node', node) => [
              ref('Flask_app::Webhead', 'custom-deployment'),
            ]
          }
        }
      end

        let(:pre_condition){'
          class { "::apache":
            default_vhost => false,
          }
        '}
        it { should compile }
        it { should contain_flask_app(title).with(
          'app_name'  => 'apptest',
          'dist_file' => 'https://testrepo/puppet_flask-0.1.5.tar.gz'
        ) }

        it { should contain_flask_app__webhead("custom-deployment").with(
          'dist_file'     => 'https://testrepo/puppet_flask-0.1.5.tar.gz',
          'app_name'      => 'apptest',
          'vhost_name'    => 'test.puppet.com',
          'vhost_port'    => '8080',
          'doc_root'      => '/var/www/root'
        ) }

        it { should contain_file('/var/www').with(
          'ensure' => 'directory',
        ) }

        it { should contain_file('/var/www/root').with(
         'ensure' => 'directory',
        ) }

        it { is_expected.to contain_file('/var/www/root/wsgi.py').with_content(/from apptest import apptest as application/) }

        it { should contain_apache__vhost('test.puppet.com').with(
          'port'               => '8080',
          'docroot'            => '/var/www/root',
          'wsgi_import_script' => '/var/www/root/wsgi.py',
        ) }

        it { should contain_exec('pip install puppet_flask-0.1.5.tar.gz') }
        it { should contain_remote_file('puppet_flask-0.1.5.tar.gz') }
        it { should contain_flask_app_http('custom-deployment') }
        it { should contain_package('python-pip').with( 'ensure' => 'present' ) }
      end

    end
  end
end
