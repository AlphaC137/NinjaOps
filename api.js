#!/usr/bin/env node

// NinjaOps API Server
// This simple API server collects real system metrics and serves them as JSON data

const http = require('http');
const { execSync } = require('child_process');
const os = require('os');
const fs = require('fs');

const PORT = process.env.PORT || 3000;

// Function to safely execute shell commands and handle errors
function safeExec(command) {
    try {
        return execSync(command, { encoding: 'utf8' }).trim();
    } catch (error) {
        console.error(`Error executing command: ${command}`, error);
        return 'Error collecting data';
    }
}

// Function to get system information
function getSystemInfo() {
    return {
        hostname: os.hostname(),
        os: safeExec('lsb_release -ds 2>/dev/null || cat /etc/*release | head -n1 || uname -om'),
        kernel: os.release(),
        uptime: formatUptime(os.uptime())
    };
}

// Function to format uptime in days, hours
function formatUptime(seconds) {
    const days = Math.floor(seconds / 86400);
    const hours = Math.floor((seconds % 86400) / 3600);
    return `${days} days, ${hours} hours`;
}

// Function to get CPU usage
function getCpuUsage() {
    // This is a simplified method that works on Linux
    try {
        const cpuInfo = safeExec('top -bn1 | grep "Cpu(s)" | sed "s/.*, *\\([0-9.]*\\)%* id.*/\\1/" | awk \'{print 100 - $1}\'');
        return parseFloat(cpuInfo).toFixed(1);
    } catch (error) {
        console.error('Error getting CPU usage', error);
        return 0;
    }
}

// Function to get memory usage
function getMemoryUsage() {
    const total = os.totalmem();
    const free = os.freemem();
    const used = total - free;
    const percentUsed = ((used / total) * 100).toFixed(1);
    return percentUsed;
}

// Function to get disk usage
function getDiskUsage() {
    try {
        const diskData = {};
        const dfOutput = safeExec('df -h | grep "^/dev/"');
        
        const lines = dfOutput.split('\n');
        lines.forEach(line => {
            const parts = line.split(/\s+/);
            if (parts.length >= 6) {
                const mountpoint = parts[5];
                const usagePercent = parts[4].replace('%', '');
                
                // Map mount points to more readable names
                if (mountpoint === '/') {
                    diskData.root = usagePercent;
                } else if (mountpoint === '/home') {
                    diskData.home = usagePercent;
                } else if (mountpoint === '/var') {
                    diskData.var = usagePercent;
                }
            }
        });
        
        // Set defaults if mount points weren't found
        if (!diskData.root) diskData.root = '0';
        if (!diskData.home) diskData.home = '0';
        if (!diskData.var) diskData.var = '0';
        
        return diskData;
    } catch (error) {
        console.error('Error getting disk usage', error);
        return { root: '0', home: '0', var: '0' };
    }
}

// Function to get services status
function getServicesStatus() {
    try {
        const services = ['nginx', 'postgresql', 'docker', 'mysql', 'apache2'];
        const servicesStatus = {};
        
        services.forEach(service => {
            const status = safeExec(`systemctl is-active ${service} 2>/dev/null || echo "inactive"`);
            servicesStatus[service] = status === 'active' ? 'running' : 'stopped';
        });
        
        return servicesStatus;
    } catch (error) {
        console.error('Error getting services status', error);
        return {};
    }
}

// Function to get load average
function getLoadAverage() {
    const load = os.loadavg();
    return `${load[0].toFixed(2)}, ${load[1].toFixed(2)}, ${load[2].toFixed(2)}`;
}

// Function to get network connectivity status
function getNetworkStatus() {
    try {
        const targets = [
            { host: '8.8.8.8', name: 'Google DNS (8.8.8.8)' },
            { host: '1.1.1.1', name: 'Cloudflare DNS (1.1.1.1)' },
            { host: 'google.com', name: 'Google (google.com)' },
            { host: 'github.com', name: 'GitHub (github.com)' }
        ];
        
        const networkStatus = {};
        
        targets.forEach(target => {
            // Use ping with a short timeout to check connectivity
            const result = safeExec(`ping -c 1 -W 2 ${target.host} >/dev/null 2>&1 && echo "reachable" || echo "unreachable"`);
            
            // Get response time if reachable
            let responseTime = '-';
            if (result === 'reachable') {
                const pingOutput = safeExec(`ping -c 1 ${target.host} | grep "time=" | awk -F "time=" '{print $2}' | awk '{print $1}'`);
                if (pingOutput !== 'Error collecting data') {
                    responseTime = pingOutput;
                }
            }
            
            networkStatus[target.name] = {
                status: result,
                responseTime: responseTime
            };
        });
        
        return networkStatus;
    } catch (error) {
        console.error('Error getting network status', error);
        return {};
    }
}

// Function to get top processes
function getTopProcesses() {
    try {
        const psOutput = safeExec('ps aux --sort=-%cpu | head -6 | tail -n +2');
        const lines = psOutput.split('\n');
        
        const processes = lines.map(line => {
            const parts = line.trim().split(/\s+/);
            if (parts.length >= 11) {
                return {
                    process: parts[10],
                    cpu: parts[2],
                    memory: parts[3]
                };
            }
            return null;
        }).filter(Boolean);
        
        return processes;
    } catch (error) {
        console.error('Error getting top processes', error);
        return [];
    }
}

// Collect all metrics and return as JSON
function getAllMetrics() {
    return {
        systemInfo: getSystemInfo(),
        cpuUsage: getCpuUsage(),
        memoryUsage: getMemoryUsage(),
        diskUsage: getDiskUsage(),
        loadAverage: getLoadAverage(),
        servicesStatus: getServicesStatus(),
        networkStatus: getNetworkStatus(),
        topProcesses: getTopProcesses()
    };
}

// Create HTTP server
const server = http.createServer((req, res) => {
    // Set CORS headers to allow requests from any origin
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    // Handle preflight requests
    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }
    
    // Only handle GET requests
    if (req.method !== 'GET') {
        res.writeHead(405, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Method not allowed' }));
        return;
    }
    
    // Serve metrics
    if (req.url === '/api/metrics') {
        const metrics = getAllMetrics();
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(metrics));
        return;
    }
    
    // Handle unknown endpoints
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
});

// Start the server
server.listen(PORT, () => {
    console.log(`NinjaOps API server running on port ${PORT}`);
    console.log(`Access metrics at: http://localhost:${PORT}/api/metrics`);
});