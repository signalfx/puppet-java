require 'spec_helper'

describe "java" do

  context 'when installing Java 7' do
    let(:facts) { default_test_facts }
    let(:params) {
      {
        :java_preference        => '7',
        :java7_update_version   => '79',
        :java8_update_version   => '45',
        :base_download_url      => 'http://download.oracle.com/otn-pub/java/jdk/',
      }
    }

    it do
      should contain_class('boxen::config')
      should contain_class('java')
    end

    it do
      should contain_package('jre-7u79-macosx-x64.dmg').with({
        :ensure   => 'present',
        :alias    => 'java-jre',
        :provider => 'pkgdmg',
        :source   => '/var/tmp/jre-7u79-macosx-x64.dmg'
      })

      should contain_package('jdk-7u79-macosx-x64.dmg').with({
        :ensure   => 'present',
        :alias    => 'java',
        :provider => 'pkgdmg',
        :source   => '/var/tmp/jdk-7u79-macosx-x64.dmg'
      })

      should contain_file('/test/boxen/bin/java').with({
        :source  => 'puppet:///modules/java/java.sh',
        :mode    => '0755'
      })

    end
  end

  context 'when installing Java 8' do
    let(:facts) { default_test_facts }
    let(:params) {
      {
        :java_preference       => '8',
        :java8_update_version  => '45',
        :base_download_url => 'http://download.oracle.com/otn-pub/java/jdk/',
      }
    }

    it do
      should contain_class('boxen::config')
      should contain_class('java')
    end

    it do
      should contain_package('jre-8u45-macosx-x64.dmg').with({
        :ensure   => 'present',
        :alias    => 'java-jre',
        :provider => 'pkgdmg',
        :source   => '/var/tmp/jre-8u45-macosx-x64.dmg'
      })

      should contain_package('jdk-8u45-macosx-x64.dmg').with({
        :ensure   => 'present',
        :alias    => 'java',
        :provider => 'pkgdmg',
        :source   => '/var/tmp/jdk-8u45-macosx-x64.dmg'
      })

      should contain_file('/test/boxen/bin/java').with({
        :source  => 'puppet:///modules/java/java.sh',
        :mode    => '0755'
      })
    end
  end

  context 'fails when java version has Yosemite relevant bug' do
    let(:facts) { default_test_facts.merge({ :macosx_productversion_major => '10.10' }) }
    let(:params) {
      {
        :java7_update_version => '51',
      }
    }
    it do
      expect {
        should contain_class('java')
      }.to raise_error(/Yosemite Requires Java 7 with a patch level >= 71 \(Bug JDK\-8027686\)/)
    end
  end
end