local java: table = {}
local cloneref = cloneref or function(v) return v end
java.services = {
    HttpService = cloneref(game:GetService("HttpService"))
}

-- java
java.console = {
    log = function(...: string): string
        local args: table = {...}
        local str: string = ""
        for i = 1, #args do
            str = str .. tostring(args[i]) .. " "
        end
        print(str)
    end,
    warn = function(...: string): string
        local args: table = {...}
        local str: string = ""
        for i = 1, #args do
            str = str .. tostring(args[i]) .. " "
        end
        warn(str)
    end,
    error = function(...: string): string
        local args: table = {...}
        local str: string = ""
        for i = 1, #args do
            str = str .. tostring(args[i]) .. " "
        end
        error(str)
    end
}

-- Array methods
java.Array = {
    isArray = function(arr: table): table
        return type(arr) == "table"
    end,
    push = table.insert,
    pop = table.remove,
}

-- Math object
java.Math = {
    random = math.random,
    floor = math.floor,
    ceil = math.ceil,
    round = function(x)
        return math.floor(x + 0.5)
    end,
    max = math.max,
    min = math.min
}

-- Time methods
java.Time = {
    now = function()
        return os.time()
    end
}

-- String methods
java.String = {
    format = string.format,
    toUpperCase = string.upper,
    toLowerCase = string.lower,
    trim = function(str: string): string
        return str:match("^%s*(.-)%s*$")
    end,
    split = function(str: string, delimiter: string): table
        local result: table = {}
        local pattern: string = string.format("([^%s]+)", delimiter)
        str:gsub(pattern, function(c)
            table.insert(result, c)
        end)
        return result
    end
}

java.Http = {
    get = function(url: string): string
        local response: string = ""
        local success: boolean, err: string = pcall(function()
            response = java.services.HttpService:PostAsync(url)
        end)
        if not success then
            java.console.error("Error making HTTP request:", err)
        end
        return response
    end,
    post = function(url: string, data: string): string
        local response: string = ""
        local success: boolean, err: string = pcall(function()
            response = java.services.HttpService:PostAsync(url, data)
        end)
        if not success then
            java.console.error("Error making HTTP request:", err)
        end
        return response
    end
}

java.Require = function(val: string): string
    return loadstring(game:HttpGet(val))
end

java.Conversion = {
    jsToLuau = function(code: string): string
        local lines: string = java.String.split(code, '\n')
        local luaucode: string = ''
        for _,v in ipairs(lines) do
            v = v:match("^%s*(.-)%s*$")
            v = v:gsub("console%.log%((.-)%)", "java.console.log(%1)")
            v = v:gsub("let%s+([%w_]+)%s*=%s*(.+)", "local %1 = %2")
            v = v:gsub("var%s+([%w_]+)%s*=%s*(.+)", "local %1 = %2")
            v = v:gsub("const%s+([%w_]+)%s*=%s*(.+)", "local %1 = %2")
            v = v:gsub("Math%.(%w+)", "java.Math.%1")
            v = v:gsub("(%w+)%.push%((.-)%)", "java.Array.push(%1, %2)")
            v = v:gsub("(%w+)%.pop%((.-)%)", "java.Array.pop(%1, %2)")
            v = v:gsub("(['\"])(.-)%1%.toUpperCase%(%)","java.String.toUpperCase(%2)")
            v = v:gsub("(['\"])(.-)%1%.toLowerCase%(%)","java.String.toLowerCase(%2)")
            v = v:gsub("%((.-)%)%s*=>%s*{(.-)}", "function(%1) %2 end")
            v = v:gsub(";%s*$", "")
            
            luaucode = luaucode..v..'\n'
        end
        return luaucode
    end,
    astToLuau = function(ast: table): string
        local function processNode(node: table): string
            if not node or type(node) ~= "table" then return "" end 
            if node.type == 'Program' then
                local code = ''
                for _,v in ipairs(node.body) do
                    code = code..processNode(v)..'\n'
                end
                return code
            elseif node.type == 'ExpressionStatement' then
                return processNode(node.expression)
            elseif node.type == 'CallExpression' then
                local callee = processNode(node.callee)
                local args = {}
                for _,v in ipairs(node.arguments) do
                    table.insert(args, processNode(v))
                end
                return string.format('%s(%s)', callee, table.concat(args, ', '))
            elseif node.type == 'Literal' then
                return tostring(node.value)
            elseif node.type == 'Idenitifier' then
                return node.name
            end
            return ''
        end
        return processNode(ast)
    end
}

return java