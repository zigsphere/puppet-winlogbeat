class winlogbeat::params {
  $service_ensure       = running
  $service_enable       = true
  $beat_name            = $::fqdn
  $tags                 = []
  $queue_size           = 1000
  $max_procs            = undef
  $fields               = {}
  $fields_under_root    = false
  $outputs              = {}
  $shipper              = {}
  $logging              = {}
  $run_options          = {}
  $use_generic_template = false
  $kernel_fail_message  = "${::kernel} is not supported by winlogbeat."
  $use_chocolatey       = false
  $package_version      = '6.4.1'

  # These are irrelevant as long as the template is set based on the major_version parameter
  # if versioncmp('1.9.1', $::rubyversion) > 0 {
  #   $conf_template = "${module_name}/winlogbeat.yml.ruby18.erb"
  # } else {
  #   $conf_template = "${module_name}/winlogbeat.yml.erb"
  # }

  case $::kernel {
    'Windows' : {
      $package_ensure   = $package_version
      $package_name     = 'winlogbeat'
      $package_source   = undef
      $install_dir      = 'C:/Program Files'
      $tmp_dir          = 'C:/Windows/Temp'
      $service_provider = undef
      $url_arch         = $::architecture ? {
        'x86'   => 'x86',
        'x64'   => 'x86_64',
        default => fail("${::architecture} is not supported by winlogbeat."),
      }
    }

    default : {
      fail($kernel_fail_message)
    }
  }
}
