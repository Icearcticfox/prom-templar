{
  prometheusRules+: {
    groups+: [
      {
        name: 'node-exporter.rules',
        rules: [
          {
            record: 'instance:node_num_cpu:sum',
            expr: 'count without (cpu, mode) (node_cpu_seconds_total{job="gce_node_exporter_discovery", mode="idle"})',
          },
          {
            record: 'instance:node_cpu_utilisation:rate5m',
            expr: '1 - avg without (cpu) (sum without (mode) (rate(node_cpu_seconds_total{job="gce_node_exporter_discovery", mode=~"idle|iowait|steal"}[5m])))',
          },
          {
            record: 'instance:node_load1_per_cpu:ratio',
            expr: '(node_load1{job="gce_node_exporter_discovery"} / instance:node_num_cpu:sum{job="gce_node_exporter_discovery"})',
          },
          {
            record: 'instance:node_memory_utilisation:ratio',
            expr: '1 - ((node_memory_MemAvailable_bytes{job="gce_node_exporter_discovery"} or (node_memory_Buffers_bytes{job="gce_node_exporter_discovery"} + node_memory_Cached_bytes{job="gce_node_exporter_discovery"} + node_memory_MemFree_bytes{job="gce_node_exporter_discovery"} + node_memory_Slab_bytes{job="gce_node_exporter_discovery"})) / node_memory_MemTotal_bytes{job="gce_node_exporter_discovery"})',
          },
          {
            record: 'instance:node_vmstat_pgmajfault:rate5m',
            expr: 'rate(node_vmstat_pgmajfault{job="gce_node_exporter_discovery"}[5m])',
          },
          {
            record: 'instance_device:node_disk_io_time_seconds:rate5m',
            expr: 'rate(node_disk_io_time_seconds_total{job="gce_node_exporter_discovery", device!=""}[5m])',
          },
          {
            record: 'instance_device:node_disk_io_time_weighted_seconds:rate5m',
            expr: 'rate(node_disk_io_time_weighted_seconds_total{job="gce_node_exporter_discovery", device!=""}[5m])',
          },
          {
            record: 'instance:node_network_receive_bytes_excluding_lo:rate5m',
            expr: 'sum without (device) (rate(node_network_receive_bytes_total{job="gce_node_exporter_discovery", device!="lo"}[5m]))',
          },
          {
            record: 'instance:node_network_transmit_bytes_excluding_lo:rate5m',
            expr: 'sum without (device) (rate(node_network_transmit_bytes_total{job="gce_node_exporter_discovery", device!="lo"}[5m]))',
          },
          {
            record: 'instance:node_network_receive_drop_excluding_lo:rate5m',
            expr: 'sum without (device) (rate(node_network_receive_drop_total{job="gce_node_exporter_discovery", device!="lo"}[5m]))',
          },
          {
            record: 'instance:node_network_transmit_drop_excluding_lo:rate5m',
            expr: 'sum without (device) (rate(node_network_transmit_drop_total{job="gce_node_exporter_discovery", device!="lo"}[5m]))',
          },
        ],
      },
    ],
  },
}
