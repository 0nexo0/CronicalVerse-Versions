---o[ CronicalVerse version check - the same file in every script, nothing to edit here ]o---
-- Add to a script:
--   1. Copy this file to <script>/cv_core/server/version.lua
--   2. fxmanifest.lua:  server_scripts { 'cv_core/server/version.lua', ... }
--                       version       '1.0.0'
--                       cv_version_id 'my_script'   -- reads my_script.json from 0nexo0/CronicalVerse-Versions
--   3. CronicalVerse-Versions: copy _template.json to my_script.json, commit, push
-- Off: Config.VersionCheck = false (one script) · set cv_versioncheck false (server.cfg, every script)

local VERSIONS_URL = "https://raw.githubusercontent.com/0nexo0/CronicalVerse-Versions/main/%s.json"

local resource = GetCurrentResourceName()

---o[ A key from this script's fxmanifest.lua, or nil when it is missing or empty ]o---
local function Meta(key)
    local value = GetResourceMetadata(resource, key, 0)
    if value ~= nil and value ~= "" then return value end
end

local scriptId = Meta('cv_version_id')
local current  = Meta('version')

---o[ "1.4.0" -> { 1, 4, 0 } ]o---
local function Parts(v)
    local out = {}
    for n in tostring(v or ""):gmatch("%d+") do out[#out + 1] = tonumber(n) end
    return out
end

---o[ -1: a older than b · 0: same · 1: a newer than b ]o---
local function Compare(a, b)
    local pa, pb = Parts(a), Parts(b)
    for i = 1, math.max(#pa, #pb) do
        local x, y = pa[i] or 0, pb[i] or 0
        if x ~= y then return x < y and -1 or 1 end
    end
    return 0
end

local function Line(text)
    print("^3[^5" .. resource .. "^3] " .. text .. "^0")
end

Citizen.CreateThread(function()
    if GetConvar('cv_versioncheck', 'true') == 'false' then return end
    if type(Config) == 'table' and Config.VersionCheck == false then return end
    Wait(3000) -- after the start-up spam, so the box is easy to see

    ---o[ Missing fxmanifest keys: say so, then fall back ]o---
    if not scriptId then
        scriptId = resource
        Line("^3cv_version_id is missing in fxmanifest.lua - using the folder name (" .. resource .. ")")
    end
    if not current then
        current = "0.0.0"
        Line("^3version is missing in fxmanifest.lua - treating it as 0.0.0")
    end

    PerformHttpRequest(VERSIONS_URL:format(scriptId), function(status, body)
        local ok, latest = pcall(json.decode, body or "")
        if status ~= 200 or not ok or type(latest) ~= 'table' or not latest.version then
            return Line("^1Version check failed (HTTP " .. tostring(status) .. ", " .. scriptId .. ".json). Running " .. current)
        end

        local cmp = Compare(current, latest.version)
        if cmp < 0 then
            Line("^1┌──────────────────────────────────────────────────────────────────┐")
            Line("^1├ ❌ Version " .. current .. " OUTDATED! Latest is " .. latest.version .. ". Please upgrade from your keymaster account")
            for _, entry in ipairs(type(latest.changelog) == 'table' and latest.changelog or {}) do
                Line("^1├ ^0" .. tostring(entry))
            end
            if latest.url then Line("^1├ ^0Download: " .. tostring(latest.url)) end
            Line("^1└──────────────────────────────────────────────────────────────────┘")
        elseif cmp > 0 then
            Line("^3├ Version " .. current .. " is newer than the release (" .. latest.version .. ") - dev build")
        else
            Line("^2┌─────────────────────────────┐")
            Line("^2├ ✅ Version " .. current .. " Up to date")
            Line("^2└─────────────────────────────┘")
        end
    end, "GET", "", { ["Cache-Control"] = "no-cache" })
end)
