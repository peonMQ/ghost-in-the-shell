--- @type Mq
local mq = require 'mq'
local logger = require 'utils/logging'
local debugUtils = require 'utils/debug'
local plugins = require 'utils/plugins'
local moveUtils = require 'lib/moveutils'
local timer = require 'lib/timer'
local merchant = require 'modules/looter/merchant'
--- @type LootItem
local item = require 'modules/looter/types/lootitem'
---@type LooterStates
local looterStates = require 'modules/looter/types/looterState'
--- @type Repository
local repository = require 'modules/looter/repository'

local state = looterStates.Idle

---@param itemId integer
---@param itemName string
---@return boolean, LootItem
local function canSellItem(itemId, itemName)
  local itemToSell = repository:tryGet(itemId)
  if not itemToSell then
    itemToSell = item:new(itemId, itemName)
  end

  return itemToSell.DoSell, itemToSell
end

---@param itemToSell item
local function sellItem(itemToSell)
  if not itemToSell() then
    return
  end

  local shouldSell, _ =  canSellItem(itemToSell.ID(), itemToSell.Name())
  if not shouldSell then
    logger.Info("%s has not listed for selling, skipping.", itemToSell.Name())
    return
  end

  if itemToSell.Value() <= 0 then
    logger.Info("%s has no value, skipping.", itemToSell.Name())
    return
  end

  local retryTimer = timer:new(3)
  local merchantWindow = mq.TLO.Window("MerchantWnd")

  local packslot = itemToSell.ItemSlot() - 22
  while merchantWindow.Child("MW_SelectedItemLabel").Text() ~= itemToSell.Name() do
    if(itemToSell.ItemSlot2() >= 0) then
      mq.cmdf("/nomodkey /itemnotify in pack%d %d leftmouseup", packslot, itemToSell.ItemSlot2() + 1)
    else
      mq.cmdf("/nomodkey /itemnotify pack%d leftmouseup", packslot)
    end

    mq.delay(retryTimer:TimeRemaining(), function() return merchantWindow.Child("MW_SelectedItemLabel").Text() == itemToSell.Name() end)

    if(retryTimer:IsComplete()) then
      logger.Error("Failed to select [%s], skipping.", itemToSell.Name())
      return
    end
  end

  mq.delay("1s", function() return merchantWindow.Child("MW_Sell_Button").Enabled() end)
  mq.cmd("/notify MerchantWnd MW_Sell_Button leftmouseup")

  local quantityWindow = mq.TLO.Window("QuantityWnd")
  mq.delay(30, function() return quantityWindow() and merchantWindow.Open() end)
  if(quantityWindow() and quantityWindow.Open()) then
    mq.cmd("/notify QuantityWnd QTYW_Accept_Button leftmouseup")
    mq.delay(30, function() return not quantityWindow() or not quantityWindow.Open() end)
  end

  mq.delay("1s", function() return not merchantWindow.Child("MW_Sell_Button").Enabled() end)

  if(itemToSell.ItemSlot2() >= 0 and mq.TLO.Me.Inventory("pack"..packslot).Item(itemToSell.ItemSlot).Item())
    or mq.TLO.Me.Inventory("pack"..packslot).Item() then
    logger.Error("Failed to sell [%s], skipping.", itemToSell.Name())
  end
end

local function sellItems()
  local startX = mq.TLO.Me.X()
  local startY = mq.TLO.Me.Y()
  local startZ = mq.TLO.Me.Z()

  if not merchant.FindMerchant() then
    logger.Debug("Unable to find any merchants nearby")
    return
  end

  local target = mq.TLO.Target
  if not target() then
    return
  end

  local merchantName= target.CleanName()

  if not moveUtils.MoveToLoc(target.X(), target.Y(), target.Z(), 20, 12) then
    logger.Debug("Unable to reach merchant <%s>", merchantName)
    return
  end

  if merchant.OpenMerchant(target --[[@as target]]) then
    -- mq.cmd("/keypress OPEN_INV_BAGS")

    local maxInventory = 23 + mq.TLO.Me.NumBagSlots() - 1
    for i=23,maxInventory,1 do
      local inventoryItem = mq.TLO.Me.Inventory(i)
      if inventoryItem() then
        if inventoryItem.Container() > 0 then
          for p=1,inventoryItem.Container() do
            sellItem(inventoryItem.Item(p))
          end
        else
          sellItem(inventoryItem --[[@as item]])
        end
      end
    end

    merchant.CloseMerchant(target --[[@as target]])
    -- mq.cmd("/keypress CLOSE_INV_BAGS")
  end

  moveUtils.MoveToLoc(startX, startY, startZ, 20, 12)
  logger.Info("Completed selling items to [%s].", merchantName)
end

local function markItemForSelling()
  local cursor = mq.TLO.Cursor
  if not cursor() then
    logger.Debug("No item to mark for selling on cursor")
    return
  end

  local itemId = cursor.ID()
  local shouldSell, sellItem = canSellItem(itemId, cursor.Name())
  if shouldSell then
    logger.Debug("Item already marked for selling")
  end

  sellItem.DoSell = true
  repository:upsert(sellItem)
  logger.Debug("Marked <%d:%s> for destroying", sellItem.Id, sellItem.Name)
end

local function createAliases()
  mq.unbind('/setsellitem')
  mq.unbind('/sellitems')
  mq.bind("/setsellitem", markItemForSelling)
  mq.bind("/sellitems", function() state = looterStates.Selling end)
end

createAliases()

local function doSell()
  if state == looterStates.Idle then
    return
  end

  if state == looterStates.Selling then
    local isBardSwapping = plugins.IsLoaded("MQ2BardSwap") and mq.TLO.BardSwap()
    if isBardSwapping then
      mq.cmd("/bardswap")
    end
    sellItems()
    state = looterStates.Idle
    if isBardSwapping then
      mq.cmd("/bardswap")
    end
  end
end

return doSell