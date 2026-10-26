# CronicalVerse-Versions

Latest version of every CronicalVerse script. Servers read these files on start to tell the owner if an update is out.
This repo must stay **public**. It holds no code, only version numbers.

## Files

| File | What it is |
|---|---|
| `<script id>.json` | latest release of one script |
| `versioncheck.lua` | the checker; the same file goes in every script |

## A script's JSON

```json
{
    "version": "1.5.0",
    "changelog": [
        "Short line shown to server owners",
        "Another change"
    ],
    "url": "https://keymaster.fivem.net"
}
```

`version` is required. `changelog` and `url` are optional. Keep only the **latest** release in the file.

## Add the checker to a script

1. Copy `versioncheck.lua` into the script, e.g. `cv_core/server/version.lua`.
2. In its `fxmanifest.lua`:
   ```lua
   server_scripts { 'cv_core/server/version.lua', ... }
   version '1.0.0'
   gsc_version_id 'my_script'   -- reads my_script.json from this repo
   ```
3. Add `my_script.json` here.

Without `gsc_version_id` the checker uses the resource folder name. That breaks if a customer renames the folder, so always set it.

## Release a new version

1. In the script: bump `version` in `fxmanifest.lua`.
2. Upload the new build to keymaster.
3. Then here: set `version` and `changelog` in `<script id>.json`, commit, push.

Do step 3 last. Pushing here tells every server to update.

## Turning it off

- One script: `Config.VersionCheck = false` (if the script has it).
- Every CronicalVerse script on a server: `set gsc_versioncheck false` in `server.cfg`.
