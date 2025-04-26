#!/bin/bash

# NinjaOps Installer
# This script installs NinjaOps and sets up required directories and configurations

echo -e "\n\e[1;36m╔════════════════════════════════════════════════════════════╗\e[0m"
echo -e "\e[1;36m║                 NINJAOPS INSTALLER                          ║\e[0m"
echo -e "\e[1;36m╚════════════════════════════════════════════════════════════╝\e[0m"

# Define installation paths
INSTALL_DIR="/opt/ninjaops"
CONFIG_DIR="/etc/ninjaops"
BIN_DIR="/usr/local/bin"
SCRIPT_NAME="ninjaops"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[1;31mPlease run as root or using sudo\e[0m"
    exit 1
fi

# Create directories
echo -e "\n\e[1m• Creating directories\e[0m"
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"

# Download or copy files
echo -e "\n\e[1m• Installing NinjaOps\e[0m"

# Copy main script to installation directory
cat > "$INSTALL_DIR/ninjaops.sh" << 'EOFNINJA'
#!/bin/bash

# NinjaOps v2.0
# A comprehensive system health monitoring and task management tool
# Featuring anime quotes for motivation and advanced monitoring capabilities

# Source configuration file
CONFIG_DIR="/etc/ninjaops"
CONFIG_FILE="$CONFIG_DIR/config.conf"
QUOTES_FILE="$CONFIG_DIR/quotes.txt"
SERVICES_FILE="$CONFIG_DIR/services.txt"
NETWORK_TARGETS_FILE="$CONFIG_DIR/network_targets.txt"

# Create default configuration if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Creating configuration directory..."
    sudo mkdir -p "$CONFIG_DIR"
fi

# Load or create configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    # Default configuration
    cat > /tmp/ninjaops.conf << EOFCONF
# NinjaOps Configuration File

# Alert thresholds (percent)
CPU_THRESHOLD=85
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90

# Log file settings
LOG_FILE="/var/log/ninjaops.log"
LOG_LEVEL="INFO"  # DEBUG, INFO, WARNING, ERROR, CRITICAL
LOG_MAX_SIZE=10   # In MB

# Alert settings
ENABLE_EMAIL_ALERTS=false
ALERT_EMAIL="admin@example.com"
SMTP_SERVER="smtp.example.com"
SMTP_PORT=587
SMTP_USER="user@example.com"
SMTP_PASSWORD="password"

# Maintenance settings
AUTO_CLEANUP=true
CLEANUP_TEMP_FILES=true
CLEANUP_PACKAGE_CACHE=true
AUTO_SECURITY_UPDATES=false

# Monitoring settings
CHECK_INTERVAL=300  # In seconds
MONITOR_SERVICES=true
MONITOR_NETWORK=true
MONITOR_DISK_IO=true
MONITOR_PROCESSES=true
EOFCONF
    sudo mv /tmp/ninjaops.conf "$CONFIG_FILE"
    echo "Default configuration created at $CONFIG_FILE"
fi

# Load configuration
source "$CONFIG_FILE"

# Create other necessary files if they don't exist
if [ ! -f "$SERVICES_FILE" ]; then
    cat > /tmp/services.txt << EOFSERV
# List of critical services to monitor (one per line)
ssh
cron
nginx
apache2
mysql
postgresql
docker
EOFSERV
    sudo mv /tmp/services.txt "$SERVICES_FILE"
    echo "Default services list created at $SERVICES_FILE"
fi

if [ ! -f "$NETWORK_TARGETS_FILE" ]; then
    cat > /tmp/network_targets.txt << EOFNET
# Network targets to monitor (one per line)
8.8.8.8,Google DNS
1.1.1.1,Cloudflare DNS
google.com,Google
github.com,GitHub
EOFNET
    sudo mv /tmp/network_targets.txt "$NETWORK_TARGETS_FILE"
    echo "Default network targets created at $NETWORK_TARGETS_FILE"
fi

# Ensure the quotes file exists
if [ ! -f "$QUOTES_FILE" ]; then
    cat > /tmp/quotes.txt << EOFQUOTE
"Those who forgive themselves, and are able to accept their true nature... They are the strong ones." – Itachi Uchiha, Naruto
"People's lives don't end when they die, it ends when they lose faith." – Itachi Uchiha, Naruto
"The next generation will always surpass the previous one. It's one of the never-ending cycles in life." – Itachi Uchiha, Naruto
"The weak are destined to lie under the heels of the strong." – Madara Uchiha, Naruto
"If you don't share someone's pain, you can never understand them." – Madara Uchiha, Naruto
"The world isn't perfect. But it's there for us, doing the best it can... that's what makes it so damn beautiful." – Roy Mustang, Fullmetal Alchemist: Brotherhood
"A lesson without pain is meaningless. That's because no one can gain without sacrificing something." – Edward Elric, Fullmetal Alchemist
"When you give up, that's when the game is over." – Kuroko Tetsuya, Kuroko no Basket
"If you don't take risks, you can't create a future!" – Monkey D. Luffy, One Piece
"No matter how deep the night, it always turns to day, eventually." – Brook, One Piece
"The only thing we're allowed to do is believe that we won't regret the choice we made." – Levi Ackerman, Attack on Titan
"Sometimes I do feel like I'm a failure. Like there's no hope for me. But even so, I'm not gonna give up. Ever!" – Izuku Midoriya, My Hero Academia
"Power isn't determined by your size, but by the size of your heart and dreams!" – Monkey D. Luffy, One Piece
"The world isn't perfect, but it's there for us, trying the best it can." – Setsuko Meioh, Sailor Moon
"I'll leave tomorrow's problems to tomorrow's me." – Saitama, One Punch Man
"Being alone is more painful than getting hurt." – Monkey D. Luffy, One Piece
"If you don't like your destiny, don't accept it." – Naruto Uzumaki, Naruto
"It's not always possible to do what we want to do, but it's important to believe in something before you actually do it." – Might Guy, Naruto
"Hard work is worthless for those that don't believe in themselves." – Naruto Uzumaki, Naruto
"It's not the face that makes someone a monster; it's the choices they make with their lives." – Naruto Uzumaki, Naruto
EOFQUOTE
    sudo mv /tmp/quotes.txt "$QUOTES_FILE"
    echo "Default quotes file created at $QUOTES_FILE"
fi

# Create log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    sudo touch "$LOG_FILE"
    sudo chmod 644 "$LOG_FILE"
fi

# Enhanced logging function with log rotation and severity levels
function log {
    local message=$1
    local level=${2:-"INFO"}
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Only log if the level is appropriate based on LOG_LEVEL
    case $LOG_LEVEL in
        "DEBUG")
            ;;
        "INFO")
            if [[ "$level" == "DEBUG" ]]; then return; fi
            ;;
        "WARNING")
            if [[ "$level" == "DEBUG" || "$level" == "INFO" ]]; then return; fi
            ;;
        "ERROR")
            if [[ "$level" == "DEBUG" || "$level" == "INFO" || "$level" == "WARNING" ]]; then return; fi
            ;;
        "CRITICAL")
            if [[ "$level" != "CRITICAL" ]]; then return; fi
            ;;
    esac
    
    # Check log file size and rotate if necessary (size in MB)
    if [ -f "$LOG_FILE" ]; then
        local size_kb=$(du -k "$LOG_FILE" | cut -f1)
        local size_mb=$((size_kb / 1024))
        
        if [ $size_mb -ge $LOG_MAX_SIZE ]; then
            # Rotate logs - keep up to 5 archived logs
            for i in {4..1}; do
                if [ -f "${LOG_FILE}.$i" ]; then
                    sudo mv "${LOG_FILE}.$i" "${LOG_FILE}.$((i+1))"
                fi
            done
            sudo mv "$LOG_FILE" "${LOG_FILE}.1"
            sudo touch "$LOG_FILE"
            sudo chmod 644 "$LOG_FILE"
            log "Log file rotated due to size limit" "INFO"
        fi
    fi
    
    # Log the message with timestamp and level
    echo "[$timestamp] [$level] $$: $message" | sudo tee -a "$LOG_FILE" > /dev/null
}

