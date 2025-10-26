local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local broadCastInterfaceFactory = require('broadcast/broadcastinterface')
local mqUtils = require('utils/mqhelpers')
local binder = require('application/binder')
local commandQueue  = require('application/command_queue')
local spell_finder = require('application/casting/spell_finder')
local assist = require('core/assist')
local spell = require('core/casting/spell')
local item = require('core/casting/item')
local settings = require('settings/settings')
local bci = broadCastInterfaceFactory('ACTOR')

---@param spawn MQSpawn
local function ressurect(spawn)
  if spawn.Type() ~= "Corpse" then
    broadcast.ErrorAll("Spawn with id <%s> is not a corpse", broadcast.ColorWrap(spawn.ID(), 'Red'))
  elseif not mqUtils.EnsureTarget(spawn.ID()) then
    broadcast.ErrorAll("Unable to target corpse <%s>", broadcast.ColorWrap(spawn.Name(), 'Red'))
  elseif mq.TLO.Target.Distance3D() > 100 then
    broadcast.ErrorAll("Corpse <%s> is out of range %s", broadcast.ColorWrap(spawn.Name(), 'Cyan'), broadcast.ColorWrap(spawn.Distance3D(), 'Red'))
  else
    if mq.TLO.Target.Distance() > 25 then
      mq.cmd("/corpse")
    end

    ---@type Spell|Item|nil
    local rezspell = nil
    if mq.TLO.FindItem("Water Sprinkler of Nem Ankh") then
      rezspell = item:new("Water Sprinkler of Nem Ankh")
      if not rezspell:WaitForReady(10) then
        broadcast.ErrorAll("Water Sprinkler of Nem Ankh timed out to become ready for casting")
        return
      end
    else
      rezspell = spell_finder.MapSpellorItem("clr_rez", {}, function (groupname, name, data) return spell:new(name, settings:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer) end)
    end

    if rezspell then
      rezspell:Cast();
    end
  end
end

local function executeBySpawnId(spawnId)
  logger.Info('REZ for [SpawnId] ==> %s.', spawnId)

  local spawn =mq.TLO.Spawn(spawnId)
  if spawn() then
    ressurect(spawn)
  else
    broadcast.ErrorAll("Could not find spawn for id <%s> for ressurection", broadcast.ColorWrap(spawnId, 'Red'))
  end

  logger.Info("End [REZ]")
end

local function executeForGroup()
  logger.Info('REZ for [Group] ==>')

  for i=1,mq.TLO.Group.Members() do
    local groupMember = mq.TLO.Group.Member(i) --[[@as groupmember]]

    local spawn =mq.TLO.Spawn(string.format("%s's corpse", groupMember.Name()))
    if spawn() and spawn.Type() == "Corpse" then
      ressurect(spawn)
    end
  end

  logger.Info("End [Group]")
end

logger.Info("Creating bind for '/rez' and /rezgroup.")
---@param query number|'group'|'raid'|'all'
local function createCommand(query)
  if mq.TLO.Me.Class.ShortName() == "CLR" then
    local spawnId = tonumber(query)
    if spawnId then
      commandQueue.Enqueue(function() executeBySpawnId(spawnId) end)
    elseif query == 'group' then
      commandQueue.Enqueue(function() executeForGroup() end)
    end
  end
end

local function createGroupCommand()
  if assist.IsOrchestrator() then
    bci.ExecuteZoneWithSelfCommand('/rez group')
  end
end

binder.Bind("/rez", createCommand, "Tells bot to ressurect spawn given id.", 'id')
binder.Bind("/rezgroup", createGroupCommand, "Tells all bots (clerics) to ressurect members in their group if they are able.")

