local DataStoreService = game:GetService("DataStoreService")
local BanStore = DataStoreService:GetDataStore("BanData")
local module = {}

function module.banPlayer(userId, reason, note)
	local key = "Player_" .. userId
	local banCount = 0
	
	-- Get current ban count
	local success, result = pcall(function()
		return BanStore:GetAsync(key)
	end)
	
	if success and result then
		banCount = result.Bans or 0
	elseif not success then
		warn("Failed to get ban data:", result)
		return
	end
	
	-- Increase ban count
	banCount += 1
	
	-- Save updated ban count
	local saveSuccess, saveError = pcall(function()
		BanStore:SetAsync(key, {Bans = banCount})
	end)
	
	if not saveSuccess then
		warn("Failed to save ban data:", saveError)
		return
	end
	
	-- Determine ban duration
	local duration = banCount == 1 and 30 * 24 * 60 * 60 or -1
	
	-- Apply the ban with retry logic
	for attempt = 1, 3 do
		local success, errorMessage = pcall(function()
			game.Players:BanAsync({
				UserIds = {userId},
				Duration = duration,
				DisplayReason = reason,
				PrivateReason = note,
				ApplyToUniverse = true,
				ExcludeAltAccounts = false
			})
		end)
		
		if success then
			break
		elseif attempt < 3 then
			task.wait(60)
		else
			warn("Ban failed after 3 attempts:", errorMessage)
		end
	end
end

return module
