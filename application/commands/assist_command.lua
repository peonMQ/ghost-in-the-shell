local mq = require('mq')
local logger = require('knightlinc/Write')
local commandQueue  = require('application/command_queue')
local assist = require('core/assist')
local assist_state = require('application/assist_state')
local binder = require('application/binder')

---@param spawnId integer
local function execute(spawnId)
  local targetSpawn = mq.TLO.Spawn(spawnId) --[[@as spawn]]
  if targetSpawn() and assist.IsValidKillTarget(targetSpawn) then
    assist_state.current_target_id = spawnId
    if mq.TLO.Pet() then
      assist_state.current_pet_target_id = spawnId
    end
  end
end

local function createCommand(spawn_id)
  local spawnId = tonumber(spawn_id)
  if not spawnId then
    return
  end

  commandQueue.Enqueue(function() execute(spawnId) end)
end

binder.Bind("/killit", createCommand, "Tells bot to set 'target_id' as his/her current kill target")

return execute