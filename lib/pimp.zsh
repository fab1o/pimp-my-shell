# General
alias cl="tput reset"
alias hg="history | grep" # $1
alias ll="ls -lAF"
alias nver="node -e 'console.log(process.version, process.arch, process.platform)'"
alias nlist="npm list --global --depth=0"
alias path="echo $PATH"

kill() {
	if [[ -z "$1" ]]; then
		echo " kill port: \e[93mkill <port>\e[0m"
		return 0;
	fi

	npx kill-port $1
}

refresh() {
	if [ -f "$HOME/.zshrc" ]; then
		source "$HOME/.zshrc"
	fi
}

upgrade() {
	if command -v omz &> /dev/null; then
		omz update
	fi
	if command -v oh-my-posh &> /dev/null; then
		oh-my-posh upgrade
	fi
}


confirm_from_() {
	if command -v gum &> /dev/null; then
		if gum confirm ""confirm:$'\e[0m'" $1" --no-show-help; then
			return 0;
		else
			return 1;
		fi
	else
		if read -qs "?"$'\e[38;5;141m'confirm:$'\e[0m'" $1 (y/n) "; then
	  	echo "y"
	  	return 0;
	  else
	  	echo "n"
	  	return 1;
  	fi
  fi
}

choose_one_() {
	# "$'\e[38;5;141m'$SHORTEN_FOLDER$'\e[0m'"

	# if command -v gum &> /dev/null; then
	echo "$(gum choose --limit=1 --height 20 --header " $1" ${@:2})"
	# 	return 0;
	# fi
	
  # PS3=${1-"choose: "}
  # select CHOICE in "$@" "quit"; do
  # 	case $CHOICE in
	# 	  "quit")
	#       return 1
	#       ;;
	# 	  *)
	#       echo "$CHOICE"
	#       return 0
	#       ;;
  #   esac
	# done
}

choose_auto_one_() {
	# if command -v gum &> /dev/null; then
	echo "$(gum choose --limit=1 --select-if-one --height 20 --header " $1" ${@:2})"
		# return 0;
	# fi
	
  # PS3=${1-"choose: "}
  # select CHOICE in "$@" "quit"; do
  # 	case $CHOICE in
	# 	  "quit")
	#       return 1
	#       ;;
	# 	  *)
	#       echo "$CHOICE"
	#       return 0
	#       ;;
  #   esac
	# done
}

# Deleting a path
del() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mdel\e[0m : to select folders in $PWD to delete"
		echo " \e[93mdel -a\e[0m : to delete all folders at once in $PWD"
		echo " \e[93mdel <path>\e[0m : to delete a folder or file"
		echo " \e[93mdel <path> -s\e[0m : to skip confirmation"
		return 0;
	fi

	if ! command -v gum &> /dev/null; then
		echo " fatal: del requires gum"
		echo " install gum: \e[93mhttps://github.com/charmbracelet/gum\e[0m"
		return 0;
	fi

	if [[ -z "$1" ]]; then
		# "*/" is to list only folders
		ls -d */ | sed 's:/$::' | gum choose --no-limit | xargs -r -I {} gum spin --title " deleting... {}" -- rm -rf "{}"
		ls
		return 0;
	fi

	if [[ "$1" == "-a" ]]; then
		if ! confirm_from_ "delete all folders in "$'\e[94m'$(PWD)$'\e[0m'"?"; then
			return 0;
		fi

		for i in */; do
			gum spin --title " deleting... ${i%/}" -- rm -rf "${i%/}"
		done
		
		return 0;
	fi

	local FILE_PATH=$(realpath "${1/#\~/$HOME}") # also works: "${1/#\~/$HOME}"
	if [ $? -ne 0 ]; then return 1; fi

	if [[ -z "$FILE_PATH" || ! -e "$FILE_PATH" ]]; then
		return 1;
	fi

	local CONFIRM_MSG="";
	local FLAG=0;
	local FLAG_2="$(dirname -- "$FILE_PATH")"

	if [[ "$FILE_PATH" == "$(PWD)" ]]; then
		FLAG=1
		CONFIRM_MSG="delete current path?";
	else
		CONFIRM_MSG="delete "$'\e[94m'$FILE_PATH$'\e[0m'"?";
	fi

	if [[ "$2" != "-s" && -n "$(ls -A "$FILE_PATH")" ]]; then
		if ! confirm_from_ $CONFIRM_MSG; then
			return 0;
		fi
	fi

	if [[ "$FLAG_2" == "." ]]; then
		gum spin --title " deleting... $FILE_PATH" -- rm -rf "$FILE_PATH"
		echo "\e[95mls $(shorten_path_)\e[0m"
		ls
	else
		local PARENT_FOLDER=$(dirname "$1")
		if [ $? -ne 0 ]; then return 1; fi

		local PARENT_PATH=$(realpath "${PARENT_FOLDER/#\~/$HOME}")
		if [ $? -ne 0 ]; then return 1; fi

		gum spin --title " deleting... $FILE_PATH" -- rm -rf "$FILE_PATH"
		echo "\e[95mls $(shorten_path_ $PARENT_PATH)\e[0m"

		if [[ $FLAG -eq 1 ]]; then
			cd "$PARENT_PATH"
			ls
		else
			ls "$PARENT_PATH"
		fi
	fi
}

# ========================================================================
# Project configuration
local Z_FAB1O_CFG="$(dirname "$0")/../config/pimp2.zshenv"
local Z_FAB1O_PRO="$(dirname "$0")/.pimp"
local VERSION=$(cat "$(dirname "$0")/.version")
# ========================================================================

# project 1 ==============================================================
local Z_PROJECT_FOLDER_1=""
local Z_PROJECT_FOLDER_1_=$(sed -n 's/^Z_PROJECT_FOLDER_1=\([^ ]*\)/\1/p' "$Z_FAB1O_CFG"); Z_PROJECT_FOLDER_1_="${Z_PROJECT_FOLDER_1_/#\~/$HOME}"
if [[ -n "$Z_PROJECT_FOLDER_1_" ]]; then
	Z_PROJECT_FOLDER_1=$(realpath $Z_PROJECT_FOLDER_1_);
	if [ $? -ne 0 ]; then
		mkdir -p $Z_PROJECT_FOLDER_1_
		if [ $? -eq 0 ]; then
			Z_PROJECT_FOLDER_1=$(realpath $Z_PROJECT_FOLDER_1_);
			echo "\e[38;5;218m created folder: $Z_PROJECT_FOLDER_1_\e[0m"
			echo " type \e[93mhelp\e[0m for more"
		fi
	fi
