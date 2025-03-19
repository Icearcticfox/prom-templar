local removeTestData(rules) =
  std.map(
    function(rule)
      if std.objectHas(rule, 'alert_rule_test') then
        rule { alert_rule_test:: null }
      else
        rule,
    rules
  );

{
  mergeRulesByName(groups):: {
    groups: std.foldl(
      function(acc, group)
        local existingGroups = std.filter(function(g) g.name == group.name, acc);
        if std.length(existingGroups) > 0 then
          std.map(
            function(g)
              if g.name == group.name then
                g { rules: removeTestData(g.rules) + removeTestData(group.rules) }
              else
                g,
            acc
          )
        else
          acc + [group { rules: removeTestData(group.rules) }],
      groups,
      []
    ),
  },
}
