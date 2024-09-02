local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local commandQueue  = require('application/command_queue')
local repository = require('application/looting/repository')
local item = require('core/lootitem')
local binder = require('application/binder')

local function execute(force)
  local cursor = mq.TLO.Cursor
  if not cursor() then
    logger.Debug("No item to mark for destroying on cursor")
    return
  end

  if cursor.NoDrop() and force ~= "force" then
    broadcast.ErrorAll("Can't mark NO-DROP item for destroy. use '/setdestroyitem force' to force marking this item for deleting")
    mq.cmd("/beep")
    return
  end

  local itemId = cursor.ID()
  local destroyItem =  repository:tryGet(itemId)
  if not destroyItem then
    destroyItem = item:new(itemId, cursor.Name())
  end

  if destroyItem.DoDestroy then
    logger.Debug("Item already marked for destroying")
  else
    destroyItem.DoDestroy = true
    repository:upsert(destroyItem)
    logger.Info("Marked <%d:%s> for destroying", destroyItem.Id, destroyItem.Name)
    broadcast.SuccessAll("Marked <%d:%s> for destroying", destroyItem.Id, destroyItem.Name)
  end

  logger.Info("Mark item for destroying command completed.")
end

local function createCommand(force)
    commandQueue.Enqueue(function() execute(force) end)
end

binder.Bind("/setdestroyitem", createCommand, "Marks item on cursors as 'destroyable'")
