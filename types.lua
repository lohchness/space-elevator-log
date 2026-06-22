---@meta

---@class TrainTeleportFinishedEvent
---@field train LuaTrain                  fully built newly created train post transfer
---@field old_train_id_1 uint32           id of the train prior to transer start
---@field stranded? uint32                optional: only if train is split due to incomplete transfer
---@field old_surface_index uint32        ??
---@field teleporter LuaEntity            space elevator entity doing the transferring

---@class SpaceElevatorInfo               Info about the space elevator
---@field main LuaEntity                  Entity doing the transfer
---@field train_stop string
---@field opposite LuaEntity              Space elevator on opposite side
---@field constructed boolean
---@field powered boolean

---@class LogEntry
---@field time MapTick                       tick of event
---@field train LuaTrain                      
---@field contents ItemWithQualityCount[]    copy of contents at the time
---@field records ScheduleRecord[]?          stops in schedule
---@field current uint32                     record index of next station
---@field teleporter LuaEntity
---@field solid_surface_name string
---@field solid_surface_index integer

---@class GuiConfig
---@field gui_id string
---@field gui LuaGuiElement
---@field player LuaPlayer
---@field filter_guis table
---@field events_contents LuaGuiElement
---@field summary_contents LuaGuiElement

---@class ElevatorZone
---@field name string              Titlecase of Surface name
---@field type string              "orbit" or "planet"
---@field zone_index int           Zone Index given by Space Exploration
---@field opposite ElevatorZone
---@field surface_index int

---@class SEZoneType
---@field name string           
---@field index int             Zone Index
---@field surface_index int
---@field type string           "planet" or "orbit"

--- A GUI element definition. This extends `LuaGuiElement.add_param` with several new attributes.
--- Children may be defined in the array portion as an alternative to the `children` subtable.
--- @class flib.GuiElemDef: LuaGuiElement.add_param.button|LuaGuiElement.add_param.camera|LuaGuiElement.add_param.checkbox|LuaGuiElement.add_param.choose_elem_button|LuaGuiElement.add_param.drop_down|LuaGuiElement.add_param.flow|LuaGuiElement.add_param.frame|LuaGuiElement.add_param.line|LuaGuiElement.add_param.list_box|LuaGuiElement.add_param.minimap|LuaGuiElement.add_param.progressbar|LuaGuiElement.add_param.radiobutton|LuaGuiElement.add_param.scroll_pane|LuaGuiElement.add_param.slider|LuaGuiElement.add_param.sprite|LuaGuiElement.add_param.sprite_button|LuaGuiElement.add_param.switch|LuaGuiElement.add_param.tab|LuaGuiElement.add_param.table|LuaGuiElement.add_param.text_box|LuaGuiElement.add_param.textfield
--- @field style_mods LuaStyle? Modifications to make to the element's style.
--- @field elem_mods LuaGuiElement? Modifications to make to the element itself.
--- @field drag_target string? Set the element's drag target to the element whose name matches this string. The drag target must be present in the `elems` table.
--- @field handler (flib.GuiElemHandler|table<defines.events, flib.GuiElemHandler>)? Handler(s) to assign to this element. If assigned to a function, that function will be called for any GUI event on this element.
--- @field children flib.GuiElemDef[]? Children to add to this element.
--- @field type string?
--- @field tab flib.GuiElemDef? To add a tab, specify `tab` and `content` and leave all other fields unset.
--- @field content flib.GuiElemDef? To add a tab, specify `tab` and `content` and leave all other fields unset.

--- A handler function to invoke when receiving GUI events for this element.
--- @alias flib.GuiElemHandler fun(e: flib.GuiEventData)

--- Aggregate type of all possible GUI events.
--- @alias flib.GuiEventData EventData.on_gui_checked_state_changed|EventData.on_gui_click|EventData.on_gui_closed|EventData.on_gui_confirmed|EventData.on_gui_elem_changed|EventData.on_gui_location_changed|EventData.on_gui_opened|EventData.on_gui_selected_tab_changed|EventData.on_gui_selection_state_changed|EventData.on_gui_switch_state_changed|EventData.on_gui_text_changed|EventData.on_gui_value_changed
