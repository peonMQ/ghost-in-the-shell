local logger = require('knightlinc/Write')

---@class CommandHandler
---@field Execute fun():nil|thread
---@field CanExecute? fun()

---@type thread[]
local postCommandQueue = {}

---@type CommandHandler[]
local queue = {}

---@param command fun():nil|thread
---@param canExecute? fun()
local function enqueue(command, canExecute)
    table.insert(queue, { Execute = command, CanExecute = canExecute })
end

---@return CommandHandler|nil #Returns the oldest item on the queue
local function deQueue()
    for idx, command in ipairs(queue) do
        if not command.CanExecute or command.CanExecute() then
          table.remove(queue, idx)
          return command
        end
    end

    return nil
end

-- Clears the command queue
local function clear()
    queue = {}
    postCommandQueue = {}
end

-- Resumes post commands in insertion order; they share game state, so order matters.
local function postProcess()
  local alive = {}
  for idx, co in ipairs(postCommandQueue) do
    local ok, err = coroutine.resume(co)
    if not ok then
      logger.Error("Postcommand <%d> failed: %s", idx, debug.traceback(co, err))
    elseif coroutine.status(co) == "dead" then
      logger.Debug("Postcommand <%d> finished", idx)
    else
      table.insert(alive, co)
    end
  end

  -- clear() during a resume (e.g. pause) must win over the rebuilt list
  if #postCommandQueue > 0 then
    postCommandQueue = alive
  end

  return next(postCommandQueue)
end

local function process()
  postProcess()

  local command = deQueue()
  if command == nil then
      return
  end

  local postCommand = command.Execute()
  logger.Debug("Executed command")
  if postCommand then
    logger.Debug("Inserting postcommand to handler")
    table.insert(postCommandQueue, postCommand)
  else
    logger.Debug("postcommand is nil")
  end
end

local function size()
  return  { Queue = #queue; PostQueue = #postCommandQueue }
end

return {
    Clear = clear,
    Enqueue = enqueue,
    Process = process,
    Size = size
}

-- table.remove performance issue
-- https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating


-- Priority queue
-- http://lua-users.org/lists/lua-l/2007-07/msg00482.html