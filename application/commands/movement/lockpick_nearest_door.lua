local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local broadCastInterfaceFactory = require("broadcast/broadcastinterface")
local plugins = require('utils/plugins')
local commandQueue  = require('application/command_queue')
local binder = require('application/binder')
local assist = require('core/assist')
local movement = require('core/movement')
local settings = require('settings/settings')

local bci = broadCastInterfaceFactory('ACTOR')

local lockpicks = "Lockpicks" -- 13010
local mechanizedLockpicks= "Mechanized Lockpicks" --16865

local function execute()
    logger.Info('Start [DoLockPick]')

    local lockpickItem = mq.TLO.FindItem("="..mechanizedLockpicks)
    if not lockpickItem() then
        lockpickItem = mq.TLO.FindItem("="..lockpicks)
    end

    if not lockpickItem() then
        broadcast.WarnAll('|- No Lockpicks set found.')
        logger.Info('End [DoLockPick]')
        return
    end

    if mq.TLO.Me.Skill('Pick Lock')() == nil then
        logger.WarnAll('|- You do not have the skill: Pick Lock')
        logger.Info('End [DoLockPick]')
        return
    end

    local maxMoveTime = 5
    -- Target the nearest door
    mq.cmd('/doortarget')
    if mq.TLO.DoorTarget.Distance() > 20 and not movement.MoveToLoc(mq.TLO.DoorTarget.Y(), mq.TLO.DoorTarget.X(), maxMoveTime, 15) then
        logger.Error("|- I could not moveto < 20 units of %s within %ss", mq.TLO.DoorTarget.Name(), maxMoveTime)
        mq.cmd("/beep")
        logger.Info('End [DoLockPick]')
        return
    end

    if (mq.TLO.DoorTarget.Distance() > 35) then
        logger.Error("|- I could not moveto < 20 units of %s within %ss", mq.TLO.DoorTarget.Name(), maxMoveTime)
        mq.cmd("/beep")
        logger.Info('End [DoLockPick]')
        return
    end

    local packslot = lockpickItem.ItemSlot() - 22
    local inpackslot = lockpickItem.ItemSlot2();
    if(inpackslot >= 0) then
      mq.cmdf("/nomodkey /itemnotify in pack%d %d leftmouseup", packslot, inpackslot + 1)
    else
      mq.cmdf("/nomodkey /itemnotify pack%d leftmouseup", packslot)
    end

    mq.delay(2000, function() return mq.TLO.Cursor() == lockpickItem.Name() end)
    if mq.TLO.Cursor() ~= lockpickItem.Name() then
        logger.Error('|- Could not pick up <%s> on cursor.', lockpickItem.Name())
        mq.cmd("/beep")
    end

    mq.cmd("/click left door")
    if(inpackslot >= 0) then
      mq.cmdf("/nomodkey /itemnotify in pack%d %d leftmouseup", packslot, inpackslot + 1)
    else
      mq.cmdf("/nomodkey /itemnotify pack%d leftmouseup", packslot)
    end

    mq.delay(2000, function() return not mq.TLO.Cursor() end)
    if mq.TLO.Cursor() then
        logger.Fatal('|- Unable to clear cursor for <%s>.', lockpickItem.Name())
    end
    logger.Info('End [DoLockPick]')
end

local function createCommand()
    if settings.isLockpicker then
      commandQueue.Enqueue(function() execute() end)
    end
end

binder.Bind("/lockpick", createCommand, 'Tells the bot to lockpick the nearest door if its within range of it and is able to.')