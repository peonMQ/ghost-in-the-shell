local logger = require('knightlinc/Write')
local lua_utils = require('utils/debug')
local settings = require('settings/settings')

logger.Trace("settings\n %s", lua_utils.ToString(settings))