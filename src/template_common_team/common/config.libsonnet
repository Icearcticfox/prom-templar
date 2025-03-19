local commonConfig = import '../../../src/jsonnet_func/config.libsonnet';

commonConfig {
  _config+:: {
    nodeExporterSelector: 'job="gce_node_exporter_discovery"',
    SystemdServiceFailedInstanceName: '',
  },
}
