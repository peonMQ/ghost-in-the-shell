local logger = require('utils/logging')

local state =  {
  isBusy = false
}

function state.Free()
  state.isBusy = false
end

function state.Busy()
  state.isBusy = true
end


return state