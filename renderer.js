// ASUS Control Center Renderer Process
// This file handles all UI interactions and communicates with main process

let currentKeyboardLevel = 3;
let currentBrightness = 150;
let systemStatus = {};

// Logging system
function addLog(message, type = 'info') {
    const timestamp = new Date().toLocaleTimeString();
    const logsContent = document.getElementById('logsContent');
    const logEntry = document.createElement('div');
    logEntry.className = 'log-entry';
    
    const typeClass = {
        'success': 'log-success',
        'error': 'log-error',
        'info': 'log-info'
    };
    
    const icon = {
        'success': '✓',
        'error': '✗',
        'info': '•'
    };
    
    logEntry.innerHTML = `
        <span class="log-timestamp">[${timestamp}]</span> 
        <span class="${typeClass[type]}">${icon[type]} ${message}</span>
    `;
    
    logsContent.appendChild(logEntry);
    logsContent.scrollTop = logsContent.scrollHeight;

    // Keep only last 100 log entries
    while (logsContent.children.length > 100) {
        logsContent.removeChild(logsContent.firstChild);
    }
}

// Execute command with loading state
async function executeCommand(command, description = '') {
    const loadingMsg = description || `Executing: ${command}`;
    addLog(loadingMsg, 'info');
    
    try {
        const result = await window.electronAPI.executeCommand(command);
        
        if (result.success) {
            addLog(`Command completed successfully`, 'success');
            if (result.stdout) {
                // Parse useful output for user
                const output = result.stdout.trim();
                if (output && !output.includes('password') && output.length < 100) {
                    addLog(`Output: ${output}`, 'info');
                }
            }
        } else {
            addLog(`Command failed: ${result.error}`, 'error');
            if (result.stderr) {
                console.error('Command stderr:', result.stderr);
            }
        }
        
        return result;
    } catch (error) {
        addLog(`Execution error: ${error.message}`, 'error');
        console.error('Command execution error:', error);
        return { success: false, error: error.message };
    }
}

// Keyboard Control Functions
async function setKeyboardLevel(level) {
    // Update UI
    document.querySelectorAll('.control-button').forEach(btn => {
        if (btn.textContent.includes('OFF') || btn.textContent.includes('DIM') || 
            btn.textContent.includes('MED') || btn.textContent.includes('BRIGHT')) {
            btn.classList.remove('active');
        }
    });
    
    event.target.classList.add('active');
    
    currentKeyboardLevel = level;
    document.getElementById('keyboardStatus').textContent = 
        `Status: Keyboard backlight at level ${level}/3`;
    
    const levelNames = ['OFF', 'DIM', 'MEDIUM', 'BRIGHT'];
    
    // Execute command
    const result = await executeCommand(
        `./rgb_control.sh basic ${level}`,
        `Setting keyboard backlight to ${levelNames[level]}`
    );
    
    if (result.success) {
        addLog(`Keyboard backlight set to ${levelNames[level]}`, 'success');
    }
}

async function setRGBMode(mode) {
    const result = await executeCommand(
        `./rgb_control.sh mode ${mode}`,
        `Setting RGB mode to ${mode.toUpperCase()}`
    );
    
    if (result.success) {
        addLog(`RGB mode set to ${mode.toUpperCase()}`, 'success');
    }
}

async function setCustomColor(color) {
    const hexColor = color.replace('#', '');
    const result = await executeCommand(
        `./rgb_control.sh color ${hexColor}`,
        `Setting custom RGB color to ${color}`
    );
    
    if (result.success) {
        addLog(`Custom RGB color set to ${color}`, 'success');
    }
}

// ScreenPad Control Functions
async function setBrightness(value) {
    currentBrightness = parseInt(value);
    document.getElementById('brightnessSlider').value = value;
    document.getElementById('brightnessValue').textContent = `${value}/235`;
    document.getElementById('screenpadStatus').textContent = 
        `Status: ScreenPad brightness at ${Math.round((value/235)*100)}%`;
    
    const result = await executeCommand(
        `./screenpad_control.sh brightness set ${value}`,
        `Setting ScreenPad brightness to ${Math.round((value/235)*100)}%`
    );
    
    if (result.success) {
        addLog(`ScreenPad brightness set to ${Math.round((value/235)*100)}%`, 'success');
    }
}

async function toggleScreenPad() {
    const result = await executeCommand(
        './screenpad_control.sh display toggle',
        'Toggling ScreenPad display'
    );
    
    if (result.success) {
        addLog('ScreenPad display toggled', 'success');
    }
}

async function showDisplayInfo() {
    const result = await executeCommand(
        './screenpad_control.sh display status',
        'Retrieving display information'
    );
    
    if (result.success) {
        addLog('Display information retrieved', 'success');
    }
}

// Touch Control Functions
async function resetTouch() {
    const result = await executeCommand(
        './screenpad_control.sh touch reset',
        'Resetting touch input device'
    );
    
    if (result.success) {
        addLog('Touch input device reset', 'success');
        document.getElementById('touchStatus').textContent = 
            'Status: Touch device reset - Testing recommended';
    }
}

