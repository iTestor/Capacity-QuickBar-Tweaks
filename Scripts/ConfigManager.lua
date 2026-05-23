local ConfigManager = {}

local function EnsureDir(path)
    local dir = path:match("(.*[/\\])")
    if dir then os.execute('mkdir "' .. dir:gsub("/", "\\") .. '" 2>nul') end
end

function ConfigManager.Setup(manifestInfo, settingsDef)
    local self = {}
    self.manifestInfo = manifestInfo -- Tabelle mit name, display, version, github, nexus_id
    self.settingsDef = settingsDef
    self.manifestPath = "./ue4ss/Mods/SN2ModSettings/registrations/" .. manifestInfo.name .. ".lua"

    function self:WriteManifest()
        EnsureDir(self.manifestPath)

        -- Header-Informationen
        local header = string.format("name=%q, display=%q", manifestInfo.name, manifestInfo.display)
        if manifestInfo.version then header = header .. string.format(", version=%q", manifestInfo.version) end
        if manifestInfo.github then header = header .. string.format(", github=%q", manifestInfo.github) end
        if manifestInfo.nexus_id then header = header .. string.format(", nexus_id=%q", manifestInfo.nexus_id) end

        -- Einstellungen generieren
        local settingsString = ""
        for _, s in ipairs(settingsDef) do
            local line = string.format("{ key=%q, title=%q, description=%q, type=%q, default=%s",
                s.key, s.title, s.description, s.type, tostring(s.default))

            -- Optionale Felder
            if s.min then line = line .. ", min=" .. s.min end
            if s.max then line = line .. ", max=" .. s.max end
            if s.step then line = line .. ", step=" .. s.step end
            if s.format then line = line .. string.format(", format=%q", s.format) end
            if s.enabled_by then line = line .. string.format(", enabled_by=%q", s.enabled_by) end

            settingsString = settingsString .. line .. " },\n"
        end

        local manifest = string.format("return { %s, settings = {\n%s} }", header, settingsString)

        local f = io.open(self.manifestPath, "w")
        if f then
            f:write(manifest); f:close()
        end
    end

    function self:UpdateConfig(currentConfig)
        local changed = false
        for _, s in ipairs(settingsDef) do
            local val = ModRef:GetSharedVariable("SN2ModSettings/" .. manifestInfo.name .. "/" .. s.key)
            if val ~= nil and currentConfig[s.key] ~= val then
                currentConfig[s.key] = val
                changed = true
            end
        end
        return changed
    end

    return self
end

return ConfigManager
