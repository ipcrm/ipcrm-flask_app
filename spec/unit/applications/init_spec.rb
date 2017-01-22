require 'spec_helper'

describe 'flask_app', :type => :application do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context "on a single node setup" do
        let(:title) { 'getting-started' }
        let(:node) { 'test.puppet.com' }

        let :params do
          {
            :app_name  => 'testui',
            :dist_file => 'puppet_flask_test',
            :nodes => {
              ref('Node', node) => [
                ref('Flask_puppet::Webhead', 'getting-started'),
              ]
            }
          }
        end

        context 'with defaults for all parameters' do
          let(:pre_condition){'
            class { "::apache": }
          '}
          it { should compile }
          it { should contain_flask_app(title).with(
            'app_name' => 'testui',
            'dist_file' => 'puppet_flask_test'
          ) }

          it { should contain_flask_app__webhead("getting-started").with(
            'local_archive' => 'testui_archive.tar.gz',
            'app_name'     => 'testui',
            'vhost_name' => 'test.puppet.com',
            'vhost_port'  => '80',
            'doc_root'    => '/var/www/flask'
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
            'doc_root'           => '/var/www/flask',
            'wsgi_import_script' => '/var/www/flask/wsgi.py',
          ) }

        end
      end
    end
  end
end

