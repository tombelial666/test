#!/usr/bin/env node

/**
 * Syncs AGENTS.md and CLAUDE.md files
 * If one file is modified, it copies its content to the other
 * Only syncs if AGENTS.md or CLAUDE.md were edited
 * 
 * This script is called by Cursor hooks (afterFileEdit) and receives JSON via stdin:
 * {
 *   "file_path": "<absolute path>",
 *   "edits": [...]
 * }
 */

import {
  readFileSync, writeFileSync, existsSync, statSync 
} from 'fs';
import { join } from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = join(__dirname, '..');

const AGENTS_PATH = join(rootDir, 'AGENTS.md');
const CLAUDE_PATH = join(rootDir, 'CLAUDE.md');

// Logging helper
function log(message, data = null) {
  const logFile = join(rootDir, '.cursor', 'sync-docs.log');
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] ${message}${data ? '\n' + JSON.stringify(data, null, 2) : ''}\n`;
  try {
    writeFileSync(logFile, logMessage, { flag: 'a' });
  } catch (_err) {
    // Ignore logging errors
  }
}

// Read JSON input from stdin (Cursor hooks pass data this way)
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
      }, 500); // Increased timeout for hook input
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

// Check if we should sync based on file_path from hook input
function shouldSync(filePath) {
  if (!filePath) {
    return false;
  }
  
  const normalizedPath = filePath.replace(/\\/g, '/');
  const isAgents = normalizedPath.endsWith('AGENTS.md');
  const isClaude = normalizedPath.endsWith('CLAUDE.md');
  
  return isAgents || isClaude;
}

function readFile(path) {
  try {
    return readFileSync(path, 'utf-8');
  } catch (_error) {
    return null;
  }
}

function writeFile(path, content) {
  writeFileSync(path, content, 'utf-8');
}

function syncDocs(sourcePath, targetPath, sourceName, targetName) {
  const sourceContent = readFile(sourcePath);
  
  if (!sourceContent) {
    console.error(`Error: ${sourceName} not found at ${sourcePath}`);
    process.exit(1);
  }

  const targetContent = readFile(targetPath);
  
  if (targetContent === sourceContent) {
    console.log(`✓ ${sourceName} and ${targetName} are already in sync`);
    return;
  }

  writeFile(targetPath, sourceContent);
  console.log(`✓ Synced ${sourceName} → ${targetName}`);
}

// Main logic
async function main() {
  log('Script started', { 
    args: process.argv.slice(2),
    cwd: process.cwd(),
    nodePath: process.execPath
  });
  
  // Read input from stdin (Cursor hooks pass JSON this way)
  const hookInput = await readStdin();
  const args = process.argv.slice(2);
  const forceSync = args.includes('--force') || args.includes('-f') || args.includes('--fix');
  
  log('After reading stdin', { 
    hasHookInput: !!hookInput,
    file_path: hookInput?.file_path,
    forceSync
  });
  
  // Check if we should sync (only for AGENTS.md or CLAUDE.md edits)
  if (!forceSync) {
    if (hookInput?.file_path) {
      // Called from Cursor hook - check file_path
      const shouldSyncFile = shouldSync(hookInput.file_path);
      log('Checking if should sync', { 
        file_path: hookInput.file_path,
        shouldSync: shouldSyncFile
      });
      
      if (!shouldSyncFile) {
        // File edited is not AGENTS.md or CLAUDE.md, exit silently
        log('File is not AGENTS.md or CLAUDE.md, exiting');
        process.exit(0);
      }
    } else {
      log('No hook input, assuming manual execution');
    }
    // If called manually, always sync (no time-based checks needed)
  }
  
  // Determine which file to use as source
  let sourceFile = args.find(arg => arg === 'AGENTS' || arg === 'agents' || arg === 'CLAUDE' || arg === 'claude');
  
  // If called from hook and file_path is known, use it to determine source
  if (!sourceFile && hookInput?.file_path) {
    const normalizedPath = hookInput.file_path.replace(/\\/g, '/');
    if (normalizedPath.endsWith('AGENTS.md')) {
      sourceFile = 'AGENTS';
    } else if (normalizedPath.endsWith('CLAUDE.md')) {
      sourceFile = 'CLAUDE';
    }
  }

  log('Determined source file', { sourceFile });
  
  if (sourceFile === 'AGENTS' || sourceFile === 'agents') {
    log('Syncing from AGENTS.md to CLAUDE.md');
    syncDocs(AGENTS_PATH, CLAUDE_PATH, 'AGENTS.md', 'CLAUDE.md');
  } else if (sourceFile === 'CLAUDE' || sourceFile === 'claude') {
    log('Syncing from CLAUDE.md to AGENTS.md');
    syncDocs(CLAUDE_PATH, AGENTS_PATH, 'CLAUDE.md', 'AGENTS.md');
  } else {
    log('Auto-detecting source file');
    // Auto-detect: use the more recently modified file as source
    // Or default to AGENTS.md if both exist
    const agentsExists = existsSync(AGENTS_PATH);
    const claudeExists = existsSync(CLAUDE_PATH);

    if (!agentsExists && !claudeExists) {
      console.error('Error: Neither AGENTS.md nor CLAUDE.md found');
      process.exit(1);
    }

    if (agentsExists && claudeExists) {
      // Check modification times
      const agentsStats = statSync(AGENTS_PATH);
      const claudeStats = statSync(CLAUDE_PATH);
      
      if (agentsStats.mtimeMs >= claudeStats.mtimeMs) {
        syncDocs(AGENTS_PATH, CLAUDE_PATH, 'AGENTS.md', 'CLAUDE.md');
      } else {
        syncDocs(CLAUDE_PATH, AGENTS_PATH, 'CLAUDE.md', 'AGENTS.md');
      }
    } else if (agentsExists) {
      syncDocs(AGENTS_PATH, CLAUDE_PATH, 'AGENTS.md', 'CLAUDE.md');
    } else {
      syncDocs(CLAUDE_PATH, AGENTS_PATH, 'CLAUDE.md', 'AGENTS.md');
    }
  }
}

main().catch((error) => {
  log('Fatal error', {
    error: error.message,
    stack: error.stack 
  });
  console.error('Error:', error);
  process.exit(1);
});
