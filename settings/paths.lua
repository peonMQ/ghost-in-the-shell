local mq = require('mq')
local luapaths = require('utils/lua-paths')

-- Script folder name relative to the MQ lua dir (RunningDir must be created at module top level)
local currentScript = luapaths.RunningDir:new():Parent():GetRelativeToMQLuaPath("")
local server_shortname = mq.TLO.MacroQuest.Server()

-- <config>/<script folder>/<server>
local serverConfigPath = string.format("%s/%s/%s", mq.configDir, currentScript, server_shortname)
-- <config>/<script folder>/<server>/data
local dataDir = string.format("%s/data", serverConfigPath)

---@param filename string
---@return string # <config>/<script folder>/<server>/data/<filename>
local function getDataDirFile(filename)
  return string.format("%s/%s", dataDir, filename)
end

return {
  ServerConfigPath = serverConfigPath,
  DataDir = dataDir,
  GetDataDirFile = getDataDirFile,
}
