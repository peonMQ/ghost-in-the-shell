--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')

--  https://www.mmobugs.com/forums/index.php?threads/turnin-macro.15376/
--  https://www.mmobugs.com/forums/index.php?threads/simplify-quest-turn-in.34738/
--  https://www.mmobugs.com/forums/index.php?threads/hand-in-macro-help-request.32770/

local me = mq.TLO.Me
local doReportXP = true
local xp= me.PctExp()
local aaXP = me.PctAAExp()
local leaderXP = 0
local handinCount = 0
local minItemsPerHandin = 1
local maxItemsPerHandin = 4
local turninItem = "Muffin"
local handinNPC = "Pandos Flintside"

local function xpGainedEvent(line)
   -- Experience calculation and reporting
   if(doReportXP) then
      logger.Info(">> XP-Delta: REG (%s%), AA (%s%), LDR (%s%)", me.PctExp() - xp, me.PctAAExp() - aaXP, 0 - leaderXP)
   end

   aaXP = me.PctAAExp()
   xp = me.PctExp()
   handinCount = handinCount + 1

   local runTimeMinutes = mq.TLO.Macro.RunTime() / 60
   local runTimeSeconds = (mq.TLO.Macro.RunTime() - runTimeMinutes) * 60

   logger.Info("%s Handins - %s min : %s sec", handinCount, runTimeMinutes, runTimeSeconds)
end

mq.event('xpgained', 'You gain#*#experience#*#', xpGainedEvent)

mq.cmdf("/mqtarget npc %s", handinNPC)

while mq.TLO.FindItemCount('='..turninItem)() > minItemsPerHandin do
   if mq.TLO.FindItemCount('='..turninItem)() < maxItemsPerHandin then
    maxItemsPerHandin = mq.TLO.FindItemCount('='..turninItem)()
   end

   for i=1,maxItemsPerHandin do
      local item = mq.TLO.FindItem('='..turninItem)
      mq.cmdf('/ctrl /itemnotify in pack%s %s leftmouseup', item.ItemSlot()-22, item.ItemSlot2() + 1)
      mq.delay(50, function() return mq.TLO.Cursor.ID() and mq.TLO.Cursor.ID() > 0 end)

      if(i == 1) then
         mq.cmd('/click left target')
         mq.delay('1s', function() return mq.TLO.Window("GiveWnd").Open() or false end)
      else
         mq.cmdf('/notify GiveWnd GVW_MyItemSlot%s leftmouseup', i-1)
         mq.delay('1s', function() return not mq.TLO.Cursor.ID() end)
      end
   end

   mq.cmd('/notify GiveWnd GVW_Give_Button leftmouseup')
   mq.delay(20, function() return mq.TLO.Window("GiveWnd").Open() ~= true end)
   mq.doevents()
   mq.exit()
end

logger.Info("Ran out of %s", turninItem)
