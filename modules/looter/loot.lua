--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local plugin = require('utils/plugins')
local mqUtils = require('utils/mq')
local moveUtils = require('lib/moveutils')
---@type Timer
local timer = require('lib/timer')
--- @type LootItem
local item = require('modules/looter/types/lootitem')
---@type LooterStates
local looterStates = require('modules/looter/types/looterState')
--- @type Repository
local repository = require('modules/looter/repository')

local state = looterStates.Idle

local function typeChrs(message, ...)
  -- https://stackoverflow.com/questions/829063/how-to-iterate-individual-characters-in-lua-string
  local str = string.format(message, ...)
  for c in str:gmatch"." do
    if c == " " then
      mq.cmd("/nomodkey /keypress space chat")
    else
      mq.cmdf("/nomodkey /keypress %s chat", c)
    end
  end
end

---@param itemId integer
---@param itemName string
---@return boolean, LootItem
local function canDestroyItem(itemId, itemName)
  local _, destroyItem = repository:tryGet(itemId)
  return item.DoDestroy, destroyItem or item:new(itemId, itemName)
end

local function alreadyHaveLoreItem(item)
  if not item.Lore() then
    return false
  end

  local findQuery = "="..item.Name()
  return mq.TLO.FindItemCount(findQuery)() > 0 or mq.TLO.FindItemBankCount(findQuery)() > 0
end

---@param item item
---@return boolean
local function canLootItem(item)
  if item.NoDrop() then
    logger.Debug("<%s> is [NO DROP], skipping.", item.Name())
    mq.cmd("/beep")
    return false
  end

  if alreadyHaveLoreItem(item) then
    logger.Debug("<%s> is [Lore] and I already have one.", item.Name())
    mq.cmd("/beep")
    return false
  end

  if item.Stackable() and mq.TLO.Me.FreeInventory() < 1 and mq.TLO.FindItemCount("="..item.Name())() > 0 then

  end

  if  mq.TLO.Me.FreeInventory() < 1 then
    if item.Stackable() and item.Stack() < item.FreeStack() then
      return true
    end

    logger.Debug("My inventory is full!", item.Name())
    mq.cmd("/beep")
    return false
  end

  -- if mq.TLO.Me.LargestFreeInventory() == 0, then mq.TLO.Me.FreeInventory() > 1 indicates a free main inventory slot
  -- mq.TLO.Me.LargestFreeInventory() only checks for free bag slots
  if mq.TLO.Me.LargestFreeInventory() > 0 and mq.TLO.Me.LargestFreeInventory() < item.Size() then
    logger.Warn("I don't have a free inventory space large enough to hold <%s>.", item.Name())
    mq.cmd("/beep")
    return false
  end

  return true
end

local function lootItem(slotNum)
  local lootTimer = timer:new(3)
  local cursor = mq.TLO.Cursor

  while not cursor() and not cursor.ID() and lootTimer:IsRunning() do
    mq.cmdf("/itemnotify loot%d leftmouseup", slotNum)
    mq.delay("1s", function() return cursor() ~= nil end)
  end

  if mq.TLO.Window("ConfirmationDialogBox").Open() then
    mq.cmd("/notify ConfirmationDialogBox Yes_Button leftmouseup")
  elseif mq.TLO.Window("QuantityWnd").Open() then
    mq.cmd("/notify QuantityWnd QTYW_Accept_Button leftmouseup")
  end

  local itemId = cursor.ID()
  if not itemId then
    logger.Debug("Unable to loot item in slotnumber <%d>", slotNum)
    return
  end

  local shouldDestroy, item = canDestroyItem(itemId, cursor.Name())
  if shouldDestroy then
    while cursor() ~= nil and lootTimer:IsRunning() do
      mq.cmdf("/destroy")
      if cursor.ID() == 0 then
        logger.Debug("Succesfully destroyed %s from slot# %s", item.Name, slotNum)
      end
    end
  else
    mqUtils.ClearCursor()
    logger.Debug("Succesfully looted %s from slot# %s", item.Name, slotNum)
  end
