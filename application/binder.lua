local mq = require('mq')

local function pairsByKeys (t, f)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, f)
  local i = 0      -- iterator variable
  local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
  end
  return iter
end


---@type table<string, {Text: string, Args: string|nil}>
local help = {}

---@param command string # The command including the slash.  '/healme'
---@param callback function # The Lua function to call when the command is entered in-game
---@param helpText string
---@param commandargs string|nil
local function bind(command, callback, helpText, commandargs)
  assert(command, "command cannot be nil")
  assert(callback, "callback cannot be nil")
  assert(helpText, "helpText cannot be nil")
  help[command] = { Text = helpText, Args = commandargs }
  mq.bind(command, callback)
end

local function generateHelpText()
  print("Ghost in the shell commands")
  for command, helptext in pairsByKeys(help) do
    if helptext.Args then
      local commandtext = string.format("\at[GITS]\ax \ay%s\ax \am%s\ax \a-t-- %s\ax", command, helptext.Args, helptext.Text)
      print(commandtext)
    else
      local commandtext = string.format("\at[GITS]\ax \ay%s\ax \a-t-- %s\ax", command, helptext.Text)
      print(commandtext)
    end
  end
end

mq.bind("/gits", generateHelpText)

return {
  Bind = bind,
}