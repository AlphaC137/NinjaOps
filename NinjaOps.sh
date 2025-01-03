#!/bin/bash

# A production tool for system health monitoring and critical task management
# Featuring anime quotes for motivation and system monitoring with alerts

# Set thresholds for alerts (in percentage for CPU, Memory, and Disk Usage)
CPU_THRESHOLD=85
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90

# Log file path
LOG_FILE="/var/log/NinjaOps.log"

# Function to log messages
log_message() {
    local message=$1
    echo "$(date) - $message" >> $LOG_FILE
}

# Function to display system information
function display_sys_info {
    echo -e "\n\e[1;32mSystem Information:\e[0m"
    echo -e "---------------------------------"
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime -p)"
    echo "OS: $(lsb_release -d | cut -f2-)"
    echo "Kernel Version: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "CPU: $(lscpu | grep 'Model name' | cut -d: -f2)"
    echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
    echo "Disk Space: $(df -h | grep '/$' | awk '{print $3 "/" $2}')"
    echo "Network: $(hostname -I)"
}

# Function to check system performance (CPU, Memory, Disk Usage)
function check_performance {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

    echo -e "\n\e[1;33mPerformance Metrics:\e[0m"
    echo -e "CPU Usage: $CPU_USAGE%"
    echo -e "Memory Usage: $MEMORY_USAGE%"
    echo -e "Disk Usage: $DISK_USAGE%"

    # Alert if CPU, Memory, or Disk usage exceeds the threshold
    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        alert "High CPU Usage: $CPU_USAGE% (Threshold: $CPU_THRESHOLD%)"
    fi

    if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
        alert "High Memory Usage: $MEMORY_USAGE% (Threshold: $MEMORY_THRESHOLD%)"
    fi

    if (( $(echo "$DISK_USAGE > $DISK_THRESHOLD" | bc -l) )); then
        alert "High Disk Usage: $DISK_USAGE% (Threshold: $DISK_THRESHOLD%)"
    fi
}

# Function to send alert (email or notification)
function alert {
    local message=$1
    echo "ALERT: $message"
    # Here, we would send an email or system notification. This is a simple echo for now.
    # Uncomment the following lines for email notification:
    # echo "$message" | mail -s "NinjaOps" admin@example.com
    # Or send a desktop notification (for local use):
    # notify-send "NinjaOps Alert" "$message"

    log_message "$message"  # Log the alert
}

# Random Meaningful Anime Quote (with Itachi and Madara's quotes on top)
function display_anime_quote {
    echo -e "\n\e[1;33mRandom Anime Quote:\e[0m"
    quotes=("“The world isn't perfect. But it's there for us, doing the best it can... that's what makes it so damn beautiful.” – Roy Mustang, Fullmetal Alchemist: Brotherhood"
            "“A lesson without pain is meaningless. That’s because no one can gain without sacrificing something. But by enduring that pain and overcoming it, he shall obtain a powerful, unmatched heart.” – Edward Elric, Fullmetal Alchemist"
            "“When you give up, that’s when the game is over.” – Kuroko Tetsuya, Kuroko no Basket"
            "“To know sorrow is not terrifying. What is terrifying is to know you can’t go back to happiness you could have.” – Hinata Shoyo, Haikyuu!!"
            "“If you don’t take risks, you can’t create a future!” – Monkey D. Luffy, One Piece"
            "“The things that are most important aren't written in books. They can't be seen or touched. They must be felt with the heart.” – Hinata Hyuga, Naruto"
            "“You should enjoy the little detours. Sometimes they take you to the best places.” – Inuyasha, Inuyasha"
            "“The only thing we’re allowed to do is believe that we won’t regret the choice we made.” – Levi Ackerman, Attack on Titan"
            "“No matter how deep the night, it always turns to day, eventually.” – Brook, One Piece"
            "“If you don’t fight, you can’t win!” – Ikki Kurogane, Rakudai Kishi no Cavalry"
            "“Those who forgive themselves, and are able to accept their true nature... They are the strong ones.” – Itachi Uchiha, Naruto"
            "“People’s lives don’t end when they die, it ends when they lose faith.” – Itachi Uchiha, Naruto"
            "“The next generation will always surpass the previous one. It’s one of the never-ending cycles in life.” – Itachi Uchiha, Naruto"
            "“No matter how much it hurts now, someday you will look back and realize your struggles changed your life for the better.” – Itachi Uchiha, Naruto"
            "“The weak are destined to lie under the heels of the strong.” – Madara Uchiha, Naruto"
            "“If you don't share someone's pain, you can never understand them.” – Madara Uchiha, Naruto"
            "“The world is full of lies, it’s just that we all choose to live in them.” – Madara Uchiha, Naruto"
            "“You can't ever truly be happy if you don't accept the reality of life. You must move forward regardless of the pain.” – Madara Uchiha, Naruto"
            "“When a man learns to love, he must bear the risk of hatred.” – Madara Uchiha, Naruto")

    RANDOM_QUOTE=${quotes[$RANDOM % ${#quotes[@]}]}
    echo -e "\n\e[1;34mAnime Quote:\e[0m"
    echo "$RANDOM_QUOTE"
}

# Function to run system maintenance tasks (cleanup, updates, etc.)
function system_maintenance {
    echo -e "\n\e[1;31mRunning System Maintenance...\e[0m"
    log_message "Running system maintenance tasks."

    # Clean package cache (for systems with apt)
    sudo apt-get clean

    # Update system packages
    sudo apt-get update && sudo apt-get upgrade -y

    # Remove unnecessary files (adjust for your system)
    sudo apt-get autoremove -y

    echo -e "\n\e[1;32mMaintenance Complete!\e[0m"
    log_message "System maintenance completed."
}

# Function to run the script based on command-line arguments
function run_task {
    case $1 in
        "info")
            display_sys_info
            ;;
        "check")
            check_performance
            ;;
        "quote")
            display_anime_quote
            ;;
        "maintenance")
            system_maintenance
            ;;
        *)
            echo -e "\nUsage: $0 {info|check|quote|maintenance}"
            exit 1
            ;;
    esac
}

# Log the start of the script
log_message "NinjaOps started."

# Display the system info by default
if [ $# -eq 0 ]; then
    display_sys_info
    check_performance
    display_anime_quote
else
    run_task $1
fi

# End of script
log_message "NinjaOps completed."
exit 0
