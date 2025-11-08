const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

// Keep a global reference of the window object
let mainWindow;

function createWindow() {
    // Create the browser window
    mainWindow = new BrowserWindow({
        width: 1200,
        height: 900,
        minWidth: 800,
        minHeight: 600,
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            enableRemoteModule: false,
            preload: path.join(__dirname, 'preload.js')
        },
        icon: path.join(__dirname, 'assets', 'icon.png'),
        show: false,
        titleBarStyle: 'hidden',
        titleBarOverlay: {
            color: '#0a0a0a',
            symbolColor: '#ff6600'
        },
        backgroundColor: '#0a0a0a',
        darkTheme: true
    });

    // Load the HTML file
    mainWindow.loadFile('asus_control_center.html');

    // Show window when ready to prevent visual flash
    mainWindow.once('ready-to-show', () => {
        mainWindow.show();
    });

    // Open DevTools in development
    if (process.env.NODE_ENV === 'development') {
        mainWindow.webContents.openDevTools();
    }

    // Emitted when the window is closed
    mainWindow.on('closed', () => {
        mainWindow = null;
    });
}

// This method will be called when Electron has finished initialization
app.whenReady().then(createWindow);

// Quit when all windows are closed
app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

// On macOS, re-create window when dock icon is clicked
app.on('activate', () => {
    if (mainWindow === null) {
        createWindow();
    }
});

// IPC handlers for executing shell commands
ipcMain.handle('execute-command', async (event, command) => {
    return new Promise((resolve, reject) => {
        const fullCommand = `cd /home/omotoye/asus_drivers && ${command}`;
        
        exec(fullCommand, { timeout: 10000 }, (error, stdout, stderr) => {
            if (error) {
                console.error(`Command error: ${error}`);
                resolve({
                    success: false,
                    error: error.message,
                    stdout: stdout || '',
                    stderr: stderr || ''
                });
            } else {
                resolve({
                    success: true,
                    stdout: stdout || '',
                    stderr: stderr || ''
                });
            }
        });
    });
});

// Handler for getting current system status
ipcMain.handle('get-system-status', async () => {
    try {
        const commands = [
            'cat /sys/class/leds/asus::kbd_backlight/brightness',
            'cat /sys/class/backlight/asus_screenpad/brightness',
            'xinput list | grep ELAN9009'
        ];

        const results = await Promise.all(commands.map(cmd => 
            new Promise(resolve => {
                exec(`cd /home/omotoye/asus_drivers && ${cmd}`, (error, stdout) => {
                    resolve(stdout?.trim() || '');
                });
            })
        ));

        return {
            keyboardLevel: parseInt(results[0]) || 0,
            screenpadBrightness: parseInt(results[1]) || 0,
            touchDevice: results[2] ? 'Connected' : 'Disconnected'
        };
    } catch (error) {
        console.error('Error getting system status:', error);
        return {
            keyboardLevel: 0,
            screenpadBrightness: 0,
            touchDevice: 'Unknown'
        };
    }
});

// Handler for showing native dialogs
ipcMain.handle('show-dialog', async (event, options) => {
    const result = await dialog.showMessageBox(mainWindow, options);
    return result;
});

// Handler for opening external terminal
ipcMain.handle('open-terminal', async () => {
    try {
        exec('gnome-terminal --working-directory=/home/omotoye/asus_drivers');
        return { success: true };
    } catch (error) {
        return { success: false, error: error.message };
    }
});

// Handler for file system operations
ipcMain.handle('read-file', async (event, filePath) => {
    try {
        const content = fs.readFileSync(filePath, 'utf8');
        return { success: true, content };
    } catch (error) {
        return { success: false, error: error.message };
    }
});

ipcMain.handle('write-file', async (event, filePath, content) => {
    try {
        fs.writeFileSync(filePath, content, 'utf8');
        return { success: true };
    } catch (error) {
        return { success: false, error: error.message };
    }
});

// Security: Prevent new window creation
app.on('web-contents-created', (event, contents) => {
    contents.on('new-window', (event, navigationUrl) => {
        event.preventDefault();
    });
});

// Auto-updater could be added here for future versions
// const { autoUpdater } = require('electron-updater');
// autoUpdater.checkForUpdatesAndNotify();