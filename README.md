# Claude Cowork Migration Tool

Backup and migration tool for Claude Cowork data (VHDX + sessions). Supports cross-PC restoration and C: drive externalization.

## 🚨 Problem

Claude Cowork stores virtual disk (VHDX) files in your user profile, consuming **several GB to tens of GB** on C: drive without most users noticing.

## ✨ Solution

This tool manages the **two critical folders** that contain all Cowork data:
1. `vm_bundles/` - Virtual disk (VHDX)
2. `local-agent-mode-sessions/` - Session registry

## 📦 Features

- **Backup**: Snapshot both folders simultaneously
- **Restore**: Cross-PC migration (verified: Windows 10 ↔ Windows 11)
- **Externalize**: Move VHDX to another drive (e.g., D:)
- **Preserve**: Conversations, projects, authentication, memory

## 🛠️ Scripts

| Script | Purpose |
|--------|---------|
| `1_backup.bat` | Backup critical folders from old PC |
| `2_externalize_vhdx.bat` | Move VHDX to external drive |
| `3_restore.bat` | Restore from backup on new PC |
| `9_verify.bat` | Verify folder integrity |

## 📖 Usage

### Backup (Old PC)
```powershell
# Run as Administrator
.\1_backup.bat
```

### Restore (New PC)
```powershell
# 1. Install Claude Desktop
# 2. Create a dummy task (to initialize VHDX)
# 3. Close Claude completely
# 4. Run as Administrator
.\2_externalize_vhdx.bat
.\3_restore.bat
```

## ⚠️ Important Notes

- Close Claude Desktop completely before running scripts
- Backup both folders **at the same time**
- Requires Windows 10/11 Pro/Enterprise (Windows Home not supported)
- Restore requires `Virtual Machine Platform` feature enabled

## 🔍 Technical Details

See our [detailed article (Japanese)](https://qiita.com/) for in-depth verification and findings.

## 📝 License

MIT License

---

**Verified Environments:**
- Windows 10 LTSC ↔ Windows 11 25H2
- Claude Desktop (MSIX package)
- Virtual Machine Platform enabled
