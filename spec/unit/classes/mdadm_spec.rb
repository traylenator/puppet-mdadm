require 'spec_helper'

describe 'mdadm', :type => :class do

  shared_examples 'mdadm' do
    it { should contain_package('mdadm').with_ensure('present') }
    it { should contain_class('mdadm::params') }
    it { should contain_class('mdadm::mdmonitor') }
    it do
      should contain_service('mdmonitor').with({
        :ensure     => 'running',
        :hasrestart => true,
        :hasstatus  => true,
        :enable     => true,
      })
    end
  end

  context 'on osfamily RedHat' do
    let(:facts) {{ :osfamily => 'RedHat' }}

    context 'no params' do
      it_behaves_like 'mdadm'
      it do
        should contain_file('/etc/sysconfig/raid-check').
          with_content(/ENABLED="yes"/).
          with_content(/CHECK="check"/). 
          with_content(/NICE="low"/). 
          with_content(/CHECK_DEVS=""/). 
          with_content(/REPAIR_DEVS=""/). 
          with_content(/SKIP_DEVS=""/)
      end
    end # no params

    context 'raid_check_options =>' do
      context '{}' do
        let(:params) {{ :raid_check_options => {} }}

        it_behaves_like 'mdadm'
        it do
          should contain_file('/etc/sysconfig/raid-check').
            with_content(/ENABLED="yes"/).
            with_content(/CHECK="check"/). 
            with_content(/NICE="low"/). 
            with_content(/CHECK_DEVS=""/). 
            with_content(/REPAIR_DEVS=""/). 
            with_content(/SKIP_DEVS=""/)
        end
      end

      context '{ ... }' do
        let(:params) do
          {
            :raid_check_options => {
              'ENABLED'     => 'foo',
              'CHECK'       => 'foo',
              'NICE'        => 'foo',
              'CHECK_DEVS'  => 'foo',
              'REPAIR_DEVS' => 'foo',
              'SKIP_DEVS'   => 'foo',
            },
          }
        end

        it_behaves_like 'mdadm'
        it do
          should contain_file('/etc/sysconfig/raid-check').
            with_content(/ENABLED="foo"/).
            with_content(/CHECK="foo"/). 
            with_content(/NICE="foo"/). 
            with_content(/CHECK_DEVS="foo"/). 
            with_content(/REPAIR_DEVS="foo"/). 
            with_content(/SKIP_DEVS="foo"/)
        end
      end

      context 'some_string' do
        let(:params) {{ :raid_check_options => 'some_string' }}

        it 'should fail' do
          expect { should }.to raise_error /is not a Hash/
        end
      end

    end # raid_check_options =>
  end

end