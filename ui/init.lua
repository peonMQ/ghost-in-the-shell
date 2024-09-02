local mq = require('mq')
local imgui = require('ImGui')
local settings = require('ui/settings')
local states = require('ui/states')
local loot = require('ui/loot')
local binder = require('application/binder')

local function PushStyleCompact()
  local style = imgui.GetStyle()
  imgui.PushStyleVar(ImGuiStyleVar.WindowPadding, 0, 0)
end

local function PopStyleCompact()
  imgui.PopStyleVar(1)
end

-- GUI Control variables
local eq_path = mq.TLO.EverQuest.Path():gsub('.*%\\', '') -- https://stackoverflow.com/questions/74408159/lua-help-to-get-an-end-of-string-after-last-special-character
local openGUI = true
local shouldDrawGUI = true
local windowFlags = bit32.bor(ImGuiWindowFlags.NoDocking, ImGuiWindowFlags.NoFocusOnAppearing)
---@type ConsoleWidget|nil
local console = nil

---@param doDraw boolean
local function shouldDrawUI(doDraw)
  openGUI = doDraw
end

---@param consoleWidget ConsoleWidget
local function init(consoleWidget)
  console = consoleWidget
  -- ImGui main function for rendering the UI window
  local renderUI = function()
    if not openGUI then return end
    ImGui.SetNextWindowSize(460, 300, ImGuiCond.FirstUseEver)
    PushStyleCompact()
    openGUI, shouldDrawGUI = imgui.Begin(('Ghost in the shell###gitsui_%s'):format(eq_path), openGUI, windowFlags) -- https://discord.com/channels/511690098136580097/866047684242309140/1268289663546949773
    PopStyleCompact()
    if shouldDrawGUI then
      if imgui.BeginTabBar("GITSTabs", ImGuiTabBarFlags.None) then
        imgui.SetItemDefaultFocus()
        if console and imgui.BeginTabItem("Console") then
          local contentSizeX, contentSizeY = imgui.GetContentRegionAvail()
          console:Render(ImVec2(contentSizeX, contentSizeY))
          imgui.EndTabItem()
        end
        if imgui.BeginTabItem("Settings") then
          settings()
          imgui.EndTabItem()
        end
        if imgui.BeginTabItem("States") then
          states()
          imgui.EndTabItem()
        end
        if imgui.BeginTabItem("Loot") then
          loot()
          imgui.EndTabItem()
        end

        imgui.EndTabBar();
      end
    end
    imgui.End()
  end
  mq.imgui.init('gitsui', renderUI)
end

binder.Bind("/gitsui", function() shouldDrawUI(true) end, "Show the Ghost in the Shell console window")

return { Init = init }