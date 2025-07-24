local Players = game:GetService("Players")
local BanService = {}

function BanService.banPlayer(userId, duration, displayReason, privateReason, antiCheat)
	local reason
	if antiCheat == true then
		reason = "You have been banned by the SGAC.\nReason: " .. (displayReason or "No reason provided")
	else
		reason = "You have been banned.\nReason: " .. (displayReason or "No reason provided")
	end

	local config = {
		UserIds = { userId },
		Duration = duration or -1,
		DisplayReason = reason,
		PrivateReason = privateReason or "No note provided",
		ExcludeAltAccounts = false,
		ApplyToUniverse = true,
	}

	for attempt = 1, 3 do
		local success, err = pcall(function()
			Players:BanAsync(config)
		end)

		if success then
			return true
		else
			warn("Ban attempt " .. attempt .. " failed: " .. tostring(err))
		end

		if attempt < 3 then
			task.wait(3)
		end
	end

	warn("Failed to ban user " .. userId .. " after 3 attempts")
	return false
end

function BanService.progressiveBan(userId, displayReason, privateReason)
	local success, banHistory = pcall(function()
		return Players:GetBanHistoryAsync(userId)
	end)

	if not success then
		warn("Failed to get ban history for user " .. userId .. ": " .. tostring(banHistory))
		return false
	end

	-- Check if user has a previous progressive ban
	local hasPreviousProgressiveBan = false
	if banHistory then
		-- Iterate through all pages of ban history
		local currentPage = banHistory
		while currentPage do
			for _, ban in pairs(currentPage:GetCurrentPage()) do
				if ban.PrivateReason and string.find(ban.PrivateReason, "PGB") then
					hasPreviousProgressiveBan = true
					break
				end
			end

			if hasPreviousProgressiveBan then
				break
			end

			-- Move to next page if available
			if currentPage.IsFinished then
				break
			else
				local pageSuccess, err = pcall(function()
					currentPage:AdvanceToNextPageAsync()
				end)

				if not pageSuccess then
					warn("Failed to advance to next page of ban history: " .. tostring(err))
					break
				end
			end
		end
	end

	local duration
	local finalPrivateReason

	if hasPreviousProgressiveBan then
		-- Permanent ban if they already have a PGB ban
		duration = -1
		finalPrivateReason = (privateReason or "No reason provided") .. " | PGB - Permanent"
	else
		-- 30 day ban for first progressive ban
		duration = 30 * 24 * 60 * 60 -- 30 days in seconds
		finalPrivateReason = (privateReason or "No reason provided") .. " | PGB"
	end

	return BanService.banPlayer(userId, duration, displayReason, finalPrivateReason, false)
end

return BanService
