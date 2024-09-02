local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local mqUtils = require('utils/mqhelpers')
local movement = require('core/movement')
local spell = require('core/casting/spell')
local spell_finder = require('application/casting/spell_finder')
local timer = require('core/timer')
local commandQueue  = require('application/command_queue')
local settings = require('settings/settings')
local binder = require('application/binder')

local function execute(petId)
  if not petId or not mq.TLO.Spawn("pcpet id "..petId).ID() then
    return
  end

  local mq_spell = spell_finder.FindGroupSpell("mag_pet_weapon");
  if not mq_spell then
    return
  end

  local pet_weapon_spell = spell:new(mq_spell.Name(), settings.gems.mag_pet_weapon or settings.gems.default, 15)
  if not pet_weapon_spell:CanCast() then
    return
  end

  if not mq.TLO.Spawn("pcpet radius 100 id "..petId).LineOfSight() then
    logger.Debug("Pet outside range or line of sight: <Spawn('pcpet radius 100 id %d)>", petId)
    return
  end

  mqUtils.ClearCursor()
  if not mqUtils.EnsureTarget(petId) then
    return
  end

  local startX = mq.TLO.Me.X()
  local startY = mq.TLO.Me.Y()
  local startZ = mq.TLO.Me.Z()

  for i=1,2 do
    if not mq.TLO.Me.SpellReady(pet_weapon_spell.Name)() then
      local refreshTimer = mq.TLO.Spell(pet_weapon_spell.Name).RecastTime() + 150
      mq.delay(refreshTimer)
    end

    pet_weapon_spell:Cast()
    mq.delay(500)

    if not mqUtils.EnsureTarget(petId) then
      return
    end

    local target = mq.TLO.Target
    if target.Distance() > 100 or target.DistanceZ() > 80 then
      logger.Debug("Pet out of range.")
      return
    end

    movement.MoveToLoc(target.X(), target.Y(), target.Z(), 20, 12)

    local retryTimer = timer:new(2000)
    while not mq.TLO.Window("GiveWnd").Open() and retryTimer:IsRunning() do
      mq.cmd("/click left target")
      mq.delay(500)
    end

    if mq.TLO.Window("GiveWnd").Open() then
      mq.cmd("/notify GiveWnd GVW_Give_Button LeftMouseUp")
      mq.delay("5s", function() return not mq.TLO.Window("GiveWnd").Open() end)
    end

    if mq.TLO.Cursor.ID() then
      logger.Debug("Could not hand <%s> to <%s> <%d>", mq.TLO.Cursor(), mq.TLO.Target(), petId)
      mq.cmd("/beep")
      mqUtils.ClearCursor()
    end

  end

  movement.MoveToLoc(startX, startY, startZ, 20, 12)
  logger.Debug("Command <weaponize_command> completed.")
end

local function createCommand(petId)
    commandQueue.Enqueue(function() execute(petId or mq.TLO.Me.Pet.ID()) end)
end

binder.Bind("/weaponizepet", createCommand, "Tells bot to weaponize the 'pet_id'", 'pet_id')

return execute
