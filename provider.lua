local scopes = require 'scopes'

---@class Provider
---@field __name string
---@field __scope? string
---@field __injectable? boolean
---@field new fun(self: Provider): Provider

---@generic T
---@param implementation T
---@return T
local function Provider(implementation)
    local provider = implementation --[[ @as Provider ]]

    if not provider.__name then
        print("[ERROR]: Provider name not found. \n" .. "\t- All providers must have a name.")
        os.exit()
    end

    if not provider.new then
        print("[ERROR]: Method 'new' not foun in provider. \n" ..
            "\t-" .. provider.__name .. '. All providers must have a "new" method')
        os.exit()
    end

    provider.__injectable = true
    if not provider.__scope then
        provider.__scope = scopes.singleton
    end

    return provider
end

return Provider
