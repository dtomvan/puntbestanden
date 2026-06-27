{ lib, ... }:
{
  groups = lib.singleton {
    name = "node";
    rules = [
      {
        alert = "diskspace";
        expr = ''node_filesystem_free_bytes{mountpoint="/"} < ${1024 * 1024 * 1024 * 5 |> toString}'';
        for = "0s";
        labels.severity = "warning";
        annotations = {
          summary = "{{$labels.instance}}: filesystem capacity below 5 GiB";
        };
      }

      {
        alert = "memory";
        expr = "avg_over_time(node_memory_MemAvailable_bytes[5m]) < ${1024 * 1024 * 500 |> toString}";
        for = "0s";
        labels.severity = "error";
        annotations = {
          summary = "{{$labels.instance}}: Memory available below 500 MiB on average in the last 5 minutes";
        };
      }

      # @bartoostveen from here on (except making use of indented strings)
      {
        alert = "NotUp";
        expr = ''
          up == 0
        '';
        for = "1m";
        labels.severity = "warning";
        annotations.summary = "scrape job {{ $labels.job }} is failing on {{ $labels.instance }}";
      }

      {
        alert = "HostOutOfMemory";
        annotations = {
          description = ''
            Node memory is filling up (< 10% left)
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host out of memory (instance {{ $labels.instance }})";
        };
        expr = "(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < .10)";
        for = "2m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostMemoryUnderMemoryPressure";
        annotations = {
          description = ''
            The node is under heavy memory pressure. High rate of major page faults ({{ $value }}/s).
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host memory under memory pressure (instance {{ $labels.instance }})";
        };
        expr = "(deriv(node_vmstat_pgmajfault[5m]) > 1000)";
        for = "0m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostUnusualNetworkThroughputIn";
        annotations = {
          description = ''
            Host receive bandwidth is high (>80%).
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host unusual network throughput in (instance {{ $labels.instance }})";
        };
        expr = "((rate(node_network_receive_bytes_total[5m]) / node_network_speed_bytes) > .80) and node_network_speed_bytes > 0";
        for = "0m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostUnusualNetworkThroughputOut";
        annotations = {
          description = ''
            Host transmit bandwidth is high (>80%)
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host unusual network throughput out (instance {{ $labels.instance }})";
        };
        expr = "((rate(node_network_transmit_bytes_total[5m]) / node_network_speed_bytes) > .80) and node_network_speed_bytes > 0";
        for = "0m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostDiskIoUtilizationHigh";
        annotations = {
          description = ''
            Disk utilization is high (> 80%)
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host disk IO utilization high (instance {{ $labels.instance }})";
        };
        expr = "(rate(node_disk_io_time_seconds_total[5m]) > .80)";
        for = "0m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostOutOfDiskSpace";
        annotations = {
          description = ''
            Disk is almost full (< 10% left)
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host out of disk space (instance {{ $labels.instance }})";
        };
        expr = "(node_filesystem_avail_bytes{fstype!~\"^(fuse.*|tmpfs|cifs|nfs)\"} / node_filesystem_size_bytes < .10 and on (instance, device, mountpoint) node_filesystem_readonly == 0)";
        for = "2m";
        labels = {
          severity = "critical";
        };
      }
      # {
      #   alert = "HostDiskMayFillIn24Hours";
      #   annotations = {
      #     description = ''
      #       Filesystem will likely run out of space within the next 24 hours.
      #         VALUE = {{ $value }}
      #         LABELS = {{ $labels }}'';
      #     summary = "Host disk may fill in 24 hours (instance {{ $labels.instance }})";
      #   };
      #   expr = "predict_linear(node_filesystem_avail_bytes{fstype!~\"^(fuse.*|tmpfs|cifs|nfs)\"}[3h], 86400) <= 0 and node_filesystem_avail_bytes > 0";
      #   for = "2m";
      #   labels = {
      #     severity = "warning";
      #   };
      # }
      {
        alert = "HostOutOfInodes";
        annotations = {
          description = ''
            Disk is almost running out of available inodes (< 10% left)
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host out of inodes (instance {{ $labels.instance }})";
        };
        expr = "(node_filesystem_files_free / node_filesystem_files < .10 and ON (instance, device, mountpoint) node_filesystem_readonly == 0) and node_filesystem_files > 0";
        for = "2m";
        labels = {
          severity = "critical";
        };
      }
      {
        alert = "HostFilesystemDeviceError";
        annotations = {
          description = ''
            Error stat-ing the {{ $labels.mountpoint }} filesystem
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host filesystem device error (instance {{ $labels.instance }})";
        };
        expr = "node_filesystem_device_error{fstype!~\"^(fuse.*|tmpfs|cifs|nfs)\"} == 1";
        for = "2m";
        labels = {
          severity = "critical";
        };
      }
      {
        alert = "HostUnusualDiskReadLatency";
        annotations = {
          description = ''
            Disk latency is growing (read operations > 100ms)
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host unusual disk read latency (instance {{ $labels.instance }})";
        };
        expr = "(rate(node_disk_read_time_seconds_total[1m]) / rate(node_disk_reads_completed_total[1m]) > 0.1 and rate(node_disk_reads_completed_total[1m]) > 0)";
        for = "2m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostUnusualDiskWriteLatency";
        annotations = {
          description = ''
            Disk latency is growing (write operations > 100ms)
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host unusual disk write latency (instance {{ $labels.instance }})";
        };
        expr = "(rate(node_disk_write_time_seconds_total[1m]) / rate(node_disk_writes_completed_total[1m]) > 0.1 and rate(node_disk_writes_completed_total[1m]) > 0)";
        for = "2m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostHighCpuLoad";
        annotations = {
          description = ''
            CPU load is > 80%
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host high CPU load (instance {{ $labels.instance }})";
        };
        expr = "1 - (avg without (cpu) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m]))) > .80";
        for = "10m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostCpuStealNoisyNeighbor";
        annotations = {
          description = ''
            CPU steal is > 10%. A noisy neighbor is killing VM performances or a spot instance may be out of credit.
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host CPU steal noisy neighbor (instance {{ $labels.instance }})";
        };
        expr = "avg without (cpu) (rate(node_cpu_seconds_total{mode=\"steal\"}[5m])) * 100 > 10";
        for = "0m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostCpuHighIowait";
        annotations = {
          description = ''
            CPU iowait > 10%. Your CPU is idling waiting for storage to respond.
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host CPU high iowait (instance {{ $labels.instance }})";
        };
        expr = "avg without (cpu) (rate(node_cpu_seconds_total{mode=\"iowait\"}[5m])) > .10";
        for = "0m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostUnusualDiskIo";
        annotations = {
          description = ''
            Disk usage >80%. Check storage for issues or increase IOPS capabilities.
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host unusual disk IO (instance {{ $labels.instance }})";
        };
        expr = "rate(node_disk_io_time_seconds_total[5m]) > 0.8";
        for = "5m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostContextSwitchingHigh";
        annotations = {
          description = ''
            Context switching is growing on the node (twice the daily average during the last 15m)
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host context switching high (instance {{ $labels.instance }})";
        };
        expr = "(rate(node_context_switches_total[15m])/count without(mode,cpu) (node_cpu_seconds_total{mode=\"idle\"})) / (rate(node_context_switches_total[1d])/count without(mode,cpu) (node_cpu_seconds_total{mode=\"idle\"})) > 2 and rate(node_context_switches_total[1d]) > 0";
        for = "0m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostSwapIsFillingUp";
        annotations = {
          description = ''
            Swap is filling up (>80%)
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host swap is filling up (instance {{ $labels.instance }})";
        };
        expr = "((1 - (node_memory_SwapFree_bytes / node_memory_SwapTotal_bytes)) * 100 > 80) and node_memory_SwapTotal_bytes > 0";
        for = "2m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostSystemdServiceCrashed";
        annotations = {
          description = ''
            systemd service {{ $labels.name }} crashed
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host systemd service crashed (instance {{ $labels.instance }})";
        };
        expr = "(node_systemd_unit_state{state=\"failed\"} == 1)";
        for = "0m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostPhysicalComponentTooHot";
        annotations = {
          description = ''
            Physical hardware component too hot
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host physical component too hot (instance {{ $labels.instance }})";
        };
        expr = "node_hwmon_temp_celsius > node_hwmon_temp_max_celsius";
        for = "5m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostNodeOvertemperatureAlarm";
        annotations = {
          description = ''
            Physical node temperature alarm triggered
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host node overtemperature alarm (instance {{ $labels.instance }})";
        };
        expr = "((node_hwmon_temp_crit_alarm_celsius == 1) or (node_hwmon_temp_alarm == 1))";
        for = "0m";
        labels = {
          severity = "critical";
        };
      }
      {
        alert = "HostSoftwareRaidInsufficientDrives";
        annotations = {
          description = ''
            MD RAID array {{ $labels.device }} on {{ $labels.instance }} has insufficient drives remaining.
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host software RAID insufficient drives (instance {{ $labels.instance }})";
        };
        expr = "((node_md_disks_required - ignoring(state) node_md_disks{state=\"active\"}) > 0)";
        for = "0m";
        labels = {
          severity = "critical";
        };
      }
      {
        alert = "HostSoftwareRaidDiskFailure";
        annotations = {
          description = ''
            MD RAID array {{ $labels.device }} on {{ $labels.instance }} needs attention.
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host software RAID disk failure (instance {{ $labels.instance }})";
        };
        expr = "(node_md_disks{state=\"failed\"} > 0)";
        for = "2m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostKernelVersionDeviations";
        annotations = {
          description = ''
            Kernel version for {{ $labels.instance }} has changed.
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host kernel version deviations (instance {{ $labels.instance }})";
        };
        expr = "changes(node_uname_info[1h]) > 0";
        for = "0m";
        labels = {
          severity = "info";
        };
      }
      {
        alert = "HostOomKillDetected";
        annotations = {
          description = ''
            OOM kill detected
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host OOM kill detected (instance {{ $labels.instance }})";
        };
        expr = "(delta(node_vmstat_oom_kill[30m]) > 0)";
        for = "0m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostEdacCorrectableErrorsDetected";
        annotations = {
          description = ''
            Host {{ $labels.instance }} has had {{ printf "%.0f" $value }} correctable memory errors reported by EDAC in the last 1 minute.
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host EDAC Correctable Errors detected (instance {{ $labels.instance }})";
        };
        expr = "(increase(node_edac_correctable_errors_total[1m]) > 0)";
        for = "0m";
        labels = {
          severity = "info";
        };
      }
      {
        alert = "HostEdacUncorrectableErrorsDetected";
        annotations = {
          description = ''
            Host {{ $labels.instance }} has had {{ printf "%.0f" $value }} uncorrectable memory errors reported by EDAC.
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host EDAC Uncorrectable Errors detected (instance {{ $labels.instance }})";
        };
        expr = "(node_edac_uncorrectable_errors_total > 0)";
        for = "0m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostNetworkReceiveErrors";
        annotations = {
          description = ''
            Host {{ $labels.instance }} interface {{ $labels.device }} has encountered {{ printf "%.0f" $value }} receive errors in the last two minutes.
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host Network Receive Errors (instance {{ $labels.instance }})";
        };
        expr = "(rate(node_network_receive_errs_total[2m]) / rate(node_network_receive_packets_total[2m]) > 0.01) and rate(node_network_receive_packets_total[2m]) > 0";
        for = "2m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostNetworkTransmitErrors";
        annotations = {
          description = ''
            Host {{ $labels.instance }} interface {{ $labels.device }} has encountered {{ printf "%.0f" $value }} transmit errors in the last two minutes.
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host Network Transmit Errors (instance {{ $labels.instance }})";
        };
        expr = "(rate(node_network_transmit_errs_total[2m]) / rate(node_network_transmit_packets_total[2m]) > 0.01) and rate(node_network_transmit_packets_total[2m]) > 0";
        for = "2m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostNetworkBondDegraded";
        annotations = {
          description = ''
            Bond "{{ $labels.device }}" degraded on "{{ $labels.instance }}".
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host Network Bond Degraded (instance {{ $labels.instance }})";
        };
        expr = "((node_bonding_active - node_bonding_slaves) != 0)";
        for = "2m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostConntrackLimit";
        annotations = {
          description = ''
            The number of conntrack is approaching limit
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host conntrack limit (instance {{ $labels.instance }})";
        };
        expr = "(node_nf_conntrack_entries / node_nf_conntrack_entries_limit > 0.8) and node_nf_conntrack_entries_limit > 0";
        for = "5m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostClockSkew";
        annotations = {
          description = ''
            Clock skew detected. Clock is out of sync. Ensure NTP is configured correctly on this host.
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host clock skew (instance {{ $labels.instance }})";
        };
        expr = "((node_timex_offset_seconds > 0.05 and deriv(node_timex_offset_seconds[5m]) >= 0) or (node_timex_offset_seconds < -0.05 and deriv(node_timex_offset_seconds[5m]) <= 0))";
        for = "10m";
        labels = {
          severity = "warning";
        };
      }
      {
        alert = "HostClockNotSynchronising";
        annotations = {
          description = ''
            Clock not synchronising. Ensure NTP is configured on this host.
              VALUE = {{ $value }}
              LABELS = {{ $labels }}'';
          summary = "Host clock not synchronising (instance {{ $labels.instance }})";
        };
        expr = "(min_over_time(node_timex_sync_status[1m]) == 0 and node_timex_maxerror_seconds >= 16)";
        for = "2m";
        labels = {
          severity = "warning";
        };
      }
    ];
  };
}