# Function to validate input parameters for security
function validate_input {
    local input=$1
    # Check if input contains potentially dangerous characters
    if [[ ! $input =~ ^[a-zA-Z0-9_.-]+$ ]]; then
        log "Invalid input detected: $input" "WARNING"
        echo "Invalid input: $input"
        return 1
    fi
    echo "$input"
    return 0
}

# Function to send alerts (email, desktop notification, etc.)
function alert {
    local message=$1
    local severity=${2:-"WARNING"}
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Always log alerts
    log "$message" "$severity"
    
    # Print to console with appropriate color
    case $severity in
        "CRITICAL")
            echo -e "\e[1;31m[$severity] $message\e[0m"
            ;;
        "ERROR")
            echo -e "\e[31m[$severity] $message\e[0m"
            ;;
        "WARNING")
            echo -e "\e[33m[$severity] $message\e[0m"
            ;;
        "INFO")
            echo -e "\e[36m[$severity] $message\e[0m"
            ;;
        "DEBUG")
            echo -e "\e[90m[$severity] $message\e[0m"
            ;;
    esac
    
    # Send email alert if enabled and severity warrants it
    if [ "$ENABLE_EMAIL_ALERTS" = true ] && [[ "$severity" == "WARNING" || "$severity" == "ERROR" || "$severity" == "CRITICAL" ]]; then
        local subject="NinjaOps Alert: [$severity] on $(hostname)"
        
        # Only use mail command if it exists
        if command -v mail > /dev/null; then
            echo -e "[$timestamp] $severity: $message\n\nThis alert was generated by NinjaOps on $(hostname)." | mail -s "$subject" "$ALERT_EMAIL"
            log "Email alert sent to $ALERT_EMAIL" "DEBUG"
        else
            log "Email alert requested but 'mail' command not available" "WARNING"
        fi
    fi
    
    # Send desktop notification if running in desktop environment
    if [ -n "$DISPLAY" ] && command -v notify-send > /dev/null; then
        notify-send -u normal "NinjaOps [$severity]" "$message"
    fi
}

