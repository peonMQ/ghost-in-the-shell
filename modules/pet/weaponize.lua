--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local plugin = require('utils/plugins')
local mqUtils = require('utils/mq')
local moveUtils = require('lib/moveutils')
local timer = require('lib/timer')
local petstates = require('modules/pet/types/petstate')
local config = require('modules/pet/config')

local state = petstates.Idle
local weaponizePetId = nil

local function weaponizePet(petId)
  local weaponizeSpell = config.WeaponizeSpell
  if not weaponizeSpell then
    logger.Debug("No weaponize spell defined, unable to weaponize pet.")
    state = petstates.Idle
    weaponizePetId = nil
    return
  end

  if not weaponizeSpell:CanCast() then
    state = petstates.Idle
    weaponizePetId = nil
    return
  end

  if not petId or not mq.TLO.Spawn("pcpet id "..petId).ID() then
    state = petstates.Idle
    weaponizePetId = nil
    return
  end

  if not mq.TLO.Spawn("pcpet radius 100 id "..petId).LineOfSight() then
    logger.Debug("Pet outside range or line of sight: <Spawn('pcpet radius 100 id %d)>", petId)
    state = petstates.Idle
    weaponizePetId = nil
    return
  end

  mqUtils.ClearCursor()

  if not mqUtils.EnsureTarget(petId) then
    state = petstates.Idle
    weaponizePetId = nil
    return
  end

  for i=1,2 do
    if not mq.TLO.Me.SpellReady(weaponizeSpell.Name)() then
      local refreshTimer = mq.TLO.Spell(weaponizeSpell.Name).RecastTime() + 150
      mq.delay(refreshTimer)
    end

    weaponizeSpell:Cast()
    mq.delay(500)

    if not mqUtils.EnsureTarget(petId) then
      state = petstates.Idle
      weaponizePetId = nil
      return
    end

    local target = mq.TLO.Target

    if (target.Distance() > 16 and target.DistanceZ() < 80) then
      moveUtils.MoveToLoc(target.X(), target.Y(), target.Z(), 20, 12)
    end

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

    state = petstates.Idle
    weaponizePetId = nil
  end
end

local function askForWeapons(characterName)
  if not mq.TLO.Me.Pet.ID() then
    return
  end

  if not characterName then
    logger.Debug("Cold not ask for weapons, param <charactername> is nil")
    return
  end

  if plugin.IsLoaded("mq2netbots") and mq.TLO.NetBots(characterName).InZone() then
    mq.cmdf("/bct %s //weaponizepet %d", characterName, mq.TLO.Me.Pet.ID())
  else
    logger.Debug("Cold not ask <%s> for weapons, NetBots not loaded or character not in zone.", characterName)
  end
end

local function doWeaponize()
  if state == petstates.WeaponizePet and weaponizePetId then
    weaponizePet(weaponizePetId)
  end
end

local function createAliases()
  mq.unbind('/weaponizepet')
  mq.unbind('/askforpetweapons')
  mq.bind("/weaponizepet", function(petId) state = petstates.WeaponizePet; weaponizePetId = petId or mq.TLO.Me.Pet.ID() end)
  mq.bind("/askforpetweapons", askForWeapons)
end

createAliases()

return doWeaponize