#!/bin/bash

# List of known VPS providers (case-insensitive)
VPS_PROVIDERS=("digitalocean" "linode" "ovh" "vultr" "hetzner" "scaleway" "amazon" "google" "microsoft" "alibaba" "contabo" "choopa" "leaseweb" "hostkey" "hostwinds" "dedibolt" "dedicated" "pfcloud" "asia" "china" "russia" "dedioutlet" "hostbaltic")

# Safe country (USA)
SAFE_COUNTRY="US"

# Temporary file to store suspicious IPs (will ask to save after analysis)
TEMP_BAN_FILE=$(mktemp)

# Variables to track suspicious IPs and total IPs processed
total_ips=0
suspicious_ips=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to greet and explain the script
function greet_and_explain() {
    echo -e "${YELLOW}"
    echo -e " _____ ______            ______         _     _     _ _______ _______ ______  "
    echo -e "(_____|_____ \\      /\\  |  ___ \\   /\\  | |   | |   | (_______|_______|_____ \\ "
    echo -e "   _   _____) )    /  \\ | |   | | /  \\ | |   | |___| |  __    _____   _____) )"
    echo -e "  | | |  ____/    / /\\ \\| |   | |/ /\\ \\| |    \\_____/  / /   |  ___) (_____ ( "
    echo -e " _| |_| |        | |__| | |   | | |__| | |_____ ___   / /____| |_____      | |"
    echo -e "(_____)_|        |______|_|   |_|______|_______|___) (_______)_______)     |_|"
    echo -e "                                                                              "
    echo -e "                                Made by Hugo Munoz                            "
    echo -e "${NC}\n"
    sleep 2

    echo -e "${YELLOW}Hello! Welcome to the IP Analysis Script.${NC}"
    echo -e "${YELLOW}This script will check if any IPs belong to VPS providers or come from outside the USA.${NC}"
    echo -e "${YELLOW}After the analysis, you can choose to save suspicious IPs in a file.${NC}"
    sleep 2
}

# Function to check if the provider is a VPS (with word-boundary matching)
function is_vps_provider() {
    local org="$1"
    for provider in "${VPS_PROVIDERS[@]}"; do
        # Use word boundaries to match exact provider names, not just substrings
        if echo "$org" | tr '[:upper:]' '[:lower:]' | grep -Eiq "\b$(echo $provider | tr '[:upper:]' '[:lower:]')\b"; then
            return 0  # Found in the VPS list
        fi
    done
    return 1
}

# Function to process the IP
function check_ip() {
    local ip=$1
    total_ips=$((total_ips + 1))  # Increase the count of total IPs
    echo -e "${BLUE}Analyzing IP: $ip...${NC}"
    sleep 1  # Pause for better display

    # Perform WHOIS lookup
    whois_output=$(whois "$ip")

    # Extract organization and country from WHOIS data
    org=$(echo "$whois_output" | grep -i "OrgName" | head -n 1 | awk '{print substr($0, index($0,$2))}')
    if [ -z "$org" ]; then
        org=$(echo "$whois_output" | grep -i "netname" | head -n 1 | awk '{print substr($0, index($0,$2))}')
    fi

    country=$(echo "$whois_output" | grep -i "country" | head -n 1 | awk '{print $2}')
    if [ -z "$country" ]; then
        country="Not Detected"
    else
        country=$(echo "$country" | tr 'a-z' 'A-Z')  # Convert to uppercase
    fi

    # Check if the IP is a VPS or outside the USA
    reason=""
    if [ -z "$org" ]; then
        echo -e "${YELLOW}$ip -> Organization not detected.${NC}"
    else
        if is_vps_provider "$org"; then
            reason="Potential VPS (Provider: $org)"
            echo -e "${RED}$ip -> $reason, Country: $country.${NC}"
            echo "$ip" >> "$TEMP_BAN_FILE"  # Save only the IP in the file (comma-delimited later)
            suspicious_ips=$((suspicious_ips + 1))  # Increment suspicious IPs count
        elif [ "$country" != "$SAFE_COUNTRY" ]; then
            reason="Outside USA (Country: $country)"
            echo -e "${RED}$ip -> $reason, Provider: $org.${NC}"
            echo "$ip" >> "$TEMP_BAN_FILE"  # Save only the IP in the file
            suspicious_ips=$((suspicious_ips + 1))  # Increment suspicious IPs count
        else
            echo -e "${GREEN}$ip -> Safe (Provider: $org, Country: $country).${NC}"
        fi
    fi
    echo ""  # Extra space after each IP analysis for better readability
}

# Function to ask the user if they want to save the suspicious IPs
function ask_to_save_ban_file() {
    if [ "$suspicious_ips" -gt 0 ]; then
        echo -e "${YELLOW}Do you want to save the suspicious IPs to ips_to_ban.txt? (y/n)${NC}"
        read -r answer
        if [[ "$answer" == "y" ]]; then
            # Output comma-separated IPs
            ip_list=$(paste -sd "," "$TEMP_BAN_FILE")
            echo "$ip_list" > "ips_to_ban.txt"
            echo -e "\n${YELLOW}Suspicious IPs saved to ips_to_ban.txt.${NC}"
        else
            echo -e "${BLUE}Suspicious IPs were not saved.${NC}"
            rm "$TEMP_BAN_FILE"
        fi
    else
        echo -e "${YELLOW}No suspicious IPs were found.${NC}"
        rm "$TEMP_BAN_FILE"
    fi
}

# Function to print the final analysis summary
function print_summary() {
    echo -e "${YELLOW}Debug: Final suspicious_ips count is $suspicious_ips.${NC}"  # Debugging line
    if [ "$suspicious_ips" -gt 0 ]; then
        # Calculate the percentage of suspicious IPs
        percentage=$((suspicious_ips * 100 / total_ips))
        echo -e "${GREEN}Analysis completed. Suspicious IPs: $suspicious_ips out of $total_ips ($percentage%).${NC}"
    else
        echo -e "${YELLOW}No suspicious IPs were found.${NC}"
    fi
}

# Start of the script
greet_and_explain

# Check if the CSV file is provided
if [ "$#" -ne 1 ]; then
    echo -e "${RED}Error: You need to provide a CSV file as an argument.${NC}"
    exit 1
fi

CSV_FILE="$1"

# Check if the CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo -e "${RED}Error: The file $CSV_FILE does not exist.${NC}"
    exit 1
fi

# Read the CSV file and process each IP (skip the first line)
echo -e "${BLUE}=== Starting IP analysis ===${NC}\n"
while IFS=',' read -r ip _; do
    if [[ ! -z "$ip" ]]; then
        check_ip "$ip"
    fi
done < <(tail -n +2 "$CSV_FILE")

echo -e "${BLUE}\n=== Analysis completed ===${NC}"

# Print the final summary
print_summary

# Ask if the user wants to save the suspicious IPs
ask_to_save_ban_file
