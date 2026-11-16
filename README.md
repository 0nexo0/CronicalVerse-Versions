# CronicalVerse-Versions

Latest version of every CronicalVerse script. Servers read these files on start to tell the owner if an update is out.
This repo must stay **public**. It holds no script code: only version numbers, the checker and a template.

## Files

| File | What it is |
|---|---|
| `<script id>.json` | latest release of one script |
| `_template.json` | starting point for a new script's JSON |
| `versioncheck.lua` | the checker; the same file goes in every script |

## Scripts

| Script (folder) | `cv_version_id` | JSON here |
|---|---|---|
| `cv_kasippu_system` | `gsc_kasippu_system` | `gsc_kasippu_system.json` |
| `cv_farming_system` | `cv_farming_system` | `cv_farming_system.json` |
| `cv_horse_siren` | — | `cv_horse_siren.json` |
| `cv_megaphone` | — | `cv_megaphone.json` |
| `gsc_wild_horse` | — | `gsc_wild_horse.json` |

`cv_kasippu_system` keeps the old id on purpose: servers still on 1.5.x read the same file.

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
   cv_version_id 'my_script'   -- reads my_script.json from this repo
   ```
3. Here: copy `_template.json` to `my_script.json`, set `version` and `changelog`, commit, push.

Without `cv_version_id` the checker uses the resource folder name. That breaks if a customer renames the folder, so always set it.
If `cv_version_id` or `version` is missing, the checker says so in the server console.

## Release a new version

1. In the script: bump `version` in `fxmanifest.lua`.
2. Upload the new build to keymaster.
3. Then here: set `version` and `changelog` in `<script id>.json`, commit, push.

Do step 3 last. Pushing here tells every server to update.

## Turning it off

- One script: `Config.VersionCheck = false` (if the script has it).
- Every CronicalVerse script on a server: `set cv_versioncheck false` in `server.cfg`.

## Scripts still on the gsc_ names

Builds released before the rename (`gsc_kasippu_system` 1.5.x) still read `gsc_version_id` and `gsc_versioncheck`. Their JSON here keeps working as it is.

`cv_kasippu_system` 1.6.0 has moved: `cv_version_id 'gsc_kasippu_system'` in `fxmanifest.lua`, and `cv_core/server/version.lua` is `versioncheck.lua`. Any other script still on the gsc_ names moves the same way on its next release.

While servers still run 1.5.x builds, turning every check off needs both lines in `server.cfg`:

```cfg
set cv_versioncheck false
set gsc_versioncheck false
```
