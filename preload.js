const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electronAPI', {
    // Command execution
    executeCommand: (command) => ipcRenderer.invoke('execute-command', command),
    
    // System status
    getSystemStatus: () => ipcRenderer.invoke('get-system-status'),
    
    // Dialogs
    showDialog: (options) => ipcRenderer.invoke('show-dialog', options),
    
    // Terminal
    openTerminal: () => ipcRenderer.invoke('open-terminal'),
    
    // File operations (for saving/loading configurations)
    readFile: (filePath) => ipcRenderer.invoke('read-file', filePath),
    writeFile: (filePath, content) => ipcRenderer.invoke('write-file', filePath, content),
    
    // Platform info
    platform: process.platform,
    
    // Versions
    versions: {
        node: process.versions.node,
        chrome: process.versions.chrome,
        electron: process.versions.electron
    }
});