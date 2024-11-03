--- Converts the given string to a boolean, defaults to false (true|on|1 are true)
---@param string_arg string
---@return boolean
local function string_to_bool(string_arg)
  if string_arg == nil then
      return false
  end

  if string.lower(string_arg) == 'true' then
    return true
  end

  if string.lower(string_arg) == "on" then
    return true
  end

  local number_arg = tonumber(string_arg)
  if number_arg then
    return number_arg == 1
  end

  return false
end

return {
  ConvertToBoolean = string_to_bool
}