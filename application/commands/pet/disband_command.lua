local mq = require("mq")
local logger = require("knightlinc/Write")
local broadcast = require 'broadcast/broadcast'
local commandQueue  = require("application/command_queue")

local function execute()
  if mq.TLO.Me.Pet() ~= "NO PET" then
    mq.cmd("/pet get lost")
  end
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

mq.bind("/disbandpet", createCommand)

return execute
