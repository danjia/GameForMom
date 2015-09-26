

function class(className, superClass)
	local t = {}
	t.superClass = superClass
	t.init = function ()end
	function t:create()
		local instance = t.superClass()
		for k,v in pairs(t) do instance[k] = v end
		instance:init()
		return instance
	end
	-- t.create = function(self)
	-- 	local instance = superClass()
	-- 	instance:init()
	-- 	return instance
	-- end
	return t
end