--- @type Mq
local mq = require('mq')
local doBuffs = require('modules/buffer/buffer')
local doLoot = require('modules/looter/loot')
local doSell = require('modules/looter/sell')
local doMeleeDps = require('modules/melee/melee')
local wait4rez = require('wait4rez/wait4rez')

require('lib/common/cleanBuffs')

-- local function doRogueStrike()
--   local me = mq.TLO.Me
--   local target = mq.TLO.Target
-- 	 if (${Me.Endurance} > ${strikeDiscEndCost} && ${Me.PctEndurance} >= ${strikeDiscMinEnd} && ${Me.CombatAbilityReady[${strikeDisc}]} && ${Me.AbilityReady[Backstab]} && !${Me.ActiveDisc.ID} && ${Me.Invis} && ${Me.Sneaking}) {
-- 		| Use 'Assassin's Strike' type disc.
-- 		/delay 1
-- 		/disc ${strikeDisc}
-- 		/delay 5 ${Bool[${Me.ActiveDisc.ID}]}
-- 		/delay 3
-- 		/doability Backstab
-- 		/delay 1
-- 		/attack on
-- 	}
-- end

local function doBackStab()
  local me = mq.TLO.Me
  local target = mq.TLO.Target
  if me.Heading.Degrees() - target.Heading.Degrees() < 45 then
    -- doRogueStrike()
    if me.AbilityReady("Backstab")() then
      mq.cmd("/doability Backstab")
    end
  end
end

while true do
  doBuffs()
  doLoot()
  doSell()
  doMeleeDps(doBackStab)
  wait4rez()
  mq.doevents()
  mq.delay(100)
end