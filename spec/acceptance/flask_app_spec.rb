require 'spec_helper_acceptance'

describe 'flask_app webhead define' do

		context 'setup web' do
      # Using puppet_apply as a helper
      it 'should work idempotently with no errors' do
        pp = <<-EOS
        include ::epel
        package {'wget': ensure => present, }
        class {'::apache':
          default_vhost => false,
        }
        flask_app::webhead {'beaker_test':
          app_name => 'webui',
        }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end


      describe port(80) do
          it { should be_listening }
      end

      describe command('curl --silent http://localhost:80') do
          its(:stdout) { should match /html/ }
      end

      describe command('curl --silent http://localhost:80') do
          its(:stdout) { should match /Puppet/ }
      end

      describe command('curl --silent http://localhost:80/TESTVALUE') do
          its(:stdout) { should match /TESTVALUE/ }
      end

  end

end
