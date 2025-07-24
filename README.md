# BanModule

A Roblox module to manage player bans using DataStore and automatic duration escalation.

## 🚀 Features

- Tracks and stores player ban counts using `DataStoreService`
- Automatically increases ban severity:
  - 1st ban: 30 days
  - 2nd+ ban: permanent
- Applies bans with `Players:BanAsync` and built-in retry logic (3 attempts)

## 🧩 Function

### `banPlayer(userId, reason, note)`
**Arguments:**
- `userId` (number): The player's UserId
- `reason` (string): Public ban reason
- `note` (string): Private ban note (not shown to player)

**Behavior:**
- Fetches and updates the player's ban count from `BanData`
- Applies ban depending on count:
  - First ban → 30 days
  - Second or more → permanent (`Duration = -1`)
- Retries `BanAsync` up to 3 times if it fails

## 💾 Data Format

Stored in `BanData` using key: `Player_<userId>`

```lua
{
  Bans = number -- number of bans
}
