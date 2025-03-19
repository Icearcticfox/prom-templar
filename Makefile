JSONNET_FMT := jsonnetfmt -n 2 --max-blank-lines 2 --string-style s --comment-style s


all: fmt lint alerts_rules_tests

fmt:
	@find . -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print | \
		xargs -n 1 -- $(JSONNET_FMT) -i
	@echo "\n------------------\n---FMT executed---\n------------------"

alerts_rules_tests:
	@for team_dir in $$dirs ; do \
		if [ -d "$$team_dir" ]; then \
			team_name=$$(basename $$(dirname $$team_dir)); \
			project_name=$$(basename $$team_dir); \
			echo "Creating alerts for team $$team_name, project $$project_name"; \
			jsonnet -S src/jsonnet_func/alerts.jsonnet --ext-str "TEAM_NAME=$${team_name}" --ext-str "PROJECT_NAME=$$project_name" > "$${team_dir}/alerts/alerts.yaml" || exit 1; \
			echo "Creating tests for team $$team_name, project $$project_name"; \
			jsonnet -S src/jsonnet_func/tests.jsonnet --ext-str "TEAM_NAME=$${team_name}" --ext-str "PROJECT_NAME=$$project_name" > "$${team_dir}/tests/tests.yaml" || exit 1; \
			if [ "$$(cat "$$team_dir/rules.libsonnet")" != '{}' ]; then \
				echo "Creating rules for team $$team_name, project $$project_name"; \
				jsonnet -S src/jsonnet_func/rules.jsonnet --ext-str "TEAM_NAME=$${team_name}" --ext-str "PROJECT_NAME=$${project_name}" > "$${team_dir}/rules/rules.yaml" || exit 1; \
			else \
				echo "Skipping project $$project_name because rules.libsonnet is empty."; \
			fi; \
		fi; \
	done

alerts.yaml:
	@for team_dir in teams/*/* ; do \
		if [ -d "$$team_dir" ]; then \
			team_name=$$(basename $$(dirname $$team_dir)); \
			project_name=$$(basename $$team_dir); \
			echo "Creating alerts for team $$team_name, project $$project_name" ; \
			jsonnet -S src/jsonnet_func/alerts.jsonnet --ext-str "TEAM_NAME=$${team_name}" --ext-str "PROJECT_NAME=$$project_name" > $${team_dir}/alerts/alerts.yaml || exit 1; \
		fi \
	done

tests.yaml:
	@for team_dir in teams/*/* ; do \
		if [ -d "$$team_dir" ]; then \
			team_name=$$(basename $$(dirname $$team_dir)); \
			project_name=$$(basename $$team_dir); \
			echo "Creating tests for team $$team_name, project $$project_name" ; \
			jsonnet -S src/jsonnet_func/tests.jsonnet --ext-str "TEAM_NAME=$${team_name}" --ext-str "PROJECT_NAME=$$project_name" > $${team_dir}/tests/tests.yaml || exit 1; \
		fi \
	done

rules.yaml:
	@for team_dir in teams/*/* ; do \
		if [ -d "$$team_dir" ]; then \
			team_name=$$(basename $$(dirname $$team_dir)); \
			project_name=$$(basename $$team_dir); \
			if [ "$$(cat $$team_dir/rules.libsonnet)" != '{}' ]; then \
				echo "Creating rules for team $$team_name, project $$project_name" ; \
				jsonnet -S src/jsonnet_func/rules.jsonnet --ext-str "TEAM_NAME=$${team_name}" --ext-str "PROJECT_NAME=$${project_name}" > $${team_dir}/rules/rules.yaml || exit 1; \
			else \
				echo "Skipping project $$project_name because rules.libsonnet is empty."; \
			fi \
		fi \
	done

lint:
	@find . -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print | \
		while read f; do \
			$(JSONNET_FMT) "$$f" | diff -u "$$f" -; \
		done

	@for team_dir in teams/*/* ; do \
		if [ -d "$$team_dir" ]; then \
			promtool check rules $${team_dir}/alerts/alerts.yaml || exit 1; \
			promtool check rules $${team_dir}/rules/rules.yaml || exit 1; \
		fi \
	done

unit_test:
	@find . -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print | \
		while read f; do \
			$(JSONNET_FMT) "$$f" | diff -u "$$f" -; \
		done

	@for team_dir in teams/*/* ; do \
		if [ -d "$$team_dir" ]; then \
			promtool test rules $${team_dir}/tests/tests.yaml || exit 1; \
		fi \
	done

.PHONY: jb_install
jb_install:
	jb install

install_pre_commit:
	@if ! command -v python3 &> /dev/null; then \
		echo "Error: Python is not installed. Please install Python."; \
	else \
		if ! command -v pre-commit &> /dev/null; then \
			echo "Pre-commit is not installed. Installing..."; \
			pip install pre-commit && pre-commit install; \
		else \
			echo "Pre-commit is already installed."; \
		fi \
	fi



create_project:
	@read -p "Write the name of your team: " TEAM; \
	read -p "Enter the project name: " PROJECT; \
	if [ -d ./teams/$$TEAM/$$PROJECT ]; then \
		echo "Project *$$PROJECT* already exists."; \
	else \
		mkdir -p ./teams/$$TEAM/$$PROJECT; \
		cp -r src/template_common_team/common/* teams/$$TEAM/$$PROJECT; \
		echo "Your project *$$PROJECT* has been created"; \
		python3 src/create_project/create_teams.py $$TEAM $$PROJECT; \
		jsonnetfmt src/create_project/teams.json > src/jsonnet_func/teams.libsonnet; \
		OS_TYPE=$$(uname -s); \
		if [ "$$OS_TYPE" = "Darwin" ]; then \
			sed -i '' 's/\"//g' src/jsonnet_func/teams.libsonnet; \
		else \
			sed -i 's/\"//g' src/jsonnet_func/teams.libsonnet; \
		fi; \
		declare -a paths=("alerts/alerts.yaml" "rules/rules.yaml" "tests/tests.yaml"); \
		for path in "$${paths[@]}"; do \
		  	func_name=$$(echo $$path | sed "s|/.*$$||"); \
			jsonnet -S src/jsonnet_func/$$func_name.jsonnet --ext-str "TEAM_NAME=$${TEAM}" --ext-str "PROJECT_NAME=$${PROJECT}" > ./teams/$${TEAM}/$${PROJECT}/$$path || exit 1; \
		done; \
	fi

clean:
	rm -rf  alerts.yaml
