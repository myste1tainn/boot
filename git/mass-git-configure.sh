#!/opt/homebrew/bin/bash

set -euo pipefail

# Config store
CONFIG_DIR="$HOME/.config/mass-git"
CONFIG_FILE="$CONFIG_DIR/config.yaml"

mkdir -p "$CONFIG_DIR"
touch "$CONFIG_FILE"

# Load yq
if ! command -v yq &>/dev/null; then
    echo "yq is required. Please install it via brew install yq"
    exit 1
fi

# Initial default structure
PROVIDERS=(github gitlab)

print_separator() {
    echo "--------------------------------------------------"
}

save_profile_bundle() {
    local profile_name="$1"
    local provider="$2"
    local bundle_name="$3"
    local endpoint="$4"
    local token="$5"

    yq e \
        ".profiles[\"$profile_name\"].type = \"$provider\" | \
       .profiles[\"$profile_name\"].bundles[\"$bundle_name\"] = {\"endpoint\": \"$endpoint\", token: \"$token\"} | \
       .profiles[\"$profile_name\"].active_bundle = \"$bundle_name\"" \
        -i "$CONFIG_FILE"

    # Activate provider if not active yet
    local current_active
    current_active=$(yq e ".active_profiles.$provider" "$CONFIG_FILE")
    if [[ "$current_active" == "null" ]]; then
        yq e ".active_profiles.$provider = \"$profile_name\"" -i "$CONFIG_FILE"
        echo "Activated [$profile_name] as the default for $provider."
    fi
}

print_active_profiles() {
    for p in "${PROVIDERS[@]}"; do
        local profile
        profile=$(yq e ".active_profiles.$p" "$CONFIG_FILE")
        if [[ "$profile" != "null" ]]; then
            bundle=$(yq e ".profiles.\"$profile\".active_bundle" "$CONFIG_FILE")
            endpoint=$(yq e ".profiles.\"$profile\".bundles.\"$bundle\".endpoint" "$CONFIG_FILE")
            echo "- $p: $profile ($bundle) → $endpoint [ACTIVE]"
        else
            echo "- $p: [none]"
        fi
    done
}

prompt_select() {
    local prompt="$1"
    shift
    local options=("$@")

    PS3="$prompt: "
    select opt in "${options[@]}"; do
        if [[ -n "$opt" ]]; then
            echo "$opt"
            break
        else
            echo "Invalid selection."
        fi
    done
}

add_or_update_profile() {
    echo "Enter profile name:" && read -r profile_name
    echo
    echo "Select provider type:" && provider=$(prompt_select "Provider" "${PROVIDERS[@]}")
    echo
    echo "Enter bundle name (e.g. default):" && read -r bundle_name
    echo
    echo "Enter endpoint (e.g. https://gitlab.com or github.com):" && read -r endpoint
    echo
    echo "Enter access token:" && read -rs token
    echo

    save_profile_bundle "$profile_name" "$provider" "$bundle_name" "$endpoint" "$token"
    echo "Profile [$profile_name] with bundle [$bundle_name] saved."
}

select_and_activate_profile() {
    local provider="$1"
    local profiles
    IFS=$'\n' read -r -d '' -a profiles < <(yq e '.profiles | keys | .[]' "$CONFIG_FILE" && printf '\0')
    local filtered=()
    for p in "${profiles[@]}"; do
        [[ "$(yq e ".profiles.\"$p\".type" "$CONFIG_FILE")" == "$provider" ]] && filtered+=("$p")
    done
    if [[ ${#filtered[@]} -eq 0 ]]; then
        echo "No $provider profiles."
        return
    fi
    local selected=$(prompt_select "Select profile to activate for $provider" "${filtered[@]}")
    echo
    yq e ".active_profiles.$provider = \"$selected\"" -i "$CONFIG_FILE"
    echo "$provider profile [$selected] activated."
}

delete_profile() {
    local provider="$1"
    IFS=$'\n' read -r -d '' -a profiles < <(yq e '.profiles | keys | .[]' "$CONFIG_FILE" && printf '\0')
    local filtered=()
    for p in "${profiles[@]}"; do
        [[ "$(yq e ".profiles.\"$p\".type" "$CONFIG_FILE")" == "$provider" ]] && filtered+=("$p")
    done
    if [[ ${#filtered[@]} -eq 0 ]]; then
        echo "No $provider profiles to delete."
        return
    fi
    local selected=$(prompt_select "Select profile to delete" "${filtered[@]}")
    echo
    yq e "del(.profiles.\"$selected\")" -i "$CONFIG_FILE"
    current_active=$(yq e ".active_profiles.$provider" "$CONFIG_FILE")
    if [[ "$current_active" == "$selected" ]]; then
        yq e "del(.active_profiles.$provider)" -i "$CONFIG_FILE"
    fi
    echo "Deleted profile [$selected] from $provider."
}

configure_menu() {
    while true; do
        print_separator
        echo "Mass Git Configuration Menu"
        print_separator
        echo "Active profiles:"
        print_active_profiles
        print_separator
        echo "1) Add new profile"
        echo "2) Activate profile"
        echo "3) Delete profile"
        echo "4) Exit"
        read -rp "Select option: " choice
        case $choice in
        1) add_or_update_profile ;;
        2)
            selected=$(prompt_select "Which provider to activate" "${PROVIDERS[@]}")
            select_and_activate_profile "$selected"
            ;;
        3)
            selected=$(prompt_select "Which provider to delete from" "${PROVIDERS[@]}")
            delete_profile "$selected"
            ;;
        4) break ;;
        *) echo "Invalid" ;;
        esac
    done
}

configure_menu
