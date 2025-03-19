local teamName = std.extVar('TEAM_NAME');
local projectName = std.extVar('PROJECT_NAME');
local teamConfig = (import 'teams.libsonnet').teamImports;

local selectedTeam = teamConfig[teamName];
local selectedProject = selectedTeam[projectName];

// Functions
local mergeAlertsRules = import './mergeAlertsRules.libsonnet';
local generateAlertsUnitTest = import './generateAlertsUnitTest.libsonnet';
local checkDuplicates = import './checkDuplicates.libsonnet';

local prometheusAlerts = {
  prometheusAlerts+:: {
    groups+: [],
  },
};

local prometheusRules = {
  prometheusRules+:: {
    groups+: [],
  },
};


local alertsImport = prometheusAlerts + selectedProject.alerts + selectedProject.config;
local rulesImport = prometheusRules + selectedProject.rules + selectedProject.config;


local mergeAlerts = {
  prometheusAlerts: mergeAlertsRules.mergeRulesByName(alertsImport.prometheusAlerts.groups),
};

local generateTests = generateAlertsUnitTest.generateAlertsUnitTest(alertsImport.prometheusAlerts.groups);

local mergeRules = {
  prometheusRules: mergeAlertsRules.mergeRulesByName(rulesImport.prometheusRules.groups),
};


if std.objectHas(teamConfig, teamName) && std.objectHas(selectedTeam, projectName) then
  {
    prometheusAlerts:
      {
        groups: checkDuplicates.checkDuplicates(mergeAlerts.prometheusAlerts.groups, 'alert'),
      },
  }
  {
    prometheusRules:
      {
        groups: checkDuplicates.checkDuplicates(rulesImport.prometheusRules.groups, 'record'),
      },
  }
  {
    prometheusTests: generateTests,
  }
else
  error ('Unknown team or project: ' + teamName + '/' + projectName)
