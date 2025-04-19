# required
# Path to project folder
# example: /Users/fab1o/Developer/pimp
Z_PROJECT_FOLDER_1=/Users/admin/Developer/pimp-my-shell
Z_PROJECT_FOLDER_2=
Z_PROJECT_FOLDER_3=

# required
# Short name
# make it short, use abbreviation and one word only
# example: pimp
Z_PROJECT_SHORT_NAME_1=pimp
Z_PROJECT_SHORT_NAME_2=
Z_PROJECT_SHORT_NAME_3=

# required
# Repository uri (http or ssh)
Z_PROJECT_REPO_1=git@github.com:fab1o/pimp-my-shell.git
Z_PROJECT_REPO_2=
Z_PROJECT_REPO_3=

# optional
# default: npm
# Package manager for each project
# example: yarn
# example: pnpm
# example: bun
Z_PACKAGE_MANAGER_1=
Z_PACKAGE_MANAGER_2=
Z_PACKAGE_MANAGER_3=

# optional
# default: Z_PACKAGE_MANAGER run setup
# Command to run for alias `setup`
Z_SETUP_1=
Z_SETUP_2=
Z_SETUP_3=

# optional
# default: Z_PACKAGE_MANAGER run dev
# Command to run for alias: `run` or `run dev`
Z_RUN_1=
Z_RUN_2=
Z_RUN_3=

# optional
# default: Z_PACKAGE_MANAGER run stage
# Command to run for alias: `run stage`
Z_RUN_STAGE_1=
Z_RUN_STAGE_2=
Z_RUN_STAGE_3=

# optional
# default: Z_PACKAGE_MANAGER run prod
# Command to run for alias: `run prod`
Z_RUN_PROD_1=
Z_RUN_PROD_2=
Z_RUN_PROD_3=

# optional
# default: code
# Code editor for reviews
Z_CODE_EDITOR_1=
Z_CODE_EDITOR_2=
Z_CODE_EDITOR_3=

# optional
# default: empty
# Command to run after alias `clone`
# example: echo 'Clone completed!'
Z_CLONE_1=
Z_CLONE_2=
Z_CLONE_3=

# optional
# default: empty
# Command to run after `pro`
# example: nvm use 22
Z_PRO_1=
Z_PRO_2=
Z_PRO_3=

# optional
# default: Z_PACKAGE_MANAGER run test
# Command to run for alias `test`
Z_TEST_1=
Z_TEST_2=
Z_TEST_3=

# optional
# default: Z_PACKAGE_MANAGER run test:coverage
# Command to run for alias `cov`
Z_COV_1=
Z_COV_2=
Z_COV_3=

# optional
# default: Z_PACKAGE_MANAGER run test:watch
# Command to run for alias `testw`
Z_TEST_WATCH_1=
Z_TEST_WATCH_2=
Z_TEST_WATCH_3=

# optional
# default: Z_PACKAGE_MANAGER run test:e2e
# Command to run for alias `e2e`
Z_E2E_1=
Z_E2E_2=
Z_E2E_3=

# optional
# default: Z_PACKAGE_MANAGER run test:e2e-ui
# Command to run for alias `e2eui`
Z_E2EUI_1=
Z_E2EUI_2=
Z_E2EUI_3=

# optional
# default: empty
# pull request template of each project.
# example: .github/pull_request_template.md
Z_PR_TEMPLATE_1=
Z_PR_TEMPLATE_2=
Z_PR_TEMPLATE_3=

# optional
# default: empty
# text to be matched in the PR template to append commit messages with command: pr
# example: Description:
Z_PR_REPLACE_1=
Z_PR_REPLACE_2=
Z_PR_REPLACE_3=

# optional
# default: 0
# 1 to append commit messages after Z_PR_REPLACE or 0 to replace it.
Z_PR_APPEND_1=0
Z_PR_APPEND_2=0
Z_PR_APPEND_3=0

# optional
# default: 0
# 1 to run tests before pushing code and creating a pr or 0 to not run tests. If tests fail, pr is aborted.
Z_PR_RUN_TEST_1=0
Z_PR_RUN_TEST_2=0
Z_PR_RUN_TEST_3=0

# optional
# default: 30 minutes
# set to 0 to stop interval
# Interval to run `gha` in minutes
Z_GHA_INTERVAL_1=
Z_GHA_INTERVAL_2=
Z_GHA_INTERVAL_3=
