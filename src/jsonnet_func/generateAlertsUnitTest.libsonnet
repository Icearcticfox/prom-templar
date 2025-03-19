{
  generateAlertsUnitTest(groups):: {
    rule_files: [
      '../alerts/alerts.yaml',
    ],
    evaluation_interval: '1m',
    tests: [
      {
        interval: '1m',
        input_series: [
          series
          for series in rule.alert_rule_test.input_series
        ],
        alert_rule_test: [
          std.prune({
            eval_time: if std.objectHas(rule, 'for') then rule['for'] else null,
            alertname: rule.alert,
            exp_alerts: [
              {
                exp_annotations: rule.alert_rule_test.exp_annotations,
                exp_labels: rule.alert_rule_test.exp_labels,
              },
            ],
          }),
        ],
      }
      for group in groups
      for rule in group.rules
      if std.objectHas(rule, 'alert_rule_test')
    ],
  },
}
