local flib_gui = require("__flib__.gui")
-- local gui = require("__flib__.gui")
local toolbar = require("gui/toolbar")
local events_table = require("gui/events")
local gui_handlers = {}

---Create Header GuiELemDef for flib
---@param gui_id string
---@return flib.GuiElemDef
local function header(gui_id)
  return {
    type = "flow",
    name = "titlebar",
    children = {
      {type = "label", style = "frame_title", caption = {"spelevator-log.header"}, ignored_by_interaction = true},
      {type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true},
      {
        type = "sprite-button",
        style = "frame_action_button",
        sprite = "utility/close",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        handler = gui_handlers.close_window,
        tags = {
            gui_id = gui_id
        }
      }
    }
  }
end

--- Creates
--- @param player LuaPlayer
local function open_gui(player)
  local gui_id = "gui-" .. player.name

  --- If player hasn't opened GUI, then create a new GUI and put it in storage.guis.
  if not storage.guis[gui_id] then
    --game.print(tostring(game.tick).." creating new gui")
    -- log("Creating new gui for "..gui_id)
    ---@type flib.GuiElemDef[]
    local gui_contents = {
      {
        type = "frame",
        direction = "vertical",
        name = "spelevator-log-window",
        children = {
          header(gui_id),
          toolbar.create_toolbar(gui_id),
          {
            type = "tabbed-pane",
            name = "tabs_pane",
            children = {
              {
                tab = {
                  type = "tab",
                  caption = { "spelevator-log.tab-events" }
                },
                content = {
                  type = "flow",
                  direction = "vertical",
                  name = "events_contents"
                }
              },
              {
                tab = {
                  type = "tab",
                  caption = { "spelevator-log.tab-summary" }
                },
                content = {
                  type = "flow",
                  direction = "vertical",
                  name = "summary_contents"
                }
              }
            }
          },
        }
      }
    }
    ---@type table<string,LuaGuiElement>, LuaGuiElement
    local _,new_gui = flib_gui.add(player.gui.screen, gui_contents)
    log(new_gui.name)
    local filter_guis = {
      time_period = new_gui.toolbar.row1.filter_time_period,
      item = new_gui.toolbar.row2.filter_item,
      surface_list = new_gui.toolbar.row2.filter_surface_list,
    }
    ---@type GuiConfig
    storage.guis[gui_id] = {
      gui_id = gui_id,
      gui = new_gui,
      player = player,
      filter_guis = filter_guis,
      events_contents = new_gui.tabs_pane.events_contents,
      summary_contents = new_gui.tabs_pane.summary_contents
    }
  end

  --- Retrieve existing GUI element from storage.guis 
  --- and re-centers and/or replaces player's current GUI element.
  local spelevator_log_gui = storage.guis[gui_id]
  if player.opened and player.opened ~= spelevator_log_gui.gui then
    --game.print(tostring(game.tick).." closing other gui before opening rocketlog")
    player.opened = nil
  end
  -- toolbar.refresh(gui_id)
  spelevator_log_gui.gui.visible = true
  spelevator_log_gui.gui.titlebar.drag_target = spelevator_log_gui.gui
  spelevator_log_gui.gui.force_auto_center()
  player.opened = spelevator_log_gui.gui
  --game.print(tostring(player.opened))
  --game.print(tostring(game.tick).." showing rocketlog gui")

  toolbar.refresh(spelevator_log_gui.filter_guis)
  events_table.create_events_table(spelevator_log_gui)
end


local function train_log_destroy_gui(gui_id)
    local train_log_gui = storage.guis[gui_id]
    train_log_gui.gui.window.destroy()
    storage.guis[gui_id] = nil
end

local function destroy_gui(gui_id)
  if storage.guis[gui_id] then
    --game.print(tostring(game.tick).." hiding gui")
    local spelevator_log_gui = storage.guis[gui_id]
    spelevator_log_gui.gui.visible = false
    if storage.guis[gui_id].player.opened == spelevator_log_gui.gui then
      storage.guis[gui_id].player.opened = nil
      --game.print(tostring(game.tick).." player cleared")
    end
    --storage.guis[gui_id] = nil
  --else
    --game.print(tostring(game.tick).." no gui to hide")
  end
end


---@param player LuaPlayer
local function open_or_close_gui(player)
  local gui_id = "gui-" .. player.name
  if storage.guis[gui_id] and storage.guis[gui_id].gui.visible then
    destroy_gui(gui_id)  -- Hide existing gui
  else
    open_gui(player)   -- Create new or show existing gui
  end
end

local function close_gui(player)
  local gui_id = "gui-" .. player.name
  -- Ignore close requests if we are not already open
  if storage.guis[gui_id] and storage.guis[gui_id].gui.visible then
    destroy_gui(gui_id)
  end
end

local function destroy_gui(gui_id)
  if storage.guis[gui_id] then
    --game.print(tostring(game.tick).." hiding gui")
    local spelevator_log_gui = storage.guis[gui_id]
    spelevator_log_gui.gui.visible = false
    if storage.guis[gui_id].player.opened == spelevator_log_gui.gui then
    --   storage.guis[gui_id].gui.window.destroy()
    --   game.print(table_size(storage.guis[gui_id].events_contents.children))
      storage.guis[gui_id].player.opened = nil
      --game.print(tostring(game.tick).." player cleared")
    end
    --storage.guis[gui_id] = nil
  --else
    --game.print(tostring(game.tick).." no gui to hide")
  end
end

function gui_handlers.close_window(event)
    local gui_id = event.element.tags.gui_id
    destroy_gui(gui_id)
end

flib_gui.add_handlers(gui_handlers, function(e, handler) 
    handler(e)
end) 


return {
    open_or_close_gui = open_or_close_gui,
}