--- initial word letters uppercase ('title case').
-- Here 'words' mean chunks of non-space characters.
---@param s string
---@return string a string with each word's first letter uppercase
local function title(s)
    return (s:gsub([[(%S)(%S*)]], function(f, r)
        return f:upper() .. r:lower()
    end))
end

--- Given a candidate search function, iterates over the table, calling the function
-- for each element in the table, and returns the first element the search function returned true.
-- Passes the index as second argument to the function.
---@param tbl table             the table to be searched
---@param func function         the function to use when searching for any matching element
---@param ... any?
---@return any, any|nil|?       the first found value
local function find(tbl, func, ...)
    for k, v in pairs(tbl) do if func(v, k, ...) then return v, k end end
    return nil
end

return {
    title = title,
    find = find
}