# Function to display system information with color formatting
function display_sys_info {
    local os_info=$(lsb_release -ds 2>/dev/null || cat /etc/*release | head -n1 || uname -om)
    local kernel=$(uname -r)
    local uptime=$(uptime -p)
    local hostname=$(hostname)
    
    echo -e "\n\e[1;32m╔════════════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[1;32m║                  SYSTEM INFORMATION                         ║\e[0m"
    echo -e "\e[1;32m╚════════════════════════════════════════════════════════════╝\e[0m"
    
    echo -e "\e[1m• Hostname:\e[0m $hostname"
    echo -e "\e[1m• OS:\e[0m $os_info"
    echo -e "\e[1m• Kernel:\e[0m $kernel"
    echo -e "\e[1m• Uptime:\e[0m $uptime"
    
    # CPU information
    local cpu_model=$(lscpu | grep 'Model name' | cut -d: -f2- | sed 's/^[ \t]*//')
    local cpu_cores=$(nproc)
    echo -e "\e[1m• CPU:\e[0m $cpu_model ($cpu_cores cores)"
    
    # Memory information with human-readable formatting
    local mem_total=$(free -h | awk '/^Mem/{print $2}')
    local mem_used=$(free -h | awk '/^Mem/{print $3}')
    local mem_free=$(free -h | awk '/^Mem/{print $4}')
    echo -e "\e[1m• Memory:\e[0m $mem_used used / $mem_total total ($mem_free free)"
    
    # Disk information
    echo -e "\e[1m• Disk Usage:\e[0m"
    df -h | grep '^/dev/' | awk '{print "  - " $1 " (" $2 "): " $3 " used / " $2 " total (" $5 " used)"}'
    
    # Network information
    echo -e "\e[1m• Network Interfaces:\e[0m"
    ip -o addr show scope global | awk '{gsub(/\/[0-9]+/, "", $4); print "  - " $2 ": " $4}'
    
    log "System information displayed" "DEBUG"
}

# Function to check system performance metrics
function check_performance {
    echo -e "\n\e[1;33m╔════════════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[1;33m║                 PERFORMANCE METRICS                         ║\e[0m"
    echo -e "\e[1;33m╚════════════════════════════════════════════════════════════╝\e[0m"
    
    # Get dynamic thresholds based on time of day
    local current_hour=$(date +%H)
    local dynamic_cpu_threshold=$CPU_THRESHOLD
    local dynamic_mem_threshold=$MEMORY_THRESHOLD
    local dynamic_disk_threshold=$DISK_THRESHOLD
    
    # Adjust thresholds during off-hours (midnight to 6am)
    if [ $current_hour -ge 0 ] && [ $current_hour -lt 6 ]; then
        dynamic_cpu_threshold=$((CPU_THRESHOLD + 10))
        dynamic_mem_threshold=$((MEMORY_THRESHOLD + 10))
    fi
    
    # CPU Usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    cpu_usage=$(printf "%.1f" $cpu_usage 2>/dev/null || echo $cpu_usage)
    
    # Format CPU usage with colors based on threshold
    if (( $(echo "$cpu_usage > $dynamic_cpu_threshold" | bc -l) )); then
        echo -e "\e[1m• CPU Usage:\e[0m \e[1;31m$cpu_usage%\e[0m (Threshold: $dynamic_cpu_threshold%)"
        alert "High CPU Usage: $cpu_usage% (Threshold: $dynamic_cpu_threshold%)" "WARNING"
    elif (( $(echo "$cpu_usage > $((dynamic_cpu_threshold * 80 / 100))" | bc -l) )); then
        echo -e "\e[1m• CPU Usage:\e[0m \e[1;33m$cpu_usage%\e[0m (Threshold: $dynamic_cpu_threshold%)"
    else
        echo -e "\e[1m• CPU Usage:\e[0m \e[1;32m$cpu_usage%\e[0m (Threshold: $dynamic_cpu_threshold%)"
    fi
    
    # Memory Usage
    local mem_total=$(free | awk '/^Mem/{print $2}')
    local mem_used=$(free | awk '/^Mem/{print $3}')
    local mem_usage=$(echo "scale=1; $mem_used * 100 / $mem_total" | bc)
    
    # Format Memory usage with colors based on threshold
    if (( $(echo "$mem_usage > $dynamic_mem_threshold" | bc -l) )); then
        echo -e "\e[1m• Memory Usage:\e[0m \e[1;31m$mem_usage%\e[0m (Threshold: $dynamic_mem_threshold%)"
        alert "High Memory Usage: $mem_usage% (Threshold: $dynamic_mem_threshold%)" "WARNING"
    elif (( $(echo "$mem_usage > $((dynamic_mem_threshold * 80 / 100))" | bc -l) )); then
        echo -e "\e[1m• Memory Usage:\e[0m \e[1;33m$mem_usage%\e[0m (Threshold: $dynamic_mem_threshold%)"
    else
        echo -e "\e[1m• Memory Usage:\e[0m \e[1;32m$mem_usage%\e[0m (Threshold: $dynamic_mem_threshold%)"
    fi
    
    # Disk Usage for each mount point
    echo -e "\e[1m• Disk Usage:\e[0m"
    df -h | grep '^/dev/' | while read line; do
        local disk=$(echo $line | awk '{print $1}')
        local mount=$(echo $line | awk '{print $6}')
        local disk_usage=$(echo $line | awk '{print $5}' | sed 's/%//')
        
        if (( disk_usage > dynamic_disk_threshold )); then
            echo -e "  - $mount ($disk): \e[1;31m$disk_usage%\e[0m (Threshold: $dynamic_disk_threshold%)"
            alert "High Disk Usage on $mount: $disk_usage% (Threshold: $dynamic_disk_threshold%)" "WARNING"
        elif (( disk_usage > dynamic_disk_threshold * 80 / 100 )); then
            echo -e "  - $mount ($disk): \e[1;33m$disk_usage%\e[0m (Threshold: $dynamic_disk_threshold%)"
        else
            echo -e "  - $mount ($disk): \e[1;32m$disk_usage%\e[0m (Threshold: $dynamic_disk_threshold%)"
        fi
    done
    
    # Load Average
    local load_avg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
    local cpu_cores=$(nproc)
    local load_1=$(echo $load_avg | awk '{print $1}')
    local load_5=$(echo $load_avg | awk '{print $2}')
    local load_15=$(echo $load_avg | awk '{print $3}')
    
    echo -e "\e[1m• Load Average (1, 5, 15 min):\e[0m $load_1, $load_5, $load_15 (on $cpu_cores cores)"
    
    # Warn if load average exceeds number of cores
    if (( $(echo "$load_5 > $cpu_cores" | bc -l) )); then
        alert "High system load: 5-minute load average ($load_5) exceeds number of CPU cores ($cpu_cores)" "WARNING"
    fi
    
    log "Performance check completed" "DEBUG"
}

# Function to monitor disk I/O
function check_disk_io {
    if [ "$MONITOR_DISK_IO" != true ]; then
        return
    fi

    echo -e "\n\e[1;36m╔════════════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[1;36m║                   DISK I/O STATISTICS                       ║\e[0m"
    echo -e "\e[1;36m╚════════════════════════════════════════════════════════════╝\e[0m"
    
    # Check if iostat is available
    if ! command -v iostat >/dev/null 2>&1; then
        echo "iostat not found. Install the sysstat package to monitor disk I/O."
        log "iostat not available for disk I/O monitoring" "WARNING"
        return
    fi
    
    echo -e "\e[1mCurrent Disk I/O:\e[0m"
    iostat -d -x 1 2 | grep -v '^$' | grep -A 20 "Device" | tail -n +2
    
    log "Disk I/O check completed" "DEBUG"
}

# Function to check services status
function check_services {
    if [ "$MONITOR_SERVICES" != true ]; then
        return
    fi

    echo -e "\n\e[1;35m╔════════════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[1;35m║                   SERVICE STATUS                            ║\e[0m"
    echo -e "\e[1;35m╚════════════════════════════════════════════════════════════╝\e[0m"
    
    if [ ! -f "$SERVICES_FILE" ]; then
        echo "Services configuration file not found at $SERVICES_FILE"
        log "Services configuration file not found" "WARNING"
        return
    fi
    
    # Read the services file, skipping comments and empty lines
    while IFS= read -r service || [ -n "$service" ]; do
        # Skip comments and empty lines
        [[ "$service" =~ ^#.*$ || -z "$service" ]] && continue
        
        echo -n -e "\e[1m• $service:\e[0m "
        
        # Check if service exists first
        if ! systemctl list-unit-files | grep -q "$service.service"; then
            echo -e "\e[1;90mNot Installed\e[0m"
            continue
        fi
        
        # Check service status
        if systemctl is-active --quiet "$service"; then
            echo -e "\e[1;32mRunning\e[0m"
        else
            echo -e "\e[1;31mStopped\e[0m"
            alert "Service $service is not running" "WARNING"
        fi
    done < "$SERVICES_FILE"
    
    log "Services check completed" "DEBUG"
}

# Function to check network connectivity
function check_network {
    if [ "$MONITOR_NETWORK" != true ]; then
        return
    fi

    echo -e "\n\e[1;34m╔════════════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[1;34m║                   NETWORK CONNECTIVITY                      ║\e[0m"
    echo -e "\e[1;34m╚════════════════════════════════════════════════════════════╝\e[0m"
    
    if [ ! -f "$NETWORK_TARGETS_FILE" ]; then
        echo "Network targets file not found at $NETWORK_TARGETS_FILE"
        log "Network targets file not found" "WARNING"
        return
    fi
    
    # Check if we have internet connectivity at all
    echo -e "\e[1m• Internet Connectivity:\e[0m"
    
    # Read the network targets file
    while IFS=, read -r target description || [ -n "$target" ]; do
        # Skip comments and empty lines
        [[ "$target" =~ ^#.*$ || -z "$target" ]] && continue
        
        # Clean up any whitespace
        target=$(echo "$target" | xargs)
        description=$(echo "$description" | xargs)
        
        # Test connectivity with timeout
        if ping -c 1 -W 2 "$target" >/dev/null 2>&1; then
            echo -e "  - $description ($target): \e[1;32mReachable\e[0m"
        else
            echo -e "  - $description ($target): \e[1;31mUnreachable\e[0m"
            alert "Network connectivity to $description ($target) failed" "WARNING"
        fi
    done < "$NETWORK_TARGETS_FILE"
    
    # Display current network interfaces and their states
    echo -e "\n\e[1m• Network Interfaces:\e[0m"
    ip -o link show | grep -v "lo:" | awk '{gsub(/:/, " "); print $2, $9}' | while read -r interface state; do
        local ip_addr=$(ip -o addr show dev "$interface" | awk '$3 == "inet" {gsub(/\/.*/, "", $4); print $4}')
        
        if [ "$state" = "UP" ]; then
            echo -e "  - $interface: \e[1;32m$state\e[0m ${ip_addr:+($ip_addr)}"
        else
            echo -e "  - $interface: \e[1;31m$state\e[0m"
        fi
    done
    
    log "Network check completed" "DEBUG"
}

# Function to display top resource-consuming processes
function check_processes {
    if [ "$MONITOR_PROCESSES" != true ]; then
        return
    fi

    echo -e "\n\e[1;31m╔════════════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[1;31m║                TOP RESOURCE CONSUMERS                       ║\e[0m"
    echo -e "\e[1;31m╚════════════════════════════════════════════════════════════╝\e[0m"
    
    echo -e "\e[1m• Top CPU Consumers:\e[0m"
    ps aux --sort=-%cpu | head -6 | awk 'NR==1{print} NR>1{printf "  %-10s %-8s %4s%% %s\n", $1, $2, $3, $11}'
    
    echo -e "\n\e[1m• Top Memory Consumers:\e[0m"
    ps aux --sort=-%mem | head -6 | awk 'NR==1{print} NR>1{printf "  %-10s %-8s %4s%% %s\n", $1, $2, $4, $11}'
    
    log "Process check completed" "DEBUG"
}

# Function to display a random anime quote
function display_anime_quote {
    echo -e "\n\e[1;36m╔════════════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[1;36m║                      ANIME WISDOM                           ║\e[0m"
    echo -e "\e[1;36m╚════════════════════════════════════════════════════════════╝\e[0m"
    
    if [ ! -f "$QUOTES_FILE" ]; then
        echo "Quotes file not found at $QUOTES_FILE"
        log "Quotes file not found" "WARNING"
        return
    fi
    
    # Count lines in the quotes file that are not empty
    local quote_count=$(grep -v '^$' "$QUOTES_FILE" | wc -l)
    
    # Get a random line number
    local random_line=$((RANDOM % quote_count + 1))
    
    # Get the quote at that line
    local quote=$(grep -v '^$' "$QUOTES_FILE" | sed -n "${random_line}p")
    
    # Display the quote with proper formatting
    echo -e "\e[1;34m$quote\e[0m"
    
    log "Anime quote displayed" "DEBUG"
}

# Function to perform system maintenance tasks
function system_maintenance {
    echo -e "\n\e[1;31m╔════════════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[1;31m║                  SYSTEM MAINTENANCE                         ║\e[0m"
    echo -e "\e[1;31m╚════════════════════════════════════════════════════════════╝\e[0m"
    
    log "Starting system maintenance tasks" "INFO"
    
    # Check if we have sudo access
    if ! sudo -n true 2>/dev/null; then
        echo "Sudo access is required for maintenance tasks."
        log "Sudo access not available for maintenance tasks" "ERROR"
        return 1
    fi
    
    # Create a backup timestamp
    local backup_time=$(date +%Y-%m-%d_%H-%M-%S)
    echo -e "\e[1m• Creating system snapshot reference point\e[0m"
    
    # Package management based on distribution
    if command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu based
        echo -e "\n\e[1m• Updating package lists\e[0m"
        if sudo apt-get update; then
            log "Package lists updated successfully" "INFO"
        else
            log "Failed to update package lists" "ERROR"
            alert "Failed to update package lists" "ERROR"
        fi
        
        if [ "$AUTO_SECURITY_UPDATES" = true ]; then
            echo -e "\n\e[1m• Installing security updates\e[0m"
            if sudo apt-get -y --only-upgrade install $(apt-get --just-print upgrade | grep -i security | awk '{print $2}' | tr '\n' ' '); then
                log "Security updates installed successfully" "INFO"
            else
                log "Failed to install security updates" "ERROR"
                alert "Failed to install security updates" "ERROR"
            fi
        fi
        
        if [ "$CLEANUP_PACKAGE_CACHE" = true ]; then
            echo -e "\n\e[1m• Cleaning package cache\e[0m"
            if sudo apt-get clean && sudo apt-get autoclean; then
                log "Package cache cleaned successfully" "INFO"
            else
                log "Failed to clean package cache" "WARNING"
            fi
        fi
        
        echo -e "\n\e[1m• Removing unnecessary packages\e[0m"
        if sudo apt-get autoremove -y; then
            log "Unnecessary packages removed successfully" "INFO"
        else
            log "Failed to remove unnecessary packages" "WARNING"
        fi
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora/RHEL 8+ based
        echo -e "\n\e[1m• Updating package lists\e[0m"
        if sudo dnf check-update -y; then
            log "Package lists updated successfully" "INFO"
        else
            log "Failed to update package lists" "ERROR"
            alert "Failed to update package lists" "ERROR"
        fi
        
        if [ "$AUTO_SECURITY_UPDATES" = true ]; then
            echo -e "\n\e[1m• Installing security updates\e[0m"
            if sudo dnf upgrade --security -y; then
                log "Security updates installed successfully" "INFO"
            else
                log "Failed to install security updates" "ERROR"
                alert "Failed to install security updates" "ERROR"
            fi
        fi
        
        if [ "$CLEANUP_PACKAGE_CACHE" = true ]; then
            echo -e "\n\e[1m• Cleaning package cache\e[0m"
            if sudo dnf clean all; then
                log "Package cache cleaned successfully" "INFO"
            else
                log "Failed to clean package cache" "WARNING"
            fi
        fi
    elif command -v yum >/dev/null 2>&1; then
        # CentOS/RHEL based
        echo -e "\n\e[1m• Updating package lists\e[0m"
        if sudo yum check-update -y; then
            log "Package lists updated successfully" "INFO"
        else
            log "Failed to update package lists" "ERROR"
            alert "Failed to update package lists" "ERROR"
        fi
        
        if [ "$AUTO_SECURITY_UPDATES" = true ]; then
            echo -e "\n\e[1m• Installing security updates\e[0m"
            if sudo yum update --security -y; then
                log "Security updates installed successfully" "INFO"
            else
                log "Failed to install security updates" "ERROR"
                alert "Failed to install security updates" "ERROR"
            fi
        fi
        
        if [ "$CLEANUP_PACKAGE_CACHE" = true ]; then
            echo -e "\n\e[1m• Cleaning package cache\e[0m"
            if sudo yum clean all; then
                log "Package cache cleaned successfully" "INFO"
            else
                log "Failed to clean package cache" "WARNING"
            fi
        fi
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux based
        echo -e "\n\e[1m• Updating package lists\e[0m"
        if sudo pacman -Sy; then
            log "Package lists updated successfully" "INFO"
        else
            log "Failed to update package lists" "ERROR"
            alert "Failed to update package lists" "ERROR"
        fi
        
        if [ "$AUTO_SECURITY_UPDATES" = true ]; then
            echo -e "\n\e[1m• Installing system updates\e[0m"
            if sudo pacman -Su --noconfirm; then
                log "System updates installed successfully" "INFO"
            else
                log "Failed to install system updates" "ERROR"
                alert "Failed to install system updates" "ERROR"
            fi
        fi
        
        if [ "$CLEANUP_PACKAGE_CACHE" = true ]; then
            echo -e "\n\e[1m• Cleaning package cache\e[0m"
            if sudo pacman -Sc --noconfirm; then
                log "Package cache cleaned successfully" "INFO"
            else
                log "Failed to clean package cache" "WARNING"
            fi
        fi
    else
        echo "Unsupported package manager. Manual system maintenance required."
        log "Unsupported package manager detected" "WARNING"
    fi
    
    # Clean up temp files
    if [ "$CLEANUP_TEMP_FILES" = true ]; then
        echo -e "\n\e[1m• Cleaning temporary files\e[0m"
        if sudo find /tmp -type f -atime +2 -delete 2>/dev/null; then
            log "Temporary files cleaned successfully" "INFO"
        else
            log "Failed to clean temporary files" "WARNING"
        fi
        
        # Clean up log files over 100MB
        echo -e "\n\e[1m• Checking for large log files\e[0m"
        large_logs=$(sudo find /var/log -type f -size +100M)
        if [ -n "$large_logs" ]; then
            echo "Large log files found:"
            echo "$large_logs"
            log "Large log files found and need attention" "WARNING"
            alert "Large log files detected: $large_logs" "WARNING"
        else
            echo "No excessively large log files found."
        fi
    fi
    
    echo -e "\n\e[1;32m✓ Maintenance tasks completed\e[0m"
    log "System maintenance completed" "INFO"
}

# Function to generate a system health report
function generate_report {
    local report_file="/tmp/ninjaops_report_$(date +%Y-%m-%d_%H-%M-%S).txt"
    echo -e "\n\e[1;36m• Generating system health report: $report_file\e[0m"
    
    {
        echo "==========================================="
        echo "          NINJAOPS SYSTEM REPORT          "
        echo "==========================================="
        echo "Generated on: $(date)"
        echo "Hostname: $(hostname)"
        echo "-------------------------------------------"
        echo
        echo "SYSTEM INFORMATION"
        echo "-------------------------------------------"
        echo "OS: $(lsb_release -ds 2>/dev/null || cat /etc/*release | head -n1 || uname -om)"
        echo "Kernel: $(uname -r)"
        echo "Uptime: $(uptime -p)"
        echo
        echo "PERFORMANCE METRICS"
        echo "-------------------------------------------"
        echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')%"
        echo "Memory Usage: $(free | awk '/^Mem/{printf("%.1f%%", $3/$2*100)}')"
        echo "Load Average: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
        echo
        echo "DISK USAGE"
        echo "-------------------------------------------"
        df -h | grep '^/dev/'
        echo
        echo "TOP CPU CONSUMERS"
        echo "-------------------------------------------"
        ps aux --sort=-%cpu | head -6
        echo
        echo "TOP MEMORY CONSUMERS"
        echo "-------------------------------------------"
        ps aux --sort=-%mem | head -6
        echo
        echo "SERVICE STATUS"
        echo "-------------------------------------------"
        if [ -f "$SERVICES_FILE" ]; then
            while IFS= read -r service || [ -n "$service" ]; do
                [[ "$service" =~ ^#.*$ || -z "$service" ]] && continue
                status=$(systemctl is-active "$service" 2>/dev/null || echo "not installed")
                echo "$service: $status"
            done < "$SERVICES_FILE"
        else
            echo "Services file not found"
        fi
        echo
        echo "RECENT SYSTEM ERRORS"
        echo "-------------------------------------------"
        journalctl -p err..alert --since "24 hours ago" --no-pager | tail -n 20
        echo
        echo "==========================================="
        echo "       END OF NINJAOPS SYSTEM REPORT      "
        echo "==========================================="
    } > "$report_file"
    
    echo -e "\e[1;32m✓ Report generated: $report_file\e[0m"
    log "System health report generated: $report_file" "INFO"
    
    # Return the file path
    echo "$report_file"
}

# Function to install any missing dependencies
function check_dependencies {
    echo -e "\n\e[1;36m• Checking dependencies...\e[0m"
    
    local dependencies=("bc" "curl" "iproute2")
    local missing_deps=()
    
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    # Check for optional dependencies
    if [ "$MONITOR_DISK_IO" = true ] && ! command -v iostat >/dev/null 2>&1; then
        missing_deps+=("sysstat")
    fi
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        echo -e "\e[1;32m✓ All required dependencies are installed\e[0m"
    else
        echo -e "\e[1;33m! Missing dependencies: ${missing_deps[*]}\e[0m"
        echo -e "Would you like to install missing dependencies? (y/n)"
        read -r install_deps
        
        if [[ "$install_deps" =~ ^[Yy]$ ]]; then
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update && sudo apt-get install -y "${missing_deps[@]}"
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y "${missing_deps[@]}"
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install -y "${missing_deps[@]}"
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S --noconfirm "${missing_deps[@]}"
            else
                echo "Unsupported package manager. Please install dependencies manually."
                log "Unable to install dependencies: unsupported package manager" "WARNING"
            fi
        else
            log "User declined to install missing dependencies: ${missing_deps[*]}" "WARNING"
        fi
    fi
}

# Function to schedule the script as a cron job
function schedule_monitoring {
    echo -e "\n\e[1;36m• Setting up scheduled monitoring\e[0m"
    
    # Full path to this script
    local script_path=$(readlink -f "$0")
    
    echo "How frequently would you like to run monitoring?"
    echo "1) Hourly"
    echo "2) Daily"
    echo "3) Weekly"
    echo "4) Custom schedule"
    read -p "Choose an option (1-4): " schedule_option
    
    local cron_schedule=""
    case $schedule_option in
        1) cron_schedule="0 * * * *" ;; # Hourly
        2) cron_schedule="0 0 * * *" ;; # Daily at midnight
        3) cron_schedule="0 0 * * 0" ;; # Weekly on Sunday
        4) # Custom
            echo "Enter custom cron schedule (e.g., '*/30 * * * *' for every 30 minutes):"
            read -p "Cron schedule: " cron_schedule
            ;;
        *) 
            echo "Invalid option. Using hourly schedule as default."
            cron_schedule="0 * * * *"
            ;;
    esac
    
    # Create a temporary cron file
    local temp_cron=$(mktemp)
    crontab -l > "$temp_cron" 2>/dev/null || echo "# NinjaOps scheduled monitoring" > "$temp_cron"
    
    # Check if the script is already scheduled
    if grep -q "$script_path" "$temp_cron"; then
        # Update existing entry
        sed -i "s|.* $script_path.*|$cron_schedule $script_path check > /dev/null 2>&1|" "$temp_cron"
    else
        # Add new entry
        echo "$cron_schedule $script_path check > /dev/null 2>&1" >> "$temp_cron"
    fi
    
    # Install the updated crontab
    crontab "$temp_cron"
    rm "$temp_cron"
    
    echo -e "\e[1;32m✓ Monitoring scheduled: $cron_schedule\e[0m"
    log "Monitoring scheduled with cron: $cron_schedule" "INFO"
}

# Function to provide a web dashboard (basic)
function start_dashboard {
    echo -e "\n\e[1;36m• Starting web dashboard\e[0m"
    
    # Check if netcat is installed
    if ! command -v nc >/dev/null 2>&1; then
        echo "Netcat (nc) is required for the web dashboard."
        echo "Please install it with your package manager."
        log "Netcat not found, cannot start dashboard" "ERROR"
        return 1
    fi
    
    # Choose port for the dashboard
    local port=8080
    read -p "Enter port for the dashboard [default: 8080]: " input_port
    if [[ -n "$input_port" ]]; then
        port=$input_port
    fi
    
    # Create a simple HTML dashboard
    local dashboard_file="/tmp/ninjaops_dashboard.html"
    
    # Generate system information for the dashboard
    local sys_info=$(display_sys_info 2>&1)
    local perf_info=$(check_performance 2>&1)
    
    # Create the HTML file
    cat > "$dashboard_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>NinjaOps Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
            color: #333;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        header {
            background-color: #2c3e50;
            color: white;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        h1, h2 {
            margin: 0;
        }
        .card {
            background-color: white;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            padding: 20px;
            margin-bottom: 20px;
        }
        .refresh-btn {
            background-color: #3498db;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 5px;
            cursor: pointer;
        }
        pre {
            background-color: #f9f9f9;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
        }
        .anime-quote {
            font-style: italic;
            padding: 15px;
            background-color: #e8f4f8;
            border-radius: 5px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>NinjaOps Dashboard</h1>
            <p>System monitoring with a touch of anime wisdom</p>
        </header>
        
        <div class="card">
            <h2>System Information</h2>
            <pre>${sys_info}</pre>
        </div>
        
        <div class="card">
            <h2>Performance Metrics</h2>
            <pre>${perf_info}</pre>
        </div>
        
        <div class="card">
            <h2>Quick Actions</h2>
            <button class="refresh-btn" onclick="location.reload()">Refresh Dashboard</button>
        </div>
        
        <div class="anime-quote">
            "Those who forgive themselves, and are able to accept their true nature... They are the strong ones." – Itachi Uchiha
        </div>
    </div>
</body>
</html>
EOF
    
    echo -e "\e[1;32m✓ Dashboard created at $dashboard_file\e[0m"
    echo -e "\e[1;33m! Starting simple HTTP server on port $port\e[0m"
    echo -e "\e[1;33m! Press Ctrl+C to stop the server\e[0m"
    log "Starting web dashboard on port $port" "INFO"
    
    # Use Python to serve the dashboard if available
    if command -v python3 >/dev/null 2>&1; then
        cd /tmp && python3 -m http.server $port
    elif command -v python >/dev/null 2>&1; then
        cd /tmp && python -m SimpleHTTPServer $port
    else
        echo "Python not found. Cannot start web server."
        log "Python not found, cannot start dashboard server" "ERROR"
        return 1
    fi
}

# Function to create a system backup
function backup_system {
    echo -e "\n\e[1;36m• Creating system backup\e[0m"
    
    # Ask for backup destination
    local default_dest="/var/backups/ninjaops"
    read -p "Enter backup destination [default: $default_dest]: " backup_dest
    backup_dest=${backup_dest:-$default_dest}
    
    # Create destination directory if it doesn't exist
    if [ ! -d "$backup_dest" ]; then
        sudo mkdir -p "$backup_dest"
    fi
    
    # Create a timestamp for the backup
    local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    local backup_file="$backup_dest/system_backup_$timestamp.tar.gz"
    
    # List of important directories to backup
    echo "Which directories would you like to backup?"
    echo "1) Home directories"
    echo "2) Configuration files"
    echo "3) Both"
    echo "4) Custom selection"
    read -p "Choose an option (1-4): " backup_option
    
    local backup_dirs=()
    case $backup_option in
        1) backup_dirs=("/home") ;;
        2) backup_dirs=("/etc") ;;
        3) backup_dirs=("/home" "/etc") ;;
        4) 
            echo "Enter directories to backup (space-separated):"
            read -p "Directories: " custom_dirs
            IFS=' ' read -ra backup_dirs <<< "$custom_dirs"
            ;;
        *) 
            echo "Invalid option. Backing up /etc as default."
            backup_dirs=("/etc")
            ;;
    esac
    
    echo -e "\n\e[1m• Creating backup of: ${backup_dirs[*]}\e[0m"
    echo -e "\e[1m• Backup destination: $backup_file\e[0m"
    
    # Create the backup
    if sudo tar -czf "$backup_file" "${backup_dirs[@]}" 2>/dev/null; then
        echo -e "\e[1;32m✓ Backup created successfully: $backup_file\e[0m"
        log "System backup created: $backup_file" "INFO"
    else
        echo -e "\e[1;31m✗ Backup failed\e[0m"
        log "System backup failed" "ERROR"
        alert "System backup failed" "ERROR"
    fi
}

