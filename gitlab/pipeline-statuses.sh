#!/bin/bash - 
#===============================================================================
#
#          FILE: pipeline-statuses.sh
# 
#         USAGE: ./pipeline-statuses.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Arnon Keereena (a.keereena@gmail.com), 
#  ORGANIZATION: 
#       CREATED: 10/02/2022 12:08
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

subgroup_names=(fe be adaptor)
subgroup_ids=(2899 2900 2901)
for i in "${!subgroup_ids[@]}"; do
    subgroup_name="${subgroup_names[$i]}"
    subgroup_id="${subgroup_ids[$i]}"
    for line in $(curl -s --header "PRIVATE-TOKEN: REDACTED_GITLAB_TOKEN" "https://gitdev.devops.krungthai.com/api/v4/groups/$subgroup_id?include_subgroups=true" | jq '.projects[] | (.id|tostring)+"#"+.name' | tr -d '"'); do
        (
        id="$(echo $line | awk -F '#' '{print $1}')"
        name="$(echo $line | awk -F '#' '{print $2}')"
        info=$(curl -s --header "PRIVATE-TOKEN: REDACTED_GITLAB_TOKEN" "https://gitdev.devops.krungthai.com/api/v4/projects/$id/pipelines")
        if [ ! -z "$(echo "$info" | grep 'Forbidden')" ]; then
            printf "%-8s%-11s%-50s %s\n" "[$id]" "[$subgroup_name]" "[$name]" "WARN: has no pipelines setup, or you don't have permission, skipping";
            continue;
        fi
        if [ "$info" = "[]" ]; then
            printf "%-8s%-11s%-50s %s\n" "[$id]" "[$subgroup_name]" "[$name]" "WARN: has no records of pipelines";
            continue;
        fi
        status=$(echo "$info" | jq '.[0] | .updated_at + " " + .ref + ": " + "status = " + .status' | tr -d '"')
        printf "%-8s%-11s%-50s %s\n" "[$id]" "[$subgroup_name]" "[$name]" "$status";
    ) &
    done;
done;

