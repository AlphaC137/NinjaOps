# NinjaOps 🥷

![Version](https://img.shields.io/badge/version-2.0-blue)
![Platform](https://img.shields.io/badge/platform-Linux-green)
![License](https://img.shields.io/badge/license-MIT-orange)

> A comprehensive system health monitoring and task management tool with a touch of anime wisdom.

## 📖 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Commands](#commands)
- [Monitoring & Alerting](#monitoring--alerting)
- [Web Dashboard](#web-dashboard)
- [Scheduled Monitoring](#scheduled-monitoring)
- [System Maintenance](#system-maintenance)
- [Backup & Reporting](#backup--reporting)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

## 🔍 Overview

NinjaOps is a powerful, feature-rich system monitoring and maintenance tool designed for Linux systems. It provides comprehensive system health checks, performance metrics, service monitoring, automated maintenance, and more - all with an anime-inspired twist that makes system administration less mundane.

Whether you're managing a single server or a fleet of systems, NinjaOps helps you stay on top of system health while occasionally delivering wisdom from your favorite anime characters.

## ✨ Features

- **Comprehensive Monitoring**
  - CPU, memory, and disk usage monitoring with customizable thresholds
  - Load average monitoring
  - Service status checks
  - Network connectivity testing
  - Disk I/O statistics
  - Process resource usage tracking

- **Smart Alerting**
  - Email alerts for critical issues
  - Desktop notifications (when run in a desktop environment)
  - Dynamic threshold adjustment based on time of day
  - Detailed logging with multiple severity levels

- **Maintenance Automation**
  - Package management (apt, dnf, yum, pacman)
  - Security updates installation
  - Temporary files cleanup
  - Package cache management
  - Large log file detection

- **System Administration Tools**
  - System backups creation
  - Health report generation
  - Service monitoring
  - Scheduled execution via cron

- **User Experience**
  - Color-coded output for easy reading
  - Web-based dashboard
  - Motivational anime quotes
  - Comprehensive help system

## 🚀 Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/yourusername/NinjaOps.git

# Navigate to the directory
cd NinjaOps

# Make the script executable
chmod +x NinjaOps.sh

# Run the setup
./NinjaOps.sh setup
```

Alternatively, you can use the provided install script:

```bash
./install.sh
```

### Manual Installation

1. Download the `NinjaOps.sh` script
2. Make it executable: `chmod +x NinjaOps.sh`
3. Run the setup command: `./NinjaOps.sh setup`
4. Follow the interactive prompts to configure settings

## ⚙️ Configuration

NinjaOps uses a configuration file located at `/etc/ninjaops/config.conf`. During initial setup, you'll be prompted to configure:

- CPU, memory, and disk threshold percentages
- Email alert settings
- Automatic cleanup preferences
- Security update automation

Additional configuration files:
- `/etc/ninjaops/services.txt` - List of critical services to monitor
- `/etc/ninjaops/network_targets.txt` - Network connectivity targets
- `/etc/ninjaops/quotes.txt` - Anime quotes collection

You can manually edit these files or run `./NinjaOps.sh setup` to reconfigure.

## 🛠️ Usage

### Basic Usage

```bash
./NinjaOps.sh [command] [options]
```

If no command is specified, NinjaOps will run a comprehensive system check including system info, performance metrics, service status, network connectivity, and top resource-consuming processes.

### Options

- `--quiet` - Reduce output verbosity
- `--no-color` - Disable colored output
- `--log-level=LVL` - Set log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)

## 📋 Commands

| Command | Description |
|---------|-------------|
| `info` | Display system information |
| `check` | Check system performance metrics |
| `services` | Check status of critical services |
| `network` | Check network connectivity |
| `processes` | Show top resource-consuming processes |
| `diskio` | Display disk I/O statistics |
| `quote` | Display a random anime quote |
| `maintenance` | Perform system maintenance tasks |
| `backup` | Create a system backup |
| `report` | Generate system health report |
| `dashboard` | Start the web dashboard |
| `schedule` | Set up scheduled monitoring |
| `setup` | Run initial setup and configuration |
| `help` | Display help information |

### Examples

```bash
# Check performance metrics
./NinjaOps.sh check

# Monitor service status
./NinjaOps.sh services

# Perform system maintenance
./NinjaOps.sh maintenance

# Get some anime wisdom
./NinjaOps.sh quote
```

## 🔔 Monitoring & Alerting

### Thresholds

NinjaOps monitors system resources based on configurable thresholds:
- CPU usage (default: 85%)
- Memory usage (default: 85%)
- Disk usage (default: 90%)

Thresholds are automatically adjusted during off-hours (midnight to 6am) to reduce false alarms.

### Alert Methods

- **Console Output**: Color-coded status indicators
- **Log File**: Detailed logs at `/var/log/ninjaops.log`
- **Email Alerts**: Optional alerts for WARNING, ERROR, and CRITICAL events
- **Desktop Notifications**: When running in a desktop environment

## 🌐 Web Dashboard

NinjaOps includes a simple web dashboard for visual monitoring:

```bash
./NinjaOps.sh dashboard
```

The dashboard runs on port 8080 by default (configurable) and shows:
- System information
- Performance metrics
- Quick action buttons
- An inspirational anime quote

## ⏱️ Scheduled Monitoring

Set up automated monitoring with:

```bash
./NinjaOps.sh schedule
```

Choose from:
- Hourly checks
- Daily checks (at midnight)
- Weekly checks (Sundays)
- Custom cron schedule

The scheduler will set up a cron job to run NinjaOps automatically.

## 🧹 System Maintenance

Run maintenance tasks with:

```bash
./NinjaOps.sh maintenance
```

This performs:
- Package list updates
- Security updates (if enabled)
- Package cache cleanup
- Temporary file cleanup
- Large log file detection

Maintenance adapts to your system's package manager (apt, dnf, yum, pacman).

## 💾 Backup & Reporting

### System Backup

Create system backups with:

```bash
./NinjaOps.sh backup
```

Choose to backup:
- Home directories
- Configuration files
- Both
- Custom directory selection

### Health Report

Generate a comprehensive system health report:

```bash
./NinjaOps.sh report
```

The report includes:
- System information
- Performance metrics
- Disk usage
- Top resource consumers
- Service status
- Recent system errors

## 📦 Dependencies

NinjaOps requires:
- Bash
- bc (basic calculator)
- curl
- iproute2

Optional dependencies:
- sysstat (for disk I/O monitoring)
- mail command (for email alerts)
- Python (for web dashboard)
- notify-send (for desktop notifications)

Missing dependencies will be detected and can be automatically installed during setup.

## 🤝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for details.