# Function to display help information
function show_help {
    echo -e "\n\e[1;32mNinjaOps v2.0 - System Monitoring and Maintenance\e[0m"
    echo -e "\e[1mUsage:\e[0m $0 [command] [options]"
    echo
    echo -e "\e[1mCommands:\e[0m"
    echo "  info             - Display system information"
    echo "  check            - Check system performance"
    echo "  services         - Check services status"
    echo "  network          - Check network connectivity"
    echo "  processes        - Show top resource-consuming processes"
    echo "  diskio           - Display disk I/O statistics"
    echo "  quote            - Display a random anime quote"
    echo "  maintenance      - Perform system maintenance tasks"
    echo "  backup           - Create a system backup"
    echo "  report           - Generate system health report"
    echo "  dashboard        - Start the web dashboard"
    echo "  schedule         - Set up scheduled monitoring"
    echo "  setup            - Initial setup and configuration"
    echo "  help             - Show this help message"
    echo
    echo -e "\e[1mOptions:\e[0m"
    echo "  --quiet          - Reduce output verbosity"
    echo "  --no-color       - Disable colored output"
    echo "  --log-level=LVL  - Set log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)"
    echo
    echo -e "\e[1mExample:\e[0m"
    echo "  $0 check         - Run performance check"
    echo "  $0 maintenance   - Perform system maintenance"
}

