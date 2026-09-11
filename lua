-- ==========================================
-- 5. HIZLANDIRILMIŞ SERVER HOP & FARM MANTIĞI
-- ==========================================
local function serverHop()
    if not isFarming then return end
    MainButton.Text = "Hızlı Sunucu Aranıyor..."
    MainButton.BackgroundColor3 = Color3.fromRGB(200, 150, 40)
    
    local PlaceId = game.PlaceId
    
    -- "sortOrder=Asc" ile API'den ilk olarak EN AZ oyuncusu olan sunucuları ister.
    local api_url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=10"
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(api_url))
    end)
    
    if success and result and result.data then
        for _, v in ipairs(result.data) do
            -- En az 1 kişinin olduğu, ama dolu olmayan (oynanabilir) farklı bir sunucu arıyoruz
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) then
                if v.playing > 0 and v.playing < v.maxPlayers and v.id ~= game.JobId then
                    
                    if queue_on_teleport then
                        queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/ZuRciu550/slap-farm/refs/heads/main/lua"))()')
                    end
                    
                    MainButton.Text = "Bulundu! Geçiliyor..."
                    TeleportService:TeleportToPlaceInstance(PlaceId, v.id, LocalPlayer)
                    return -- Işınlanma emri verildi, fonksiyonu durdur
                end
            end
        end
    end
    
    -- Eğer API'den gelen 10 sunucuda uygun yer yoksa 1 saniye bekleyip tekrar dener
    task.wait(1)
    serverHop()
end
