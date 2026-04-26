# Claude Cowork Data Management Tool

Tools and guides for managing Claude Cowork's virtual disk (VHDX) and preventing C: drive space exhaustion.

## 🚨 Problem

**Claude Cowork silently consumes several GB to tens of GB on your C: drive.**

When you use Cowork, it creates a virtual disk (VHDX file) in:
```
C:\Users\<YourName>\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Local\vm_bundles\
```

> **Note:** The package folder is typically `Claude_pzs8sxrjxfjjc` for standard installations. If your folder name differs, adjust paths accordingly.

Most users don't notice until their C: drive runs out of space.

## ✨ Primary Solution: Move VHDX to Another Drive

**Use `move_claude_vmbundles` script to relocate the VHDX to `C:\ClaudeData\` (or any other drive).**

### Step-by-Step Instructions

1. **Close Claude Desktop completely**
   - Quit from system tray
   - Verify `Claude.exe` is not running in Task Manager

2. **Run the script as Administrator:**
   ```batch
   move_claude_vmbundles.bat
   ```
   - Moves `vm_bundles/` to `C:\ClaudeData\vm_bundles\`
   - Creates a junction point at the original location
   - Sets proper AppContainer permissions

3. **Launch Claude Desktop**
   - If Cowork doesn't work immediately, **restart your PC**
   - Junction synchronization may require **multiple reboots** in some cases

### What Gets Moved

- Virtual disk files (VHDX) - the largest space consumer
- All Cowork workspace data

---

## 🔄 PC Migration (Cross-PC Restore)

If you're migrating to a new PC, you need to preserve **two critical folders**:

| Folder | Content |
|--------|---------|
| `vm_bundles/` | Virtual disk (VHDX) - your workspace files |
| `local-agent-mode-sessions/` | Session registry - conversation history |

### Migration Procedure

#### **On Old PC:**

1. **Close Claude Desktop completely**

2. **Backup both folders simultaneously:**
   ```powershell
   # Adjust backup destination as needed
   robocopy 'C:\ClaudeData\vm_bundles' 'D:\Backup\vm_bundles' /E /COPY:DAT /R:1 /W:1
   
   robocopy "$env:USERPROFILE\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\local-agent-mode-sessions" `
            'D:\Backup\sessions' /E /COPY:DAT /R:1 /W:1
   ```

#### **On New PC:**

1. **Install Claude Desktop**

2. **Close Claude.exe completely**

3. **(Optional) Externalize VHDX to C:\ClaudeData:**
   ```batch
   move_claude_vmbundles.bat
   ```
   - Skip this step if you want to keep VHDX in the default location

4. **Restart PC**

5. **Launch Claude and create a dummy Cowork task**
   - This initializes the VHDX file structure
   - Just create any simple task (e.g., "list files in Downloads")

6. **Close Claude.exe completely**

7. **Restore backup using robocopy:**

   **If you externalized (step 3):**
   ```powershell
   robocopy 'D:\Backup\vm_bundles' 'C:\ClaudeData\vm_bundles' /MIR /COPY:DAT /R:1 /W:1
   
   robocopy 'D:\Backup\sessions' "$env:USERPROFILE\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\local-agent-mode-sessions" `
            /MIR /COPY:DAT /R:1 /W:1
   ```

   **If you kept default location (skipped step 3):**
   ```powershell
   robocopy 'D:\Backup\vm_bundles' "$env:USERPROFILE\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Local\vm_bundles" /MIR /COPY:DAT /R:1 /W:1
   
   robocopy 'D:\Backup\sessions' "$env:USERPROFILE\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\local-agent-mode-sessions" `
            /MIR /COPY:DAT /R:1 /W:1
   ```

8. **Fix AppContainer permissions (Administrator PowerShell):**
   ```powershell
   icacls C:\ClaudeData /grant '*S-1-15-2-1:(OI)(CI)F' /T
   ```
   - If you kept default location, adjust path accordingly

9. **Restart PC**

10. **Launch Claude**
    - If synchronization fails, **restart PC again** (may require multiple reboots)

### What Gets Preserved

- ✅ All conversations and projects
- ✅ Authentication state
- ✅ Memory and preferences
- ✅ Workspace files

