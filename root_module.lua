local registry = require 'registry'
local scopes = require 'scopes'

local RootModule = {}
RootModule.__index = RootModule

---@alias Fn fun(): nil

---@param root_module Module
---@return { start: fun(Fn): nil }
function RootModule:new(root_module)
    local providers = self:_collect_all_providers(root_module)

    print('\n--- Loading providers ---\n')
    self:_register_providers(providers)

    print('\n--- Providers instantiation ---\n')
    self:_instantiate_providers()

    return {
        start = function(cb)
            print('\n--- Starting app ---\n')
            cb()
        end
    }
end

---@param root_module Module
---@return Provider[]
function RootModule:_collect_all_providers(root_module)
    local app_providers = root_module.providers
    local sub_modules = root_module.modules

    ---@type Provider[]
    local providers = {}

    if app_providers then
        if app_providers then
            for _, provider in pairs(app_providers) do
                providers[provider.__name] = provider
            end
        end
    end

    if sub_modules then
        if #sub_modules then
            for _, module in pairs(sub_modules) do
                local module_providers = module.providers

                if module_providers then
                    for _, provider in pairs(module_providers) do
                        providers[provider.__name] = provider
                    end
                end
            end
        end
    end

    return providers
end

---@param providers Provider[]
function RootModule:_register_providers(providers)
    if #providers then
        for _, provider in pairs(providers) do
            local scope = provider.__scope

            print('Registering provider: ' .. provider.__name .. '. Scope -> ' .. provider.__scope)
            if scope == scopes.singleton then
                registry.singleton[provider.__name] = provider:new()
            end

            if scope == scopes.injection then
                registry.injection[provider.__name] = provider
            end
        end
    end
end

function RootModule:_instantiate_providers()
    for key, provider in pairs(registry.singleton) do
        print('Instantiaging provider: ', provider.__name)
        local instance = provider:new()
        registry.singleton[key] = instance
    end
end

return RootModule
