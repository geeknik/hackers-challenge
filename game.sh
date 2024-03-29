#!/bin/bash

# Global variables
num_systems=20
num_npcs=10
num_shops=5
stealth_meter=100
reputation_meter=0
hacking_tools=("nmap" "metasploit" "hydra" "sqlmap" "wireshark" "hashcat" "john" "burpsuite")
hacking_missions=("Scan network", "Exploit system", "Crack password", "Steal data", "Disrupt service", "Plant backdoor")

# Function to display the title screen
display_title_screen() {
  clear
  echo "
    _   _      _ _        __        __         _     _ 
   | | | | ___| | | ___   \ \      / /__  _ __| | __| |
   | |_| |/ _ \ | |/ _ \   \ \ /\ / / _ \| '__| |/ _\` |
   |  _  |  __/ | | (_) |   \ V  V / (_) | |  | | (_| |
   |_| |_|\___|_|_|\___/     \_/\_/ \___/|_|  |_|\__,_|
  "

  PS3="What would you like to do? "
  options=("Start New Game" "Load Saved Game" "Tutorial" "View Credits" "Exit")
  select opt in "${options[@]}"; do
    case $opt in
      "Start New Game")
        echo "Starting a new game..."
        hack_game
        ;;
      "Load Saved Game")
        echo "Loading saved game..."
        load_game
        hack_game
        ;;
      "Tutorial")
        echo "Starting Tutorial..."
        tutorial_sequence
        hack_game
        exit 0
        ;;
      "View Credits")
        echo "Displaying credits..."
        # Implement credits screen here
        ;;
      "Exit")
        echo "Exiting the game..."
        exit 0
        ;;
      *) echo "Invalid option. Please try again.";;
    esac
  done
}

# Function to display the command prompt
display_command_prompt() {
  local color="\e[1;34m" # Blue color for the prompt
  local reset="\e[0m"
  echo -e "${color}The Hacker's Challenge > ${reset}\c"
}

tutorial_progress=0

tutorial_sequence() {
  clear
  echo "Welcome to the tutorial for The Hacker's Challenge!"
  echo "In this tutorial, you will learn the basic mechanics of the game."
  read -p "Press Enter to continue..."

  # Tutorial Step 1: Navigating the Network
  echo "Step 1: Navigating the Network"
  echo "The game world is represented by a network of interconnected systems, each with its own security level."
  echo "You can view the current network topology by using the 'display_network' command."
  read -p "Press Enter to try it now..."
  echo "Displaying the current network topology:"
  display_network
  echo "You can see the different systems on the network, along with their security levels (represented by color)."
  ((tutorial_progress++))

  # Tutorial Step 2: Scanning Systems
  echo "Step 2: Scanning Systems"
  echo "To gather information about a system, you can use the 'scan' command followed by the target IP address."
  echo "This will allow you to determine the security level of the system before attempting to exploit it."
  read -p "Press Enter to try scanning a system..."
  echo "Scanning the network..."
  scan_network
  echo "The scan has provided you with information about the security levels of the systems on the network."
  ((tutorial_progress++))

  # Tutorial Step 3: Exploiting Systems
  echo "Step 3: Exploiting Systems"
  echo "Once you have gathered information about a system, you can attempt to exploit it using the 'exploit' command."
  echo "Be careful, as the security level of the system will affect your chances of success and impact your stealth meter."
  read -p "Press Enter to try exploiting a system..."
  echo -n "Enter the target system: "
  read target_system
  echo "Exploiting $target_system..."
  exploit_system $target_system
  echo "The exploit was successful, and your reputation meter has increased."
  ((tutorial_progress++))

  # Tutorial Step 4: Stealth and Reputation
  echo "Step 4: Stealth and Reputation"
  echo "Your actions will affect your stealth meter and reputation meter. Be careful not to get caught!"
  echo "You can check your current status using the 'display_status_panel' command."
  read -p "Press Enter to view your status..."
  display_status_panel
  echo "As you can see, your stealth meter and reputation meter are displayed, along with your available hacking tools."
  ((tutorial_progress++))

  echo "Congratulations! You have completed the tutorial. Good luck on your hacking journey!"
  read -p "Press Enter to start the game..."
}

