---@class ProvidersRegistry
---@field singleton Provider[]
---@field injection Provider[]
local providersRegistry = {
    singleton = {},
    injection = {}
}

return providersRegistry

