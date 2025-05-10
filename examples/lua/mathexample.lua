local java = {
    js = loadstring(game:HttpGet('https://raw.githubusercontent.com/sstvskids/JStoLuaU/refs/heads/main/javaconvert.lua'))(),
    example = loadstring(game:HttpGet('https://raw.githubusercontent.com/sstvskids/JStoLuaU/refs/heads/main/examples/javascript/mathexample.js'))()
}

return java.js.conversion.convertToLuau(java.example)