# Function to handle user input
handle_user_input() {
  local input
  read -e -p "$(display_command_prompt)" input
  case $input in
    "scan"*)
      scan_network
      ;;
    "exploit"*)
      exploit_system
      ;;
    "crack"*)
      crack_password
      ;;
    "steal"*)
      steal_data
      ;;
    "disrupt"*)
      disrupt_service
      ;;
    "plant"*)
      plant_backdoor
      ;;
    "mission")
      select_mission
      ;;
    "tool")
      manage_tools
      ;;
    "npc"*)
      read -p "Enter NPC ID: " npc_id
      interact_with_npc $npc_id
      ;;
    "shop"*)
      read -p "Enter shop ID: " shop_id
      visit_shop $shop_id
      ;;
    "exit")
      echo "Exiting The Hacker's Challenge..."
      save_game
      exit 0
      ;;
    *)
      echo "Invalid command. Please try again."
      ;;
  esac
}

save_game() {
  local save_file="$HOME/.hacker_challenge/save.dat"
  mkdir -p "$HOME/.hacker_challenge"

  # Serialize game data
  local game_data=$(printf '%s\n%d\n%d\n' "${systems[@]}" "$stealth_meter" "$reputation_meter")

  # Write game data to the save file
  echo "$game_data" > "$save_file"
  echo "Game saved successfully!"
}

load_game() {
  local save_file="$HOME/.hacker_challenge/save.dat"

  if [ -f "$save_file" ]; then
    # Deserialize game data
    readarray -t systems < <(head -n $num_systems "$save_file")
    stealth_meter=$(sed -n "$((num_systems+1))p" "$save_file")
    reputation_meter=$(sed -n "$((num_systems+2))p" "$save_file")

    echo "Game loaded successfully!"
  else
    echo "No saved game found. Starting a new game."
  fi
}

# Function to display the status panel
display_status_panel() {
  local color_stealth="\e[1;32m" # Green for high stealth
  local color_reputation="\e[1;33m" # Yellow for reputation
  local reset="\e[0m"

  echo -e "
  ${color_stealth}Stealth Meter: $stealth_meter${reset}
  ${color_reputation}Reputation Meter: $reputation_meter${reset}
  Available Hacking Tools: ${hacking_tools[*]}
  "
}

hack_game() {
  clear
  echo "Welcome to The Hacker's Challenge!"
  read -p "Are you a white hat or black hat hacker? (white/black): " player_type
  case $player_type in
    white) hacking_difficulty=medium ;;
    black) hacking_difficulty=hard ;;
    *) echo "Invalid choice! Using default medium difficulty." && hacking_difficulty=medium ;;
  esac

  echo "Initializing network topology..."
  generate_network
  generate_npcs
  generate_shops

  echo "Hacker identity set to: $player_type"
  echo "Hacking difficulty: $hacking_difficulty"


  while true; do
    clear
    if [[ $tutorial_progress -lt 4 ]]; then
      tutorial_sequence
    else
      display_network
      display_npcs
      display_shops
      display_status_panel
      handle_user_input
    fi
  done
}

generate_network() {
  for i in $(seq 1 $num_systems); do
    color=$(generate_color)
    security_level=$(get_security_level $color)
    system_type=$(generate_system_type)
    systems[$i]="[$color] $system_type ($security_level)"
  done
}

generate_npcs() {
  for i in $(seq 1 $num_npcs); do
    npc_type=$(generate_npc_type)
    npc_info="NPC $i ($npc_type)"
    npcs[$i]=$npc_info
  done
}

generate_shops() {
  for i in $(seq 1 $num_shops); do
    shop_type=$(generate_shop_type)
    shop_info="Shop $i ($shop_type)"
    shops[$i]=$shop_info
  done
}

display_network() {
  for system in "${systems[@]}"; do
    echo "$system"
  done
}

