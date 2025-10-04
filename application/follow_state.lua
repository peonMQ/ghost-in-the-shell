local mq = require('mq')
local plugins = require('utils/plugins')
local loader = require('settings/loader')

---@alias FollowMode 'nav'|'actor'|'advpath'|'moveutils'

---@class FollowStateData
---@field mode FollowMode|nil what kind of follow mode are we in
---@field spawn_id number|nil

---@class FollowState : FollowStateData
---@field Reset fun(self: FollowStateData) reset state to default state
---@field IsActive fun(self: FollowStateData, mode: FollowMode|nil): boolean
---@field Activate fun(self: FollowStateData, mode: FollowMode, spawnId: number)
---@field Stop fun(self: FollowStateData)

---@class FollowStateData
local defaultState = {
  mode = nil,
  spawn_id = nil
}

local state = loader.Clone(defaultState) --[[@as FollowState]]
state.Reset = function(self)
  self.mode = nil
  self.spawn_id = nil
end

state.IsActive = function (self, mode)
  if not self.spawn_id then
    return false
  end

  return not mode or self.mode == mode;
end

state.Activate = function (self, mode, spawnId)
  state:Stop()
  self.mode = mode
  self.spawn_id = spawnId
end

state.Stop = function(self)
  if mq.TLO.Navigation.Active() then
    mq.cmd("/nav stop")
    mq.delay(1)
  end

  if plugins.IsLoaded("mqactorfollow") and mq.TLO.ActorFollow.IsFollowing() then
    mq.cmd("/actfollow off")
    mq.delay(1)
  end

  if plugins.IsLoaded("mq2advpath") and mq.TLO.AdvPath.Active() then
    mq.cmd("/afollow off")
    mq.delay(1)
  end

  if plugins.IsLoaded("mq2moveutils") and mq.TLO.MoveUtils.Command() ~= "NONE" then
    mq.cmd("/stick off")
    mq.cmd("/moveto off")
    mq.delay(1)
  end

  self:Reset()
end

return state