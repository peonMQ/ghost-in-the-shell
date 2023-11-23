local mq = require("mq")
local logger = require("knightlinc/Write")
local broadcast = require 'broadcast/broadcast'
local commandQueue  = require("application/command_queue")
local config = require 'modules/pet/config'

local function execute()
  local me = mq.TLO.Me
  if me.Pet() ~= "NO PET" then
    mq.cmd("/pet back off")
  end

  config.CurrentPetTarget = 0
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

mq.bind("/resetpet", createCommand)

return execute
