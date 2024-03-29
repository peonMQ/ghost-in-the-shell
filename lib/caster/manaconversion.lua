
local settings = require 'settings/settings'

local function doManaConversion()
  for _, conversion in pairs(settings.mana.conversions) do
    if conversion:CanCast() then
      conversion:Cast()
    end
  end
end

return doManaConversion