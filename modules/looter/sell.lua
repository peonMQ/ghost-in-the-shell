--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local moveUtils = require('lib/moveutils')
local timer = require('lib/timer')
local merchant = require('modules/looter/merchant')
--- @type LootItem
local item = require('modules/looter/types/lootitem')
---@type LooterStates
local looterStates = require('modules/looter/types/looterState')
--- @type Repository
local repository = require('modules/looter/repository')

local state = looterStates.Idle

---@param itemId integer
---@param itemName string
---@return boolean, LootItem
local function canSellItem(itemId, itemName)
  local _, itemToSell = repository:tryGet(itemId)
  return item.DoSell, itemToSell or item:new(itemId, itemName)
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

  local packslot = itemToSell.ItemSlot - 22
  while merchantWindow.Child("MW_SelectedItemLabel").Text() ~= itemToSell.Name() do
    if(itemToSell.ItemSlot2 >= 0) then
      mq.cmdf("/itemnotify in pack%d %d leftmouseup", packslot, itemToSell.ItemSlot2+1)
    else
      mq.cmdf("/itemnotify in pack%d leftmouseup", packslot)
    end

    if(retryTimer:IsComplete()) then
      logger.Error("Failed to select [%s], skipping.", itemToSell.Name())
      return
    end
  end

  local quantityWindow = mq.TLO.Window("QuantityWnd")
  mq.cmd("/notify MerchantWnd MW_Sell_Button leftmouseup")
  mq.delay(30, function() return quantityWindow() and merchantWindow.Open() end)
  if(quantityWindow() and quantityWindow.Open()) then
    mq.cmd("/notify QuantityWnd QTYW_Accept_Button leftmouseup")
    mq.delay(30, function() return not quantityWindow() or not quantityWindow.Open() end)
  end 

  if(itemToSell.ItemSlot2 >= 0 and mq.TLO.Me.Inventory("pack"..packslot).Item(itemToSell.ItemSlot).Item())
    or mq.TLO.Me.Inventory("pack"..packslot).Item() then
    logger.Error("Failed to sell [%s], skipping.", itemToSell.Name())
  end
end

local function sellItems()
  local startX = mq.TLO.Me.X()
  local startY = mq.TLO.Me.Y()

  if not merchant.FindMerchant() then
    logger.Debug("Unable to find any merchants nearby")
    return
  end

  local target = mq.TLO.Target
  if not target() then
    return
  end

  if not moveUtils.MoveToLoc(target.X(), target.Y(), 20, 12) then
    logger.Debug("Unable to reach merchant <%s>", target.Name())
    return
  end

  if merchant.OpenMerchant(target --[[@as target]]) then
    -- mq.cmd("/keypress OPEN_INV_BAGS")
    
    for i=23,30,1 do
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

  moveUtils.MoveToLoc(startX, startY, 20, 12)
  state = looterStates.Idle
  logger.Info("Completed selling items to [%s].", target.CleanName())
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

  if state == looterStates.Looting then
    sellItems()
  end
end

return doSell