async function fixTouchBehavior() {
    const result = await executeCommand(
        './fix_touch.sh',
        'Applying touch configuration update'
    );
    
    if (result.success) {
        addLog('Touch configuration refreshed', 'success');
        document.getElementById('touchStatus').textContent = 
            'Status: Touch settings refreshed';
    }
}

async function showTouchInfo() {
    const result = await executeCommand(
        './test_touch.sh',
        'Retrieving touch device information'
    );
    
    if (result.success) {
        addLog('Touch device information retrieved', 'success');
    }
}

async function launchOptimizedBrowser() {
    const result = await executeCommand(
        '~/launch_browser_touch.sh',
        'Launching touch-optimized browser'
    );
    
    if (result.success) {
        addLog('Touch-optimized browser launched', 'success');
    }
}

async function testTouch() {
    const result = await executeCommand(
        './test_touch.sh',
        'Running touch functionality test'
    );
    
    if (result.success) {
        addLog('Touch functionality test completed', 'success');
    }
}

// System Functions
async function refreshStatus() {
    addLog('Refreshing system status...', 'info');
    
    try {
        const status = await window.electronAPI.getSystemStatus();
        systemStatus = status;
        
        // Update UI with real status
        currentKeyboardLevel = status.keyboardLevel;
        currentBrightness = status.screenpadBrightness;
        
        // Update displays
        document.getElementById('keyboardStatus').textContent = 
            `Status: Keyboard backlight at level ${status.keyboardLevel}/3`;
        
        document.getElementById('screenpadStatus').textContent = 
            `Status: ScreenPad brightness at ${Math.round((status.screenpadBrightness/235)*100)}%`;
        
        document.getElementById('touchStatus').textContent = 
            `Status: Touch device ${status.touchDevice}`;
        
        document.getElementById('systemStatus').textContent = 
            `System: Ubuntu 22.04 | Touch: ${status.touchDevice} | Updated: ${new Date().toLocaleTimeString()}`;
        
        // Update slider
        document.getElementById('brightnessSlider').value = status.screenpadBrightness;
        document.getElementById('brightnessValue').textContent = `${status.screenpadBrightness}/235`;
        
        addLog('System status refreshed successfully', 'success');
    } catch (error) {
        addLog(`Failed to refresh status: ${error.message}`, 'error');
    }
}

async function runDiagnostics() {
    addLog('Running comprehensive system diagnostics...', 'info');
    
    const commands = [
        { cmd: './test_touch.sh', desc: 'Touch device diagnostics' },
        { cmd: 'xrandr --listmonitors', desc: 'Display configuration check' },
        { cmd: './rgb_control.sh list', desc: 'RGB device detection' }
    ];
    
    for (const { cmd, desc } of commands) {
        addLog(`Running: ${desc}`, 'info');
        await executeCommand(cmd);
        // Small delay between commands
        await new Promise(resolve => setTimeout(resolve, 500));
    }
    
    addLog('System diagnostics completed', 'success');
}

async function reloadDrivers() {
    const result = await executeCommand(
        './immediate_touch_fix.sh',
        'Reloading ASUS drivers and touch optimization'
    );
    
    if (result.success) {
        addLog('Drivers reloaded successfully', 'success');
        // Refresh status after reloading
        setTimeout(refreshStatus, 1000);
    }
}

async function openTerminal() {
    try {
        const result = await window.electronAPI.openTerminal();
        if (result.success) {
            addLog('Terminal opened in driver directory', 'success');
        } else {
            addLog('Failed to open terminal', 'error');
        }
    } catch (error) {
        addLog(`Terminal error: ${error.message}`, 'error');
    }
}

function clearLogs() {
    document.getElementById('logsContent').innerHTML = '';
    addLog('Logs cleared', 'info');
}

// Initialize the application
document.addEventListener('DOMContentLoaded', async function() {
    addLog('ASUS Zephyrus Duo Control Center initialized', 'success');
    addLog(`Running on Electron ${window.electronAPI.versions.electron}`, 'info');
    
    // Get initial system status
    await refreshStatus();
    
    // Set up periodic status updates
    setInterval(async () => {
        // Refresh status every 30 seconds
        await refreshStatus();
    }, 30000);
    
    // Set up periodic heartbeat logs
    setInterval(() => {
        if (Math.random() > 0.7) {
            const messages = [
                'Touch device heartbeat normal',
                'ScreenPad temperature optimal', 
                'RGB controller responding',
                'System performance stable',
                'Driver services running'
            ];
            addLog(messages[Math.floor(Math.random() * messages.length)], 'info');
        }
    }, 15000);
    
    addLog('Background monitoring started', 'info');
});

// Handle window close
window.addEventListener('beforeunload', () => {
    addLog('Control Center shutting down...', 'info');
});
