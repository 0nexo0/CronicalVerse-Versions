---o[ GSC version check - the same file in every script, nothing to edit here ]o---
-- fxmanifest.lua:  version '1.5.0'
--                  gsc_version_id 'gsc_kasippu_system'   -- <id>.json in 0nexo0/CronicalVerse-Versions
-- Off: Config.VersionCheck = false (this script) · set gsc_versioncheck false (server.cfg, every script)

local VERSIONS_URL = "https://raw.githubusercontent.com/0nexo0/CronicalVerse-Versions/main/%s.json"

local resource = GetCurrentResourceName()
local scriptId = GetResourceMetadata(resource, 'gsc_version_id', 0) or resource
local current  = GetResourceMetadata(resource, 'version', 0) or "0.0.0"

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
    if GetConvar('gsc_versioncheck', 'true') == 'false' then return end
    if type(Config) == 'table' and Config.VersionCheck == false then return end
    Wait(3000) -- after the start-up spam, so the box is easy to see

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