# Function for initial setup
function setup {
    echo -e "\n\e[1;36m╔════════════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[1;36m║                     INITIAL SETUP                           ║\e[0m"
    echo -e "\e[1;36m╚════════════════════════════════════════════════════════════╝\e[0m"
    
    # Check dependencies
    check_dependencies
    
    # Configure basic settings
    echo -e "\n\e[1m• Configure basic settings\e[0m"
    
    # CPU Threshold
    read -p "Enter CPU usage threshold % [default: $CPU_THRESHOLD]: " input_cpu
    if [[ -n "$input_cpu" ]]; then
        CPU_THRESHOLD=$input_cpu
    fi
    
    # Memory Threshold
    read -p "Enter Memory usage threshold % [default: $MEMORY_THRESHOLD]: " input_mem
    if [[ -n "$input_mem" ]]; then
        MEMORY_THRESHOLD=$input_mem
    fi
    
    # Disk Threshold
    read -p "Enter Disk usage threshold % [default: $DISK_THRESHOLD]: " input_disk
    if [[ -n "$input_disk" ]]; then
        DISK_THRESHOLD=$input_disk
    fi
    
    # Email Alerts
    read -p "Enable email alerts? (y/n) [default: n]: " input_email
    if [[ "$input_email" =~ ^[Yy]$ ]]; then
        ENABLE_EMAIL_ALERTS=true
        read -p "Enter alert email address: " ALERT_EMAIL
    else
        ENABLE_EMAIL_ALERTS=false
    fi
    
    # Auto Maintenance
    read -p "Enable automatic cleanup? (y/n) [default: y]: " input_cleanup
    if [[ "$input_cleanup" =~ ^[Nn]$ ]]; then
        AUTO_CLEANUP=false
    else
        AUTO_CLEANUP=true
    fi
    
    # Security Updates
    read -p "Enable automatic security updates? (y/n) [default: n]: " input_security
    if [[ "$input_security" =~ ^[Yy]$ ]]; then
        AUTO_SECURITY_UPDATES=true
    else
        AUTO_SECURITY_UPDATES=false
    fi
    
    # Save to config file
    cat > /tmp/ninjaops.conf << EOF
# NinjaOps Configuration File
# Updated on $(date)

# Alert thresholds (percent)
CPU_THRESHOLD=$CPU_THRESHOLD
MEMORY_THRESHOLD=$MEMORY_THRESHOLD
DISK_THRESHOLD=$DISK_THRESHOLD

# Log file settings
LOG_FILE="$LOG_FILE"
LOG_LEVEL="INFO"
LOG_MAX_SIZE=10

# Alert settings
ENABLE_EMAIL_ALERTS=$ENABLE_EMAIL_ALERTS
ALERT_EMAIL="$ALERT_EMAIL"
SMTP_SERVER="smtp.example.com"
SMTP_PORT=587
SMTP_USER="user@example.com"
SMTP_PASSWORD="password"

# Maintenance settings
AUTO_CLEANUP=$AUTO_CLEANUP
CLEANUP_TEMP_FILES=true
CLEANUP_PACKAGE_CACHE=true
AUTO_SECURITY_UPDATES=$AUTO_SECURITY_UPDATES

# Monitoring settings
CHECK_INTERVAL=300
MONITOR_SERVICES=true
MONITOR_NETWORK=true
MONITOR_DISK_IO=true
MONITOR_PROCESSES=true
EOF
    sudo mv /tmp/ninjaops.conf "$CONFIG_FILE"
    
    echo -e "\e[1;32m✓ Configuration saved to $CONFIG_FILE\e[0m"
    log "Initial setup completed" "INFO"
    
    # Ask about scheduling
    read -p "Would you like to set up scheduled monitoring? (y/n): " setup_schedule
    if [[ "$setup_schedule" =~ ^[Yy]$ ]]; then
        schedule_monitoring
    fi
}

