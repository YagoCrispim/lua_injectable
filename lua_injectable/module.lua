---@class Module
---@field name string
---@field providers? Provider[] | table[]
---@field modules? Module[]

---@param definition Module
---@return Module
local function Module(definition)
    if not definition.name then
        error("[ERROR]: Module name not found. \n" .. "\t- All modules must have a name.")
        os.exit()
    end
    return definition
end

return Module
