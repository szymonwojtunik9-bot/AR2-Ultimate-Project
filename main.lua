-- ==============================================================================
--[ MAIN LOADER - AR2 ULTIMATE PROJECT ]
-- Ten skrypt ładuje wszystkie moduły po kolei.
-- Dzięki podziałowi na pliki, kod jest czystszy i łatwiejszy w edycji.
-- ==============================================================================

local function LoadModule(fileName)
    local success, content = pcall(function()
        return readfile(fileName)
    end)
    
    if success and content then
        print("[LOADER] Ładowanie modułu: " .. fileName)
        loadstring(content)()
    else
        warn("[LOADER] Nie udało się załadować: " .. fileName .. " (Upewnij się, że plik istnieje w folderze workspace)")
    end
end

-- Kolejność ładowania jest ważna:
LoadModule("core_config.lua") -- Musi być pierwszy (ustawia getgenv().SolarConfig)
task.wait(0.1)
LoadModule("esp_visuals.lua")
LoadModule("aim_combat.lua")

print("[LOADER] Wszystkie moduły zostały załadowane pomyślnie.")