# Parse command line arguments
COMMAND=""
QUIET_MODE=false
NO_COLOR=false

# Process options
for arg in "$@"; do
    case $arg in
        --quiet)
            QUIET_MODE=true
            shift
            ;;
        --no-color)
            NO_COLOR=true
            shift
            ;;
        --log-level=*)
            LOG_LEVEL="${arg#*=}"
            shift
            ;;
        -*)
            echo "Unknown option: $arg"
            show_help
            exit 1
            ;;
        *)
            if [ -z "$COMMAND" ]; then
                COMMAND=$arg
            fi
            shift
            ;;
    esac
done

# Disable colors if requested
if [ "$NO_COLOR" = true ]; then
    # Remove all color codes
    function echo() {
        command echo "$@" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mK]//g"
    }
fi

# Main execution based on command
case $COMMAND in
    "info")
        display_sys_info
        ;;
    "check")
        check_performance
        ;;
    "services")
        check_services
        ;;
    "network")
        check_network
        ;;
    "processes")
        check_processes
        ;;
    "diskio")
        check_disk_io
        ;;
    "quote")
        display_anime_quote
        ;;
    "maintenance")
        system_maintenance
        ;;
    "backup")
        backup_system
        ;;
    "report")
        report_file=$(generate_report)
        echo -e "\nReport saved to: $report_file"
        ;;
    "dashboard")
        start_dashboard
        ;;
    "schedule")
        schedule_monitoring
        ;;
    "setup")
        setup
        ;;
    "help")
        show_help
        ;;
    "")
        # Run default checks if no command specified
        display_sys_info
        check_performance
        check_services
        check_network
        check_processes
        display_anime_quote
        ;;
    *)
        echo "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac

