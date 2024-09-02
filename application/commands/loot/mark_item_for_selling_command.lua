local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local commandQueue  = require('application/command_queue')
local repository = require('application/looting/repository')
local item = require('core/lootitem')
local binder = require('application/binder')

local function execute()
  local cursor = mq.TLO.Cursor
  if not cursor() then
    logger.Debug("No item to mark for selling on cursor")
    return
  end

  local itemId = cursor.ID()
  local sellItem = repository:tryGet(itemId)
  if not sellItem then
    sellItem = item:new(itemId, cursor.Name())
  end

  if sellItem.DoSell then
    logger.Debug("Item already marked for selling")
  else
    sellItem.DoSell = true
    repository:upsert(sellItem)
    logger.Info("Marked <%d:%s> for selling.", sellItem.Id, sellItem.Name)
    broadcast.SuccessAll("Marked <%d:%s> for selling.", sellItem.Id, sellItem.Name)
  end

  logger.Info("Mark item for selling command completed.")
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

binder.Bind("/setsellitem", createCommand, "Marks item on cursors as 'sellable'")
