--- @type Mq
local mq = require 'mq'
local logger = require 'utils/logging'
local plugin = require 'utils/plugins'
local mqUtils = require 'utils/mqhelpers'
local timer = require 'lib/timer'

plugin.EnsureIsLoaded("mq2nav")

local function findMerchant()
  local merchantSpawn = mq.TLO.NearestSpawn("Merchant radius 100")
  local nav = mq.TLO.Navigation

  if not merchantSpawn() or not nav.PathExists("id "..merchantSpawn.ID()) then
    logger.Warn("There are no merchants nearby!")
    return false
  end

  if mqUtils.EnsureTarget(merchantSpawn.ID()) then
    return not mq.TLO.Target.Aggressive()
  end

  return false
end

---@param target spawn
---@return boolean
local function openMerchant(target)
  local merchantWindow = mq.TLO.Window("MerchantWnd")
  local openMerchantTimer = timer:new(10)

  if not merchantWindow.Open() then
    mq.cmd("/click right target")
    mq.delay("5s", function ()
      return merchantWindow.Open() or openMerchantTimer:IsComplete()
    end)
  end

  if not merchantWindow.Open() then
    logger.Warn("Failed to open trade with [%s].", target.CleanName())
    return false
  end

  mq.delay("5s", function ()
    return (merchantWindow.Child("ItemList") and merchantWindow.Child("ItemList").Items() > 0) or openMerchantTimer:IsComplete()
  end)

  return merchantWindow.Child("ItemList").Items() > 0
end

---@param target spawn
---@return boolean
local function closeMerchant(target)
  local merchantWindow = mq.TLO.Window("MerchantWnd")
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