# Log the end of the script execution
log "NinjaOps execution completed for command: ${COMMAND:-default}" "INFO"

exit 0
EOFNINJA

# Make script executable
chmod +x "$INSTALL_DIR/ninjaops.sh"

# Create symlink
echo -e "\n\e[1m• Creating symlink\e[0m"
ln -sf "$INSTALL_DIR/ninjaops.sh" "$BIN_DIR/$SCRIPT_NAME"

# Create default configuration files
echo -e "\n\e[1m• Creating configuration files\e[0m"

# Default config
cat > "$CONFIG_DIR/config.conf" << EOF
# NinjaOps Configuration File

# Alert thresholds (percent)
CPU_THRESHOLD=85
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90

# Log file settings
LOG_FILE="/var/log/ninjaops.log"
LOG_LEVEL="INFO"
LOG_MAX_SIZE=10

# Alert settings
ENABLE_EMAIL_ALERTS=false
ALERT_EMAIL="admin@example.com"
SMTP_SERVER="smtp.example.com"
SMTP_PORT=587
SMTP_USER="user@example.com"
SMTP_PASSWORD="password"

# Maintenance settings
AUTO_CLEANUP=true
CLEANUP_TEMP_FILES=true
CLEANUP_PACKAGE_CACHE=true
AUTO_SECURITY_UPDATES=false

