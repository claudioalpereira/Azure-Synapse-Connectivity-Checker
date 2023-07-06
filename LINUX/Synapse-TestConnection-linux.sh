#!/bin/bash

#    Author: Sergio Fonseca
#    Twitter @FonsecaSergio
#    Email: sergio.fonseca@microsoft.com
#    Last Updated: 2023-07-06

## Copyright (c) Microsoft Corporation.
#Licensed under the MIT license.

#Azure Synapse Test Connection - Linux Version
#Tested on 
#  - Linux (Azure VM - ubuntu 23.04) - 2023-07-06

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# Define the workspace name
workspacename="REPLACEWORKSPACENAME"
DisableAnonymousTelemetry=false
############################################################################################
version="1.0"
hostsfilepath="/etc/hosts"


# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

############################################################################################
if [ "$(uname)" == "Darwin" ]; then
    SO="MACOS"
elif [ "$(uname)" == "Linux" ]; then
    SO="LINUX"
else
    SO="OTHER"
fi


echo -e "${Cyan}------------------------------------------------------------------------------------${Color_Off}"
echo -e "${Cyan}Azure Synapse Connectivity Checker${Color_Off}"
echo -e "${Cyan} - Version: $version${Color_Off}"
echo -e "${Cyan} - SO: $SO${Color_Off}"
echo -e "${Cyan} - Workspacename: $workspacename${Color_Off}"
echo -e "${Cyan}------------------------------------------------------------------------------------${Color_Off}"
echo -e "${Cyan}Bash Version${Color_Off}"
$(echo -e "bash --version")
echo -e "${Cyan}------------------------------------------------------------------------------------${Color_Off}"

############################################################################################
# Define the endpoints
EndpointTestList=()

declare -A Endpoints=(
    ["$workspacename.sql.azuresynapse.net"]="1433 1443 443"
    ["$workspacename-ondemand.sql.azuresynapse.net"]="1433 1443 443"
    ["$workspacename.database.windows.net"]="1433 1443 443"
    ["$workspacename.dev.azuresynapse.net"]="443"
    ["web.azuresynapse.net"]="443"
    ["management.azure.com"]="443"
    ["login.windows.net"]="443"
    ["login.microsoftonline.com"]="443"
    ["aadcdn.msauth.net"]="443"
    ["graph.microsoft.com"]="443"
)

for Endpoint in "${!Endpoints[@]}"
do
    Ports=(${Endpoints[$Endpoint]})
    EndpointTestList+=("$Endpoint ${Ports[*]}")
done

############################################################################################

function logEvent() {
    local Message=$1
    local AnonymousRunId=$(uuidgen)

    if [ "$DisableAnonymousTelemetry" != true ]; then
        InstrumentationKey="d94ff6ec-feda-4cc9-8d0c-0a5e6049b581"
        body=$(jq -n --arg name "Microsoft.ApplicationInsights.Event" --arg time "$(date -u +"%Y-%m-%dT%H:%M:%S.%NZ")" --arg iKey "$InstrumentationKey" --arg ai_user_id "$AnonymousRunId" --arg ver "2" --arg name "$Message" '{name: $name, time: $time, iKey: $iKey, tags: {"ai.user.id": $ai_user_id}, data: {baseType: "EventData", baseData: {ver: $ver, name: $name}}}')
        response=$(curl -sS -X POST -H "Content-Type: application/json" -d "$body" "https://dc.services.visualstudio.com/v2/track" 2>&1)
        if [ $? -ne 0 ]; then
            echo "Error: $response" >&2
        fi
    else
        echo "Anonymous Telemetry is disabled" >&2
    fi
}

logEvent "Version: $version - Linux"

print_hostfileentries() {
    local hosts_file="$1"
    #sed -e 's/#.*//' -e 's/[[:blank:]]*$//' -e '/^$/d' "$hosts_file"
    sed -e 's/#.*//' -e 's/[[:blank:]]*$//' -e '/^$/d' "$hosts_file" | sed 's/^/ - /'
}


print_ip_for_endpoint() {
    local endpoint="$1"

    # Perform the nslookup
    result=$(nslookup "$endpoint")

    # Save the output to a variable
    output=$(echo "$result" | awk '/^Address: / {print $2; exit}')

    # Print the output
    echo -e " - NSLookup result : ${Blue}$output${Color_Off}"
}

print_port_status() {
    local endpoint="$1"
    local port="$2"
    local timeout=2

    # Create a new TCP client object
    tcpClient=$(nc -v -w "$timeout" "$endpoint" "$port" 2>&1)

    # Check if the port is open
    if [[ "$tcpClient" == *succeeded* ]]; then
        echo -e "${Green} > Port $port on $endpoint is open${Color_Off}"
    else
        echo -e "${Red} > Port $port on $endpoint is closed${Color_Off}"
    fi
}

function print_CxDNSServer {
    # Get the DNS client server addresses from resolv.conf file
    DNSServers=$(grep -E '^nameserver' /etc/resolv.conf | awk '{print $2}')

    # Filter out loopback and Bluetooth interfaces, and empty server addresses
    DNSServers=$(echo "$DNSServers")

    # Return the DNS server addresses
    echo "DNSServers: $DNSServers"
}

function print_proxysettings 
{
    env | grep -i proxy
}

############################################################################################

echo "------------------------------------------------------------------------------------"
echo -e "${Yellow}HOST FILE ENTRIES${Color_Off}"
echo "------------------------------------------------------------------------------------"
print_hostfileentries "$hostsfilepath"

echo "------------------------------------------------------------------------------------"
echo -e "${Yellow}CX DNS SERVERS${Color_Off}"
echo "------------------------------------------------------------------------------------"
print_CxDNSServer

echo "------------------------------------------------------------------------------------"
echo -e "${Yellow}Proxy Settings (IF ANY):${Color_Off}"
echo "------------------------------------------------------------------------------------"
print_proxysettings


echo "------------------------------------------------------------------------------------"
echo -e "${Yellow}NAME RESOLUTION - NSLOOKUP${Color_Off}"
echo "------------------------------------------------------------------------------------"


for EndpointTest in "${EndpointTestList[@]}"
do
    Endpoint=$(echo "$EndpointTest" | cut -d ' ' -f 1)
    Ports=$(echo "$EndpointTest" | cut -d ' ' -f 2-)

    echo "------------------------------------------------------------------------------------"
    echo "Endpoint: $Endpoint and ports: $Ports"
    print_ip_for_endpoint "$Endpoint"

    for Port in $Ports
    do
        print_port_status "$Endpoint" "$Port"
    done
done

echo "------------------------------------------------------------------------------------"