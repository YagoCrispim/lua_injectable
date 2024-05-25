local registry = require 'registry'

---@class New
---@field _current_provider_name string
---@field _last_provider_name string
local Resolve = {
    _current_provider_name = '',
    _last_provider_name = ''
}
Resolve.__index = Resolve

---@generic T
---@return fun(class: T): T
function Resolve:new()
    return function(class)
        if not class then
            return {}
        end

        if type(class) ~= 'table' then
            return class
        end

        local instance = {}

        for key, value in pairs(class) do
            if key ~= 'new' then
                instance[key] = value

                if type(value) == 'table' and value.__is_injectable then
                    local provider = value --[[ @as Provider ]]

                    if provider.__scope == 'singleton' then
                        self:_resolve_scope_singleton(key, instance, provider)
                    end

                    if provider.__scope == 'transient' then
                        self:_resolve_scope_injection(key, instance, provider)
                    end
                end
            end
        end

        self:_clear(instance)
        return setmetatable(instance, class)
    end
end

---@param instance table
function Resolve:_clear(instance)
    instance.new = nil
    self._current_provider_name = ''
    self._last_provider_name = ''
end

---@generic T
---@param key string
---@param instance table
---@param provider Provider
function Resolve:_resolve_scope_singleton(key, instance, provider)
    for provider_name, provider_instance in pairs(registry.singleton) do
        if provider_name == provider.__name then
            self._last_provider_name = provider_name --[[ @as string ]]
            instance[key] = provider_instance
        end
    end
end

---@generic T
---@param key string
---@param instance table
---@param provider Provider
function Resolve:_resolve_scope_injection(key, instance, provider)
    for provider_name, provider_instance in pairs(registry.injection) do
        local pname = provider_name --[[ @as string ]]

        if pname == provider.__name then
            self._current_provider_name = pname
            if self._current_provider_name ~= self._last_provider_name then
                self._last_provider_name = pname
                instance[key] = provider_instance:new()
            end
        end
    end
end

return Resolve:new()