**Verified Migration Paths:**
- Windows 10 LTSC ↔ Windows 11 25H2

---

## ⚠️ Critical Notes

### Before Running Any Operations

- **Always close Claude Desktop completely**
  - Check system tray
  - Verify in Task Manager that `Claude.exe` is not running

### Backup Guidelines

- **Backup both folders at the exact same time**
- Never restore only one folder - they must be synchronized pairs
- Restoring mismatched versions will cause session errors

### System Requirements

- **Windows 10/11 Pro/Enterprise/Education**
  - **Windows Home is NOT supported** (lacks full Hyper-V)
- **Virtual Machine Platform** must be enabled:
  ```powershell
  Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
  ```
- Administrator privileges required for all operations

### Troubleshooting

**Cowork doesn't work after migration:**
- Restart PC (may need 2-3 reboots for junction sync)
- Verify both folders were restored
- Check AppContainer permissions with `icacls C:\ClaudeData`

**"Plan9 mount failed" error:**
- You're on Windows Home (unsupported)
- Upgrade to Pro/Enterprise/Education

---

## 🔍 Why These Two Folders?

Through extensive cross-PC testing, we confirmed that **only these two folders** contain all Cowork data:

1. **`vm_bundles/`**
   - Contains VHDX virtual disk files
   - Stores all workspace files and execution environment

2. **`local-agent-mode-sessions/`**
   - Registry mapping sessions to VMs
   - Preserves conversation history

**They must be treated as a synchronized pair** - backing up or restoring only one will break the system.

---

## 📝 Files in This Repository

| File | Purpose |
|------|---------|
| `move_claude_vmbundles.bat` | Launcher (run this) |
| `move_claude_vmbundles.ps1` | Main externalization script |
| `README.md` | This guide |

---

## 🔗 Additional Resources

