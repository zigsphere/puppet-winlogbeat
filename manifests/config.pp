class winlogbeat::config {
  $winlogbeat_config = delete_undef_values({
    'beat_name'         => $winlogbeat::beat_name,
    'tags'              => $winlogbeat::tags,
    'queue_size'        => $winlogbeat::queue_size,
    'max_procs'         => $winlogbeat::max_procs,
    'fields'            => $winlogbeat::fields,
    'fields_under_root' => $winlogbeat::fields_under_root,
    'winlogbeat'        => {
      'registry_file' => $winlogbeat::real_registry_file,
      'metrics'       => $winlogbeat::metrics,
      'event_logs'    => $winlogbeat::event_logs_final,
    },
    'output'            => $winlogbeat::outputs,
    'shipper'           => $winlogbeat::shipper,
    'logging'           => $winlogbeat::logging,
    'runoptions'        => $winlogbeat::run_options,
  })

  case $::kernel {
    'Windows' : {
      if $winlogbeat::use_chocolatey {
        $winlogbeat_path = 'C:\\ProgramData\\chocolatey\\bin\\winlogbeat.exe'
      }
      else {
        $cmd_install_dir = regsubst($winlogbeat::install_dir, '/', '\\', 'G')
        $winlogbeat_path = join([$cmd_install_dir, 'Winlogbeat', 'winlogbeat.exe'], '\\')
      }
      if $winlogbeat::major_version == '6' {
        $validate_subcommand = 'test config'
      }
      else {
        $validate_subcommand = '-N -configtest'
      }
      file {'winlogbeat.yml':
        ensure       => file,
        path         => $winlogbeat::real_config_file,
        content      => template($winlogbeat::real_conf_template),
        validate_cmd => "\"${winlogbeat_path}\" ${validate_subcommand} -c \"%\"",
        notify       => Service['winlogbeat'],
      }
    } # end Windows

    default : {
      fail($winlogbeat::kernel_fail_message)
    }
  }
}
