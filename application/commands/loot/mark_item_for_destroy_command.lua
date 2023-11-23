local mq = require("mq")
local logger = require("knightlinc/Write")
local commandQueue  = require("application/command_queue")
local repository = require 'modules/looter/repository'
local item = require 'modules/looter/types/lootitem'

local function execute()
  local cursor = mq.TLO.Cursor
  if not cursor() then
    logger.Debug("No item to mark for destroying on cursor")
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
  end

  logger.Info("Mark item for destroying command completed.")
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

mq.bind("/setdestroyitem", createCommand)