display_npcs() {
  for npc in "${npcs[@]}"; do
    echo "$npc"
  done
}

display_shops() {
  for shop in "${shops[@]}"; do
    echo "$shop"
  done
}

get_security_level() {
  local color=$1
  case $color in
    green) echo "low";;
    yellow) echo "medium";;
    red) echo "high";;
  esac
}

generate_color() {
  local colors=("green" "yellow" "red")
  echo "${colors[$((RANDOM % ${#colors[@]}))]}"
}

generate_system_type() {
  local system_types=("Web Server" "Database" "File Server" "Mail Server" "IoT Device")
  echo "${system_types[$((RANDOM % ${#system_types[@]}))]}"
}

generate_npc_type() {
  local npc_types=("Hacker" "System Admin" "Security Guard" "CEO" "Janitor" "Researcher" "Whistleblower")
  echo "${npc_types[$((RANDOM % ${#npc_types[@]}))]}"
}

generate_shop_type() {
  local shop_types=("Hacking Tools" "Black Market" "Cybersecurity Supplies" "Information Broker" "Coding Workshop")
  echo "${shop_types[$((RANDOM % ${#shop_types[@]}))]}"
}

select_mission() {
  select mission in "${hacking_missions[@]}"; do
    case $mission in
      "Scan network")
        scan_network
        ;;
      "Exploit system")
        exploit_system
        ;;
      "Crack password")
        crack_password
        ;;
      "Steal data")
        steal_data
        ;;
      "Disrupt service")
        disrupt_service
        ;;
      "Plant backdoor")
        plant_backdoor
        ;;
      *)
        echo "Invalid mission. Please try again."
        ;;
    esac
    break
  done
}

manage_tools() {
  echo "Available hacking tools:"
  for tool in "${hacking_tools[@]}"; do
    echo "- $tool"
  done
  read -p "Enter tool to use: " tool
  if [[ " ${hacking_tools[@]} " =~ " $tool " ]]; then
    echo "Using $tool..."
    # Implement tool functionality here
  else
    echo "Invalid tool. Please try again."
  fi
}

interact_with_npc() {
  local npc_id=$1
  local npc_type=${npcs[$npc_id]#*\(}
  npc_type=${npc_type%\)*}
  echo "Interacting with NPC $npc_id ($npc_type)..."
  sleep 2
  case $npc_type in
    Hacker)
      echo "The hacker offers to sell you some valuable information for a price."
      ;;
    "System Admin")
      echo "The system admin warns you to leave the network immediately."
      update_stealth_meter high
      ;;
    "Security Guard")
      echo "The security guard spots you and calls for backup."
      update_stealth_meter high
      ;;
    CEO)
      echo "The CEO offers you a job as a white hat hacker for the company."
      ;;
    Janitor)
      echo "The janitor doesn't seem to notice your presence."
      ;;
    Researcher)
      echo "The researcher shares some useful information about the network's vulnerabilities."
      update_reputation_meter
      ;;
    Whistleblower)
      echo "The whistleblower provides you with sensitive data about the company's illegal activities."
      update_reputation_meter
      ;;
  esac
}

visit_shop() {
  local shop_id=$1
  local shop_type=${shops[$shop_id]#*\(}
  shop_type=${shop_type%\)*}
  echo "Visiting Shop $shop_id ($shop_type)..."
  sleep 2
  case $shop_type in
    "Hacking Tools")
      echo "The shop offers a variety of hacking tools for purchase."
      manage_tools
      ;;
    "Black Market")
      echo "The black market vendor has some rare and powerful exploits for sale."
      ;;
    "Cybersecurity Supplies")
      echo "The shop sells security-focused hardware and software."
      ;;
    "Information Broker")
      echo "The information broker has valuable intelligence on the network's defenses."
      update_reputation_meter
      ;;
    "Coding Workshop")
      echo "The workshop offers training on advanced programming and scripting techniques."
      update_reputation_meter
      ;;
  esac
}

