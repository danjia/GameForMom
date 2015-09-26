--@brief 队列
local Queue = {}

--@brief 新建
function Queue:new(t)
	local t = t or {}
	setmetatable(t, self)
	self.__index = self
	t.m_q = {}
	t.m_startIndex = 1
	t.m_endIndex = 0
	return t
end

--@brief 元素入队
function Queue:push(obj)
	self.m_endIndex = self.m_endIndex + 1
	self.m_q[self.m_endIndex] = obj
end

--@brief 元素出队
function Queue:pop()
	local obj = self.m_q[self.m_startIndex]
	self.m_q[self.m_startIndex] = nil
    self.m_startIndex = self.m_startIndex + 1
	return obj
end

--@brief 判断是否为空
function Queue:isEmpty()
	return self.m_endIndex - self.m_startIndex >= 0 
end

--@brief 获取队前的元素
function Queue:getFront()
	if not self:isEmpty() then
		return self.m_q[self.m_startIndex]
	end
	return nil
end

--@brief 获取队尾的元素
function Queue:getRear()
	if not self:isEmpty() then
		return self.m_q[self.m_endIndex]
	end
	return nil
end

--@brief 轻度清除
function Queue:clear()
	self.m_startIndex = 1
	self.m_endIndex = 0
end

--@brief 深度清除
function Queue:deepClear()
	for k, v in pairs(self.m_q) do
		self.m_q[k] = nil
	end
	self:clear()
end

return Queue