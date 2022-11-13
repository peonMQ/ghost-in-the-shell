--- @type Mq
local mq = require('mq')
local logger = require('lib/util/logging')

local function DoSummon (itemName)
  mq.cmdf('/itemnotify "%s" rightmouseup', itemName)
  mq.delay("3s", function() return mq.TLO.Cursor.ID() and mq.TLO.Cursor.ID() > 0 end)
  if mq.TLO.Cursor.ID() then
    mq.cmd('/autoinventory')
  end
  logger.Debug("Done sommon with cursor <%s>", mq.TLO.Cursor.ID())
end

local function SummonFood (foodSpell, foodItem, maxFoodCount)
  logger.Info('Start [SummonFood] ==> %s of %s.', maxFoodCount, foodItem)

  if mq.TLO.FindItemCount('='..foodSpell)() < 1 then
    logger.Fatal('Missing item/spell <%s>', foodSpell)
  end

  while mq.TLO.FindItemCount('='..foodItem)() < maxFoodCount do
    while mq.TLO.Cursor.ID() do
      mq.cmd('/autoinventory')
    end

    if mq.TLO.FindItem('='..foodSpell).TimerReady() == 0 then
      logger.Info('Summoning: %s =>  %s/%s', foodItem, mq.TLO.FindItemCount('='..foodItem)()+1, maxFoodCount)
      DoSummon(foodSpell)
      mq.delay(mq.TLO.FindItem('='..foodSpell).TimerReady() + 500)
    end
  end

  mq.cmd('/beep .\\sounds\\mail1.wav')
  logger.Info("End [SummonFood]")
end

local function Main()
  local foodSpell  = "Endless Turkeys"
  local foodItem  = "Cooked Turkey"
  local maxFoodCount  = 5

  SummonFood(foodSpell, foodItem, maxFoodCount)
end

Main()