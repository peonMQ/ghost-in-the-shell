local mq = require('mq')
local mq_utils = require('mq/Utils')
local lua_utils = require('utils/debug')
local logger = require('knightlinc/Write')

local next = next

---@generic T
---@param original T
---@return T
local function clone(original)
  local orig_type = type(original)
  if orig_type == 'table' then
    local copy = {}
    for orig_key, orig_value in pairs(original) do
      if type(orig_value) == "table" then
        if getmetatable(orig_value) == nil then
          copy[orig_key] = clone(orig_value)
        else
          copy[orig_key] = orig_value
        end
      else
        copy[orig_key] = orig_value
      end
    end

    return copy
  end

  return original
end

---@generic T : table
---@param loaded T
---@param default T
---@return T
local function leftJoin(loaded, default, notMergeTableKeys)
  local config = clone(default)
  for key, value in pairs(loaded) do
    local defaultValue = default[key]
    if defaultValue and type(defaultValue) == "table" and type(value) == "table" then
      if notMergeTableKeys[key] then
        config[key] = value
      elseif not tonumber(key) and next(defaultValue) then
        config[key] = leftJoin(value, defaultValue, notMergeTableKeys)
      else
        config[key] = value
      end
    elseif type(value) == type(defaultValue) then
      config[key] = value
    elseif not defaultValue then
      config[key] = value
    end
  end

  return config
end

local function loadFile(file_name)
  local file = loadfile(file_name)
  if file then
      return file()
  end

  return nil
end

---@generic T : table
---@param default_settings T
---@param server_settings_filename string
---@param class_settings_filename string
---@param bot_settings_filename string
---@return T
local function loadSettings(default_settings, server_settings_filename, class_settings_filename, bot_settings_filename)
  local notMergeTableKeys = { mt_heal = 1, mt_emergency_heal = 1, default = 1, ae_group = 1}
  local settings = clone(default_settings)
  local server_settings = loadFile(server_settings_filename) or {}
  logger.Debug("server_settings\n %s", lua_utils.ToString(server_settings))

  local class_settings = loadFile(class_settings_filename) or {}
  logger.Debug("class_settings\n %s", lua_utils.ToString(class_settings))

  local bot_settings = loadFile(bot_settings_filename) or {}
  logger.Debug("bot_settings\n %s", lua_utils.ToString(bot_settings))

  local new_settings = leftJoin(bot_settings, leftJoin(class_settings, leftJoin(server_settings, settings, notMergeTableKeys), notMergeTableKeys), notMergeTableKeys)
  return new_settings
end

return {
  Clone = clone,
  LoadSettings = loadSettings
}
