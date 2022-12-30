Horizon = {}

Horizon.isInteger = function(str)
    return not (str == "" or str:find("%D"))  
end


local NumberCharset = {}
local Charset = {}

for i = 48,  57 do 
    table.insert(NumberCharset, string.char(i)) 
end

for i = 65,  90 do 
    table.insert(Charset, string.char(i)) 
end

for i = 97, 122 do 
    table.insert(Charset, string.char(i)) 
end

Horizon.StyleText = function (text)
    local result = ''
    if text ~= '' then
        result = string.format('%s%s',string.upper(string.sub(text,string.len(text)*-1,string.len(text)*-1)),string.sub(text, 2))
    end
    return result
end

Horizon.GetRandomNumber = function(length)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return Horizon.GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

Horizon.GetRandomLetter = function(length)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return Horizon.GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end