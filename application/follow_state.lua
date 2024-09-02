local mq = require('mq')
local plugins = require('utils/plugins')
local loader = require('settings/loader')

---@alias FollowMode 'nav'|'actor'|'advpath'|'moveutils'

---@class FollowStateData
---@field mode FollowMode what kind of follow mode are we in
---@field spawn_id number|nil

---@class FollowState : FollowStateData
---@field Reset fun(self: FollowStateData, property?: string) reset state to default state
---@field IsActive fun(self: FollowStateData, mode: FollowMode|nil): boolean
---@field Activate fun(self: FollowStateData, mode: FollowMode, spawnId: number)
---@field Stop fun()

---@class FollowStateData
local defaultState = {
  mode = 'nav',
  spawn_id = nil
}

local state = loader.Clone(defaultState) --[[@as FollowState]]
state.Reset = function(self, property)
  for key, value in pairs(defaultState) do
    if not property or key == property then
      self[key] = value
    end
  end

  if not property or "spawn_id" == property then
    self.spawn_id = nil
  end
end

state.IsActive = function (self, mode)
  if not self.spawn_id then
    return false
  end

  return not mode or self.mode == mode;
end

state.Activate = function (self, mode, spawnId)
  self.mode = mode
  self.spawn_id = spawnId
end

state.Stop = function()
  if mq.TLO.Navigation.Active() then
    mq.cmd("/nav stop")
  end

  if plugins.IsLoaded("mqactorfollow") and mq.TLO.ActorFollow.IsFollowing() then
    mq.cmd("/actfollow off")
  end

  if plugins.IsLoaded("mq2advpath") and mq.TLO.AdvPath.Active() then
    mq.cmd("/afollow off")
  end

  if plugins.IsLoaded("mq2moveutils") and mq.TLO.MoveUtils.Command() ~= "NONE" then
    mq.cmd("/stick off")
    mq.cmd("/moveto off")
  end
end

return state