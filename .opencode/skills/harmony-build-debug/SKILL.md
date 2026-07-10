---
name: harmony-build-debug
description: How to diagnose and fix HarmonyOS build failures using hvigorw output.
---

# Harmony Build Debug Skill

## Description
How to diagnose and fix HarmonyOS build failures using hvigorw output.

## Instructions
When a HarmonyOS build fails:

1. **Read the error output**: Focus on lines containing `ERROR`, ignore `WARN` lines unless relevant.
2. **Common error categories**:
   - **Type errors**: ArkTS strict type checking failures. Fix by adding explicit types or removing unsafe casts.
   - **Import errors**: Missing module or wrong import path. Check `oh-package.json5` dependencies.
   - **Resource errors**: Missing or misnamed resources in `resources/` directory.
   - **Permission errors**: Undeclared permissions in `module.json5`.
   - **SDK version errors**: API level mismatch. Check `compileSdkVersion` in `build-profile.json5`.
3. **Incremental approach**: After fixing errors, run `hmos_compilation` again with `--incremental`.
4. **Clean build**: If incremental build fails unexpectedly, suggest deleting `.hvigor` and `build` directories.

## DevEco Home
- `DEVECO_HOME` must point to the DevEco Studio installation directory.
- Common paths: `C:\Program Files\DevEco Studio` or `%USERPROFILE%\DevEco Studio`.
- The tool needs `tools/node/node.exe`, `tools/hvigor/bin/hvigorw.js`, and `sdk/` inside DEVECO_HOME.
