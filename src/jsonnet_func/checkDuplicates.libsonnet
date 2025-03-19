{
  checkDuplicates(groups, type)::
    local duplicatesInfo = std.foldl(
      function(acc, group)
        local names = if type == 'alert' then
          std.map(function(r) r.alert, group.rules)
        else if type == 'record' then
          std.map(function(r) r.record, group.rules)
        else
          error 'Unsupported type: ' + type;
        local duplicates = std.filter(
          function(name) std.count(names, name) > 1,
          std.set(names)
        );
        if std.length(duplicates) > 0 then
          acc + [{ group: group.name, type: type, duplicates: duplicates }]
        else
          acc,
      groups,
      []
    );

    if std.length(duplicatesInfo) > 0 then
      error 'Duplicate names found: ' + std.toString(duplicatesInfo)
    else
      groups,
}