end

local function lootCorpse()
  mqUtils.ClearCursor()
  mq.cmd("/loot")
  local corpse = mq.TLO.Corpse
  mq.delay("1s", function() return corpse() and corpse.Items() > 0 end)
  if corpse.Items() > 0 then
    logger.Debug("Looting <%s> with # of items: %d", mq.TLO.Target.Name(), corpse.Items())
    for i=1,corpse.Items() do
      local itemToLoot = corpse.Item(i) --[[@as item]]
      logger.Debug("Looting %s from slot %d of %d", itemToLoot.Name(), i, corpse.Items())

      if canLootItem(itemToLoot) then
        lootItem(i)
        mq.delay(10)
      end
      logger.Debug("Done looting slot <%d>", i)
    end
  end
  logger.Debug("Ending loot on <%s>, no items left: %d", mq.TLO.Target.Name(), corpse.Items())

  if corpse.Items() > 0 then
    mq.cmd("/keypress /")
    mq.delay(1)
    typeChrs("/bca %d - ", mq.TLO.Target.ID())
    mq.delay(1)
    mq.cmd("/notify LootWnd BroadcastButton leftmouseup")
    mq.delay(1)
    mq.cmd("/keypress enter chat")
  end

  if mq.TLO.Corpse.Open() then
    mq.cmd("/notify LootWnd DoneButton leftmouseup")
    mq.delay("1s", function() return mq.TLO.Window("LootWnd").Open() end)
  end
end

local function lootNearestCorpse()
  local startX = mq.TLO.Me.X()
  local startY = mq.TLO.Me.Y()
  local startZ = mq.TLO.Me.Z()
  local isTwisting = plugin.IsLoaded("mq2twist") and mq.TLO.Twist.Twisting()
  if isTwisting then
    mq.cmd("/twist stop")
    mq.delay(20, function() return not mq.TLO.Me.Casting.ID() end)
  end

  if not mq.TLO.Me.Casting.ID() then
    local seekRadius = 100
    local searchCorpseString = string.format("npc corpse zradius 50 radius %s", seekRadius)
    local closestCorpseID = mq.TLO.NearestSpawn(1, searchCorpseString).ID()
    if mq.TLO.Spawn(closestCorpseID) and mqUtils.EnsureTarget(closestCorpseID) then
      local target = mq.TLO.Target
      if target.Distance() > 16 and target.DistanceZ() < 80 then
        moveUtils.MoveToLoc(target.X(), target.Y(), target.Z(), 20, 12)
      end

      if target.Distance() <= 20 and target.DistanceZ() < 40 then
        lootCorpse()
      else
        logger.Info("Corpse %s is %d|%d distance, skipping", target.Name(), target.Distance(), target.DistanceZ())
      end
    else
      logger.Info("Unable to locate or target corpse id <%s>", closestCorpseID)
    end

  else
    logger.Info("Unable to loot corpse, currently casting.")
  end 

  moveUtils.MoveToLoc(startX, startY, startZ, 20, 12)
  state = looterStates.Idle
end

local function markItemForDestroying()
  local cursor = mq.TLO.Cursor
  if not cursor() then
    logger.Debug("No item to mark for destroying on cursor")
    return
  end

  local itemId = cursor.ID()
  local shouldDestroy, item = canDestroyItem(itemId, cursor.Name())
  if shouldDestroy then
    logger.Debug("Item already marked for destroying")
  end

  item.DoDestroy = true
  repository:upsert(item)
  logger.Debug("Marked <%d:%s> for destroying", item.Id, item.Name)
end

local function createAliases()
  mq.unbind('/setdestroyitem')
  mq.unbind('/doloot')
  mq.bind("/setdestroyitem", markItemForDestroying)
  mq.bind("/doloot", function() state = looterStates.Looting end)
end

createAliases()

local function doLoot()
  if state == looterStates.Idle then
    return
  end

  if state == looterStates.Looting then
    lootNearestCorpse()
  end
end

return doLoot