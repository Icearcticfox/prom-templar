# Prom-templar

Unified repository for managing Prometheus alerts using Jsonnet templates. It provides a structured approach to defining, testing, and deploying alerting rules for different teams.

🚀 Key Features:
- Template-based Alerts: Uses Jsonnet for reusable and modular alert definitions  
-	Pre-commit Hooks: Ensures validation and formatting before commits  
-	Automated Unit Testing: Supports Prometheus unit tests for alert rules  
-	Team-Specific Configurations: Allows customization for different teams  
-	Docker-Based Execution: Simplifies alert generation and deployment with containerized workflows  

🛠 How It Works:
1.	Users define alerts in Jsonnet templates  
2.	Alerts are compiled into Prometheus-compatible YAML  
3.	Automated unit tests validate alert logic  
4.	A pre-commit hook ensures correctness before pushing to version control  
5.	YAML files are deployed to Prometheus for monitoring and alerting  

This toolkit streamlines alert management, ensures consistency, and improves the reliability of Prometheus-based monitoring setups.

* [Structure](#structure)
* [Installation](#installation)
  * [Installing pre-commit](#installing-pre-commit)
  * [Additional configuration](#additional-configuration)
  * [Unit tests](#unit-tests)
* [Usage](#usage)
  * [Creating a Project](#creating-a-project)
  * [Execution](#execution)
  * [Test environment](#test-environment)

## Structure

```markdown
|-- common_templates/
|-- src/
|-- teams/
```

* **common_templates** - Directory containing alert files written in Jsonnet.
* **src** - Code for scripts.
* **teams** - Directory containing team-specific configurations and alert parameters.

## Installation

Manual installation:

```bash
docker build --progress=plain -t jsonnet .
```

Pull Docker image:

```bash
docker pull jsonnet:latest
```

### Installing pre-commit

To install **pre-commit**, use the following command:

```bash
make install_pre_commit
```

If you do not have **Makefile** installed and do not want to install it, enter the following command:

```bash
pip install pre-commit && pre-commit install
```

### Additional Configuration

To add new alerts, create a new file in the `jsonnet_templates` directory.

Once created, you can add options to your `config.libsonnet` file:

```jsonnet
local commonConfig = import '../../config.libsonnet';

commonConfig {
  _config+:: {
    nodeExporterSelector: 'job="node_exporter"',
  },
}
```

You can also create new parameters and update them in the configuration file after creating a new alert.

### Unit Tests

[Explore the official documentation](https://prometheus.io/docs/prometheus/latest/configuration/unit_testing_rules/#test-yml)

To add unit tests to alerts, define a new `alert_rule_test` block in the alert definition.

* `exp_labels` - Expected labels when an alert is triggered.
* `exp_annotations` - Expected annotations.
* `input_series` - Data series used to validate the alert logic.

Example alert with a test:

```jsonnet
{
  alert: 'NodeFilesystemSpaceFillingUpWarn',
  expr: |||
    node_filesystem_avail_bytes{%(nodeExporterSelector)s,%(fsSelector)s} /
    node_filesystem_size_bytes{%(nodeExporterSelector)s,%(fsSelector)s} * 100 < %(nodeWarningDiskSpaceUsage)s
  ||| % $._config,
  'for': '1h',
  labels: {
    severity: '%(WarningSeverity)s' % $._config,
  },
  annotations: {
    summary: 'Filesystem is predicted to run out of space within the next 24 hours.',
    description: 'Filesystem on {{ $labels.device }}, mounted on {{ $labels.mountpoint }},
     at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available space left and is filling up.',
  },
  alert_rule_test: {
    exp_labels: $._config.unit_tests.node_exporter.exp_labels_warning,
    exp_annotations:
      {
        summary: 'Filesystem is predicted to run out of space within the next 24 hours.',
        description: 'Filesystem on '
                     + $._config.unit_tests.node_exporter.exp_labels.device
                     + ', mounted on '
                     + $._config.unit_tests.node_exporter.exp_labels.mountpoint
                     + ', at '
                     + $._config.unit_tests.node_exporter.exp_labels.instance
                     + ' has only 14.76% available space left and is filling up.',
      },
    input_series: [
      {
        series: 'node_filesystem_size_bytes{'
                + $._config.unit_tests.node_exporter.metric_labels
                + '}',
        values: '105588215808x60',
      },
      {
        series: 'node_filesystem_avail_bytes{'
                + $._config.unit_tests.node_exporter.metric_labels
                + '}',
        values: '15588215808x60',
      },
    ],
  },
}
```

After running the pre-commit script, a test file will be created in `teams/your_team/your_project/tests/tests.yaml`.
Tests run automatically when executing the pre-commit script and also in the CI pipeline.

## Usage

### Creating a Project

To create a project, execute the following command:

```bash
docker run -it --rm -v ./:/app jsonnet:latest create_project
```

You will need to enter two variables:

1. The project name within the `teams` directory.
2. (Optional) The project name in an external tracking system.

### Execution

Once the configurations and parameters are set, generate YAML files using:

```bash
docker run -it --rm -v ./:/app jsonnet:latest all
```

### Test Environment

If you have a test environment, create a `prometheus.txt` file and list test Prometheus instances, separated by commas:

```markdown
prometheus-instance-1, prometheus-instance-2
```
