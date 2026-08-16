// No privileged APIs are needed by the renderer today. This file exists so
// the BrowserWindow can keep contextIsolation on (and nodeIntegration off)
// while leaving a place to bridge APIs via contextBridge if that changes.
