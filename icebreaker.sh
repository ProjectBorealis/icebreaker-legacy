#!/usr/bin/env bash

version="2.5.4"
declare -a all_modules=("Ravenholm" "Episode3" "Development" "Imported" "Shared")
declare -a standard_nodes=("maps" "sounds" "music" "materials" "models" "particles")
declare -a import_nodes=("sounds" "music" "materials" "models" "particles" "maps/d1_town_01")
declare -a share_nodes=("sounds" "materials" "models" "particles")

# resolve shell-specifics
case "$(echo "$SHELL" | sed -E 's|/usr(/local)?||g')" in
    "/bin/zsh")
        RCPATH="$HOME/.zshrc"
        if [[ ! -f "$RCPATH" ]]; then
            touch "$RCPATH"
        fi
        SOURCE="${BASH_SOURCE[0]:-${(%):-%N}}"
    ;;
    *)
        RCPATH="$HOME/.bashrc"
        if [[ -f "$HOME/.bash_aliases" ]]; then
            RCPATH="$HOME/.bash_aliases"
        fi
        if [[ ! -f "$RCPATH" ]]; then
            touch "$RCPATH"
        fi
        SOURCE="${BASH_SOURCE[0]}"
    ;;
esac

# get base dir regardless of execution location
while [[ -h "$SOURCE" ]]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SOURCE=$([[ "$SOURCE" = /* ]] && echo "$SOURCE" || echo "$PWD/${SOURCE#./}")
basedir=$(dirname "$SOURCE")

# source our helper scripts
source "$basedir/scripts/functions.sh"
source "$basedir/scripts/git-wrappers.sh"

case "$1" in
    "b" | "branch" | "switch")
    (
        if [[ -z "$3" ]]; then
          printf "branch: Switch to an existing branch, or create a new one if it does not exist.\n"
          printf "$(color 1)Usage:$(colorend) branch branch_name nodes...\n"
        else
          cd "$basedir"
          git gc --auto
          (git submodule foreach "git gc --auto") &>/dev/null
          for ((i = 3; i <= $#; i++ )); do
            module=${!i}
            if [[ $module = "all" ]]; then
              printf "$(color 1 36)$(color 1)Branching everything to $2...$(colorend)\n"
              switch $2 && printf "$(color 32)$(color 1)Branched base repo to $2.$(colorend)\n" || printf "$(color 31)$(color 1)Branching base repo to $2 failed.$(colorend)\n"
              if [[ $2 = "master" ]] || [[ $2 = "stable" ]] || [[ $2 = "dev" ]] && [[ -d "Binaries/.git/" ]]; then
                ./icebreaker.sh bin b $2
              fi
              for module_a in "${all_modules[@]}"; do
                if [[ "$module_a" = "Shared" ]]; then
                  for node in "${share_nodes[@]}"; do
                    printf "$(color 1 36)$(color 1)Branching Shared/${node} to $2...$(colorend)"
                    (cd "Content/Shared/${node}" && switch $2) && printf "$(color 32)$(color 1)Branched Shared/${node} to $2.$(colorend)\n" || printf "$(color 31)$(color 1)Branching Shared/${node} to $2 failed.$(colorend)\n"
                  done
                elif [[ "$module_a" = "Imported" ]]; then
                  for node in "${import_nodes[@]}"; do
                    printf "$(color 1 36)$(color 1)Branching Imported/${node} to $2...$(colorend)\n"
                    (cd "Content/Imported/${node}" && switch $2) && printf "$(color 32)$(color 1)Branched Imported/${node} to $2.$(colorend)\n" || printf "$(color 31)$(color 1)Branching Imported/${node} to $2 failed.$(colorend)\n"
                  done
                else
                  for node in "${standard_nodes[[@]}"; do
                    printf "$(color 1 36)$(color 1)Branching ${module_a}/${node}...$(colorend)\n"
                    (cd "Content/${module_a}/${node}" && switch $2) && printf "$(color 32)$(color 1)Branched ${module_a}/${node} to $2.$(colorend)\n" || printf "$(color 31)$(color 1)Branching ${module_a}/${node} to $2 failed.$(colorend)\n"
                  done
                fi
              done
              exit 0
            elif [[ $module = "all_nodes" ]]; then
              printf "$(color 1 36)$(color 1)Branching all nodes to $2...$(colorend)\n"
              for module_a in "${all_modules[@]}"; do
                if [[ "$module_a" = "Shared" ]]; then
                  for node in "${share_nodes[@]}"; do
                    printf "$(color 1 36)$(color 1)Branching Shared/${node} to $2...$(colorend)"
                    (cd "Content/Shared/${node}" && switch $2) && printf "$(color 32)$(color 1)Branched Shared/${node} to $2.$(colorend)\n" || printf "$(color 31)$(color 1)Branching Shared/${node} to $2 failed.$(colorend)\n"
                  done
                elif [[ "$module_a" = "Imported" ]]; then
                    for node in "${import_nodes[@]}"; do
                      printf "$(color 1 36)$(color 1)Branching Imported/${node} to $2...$(colorend)\n"
                      (cd "Content/Imported/${node}" && switch $2) && printf "$(color 32)$(color 1)Branched Imported/${node} to $2.$(colorend)\n" || printf "$(color 31)$(color 1)Branching Imported/${node} to $2 failed.$(colorend)\n"
                    done
                else
                    for node in "${standard_nodes[@]}"; do
                      printf "$(color 1 36)$(color 1)Branching ${module_a}/${node}...$(colorend)\n"
                      (cd "Content/${module_a}/${node}" && switch $2) && printf "$(color 32)$(color 1)Branched ${module_a}/${node} to $2.$(colorend)\n" || printf "$(color 31)$(color 1)Branching ${module_a}/${node} to $2 failed.$(colorend)\n"
                    done
                fi
              done
              exit 0
            elif [[ $module = "base" ]]; then
              printf "$(color 1 36)$(color 1)Branching base repo to $2...$(colorend)\n"
              if [[ $2 = "master" ]] || [[ $2 = "stable" ]] || [[ $2 = "dev" ]] && [[ -d "Binaries/.git/" ]]; then
                ./icebreaker.sh bin b $2
              fi
              switch $2 && printf "$(color 32)$(color 1)Branched base repo to $2.$(colorend)\n" || printf "$(color 31)$(color 1)Branching base repo to $2 failed.$(colorend)\n"
            elif [[ $(contains "${all_modules[@]}" $module) = "y" ]]; then
              if [[ "$module" = "Shared" ]]; then
                for node in "${share_nodes[@]}"; do
                  printf "$(color 1 36)$(color 1)Branching Shared/${node} to $2...$(colorend)"
                  (cd "Content/Shared/${node}" && switch $2) && printf "$(color 32)$(color 1)Branched Shared/${node} to $2.$(colorend)\n" || printf "$(color 31)$(color 1)Branching Shared/${node} to $2 failed.$(colorend)\n"
                done
              elif [[ "$module" = "Imported" ]]; then
                for node in "${import_nodes[@]}"; do
                  printf "$(color 1 36)$(color 1)Branching Imported/${node} to $2...$(colorend)\n"
                  (cd "Content/Imported/${node}" && switch $2) && printf "$(color 32)$(color 1)Branched Imported/${node} to $2.$(colorend)\n" || printf "$(color 31)$(color 1)Branching Imported/${node} to $2 failed.$(colorend)\n"
                done
              else
                for node in "${standard_nodes[@]}"; do
                  printf "$(color 1 36)$(color 1)Branching ${module}/${node}...$(colorend)\n"
                  (cd "Content/${module}/${node}" && switch $2) && printf "$(color 32)$(color 1)Branched ${module}/${node} to $2.$(colorend)\n" || printf "$(color 31)$(color 1)Branching ${module}/${node} to $2 failed.$(colorend)\n"
                done
              fi
            else
              printf "$(color 1 36)$(color 1)Branching ${module}...$(colorend)\n"
              (cd "Content/${module}" && switch $2) && printf "$(color 32)$(color 1)Branched ${module} to $2.$(colorend)\n" || printf "$(color 31)$(color 1)Branching ${module} to $2 failed.$(colorend)\n"
            fi
          done
        fi
    )
    ;;
    "u" | "update")
    (
        set -e
        if [[ -z "$2" ]]; then
          printf "update: Gets the latest targeted changes, rather than the absolute latest from the repo.\n"
          printf "$(color 1)Usage:$(colorend) update nodes...\n"
        else
          cd "$basedir"
          git gc --auto
          (git submodule foreach "git gc --auto") &>/dev/null
          for ((i = 2; i <= $#; i++ )); do
            module=${!i}
            if [[ $module = "all" ]]; then
              printf "$(color 1 36)$(color 1)Updating everything...$(colorend)\n"
              printf "$(color 1 36)$(color 1)Updating base repo...$(colorend)\n"
              git fetch
              if [[ "$(git diff --name-only HEAD @{upstream} -- | grep "icebreaker.sh")" = "icebreaker.sh" ]]; then
                printf "$(color 31)$(color 1)Please use 'git pull' to sync the base repo.$(colorend)\n"
              else
                git pull && printf "$(color 32)$(color 1)Updated base repo.$(colorend)\n" || printf "$(color 31)$(color 1)Updating base repo failed.$(colorend)\n"
              fi
              if [[ -d "Binaries/.git/" ]]; then
                ./icebreaker.sh bin u
              fi
              printf "$(color 1 36)$(color 1)Updating all nodes...$(colorend)\n"
              git submodule update --init -j 4 && printf "$(color 32)$(color 1)Updated all nodes.$(colorend)\n" || printf "$(color 31)$(color 1)Updating all nodes failed.$(colorend)\n"
              exit 0
            elif [[ $module = "all_nodes" ]]; then
              printf "$(color 1 36)$(color 1)Updating all nodes...$(colorend)\n"
              git submodule update --init -j 4 && printf "$(color 32)$(color 1)Updated all nodes.$(colorend)\n" || printf "$(color 31)$(color 1)Updating all nodes failed.$(colorend)\n"
              exit 0
            elif [[ $module = "base" ]]; then
              printf "$(color 1 36)$(color 1)Updating base repo...$(colorend)\n"
              git fetch
              if [[ "$(git diff --name-only HEAD @{upstream} -- | grep "icebreaker.sh")" = "icebreaker.sh" ]]; then
                printf "$(color 31)$(color 1)Please use 'git pull' to sync the base repo.$(colorend)\n"
              else
                git pull && printf "$(color 32)$(color 1)Updated base repo.$(colorend)\n" || printf "$(color 31)$(color 1)Updating base repo failed.$(colorend)\n"
              fi
              if [[ -d "Binaries/.git/" ]]; then
                ./icebreaker.sh bin u
              fi
            else
              printf "$(color 1 36)$(color 1)Updating ${module}...$(colorend)\n"
              git submodule update --init -j 4 "Content/${module}" && printf "$(color 32)$(color 1)Updated ${module}.$(colorend)\n" || printf "$(color 31)$(color 31)$(color 1)Updating ${module} failed.$(colorend)\n"
            fi
          done
        fi
    )
    ;;
    "s" | "sync")
    (
        set -e
        if [[ -z "$2" ]]; then
          printf "sync: Gets the latest changes from the repo.\n"
          printf "$(color 1)Usage:$(colorend) sync nodes...\n"
        else
          cd "$basedir"
          git gc --auto
          (git submodule foreach "git gc --auto") &>/dev/null
          for ((i = 2; i <= $#; i++ )); do
            module=${!i}
            if [[ $module = "all" ]]; then
              printf "$(color 1 36)$(color 1)Syncing everything...$(colorend)\n"
              printf "$(color 1 36)$(color 1)Syncing base repo...$(colorend)\n"
              git fetch
              if [[ "$(git diff --name-only HEAD @{upstream} -- | grep "icebreaker.sh")" = icebreaker.sh ]]; then
                printf "$(color 31)$(color 1)Please use 'git pull' to sync the base repo.$(colorend)\n"
              else
                git pull && printf "$(color 32)$(color 1)Synced base repo.$(colorend)\n" || printf "$(color 31)$(color 1)Syncing base repo failed.$(colorend)\n"
              fi
              if [[ -d "Binaries/.git/" ]]; then
                ./icebreaker.sh bin u
              fi
              printf "$(color 1 36)$(color 1)Syncing all nodes...$(colorend)\n"
              git submodule update --init --remote --rebase -j 4 && printf "$(color 32)$(color 1)Synced all nodes.$(colorend)\n" || printf "$(color 31)$(color 1)Syncing all nodes failed.$(colorend)\n"
              exit 0
            elif [[ $module = "all_nodes" ]]; then
              printf "$(color 1 36)$(color 1)Syncing all nodes...$(colorend)\n"
              git submodule update --init --remote --rebase -j 4 && printf "$(color 32)$(color 1)Synced all nodes.$(colorend)\n" || printf "$(color 31)$(color 1)Syncing all nodes failed.$(colorend)\n"
              exit 0
            elif [[ $module = "base" ]]; then
              printf "$(color 1 36)$(color 1)Syncing base repo...$(colorend)\n"
              git fetch
              if [[ "$(git diff --name-only HEAD @{upstream} -- | grep "icebreaker.sh")" = "icebreaker.sh" ]]; then
                printf "$(color 31)$(color 1)Please use 'git pull' to sync the base repo.$(colorend)\n"
              else
                git pull && printf "$(color 32)$(color 1)Synced base repo.$(colorend)\n" || printf "$(color 31)$(color 1)Syncing base repo failed.$(colorend)\n"
              fi
              if [[ -d "Binaries/.git/" ]]; then
                ./icebreaker.sh bin u
              fi
            else
              printf "$(color 1 36)$(color 1)Syncing ${module}...$(colorend)\n"
              git submodule update --init --remote --rebase -j 4 "Content/${module}" && printf "$(color 32)$(color 1)Synced ${module}.$(colorend)\n" || printf "$(color 31)$(color 1)Syncing ${module} failed.$(colorend)\n"
            fi
          done
        fi
    )
    ;;
    "ph" | "publish" | "p" | "push")
    (
      OPTIND=2
      only_changes="n"
      ask_files="n"
      while getopts ":cap" opt; do
        case $opt in
          c)
            only_changes="y"
          ;;
          a)
            ask_files="e"
          ;;
          p)
            ask_files="p"
          ;;
        esac
      done
      shift "$((OPTIND-2))"
      if [[ -z "$2" ]]; then
        printf "publish: Commit and push your changes and additions to the repo.\n"
        printf "$(color 1)Usage:$(colorend) publish nodes...\n"
        printf "$(color 1)Arguments$(colorend)\n"
        printf "     -c : only publish changed files, not additions\n"
        printf "     -a : ask what files to exclude from being published\n"
      else
        cd "$basedir"
        git gc --auto
        (git submodule foreach "git gc --auto") &>/dev/null
        publish_base="n"
        for ((i = 2; i <= $#; i++ )); do
          module=${!i}
          if [[ $module = "base" ]]; then
            publish_base="y"
          elif [[ $module = "all" ]]; then
            publish_base="y"
            for module_a in "${all_modules[@]}"; do
              if [[ "$module_a" = "Shared" ]]; then
              nodes="${share_nodes[@]}"
              elif [[ "$module_a" = "Imported" ]]; then
                nodes="${import_nodes[@]}"
              else
                nodes="${standard_nodes[@]}"
              fi
              for node in $nodes; do
                if [[ $ask_files != "n" ]]; then
                  publishNode "${module_a}/${node}" $only_changes $ask_files
                else
                  (publishNode "${module_a}/${node}" $only_changes $ask_files 2>&1 | sed "s/^/[${module_a}\/${node}] /") &
                fi
              done
            done
            break
          elif [[ $module = "all_nodes" ]]; then
            for module_a in "${all_modules[@]}"; do
              if [[ "$module_a" = "Shared" ]]; then
              nodes="${share_nodes[@]}"
              elif [[ "$module_a" = "Imported" ]]; then
                nodes="${import_nodes[@]}"
              else
                nodes="${standard_nodes[@]}"
              fi
              for node in $nodes; do
                if [[ $ask_files != "n" ]]; then
                  publishNode "${module_a}/${node}" $only_changes $ask_files
                else
                  (publishNode "${module_a}/${node}" $only_changes $ask_files 2>&1 | sed "s/^/[${module_a}\/${node}] /") &
                fi
              done
            done
            exit 0
          elif [[ $(contains "${all_modules[@]}" $module) = "y" ]]; then
            if [[ "$module" = "Shared" ]]; then
              nodes="${share_nodes[@]}"
            elif [[ "$module" = "Imported" ]]; then
              nodes="${import_nodes[@]}"
            else
              nodes="${standard_nodes[@]}"
            fi
            for node in $nodes; do
              if [[ $ask_files != "n" ]]; then
                publishNode "${module}/${node}" $only_changes $ask_files
              else
                (publishNode "${module}/${node}" $only_changes $ask_files 2>&1 | sed "s/^/[${module}\/${node}] /") &
              fi
            done
          else
            if [[ $ask_files != "n" ]]; then
              publishNode "${module}" $only_changes $ask_files
            else
              (publishNode "${module}" $only_changes $ask_files 2>&1 | sed "s/^/[${module//\//\\/}] /") &
            fi
          fi
        done
        wait
        if [[ $publish_base = "y" ]]; then
          printf "$(color 1 36)$(color 1)Publishing base repo...$(colorend)\n"
          ./icebreaker.sh source encode
          if [[ $only_changes = "y" ]]; then
            git add . -u
          else
            git add . -A
          fi
          if [[ $ask_files = "e" ]] && [[ -n "$(git diff --stat --cached)" ]]; then
            printf "$(color 1)Would you like to ignore a path in the base repo(y/N)?$(colorend)\n"
            read answer
            while [[ "$answer" != "${answer#[Yy]}" ]] && [[ -n "$(git diff --stat --cached)" ]]; do
                git diff --stat --cached
                printf "$(color 1)Type the name of the path in the base repo you would like to ignore: $(colorend)\n"
                read path
                git reset -- "${path}"
                if [[ -n "$(git diff --stat --cached)" ]]; then
                  printf "$(color 1)Would you like to ignore another path in the base repo(y/N)?$(colorend)\n"
                  read answer
                fi
            done
          elif [[ $ask_files = "p" ]] && ( [[ -n "$(git diff --stat)" ]] || [[ -n "$(git ls-files -o)" ]] ); then
            printf "$(color 1)Would you like to add a path in the base repo(y/N)?$(colorend)\n"
            read answer
            while [[ "$answer" != "${answer#[Yy]}" ]] && ( [[ -n "$(git diff --stat)" ]] || [[ -n "$(cd Content/${node} && git ls-files -o)" ]] ); do
                git diff --stat
                git ls-files -o
                printf "$(color 1)Type the name of the path in the base repo you would like to add: $(colorend)\n"
                read path
                git add -- "${path}"
                if [[ -n "$(git diff --stat)" ]] || [[ -n "$(cd Content/${node} && git ls-files -o)" ]]; then
                  printf "$(color 1)Would you like to add another path in the base repo(y/N)?$(colorend)\n"
                  read answer
                fi
            done
          fi
          git commit
          git push --progress --recurse-submodules=on-demand -qu origin $(git rev-parse --abbrev-ref HEAD) && printf "$(color 32)$(color 1)Published base repo.$(colorend)\n" || printf "$(color 31)$(color 1)Publishing base repo failed.$(colorend)\n"
        fi
      fi
    )
    ;;
    "ssh")
    (
      if [[ -n "$2" ]]; then
        ssh-keygen -t rsa -C "${2}" -b 4096
        cat ~/.ssh/id_rsa.pub | clip
        printf "$(color 1)SSH key copied to clipboard. Paste it into this form: https://gitlab.com/profile/keys$(colorend)\n"
      else
        echo "Adding SSH key to SSH. If you need to generate an SSH key, please specify an email."
      fi
      if [[ "$?" -eq 0 ]]; then
        (grep "ssh-agent" "$RCPATH" > /dev/null) || (echo "eval \$(ssh-agent -s)" >> "$RCPATH")
        (grep "ssh-add" "$RCPATH" > /dev/null) || (echo "ssh-add ~/.ssh/id_rsa" >> "$RCPATH")
        eval $(ssh-agent -s)
        ssh-add ~/.ssh/id_rsa
      fi
    )
    ;;
    "setup")
    (
        if [[ ! -d "${basedir}/Binaries/.git" ]]; then
          "$basedir/icebreaker.sh" bin i
        fi
        git config submodule.fetchJobs 4
        git config lfs.locksverify true
        git config gc.autoDetach true
        git config push.recurseSubmodules on-demand
        git config status.submodulesummary 1
        if [[ "$(git config core.editor)" = "vim" ]]; then
            git config core.editor "nano"
        fi
        if [[ -f "$RCPATH" ]] ; then
            NAME="icebreaker"
            if [[ ! -z "${2+x}" ]] ; then
                NAME="$2"
            fi
            (grep "alias $NAME=" "$RCPATH" > /dev/null) && (sed -i "s|alias $NAME=.*|alias $NAME='. \"$SOURCE\"'|g" "$RCPATH") || (echo "alias $NAME='. \"$SOURCE\"'" >> "$RCPATH")
            echo "Enter this command in your terminal to use $(color 1)'$NAME'$(colorend) immediately, or restart your terminal:"
            echo "alias $NAME='. \"$SOURCE\"'"
        else
          printf "$(color 31)$(color 1)We were unable to setup the Icebreaker tool alias: $RCPATH is missing.$(colorend)\n"
        fi
    )
    ;;
    "binaries" | "bin")
    (
        case "$2" in
            "branch" | "b")
            (
              set -e
              printf "$(color 1 36)$(color 1)Branching binaries to $3...$(colorend)\n"
              (cd "$basedir/Binaries" && git gc --auto && cd "$basedir/Binaries" && git checkout $3) && printf "$(color 32)$(color 1)Branched binaries to $3.$(colorend)\n" || printf "$(color 31)$(color 1)Branching binaries to $3 failed.$(colorend)\n"
            )
            ;;
            "init" | "i")
            (
              set -e
              printf "$(color 1 36)$(color 1)Downloading binaries...$(colorend)\n"
              (cd "$basedir" && git clone git@gitlab.com:project-borealis/Binaries.git --depth 1 --no-single-branch) && printf "$(color 32)$(color 1)Downloaded binaries.$(colorend)\n" || printf "$(color 31)$(color 1)Downloading binaries failed.$(colorend)\n"
            )
            ;;
            "update" | "u")
            (
              set -e
              printf "$(color 1 36)$(color 1)Updating binaries...$(colorend)\n"
              (cd "$basedir/Binaries" && git gc --auto && cd "$basedir/Binaries" && git pull) && printf "$(color 32)$(color 1)Updated binaries.$(colorend)\n" || printf "$(color 31)$(color 1)Updating binaries failed.$(colorend)\n"
            )
            ;;
            "publish" | "p" | "ph")
            (
              printf "$(color 1 36)$(color 1)Publishing binaries...$(colorend)\n"
              commit=$(git rev-parse HEAD)
              (cd "$basedir/Binaries" && git gc --auto && cd "$basedir/Binaries" && git commit -am "Update binaries to $commit"; git push) && printf "$(color 32)$(color 1)Published binaries.$(colorend)\n" || printf "$(color 31)$(color 1)Publishing binaries failed.$(colorend)\n"
            )
            ;;
            *)
              echo "Binaries subcommands:"
              echo ""
              echo " * init                    | setup getting binaries from git"
              echo " * branch <branch-name>    | switch to a Binaries branch, master or stable"
              echo " * update                  | Update the Binaries folder from git"
              echo " * publish                 | Publish the Binaries to git (for programmers)"
            ;;
        esac
    )
    ;;
    "source")
    (
        case "$2" in
            "encode")
            (
              cd "${basedir}/Source"
              declare files=$(find . -type f)
              for file in $files; do
                cd "${basedir}/Source"
                declare encoding=$(file -bi "$file" | awk -F "=" '{print $2}')
                declare encoding=${encoding^^}
                if [[ "$encoding" != UTF-8 ]]; then
                    printf "$(color 1 36)$(color 1)Converting $file with encoding $encoding to UTF-8.$(colorend)\n"
                    declare encoded=$(iconv -f $encoding -t UTF-8 "$file")
                    echo "$encoded" > "$file"
                    sed -i -e 's/\r*$/\r/' "$file"
                fi
              done
            )
            ;;
            *)
                echo "Source tools:"
                echo "encode | convert all source files to UTF-8"
            ;;
        esac
    )
    ;;
    "r" | "reset")
    (
        if [[ -z "$2" ]]; then
          printf "reset: Resets all changes to any tracked files in nodes.\n"
          printf "$(color 1)Usage:$(colorend) reset nodes...\n"
        else
          cd "$basedir"
          git gc --auto
          (git submodule foreach "git gc --auto") &>/dev/null
          for ((i = 2; i <= $#; i++ )); do
            module=${!i}
            if [[ $module = "all" ]]; then
              printf "$(color 1 36)$(color 1)Resetting everything...$(colorend)\n"
              git reset --hard && printf "$(color 32)$(color 1)Reset base repo.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting base repo failed.$(colorend)\n"
              for module_a in "${all_modules[@]}"; do
				if [[ "$module_a" = "Shared" ]]; then
					for node in "${share_nodes[@]}"; do
					  printf "$(color 1 36)$(color 1)Resetting Shared/${node}...$(colorend)"
					  (cd "Content/Shared/${node}" && git reset --hard) && printf "$(color 32)$(color 1)Reset Shared/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting Shared/${node} failed.$(colorend)\n"
					done
                elif [[ "$module_a" = "Imported" ]]; then
                    for node in "${import_nodes[@]}"; do
                      printf "$(color 1 36)$(color 1)Resetting Imported/${node}...$(colorend)\n"
                      (cd "Content/Imported/${node}" && git reset --hard) && printf "$(color 32)$(color 1)Reset Imported/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting Imported/${node} failed.$(colorend)\n"
                    done
                else
                    for node in "${standard_nodes[@]}"; do
                      printf "$(color 1 36)$(color 1)Resetting ${module_a}/${node}...$(colorend)\n"
                      (cd "Content/${module_a}/${node}" && git reset --hard) && printf "$(color 32)$(color 1)Reset ${module_a}/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting ${module_a}/${node} failed.$(colorend)\n"
                    done
                fi
              done
              exit 0
            elif [[ $module = "all_nodes" ]]; then
              printf "$(color 1 36)$(color 1)Resetting all nodes...$(colorend)\n"
              for module_a in "${all_modules[@]}"; do
				if [[ "$module_a" = "Shared" ]]; then
					for node in "${share_nodes[@]}"; do
					  printf "$(color 1 36)$(color 1)Resetting Shared/${node}...$(colorend)"
					  (cd "Content/Shared/${node}" && git reset --hard) && printf "$(color 32)$(color 1)Reset Shared/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting Shared/${node} failed.$(colorend)\n"
					done
                elif [[ "$module_a" = "Imported" ]]; then
                    for node in "${import_nodes[@]}"; do
                      printf "$(color 1 36)$(color 1)Resetting Imported/${node}...$(colorend)\n"
                      (cd "Content/Imported/${node}" && git reset --hard) && printf "$(color 32)$(color 1)Reset Imported/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting Imported/${node} failed.$(colorend)\n"
                    done
                else
                    for node in "${standard_nodes[@]}"; do
                      printf "$(color 1 36)$(color 1)Resetting ${module_a}/${node}...$(colorend)\n"
                      (cd "Content/${module_a}/${node}" && git reset --hard) && printf "$(color 32)$(color 1)Reset ${module_a}/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting ${module_a}/${node} failed.$(colorend)\n"
                    done
                fi
              done
              exit 0
            elif [[ $module = "base" ]]; then
              printf "$(color 1 36)$(color 1)Resetting base repo...$(colorend)\n"
              git reset --hard && printf "$(color 32)$(color 1)Reset base repo.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting base repo failed.$(colorend)\n"
            elif [[ $(contains "${all_modules[@]}" $module) = "y" ]]; then
              if [[ "$module" = "Shared" ]]; then
                for node in "${share_nodes[@]}"; do
                  printf "$(color 1 36)$(color 1)Resetting Shared/${node}...$(colorend)"
                  (cd "Content/Shared/${node}" && git reset --hard) && printf "$(color 32)$(color 1)Reset Shared/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting Shared/${node} failed.$(colorend)\n"
                done
              elif [[ "$module" = "Imported" ]]; then
                for node in "${import_nodes[@]}"; do
                  printf "$(color 1 36)$(color 1)Resetting Imported/${node}...$(colorend)\n"
                  (cd "Content/Imported/${node}" && git reset --hard) && printf "$(color 32)$(color 1)Reset Imported/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting Imported/${node} failed.$(colorend)\n"
                done
              else
                for node in "${standard_nodes[@]}"; do
                  printf "$(color 1 36)$(color 1)Resetting ${module}/${node}...$(colorend)\n"
                  (cd "Content/${module}/${node}" && git reset --hard) && printf "$(color 32)$(color 1)Reset ${module}/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting ${module}/${node} failed.$(colorend)\n"
                done
              fi
            else
              printf "$(color 1 36)$(color 1)Resetting ${module}...$(colorend)\n"
              (cd "Content/${module}" && git reset --hard) && printf "$(color 32)$(color 1)Reset ${module}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting ${module} failed.$(colorend)\n"
            fi
          done
        fi
    )
    ;;
    "rf" | "reset-full")
    (
        if [[ -z "$2" ]]; then
          printf "reset-full: Resets all changes to any tracked files in nodes and removes all added/untracked files.\n"
          printf "$(color 1)Usage:$(colorend) reset-full nodes...\n"
        else
          cd "$basedir"
          git gc --auto
          (git submodule foreach "git gc --auto") &>/dev/null
          for ((i = 2; i <= $#; i++ )); do
            module=${!i}
            if [[ $module = "all" ]]; then
              printf "$(color 1 36)$(color 1)Resetting everything...$(colorend)\n"
              git reset --hard && git clean -dxf && printf "$(color 32)$(color 1)Reset base repo.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting base repo failed.$(colorend)\n"
              for module_a in "${all_modules[@]}"; do
				if [[ "$module_a" = "Shared" ]]; then
					for node in "${share_nodes[@]}"; do
					  printf "$(color 1 36)$(color 1)Resetting Shared/${node}...$(colorend)"
					  (cd "Content/Shared/${node}" && git reset --hard && git clean -dxf) && printf "$(color 32)$(color 1)Reset Shared/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting Shared/${node} failed.$(colorend)\n"
					done
                elif [[ "$module_a" = "Imported" ]]; then
                    for node in "${import_nodes[@]}"; do
                      printf "$(color 1 36)$(color 1)Resetting Imported/${node}...$(colorend)\n"
                      (cd "Content/Imported/${node}" && git reset --hard && git clean -dxf) && printf "$(color 32)$(color 1)Reset Imported/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting Imported/${node} failed.$(colorend)\n"
                    done
                else
                    for node in "${standard_nodes[@]}"; do
                      printf "$(color 1 36)$(color 1)Resetting ${module_a}/${node}...$(colorend)\n"
                      (cd "Content/${module_a}/${node}" && git reset --hard && git clean -dxf) && printf "$(color 32)$(color 1)Reset ${module_a}/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting ${module_a}/${node} failed.$(colorend)\n"
                    done
                fi
              done
              exit 0
            elif [[ $module = "all_nodes" ]]; then
              printf "$(color 1 36)$(color 1)Resetting all nodes...$(colorend)\n"
              for module_a in "${all_modules[@]}"; do
				if [[ "$module_a" = "Shared" ]]; then
					for node in "${share_nodes[@]}"; do
					  printf "$(color 1 36)$(color 1)Resetting Shared/${node}...$(colorend)"
					  (cd "Content/Shared/${node}" && git reset --hard && git clean -dxf) && printf "$(color 32)$(color 1)Reset Shared/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting Shared/${node} failed.$(colorend)\n"
					done
                elif [[ "$module_a" = "Imported" ]]; then
                    for node in "${import_nodes[@]}"; do
                      printf "$(color 1 36)$(color 1)Resetting Imported/${node}...$(colorend)\n"
                      (cd "Content/Imported/${node}" && git reset --hard && git clean -dxf) && printf "$(color 32)$(color 1)Reset Imported/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting Imported/${node} failed.$(colorend)\n"
                    done
                else
                    for node in "${standard_nodes[@]}"; do
                      printf "$(color 1 36)$(color 1)Resetting ${module_a}/${node}...$(colorend)\n"
                      (cd "Content/${module_a}/${node}" && git reset --hard && git clean -dxf) && printf "$(color 32)$(color 1)Reset ${module_a}/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting ${module_a}/${node} failed.$(colorend)\n"
                    done
                fi
              done
              exit 0
            elif [[ $module = "base" ]]; then
              printf "$(color 1 36)$(color 1)Resetting base repo...$(colorend)\n"
              git reset --hard && git clean -dxf && printf "$(color 32)$(color 1)Reset base repo.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting base repo failed.$(colorend)\n"
            elif [[ $(contains "${all_modules[@]}" $module) = "y" ]]; then
              if [[ "$module" = "Shared" ]]; then
                for node in "${share_nodes[@]}"; do
                  printf "$(color 1 36)$(color 1)Resetting Shared/${node}...$(colorend)"
                  (cd "Content/Shared/${node}" && git reset --hard && git clean -dxf) && printf "$(color 32)$(color 1)Reset Shared/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting Shared/${node} failed.$(colorend)\n"
                done
              elif [[ "$module" = "Imported" ]]; then
                for node in "${import_nodes[@]}"; do
                  printf "$(color 1 36)$(color 1)Resetting Imported/${node}...$(colorend)\n"
                  (cd "Content/Imported/${node}" && git reset --hard && git clean -dxf) && printf "$(color 32)$(color 1)Reset Imported/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting Imported/${node} failed.$(colorend)\n"
                done
              else
                for node in "${standard_nodes[@]}"; do
                  printf "$(color 1 36)$(color 1)Resetting ${module}/${node}...$(colorend)\n"
                  (cd "Content/${module}/${node}" && git reset --hard && git clean -dxf) && printf "$(color 32)$(color 1)Reset ${module}/${node}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting ${module}/${node} failed.$(colorend)\n"
                done
              fi
            else
              printf "$(color 1 36)$(color 1)Resetting ${module}...$(colorend)\n"
              (cd "Content/${module}" && git reset --hard && git clean -dxf) && printf "$(color 32)$(color 1)Reset ${module}.$(colorend)\n" || printf "$(color 31)$(color 1)Resetting ${module} failed.$(colorend)\n"
            fi
          done
        fi
    )
    ;;
    *)
        echo "Icebreaker v${version} commands"
        echo ""
        echo " Normal commands:"
        echo "  * u, update         | Gets the latest targeted changes, rather than the absolute latest from the repo. Most useful on the stable branch."
        echo "  * s, sync           | Gets the latest changes from the repo."
        echo "  * b, branch         | Switch to an existing branch, or create a new one if it does not exist."
        echo "  * p, publish        | Commit and push your changes to the repo."
        echo "  * bin, binaries     | Get pre-compiled binaries for the editor."
        echo "  * source            | Source code tools for programmers."
        echo "  * r, reset          | Resets all changes to any tracked files in nodes."
        echo "  * rf, reset-full    | Resets all changes to any tracked files in nodes and removes all added/untracked files."
        echo ""
        echo " Setup commands:"
        echo "  * ssh               | Sets up SSH to auto-start. You can also specify an email to generate an SSH key and then set up SSH."
        echo "  * setup             | Add an alias to $RCPATH to allow full functionality of this script. Run as:"
        echo "                      |     ./icebreaker.sh setup"
        echo "                      | After you run this command you'll be able to just run 'icebreaker' from anywhere."
        echo "                      | The default name for the resulting alias is 'icebreaker', you can give an argument to override"
        echo "                      | this default, such as:"
        echo "                      |     ./icebreaker.sh setup example"
        echo "                      | Which will allow you to run 'example' instead."
        echo ""
        read -n 1 -s -r -p "$(color 1)Press any key to continue.$(colorend)"
    ;;
esac
