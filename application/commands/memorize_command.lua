local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local commandQueue  = require('application/command_queue')
local spell_finder = require('application/casting/spell_finder')
local settings = require('settings/settings')
local binder = require('application/binder')

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
          logger.Info("Memorizing \ag%s\ax in gem %d", spell.RankName.Name(), gem)
          mq.cmdf('/memspell %d "%s"', gem, spell.RankName.Name())
          mq.delay("10s", function() return mq.TLO.Me.Gem(spell.RankName.Name())() ~= nil end)
          mq.delay(500)
        end
      end
  end

  broadcast.InfoAll("Memorized spells")
end

local function createCommand()
  commandQueue.Enqueue(function() execute() end)
end

binder.Bind("/memspells", createCommand, "Tells bot to memorize spells according to the default 'gem' setting")

return execute
-- /notify CastSpellWnd CSPW_Spell0 rightmousedown
-- /lua parse mq.TLO.Window("BuffWindow").Child("Buff1")
-- /lua parse mq.TLO.Window("CastSpellWnd").Child("CSPW_Spell0").RightMouseUp()