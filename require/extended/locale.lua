Locales = {}

function _(str, ...)  -- Translate string
	if Locales[extendedConfig.Locale] ~= nil then
		if Locales[extendedConfig.Locale][str] ~= nil then
			return string.format(Locales[extendedConfig.Locale][str], ...)
		else
			return 'Translation [' .. extendedConfig.Locale .. '][' .. str .. '] does not exist'
		end

	else
		return 'Locale [' .. extendedConfig.Locale .. '] does not exist'
	end
end

function _U(str, ...) -- Translate string first char uppercase
	return tostring(_(str, ...):gsub("^%l", string.upper))
end