fi
local Z_PROJECT_SHORT_NAME_1=$(sed -n 's/^Z_PROJECT_SHORT_NAME_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_PROJECT_REPO_1=$(sed -n 's/^Z_PROJECT_REPO_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_PACKAGE_MANAGER_1=${$(sed -n 's/^Z_PACKAGE_MANAGER_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-npm}
local Z_CODE_EDITOR_1=${$(sed -n 's/^Z_CODE_EDITOR_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-code}
local Z_CLONE_1=$(sed -n 's/^Z_CLONE_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_SETUP_1=${$(sed -n 's/^Z_SETUP_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_1 $([[ $Z_PACKAGE_MANAGER_1 == "yarn" ]] && echo "" || echo "run ")setup}
local Z_RUN_1=${$(sed -n 's/^Z_RUN_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_1 $([[ $Z_PACKAGE_MANAGER_1 == "yarn" ]] && echo "" || echo "run ")dev}
# local Z_RUN_DEV_1=${$(sed -n 's/^Z_RUN_DEV_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_1 $([[ $Z_PACKAGE_MANAGER_1 == "yarn" ]] && echo "" || echo "run ")dev}
local Z_RUN_STAGE_1=${$(sed -n 's/^Z_RUN_STAGE_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_1 $([[ $Z_PACKAGE_MANAGER_1 == "yarn" ]] && echo "" || echo "run ")stage}
local Z_RUN_PROD_1=${$(sed -n 's/^Z_RUN_PROD_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_1 $([[ $Z_PACKAGE_MANAGER_1 == "yarn" ]] && echo "" || echo "run ")prod}
local Z_PRO_1=$(sed -n 's/^Z_PRO_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_TEST_1=${$(sed -n 's/^Z_TEST_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_1 $([[ $Z_PACKAGE_MANAGER_1 == "yarn" ]] && echo "" || echo "run ")test}
local Z_COV_1=${$(sed -n 's/^Z_COV_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_1 $([[ $Z_PACKAGE_MANAGER_1 == "yarn" ]] && echo "" || echo "run ")test:coverage}
local Z_TEST_WATCH_1=${$(sed -n 's/^Z_TEST_WATCH_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_1 $([[ $Z_PACKAGE_MANAGER_1 == "yarn" ]] && echo "" || echo "run ")test:watch}
local Z_E2E_1=${$(sed -n 's/^Z_E2E_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_1 $([[ $Z_PACKAGE_MANAGER_1 == "yarn" ]] && echo "" || echo "run ")test:e2e}
local Z_E2EUI_1=${$(sed -n 's/^Z_E2EUI_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_1 $([[ $Z_PACKAGE_MANAGER_1 == "yarn" ]] && echo "" || echo "run ")test:e2e-ui}
local Z_PR_TEMPLATE_1=$(sed -n 's/^Z_PR_TEMPLATE_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_PR_REPLACE_1=$(sed -n 's/^Z_PR_REPLACE_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_PR_APPEND_1=${$(sed -n 's/^Z_PR_APPEND_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-0}
local Z_PR_RUN_TEST_1=${$(sed -n 's/^Z_PR_RUN_TEST_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-0}
local Z_GHA_INTERVAL_1=${$(sed -n 's/^Z_GHA_INTERVAL_1=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-30}

# project 2 ========================================================================
local Z_PROJECT_FOLDER_2=""
local Z_PROJECT_FOLDER_2_=$(sed -n 's/^Z_PROJECT_FOLDER_2=\([^ ]*\)/\1/p' "$Z_FAB1O_CFG"); Z_PROJECT_FOLDER_2_="${Z_PROJECT_FOLDER_2_/#\~/$HOME}"
if [[ -n "$Z_PROJECT_FOLDER_2_" ]]; then
	Z_PROJECT_FOLDER_2=$(realpath $Z_PROJECT_FOLDER_2_);
	if [ $? -ne 0 ]; then
		mkdir -p $Z_PROJECT_FOLDER_2_
		if [ $? -eq 0 ]; then
			Z_PROJECT_FOLDER_2=$(realpath $Z_PROJECT_FOLDER_2_);
			echo "\e[38;5;218m created folder: $Z_PROJECT_FOLDER_2_\e[0m"
			echo " type \e[93mhelp\e[0m for more"
		fi
	fi
fi
local Z_PROJECT_SHORT_NAME_2=$(sed -n 's/^Z_PROJECT_SHORT_NAME_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_PROJECT_REPO_2=$(sed -n 's/^Z_PROJECT_REPO_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_PACKAGE_MANAGER_2=${$(sed -n 's/^Z_PACKAGE_MANAGER_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-npm};
local Z_CODE_EDITOR_2=${$(sed -n 's/^Z_CODE_EDITOR_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-code}
local Z_CLONE_2=$(sed -n 's/^Z_CLONE_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_SETUP_2=${$(sed -n 's/^Z_SETUP_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_2 $([[ $Z_PACKAGE_MANAGER_2 == "yarn" ]] && echo "" || echo "run ")setup}
local Z_RUN_2=${$(sed -n 's/^Z_RUN_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_2 $([[ $Z_PACKAGE_MANAGER_2 == "yarn" ]] && echo "" || echo "run ")dev}
# local Z_RUN_DEV_2=${$(sed -n 's/^Z_RUN_DEV_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_2 $([[ $Z_PACKAGE_MANAGER_2 == "yarn" ]] && echo "" || echo "run ")dev}
local Z_RUN_STAGE_2=${$(sed -n 's/^Z_RUN_STAGE_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_2 $([[ $Z_PACKAGE_MANAGER_2 == "yarn" ]] && echo "" || echo "run ")stage}
local Z_RUN_PROD_2=${$(sed -n 's/^Z_RUN_PROD_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_2 $([[ $Z_PACKAGE_MANAGER_2 == "yarn" ]] && echo "" || echo "run ")prod}
local Z_PRO_2=$(sed -n 's/^Z_PRO_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_TEST_2=${$(sed -n 's/^Z_TEST_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_2 $([[ $Z_PACKAGE_MANAGER_2 == "yarn" ]] && echo "" || echo "run ")test}
local Z_COV_2=${$(sed -n 's/^Z_COV_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_2 $([[ $Z_PACKAGE_MANAGER_2 == "yarn" ]] && echo "" || echo "run ")test:coverage}
local Z_TEST_WATCH_2=${$(sed -n 's/^Z_TEST_WATCH_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_2 $([[ $Z_PACKAGE_MANAGER_2 == "yarn" ]] && echo "" || echo "run ")test:watch}
local Z_E2E_2=${$(sed -n 's/^Z_E2E_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_2 $([[ $Z_PACKAGE_MANAGER_2 == "yarn" ]] && echo "" || echo "run ")test:e2e}
local Z_E2EUI_2=${$(sed -n 's/^Z_E2EUI_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_2 $([[ $Z_PACKAGE_MANAGER_2 == "yarn" ]] && echo "" || echo "run ")test:e2e-ui}
local Z_PR_TEMPLATE_2=$(sed -n 's/^Z_PR_TEMPLATE_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_PR_REPLACE_2=$(sed -n 's/^Z_PR_REPLACE_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_PR_APPEND_2=${$(sed -n 's/^Z_PR_APPEND_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-0}
local Z_PR_RUN_TEST_2=${$(sed -n 's/^Z_PR_RUN_TEST_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-0}
local Z_GHA_INTERVAL_2=${$(sed -n 's/^Z_GHA_INTERVAL_2=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-30}

# project 3 ========================================================================
local Z_PROJECT_FOLDER_3=""
local Z_PROJECT_FOLDER_3_=$(sed -n 's/^Z_PROJECT_FOLDER_3=\([^ ]*\)/\1/p' "$Z_FAB1O_CFG"); Z_PROJECT_FOLDER_3_="${Z_PROJECT_FOLDER_3_/#\~/$HOME}"
if [[ -n "$Z_PROJECT_FOLDER_3_" ]]; then
	Z_PROJECT_FOLDER_3=$(realpath $Z_PROJECT_FOLDER_3_);
	if [ $? -ne 0 ]; then
		mkdir -p $Z_PROJECT_FOLDER_3_
		if [ $? -eq 0 ]; then
			Z_PROJECT_FOLDER_3=$(realpath $Z_PROJECT_FOLDER_3_);
			echo "\e[38;5;218m created folder: $Z_PROJECT_FOLDER_3_\e[0m"
			echo " type \e[93mhelp\e[0m for more"
		fi
	fi
fi
local Z_PROJECT_SHORT_NAME_3=$(sed -n 's/^Z_PROJECT_SHORT_NAME_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_PROJECT_REPO_3=$(sed -n 's/^Z_PROJECT_REPO_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_PACKAGE_MANAGER_3=${$(sed -n 's/^Z_PACKAGE_MANAGER_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-npm};
local Z_CODE_EDITOR_3=${$(sed -n 's/^Z_CODE_EDITOR_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-code}
local Z_CLONE_3=$(sed -n 's/^Z_CLONE_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_SETUP_3=${$(sed -n 's/^Z_SETUP_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_3 $([[ $Z_PACKAGE_MANAGER_3 == "yarn" ]] && echo "" || echo "run ")setup}
local Z_RUN_3=${$(sed -n 's/^Z_RUN_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_3 $([[ $Z_PACKAGE_MANAGER_3 == "yarn" ]] && echo "" || echo "run ")dev}
# local Z_RUN_DEV_3=${$(sed -n 's/^Z_RUN_DEV_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_3 $([[ $Z_PACKAGE_MANAGER_3 == "yarn" ]] && echo "" || echo "run ")dev}
local Z_RUN_STAGE_3=${$(sed -n 's/^Z_RUN_STAGE_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_3 $([[ $Z_PACKAGE_MANAGER_3 == "yarn" ]] && echo "" || echo "run ")stage}
local Z_RUN_PROD_3=${$(sed -n 's/^Z_RUN_PROD_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_3 $([[ $Z_PACKAGE_MANAGER_3 == "yarn" ]] && echo "" || echo "run ")prod}
local Z_PRO_3=$(sed -n 's/^Z_PRO_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_TEST_3=${$(sed -n 's/^Z_TEST_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_3 $([[ $Z_PACKAGE_MANAGER_3 == "yarn" ]] && echo "" || echo "run ")test}
local Z_COV_3=${$(sed -n 's/^Z_COV_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_3 $([[ $Z_PACKAGE_MANAGER_3 == "yarn" ]] && echo "" || echo "run ")test:coverage}
local Z_TEST_WATCH_3=${$(sed -n 's/^Z_TEST_WATCH_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_3 $([[ $Z_PACKAGE_MANAGER_3 == "yarn" ]] && echo "" || echo "run ")test:watch}
local Z_E2E_3=${$(sed -n 's/^Z_E2E_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_3 $([[ $Z_PACKAGE_MANAGER_3 == "yarn" ]] && echo "" || echo "run ")test:e2e}
local Z_E2EUI_3=${$(sed -n 's/^Z_E2EUI_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-$Z_PACKAGE_MANAGER_3 $([[ $Z_PACKAGE_MANAGER_3 == "yarn" ]] && echo "" || echo "run ")test:e2e-ui}
local Z_PR_TEMPLATE_3=$(sed -n 's/^Z_PR_TEMPLATE_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_PR_REPLACE_3=$(sed -n 's/^Z_PR_REPLACE_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG)
local Z_PR_APPEND_3=${$(sed -n 's/^Z_PR_APPEND_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-0}
local Z_PR_RUN_TEST_3=${$(sed -n 's/^Z_PR_RUN_TEST_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-0}
local Z_GHA_INTERVAL_3=${$(sed -n 's/^Z_GHA_INTERVAL_3=\([^ ]*\)/\1/p' $Z_FAB1O_CFG):-30}

local Z_PROJECT_FOLDER=""
local Z_PROJECT_SHORT_NAME=""
local Z_PROJECT_REPO=""
local Z_PACKAGE_MANAGER=""
local Z_CODE_EDITOR=""
local Z_CLONE=""
local Z_SETUP=""
local Z_RUN=""
# local Z_RUN_DEV=""
local Z_RUN_STAGE=""
local Z_RUN_PROD=""
local Z_PRO=""
local Z_TEST=""
local Z_COV=""
local Z_TEST_WATCH=""
local Z_E2E=""
local Z_E2EUI=""
local Z_PR_TEMPLATE=""
local Z_PR_REPLACE=""
local Z_PR_APPEND=""
local Z_PR_RUN_TEST=""
local Z_GHA_INTERVAL=""

local PAST_BRANCH=""

local ERROR_PROJ_1=0;

local TITLE_COR="\e[37m"
local COMMAND_COR="\e[33m"
local PROJECT_COR="\e[34m"
local PROJECT_COR_2="\e[94m"
local PACKAGE_COR="\e[35m"
local PACKAGE_COR_2="\e[95m" #$'\e[38;5;141m'
local CODE_REVIEW="\e[96m"
local GIT_COR="\e[36m"
local PURPLE="\e[1;95m"
local BOLD="\e[1;37m"

hello() {
	echo "pimp my shell!"
}

help() {

	local total_width=69 # do not change this! it will mess with version display

	help_line() {
		local word=$1
		local color=${2:-"250"}

		if ! command -v gum &> /dev/null; then
			echo "$TITLE_COR -- $word ----------------------------------------------------- \e[0m"
			return 0;
		fi

		# Calculate how much space is needed on each side
		local word_length=${#word}
		local padding=$(( (total_width - word_length - 2) / 2 ))  # -2 for spaces around word

		# Generate the line
		local line="$(printf '%*s' "$padding" '' | tr ' ' '─') $word $(printf '%*s' "$padding" '' | tr ' ' '─')"

		# If word length is odd, line may be short by 1 — pad one more dash
		[ ${#line} -lt $total_width ] && line="$line─"

		# Display with gum
		gum style --foreground="$color" --border=none --padding="0 1" "$line"
	}
	#tput reset

	if command -v gum &> /dev/null; then
		gum style --border=rounded --margin="0" --padding="1 16" --border-foreground="212" --width="$total_width" \
			--align=center "welcome to $(gum style --foreground 212 "fab1o's pimp my shell! v$VERSION")"
	fi
	
	echo ""
	help_line "general"
	echo " $COMMAND_COR cl \e[0m\t\t = clear"
	echo " $COMMAND_COR del \e[0m\t\t = delete utility"
	echo " $COMMAND_COR help \e[0m\t\t = show help"
	echo " $COMMAND_COR hg \$1 \e[0m\t = history | grep"
	echo " $COMMAND_COR kill \$1 \e[0m\t = kill port"
	echo " $COMMAND_COR ll \e[0m\t\t = ls -laF"
	echo " $COMMAND_COR nver \e[0m\t\t = node version"
	echo " $COMMAND_COR nlist \e[0m\t = npm list global"
	echo " $COMMAND_COR path \e[0m\t\t = echo \$PATH"
	echo " $COMMAND_COR refresh \e[0m\t = source .zshrc"
	echo " $COMMAND_COR upgrade \e[0m\t = upgrade zsh + omp"

	if [ "$ERROR_PROJ_1" -eq 1 ]; then
		echo ""
		echo "\e[31mAlert: At least one project must be configured!\e[0m"
		echo ""
		echo " edit \e[33m.zfab1ocfg\e[0m as shown in the example below:"
		echo ""
		echo "  Z_PROJECT_FOLDER_1=\e[38;5;141m/Users/fab1o/Developer/pimp-my-shell\e[0m"
		echo "  Z_PROJECT_SHORT_NAME_1=\e[38;5;141mpimp\e[0m"
		echo "  Z_PROJECT_REPO_1=\e[38;5;141mgit@github.com:fab1o/pimp-my-shell.git\e[0m"
		echo ""
		echo " then restart your terminal"
		return 0;
	fi
	
	echo ""
	help_line "get started" 212

	echo ""
	echo "  1.\e[38;5;218m clone\e[0m project, type$PROJECT_COR_2 clone -h\e[0m for help"
	echo "  2.\e[38;5;218m setup\e[0m project, type$PROJECT_COR_2 setup -h\e[0m for help"
	echo "  3.\e[38;5;218m run\e[0m a project, type$PROJECT_COR_2 run -h\e[0m for help"
	# echo ""
	# help_line "code reviews"

	# echo ""
	# echo "  1. open a review, type$PROJECT_COR_2 rev -h\e[0m for help"
	# echo "  2. list reviews, type$PROJECT_COR_2 revs -h\e[0m for help"
	echo ""
	help_line "project selection"
	echo " $PROJECT_COR_2 pro \e[0m\t\t = set project"

	if [[ -n "$Z_PROJECT_FOLDER_1" && -n "$Z_PROJECT_SHORT_NAME_1" ]] then
		echo " $PROJECT_COR_2 $Z_PROJECT_SHORT_NAME_1 \e[0m$([ ${#Z_PROJECT_SHORT_NAME_1} -lt 5 ] && echo -e "\t\t = set project and open /$(shorten_path_ "$Z_PROJECT_FOLDER_1" short)" || echo -e "\t = set project and open /$(shorten_path_ "$Z_PROJECT_FOLDER_1" short)")";
	fi
	if [[ -n "$Z_PROJECT_FOLDER_2" && -n "$Z_PROJECT_SHORT_NAME_2" ]] then
		echo " $PROJECT_COR_2 $Z_PROJECT_SHORT_NAME_2 \e[0m$([ ${#Z_PROJECT_SHORT_NAME_2} -lt 5 ] && echo -e "\t\t = set project and open /$(shorten_path_ "$Z_PROJECT_FOLDER_2" short)" || echo -e "\t = set project and open /$(shorten_path_ "$Z_PROJECT_FOLDER_2" short)")";
	fi
	if [[ -n "$Z_PROJECT_FOLDER_3" && -n "$Z_PROJECT_SHORT_NAME_3" ]] then
		echo " $PROJECT_COR_2 $Z_PROJECT_SHORT_NAME_3 \e[0m$([ ${#Z_PROJECT_SHORT_NAME_3} -lt 5 ] && echo -e "\t\t = set project and open /$(shorten_path_ "$Z_PROJECT_FOLDER_3" short)" || echo -e "\t = set project and open /$(shorten_path_ "$Z_PROJECT_FOLDER_3" short)")";
	fi

	echo ""
	help_line "project"
	echo " $PROJECT_COR clone \e[0m\t = clone project or branch"
	echo " $PROJECT_COR setup \e[0m\t = $((( ${#Z_SETUP} > 47 )) && echo "${Z_SETUP[1,47]}..." || echo $Z_SETUP)"
	echo " $PROJECT_COR run \e[0m\t\t = $((( ${#Z_RUN} > 47 )) && echo "${Z_RUN[1,47]}..." || echo $Z_RUN)"
	echo " $PROJECT_COR run stage \e[0m\t = $((( ${#Z_RUN_STAGE} > 47 )) && echo "${Z_RUN_STAGE[1,47]}..." || echo $Z_RUN_STAGE)"
	echo " $PROJECT_COR run prod \e[0m\t = $((( ${#Z_RUN_PROD} > 47 )) && echo "${Z_RUN_PROD[1,47]}..." || echo $Z_RUN_PROD)"
	echo ""
	help_line "code review"
	echo " $CODE_REVIEW rev \e[0m\t\t = select branch to review"
	echo " $CODE_REVIEW rev \$1\e[0m\t = open review"
	echo " $CODE_REVIEW revs \e[0m\t\t = list local reviews"

	echo ""
	help_line "$Z_PACKAGE_MANAGER"
	echo " $PACKAGE_COR build \e[0m\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")build"
	echo " $PACKAGE_COR deploy \e[0m\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")deploy"
	echo " $PACKAGE_COR fix \e[0m\t\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")lint + format"
	echo " $PACKAGE_COR format \e[0m\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")format"
	echo " $PACKAGE_COR i \e[0m\t\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")install"
	echo " $PACKAGE_COR ig \e[0m\t\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")install global"
	echo " $PACKAGE_COR lint \e[0m\t\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")lint"
	echo " $PACKAGE_COR rdev \e[0m\t\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")dev"
	echo " $PACKAGE_COR sb \e[0m\t\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")storybook"
	echo " $PACKAGE_COR sbb \e[0m\t\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")storybook:build"
	echo " $PACKAGE_COR start \e[0m\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")start"
	echo " $PACKAGE_COR tsc \e[0m\t\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")tsc"
	echo ""
	help_line "test $Z_PROJECT_SHORT_NAME"
	if [[ "$Z_COV" != "$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:coverage" ]]; then
		echo " $PACKAGE_COR ${Z_PACKAGE_MANAGER:0:1}cov \e[0m\t\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:coverage"
	fi
	if [[ "$Z_E2E" != "$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:e2e" ]]; then
		echo " $PACKAGE_COR ${Z_PACKAGE_MANAGER:0:1}e2e \e[0m\t\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:e2e"
	fi
	if [[ "$Z_E2EUI" != "$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:e2e-ui" ]]; then
		echo " $PACKAGE_COR ${Z_PACKAGE_MANAGER:0:1}e2eui \e[0m\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:e2e-ui"
	fi
	if [[ "$Z_TEST" != "$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test" ]]; then
		echo " $PACKAGE_COR ${Z_PACKAGE_MANAGER:0:1}test \e[0m\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test"
	fi
	if [[ "$Z_TEST_WATCH" != "$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:watch" ]]; then
		echo " $PACKAGE_COR ${Z_PACKAGE_MANAGER:0:1}testw \e[0m\t = $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:watch"
	fi
	echo " $PACKAGE_COR_2 cov \e[0m\t\t = $Z_COV"
	echo " $PACKAGE_COR_2 e2e \e[0m\t\t = $Z_E2E"
	echo " $PACKAGE_COR_2 e2eui \e[0m\t = $Z_E2EUI"
	echo " $PACKAGE_COR_2 test \e[0m\t\t = $Z_TEST"
	echo " $PACKAGE_COR_2 testw \e[0m\t = $Z_TEST_WATCH"

	echo ""
	help_line "git"
	echo " $GIT_COR gconf \e[0m\t = git config"
	echo " $GIT_COR gha \e[0m\t\t = view last workflow run"
	echo " $GIT_COR st \e[0m\t\t = git status"
	echo ""
	help_line "git branch"
	echo " $GIT_COR back \e[0m\t\t = go back to previous branch"
	echo " $GIT_COR co \e[0m\t\t = switch branch"
	echo " $GIT_COR co \$1 \$2 \e[0m\t = create branch off of \$2"
	echo " $GIT_COR dev \e[0m\t\t = switch to develop or dev"
	echo " $GIT_COR main \e[0m\t\t = switch to master or main"
	echo " $GIT_COR renb \$1\e[0m\t = rename branch"
	echo " $GIT_COR stage \e[0m\t = switch to staging or stage"
	echo ""
	help_line "git clean"
	echo " $GIT_COR clean\e[0m\t\t = clean + restore"
	echo " $GIT_COR delb \e[0m\t\t = delete local branches"
	echo " $GIT_COR prune \e[0m\t = prune branches and tags"
	echo " $GIT_COR reset1 \e[0m\t = reset soft 1 commit"
	echo " $GIT_COR reset2 \e[0m\t = reset soft 2 commits"
	echo " $GIT_COR reset3 \e[0m\t = reset soft 3 commits"
	echo " $GIT_COR reset4 \e[0m\t = reset soft 4 commits"
	echo " $GIT_COR reset5 \e[0m\t = reset soft 5 commits"
	echo " $GIT_COR reseta \e[0m\t = reset hard + clean"
	echo " $GIT_COR restore \e[0m\t = undo edits since last commit"
	echo ""
	help_line "git log"
	echo " $GIT_COR glog \e[0m\t\t = git log"
	echo " $GIT_COR gll \e[0m\t\t = list local branches"
	echo " $GIT_COR gll \$1 \e[0m\t = list local branches matching \$1"
	echo " $GIT_COR glr \e[0m\t\t = list remote branches"
	echo " $GIT_COR glr \$1 \e[0m\t = list remote branches matching \$1"
	echo ""
	help_line "git pull"
	echo " $GIT_COR fetch \e[0m\t = fetch all"
	echo " $GIT_COR fetch \$1 \e[0m\t = fetch branch"
	echo " $GIT_COR pull \e[0m\t\t = pull all branches"
	echo " $GIT_COR pull tags\e[0m\t = pull all tags"
	echo ""
	help_line "git push"
	echo " $GIT_COR add \e[0m\t\t = add files to index"
	echo " $GIT_COR commit \e[0m\t = commit wizard"
	echo " $GIT_COR commit \$1\e[0m\t = commit message"
	echo " $GIT_COR pr \e[0m\t\t = create pull request"
	echo " $GIT_COR pr \$1\e[0m\t\t = create pr w/ labels"
	echo " $GIT_COR push \e[0m\t\t = push all no-verify"
	echo " $GIT_COR pushf \e[0m\t = push all force"
	echo ""
	help_line "git rebase"
	echo " $GIT_COR abort\e[0m\t\t = abort rebase/merge/chp"
	echo " $GIT_COR chc \e[0m\t\t = continue cherry-pick"
	echo " $GIT_COR chp \$1 \e[0m\t = cherry-pick commit"
	echo " $GIT_COR conti \e[0m\t = continue rebase/merge/chp"
	echo " $GIT_COR mc \e[0m\t\t = continue merge"
	echo " $GIT_COR merge \e[0m\t = merge from $(git config --get init.defaultBranch) branch"
	echo " $GIT_COR merge \$1 \e[0m\t = merge from branch"
	echo " $GIT_COR rc \e[0m\t\t = continue rebase"
	echo " $GIT_COR rebase \e[0m\t = rebase from $(git config --get init.defaultBranch) branch"
	echo " $GIT_COR rebase \$1 \e[0m\t = rebase from branch"
	echo ""
	help_line "git stash"
	echo " $GIT_COR pop \e[0m\t\t = stash pop index"
	echo " $GIT_COR stash \e[0m\t = stash unnamed"
	echo " $GIT_COR stash \$1 \e[0m\t = stash w/ name"
	echo " $GIT_COR stashes \e[0m\t = list all stashes"
	echo ""
	help_line "git tags"
	echo " $GIT_COR dtag \$1\e[0m\t = delete tag remotely"
	echo " $GIT_COR ltag \e[0m\t\t = display latest tag"
	echo " $GIT_COR tag \$1\e[0m\t = create tag remotely"
	echo " $GIT_COR tags \e[0m\t\t = list latest tags"

	echo ""
}

check_prj_() {
	local ERROR_PROJ=0;

	if [[ -z $Z_PROJECT_FOLDER ]]; then
		echo " \e[31mfatal:\e[0m not found Z_PROJECT_FOLDER=";
		ERROR_PROJ=1
	else
		if [[ ! -d "$Z_PROJECT_FOLDER" ]]; then
			echo " \e[31mfatal:\e[0m cannot locate Z_PROJECT_FOLDER=$Z_PROJECT_FOLDER";
			if [[ -n "$Z_PROJECT_FOLDER" ]]; then
				echo "mkdir "$Z_PROJECT_FOLDER""
			fi
			ERROR_PROJ=1
		fi
	fi
	if [[ -z $Z_PROJECT_SHORT_NAME ]]; then
		echo " \e[31mfatal:\e[0m not found Z_PROJECT_SHORT_NAME=";
		ERROR_PROJ=1
	fi
	if [[ -z $Z_PROJECT_REPO ]]; then
		echo " \e[31mfatal:\e[0m not found Z_PROJECT_REPO=";
		ERROR_PROJ=1
	fi
	if [[ -z $Z_PACKAGE_MANAGER ]]; then
		echo " \e[31mfatal:\e[0m not found Z_PACKAGE_MANAGER=";
		ERROR_PROJ=1
	fi

	if [[ "$ERROR_PROJ" -eq 1 ]]; then
		echo " \nedit .zfab1ocfg then restart your terminal\n";
		return 1;
	fi

	return 0;
}

check_prj_1_() {
	ERROR_PROJ_1=0;

	if [[ -z "$Z_PROJECT_FOLDER_1" ]]; then
		Z_PROJECT_FOLDER_1_=$(sed -n 's/^Z_PROJECT_FOLDER_1=\([^ ]*\)/\1/p' "$Z_FAB1O_CFG"); Z_PROJECT_FOLDER_1_="${Z_PROJECT_FOLDER_1_/#\~/$HOME}"
		if [[ -n "$Z_PROJECT_FOLDER_1_" ]]; then
			Z_PROJECT_FOLDER_1=$(realpath $Z_PROJECT_FOLDER_1_);
			if [ $? -ne 0 ]; then
				mkdir -p $Z_PROJECT_FOLDER_1_
				if [ $? -eq 0 ]; then
					Z_PROJECT_FOLDER_1=$(realpath $Z_PROJECT_FOLDER_1_);
					echo "\e[38;5;218m created folder: $Z_PROJECT_FOLDER_1_\e[0m"
					echo " type \e[93mhelp\e[0m for more"
				fi
			fi
		fi
	fi

	if [[ -z "$Z_PROJECT_FOLDER_1" ]]; then
		if [[ -z "$1" ]]; then
			echo " \e[31mfatal:\e[0m not found Z_PROJECT_FOLDER_1=$Z_PROJECT_FOLDER_1";
		fi
		ERROR_PROJ_1=1
	else
		if [[ ! -d "$Z_PROJECT_FOLDER_1" ]]; then
			if [[ -z "$1" ]]; then
				echo " \e[31mfatal:\e[0m cannot locate Z_PROJECT_FOLDER_1=$Z_PROJECT_FOLDER_1";
			fi
			ERROR_PROJ_1=1
		fi
	fi
	if [[ -z $Z_PROJECT_SHORT_NAME_1 ]]; then
		if [[ -z "$1" ]]; then
			echo " \e[31mfatal:\e[0m not found Z_PROJECT_SHORT_NAME_1=";
		fi
		ERROR_PROJ_1=1
	fi
	if [[ -z $Z_PROJECT_REPO_1 ]]; then
		if [[ -z "$1" ]]; then
			echo " \e[31mfatal:\e[0m not found Z_PROJECT_REPO_1=";
		fi
		ERROR_PROJ_1=1
	fi

	if [[ "$ERROR_PROJ_1" -eq 1 ]]; then
		if [[ -z "$1" ]]; then
			echo " \nedit .zfab1ocfg then restart your terminal\n";
		fi
		return 1;
	fi

	return 0;
}

check_prj_2_() {
	local ERROR_PROJ_2=0

	if [[ -z "$Z_PROJECT_FOLDER_2" ]]; then
		Z_PROJECT_FOLDER_2_=$(sed -n 's/^Z_PROJECT_FOLDER_2=\([^ ]*\)/\1/p' "$Z_FAB1O_CFG"); Z_PROJECT_FOLDER_2_="${Z_PROJECT_FOLDER_2_/#\~/$HOME}"
		if [[ -n "$Z_PROJECT_FOLDER_2_" ]]; then
			Z_PROJECT_FOLDER_2=$(realpath $Z_PROJECT_FOLDER_2_);
			if [ $? -ne 0 ]; then
				mkdir -p $Z_PROJECT_FOLDER_2_
				if [ $? -eq 0 ]; then
					Z_PROJECT_FOLDER_2=$(realpath $Z_PROJECT_FOLDER_2_);
					echo "\e[38;5;218m created folder: $Z_PROJECT_FOLDER_2_\e[0m"
					echo " type \e[93mhelp\e[0m for more"
				fi
			fi
		fi
	fi

	if [[ -z "$Z_PROJECT_FOLDER_2" ]]; then
		if [[ -z "$1" ]]; then
			echo "\e[31mfatal:\e[0m not found Z_PROJECT_FOLDER_2=$Z_PROJECT_FOLDER_2";
		fi
		ERROR_PROJ_2=1
	else
		if [[ ! -d "$Z_PROJECT_FOLDER_2" ]]; then
			if [[ -z "$1" ]]; then
				echo "\e[31mfatal:\e[0m cannot locate Z_PROJECT_FOLDER_2=$Z_PROJECT_FOLDER_2";
			fi
			ERROR_PROJ_2=1
		fi
	fi
	if [[ -z $Z_PROJECT_SHORT_NAME_2 ]]; then
		if [[ -z "$1" ]]; then
			echo "\e[31mfatal:\e[0m not found Z_PROJECT_SHORT_NAME_2=";
		fi
		ERROR_PROJ_2=1
	fi
	if [[ -z $Z_PROJECT_REPO_2 ]]; then
		if [[ -z "$1" ]]; then
			echo "\e[31mfatal:\e[0m not found Z_PROJECT_REPO_2=";
		fi
		ERROR_PROJ_2=1
	fi

	if [[ "$ERROR_PROJ_2" -eq 1 ]]; then
		if [[ -z "$1" ]]; then
			echo "\nedit .zfab1ocfg then restart your terminal\n";
		fi
		return 1;
	fi

	return 0;
}

check_prj_3_() {
	local ERROR_PROJ_3=0

	if [[ -z "$Z_PROJECT_FOLDER_3" ]]; then
		Z_PROJECT_FOLDER_3_=$(sed -n 's/^Z_PROJECT_FOLDER_3=\([^ ]*\)/\1/p' "$Z_FAB1O_CFG"); Z_PROJECT_FOLDER_3_="${Z_PROJECT_FOLDER_3_/#\~/$HOME}"
		if [[ -n "$Z_PROJECT_FOLDER_3_" ]]; then
			Z_PROJECT_FOLDER_3=$(realpath $Z_PROJECT_FOLDER_3_);
			if [ $? -ne 0 ]; then
				mkdir -p $Z_PROJECT_FOLDER_3_
				if [ $? -eq 0 ]; then
					Z_PROJECT_FOLDER_3=$(realpath $Z_PROJECT_FOLDER_3_);
					echo "\e[38;5;218m created folder: $Z_PROJECT_FOLDER_3_\e[0m"
					echo " type \e[93mhelp\e[0m for more"
				fi
			fi
		fi
	fi

	if [[ -z "$Z_PROJECT_FOLDER_3" ]]; then
		if [[ -z "$1" ]]; then
			echo " \e[31mfatal:\e[0m not found Z_PROJECT_FOLDER_3=$Z_PROJECT_FOLDER_3";
		fi
		ERROR_PROJ_3=1
	else	
		if [[ ! -d "$Z_PROJECT_FOLDER_3" ]]; then
			if [[ -z "$1" ]]; then
				echo " \e[31mfatal:\e[0m cannot locate Z_PROJECT_FOLDER_3=$Z_PROJECT_FOLDER_3";
			fi
			ERROR_PROJ_3=1
		fi
	fi
	if [[ -z $Z_PROJECT_SHORT_NAME_3 ]]; then
		if [[ -z "$1" ]]; then
			echo " \e[31mfatal:\e[0m not found Z_PROJECT_SHORT_NAME_3=";
		fi
		ERROR_PROJ_3=1
	fi
	if [[ -z $Z_PROJECT_REPO_3 ]]; then
		if [[ -z "$1" ]]; then
			echo " \e[31mfatal:\e[0m not found Z_PROJECT_REPO_3=";
		fi
		ERROR_PROJ_3=1
	fi

	if [[ "$ERROR_PROJ_3" -eq 1 ]]; then
		if [[ -z "$1" ]]; then
			echo " \nedit .zfab1ocfg then restart your terminal\n";
		fi
		return 1;
	fi

	return 0;
}

check_prj_1_ "skip"
if [ $? -ne 0 ]; then return 1; fi

[[ ! -f "$Z_FAB1O_PRO" ]] && echo "$Z_PROJECT_SHORT_NAME_1" > "$Z_FAB1O_PRO";

# check what project is set
which_pro() {
	if [[ -n "$Z_PROJECT_SHORT_NAME" ]]; then
		echo " project is set to: \e[34m$Z_PROJECT_SHORT_NAME\e[0m"
	fi

	if [[ -n "$1" ]]; then
		echo ""
		echo " options:"

		if [[ -n "$Z_PROJECT_SHORT_NAME_1" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_1" ]]; then
			echo " \e[93mpro $Z_PROJECT_SHORT_NAME_1\e[0m";
		fi

		if [[ -n "$Z_PROJECT_SHORT_NAME_2" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_2" ]]; then
			echo " \e[93mpro $Z_PROJECT_SHORT_NAME_2\e[0m";
		fi

		if [[ -n "$Z_PROJECT_SHORT_NAME_3" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_3" ]]; then
			echo " \e[93mpro $Z_PROJECT_SHORT_NAME_3\e[0m";
		fi
	fi
}

which_pro_pwd() {
	if [[ -n "$Z_PROJECT_SHORT_NAME_1" && -n "$Z_PROJECT_FOLDER_1" ]]; then
		if [[ $(PWD) == $Z_PROJECT_FOLDER_1* ]]; then
			echo $Z_PROJECT_SHORT_NAME_1
			return 0;
		fi
	fi

	if [[ -n "$Z_PROJECT_SHORT_NAME_2" && -n "$Z_PROJECT_FOLDER_2" ]]; then
		if [[ $(PWD) == $Z_PROJECT_FOLDER_2* ]]; then
			echo $Z_PROJECT_SHORT_NAME_2
			return 0;
		fi
	fi

	if [[ -n "$Z_PROJECT_SHORT_NAME_3" && -n "$Z_PROJECT_FOLDER_3" ]]; then
		if [[ $(PWD) == $Z_PROJECT_FOLDER_3* ]]; then
			echo $Z_PROJECT_SHORT_NAME_3
			return 0;
		fi
	fi

	# cannot determine project based on pwd
	return 1;
}

pro() {
	if [[ -z "$1" ]]; then
		echo " project is set to: \e[34m$Z_PROJECT_SHORT_NAME\e[0m\n"
		local PROS=("$Z_PROJECT_SHORT_NAME_1" "$Z_PROJECT_SHORT_NAME_2" "$Z_PROJECT_SHORT_NAME_3")
		local CHOICE=$(choose_one_ "set pro:" $PROS);
		if [[ $? -eq 0 && -n "$CHOICE" ]]; then
			pro "$CHOICE"
			if [ $? -eq 0 ]; then return 0; else return 1; fi
		else
			return 0;
		fi
	fi

	# check if current folder is a project, then set project to that
	if [[ "$1" == "pwd" ]]; then
		local PRO_PWD=$(which_pro_pwd);
		if [[ -n "$PRO_PWD" ]]; then
			pro "$PRO_PWD" "$2"
			if [ $? -eq 0 ]; then return 0; else return 1; fi
		fi

		if [[ -z "$2" ]]; then
			if [[ -n "$Z_PROJECT_SHORT_NAME" ]]; then
				echo " project is set to: \e[34m$Z_PROJECT_SHORT_NAME\e[0m"
			fi
		fi

		return 1;
	fi

	if [[ "$1" != "$Z_PROJECT_SHORT_NAME_1" && "$1" != "$Z_PROJECT_SHORT_NAME_2" && "$1" != "$Z_PROJECT_SHORT_NAME_3" ]]; then		
		which_pro "$1";
		return 1;
	fi

	if [[ "$1" == "$Z_PROJECT_SHORT_NAME_1" ]]; then
		check_prj_1_;
		if [ $? -ne 0 ]; then
			which_pro;
			return 1;
		fi

		Z_PROJECT_FOLDER="$Z_PROJECT_FOLDER_1"
		Z_PROJECT_SHORT_NAME="$Z_PROJECT_SHORT_NAME_1"
		Z_PROJECT_REPO="$Z_PROJECT_REPO_1"
		Z_PACKAGE_MANAGER="$Z_PACKAGE_MANAGER_1"
		Z_CODE_EDITOR="$Z_CODE_EDITOR_1"
		Z_CLONE="$Z_CLONE_1"
		Z_SETUP="$Z_SETUP_1"
		Z_RUN="$Z_RUN_1"
		# Z_RUN_DEV="$Z_RUN_DEV_1"
		Z_RUN_STAGE="$Z_RUN_STAGE_1"
		Z_RUN_PROD="$Z_RUN_PROD_1"
		Z_PRO="$Z_PRO_1"
		Z_TEST="$Z_TEST_1"
		Z_COV="$Z_COV_1"
		Z_TEST_WATCH="$Z_TEST_WATCH_1"
		Z_E2E="$Z_E2E_1"
		Z_E2EUI="$Z_E2EUI_1"
		Z_PR_TEMPLATE="$Z_PR_TEMPLATE_1"
		Z_PR_REPLACE="$Z_PR_REPLACE_1"
		Z_PR_APPEND="$Z_PR_APPEND_1"
		Z_PR_RUN_TEST="$Z_PR_RUN_TEST_1"
		Z_GHA_INTERVAL="$Z_GHA_INTERVAL_1"

	elif [[ "$1" == "$Z_PROJECT_SHORT_NAME_2" ]]; then
		check_prj_2_;
		if [ $? -ne 0 ]; then
			which_pro;
			return 1;
		fi

		Z_PROJECT_FOLDER="$Z_PROJECT_FOLDER_2"
		Z_PROJECT_SHORT_NAME="$Z_PROJECT_SHORT_NAME_2"
		Z_PROJECT_REPO="$Z_PROJECT_REPO_2"
		Z_PACKAGE_MANAGER="$Z_PACKAGE_MANAGER_2"
		Z_CODE_EDITOR="$Z_CODE_EDITOR_2"
		Z_CLONE="$Z_CLONE_2"
		Z_SETUP="$Z_SETUP_2"
		Z_RUN="$Z_RUN_2"
		# Z_RUN_DEV="$Z_RUN_DEV_2"
		Z_RUN_STAGE="$Z_RUN_STAGE_2"
		Z_RUN_PROD="$Z_RUN_PROD_2"
		Z_PRO="$Z_PRO_2"
		Z_TEST="$Z_TEST_2"
		Z_COV="$Z_COV_2"
		Z_TEST_WATCH="$Z_TEST_WATCH_2"
		Z_E2E="$Z_E2E_2"
		Z_E2EUI="$Z_E2EUI_2"
		Z_PR_TEMPLATE="$Z_PR_TEMPLATE_2"
		Z_PR_REPLACE="$Z_PR_REPLACE_2"
		Z_PR_APPEND="$Z_PR_APPEND_2"
		Z_PR_RUN_TEST="$Z_PR_RUN_TEST_2"
		Z_GHA_INTERVAL="$Z_GHA_INTERVAL_2"

	elif [[ "$1" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
		check_prj_3_;
		if [ $? -ne 0 ]; then
			which_pro;
			return 1;
		fi

		Z_PROJECT_FOLDER="$Z_PROJECT_FOLDER_3"
		Z_PROJECT_SHORT_NAME="$Z_PROJECT_SHORT_NAME_3"
		Z_PROJECT_REPO="$Z_PROJECT_REPO_3"
		Z_PACKAGE_MANAGER="$Z_PACKAGE_MANAGER_3"
		Z_CODE_EDITOR="$Z_CODE_EDITOR_3"
		Z_CLONE="$Z_CLONE_3"
		Z_SETUP="$Z_SETUP_3"
		Z_RUN="$Z_RUN_3"
		# Z_RUN_DEV="$Z_RUN_DEV_3"
		Z_RUN_STAGE="$Z_RUN_STAGE_3"
		Z_RUN_PROD="$Z_RUN_PROD_3"
		Z_PRO="$Z_PRO_3"
		Z_TEST="$Z_TEST_3"
		Z_COV="$Z_COV_3"
		Z_TEST_WATCH="$Z_TEST_WATCH_3"
		Z_E2E="$Z_E2E_3"
		Z_E2EUI="$Z_E2EUI_3"
		Z_PR_TEMPLATE="$Z_PR_TEMPLATE_3"
		Z_PR_REPLACE="$Z_PR_REPLACE_3"
		Z_PR_APPEND="$Z_PR_APPEND_3"
		Z_PR_RUN_TEST="$Z_PR_RUN_TEST_3"
		Z_GHA_INTERVAL="$Z_GHA_INTERVAL_3"
	else
		which_pro;
		return 0;
	fi

	echo "$Z_PROJECT_SHORT_NAME" > "$Z_FAB1O_PRO"

	if [[ "$2" != "refresh" ]]; then
		which_pro;
	fi

	if [[ $(PWD) != $Z_PROJECT_FOLDER* ]]; then
		if [[ "$2" != "skip" ]]; then
			cd "$Z_PROJECT_FOLDER"
		fi
	fi

	if [[ -n "$Z_PRO" && "$2" != "refresh" ]]; then
		eval $Z_PRO
	fi
	
	export Z_PROJECT_SHORT_NAME="$Z_PROJECT_SHORT_NAME"

	if [[ "$2" != "skip" ]]; then
		refresh
	fi
}

# auto pro ===============================================================
pro pwd "skip"

if [ $? -ne 0 ]; then
	# get stored project and set project but do not change PWD
	local Z_PROJECT_USER_CONFIG="$(head -n 1 "$Z_FAB1O_PRO")";

	if [[ "$Z_PROJECT_USER_CONFIG" == "$Z_PROJECT_SHORT_NAME_1" || "$Z_PROJECT_USER_CONFIG" == "$Z_PROJECT_SHORT_NAME_2" || "$Z_PROJECT_USER_CONFIG" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
		pro "$Z_PROJECT_USER_CONFIG" "skip"
	else
		# if there's nothing set in config, choose the 1st one available
		if [[ -n "$Z_PROJECT_SHORT_NAME_1" ]]; then
			pro "$Z_PROJECT_SHORT_NAME_1" "skip"
		elif [[ -n "$Z_PROJECT_SHORT_NAME_2" ]]; then
			pro "$Z_PROJECT_SHORT_NAME_2" "skip"
		elif [[ -n "$Z_PROJECT_SHORT_NAME_3" ]]; then
			pro "$Z_PROJECT_SHORT_NAME_3" "skip"
		fi
	fi
fi
# ==========================================================================

check_pkg_silent() {
	local FOLDER=""
	
	if [[ -n "$1" ]]; then
		FOLDER="$(realpath "${1/#\~/$HOME}")"
		if [ $? -ne 0 ]; then
			return 2;
		fi
	else
		FOLDER="$(PWD)"
	fi

	if [[ ! -d "$FOLDER" ]]; then
		return 1;
	fi

  while [[ "$FOLDER" != "/" ]]; do
    if [[ -f "$FOLDER/package.json" ]]; then
      return 0
    fi
    FOLDER="$(dirname "$FOLDER")"
  done

  return 1
}

check_pkg() {
	check_pkg_silent "$1"
	local RET=$?
	if [ $RET -eq 2 ]; then
		return 1;
	fi
	if [ $RET -ne 0 ]; then
		echo " not a project folder: ${1:-$(PWD)}"
		return 1;
	fi
}

check_git_silent_() {
	local PWD_="$(PWD)"
	local FOLDER=${1:-$PWD_};
	
	if [[ ! -d "$FOLDER" ]]; then
		return 1;
	fi

	cd "$FOLDER"
  git rev-parse --is-inside-work-tree >/dev/null 2>&1
	local RET=$?

	cd "$PWD_"
	return $RET
}

check_git_() {
	check_git_silent_ "$1"
	
	if [ $? -eq 0 ]; then
		return 0;
	fi

	echo " not a git folder: ${1:-$(PWD)}"
	return 1;
}

alias i="$Z_PACKAGE_MANAGER install"
# Package manager aliases =========================================================
alias build="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")build"
alias deploy="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")deploy"
alias fix="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")format && $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")lint && $Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")format"
alias format="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")format"
alias ig="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")install --global"
alias lint="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")lint"
alias rdev="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")dev"
alias tsc="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")tsc"
alias sb="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")storybook"
alias sbb="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")storybook:build"
alias start="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")start"

unalias ncov 2>/dev/null
unalias ntest 2>/dev/null
unalias ne2e 2>/dev/null
unalias ne2eui 2>/dev/null
unalias ntestw 2>/dev/null

unalias ycov 2>/dev/null
unalias ytest 2>/dev/null
unalias ye2e 2>/dev/null
unalias ye2eui 2>/dev/null
unalias ytestw 2>/dev/null

unalias pcov 2>/dev/null
unalias ptest 2>/dev/null
unalias pe2e 2>/dev/null
unalias pe2eui 2>/dev/null
unalias ptestw 2>/dev/null

unalias bcov 2>/dev/null
unalias btest 2>/dev/null
unalias be2e 2>/dev/null
unalias be2eui 2>/dev/null
unalias btestw 2>/dev/null 

if [[ "$Z_COV" != "$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:coverage" ]]; then
	alias ${Z_PACKAGE_MANAGER:0:1}cov="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:coverage"
fi
if [[ "$Z_TEST" != "$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test" ]]; then
	alias ${Z_PACKAGE_MANAGER:0:1}test="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test"
fi
if [[ "$Z_E2E" != "$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:e2e" ]]; then
	alias ${Z_PACKAGE_MANAGER:0:1}e2e="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:e2e"
fi
if [[ "$Z_E2EUI" != "$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:e2e-ui" ]]; then
	alias ${Z_PACKAGE_MANAGER:0:1}e2eui="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:e2e-ui"
fi
if [[ "$Z_TEST_WATCH" != "$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:watch" ]]; then
	alias ${Z_PACKAGE_MANAGER:0:1}testw="$Z_PACKAGE_MANAGER $([[ $Z_PACKAGE_MANAGER == "yarn" ]] && echo "" || echo "run ")test:watch"
fi

# Project aliases =========================================================
if [[ -n "$Z_PROJECT_SHORT_NAME_1" ]]; then
	$Z_PROJECT_SHORT_NAME_1() {
		check_pkg_silent "$Z_PROJECT_FOLDER_1"
		local SINGLE_MODE=$?;

		if [[ "$1" == "-h" ]]; then
			if [ $SINGLE_MODE -eq 0 ]; then
				echo " \e[93m$Z_PROJECT_SHORT_NAME_1\e[0m : to open $Z_PROJECT_SHORT_NAME_1"
				echo " \e[93m$Z_PROJECT_SHORT_NAME_1 \e[33m[<branch>]\e[0m : to open $Z_PROJECT_SHORT_NAME_1 and switch to branch"
			else
				echo " \e[93m$Z_PROJECT_SHORT_NAME_1\e[0m : to open $Z_PROJECT_SHORT_NAME_1"
				echo " \e[93m$Z_PROJECT_SHORT_NAME_1 \e[33m[<folder>]\e[0m : to open $Z_PROJECT_SHORT_NAME_1 into folder"
				echo " \e[93m$Z_PROJECT_SHORT_NAME_1 \e[33m[<folder>] [<branch>]\e[0m : to open $Z_PROJECT_SHORT_NAME_1 into folder and switch to branch"
			fi
			return 0;
		fi

		pro "$Z_PROJECT_SHORT_NAME_1" refresh

		local FOLDER=""
		local BRANCH=""

		if [ $SINGLE_MODE -eq 0 ]; then
			BRANCH="$1"
		else
			FOLDER="$1"
			BRANCH="$2"
		fi

		if [[ -n "$FOLDER" ]]; then
			check_pkg "$FOLDER"
			if [ $? -eq 0 ]; then
				cd "$FOLDER"
			fi
		fi
		
		if [[ -n "$BRANCH" ]]; then
			if [ $? -eq 0 ]; then
				co $BRANCH
			fi
		fi
	}
fi

if [[ -n "$Z_PROJECT_SHORT_NAME_2" ]]; then
	$Z_PROJECT_SHORT_NAME_2() {
		check_pkg_silent "$Z_PROJECT_FOLDER_2"
		local SINGLE_MODE=$?;

		if [[ "$1" == "-h" ]]; then
			if [ $SINGLE_MODE -eq 0 ]; then
				echo " \e[93m$Z_PROJECT_SHORT_NAME_2\e[0m : to open $Z_PROJECT_SHORT_NAME_2"
				echo " \e[93m$Z_PROJECT_SHORT_NAME_2 \e[33m[<branch>]\e[0m : to open $Z_PROJECT_SHORT_NAME_2 and switch to branch"
			else
				echo " \e[93m$Z_PROJECT_SHORT_NAME_2\e[0m : to open $Z_PROJECT_SHORT_NAME_2"
				echo " \e[93m$Z_PROJECT_SHORT_NAME_2 \e[33m[<folder>]\e[0m : to open $Z_PROJECT_SHORT_NAME_2 into folder"
				echo " \e[93m$Z_PROJECT_SHORT_NAME_2 \e[33m[<folder> <branch>]\e[0m : to open $Z_PROJECT_SHORT_NAME_2 into folder and switch to branch"
			fi
			return 0;
		fi

		pro "$Z_PROJECT_SHORT_NAME_2" refresh

		local FOLDER=""
		local BRANCH=""

		if [ $SINGLE_MODE -eq 0 ]; then
			BRANCH="$1"
		else
			FOLDER="$1"
			BRANCH="$2"
		fi

		if [[ -n "$FOLDER" ]]; then
			check_pkg "$FOLDER"
			if [ $? -eq 0 ]; then
				cd "$FOLDER"
			fi
		fi
		
		if [[ -n "$BRANCH" ]]; then
			if [ $? -eq 0 ]; then
				co $BRANCH
			fi
		fi
	}
fi

if [[ -n "$Z_PROJECT_SHORT_NAME_3" ]]; then
	$Z_PROJECT_SHORT_NAME_3() {
		check_pkg_silent "$Z_PROJECT_FOLDER_3"
		local SINGLE_MODE=$?;

		if [[ "$1" == "-h" ]]; then
			if [ $SINGLE_MODE -eq 0 ]; then
				echo " \e[93m$Z_PROJECT_SHORT_NAME_3\e[0m : to open $Z_PROJECT_SHORT_NAME_3"
				echo " \e[93m$Z_PROJECT_SHORT_NAME_3 \e[33m[<branch>]\e[0m : to open $Z_PROJECT_SHORT_NAME_3 and switch to branch"
			else
				echo " \e[93m$Z_PROJECT_SHORT_NAME_3\e[0m : to open $Z_PROJECT_SHORT_NAME_3"
				echo " \e[93m$Z_PROJECT_SHORT_NAME_3 \e[33m[<folder>]\e[0m : to open $Z_PROJECT_SHORT_NAME_3 into folder"
				echo " \e[93m$Z_PROJECT_SHORT_NAME_3 \e[33m[<folder> <branch>]\e[0m : to open $Z_PROJECT_SHORT_NAME_3 into folder and switch to branch"
			fi
			return 0;
		fi

		pro "$Z_PROJECT_SHORT_NAME_3" refresh

		local FOLDER=""
		local BRANCH=""

		if [ $SINGLE_MODE -eq 0 ]; then
			BRANCH="$1"
		else
			FOLDER="$1"
			BRANCH="$2"
		fi

		if [[ -n "$FOLDER" ]]; then
			check_pkg "$FOLDER"
			if [ $? -eq 0 ]; then
				cd "$FOLDER"
			fi
		fi
		
		if [[ -n "$BRANCH" ]]; then
			if [ $? -eq 0 ]; then
				co $BRANCH
			fi
		fi
	}
fi

test() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mtest\e[0m : to $Z_TEST"
		return 0;
	fi

	check_pkg; if [ $? -ne 0 ]; then return 1; fi

	eval $Z_TEST "$@"
	if [ $? -ne 0 ]; then
		eval $Z_TEST "$@"
	fi
}

cov() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mcov\e[0m : to $Z_COV"
		return 0;
	fi

	check_pkg; if [ $? -ne 0 ]; then return 1; fi

	eval $Z_COV "$@"
	if [ $? -ne 0 ]; then
		eval $Z_COV "$@"
	fi
}

testw() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mtestw\e[0m : to $Z_TEST_WATCH"
		return 0;
	fi

	check_pkg; if [ $? -ne 0 ]; then return 1; fi

	eval $Z_TEST_WATCH "$@"
	if [ $? -ne 0 ]; then
		eval $Z_TEST_WATCH "$@"
	fi
}

e2e() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93me2e\e[0m : to $Z_E2E"
		echo " \e[93me2e <project>\e[0m : to $Z_E2E --project <project>"
		return 0;
	fi

	check_pkg; if [ $? -ne 0 ]; then return 1; fi

	if [[ -z "$1" ]]; then
		eval $Z_E2E
	else
		eval $Z_E2E --project "$1"
	fi
}

e2eui() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93me2eui\e[0m : to $Z_E2EUI"
		echo " \e[93me2eui \e[33m<project>\e[0m : to $Z_E2EUI --project"
		return 0;
	fi

	check_pkg; if [ $? -ne 0 ]; then return 1; fi

	if [[ -z "$1" ]]; then
		eval $Z_E2EUI
	else
		eval $Z_E2EUI --project "$1"
	fi
}

add() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93madd\e[0m : to add all files to index"
		echo " \e[93madd \e[33m<files>\e[0m : to add files to index"
		return 0;
	fi

	check_git_; if [ $? -ne 0 ]; then return 1; fi

	if [[ -z "$1" ]]; then
		git add . "$@"
	else
		git add "$@"
	fi
}

# Creating PRs =============================================================
pr() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93pr\e[0m : to create a pull request"
		echo " \e[93pr -s\e[0m : to create a pull request, skip test"
		echo " \e[93pr <labels>\e[0m : to create a pull request with labels"
		return 0;
	fi

	if ! command -v gh &> /dev/null; then
		echo " fatal: pr requires gh"
		echo " install gh: \e[93mhttps://github.com/cli/cli\e[0m"
		return 0;
	fi

	check_git_; if [ $? -ne 0 ]; then return 1; fi

	# Initialize an empty string to store the commit details
	local COMMIT_MSGS=""
	local PR_TITLE=""

	local REMOTE_BRANCH=$(git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)" origin/mainline)

	# Get the current branch name
	local CURRENT_BRANCH=$(git branch --show-current)

	# Local branch has been pushed to remote
	if [[ -n "$REMOTE_BRANCH" ]]; then
		# Get the current user's name (author)
		local current_author=$(git config --get user.email)
		# Get the current commit hash where origin/HEAD is pointing
		local origin_head_commit=$(git rev-parse origin/HEAD)

		# Loop through all commits in the current branch using git log (newest to oldest)
		git log --pretty=format:'%H | %ae | %at | %s' $CURRENT_BRANCH | xargs -0 | while IFS= read -r line; do
		  # Extract commit hash, commit author, and commit message using the '|' separator
	    local commit_hash=$(echo "$line" | cut -d'|' -f1 | xargs)
	    local commit_author=$(echo "$line" | cut -d'|' -f2 | xargs)
	    local commit_date=$(echo "$line" | cut -d'|' -f3- | xargs)
	    local commit_message=$(echo "$line" | cut -d'|' -f4- | xargs -0)

			local NOW_TS=$(date +%s)
			# 7 days in seconds = 7 * 86400
			local ONE_WEEK=$((7 * 86400))

			# Check if the commit belongs to the current branch
			if ! git branch --contains "$commit_hash" | grep -q "\b$CURRENT_BRANCH\b"; then
			  break;
			fi

			if (( NOW_TS - COMMIT_TS > ONE_WEEK )); then
				break;
			fi

	    # Stop if the commit is the origin/HEAD commit
	    if [[ "$commit_hash" == "$origin_head_commit" ]]; then
	      break;
	    fi
	    # Check if the commit's author matches the current user
	    if [[ "$commit_author" != "$current_author" ]]; then
	      break;
	    fi

			local DIRTY_PR_TITLE="$commit_message"
			local PR_TITLE="$DIRTY_PR_TITLE"

			if [[ $DIRTY_PR_TITLE =~ ([[:alnum:]]+-[[:digit:]]+) ]]; then
				local ticket="${match[1]}"
				PR_TITLE="$ticket"
				
				if [[ $DIRTY_PR_TITLE =~ [[:alnum:]]+-[[:digit:]]+(.*) ]]; then
					local rest="${match[1]}"
					PR_TITLE="$PR_TITLE$rest"
				fi
			fi

	    # Add the commit hash and message to the list
	    COMMIT_MSGS+="- $commit_hash - $commit_message"$'\n'
		done
	else
		# Local branch has not yet been pushed to remote

		# Loop through all commits in the current branch using git log (newest to oldest)
		git log --branches --not --remotes --oneline --pretty=format:'%H | %s' | xargs -0 | while IFS= read -r line; do
	    local commit_hash=$(echo "$line" | cut -d'|' -f1 | xargs)
	    local commit_message=$(echo "$line" | cut -d'|' -f2- | xargs -0)

		  # # Use grep with a regular expression to find all branches referencing the commit hash
			# local branches=$(grep -R "$commit_hash" .git/refs/heads | sed 's|.*/heads/||' | cut -d: -f1 | sed 's|$|\||')

			# if ! echo "$branches" | grep -q "$CURRENT_BRANCH|"; then
			# 	break
			# fi
			# Check if the commit belongs to the current branch
			if ! git branch --contains "$commit_hash" | grep -q "\b$CURRENT_BRANCH\b"; then
			  break;
			fi

			local DIRTY_PR_TITLE="$commit_message"
			local PR_TITLE="$DIRTY_PR_TITLE"

			if [[ $DIRTY_PR_TITLE =~ ([[:alnum:]]+-[[:digit:]]+) ]]; then
				local ticket="${match[1]}"
				PR_TITLE="$ticket"
				
				if [[ $DIRTY_PR_TITLE =~ [[:alnum:]]+-[[:digit:]]+(.*) ]]; then
					local rest="${match[1]}"
					PR_TITLE="$PR_TITLE$rest"
				fi
			fi

	    # Add the commit hash and message to the list
			COMMIT_MSGS+="- $commit_hash - $commit_message"$'\n'
		done
	fi

	if [[ ! -n "$COMMIT_MSGS" ]]; then
		echo " no commits found, try \e[93mpush\e[0m first.";
		return 0;
	fi

	local PR_BODY="$COMMIT_MSGS"

	if [[ -f "$Z_PR_TEMPLATE" && -n "$Z_PR_REPLACE" ]]; then
		local PR_TEMPLATE=$(cat $Z_PR_TEMPLATE)

		if [[ $Z_PR_APPEND -eq 1 ]]; then
			# Append commit msgs right after Z_PR_REPLACE in pr template
			PR_BODY=$(echo "$PR_TEMPLATE" | perl -pe "s/(\Q$Z_PR_REPLACE\E)/\1\n\n$COMMIT_MSGS\n/")
		else
			# Replace Z_PR_REPLACE with commit msgs in pr template
			PR_BODY=$(echo "$PR_TEMPLATE" | perl -pe "s/\Q$Z_PR_REPLACE\E/$COMMIT_MSGS/g")
		fi
	fi

  # debugging purposes
	# echo " PR_TITLE: $PR_TITLE"
	# echo ""
	# echo "$PR_BODY"
	# return 0;

	if [[ $Z_PR_RUN_TEST -eq 1 && "$1" != "-s" ]]; then
		local STATUS=$(git status --porcelain)
		if [[ -n "$STATUS" ]]; then
			st
			echo .
			if ! confirm_from_ "skip test?"; then
				return 0;
		  fi
		else
			test
			if [ $? -ne 0 ]; then
				echo " \e[33m\nfatal: tests are not passing!\e[0m won't push!";
				return 1;
			fi
	  fi
	fi

	push

	local MY_BRANCH=$(git branch --show-current);

	if [[ -z "$1" ]]; then
		gh pr create -a @me --title $PR_TITLE --body $PR_BODY --web --head $MY_BRANCH
	else
		gh pr create -a @me --title $PR_TITLE --body $PR_BODY --web --head $MY_BRANCH --label "$1"
	fi
}

run() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mrun\e[0m : to run dev in current folder"
		echo " \e[93mrun <folder>\e[0m : to run dev in $Z_PROJECT_SHORT_NAME's folder"
		echo " --"
		echo " \e[93mrun dev\e[0m : to run dev in current folder"
		echo " \e[93mrun stage\e[0m : to run stage in current folder"
		echo " \e[93mrun prod\e[0m : to run prod in current folder"
		echo " --"
		if [[ -n "$Z_PROJECT_SHORT_NAME" ]]; then
			echo " \e[93mrun \e[33m[<folder>] [<env>]\e[0m : to run $Z_PROJECT_SHORT_NAME's folder on an environment"
			echo " --"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_1" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_1" ]]; then
			echo " \e[93mrun $Z_PROJECT_SHORT_NAME_1 \e[33m[<folder>] [<env>]\e[0m : to run $Z_PROJECT_SHORT_NAME_1's folder on an environment"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_2" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_2" ]]; then
			echo " \e[93mrun $Z_PROJECT_SHORT_NAME_2 \e[33m[<folder>] [<env>]\e[0m : to run $Z_PROJECT_SHORT_NAME_2's folder on an environment"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_3" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_3" ]]; then
			echo " \e[93mrun $Z_PROJECT_SHORT_NAME_3 \e[33m[<folder>] [<env>]\e[0m : to run $Z_PROJECT_SHORT_NAME_3's folder on an environment"
		fi
		return 0;
	fi

	local PROJ_ARG=""
	local FOLDER_ARG=""
	local _ENV="dev"

	if [[ -n "$3" ]]; then
		PROJ_ARG="$1"
		_ENV="$3"
		FOLDER_ARG="$2"
	elif [[ -n "$2" ]]; then
		if [[ "$1" == "$Z_PROJECT_SHORT_NAME_1" || "$1" == "$Z_PROJECT_SHORT_NAME_2" || "$1" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			PROJ_ARG="${1:-$Z_PROJECT_SHORT_NAME}"
			if [[ "$2" == "dev" || "$2" == "stage" || "$2" == "prod" ]]; then
				if [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_1" ]]; then
					check_pkg_silent "$Z_PROJECT_FOLDER_1";
				elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_2" ]]; then
					check_pkg_silent "$Z_PROJECT_FOLDER_2";
				elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
					check_pkg_silent "$Z_PROJECT_FOLDER_3";
				fi
				if [[ $? -eq 0 ]]; then
					_ENV="$2"
				else
					FOLDER_ARG="$2"
				fi
			else
				FOLDER_ARG="$2"
			fi
		else
			FOLDER_ARG="$1"
			_ENV="$2"
		fi
	elif [[ -n "$1" ]]; then
		if [[ "$1" == "$Z_PROJECT_SHORT_NAME_1" || "$1" == "$Z_PROJECT_SHORT_NAME_2" || "$1" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			PROJ_ARG="${1:-$Z_PROJECT_SHORT_NAME}"
		else
			check_pkg_silent "$(PWD)";
			if [[ $? -eq 0 ]]; then
				_ENV="$1"
			else
				FOLDER_ARG="$1"
			fi
		fi
	fi

	# it's possible to run a project without PROJ_ARG

	if [[ "$_ENV" != "dev" && "$_ENV" != "stage" && "$_ENV" != "prod" ]]; then
		echo " env is incorrect, valid options: dev, stage or prod"
		echo "  \e[93mrun -h\e[0m for help"
		return 1;
	fi

	# debugging
	# echo "PROJ_ARG=$PROJ_ARG"
	# echo "FOLDER_ARG=$FOLDER_ARG"
	# echo "_ENV=$_ENV"
	# return 0;

	local PROJ_FOLDER="";
	local RUN="$Z_RUN";

	if [[ "$_ENV" == "stage" ]]; then
		RUN="$Z_RUN_STAGE"
	elif [[ "$_ENV" == "prod" ]]; then
		RUN="$Z_RUN_PROD"
	fi

	if [[ -n "$PROJ_ARG" ]]; then
		if [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_1" ]]; then
			check_prj_1_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_1"
			RUN="$Z_RUN_1"

			if [[ "$_ENV" == "stage" ]]; then
				RUN="$Z_RUN_STAGE_1"
			elif [[ "$_ENV" == "prod" ]]; then
				RUN="$Z_RUN_PROD_1"
			fi

		elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_2" ]]; then
			check_prj_2_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_2"
			RUN="$Z_RUN_2"

			if [[ "$_ENV" == "stage" ]]; then
				RUN="$Z_RUN_STAGE_2"
			elif [[ "$_ENV" == "prod" ]]; then
				RUN="$Z_RUN_PROD_2"
			fi

		elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			check_prj_3_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_3"
			RUN="$Z_RUN_3"

			if [[ "$_ENV" == "stage" ]]; then
				RUN="$Z_RUN_STAGE_3"
			elif [[ "$_ENV" == "prod" ]]; then
				RUN="$Z_RUN_PROD_3"
			fi
		fi
	else
		PROJ_ARG="$Z_PROJECT_SHORT_NAME"
	fi

	if [[ -z "$RUN" ]]; then
		echo " no Z_RUN found in \e[34m$PROJ_ARG\e[0m"
		return 0;
	fi

	if [[ -n "$PROJ_FOLDER" ]]; then
		local PWD_="$(PWD)";

		cd "$PROJ_FOLDER"
		check_pkg_silent;

		# if PROJ_FOLDER is a project
		if [ $? -eq 0 ]; then
			echo " run $_ENV \e[1;95m$(shorten_path_)\e[0m"
			echo "$PACKAGE_COR $RUN\e[0m"
			eval $RUN
			if [ $? -ne 0 ]; then
				cd "$PWD_"
				return 1;
			fi
		else
			if [[ -n "$FOLDER_ARG" ]]; then
				check_pkg "$PROJ_FOLDER/$FOLDER_ARG"; if [ $? -ne 0 ]; then return 1; fi
				cd "$FOLDER_ARG"
	
				echo " run $_ENV \e[1;95m$(shorten_path_)\e[0m"
				echo "$PACKAGE_COR $RUN\e[0m"
				eval $RUN
				if [ $? -ne 0 ]; then
					cd "$PWD_"
					return 1;
				fi
			else
				local FOLDERS=$(ls -d */ | grep -v '^revs/$' | sed 's:/$::' | sort -fu)

				if [[ -z "$FOLDERS" ]]; then
					echo " no folder was found in \e[34m$PROJ_ARG\e[0m"
					cd "$PWD_"
					return 0;
				fi

				local CHOICE=$(choose_auto_one_ "choose folder:" $(echo "$FOLDERS" | tr ' ' '\n'));
				if [[ $? -eq 0 && -n "$CHOICE" ]]; then
					run "$PROJ_ARG" "$CHOICE"
					return 0;
				else
					cd "$PWD_"
				fi
			fi
		fi
		return 0;
	fi

	if [[ -n "$FOLDER_ARG" ]]; then
		check_pkg "$FOLDER_ARG"; if [ $? -ne 0 ]; then return 1; fi
		cd "$FOLDER_ARG"
	fi

	check_pkg; if [ $? -ne 0 ]; then return 1; fi

	echo " run $_ENV \e[1;95m$(shorten_path_)\e[0m"
	echo "$PACKAGE_COR $RUN\e[0m"
	eval $RUN
	cd "$PWD_"
}

setup() {
	if [[ "$1" == "-h" ]]; then
			echo " \e[93msetup\e[0m : to setup current folder"
			if [[ -n "$Z_PROJECT_SHORT_NAME" ]]; then
				echo " \e[93msetup <folder>\e[0m : to setup $Z_PROJECT_SHORT_NAME's folder"
			fi
			echo " --"
		if [[ -n "$Z_PROJECT_SHORT_NAME_1" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_1" ]]; then
			echo " \e[93msetup $Z_PROJECT_SHORT_NAME_1 \e[33m[<folder>]\e[0m : to setup $Z_PROJECT_SHORT_NAME_1's folder"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_2" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_2" ]]; then
			echo " \e[93msetup $Z_PROJECT_SHORT_NAME_2 \e[33m[<folder>]\e[0m : to setup $Z_PROJECT_SHORT_NAME_2's folder"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_3" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_3" ]]; then
			echo " \e[93msetup $Z_PROJECT_SHORT_NAME_3 \e[33m[<folder>]\e[0m : to setup $Z_PROJECT_SHORT_NAME_3's folder"
		fi
		return 0;
	fi

	local PROJ_ARG=""
	local FOLDER_ARG=""

	if [[ -n "$2" ]]; then
		PROJ_ARG="$1"
		FOLDER_ARG="$2"
	elif [[ -n "$1" ]]; then
		if [[ "$1" == "$Z_PROJECT_SHORT_NAME_1" || "$1" == "$Z_PROJECT_SHORT_NAME_2" || "$1" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			PROJ_ARG="${1:-$Z_PROJECT_SHORT_NAME}"
		else
			FOLDER_ARG="$1"
		fi
	fi

	local PROJ_FOLDER="";
	local SETUP="$Z_SETUP";

	if [[ -n "$PROJ_ARG" ]]; then
		if [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_1" ]]; then
			check_prj_1_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_1"
			SETUP="$Z_SETUP_1"

		elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_2" ]]; then
			check_prj_2_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_2"
			SETUP="$Z_SETUP_2"

		elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			check_prj_3_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_3"
			SETUP="$Z_SETUP_3"

		else
			echo " not a valid project: $PROJ_ARG"
			echo "  \e[93msetup -h\e[0m for help"
			return 1;
		fi
	else
		PROJ_ARG="$Z_PROJECT_SHORT_NAME"
	fi

	if [[ -z "$SETUP" ]]; then
		echo " no Z_SETUP command found in \e[34m$PROJ_ARG\e[0m"
		return 0;
	fi

	local PWD_="$(PWD)";

	if [[ -n "$PROJ_FOLDER" ]]; then
		cd "$PROJ_FOLDER"
		check_pkg_silent;

		# if PROJ_FOLDER is a project
		if [ $? -eq 0 ]; then
			echo " setup on \e[1;95m$(shorten_path_)\e[0m"
			echo "$PACKAGE_COR $SETUP\e[0m"
			eval $SETUP
			cd "$PWD_"
		else
			if [[ -n "$FOLDER_ARG" ]]; then
				check_pkg "$PROJ_FOLDER/$FOLDER_ARG"; if [ $? -ne 0 ]; then return 1; fi
				cd "$FOLDER_ARG"
				echo " setup on \e[1;95m$(shorten_path_)\e[0m"
				echo "$PACKAGE_COR $SETUP\e[0m"
				eval $SETUP
				cd "$PWD_"
			else
				local FOLDERS=$(ls -d */ | grep -v '^revs/$' | sed 's:/$::' | sort -fu)

				if [[ -z "$FOLDERS" ]]; then
					echo " no folder was found in \e[34m$PROJ_ARG\e[0m"
					cd "$PWD_"
					return 0;
				fi

				local CHOICE=$(choose_auto_one_ "choose folder:" $(echo "$FOLDERS" | tr ' ' '\n'));
				if [[ $? -eq 0 && -n "$CHOICE" ]]; then
					setup "$PROJ_ARG" "$CHOICE"
					return 0;
				else
					cd "$PWD_"
				fi
			fi
		fi
		return 0;
	fi

	if [[ -n "$FOLDER_ARG" ]]; then
		check_pkg "$FOLDER_ARG"; if [ $? -ne 0 ]; then return 1; fi
		cd "$FOLDER_ARG"
	fi

	check_pkg; if [ $? -ne 0 ]; then return 1; fi

	echo " setup on \e[1;95m$(shorten_path_)\e[0m"
	echo "$PACKAGE_COR $SETUP\e[0m"
	eval $SETUP
	cd "$PWD_"
}

# Clone =====================================================================
# review branch
revs() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mrevs\e[0m : to list reviews from $Z_PROJECT_SHORT_NAME"
		echo " \e[93mrevs <pro>\e[0m : to list reviews from project"
		return 0;
	fi
	
	local PROJ_ARG="$Z_PROJECT_SHORT_NAME"

	if [[ -n "$1" ]]; then
		if [[ "$1" == "$Z_PROJECT_SHORT_NAME_1" || "$1" == "$Z_PROJECT_SHORT_NAME_2" || "$1" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			PROJ_ARG="${1:-$Z_PROJECT_SHORT_NAME}"
		else
			echo " not a valid project: $1"
			echo "  \e[93mpro -h\e[0m for help"
			return 0;
		fi
	fi

	local PROJ_FOLDER=""

	if [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_1" ]]; then
		check_prj_1_; if [ $? -ne 0 ]; then return 1; fi
		PROJ_FOLDER="$Z_PROJECT_FOLDER_1"

	elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_2" ]]; then
		check_prj_2_; if [ $? -ne 0 ]; then return 1; fi
		PROJ_FOLDER="$Z_PROJECT_FOLDER_2"

	elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
		check_prj_3_; if [ $? -ne 0 ]; then return 1; fi
		PROJ_FOLDER="$Z_PROJECT_FOLDER_3"

	else
			echo " not a valid project: $PROJ_ARG"
			echo "  \e[93mrevs -h\e[0m for help"
		return 1;
	fi

	if [[ -z "$PROJ_FOLDER" ]]; then
		check_prj_;
		return 1;
	fi

	local REVS_FOLDER="$PROJ_FOLDER/revs"

	if [[ ! -d "$REVS_FOLDER" ]]; then
		REVS_FOLDER="$PROJ_FOLDER-revs"
	fi

	if [[ ! -d "$REVS_FOLDER" ]]; then
		echo " no revs folder was found in $PROJ_FOLDER"
		echo "  \e[93mrev -h\e[0m for help"
		return 0;
	fi

	local PWD_="$(PWD)";

	cd "$REVS_FOLDER"
	local REVS=$(ls -d rev* | xargs -0 | sort -fu)

	if [[ -z "$REVS" ]]; then
		echo " no rev was found in $PROJ_FOLDER"
		echo "  \e[93mrev -h\e[0m for help"
		cd "$PWD_"
		return 0;
	fi

	local CHOICE=$(gum choose --limit=1 --height 40 --header " choose review:" $(echo "$REVS" | tr ' ' '\n'))
	if [[ $? -eq 0 && -n "$CHOICE" ]]; then
		rev "$PROJ_ARG" "${CHOICE//rev./}" "clean"
		return 0;
	fi

	cd "$PWD_"
	return 0;
}

rev() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mrev\e[0m : to open a branch for review"
		echo " \e[93mrev <branch>\e[0m : to open $Z_PROJECT_SHORT_NAME's branch for review"
		if [[ -n "$Z_PROJECT_SHORT_NAME_1" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_1" ]]; then
			echo " \e[93mrev $Z_PROJECT_SHORT_NAME_1 \e[33m[<branch>]\e[0m : to open $Z_PROJECT_SHORT_NAME_1's branch for review"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_2" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_2" ]]; then
			echo " \e[93mrev $Z_PROJECT_SHORT_NAME_2 \e[33m[<branch>]\e[0m : to open $Z_PROJECT_SHORT_NAME_2's branch for review"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_3" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_3" ]]; then
			echo " \e[93mrev $Z_PROJECT_SHORT_NAME_3 \e[33m[<branch>]\e[0m : to open $Z_PROJECT_SHORT_NAME_3's branch for review"
		fi
		return 0;
	fi

	local PROJ_ARG="$Z_PROJECT_SHORT_NAME"
	local BRANCH_ARG=""

	if [[ -n "$2" ]]; then
		PROJ_ARG="$1"
		BRANCH_ARG="$2"
	elif [[ -n "$1" ]]; then
		if [[ "$1" == "$Z_PROJECT_SHORT_NAME_1" || "$1" == "$Z_PROJECT_SHORT_NAME_2" || "$1" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			PROJ_ARG="${1:-$Z_PROJECT_SHORT_NAME}"
		else
			BRANCH_ARG="$1"
		fi
	fi

	local PROJ_REPO=""
	local PROJ_FOLDER=""
	local SETUP="";
	local CLONE="";
	local CODE_EDITOR="$Z_CODE_EDITOR";

	if [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_1" ]]; then
		check_prj_1_; if [ $? -ne 0 ]; then return 1; fi
		PROJ_REPO="$Z_PROJECT_REPO_1"
		PROJ_FOLDER="$Z_PROJECT_FOLDER_1"
		SETUP="$Z_SETUP_1"
		CLONE="$Z_CLONE_1"
		CODE_EDITOR="$Z_CODE_EDITOR_1"

	elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_2" ]]; then
		check_prj_2_; if [ $? -ne 0 ]; then return 1; fi
		PROJ_REPO="$Z_PROJECT_REPO_2"
		PROJ_FOLDER="$Z_PROJECT_FOLDER_2"
		SETUP="$Z_SETUP_2"
		CLONE="$Z_CLONE_2"
		CODE_EDITOR="$Z_CODE_EDITOR_2"

	elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
		check_prj_3_; if [ $? -ne 0 ]; then return 1; fi
		PROJ_REPO="$Z_PROJECT_REPO_3"
		PROJ_FOLDER="$Z_PROJECT_FOLDER_3"
		SETUP="$Z_SETUP_3"
		CLONE="$Z_CLONE_3"
		CODE_EDITOR="$Z_CODE_EDITOR_3"

	else
		echo " not a valid project: $PROJ_ARG"
		echo "  \e[93mrev -h\e[0m for help"
		return 1;
	fi

	if [[ -z "$PROJ_REPO" || -z "$PROJ_FOLDER" ]]; then
		check_prj_;
		return 1;
	fi

	local PWD_="$(PWD)";

	local BRANCH="";
	# local SHORTEN_FOLDER="$(shorten_path_ "$PROJ_FOLDER")"

	if [[ -z "$3" ]]; then
		open_prj_for_git_ "$PROJ_FOLDER"; if [ $? -ne 0 ]; then return 1; fi

		git fetch origin --quiet

		if [[ -z "$1" || -z "$BRANCH_ARG" ]]; then
			select_pr_;
			if [ $? -ne 0 ]; then
				cd "$PWD_"
				return 1;
			fi

			if [[ -n "$PR_CHOICE_" ]]; then
				echo " \e[38;5;218mpreparing to create review for PR: $PR_TITLE_\e[0m"
				rev "$PROJ_ARG" "$PR_BRANCH_" "skip"
			fi
			cd "$PWD_"
			return 0;
		fi

		select_pr_ "$BRANCH_ARG";
		if [ $? -ne 0 ]; then
			cd "$PWD_"
			return 1;
		fi

		if [[ -n "$PR_CHOICE_" ]]; then
			echo " \e[38;5;218mpreparing to create review for PR: $PR_TITLE_\e[0m"
			rev "$PROJ_ARG" "$PR_BRANCH_" "skip"
		fi
		cd "$PWD_"
		return 0;

		echo " fatal: did not match any branch known to git: $BRANCH_ARG"
		cd "$PWD_"
		return 1;
	else
		BRANCH="$BRANCH_ARG"
	fi

	local BRANCH_FOLDER="${BRANCH//\\/-}";
	BRANCH_FOLDER="${BRANCH_FOLDER//\//-}";

	local REVS_FOLDER=""

	# check if using the PROJ_FOLDER as single clone mode
	if [[ -d "$PROJ_FOLDER/.git" ]]; then
		REVS_FOLDER="$PROJ_FOLDER-revs"
	else
		REVS_FOLDER="$PROJ_FOLDER/revs"
	fi

	local FOLDER="$REVS_FOLDER/rev.$BRANCH_FOLDER"

	if [[ -d "$FOLDER" ]]; then
		echo "\e[38;5;176m review already exist, opening $(shorten_path_ $FOLDER)\e[0m"
		cd "$FOLDER"
		
		local STATUS=$(git status --porcelain)
		if [[ -n "$STATUS" ]]; then
			if ! confirm_from_ "branch is not clean, reset?"; then
				return 0;
			fi
			echo " resetting..."
			reseta
		fi
		git checkout "$BRANCH" --quiet
		echo " pulling latest changes..."
		pull
		echo "$PACKAGE_COR $SETUP\e[0m"
		eval " $SETUP"
		eval $CODE_EDITOR .
		return 0;
	fi

	# making sure the revs folder exists
	mkdir -p "$REVS_FOLDER";
	echo "\e[38;5;176m in $(shorten_path_ $FOLDER)\e[0m"

	cd "$REVS_FOLDER"
	if command -v gum &> /dev/null; then
		gum spin --title "cloning... $PROJ_REPO" -- git clone $PROJ_REPO $FOLDER --quiet
	else
		echo " cloning... $PROJ_REPO";
		git clone $PROJ_REPO $FOLDER --quiet
	fi

	cd "$FOLDER"
	echo "$PROJECT_COR $CLONE\e[0m"
	eval $CLONE

	git checkout "$BRANCH" --quiet
	echo "$PACKAGE_COR $SETUP\e[0m"
	eval " $SETUP"
	
	eval $CODE_EDITOR .
}

# clone my project and checkout branch
clone() {
	if [[ "$1" == "" || "$1" == "-h" ]]; then
		if [[ -n "$Z_PROJECT_SHORT_NAME" ]]; then
			echo " \e[93mclone $Z_PROJECT_SHORT_NAME \e[33m[<branch>]\e[0m : to clone $Z_PROJECT_SHORT_NAME branch"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_1" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_1" ]]; then
			echo " \e[93mclone $Z_PROJECT_SHORT_NAME_1 \e[33m[<branch>]\e[0m : to clone $Z_PROJECT_SHORT_NAME_1 branch"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_2" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_2" ]]; then
			echo " \e[93mclone $Z_PROJECT_SHORT_NAME_2 \e[33m[<branch>]\e[0m : to clone $Z_PROJECT_SHORT_NAME_2 branch"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_3" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_3" ]]; then
			echo " \e[93mclone $Z_PROJECT_SHORT_NAME_3 \e[33m[<branch>]\e[0m : to clone $Z_PROJECT_SHORT_NAME_3 branch"
		fi
		return 0;
	fi

	local PROJ_ARG="$Z_PROJECT_SHORT_NAME"
	local BRANCH_ARG=""

	if [[ -n "$2" ]]; then
		PROJ_ARG="$1"
		BRANCH_ARG="$2"
	elif [[ -n "$1" ]]; then
		if [[ "$1" == "$Z_PROJECT_SHORT_NAME_1" || "$1" == "$Z_PROJECT_SHORT_NAME_2" || "$1" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			PROJ_ARG="${1:-$Z_PROJECT_SHORT_NAME}"
		else
			BRANCH_ARG="$1"
		fi
	fi

	local PROJ_REPO=""
	local PROJ_FOLDER=""
	local CLONE="";

	if [[ -n "$$PROJ_ARG" ]]; then
		if [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_1" ]]; then
			check_prj_1_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_REPO="$Z_PROJECT_REPO_1"
			PROJ_FOLDER="$Z_PROJECT_FOLDER_1"
			CLONE="$Z_CLONE_1"

		elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_2" ]]; then
			check_prj_2_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_REPO="$Z_PROJECT_REPO_2"
			PROJ_FOLDER="$Z_PROJECT_FOLDER_2"
			CLONE="$Z_CLONE_2"

		elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			check_prj_3_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_REPO="$Z_PROJECT_REPO_3"
			PROJ_FOLDER="$Z_PROJECT_FOLDER_3"
			CLONE="$Z_CLONE_3"
		fi
	fi

	if [[ -z "$PROJ_REPO" || -z "$PROJ_FOLDER" ]]; then
		check_prj_;
		return 1;
	fi

	check_git_silent_ "$PROJ_FOLDER";
	if [ $? -eq 0 ]; then # SINGLE_MODE
		echo " git repo already cloned: \e[34m$PROJ_FOLDER\e[0m"
		return 1;
	fi

	local PWD_="$(PWD)";

	if [[ -z "$BRANCH_ARG" ]]; then

		local WORK_MODE=""

		# ask user if they want to single project mode, or multiple mode
		if command -v gum &> /dev/null; then
			gum confirm ""mode:$'\e[0m'" how do you prefer to manage repos: single or multiple?"  --no-show-help --affirmative="single" --negative="multiple"
			local STATUS=$?
			if [[ $STATUS -eq 0 ]]; then
				WORK_MODE="s"
			elif [[ $STATUS -eq 1 ]]; then
				WORK_MODE="m"
			else
				return 0;
			fi
		else
		while true; do
			echo -n ""$'\e[38;5;141m'mode:$'\e[0m'" how do you prefer to manage repos: "$'\e[38;5;218m'single:$'\e[0m'" or "$'\e[38;5;218m'multiple:$'\e[0m'"? [s/m]: "
			stty -echo                  # Turn off input echo
			read -k 1 mode              # Read one character
			stty echo                   # Turn echo back on
			case "$mode" in
				[sSmM]) break ;;          # Accept only s or m (case-insensitive)
				*) echo "" ;;
			esac
		done
			WORK_MODE=$mode;
			if [[ "$WORK_MODE" == "s" || "$WORK_MODE" == "S" ]]; then
				WORK_MODE="s"
			else
				WORK_MODE="m"
			fi
			return;
		fi

		if [[ "$WORK_MODE" == "s" ]]; then

			if command -v gum &> /dev/null; then
				gum spin --title "cloning... $(shorten_path_ "$PROJ_FOLDER")" -- git clone $PROJ_REPO "$PROJ_FOLDER" --quiet
				if [ $? -ne 0 ]; then return 1; fi
			else
				git clone $PROJ_REPO "$PROJ_FOLDER"
				if [ $? -ne 0 ]; then return 1; fi
			fi

			cd "$PROJ_FOLDER"

			echo "$PROJECT_COR $CLONE\e[0m"
			eval $CLONE
			return 0;
		fi

		# multiple clone mode
	
		if command -v gum &> /dev/null; then
			gum spin --title "cleaning..." -- rm -rf "$PROJ_FOLDER/.temp"
			gum spin --title "cloning... $(shorten_path_ "$PROJ_REPO")" -- git clone $PROJ_REPO "$PROJ_FOLDER/.temp" --quiet
		else
			echo " cloning... $PROJ_REPO";
			rm -rf "$PROJ_FOLDER/.temp"
			git clone $PROJ_REPO "$PROJ_FOLDER/.temp" --quiet
		fi

	  cd "$PROJ_FOLDER/.temp"

		local DEFAULT_BRANCH_1=$(git config --get init.defaultBranch);
		local DEFAULT_BRANCH_2=$(git branch --show-current);

		if [[ "$DEFAULT_BRANCH_2" != "$DEFAULT_BRANCH_1" ]]; then
			BRANCH_ARG=$(choose_auto_one_ "choose default branch:" "$DEFAULT_BRANCH_1" "$DEFAULT_BRANCH_2");
			if [[ -z "$BRANCH_ARG" ]]; then
				cd "$PWD_"
				return 0;
			fi
		else
			BRANCH_ARG="$DEFAULT_BRANCH_1";
		fi

		cd "$PROJ_FOLDER" # go back one level
		rm -rf "$PROJ_FOLDER/.temp"

		# end of with BRANCH_ARG
	fi

	if [[ -z "$BRANCH_ARG" ]]; then
		echo " branch not found" # should never happen
		return 1;
	fi

	BRANCH_ARG="${BRANCH_ARG//\\/-}"
	BRANCH_ARG="${BRANCH_ARG//\//-}"

	if command -v gum &> /dev/null; then
		gum spin --title "cloning... $(shorten_path_ "$PROJ_FOLDER/$BRANCH_ARG")" -- git clone $PROJ_REPO "$PROJ_FOLDER/$BRANCH_ARG" --quiet
		if [ $? -ne 0 ]; then return 1; fi
	else
  	git clone $PROJ_REPO "$PROJ_FOLDER/$BRANCH_ARG"
		if [ $? -ne 0 ]; then return 1; fi
	fi

	cd "$PROJ_FOLDER/$BRANCH_ARG"
	
	git config init.defaultBranch $BRANCH_ARG

	if [[ "$BRANCH_ARG" != "$(git branch --show-current)" ]]; then
		# check if branch exist
		local REMOTE_BRANCH=$(git ls-remote --heads origin "$BRANCH_ARG")
		local LOCAL_BRANCH=$(git branch --list "$BRANCH_ARG" | head -n 1)

		if [[ -z "$REMOTE_BRANCH" && -z "$LOCAL_BRANCH" ]]; then
			git checkout -b "$BRANCH_ARG" --quiet
		else
			git checkout "$BRANCH_ARG" --quiet
		fi
		
	fi

	echo "$PROJECT_COR $CLONE\e[0m"
	eval $CLONE

	# if [[ -n "$2" ]]; then
	# 	cd "$PWD_"
	# fi
	return 0;
}

# Git -----------------------------------------------------------------------==
alias chc="git cherry-pick --continue"
alias chp="git cherry-pick" # $1
alias clean="git clean -fd -q && git restore -q ."
alias pushf="git push --no-verify --force && git push --no-verify --tags --force"
alias renb="git branch -m" # $1
alias mc="git add . && git merge --continue"
alias pop="git stash pop --index"
alias rc="git add . && git rebase --continue"
alias reset1="git log -1 --pretty=format:'%s' | xargs -0 && git reset --soft HEAD~1"
alias reset2="git log -2 --pretty=format:'%s' | xargs -0 && git reset --soft HEAD~2"
alias reset3="git log -3 --pretty=format:'%s' | xargs -0 && git reset --soft HEAD~3"
alias reset4="git log -4 --pretty=format:'%s' | xargs -0 && git reset --soft HEAD~4"
alias reset5="git log -5 --pretty=format:'%s' | xargs -0 && git reset --soft HEAD~5"
alias st="git status"
alias stashes="git stash list"

abort() {
	check_git_; if [ $? -ne 0 ]; then return 1; fi

	GIT_EDITOR=true git rebase --abort
	GIT_EDITOR=true git merge --abort
	GIT_EDITOR=true git cherry-pick --abort
}

conti() {
	check_git_; if [ $? -ne 0 ]; then return 1; fi

	git add .

	git rebase --continue
	git merge --continue
	git cherry-pick --continue
}

# Commits -----------------------------------------------------------------------
commit() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mcommit\e[0m : to commit wizard"
		echo " \e[93mcommit <message>\e[0m : to create a commit with message"
		return 0;
	fi

	check_git_; if [ $? -ne 0 ]; then return 1; fi

	#check if branch is clean
	local STATUS=$(git status --porcelain)
	if [[ -z "$STATUS" ]]; then # clean status
		st
		return 0;
	fi

	if [[ -z "$1" ]]; then
		if ! command -v gum &> /dev/null; then
			echo " fatal: commit requires gum"
			echo " install gum: \e[93mhttps://github.com/charmbracelet/gum\e[0m"
			return 0;
		fi

		local TYPE=$(gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")
		if [ ! $? -eq 0 ] || [ -z "$TYPE" ]; then
			return 0;
		fi
		local SCOPE=$(gum input --placeholder "scope")

		# Since the scope is optional, wrap it in parentheses if it has a value.
		if [[ -n "$SCOPE" ]]; then
			SCOPE="($SCOPE)"
		fi

		local SUMMARY=$(gum input --value "$TYPE$SCOPE: ")
		if [ ! $? -eq 0 ] || [ -z "$SUMMARY" ]; then
			return 0;
		fi

		# Commit these changes if user confirms
		git add .
		git commit --no-verify --message "$SUMMARY";
	else
		git add .
		git commit --no-verify --message "$1"
	fi
}

fetch() {
	check_git_; if [ $? -ne 0 ]; then return 1; fi

	if [[ -z "$1" ]]; then
		git fetch --tags --all --prune-tags --prune
	else
		local MY_BRANCH=$(git branch --show-current)

		if [[ "$MY_BRANCH" == "$1" ]]; then
			git fetch origin
		else
			git fetch origin $1:$1
		fi
	fi
}

gconf() {
	echo " \e[33mUsername:\e[0m $(git config --get user.name)"
	echo " \e[33mEmail:\e[0m $(git config --get user.email)"
	echo " \e[33mDefault branch:\e[0m $(git config --get init.defaultBranch)"
}

glog() {
	local PWD_="$(PWD)";

	open_prj_for_git_; if [ $? -ne 0 ]; then return 1; fi
	
	git fetch origin --quiet

	git log -15 --graph --abbrev-commit --pretty=format:'%C(magenta)%h%Creset ~%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset';

	cd "$PWD_"
}

push() {
	check_git_; if [ $? -ne 0 ]; then return 1; fi

	local MY_BRANCH=$(git branch --show-current)

	fetch

	git push --no-verify --set-upstream origin $MY_BRANCH
}

stash() {
	check_git_; if [ $? -ne 0 ]; then return 1; fi

	git stash push --include-untracked --message "${1:-.}"
}

detag() {
	dtag "$@"
}

dtag() {
	if [[ -z "$1" ]] || [[ "$1" == "-h" ]]; then
		echo " \e[93mdtag <name>\e[0m : to delete tag"
		return 0;
	fi

	local PWD_="$(PWD)";

	open_prj_for_git_; if [ $? -ne 0 ]; then return 1; fi
	
	git fetch --tags --prune-tags

	git tag -d $1
	if [ $? -ne 0 ]; then
		cd "$PWD_"
		return 1;
	fi

	git push origin --delete $1
	cd "$PWD_"
}

pull() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mpull\e[0m : to pull all branches"
		echo " \e[93mpull tags\e[0m : to pull all tags"
		return 0;
	fi

	# let git command fail

	if [[ "$1" == "tags" ]] then
		git pull --tags --all
	else
		git pull --all --rebase "$@"
	fi
}

tag() {
	if [[ -z "$1" ]] || [[ "$1" == "-h" ]]; then
		echo " \e[93mtag <name>\e[0m : to create a new tag"
		return 0;
	fi

	local PWD_="$(PWD)";

	open_prj_for_git_; if [ $? -ne 0 ]; then return 1; fi
	
	prune

	git tag --annotate $1 --message $1
	if [ $? -ne 0 ]; then
		cd "$PWD_"
		return 1;
	fi

	git push --no-verify --tags
	cd "$PWD_"
}

ltag() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mltag\e[0m : to display last tag"
		return 0;
	fi

	local PWD_="$(PWD)";

	open_prj_for_git_; if [ $? -ne 0 ]; then return 1; fi
	
	git fetch --tags --prune-tags

	tags 1

	cd "$PWD_"
}

tags() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mtags\e[0m : to list all tags"
		echo " \e[93mtags <x>\e[0m : to list x number of tags"
		return 0;
	fi

	local PWD_="$(PWD)";

	open_prj_for_git_; if [ $? -ne 0 ]; then return 1; fi

	# prune

	local TAG=""

	if [[ -z "$1" ]]; then
		TAG=$(git for-each-ref refs/tags --sort=-taggerdate --format='%(refname:short)')

		if [[ -z "$TAG" ]]; then
			TAG=$(git for-each-ref refs/tags --sort=-committerdate --format='%(refname:short)')
		fi
	else
		TAG=$(git for-each-ref refs/tags --sort=-taggerdate --format='%(refname:short)' --count=$1)

		if [[ -z "$TAG" ]]; then
			TAG=$(git for-each-ref refs/tags --sort=-committerdate --format='%(refname:short)' --count=$1)
		fi
	fi

	if [[ -z "$TAG" ]]; then
		echo " no tags found"
	else
		echo "$TAG"
	fi

	cd "$PWD_"
}

restore() {
	check_git_; if [ $? -ne 0 ]; then return 1; fi

  git restore -q .
}

reseta() {
	check_git_; if [ $? -ne 0 ]; then return 1; fi

	# check if current branch exists in remote
	local REMOTE_BRANCH=$(git ls-remote --heads origin "$(git branch --show-current)")

	if [[ -n "$REMOTE_BRANCH" ]]; then
		git reset --hard origin/$(git branch --show-current)
	else
		git reset --hard
	fi
	clean
}

open_prj_for_git_() {
	local PWD_="$(PWD)"
	local PROJ_FOLDER=${1:-$PWD_};

	check_git_silent_ "$PROJ_FOLDER"
	if [ $? -ne 0 ]; then
		cd "$PROJ_FOLDER"

		local FOLDER=""
		local folders=("main" "master" "stage" "staging" "dev" "develop")

		# Loop through each folder name
		for defaultFolder in "${folders[@]}"; do
	    if [[ -d "$defaultFolder" ]]; then
        check_git_silent_ "$defaultFolder"
        if [ $? -eq 0 ]; then
        	FOLDER="$defaultFolder"
        	break;
        fi
	    fi
		done

		if [[ -z "$FOLDER" ]]; then
			for i in */; do
				if [[ -d "$i/.git" ]]; then
					FOLDER="$i";
					break;
				fi
			done
		fi

		if [[ -z "$FOLDER" ]]; then
			echo " no git folder in $PROJ_FOLDER"
			cd "$PWD_"
			return 1;
		fi

		cd "$FOLDER"
	fi
}

# List branches -----------------------------------------------------------------------
# list remote branches that contains an optional text and adds a link to the branch in github
glr() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mgll\e[0m : to list remote branches"
		echo " \e[93mgll <branch>\e[0m : to list remote branches matching branch"
		return 0;
	fi

	local PWD_="$(PWD)";

	open_prj_for_git_; if [ $? -ne 0 ]; then return 1; fi

	git fetch origin --quiet

	git branch -r --list "*$1*" --sort=authordate --format='%(authordate:format:%m-%d-%Y) %(align:17,left)%(authorname)%(end) %(refname:strip=3)' | sed \
    -e 's/\([0-9]*-[0-9]*-[0-9]*\)/\x1b[32m\1\x1b[0m/' \
    -e 's/\([^\ ]*\)$/\x1b[34m\x1b]8;;https:\/\/github.com\/wmgtech\/wmg2-one-app\/tree\/\1\x1b\\\1\x1b]8;;\x1b\\\x1b[0m/'

  cd "$PWD_"
}

# list only local branches that contains an optional text
gll() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mgll\e[0m : to list local branches"
		echo " \e[93mgll <branch>\e[0m : to list local branches matching <branch>"
		return 0;
	fi
	
	local PWD_="$(PWD)";

	open_prj_for_git_; if [ $? -ne 0 ]; then return 1; fi

	git branch --list "*$1*" --sort=authordate --format="%(authordate:format:%m-%d-%Y) %(align:17,left)%(authorname)%(end) %(refname:strip=2)" | sed \
		-e 's/\([0-9]*-[0-9]*-[0-9]*\)/\x1b[32m\1\x1b[0m/' \
	  -e 's/\([^ ]*\)$/\x1b[34m\1\x1b[0m/'

  cd "$PWD_"
}

shorten_path_() {
	local FOLDER=${1:-$(PWD)};

	if [[ -z "$2" ]]; then
		echo "$(basename "$(dirname "$FOLDER")")/$(basename "$FOLDER")"
	else
		echo "$(basename "$FOLDER")"
	fi
}

choose_branch_() {
	local CHOICE=$(choose_auto_one_ "$2" $(echo "$1" | tr ' ' '\n'))
	if [[ $? -ne 0 || -z "$CHOICE" ]]; then
		echo ""
	else
		echo "$CHOICE"
	fi
}

filter_branch_() {
	local CHOICE=$(echo "$1" | gum filter --limit 1 --placeholder " $2")
	if [[ $? -ne 0 || -z "$CHOICE" ]]; then
		echo ""
	else
		echo "$CHOICE"
	fi
}

local CHOICE_=""
local PR_CHOICE_=""
local PR_TITLE_=""
local PR_BRANCH_=""

# select_branch_ -a <search> <header>
select_branch_() {
	local BRANCHES=$(git branch "$1" --list --format="%(refname:strip=2)" | grep -i "${2//[^a-zA-Z0-9]/}" | sed 's/^[* ]*//g' | sed -e 's/HEAD//' | sed -e 's/remotes\///' | sed -e 's/HEAD -> origin\///' | sed -e 's/origin\///' | sort -fu)
	local BRANCH_COUNT=$(echo "$BRANCHES" | wc -l)

	if [[ -n "$BRANCHES" ]]; then
		if [ $BRANCH_COUNT -gt 10 ]; then
			CHOICE_=$(filter_branch_ "$BRANCHES" ${@:3})
		else
			CHOICE_=$(choose_branch_ "$BRANCHES" ${@:3})
		fi
		return 0;
	fi
	return 1;
}

select_pr_() {
	local pr_list=$(gh pr list | grep -i "${1//[^a-zA-Z0-9]/}" | awk -F'\t' '{print $1 "\t" $2 "\t" $3}');
	local PRS_COUNT=$(echo "$pr_list" | wc -l);

	if [[ -n "$pr_list" ]]; then
		local titles=$(echo "$pr_list" | cut -f2);

		if [ $PRS_COUNT -gt 10 ]; then
			PR_TITLE_=$(echo "$titles" | gum filter --select-if-one --height 30 --placeholder " search pull request:");
		else
			PR_TITLE_=$(echo "$titles" | gum choose --select-if-one --height 30 --header " choose pull request:");
		fi

		PR_CHOICE_="$(echo "$pr_list" | awk -v title="$PR_TITLE_" -F'\t' '$2 == title {print $1}')"
		PR_BRANCH_="$(echo "$pr_list" | awk -v title="$PR_TITLE_" -F'\t' '$2 == title {print $3}')"

		return 0;
	fi

	return 1;
}

local LAST_WORKFLOW=""
local LAST_WORKFLOW_PROJ=""

gha_() {
	local PWD_="$(PWD)";

	if [[ -n "$LAST_WORKFLOW_PROJ" ]]; then
		check_git_ "$LAST_WORKFLOW_PROJ";
		if [ $? -ne 0 ]; then
			return 1;
		fi
		
		cd "$LAST_WORKFLOW_PROJ"
	fi

	local RUN_STATUS=$(gh run list --workflow "$LAST_WORKFLOW" --limit 1 --json conclusion --jq '.[0].conclusion' 2>/dev/null)

	if [[ -z "$RUN_STATUS" ]]; then
		echo ""
		echo "\a ⚠️ No workflow runs found for '$LAST_WORKFLOW'"

		local end=$((SECONDS+2))
		while [ $SECONDS -lt $end ]; do
			echo -e "\a"
			sleep 0.1
		done
		return 1
	fi

	# Output status with emoji
	if [[ "$RUN_STATUS" == "success" ]]; then
		echo ""
		echo " ✅ Workflow '$LAST_WORKFLOW' passed!"
	else
		echo ""
		echo "\a ❌ Workflow '$LAST_WORKFLOW' failed (status: $RUN_STATUS)"
		
		local end=$((SECONDS+2))
		while [ $SECONDS -lt $end ]; do
			echo -e "\a"
			sleep 0.1
		done
		return 1
	fi

	cd "$PWD_"
}

gha() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mgha\e[0m : to view last workflow run in current project"
		echo " \e[93mgha \e[33m[<workflow>]\e[0m : to view last run for a workflow in current project"
		if [[ -n "$Z_PROJECT_SHORT_NAME_1" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_1" ]]; then
			echo " \e[93mgha $Z_PROJECT_SHORT_NAME_1 \e[33m[<workflow>]\e[0m : to view $Z_PROJECT_SHORT_NAME_1's last workflow run"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_2" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_2" ]]; then
			echo " \e[93mgha $Z_PROJECT_SHORT_NAME_2 \e[33m[<workflow>]\e[0m : to view $Z_PROJECT_SHORT_NAME_2's last workflow run"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_3" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_3" ]]; then
			echo " \e[93mgha $Z_PROJECT_SHORT_NAME_3 \e[33m[<workflow>]\e[0m : to view $Z_PROJECT_SHORT_NAME_3's last workflow run"
		fi
		return 0;
	fi

	local WORKFLOW="$LAST_WORKFLOW";
	local PROJ_ARG="$LAST_WORKFLOW_PROJ"

	if [[ -n "$2" ]]; then
		PROJ_ARG="$1"
		WORKFLOW="$2"
	elif [[ -n "$1" ]]; then
		if [[ "$1" == "$Z_PROJECT_SHORT_NAME_1" || "$1" == "$Z_PROJECT_SHORT_NAME_2" || "$1" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			PROJ_ARG="$1"
		else
			WORKFLOW="$1"
		fi
	fi

	local PROJ_FOLDER="$(PWD)"
	local GHA_INTERVAL=30;

	if [[ -n "$PROJ_ARG" ]]; then
		if [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_1" ]]; then
			check_prj_1_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_1"
			GHA_INTERVAL=$Z_GHA_INTERVAL_1

		elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_2" ]]; then
			check_prj_2_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_2"
			GHA_INTERVAL=$Z_GHA_INTERVAL_2

		elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			check_prj_3_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_3"
			GHA_INTERVAL=$Z_GHA_INTERVAL_3
		fi
	fi

	local PWD_="$(PWD)";

	if [[ -n "$PROJ_FOLDER" ]]; then
		check_git_ "$PROJ_FOLDER";
		if [ $? -ne 0 ]; then
			return 1;
		fi
		
		cd "$PROJ_FOLDER"
	fi

	if [[ -z "$WORKFLOW" ]]; then
		local WK_LIST=$(gh workflow list | cut -f1)
		if [[ -z "$WK_LIST" || "$WK_LIST" == "No workflows found" ]]; then
			echo " no workflows found"
			cd "$PWD_"
			return 1;
		fi
		
		WORKFLOW=$(gum choose --header " choose workflow:" "$WK_LIST");
		if [[ $? -ne 0 || -z "$WORKFLOW" ]]; then
			cd "$PWD_"
			return 1;
		fi
	fi

	if [[ -z "$LAST_WORKFLOW" ]]; then
		LAST_WORKFLOW="$WORKFLOW"
		LAST_WORKFLOW_PROJ="$PROJ_FOLDER"
		gha_
	else
		if [[ $GHA_INTERVAL -gt 0 ]]; then
			echo " running gha every $GHA_INTERVAL minutes"
			echo " press cmd+c to stop"

			while true; do
				echo "Running gha at $(date)"
				gha_
				echo "Sleeping $GHA_INTERVAL minutes..."
				sleep $(($GHA_INTERVAL * 60 * 60))
			done
		else
			gha_
		fi
	fi
}

co() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mco\e[0m : to list local branches to switch"
		echo " \e[93mco pr\e[0m : to list PRs to check out"
		echo " \e[93mco -r\e[0m : to list remote branches only"
		echo " \e[93mco -a\e[0m : to list all branches"
		echo " --"
		echo " \e[93mco <branch>\e[0m : to switch to an existing branch"
		echo " \e[93mco -e <branch>\e[0m : to switch to exact branch"
		echo " \e[93mco -b <branch>\e[0m : to create branch off of current HEAD"
	  echo " \e[93mco <branch> <base_branch>\e[0m : to create branch off of base branch"
		return 0;
	fi

	check_git_; if [ $? -ne 0 ]; then return 1; fi

	git fetch origin --quiet

	local SHORTEN_FOLDER="$(shorten_path_)"
	local _PAST_BRANCH="$(git branch --show-current)"

	# co (no arguments) local branches
	if [[ -z "$1" ]]; then
		select_branch_ --list "$1" "search local branches:"

		if [ $? -ne 0 ]; then
			echo " no branches matching '$2'"
		fi
		if [[ -n "$CHOICE_" ]]; then
			co -e $CHOICE_
			if [ $? -eq 0 ]; then return 0; else return 1; fi
		fi
		return 0;
	fi

	# co pr
	if [[ "$1" == "pr" ]]; then
		select_pr_ "$2";

		if [ $? -ne 0 ]; then
			return 1;
		fi
		if [[ -n "$PR_CHOICE_" ]]; then
			echo " checking out PR: $PR_TITLE_"
			gh pr checkout $PR_CHOICE_
		fi
		return 0;
	fi

	# co -a all branches
	if [[ "$1" == "-a" ]]; then
		select_branch_ -a "$2" "search all branches:"

		if [ $? -ne 0 ]; then
			echo " no branches matching '$2'"
		fi
		if [[ -n "$CHOICE_" ]]; then
			co -e $CHOICE_
			if [ $? -eq 0 ]; then return 0; else return 1; fi
		fi
		return 0;
	fi

	# co -r remote branches
	if [[ "$1" == "-r" ]]; then
		select_branch_ -r "$2" "search remote branches:"
		
		if [ $? -ne 0 ]; then
			echo " no branches matching '$2'"
		fi
		if [[ -n "$CHOICE_" ]]; then
			co -e $CHOICE_
			if [ $? -eq 0 ]; then return 0; else return 1; fi
		fi
		return 0;
	fi

	# co -b BRANCH create branch
	if [[ "$1" == "-b" ]]; then
		if [[ -n "$2" ]]; then
			_PAST_BRANCH="$(git branch --show-current)"
			if git checkout -b $2 >/dev/null 2>&1; then
				PAST_BRANCH="$_PAST_BRANCH"
				return 0;
			fi
			echo " did not match any branch known to git: $2"
		else
			echo " branch is required"
			echo "  \e[93mco -b <branch>\e[0m : to create branch off of current HEAD"
		fi
		return 1;
	fi

	# co -e BRANCH just checkout, do not create branch
	if [[ "$1" == "-e" ]]; then
		if [[ -n "$2" ]]; then
 			_PAST_BRANCH="$(git branch --show-current)"
			if git switch $2 >/dev/null 2>&1; then
				PAST_BRANCH="$_PAST_BRANCH"
				return 0;
			fi
			echo " did not match any branch known to git: $2"
		else
			echo " branch is required"
			echo "  \e[93mco -e <branch>\e[0m : to switch to exact branch"
		fi
		return 1;
	fi

	# co BRANCH
	if [[ -z "$2" ]]; then
		select_branch_ -a "$1" "search branches:"

		if [ $? -ne 0 ]; then
			echo " no branches matching '$2'"
		fi
		if [[ -n "$CHOICE_" ]]; then
			co -e $CHOICE_
			if [ $? -eq 0 ]; then return 0; else return 1; fi
		fi
		return 0;
	fi

	local BRANCH="$1"

	# co BRANCH BASE_BRANCH
	local CHOICES=$(git branch -a --list --format="%(refname:strip=2)" | grep -i "${2//[^a-zA-Z0-9]/}" | sed 's/^[* ]*//g' | sed -e 's/HEAD//' | sed -e 's/remotes\///' | sed -e 's/HEAD -> origin\///' | sed -e 's/origin\///' | sort -fu)
	if [[ $? -ne 0 || -z "$CHOICES" ]]; then
		echo " did not match any branch known to git: $2"
		return 1;
	fi
	local USER_BASE_BRANCH=$(choose_auto_one_ "search base branch:" $(echo "$CHOICES" | tr ' ' '\n'))
	if [[ -z "$USER_BASE_BRANCH" ]]; then
		return 0;
	fi

	git switch $USER_BASE_BRANCH --quiet
	if [ $? -ne 0 ]; then return 1; fi
	pull --quiet
	git branch $BRANCH $USER_BASE_BRANCH
	if [ $? -ne 0 ]; then return 1; fi
	git switch $BRANCH
	if [ $? -ne 0 ]; then return 1; fi
	PAST_BRANCH="$_PAST_BRANCH"
}

back() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mback\e[0m : to go back to previous branch"
		return 0;
	fi

	check_git_; if [ $? -ne 0 ]; then return 1; fi

	if [[ -n "$PAST_BRANCH" ]]; then
		co "$PAST_BRANCH"
	fi
}

# checkout dev or develop branch
dev() {
	if [[ "$1" == "-h" ]]; then
			echo " \e[93mdev\e[0m : to switch to dev in current project"
		if [[ -n "$Z_PROJECT_SHORT_NAME_1" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_1" ]]; then
			echo " \e[93mdev $Z_PROJECT_SHORT_NAME_1 \e[0m : to switch to dev in $Z_PROJECT_SHORT_NAME_1"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_2" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_2" ]]; then
			echo " \e[93mdev $Z_PROJECT_SHORT_NAME_2 \e[0m : to switch to dev in $Z_PROJECT_SHORT_NAME_2"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_3" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_3" ]]; then
			echo " \e[93mdev $Z_PROJECT_SHORT_NAME_3 \e[0m : to switch to dev in $Z_PROJECT_SHORT_NAME_3"
		fi
		return 0;
	fi

	local PROJ_FOLDER="$(PWD)"

	if [[ -n "$1" ]]; then
		if [[ "$1" == "$Z_PROJECT_SHORT_NAME_1" ]]; then
			check_prj_1_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_1"

		elif [[ "$1" == "$Z_PROJECT_SHORT_NAME_2" ]]; then
			check_prj_2_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_2"

		elif [[ "$1" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			check_prj_3_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_3"

		else
			echo " not a valid project: $1"
			echo "  \e[93mdev -h\e[0m for help"
			return 1;
		fi
	fi

	local PWD_="$(PWD)"
	
	local FOLDER=""
	local folders=("$PROJ_FOLDER" "$PROJ_FOLDER/dev" "$PROJ_FOLDER/develop")

	# Loop through each folder name
	for defaultFolder in "${folders[@]}"; do
    if [[ -d "$defaultFolder" ]]; then
      check_git_silent_ "$defaultFolder"
      if [ $? -eq 0 ]; then
      	FOLDER="$defaultFolder"
      	break;
      fi
    fi
	done

	if [[ -z "$FOLDER" ]]; then
		cd "$PWD_"
		return 1;
	fi

	eval "$1"
	cd "$FOLDER"

	if [[ -n "$(git branch -a --list | grep -w dev)" ]]; then
		co -e dev
	elif [[ -n "$(git branch -a --list | grep -w develop)" ]]; then
		co -e develop
	else
		echo " fatal: dev or develop branch is not known to git";
		cd "$PWD_"
	fi
}

# checkout main branch
main() {
	if [[ "$1" == "-h" ]]; then
			echo " \e[93mmain\e[0m : to switch to main in current project"
		if [[ -n "$Z_PROJECT_SHORT_NAME_1" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_1" ]]; then
			echo " \e[93mmain $Z_PROJECT_SHORT_NAME_1 \e[0m : to switch to main in $Z_PROJECT_SHORT_NAME_1"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_2" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_2" ]]; then
			echo " \e[93mmain $Z_PROJECT_SHORT_NAME_2 \e[0m : to switch to main in $Z_PROJECT_SHORT_NAME_2"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_3" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_3" ]]; then
			echo " \e[93mmain $Z_PROJECT_SHORT_NAME_3 \e[0m : to switch to main in $Z_PROJECT_SHORT_NAME_3"
		fi
		return 0;
	fi

	local PROJ_FOLDER="$(PWD)"

	if [[ -n "$1" ]]; then
		if [[ "$1" == "$Z_PROJECT_SHORT_NAME_1" ]]; then
			check_prj_1_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_1"

		elif [[ "$1" == "$Z_PROJECT_SHORT_NAME_2" ]]; then
			check_prj_2_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_2"

		elif [[ "$1" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			check_prj_3_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_3"

		else
			echo " not a valid project: $1"
			echo "  \e[93mmain -h\e[0m for help"
			return 1;
		fi
	fi

	local PWD_="$(PWD)"
	
	local FOLDER=""
	local folders=("$PROJ_FOLDER" "$PROJ_FOLDER/main" "$PROJ_FOLDER/master")

	# Loop through each folder name
	for defaultFolder in "${folders[@]}"; do
    if [[ -d "$defaultFolder" ]]; then
      check_git_silent_ "$defaultFolder"
      if [ $? -eq 0 ]; then
      	FOLDER="$defaultFolder"
      	break;
      fi
    fi
	done

	if [[ -z "$FOLDER" ]]; then
		cd "$PWD_"
		return 1;
	fi

	eval "$1"
	cd "$FOLDER"

	if [[ -n "$(git branch -a --list | grep -w main)" ]]; then
		co -e main
	elif [[ -n "$(git branch -a --list | grep -w master)" ]]; then
		co -e master
	else
		echo " fatal: main or master branch is not known to git";
		cd "$PWD_"
	fi
}

# checkout stage branch
stage() {
	if [[ "$1" == "-h" ]]; then
			echo " \e[93mstage\e[0m : to switch to stage in current project"
		if [[ -n "$Z_PROJECT_SHORT_NAME_1" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_1" ]]; then
			echo " \e[93mstage $Z_PROJECT_SHORT_NAME_1 \e[0m : to switch to stage in $Z_PROJECT_SHORT_NAME_1"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_2" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_2" ]]; then
			echo " \e[93mstage $Z_PROJECT_SHORT_NAME_2 \e[0m : to to switch to stage in $Z_PROJECT_SHORT_NAME_2"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_3" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_3" ]]; then
			echo " \e[93mstage $Z_PROJECT_SHORT_NAME_3 \e[0m : to to switch to stage in $Z_PROJECT_SHORT_NAME_3"
		fi
		return 0;
	fi

	local PROJ_FOLDER="$(PWD)"

	if [[ -n "$1" ]]; then
		if [[ "$1" == "$Z_PROJECT_SHORT_NAME_1" ]]; then
			check_prj_1_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_1"

		elif [[ "$1" == "$Z_PROJECT_SHORT_NAME_2" ]]; then
			check_prj_2_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_2"

		elif [[ "$1" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			check_prj_3_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_3"

		else
			echo " not a valid project: $1"
			echo "  \e[93mstage -h\e[0m for help"
			return 1;
		fi
	fi

	local PWD_="$(PWD)"
	
	local FOLDER=""
	local folders=("$PROJ_FOLDER" "$PROJ_FOLDER/stage" "$PROJ_FOLDER/staging")

	# Loop through each folder name
	for defaultFolder in "${folders[@]}"; do
    if [[ -d "$defaultFolder" ]]; then
      check_git_silent_ "$defaultFolder"
      if [ $? -eq 0 ]; then
      	FOLDER="$defaultFolder"
      	break;
      fi
    fi
	done

	if [[ -z "$FOLDER" ]]; then
		cd "$PWD_"
		return 1;
	fi

	eval "$1"
	cd "$FOLDER"

	if [[ -n "$(git branch -a --list | grep -w stage)" ]]; then
		co -e stage
	elif [[ -n "$(git branch -a --list | grep -w staging)" ]]; then
		co -e staging
	else
		echo " fatal: stage or staging branch is not known to git";
		cd "$PWD_"
	fi
}

# Merging & Rebasing -----------------------------------------------------------------------=
# rebase $1 or main
rebase() {
	check_git_; if [ $? -ne 0 ]; then return 1; fi

	local MY_BRANCH=$(git branch --show-current)
	local DEFAULT_MAIN_BRANCH=$(git config --get init.defaultBranch)
	local MAIN_BRANCH="${1:-$DEFAULT_MAIN_BRANCH}"

	if [[ "$MY_BRANCH" == "$DEFAULT_MAIN_BRANCH" ]]; then
		echo " fatal: cannot rebase in branch: $MY_BRANCH";
		return 1;
	fi

	git fetch origin --quiet $MAIN_BRANCH:$MAIN_BRANCH

	echo " rebase from branch '\e[94m$MAIN_BRANCH\e[0m'"
	git rebase $MAIN_BRANCH

	if read -qs "?done! continue git push? (y/n) "; then
		echo "y"
    git push --force-with-lease --tags --no-verify --set-upstream origin $MY_BRANCH
  else
  	echo "n"
  fi
}

# merge branch $1 or default branch
merge() {
	check_git_; if [ $? -ne 0 ]; then return 1; fi

	local MY_BRANCH=$(git branch --show-current)
	local DEFAULT_MAIN_BRANCH=$(git config --get init.defaultBranch)
	local MAIN_BRANCH="${1:-$DEFAULT_MAIN_BRANCH}"

	if [[ "$MY_BRANCH" == "$DEFAULT_MAIN_BRANCH" ]]; then
		echo " fatal: cannot merge in branch: $MY_BRANCH";
		return 1;
	fi

	git fetch origin --quiet $MAIN_BRANCH:$MAIN_BRANCH

	echo " merge from branch '\e[94m$MAIN_BRANCH\e[0m'"
	git merge $MAIN_BRANCH

	if read -qs "?done! continue git push? (y/n) "; then
		echo "y"
    git push --no-verify --set-upstream origin $MY_BRANCH
  else
  	echo "n"
  fi
}

# Delete local branches ===========================================================
prune() {
	check_git_; if [ $? -ne 0 ]; then return 1; fi

	local DEFAULT_MAIN_BRANCH=$(git config --get init.defaultBranch)

	# local STATUS=$(git status --porcelain)
	# if [[ -z $STATUS ]]; then # clean status
	# 	git checkout $DEFAULT_MAIN_BRANCH --quiet
	# fi

	# delets all tags
	git tag -l | xargs git tag -d
	# fetch tags that exist in the remote
	git fetch origin --quiet --prune --prune-tags
	
	# lists all branches that have been merged into the currently checked-out branch
	# that can be safely deleted without losing any unmerged work and filters out the default branch
	git branch --merged | grep -v "^\*\\|$DEFAULT_MAIN_BRANCH" | xargs -n 1 git branch -d
	git prune "$@"
}

# list branches and select one to delete or delete $1
delb() {
	if [[ "$1" == "-h" ]]; then
		echo " \e[93mdelb -f\e[0m : to delete default braches too"
		if [[ -n "$Z_PROJECT_SHORT_NAME" ]]; then	
			echo " \e[93mdelb \e[33m[<branch>]\e[0m : to find local branches to delete"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_1" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_1" ]]; then
			echo " \e[93mdelb $Z_PROJECT_SHORT_NAME_1 \e[33m[<branch>]\e[0m : to find local branches to delete in $Z_PROJECT_SHORT_NAME_1"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_2" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_2" ]]; then
			echo " \e[93mdelb $Z_PROJECT_SHORT_NAME_2 \e[33m[<branch>]\e[0m : to find local branches to delete in $Z_PROJECT_SHORT_NAME_2"
		fi
		if [[ -n "$Z_PROJECT_SHORT_NAME_3" && "$Z_PROJECT_SHORT_NAME" != "$Z_PROJECT_SHORT_NAME_3" ]]; then
			echo " \e[93mdelb $Z_PROJECT_SHORT_NAME_3 \e[33m[<branch>]\e[0m : to find local branches to delete in $Z_PROJECT_SHORT_NAME_3"
		fi
		return 0;
	fi

	if ! command -v gum &> /dev/null; then
		echo " fatal: delb requires gum"
		echo " install gum: \e[93mhttps://github.com/charmbracelet/gum\e[0m"
		return 0;
	fi

	local PROJ_ARG=""
	local BRANCH_ARG=""

	if [[ -n "$2" ]]; then
		PROJ_ARG="$1"
		BRANCH_ARG="$2"
	elif [[ -n "$1" && "$1" != "-1" ]]; then
		if [[ "$1" == "$Z_PROJECT_SHORT_NAME_1" || "$1" == "$Z_PROJECT_SHORT_NAME_2" || "$1" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			PROJ_ARG="${1:-$Z_PROJECT_SHORT_NAME}"
		else
			BRANCH_ARG="$1"
		fi
	fi

	local PROJ_FOLDER=""

	if [[ -n "$PROJ_ARG" ]]; then
		if [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_1" ]]; then
			check_prj_1_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_1"

		elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_2" ]]; then
			check_prj_2_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_2"

		elif [[ "$PROJ_ARG" == "$Z_PROJECT_SHORT_NAME_3" ]]; then
			check_prj_3_; if [ $? -ne 0 ]; then return 1; fi
			PROJ_FOLDER="$Z_PROJECT_FOLDER_3"

		else
			echo " not a valid project: $PROJ_ARG"
			echo "  \e[93mdelb -h\e[0m for help"
			return 1;
		fi
	else
		PROJ_FOLDER="$(PWD)"
	fi

	local PWD_="$(PWD)";

	cd "$PROJ_FOLDER"
	check_git_silent_;

	# PROJ_FOLDER is git
	if [ $? -eq 0 ]; then
		# delb (no arguments)
		if [[ -z "$BRANCH_ARG" ]] || [[ "$1" == "-f" ]]; then
			local CHOICES="";
			if [[ "$1" == "-f" ]]; then
				CHOICES=$(git branch | grep -v '^\*' | cut -c 3- | sort -fu);
			else
				CHOICES=$(git branch | grep -v '^\*' | cut -c 3- | grep -vE '^(main|dev|stage)$' | sort -fu);
			fi
			if [[ -n "$CHOICES" ]]; then
				echo "$CHOICES" | gum choose --no-limit --header " choose branches to delete" | xargs git branch -D
			else
				echo " no branches found to delete in \e[96m$(shorten_path_ $PROJ_FOLDER)\e[0m"
			fi
		else # delb BRANCH
			local BRANCH_SEARCH="${BRANCH_ARG//\*/}"
			local BRANCH=$(git branch | grep -w "$BRANCH_SEARCH" | cut -c 3- | head -n 1)
			if [[ -z "$BRANCH" ]]; then
				echo " no branches matching: \e[94m$BRANCH_SEARCH\e[0m in \e[96m$(shorten_path_ $PROJ_FOLDER)\e[0m"
			else
				local CONFIRM_MSG="delete "$'\e[33m'$BRANCH:$'\e[0m'" in "$'\e[94m'$(shorten_path_ $PROJ_FOLDER)$'\e[0m'"?"
				if confirm_from_ $CONFIRM_MSG; then
					git branch -D $BRANCH
				fi
			fi
		fi

		cd "$PWD_"
		return 0;
	fi

	# where PROJ_FOLDER is not git, go through all folders in PROJ_FOLDER
	# delb (no arguments)
	if [[ -z "$BRANCH_ARG" ]] || [[ "$1" == "-f" ]]; then
		for i in */; do
			cd "$PROJ_FOLDER/$i"
			if [[ -d ".git" || $(is_git_repo) -eq 0 ]]; then
				cd "$PROJ_FOLDER/$i"
				local CHOICES="";
				if [[ "$1" == "-f" ]]; then
					CHOICES=$(git branch | grep -v '^\*' | cut -c 3- | sort -fu);
				else
					CHOICES=$(git branch | grep -v '^\*' | cut -c 3- | grep -vE '^(main|dev|stage)$' | sort -fu);
				fi
				if [[ -n "$CHOICES" ]]; then
					echo " branches in \e[96m$(shorten_path_ $PROJ_FOLDER/$i)\e[0m"
					echo "$CHOICES" | gum choose --no-limit --header " choose branches to delete" | xargs git branch -D
				else
					echo " no branches in \e[96m$(shorten_path_ $PROJ_FOLDER/$i)\e[0m"
				fi
			fi
		done

		cd "$PWD_"
		return 0;
	fi

	# where PROJ_FOLDER is not git, go through all folders in PROJ_FOLDER
	# delb BRANCH
	for i in */; do
		cd "$PROJ_FOLDER/$i"
		if [[ -d ".git" || $(is_git_repo) -eq 0 ]]; then
			cd "$PROJ_FOLDER/$i"
			local BRANCH_SEARCH="${BRANCH_ARG//\*/}"
			local BRANCH=$(git branch | grep -w "$BRANCH_SEARCH" | cut -c 3- | head -n 1)
			if [[ -z "$BRANCH" ]]; then
				echo " no branches matching: \e[94m$BRANCH_SEARCH\e[0m in \e[96m$(shorten_path_ $PROJ_FOLDER/$i)\e[0m"
			else
				local CONFIRM_MSG="delete "$'\e[33m'$BRANCH:$'\e[0m'" in "$'\e[94m'$(shorten_path_ $PROJ_FOLDER/$i)$'\e[0m'"?"
				if confirm_from_ $CONFIRM_MSG; then
					git branch -D $BRANCH
				fi
			fi
		fi
	done

	cd "$PWD_"
}
