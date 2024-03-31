local mq = require("mq")
local logger = require("knightlinc/Write")
local broadcast = require 'broadcast/broadcast'
local commandQueue  = require("application/command_queue")
local spell_finder = require 'lib/spells/spell_finder'
local settings = require 'settings/settings'
local broadCastInterfaceFactory = require('broadcast/broadcastinterface')()

local function execute()
  if settings.gems == nil then
    return
  end

  local t = mq.TLO.Me.NumGems()
  for i = 1, mq.TLO.Me.NumGems(), 1 do
    if  mq.TLO.Me.Gem(i)() then
      logger.Info("Clearing %s in gem %d", mq.TLO.Me.Gem(i)(), i)
      mq.TLO.Window("CastSpellWnd/CSPW_Spell"..(i-1)).RightMouseUp()
      mq.delay(1000, function() return not mq.TLO.Me.Gem(i)() end)
    end
  end

  for spell_group, gem in pairs(settings.gems) do
      if not mq.TLO.Me.Gem(gem)() then
        local spell = spell_finder.FindGroupSpell(spell_group)
        if spell and spell() then
          logger.Info("Memorizing \ag%s\ax in gem %d", spell.RankName(), gem)
          mq.cmdf('/memspell  %d "%s"', gem, spell.RankName())
          mq.delay("10s", function() return mq.TLO.Me.Gem(spell.RankName.Name())() ~= nil end)
          mq.delay(500)
          local waitForReady = spell.RecoveryTime()
          mq.delay(waitForReady)
        end
      end
  end

  broadcast.InfoAll("Memorized spells")
end

local function createCommand()
  commandQueue.Enqueue(function() execute() end)
end

mq.bind("/memspells", createCommand)

return execute
-- /notify CastSpellWnd CSPW_Spell0 rightmousedown
-- /lua parse mq.TLO.Window("BuffWindow").Child("Buff1")
-- /lua parse mq.TLO.Window("CastSpellWnd").Child("CSPW_Spell0").RightMouseUp()