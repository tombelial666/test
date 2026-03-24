#!/usr/bin/env node

/**
 * Syncs .claude and .cursor directories
 * If a file in one directory is modified, it copies to the other
 * Only syncs if files in .claude/ or .cursor/ were edited
 * 
 * This script is called by Cursor/Claude hooks (afterFileEdit) and receives JSON via stdin:
 * {
 *   "file_path": "<absolute path>",
 *   "edits": [...]
 * }
 */

import {
  readFileSync, writeFileSync, existsSync, statSync, mkdirSync, readdirSync, lstatSync, copyFileSync 
} from 'fs';
import {
  join, dirname
} from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = join(__dirname, '..');

const CURSOR_DIR = join(rootDir, '.cursor');
const CLAUDE_DIR = join(rootDir, '.claude');

// Parent DevReps workspace — skills synced here so they work when VS Code is opened at DevReps level
const PARENT_DIR = join(rootDir, '..');
const PARENT_CLAUDE_SKILLS_DIR = join(PARENT_DIR, '.claude', 'skills');
const PARENT_CURSOR_SKILLS_DIR = join(PARENT_DIR, '.cursor', 'skills');

// Logging helper
function log(message, data = null) {
  const logFile = join(rootDir, '.cursor', 'sync-configs.log');
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] ${message}${data ? '\n' + JSON.stringify(data, null, 2) : ''}\n`;
  try {
    writeFileSync(logFile, logMessage, { flag: 'a' });
  } catch (_err) {
    // Ignore logging errors
  }
}

// Read JSON input from stdin (Cursor/Claude hooks pass data this way)
async function readStdin() {
  return new Promise((resolve) => {
    let data = '';
    let timeoutId;
    
    process.stdin.setEncoding('utf8');
    
    process.stdin.on('data', (chunk) => {
      data += chunk;
      // Reset timeout when data arrives
      if (timeoutId) clearTimeout(timeoutId);
      timeoutId = setTimeout(() => {
        if (data) {
          try {
            const parsed = JSON.parse(data);
            log('Received stdin data', parsed);
            resolve(parsed);
          } catch (err) {
            log('Error parsing stdin', {
              error: err.message,
              data 
            });
            resolve(null);
          }
        } else {
          log('No stdin data received');
          resolve(null);
        }
      }, 500);
    });
    
    process.stdin.on('end', () => {
      if (timeoutId) clearTimeout(timeoutId);
      if (data) {
        try {
          const parsed = JSON.parse(data);
          log('Received stdin data (on end)', parsed);
          resolve(parsed);
        } catch (err) {
          log('Error parsing stdin (on end)', {
            error: err.message,
            data 
          });
          resolve(null);
        }
      } else {
        log('No stdin data (on end)');
        resolve(null);
      }
    });
    
    // Fallback timeout for manual execution
    setTimeout(() => {
      if (!data) {
        log('Timeout waiting for stdin (manual execution?)');
        resolve(null);
      }
    }, 1000);
  });
}

// Check if file path is in .cursor or .claude directory
function getConfigDir(filePath) {
  if (!filePath) {
    return null;
  }
  
  const normalizedPath = filePath.replace(/\\/g, '/');
  
  if (normalizedPath.includes('/.cursor/')) {
    return 'cursor';
  }
  
  if (normalizedPath.includes('/.claude/')) {
    return 'claude';
  }
  
  return null;
}

// Get relative path from config directory root
function getRelativePath(filePath, configDir) {
  const normalizedPath = filePath.replace(/\\/g, '/');
  const dirPath = configDir === 'cursor' ? CURSOR_DIR : CLAUDE_DIR;
  const dirNormalized = dirPath.replace(/\\/g, '/');
  
  if (normalizedPath.startsWith(dirNormalized)) {
    return normalizedPath.substring(dirNormalized.length + 1);
  }
  
  return null;
}

// Recursively copy directory structure
function copyDirectory(src, dest) {
  if (!existsSync(src)) {
    return;
  }
  
  if (!existsSync(dest)) {
    mkdirSync(dest, { recursive: true });
  }
  
  const entries = readdirSync(src);
  
  for (const entry of entries) {
    const srcPath = join(src, entry);
    const destPath = join(dest, entry);
    const stat = lstatSync(srcPath);
    
    if (stat.isDirectory()) {
      copyDirectory(srcPath, destPath);
    } else {
      copyFileSync(srcPath, destPath);
    }
  }
}

// Sync a single file from source to target
function syncFile(sourcePath, targetPath, relativePath) {
  try {
    if (!existsSync(sourcePath)) {
      log(`Source file does not exist: ${sourcePath}`);
      return false;
    }
    
    // Ensure target directory exists
    const targetDir = dirname(targetPath);
    if (!existsSync(targetDir)) {
      mkdirSync(targetDir, { recursive: true });
    }
    
    // Read source content
    const content = readFileSync(sourcePath, 'utf-8');
    
    // Check if target exists and has same content
    if (existsSync(targetPath)) {
      const targetContent = readFileSync(targetPath, 'utf-8');
      if (targetContent === content) {
        log(`Files already in sync: ${relativePath}`);
        return false;
      }
    }
    
    // Write to target
    writeFileSync(targetPath, content, 'utf-8');
    log(`Synced file: ${relativePath}`);
    console.log(`✓ Synced ${relativePath}`);
    return true;
  } catch (error) {
    log(`Error syncing file ${relativePath}`, { error: error.message });
    console.error(`Error syncing ${relativePath}:`, error.message);
    return false;
  }
}

// Sync entire directory structure
function syncDirectories(sourceDir, targetDir, sourceName, targetName) {
  if (!existsSync(sourceDir)) {
    console.error(`Error: ${sourceName} directory not found at ${sourceDir}`);
    return;
  }
  
  log(`Syncing ${sourceName} → ${targetName}`);
  copyDirectory(sourceDir, targetDir);
  console.log(`✓ Synced ${sourceName} → ${targetName}`);
}

// Sync skills to parent DevReps .claude/skills and .cursor/skills
function syncSkillsToParent(sourceSkillsDir) {
  if (!existsSync(sourceSkillsDir)) return;

  let synced = false;

  for (const targetDir of [PARENT_CLAUDE_SKILLS_DIR, PARENT_CURSOR_SKILLS_DIR]) {
    if (!existsSync(targetDir)) {
      log(`Parent skills dir does not exist, skipping: ${targetDir}`);
      continue;
    }
    copyDirectory(sourceSkillsDir, targetDir);
    console.log(`✓ Synced skills → ${targetDir}`);
    synced = true;
  }

  if (synced) {
    log('Synced skills to parent DevReps directories');
  }
}

// Main logic
async function main() {
  log('Script started', { 
    args: process.argv.slice(2),
    cwd: process.cwd(),
    nodePath: process.execPath
  });
  
  // Read input from stdin (Cursor/Claude hooks pass JSON this way)
  const hookInput = await readStdin();
  const args = process.argv.slice(2);
  const forceSync = args.includes('--force') || args.includes('-f') || args.includes('--fix');
  const syncAll = args.includes('--all') || args.includes('-a');
  
  log('After reading stdin', { 
    hasHookInput: !!hookInput,
    file_path: hookInput?.file_path,
    forceSync,
    syncAll
  });
  
  // Check if we should sync (only for .cursor or .claude edits)
  if (!forceSync && !syncAll) {
    if (hookInput?.file_path) {
      // Called from hook - check file_path
      const configDir = getConfigDir(hookInput.file_path);
      log('Checking if should sync', { 
        file_path: hookInput.file_path,
        configDir
      });
      
      if (!configDir) {
        // File edited is not in .cursor or .claude, exit silently
        log('File is not in .cursor or .claude, exiting');
        process.exit(0);
      }
    } else {
      log('No hook input, assuming manual execution');
    }
  }
  
  if (syncAll) {
    // Sync entire directories
    if (args.includes('cursor') || args.includes('CURSOR')) {
      syncDirectories(CURSOR_DIR, CLAUDE_DIR, '.cursor', '.claude');
    } else if (args.includes('claude') || args.includes('CLAUDE')) {
      syncDirectories(CLAUDE_DIR, CURSOR_DIR, '.claude', '.cursor');
    } else {
      // Auto-detect: use the more recently modified directory
      const cursorExists = existsSync(CURSOR_DIR);
      const claudeExists = existsSync(CLAUDE_DIR);
      
      if (cursorExists && claudeExists) {
        // Check modification times of directories
        const cursorStats = statSync(CURSOR_DIR);
        const claudeStats = statSync(CLAUDE_DIR);
        
        if (cursorStats.mtimeMs >= claudeStats.mtimeMs) {
          syncDirectories(CURSOR_DIR, CLAUDE_DIR, '.cursor', '.claude');
        } else {
          syncDirectories(CLAUDE_DIR, CURSOR_DIR, '.claude', '.cursor');
        }
      } else if (cursorExists) {
        syncDirectories(CURSOR_DIR, CLAUDE_DIR, '.cursor', '.claude');
      } else if (claudeExists) {
        syncDirectories(CLAUDE_DIR, CURSOR_DIR, '.claude', '.cursor');
      }
    }
    return;
  }
  
  // Sync single file based on hook input
  if (hookInput?.file_path) {
    const configDir = getConfigDir(hookInput.file_path);
    const relativePath = getRelativePath(hookInput.file_path, configDir);

    if (configDir && relativePath) {
      if (configDir === 'cursor') {
        const sourcePath = join(CURSOR_DIR, relativePath);
        const targetPath = join(CLAUDE_DIR, relativePath);
        syncFile(sourcePath, targetPath, relativePath);
      } else if (configDir === 'claude') {
        const sourcePath = join(CLAUDE_DIR, relativePath);
        const targetPath = join(CURSOR_DIR, relativePath);
        syncFile(sourcePath, targetPath, relativePath);
      }
      // If the changed file is inside skills/, also propagate to parent DevReps
      if (relativePath.startsWith('skills/') || relativePath.startsWith('skills\\')) {
        syncSkillsToParent(join(CLAUDE_DIR, 'skills'));
      }
      return;
    }
  }
  
  // Manual execution without specific file - sync all
  log('Manual execution, syncing all');
  const cursorExists = existsSync(CURSOR_DIR);
  const claudeExists = existsSync(CLAUDE_DIR);

  if (cursorExists && claudeExists) {
    const cursorStats = statSync(CURSOR_DIR);
    const claudeStats = statSync(CLAUDE_DIR);

    if (cursorStats.mtimeMs >= claudeStats.mtimeMs) {
      syncDirectories(CURSOR_DIR, CLAUDE_DIR, '.cursor', '.claude');
    } else {
      syncDirectories(CLAUDE_DIR, CURSOR_DIR, '.claude', '.cursor');
    }
  } else if (cursorExists) {
    syncDirectories(CURSOR_DIR, CLAUDE_DIR, '.cursor', '.claude');
  } else if (claudeExists) {
    syncDirectories(CLAUDE_DIR, CURSOR_DIR, '.claude', '.cursor');
  }

  // Always propagate skills to parent DevReps workspace
  syncSkillsToParent(join(CLAUDE_DIR, 'skills'));
}

main().catch((error) => {
  log('Fatal error', {
    error: error.message,
    stack: error.stack 
  });
  console.error('Error:', error);
  process.exit(1);
});

