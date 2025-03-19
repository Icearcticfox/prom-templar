import argparse
import json
import os


def create_project(team_name, project_name):
    team_imports_json = './src/create_project/teams.json'

    if os.path.isfile(team_imports_json):
        with open(team_imports_json, 'r') as f:
            data = json.load(f)
    else:
        data = {"teamImports": {}}

    if team_name not in data["teamImports"]:
        data["teamImports"][team_name] = {}

    if project_name in data["teamImports"][team_name]:
        print(f"Project *{project_name}* in team *{team_name}* already exists.")
    else:
        data["teamImports"][team_name][project_name] = {
            "config": f"(import '../../teams/{team_name}/{project_name}/config.libsonnet')",
            "alerts": f"(import '../../teams/{team_name}/{project_name}/alerts.libsonnet')",
            "rules": f"(import '../../teams/{team_name}/{project_name}/rules.libsonnet')"
        }

        with open(team_imports_json, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"The project *{project_name}* in team *{team_name}* is configured in the teams file.")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("team_name", type=str, help="Name of the team")
    parser.add_argument("project_name", type=str, help="Name of the project within the team")
    args = parser.parse_args()

    create_project(args.team_name, args.project_name)


if __name__ == '__main__':
    main()
