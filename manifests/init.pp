#
# curl -L -b "oraclelicense=a" http://download.oracle.com/otn-pub/java/jdk/8u40-b27/jdk-8u40-macosx-x64.dmg -O
#
# Public: installs java jre-7u51 and JCE unlimited key size policy files
#
# Examples
#
#    include java
class java (
  $java7_update_version        = '79',
  $java_preference             = '8',
  $java8_update_version        = '45',
  $base_download_url       = 'http://download.oracle.com/otn-pub/java/jdk/'
) {
  include boxen::config

  $jdk7_dir       = "/Library/Java/JavaVirtualMachines/jdk1.7.0_${java7_update_version}.jdk"
  $jdk8_dir       = "/Library/Java/JavaVirtualMachines/jdk1.8.0_${java8_update_version}.jdk"
  $sec_dir        = "${::jdk_dir}/Contents/Home/jre/lib/security"
  $wrapper        = "${boxen::config::bindir}/java"

  if ((versioncmp($::macosx_productversion_major, '10.10') >= 0) and
    versioncmp($java7_update_version, '71') < 0)
  {
    fail('Yosemite Requires Java 7 with a patch level >= 71 (Bug JDK-8027686)')
  }

  file { $wrapper:
    source  => 'puppet:///modules/java/java.sh',
    mode    => '0755'
  }

  case $java_preference {

    '7': {

      if (versioncmp($::java_version, '1.8.0') < 0) {

        exec { 'download oracle jdk 7':
          command  => "curl -L -b \"oraclelicense=a\" ${base_download_url}/jdk-7u${java7_update_version}-macosx-x64.dmg > /var/tmp/jdk-7u${java7_update_version}-macosx-x64.dmg",
        }

        exec { 'download oracle jre 7':
          command  => "curl -L -b \"oraclelicense=a\" ${base_download_url}/jre-7u${java7_update_version}-macosx-x64.dmg > /var/tmp/jre-7u${java7_update_version}-macosx-x64.dmg",
        }


        #exec { 'download oracle jce 7 extended policy files':
        #  command  => 'curl -L -b \"oraclelicense=a\" http://download.oracle.com/otn-pub/java/jce/7/UnlimitedJCEPolicyJDK7.zip > UnlimitedJCEPolicyJDK7.zip',
        #}

        package {
          "jre-7u${java7_update_version}-macosx-x64.dmg":
            ensure   => present,
            alias    => 'java-jre',
            provider => pkgdmg,
            source   => "/var/tmp/jre-7u${java7_update_version}-macosx-x64.dmg";
          "jdk-7u${java7_update_version}-macosx-x64.dmg":
            ensure   => present,
            alias    => 'java',
            provider => pkgdmg,
            source   => "/var/tmp/jdk-7u${java7_update_version}-macosx-x64.dmg";
        }

        # Allow 'large' keys locally.
        # http://www.ngs.ac.uk/tools/jcepolicyfiles
        file { $sec_dir:
          ensure  => 'directory',
          owner   => 'root',
          group   => 'wheel',
          mode    => '0775',
          require => Package['java']
        }

        file { "${sec_dir}/local_policy.jar":
          source  => 'puppet:///modules/java/java7/local_policy.jar',
          owner   => 'root',
          group   => 'wheel',
          mode    => '0664',
          require => File[$sec_dir]
        }

        file { "${sec_dir}/US_export_policy.jar":
          source  => 'puppet:///modules/java/java7/US_export_policy.jar',
          owner   => 'root',
          group   => 'wheel',
          mode    => '0664',
          require => File[$sec_dir]
        }
      }
    }

    '8': {

      if (versioncmp($::java_version, '1.8.0') < 0) {

        exec { 'download oracle jdk 8':
          command  => "curl -L -b \"oraclelicense=a\" ${base_download_url}/jdk-8u${java8_update_version}-macosx-x64.dmg > /var/tmp/jdk-8u${java8_update_version}-macosx-x64.dmg",
        }

        exec { 'download oracle jre 8':
          command  => "curl -L -b \"oraclelicense=a\" ${  base_download_url}/jre-8u${java8_update_version}-macosx-x64.dmg > /var/tmp/jre-8u${java8_update_version}-macosx-x64.dmg",
        }

        #exec { 'download oracle jce 8 extended policy files':
        #  command  => 'curl -L -b \"oraclelicense=a\" http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip > /var/tmp/jce_policy-8.zip',
        #}

        package {
          "jre-8u${java8_update_version}-macosx-x64.dmg":
            ensure   => present,
            alias    => 'java-jre',
            provider => pkgdmg,
            source   => "/var/tmp/jre-8u${java8_update_version}-macosx-x64.dmg";
          "jdk-8u${java8_update_version}-macosx-x64.dmg":
            ensure   => present,
            alias    => 'java',
            provider => pkgdmg,
            source   => "/var/tmp/jdk-8u${java8_update_version}-macosx-x64.dmg";
        }

        # Allow 'large' keys locally.
        # http://www.ngs.ac.uk/tools/jcepolicyfiles
        file { $sec_dir:
          ensure  => 'directory',
          owner   => 'root',
          group   => 'wheel',
          mode    => '0775',
          require => Package['java']
        }

        file { "${sec_dir}/local_policy.jar":
          source  => 'puppet:///modules/java/java8/local_policy.jar',
          owner   => 'root',
          group   => 'wheel',
          mode    => '0664',
          require => File[$sec_dir]
        }

        file { "${sec_dir}/US_export_policy.jar":
          source  => 'puppet:///modules/java/java8/US_export_policy.jar',
          owner   => 'root',
          group   => 'wheel',
          mode    => '0664',
          require => File[$sec_dir]
        }
      }
    }

    default: {
    # noop
    }
  }
}
