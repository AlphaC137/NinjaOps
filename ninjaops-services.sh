[Unit]
Description=NinjaOps System Monitoring Service
After=network.target

[Service]
Type=simple
ExecStart=/opt/ninjaops/ninjaops.sh check
Restart=on-failure
RestartSec=60
User=root
Group=root

[Install]
WantedBy=multi-user.target