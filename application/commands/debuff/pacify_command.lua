local mq = require('mq')
local logger = require('knightlinc/Write')
local mqUtils = require('utils/mqhelpers')
local commandQueue  = require('application/command_queue')
local spell_finder = require('application/casting/spell_finder')
local settings = require('settings/settings')
local debuff = require('core/casting/debuffs/debuffspell')
local binder = require('application/binder')

local function execute(targetId)
  local pacifySpell = spell_finder.FindGroupSpell("enc_pacify")
  if not pacifySpell then
    logger.Info("No pacify spell found.")
    return
  end

  local spell = debuff:new(pacifySpell.Name(), settings:GetDefaultGem("enc_pacify"), 10, 3, 3)
  if mqUtils.EnsureTarget(targetId) and spell:CanCastOnTarget(mq.TLO.Target --[[@as target]]) then
    spell:Cast()
  end
end

local function createCommand(targetId)
  if mq.TLO.Me.Class.ShortName() ~= "ENC" then
    return
  end

  commandQueue.Enqueue(function() execute(targetId) end)
end

binder.Bind("/pacify", createCommand, "Tells the enchanter to passify the given target", 'target_id')
