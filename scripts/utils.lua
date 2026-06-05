--- iniital word letters uppercase ('title case').
-- Here 'words' mean chunks of non-space characters.
---@param s string
---@return string a string with each word's first letter uppercase
local function title(s)
    return (s:gsub([[(%S)(%S*)]], function(f, r)
        return f:upper() .. r:lower()
    end))
end

return {
    title = title
}