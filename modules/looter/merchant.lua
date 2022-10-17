--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local plugin = require('utils/plugins')
local mqUtils = require('utils/mq')
local timer = require('lib/timer')

plugin.EnsureIsLoaded("mq2nav")

local function findMerchant()
  local merchantSpawn = mq.TLO.Spawn("Merchant")
  local nav = mq.TLO.Navigation

  if not merchantSpawn() or not nav.PathExists("id "..merchantSpawn.ID()) or mqUtils.IsMaybeAggressive(merchantSpawn --[[@as spawn]]) then
    logger.Warn("There are no merchants nearby!")
    return false
  end

  return mqUtils.EnsureTarget(merchantSpawn.ID())
end

---@param target spawn
---@return boolean
local function openMerchant(target)
  local merchantWindow = mq.TLO.Window("MerchantWindow")
  local openMerchantTimer = timer:new(5)
  while not merchantWindow.Open() and openMerchantTimer:IsRunning() do
    mq.cmd("/click right target")
    mq.delay(10)
  end

  if not merchantWindow.Open() then
    logger.Warn("Failed to open trade with [%s].", target.CleanName())
    return false
  end

  while not merchantWindow.Child("ItemList") and merchantWindow.Child("ItemList").Items() > 0 and openMerchantTimer:IsRunning() do
    mq.delay(2)
  end

  return merchantWindow.Child("ItemList").Items() > 0
end

---@param target spawn
---@return boolean
local function closeMerchant(target)
  local merchantWindow = mq.TLO.Window("MerchantWindow")
  local closeMerchantTimer = timer:new(5)
  while merchantWindow.Open() and closeMerchantTimer:IsRunning() do
    mq.cmd("/notify MerchantWnd MW_Done_Button leftmouseup")
    mq.delay(10)
  end

  if merchantWindow.Open() then
    logger.Warn("Failed to close trade with [%s].", target.CleanName())
    return false
  end

  return true
end

local MerchantLib = {
  FindMerchant = findMerchant,
  OpenMerchant = openMerchant,
  CloseMerchant = closeMerchant,
}

return MerchantLib