scan_network() {
  echo "Scanning the network..."
  sleep 3
  for system in "${systems[@]}"; do
    local system_info=$(echo "$system" | sed 's/\[\([^]]*\)\] \([^(]*\) (\([^)]*\))/\1 \2 \3/')
    local color=$(echo "$system_info" | awk '{print $1}')
    local system_type=$(echo "$system_info" | awk '{print $2}')
    local security_level=$(echo "$system_info" | awk '{print $3}')
    echo "Scanning $system_type ($security_level)..."
    update_stealth_meter $security_level
  done
}

exploit_system() {
  read -p "Enter target system: " target_system
  echo "Exploiting $target_system..."
  sleep 4
  local system_info=$(echo "$target_system" | sed 's/\[\([^]]*\)\] \([^(]*\) (\([^)]*\))/\1 \2 \3/')
  local color=$(echo "$system_info" | awk '{print $1}')
  local system_type=$(echo "$system_info" | awk '{print $2}')
  local security_level=$(echo "$system_info" | awk '{print $3}')
  echo "Security level: $security_level"
  update_stealth_meter $security_level
  update_reputation_meter
}

crack_password() {
  read -p "Enter target system: " target_system
  echo "Cracking password on $target_system..."
  sleep 6
  local system_info=$(echo "$target_system" | sed 's/\[\([^]]*\)\] \([^(]*\) (\([^)]*\))/\1 \2 \3/')
  local color=$(echo "$system_info" | awk '{print $1}')
  local system_type=$(echo "$system_info" | awk '{print $2}')
  local security_level=$(echo "$system_info" | awk '{print $3}')
  echo "Security level: $security_level"
  update_stealth_meter $security_level
  update_reputation_meter
}

steal_data() {
  read -p "Enter target system: " target_system
  echo "Stealing data from $target_system..."
  sleep 5
  local system_info=$(echo "$target_system" | sed 's/\[\([^]]*\)\] \([^(]*\) (\([^)]*\))/\1 \2 \3/')
  local color=$(echo "$system_info" | awk '{print $1}')
  local system_type=$(echo "$system_info" | awk '{print $2}')
  local security_level=$(echo "$system_info" | awk '{print $3}')
  echo "Security level: $security_level"
  update_stealth_meter $security_level
  update_reputation_meter
}

disrupt_service() {
  read -p "Enter target system: " target_system
  echo "Disrupting service on $target_system..."
  sleep 3
  local system_info=$(echo "$target_system" | sed 's/\[\([^]]*\)\] \([^(]*\) (\([^)]*\))/\1 \2 \3/')
  local color=$(echo "$system_info" | awk '{print $1}')
  local system_type=$(echo "$system_info" | awk '{print $2}')
  local security_level=$(echo "$system_info" | awk '{print $3}')
  echo "Security level: $security_level"
  update_stealth_meter $security_level
  update_reputation_meter
}

plant_backdoor() {
  read -p "Enter target system: " target_system
  echo "Planting backdoor on $target_system..."
  sleep 7
  local system_info=$(echo "$target_system" | sed 's/\[\([^]]*\)\] \([^(]*\) (\([^)]*\))/\1 \2 \3/')
  local color=$(echo "$system_info" | awk '{print $1}')
  local system_type=$(echo "$system_info" | awk '{print $2}')
  local security_level=$(echo "$system_info" | awk '{print $3}')
  echo "Security level: $security_level"
  update_stealth_meter $security_level
  update_reputation_meter
}

update_stealth_meter() {
  local security_level=$1
  case $security_level in
    low) stealth_meter=$((stealth_meter - 10));;
    medium) stealth_meter=$((stealth_meter - 25));;
    high) stealth_meter=$((stealth_meter - 50));;
  esac
  if [[ $stealth_meter -le 0 ]]; then
    echo "Stealth meter depleted! You've been detected and the game is over."
    exit 1
  fi
}

update_reputation_meter() {
  reputation_meter=$((reputation_meter + 10))
  echo "Reputation meter increased to $reputation_meter"
}

display_title_screen