# Monitoring settings
CHECK_INTERVAL=300
MONITOR_SERVICES=true
MONITOR_NETWORK=true
MONITOR_DISK_IO=true
MONITOR_PROCESSES=true
EOF

# Default services list
cat > "$CONFIG_DIR/services.txt" << EOF
# List of critical services to monitor (one per line)
ssh
cron
nginx
apache2
mysql
postgresql
docker
EOF

# Default network targets
cat > "$CONFIG_DIR/network_targets.txt" << EOF
# Network targets to monitor (one per line)
8.8.8.8,Google DNS
1.1.1.1,Cloudflare DNS
google.com,Google
github.com,GitHub
EOF

# Default quotes file
cat > "$CONFIG_DIR/quotes.txt" << EOF
"Those who forgive themselves, and are able to accept their true nature... They are the strong ones." – Itachi Uchiha, Naruto
"People's lives don't end when they die, it ends when they lose faith." – Itachi Uchiha, Naruto
"The next generation will always surpass the previous one. It's one of the never-ending cycles in life." – Itachi Uchiha, Naruto
"The weak are destined to lie under the heels of the strong." – Madara Uchiha, Naruto
"If you don't share someone's pain, you can never understand them." – Madara Uchiha, Naruto
"The world isn't perfect. But it's there for us, doing the best it can... that's what makes it so damn beautiful." – Roy Mustang, Fullmetal Alchemist: Brotherhood
"A lesson without pain is meaningless. That's because no one can gain without sacrificing something." – Edward Elric, Fullmetal Alchemist
"When you give up, that's when the game is over." – Kuroko Tetsuya, Kuroko no Basket
"If you don't take risks, you can't create a future!" – Monkey D. Luffy, One Piece
"No matter how deep the night, it always turns to day, eventually." – Brook, One Piece
"The only thing we're allowed to do is believe that we won't regret the choice we made." – Levi Ackerman, Attack on Titan
"Sometimes I do feel like I'm a failure. Like there's no hope for me. But even so, I'm not gonna give up. Ever!" – Izuku Midoriya, My Hero Academia
"Power isn't determined by your size, but by the size of your heart and dreams!" – Monkey D. Luffy, One Piece
"The world isn't perfect, but it's there for us, trying the best it can." – Setsuko Meioh, Sailor Moon
"I'll leave tomorrow's problems to tomorrow's me." – Saitama, One Punch Man
"Being alone is more painful than getting hurt." – Monkey D. Luffy, One Piece
"If you don't like your destiny, don't accept it." – Naruto Uzumaki, Naruto
"It's not always possible to do what we want to do, but it's important to believe in something before you actually do it." – Might Guy, Naruto
"Hard work is worthless for those that don't believe in themselves." – Naruto Uzumaki, Naruto
"It's not the face that makes someone a monster; it's the choices they make with their lives." – Naruto Uzumaki, Naruto
EOF

# Create log file
touch "/var/log/ninjaops.log"
chmod 644 "/var/log/ninjaops.log"

echo -e "\n\e[1;32m✓ NinjaOps installation completed!\e[0m"
echo -e "\n\e[1mYou can now run:\e[0m $SCRIPT_NAME help"
echo -e "\e[1mOr setup NinjaOps with:\e[0m $SCRIPT_NAME setup"

# Ask about running setup wizard
echo -e "\n\e[1mWould you like to run the setup wizard now? (y/n)\e[0m"
read -r run_setup
if [[ "$run_setup" =~ ^[Yy]$ ]]; then
    "$BIN_DIR/$SCRIPT_NAME" setup
fi

exit 0