- [Detailed Technical Article (Japanese)](https://qiita.com/) - In-depth verification process and findings
- Issues and pull requests welcome!

---

## 📄 License

MIT License

---

**Author:** Hiroto Kozuki  
**Verified Environments:** Windows 10 LTSC, Windows 11 25H2  
**Last Updated:** April 2026
# Claude Cowork Data Management Tool

Tools and guides for managing Claude Cowork's virtual disk (VHDX) and preventing C: drive space exhaustion.

## 🚨 Problem

**Claude Cowork silently consumes several GB to tens of GB on your C: drive.**

When you use Cowork, it creates a virtual disk (VHDX file) in:
```
C:\Users\<YourName>\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Local\vm_bundles\
```

Most users don't notice until their C: drive runs out of space.

## ✨ Primary Solution: Move VHDX to Another Drive

**Use `move_claude_vmbundles` script to relocate the VHDX to `C:\ClaudeData\` (or any other drive).**

### Step-by-Step Instructions

1. **Close Claude Desktop completely**
   - Quit from system tray
   - Verify `Claude.exe` is not running in Task Manager

2. **Run the script as Administrator:**
   ```batch
   move_claude_vmbundles.bat
   ```
   - Moves `vm_bundles/` to `C:\ClaudeData\vm_bundles\`
   - Creates a junction point at the original location
   - Sets proper AppContainer permissions

3. **Launch Claude Desktop**
   - If Cowork doesn't work immediately, **restart your PC**
   - Junction synchronization may require **multiple reboots** in some cases

### What Gets Moved

- Virtual disk files (VHDX) - the largest space consumer
- All Cowork workspace data

---

## 🔄 PC Migration (Cross-PC Restore)

If you're migrating to a new PC, you need to preserve **two critical folders**:

| Folder | Content |
|--------|---------|
| `vm_bundles/` | Virtual disk (VHDX) - your workspace files |
| `local-agent-mode-sessions/` | Session registry - conversation history |

### Migration Procedure

#### **On Old PC:**

1. **Close Claude Desktop completely**

2. **Backup both folders simultaneously:**
   ```powershell
   # Adjust backup destination as needed
   robocopy 'C:\ClaudeData\vm_bundles' 'D:\Backup\vm_bundles' /E /COPY:DAT /R:1 /W:1
   
   robocopy "$env:USERPROFILE\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\local-agent-mode-sessions" `
            'D:\Backup\sessions' /E /COPY:DAT /R:1 /W:1
   ```

#### **On New PC:**

1. **Install Claude Desktop**

2. **Close Claude.exe completely**

3. **(Optional) Externalize VHDX to C:\ClaudeData:**
   ```batch
   move_claude_vmbundles.bat
   ```
   - Skip this step if you want to keep VHDX in the default location

4. **Restart PC**

5. **Launch Claude and create a dummy Cowork task**
   - This initializes the VHDX file structure
   - Just create any simple task (e.g., "list files in Downloads")

6. **Close Claude.exe completely**

7. **Restore backup using robocopy:**

   **If you externalized (step 3):**
   ```powershell
   robocopy 'D:\Backup\vm_bundles' 'C:\ClaudeData\vm_bundles' /MIR /COPY:DAT /R:1 /W:1
   
   robocopy 'D:\Backup\sessions' "$env:USERPROFILE\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\local-agent-mode-sessions" `
            /MIR /COPY:DAT /R:1 /W:1
   ```

   **If you kept default location (skipped step 3):**
   ```powershell
   robocopy 'D:\Backup\vm_bundles' "$env:USERPROFILE\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Local\vm_bundles" /MIR /COPY:DAT /R:1 /W:1
   
   robocopy 'D:\Backup\sessions' "$env:USERPROFILE\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\local-agent-mode-sessions" `
            /MIR /COPY:DAT /R:1 /W:1
   ```

8. **Fix AppContainer permissions (Administrator PowerShell):**
   ```powershell
   icacls C:\ClaudeData /grant '*S-1-15-2-1:(OI)(CI)F' /T
   ```
   - If you kept default location, adjust path accordingly

9. **Restart PC**

10. **Launch Claude**
    - If synchronization fails, **restart PC again** (may require multiple reboots)

### What Gets Preserved

- ✅ All conversations and projects
- ✅ Authentication state
- ✅ Memory and preferences
- ✅ Workspace files

**Verified Migration Paths:**
- Windows 10 LTSC ↔ Windows 11 25H2

---

## ⚠️ Critical Notes

### Before Running Any Operations

- **Always close Claude Desktop completely**
  - Check system tray
  - Verify in Task Manager that `Claude.exe` is not running

### Backup Guidelines

- **Backup both folders at the exact same time**
- Never restore only one folder - they must be synchronized pairs
- Restoring mismatched versions will cause session errors

### System Requirements

- **Windows 10/11 Pro/Enterprise/Education**
  - **Windows Home is NOT supported** (lacks full Hyper-V)
- **Virtual Machine Platform** must be enabled:
  ```powershell
  Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
  ```
- Administrator privileges required for all operations

### Troubleshooting

**Cowork doesn't work after migration:**
- Restart PC (may need 2-3 reboots for junction sync)
- Verify both folders were restored
- Check AppContainer permissions with `icacls C:\ClaudeData`

**"Plan9 mount failed" error:**
- You're on Windows Home (unsupported)
- Upgrade to Pro/Enterprise/Education

---

## 🔍 Why These Two Folders?

Through extensive cross-PC testing, we confirmed that **only these two folders** contain all Cowork data:

1. **`vm_bundles/`**
   - Contains VHDX virtual disk files
   - Stores all workspace files and execution environment

2. **`local-agent-mode-sessions/`**
   - Registry mapping sessions to VMs
   - Preserves conversation history

**They must be treated as a synchronized pair** - backing up or restoring only one will break the system.

---

## 📝 Files in This Repository

| File | Purpose |
|------|---------|
| `move_claude_vmbundles.bat` | Launcher (run this) |
| `move_claude_vmbundles.ps1` | Main externalization script |
| `README.md` | This guide |

---

## 🔗 Additional Resources

- [Detailed Technical Article (Japanese)](https://qiita.com/) - In-depth verification process and findings
- Issues and pull requests welcome!

---

## 📄 License

MIT License

---

**Author:** Hiroto Kozuki  
**Verified Environments:** Windows 10 LTSC, Windows 11 25H2  
**Last Updated:** April 2026
