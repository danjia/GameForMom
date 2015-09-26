local GameManager = {}

local Queue = require("scripts.common.Queue")

local dir = {{-1, 0}, {0, 1}, {1, 0}, {0, -1}}
local INF = 999999

function GameManager:init()
	--记录点击的位置
	self.m_clickPos = {}

	self.m_state = STATE_NONE

	self.m_curLevel = 1
end
--------------------------------------------------
--[[
				Get  Set
]]
---------------------------------------------------
--@brief 要设置的状态
function GameManager:setState(state)
	self.m_state = state
end
function GameManager:getState()
	return self.m_state
end

--@brief 当前状态
function GameManager:setCurState(curState)
	self.m_curState = curState
end
function GameManager:getCurState()
	return self.m_curState
end

--@brief 关卡
function GameManager:setCurLevel(curLevel)
	self.m_curLevel = curLevel
end
function GameManager:getCurLevel()
	return self.m_curLevel
end
function GameManager:increaseCurLevel()
	self.m_curLevel = self.m_curLevel + 1
end
---------------------------------------------------

--@brief 设置地图
function GameManager:setMap(map, iconWidth, iconHeight)
	self.m_map = map
	self.m_iconWidth  = iconWidth
	self.m_iconHeight = iconHeight
	self.m_mapCols = #map[1]
	self.m_mapRows = #map
	self.m_mapWidth = self.m_iconWidth*self.m_mapCols
	self.m_mapHeight = self.m_iconHeight*self.m_mapRows
	self.m_vis = {}
	for row = 1, self.m_mapRows do
		local t = {}
		for col = 1, self.m_mapCols do
			t[col] = false 	
		end
		self.m_vis[row] = t
	end

	--
	self.m_mapPathLength = {}
	self.m_mapTurnNum = {}
	self.m_mapDir ={}
	for row = 1, self.m_mapRows do
		local pathRow   = {}
		local turNumRow = {}
		local dirRow    = {}
		for col = 1, self.m_mapCols do
			pathRow[col]   = INF
			turNumRow[col] = INF
			dirRow[col]    = 0
		end
		self.m_mapPathLength[row] = pathRow
		self.m_mapTurnNum[row]    = turNumRow
		self.m_mapDir[row]        = dirRow
	end

	--队列
	self.m_queue = Queue:new()
end

--@brief 获取icon的大小
function GameManager:getIconSize()
	return self.m_iconWidth, self.m_iconHeight
end

--@brief 获取map的大小
function GameManager:getMapSize()
	return self.m_mapRows, self.m_mapCols
end

--@brief 设置地图的单元格
function GameManager:setTheMapCell(row, col, value)
	self.m_map[row][col] = value
end

--@brief 迪杰斯特
function GameManager:dijstra2(srcRow, srcCol, desRow, desCol)
	--初始化地图信息(路径长度, 拐弯数量, 拐弯)
	for row = 1, self.m_mapRows do
		for col = 1, self.m_mapCols do
			self.m_mapPathLength[row][col] = INF
			self.m_mapTurnNum[row][col]    = INF
			self.m_mapDir[row][col]        = 0
		end
	end
	self.m_mapPathLength[srcRow][srcCol] = 0
	self.m_mapTurnNum[srcRow][srcCol]       = 0

	--清除队列
	self.m_queue:clear()
	--将第一个元素添加到队列里面
	self.m_queue:push({srcRow, srcCol})

	--队列不为空
	while self.m_queue:isEmpty() do
		local frontObj = self.m_queue:pop()
        if not frontObj then
            local a = 1
        end
		
		local curRow, curCol = frontObj[1], frontObj[2]
		--print("cur:("..curRow..","..curCol..")")
		if curRow == desRow and curCol == desCol then
			return true, self.m_mapDir
		end

		local curDir = self.m_mapDir[curRow][curCol]

		--检查下4个方向
		for d = 1, 4 do
			local newRow = curRow + dir[d][1]
			local newCol = curCol + dir[d][2]
			if newRow >= 1 and newRow <= self.m_mapRows and --上下边界检测 
				newCol >= 1 and newCol <= self.m_mapCols and --左右边界检测
				((0==self.m_map[newRow][newCol]) or (newRow == desRow and newCol == desCol)) and
				self.m_mapTurnNum[newRow][newCol] >= self.m_mapTurnNum[curRow][curCol] then --转弯数
				
				local newTurnNum = self.m_mapTurnNum[curRow][curCol]
				--如果不是从原点出发(原点到下一步的转弯数不用变) and 当前位置和下一步的方向不同
				if 0 ~= curDir and curDir ~= d then
					--转弯数要加1
					newTurnNum = newTurnNum + 1
			   	end

			   	--从当前(curRow, curCol)出发的转弯数<从别的地方到达(newRow, newCol)的转弯数
			   	if (newTurnNum < self.m_mapTurnNum[newRow][newCol] or 
			   		--从当前(curRow, curCol)出发的转弯数==从别的地方到达(newRow, newCol)的转弯数, 不过距离距离小了
			   		(newTurnNum == self.m_mapTurnNum[newRow][newCol] and
			   			self.m_mapPathLength[newRow][newCol] > self.m_mapPathLength[curRow][curCol]+1)) and
			   		newTurnNum <= 2 then

			   		--重置下信息
			   		self.m_mapPathLength[newRow][newCol] = self.m_mapPathLength[curRow][curCol] + 1
			   		self.m_mapTurnNum[newRow][newCol]    = newTurnNum
			   		self.m_mapDir[newRow][newCol]        = d
			   		self.m_queue:push({newRow, newCol})
			   		--print("push:("..newRow..","..newCol..")")
			   	end
			end
		end
		--print("-----------------------------------------------------")
	end
	return false, nil
end

local function checkIsContainIn(d, t)
	if t then
		for i = 1, #t do
			if t[i] == d then
				return true
			end
		end
	end
	return false
end

--@brief 迪杰斯特
function GameManager:dijstra(srcRow, srcCol, desRow, desCol)
	--初始化地图信息(路径长度, 拐弯数量, 拐弯)
	for row = 1, self.m_mapRows do
		for col = 1, self.m_mapCols do
			self.m_mapPathLength[row][col] = INF
			self.m_mapTurnNum[row][col]    = INF
			self.m_mapDir[row][col]        = nil
		end
	end
	self.m_mapPathLength[srcRow][srcCol] = 0
	self.m_mapTurnNum[srcRow][srcCol]       = 0

	--清除队列
	self.m_queue:clear()
	--将第一个元素添加到队列里面
	self.m_queue:push({srcRow, srcCol})
	--队列不为空
	while self.m_queue:isEmpty() do
		local frontObj = self.m_queue:pop()
        if not frontObj then
            local a = 1
        end
		
		local curRow, curCol = frontObj[1], frontObj[2]
		--print("cur:("..curRow..","..curCol..")")
		if curRow == desRow and curCol == desCol then
			return true, self.m_mapDir
		end

		local curDir = self.m_mapDir[curRow][curCol]

		--检查下4个方向
		for d = 1, 4 do
			local newRow = curRow + dir[d][1]
			local newCol = curCol + dir[d][2]
			if newRow >= 1 and newRow <= self.m_mapRows and --上下边界检测 
				newCol >= 1 and newCol <= self.m_mapCols and --左右边界检测
				((0==self.m_map[newRow][newCol]) or (newRow == desRow and newCol == desCol)) and
				self.m_mapTurnNum[newRow][newCol] >= self.m_mapTurnNum[curRow][curCol] then --转弯数
				
				local newTurnNum = self.m_mapTurnNum[curRow][curCol]
				--如果不是从原点出发(原点到下一步的转弯数不用变) and 当前位置和下一步的方向不同
				if nil ~= curDir and not checkIsContainIn(d, curDir) then
					--转弯数要加1
					newTurnNum = newTurnNum + 1
				end 
				-- if 0 ~= curDir and curDir ~= d then
				-- 	--转弯数要加1
				-- 	newTurnNum = newTurnNum + 1
			 --   	end

			   	--从当前(curRow, curCol)出发的转弯数<从别的地方到达(newRow, newCol)的转弯数
			   	if (newTurnNum < self.m_mapTurnNum[newRow][newCol] or 
			   		--从当前(curRow, curCol)出发的转弯数==从别的地方到达(newRow, newCol)的转弯数, 不过距离距离小了
			   		(newTurnNum == self.m_mapTurnNum[newRow][newCol] and
			   			self.m_mapPathLength[newRow][newCol] >= self.m_mapPathLength[curRow][curCol]+1)) and
			   		newTurnNum <= 2 then

			   		--重置下信息
			   		self.m_mapPathLength[newRow][newCol] = self.m_mapPathLength[curRow][curCol] + 1
			   		self.m_mapTurnNum[newRow][newCol]    = newTurnNum
			   		if not self.m_mapDir[newRow][newCol] then
			   			self.m_mapDir[newRow][newCol] = {}
			   		end
			   		self.m_mapDir[newRow][newCol][#self.m_mapDir[newRow][newCol]+1] = d
			   		self.m_queue:push({newRow, newCol})
			   		print("push:("..newRow..","..newCol..")")
			   	end
			end
		end
		--print("-----------------------------------------------------")
	end
	return false, nil
end

--@brief 深度优先搜索
function GameManager:dfs(curRow, curCol, desRow, desCol, preDir, curTurnNum, path)
	--print("("..curRow..", "..curCol..")")
	path[#path+1] = {curRow, curCol, preDir}
	--已经访问
	self.m_vis[curRow][curCol] = true
	--是否找到目标
	if curRow == desRow and curCol == desCol then
		return true, path
	end
	--已经转了2个弯了的话
	if curTurnNum > 2 then
		--恢复为未访问
		--print("2:remove vis msg:("..curRow..","..curCol..")")
		self.m_vis[curRow][curCol] = false
		path[#path] = nil
		return false, nil
	end
	local isNeedAddTurn = false --是否需要增加拐弯计数
	for d = 1, 4 do
		local newRow = curRow + dir[d][1]
		local newCol = curCol + dir[d][2]
		--print("check:("..newRow..","..newCol..") curTurnNum:"..curTurnNum)
		if newRow >= 1 and newRow <= self.m_mapRows and newCol >= 1 and newCol <= self.m_mapCols and
			((not self.m_vis[newRow][newCol] and 0==self.m_map[newRow][newCol]) or 
			 (newRow == desRow and newCol == desCol)) then
			isNeedAddTurn = false
			if 0 == preDir or preDir ~= d then
				if 0 ~= preDir then
					isNeedAddTurn = true
				end
				preDir = d

				--curTurnNum = curTurnNum + 1
			end
			print("accept:("..newRow..","..newCol..")")
			local existPath, path = self:dfs(newRow, newCol, desRow, desCol, preDir, curTurnNum+(isNeedAddTurn and 1 or 0), path) 
			if existPath then
				return true, path
			end
		end
	end
	--恢复为未访问
	--print("3:remove vis msg:("..curRow..","..curCol..")")
	self.m_vis[curRow][curCol] = false
	path[#path] = nil
	return false, nil
end

--@brief 查找路径
function GameManager:findTheWay(curRow, curCol, desRow, desCol, preDir, curTurnNum)
	if self.m_map[curRow][curCol] == self.m_map[desRow][desCol] then
		for row = 1, self.m_mapRows do
			for col = 1, self.m_mapCols do
				self.m_vis[row][col] = false 	
			end
		end
		--print("start to find the way!!")
		return self:dfs(curRow, curCol, desRow, desCol, preDir, curTurnNum, {})
	else
		--print("not same!!!")
		return false
	end
end

function GameManager:findTheWay2(curRow, curCol, desRow, desCol)
	if self.m_map[curRow][curCol]~=0 and self.m_map[curRow][curCol] == self.m_map[desRow][desCol] then
		--print("start to find the way!!")
		return self:dijstra(curRow, curCol, desRow, desCol)
	else
		--print("not same!!!")
		return false
	end
end

--@brief 获取地图上的行列
function GameManager:getMapAddress(x, y)
	if x < 0 or x > self.m_mapWidth or y < 0 or y > self.m_mapHeight then
		return -1, -1
	end 
	local xIntPart, xFloatPart = math.modf(x/self.m_iconWidth)
	local yIntPart, yFloatPart = math.modf((self.m_mapRows*self.m_iconHeight-y)/self.m_iconHeight)
	return yIntPart+1, xIntPart+1
end

--@brief 
--@example 3*3map
------------------------
-- map tag:
-- 0 1 2
-- 3 4 5
-- 6 7 8
------------------------
-- map row col:
-- (1, 1) (1, 2) (1, 3)
-- (2, 1) (2, 2) (2, 3)
-- (3, 1) (3, 2) (3, 3)
------------------------
function GameManager:getRowColByTag(tag)
	return math.modf(tag/self.m_mapCols)+1, tag%self.m_mapCols+1
end
function GameManager:getTagByRowCol(row, col)
	return (row-1)*self.m_mapCols+(col-1)
end

--------------------------------------------------------
--@brief 设置点击位置
function GameManager:setClickPos(row, col)
	if -1~=row and -1~=col and 0 ~= self.m_map[row][col] then
		if not self.m_clickPos[1] then
			self.m_clickPos[1] = {row, col}
		elseif self.m_clickPos[1][1] ~= row or self.m_clickPos[1][2] ~= col then
			self.m_clickPos[2] = {row, col}
		end	
	end
end

--@brief 获取点击位置
function GameManager:getClickPos()
	return self.m_clickPos
end

--@brief 清除点击位置
function GameManager:clearClickPos()
	self.m_clickPos = {}
end

function GameManager:getPositionByIndex(row, col)
	return (col-1)*self.m_iconWidth+self.m_iconWidth/2, (self.m_mapRows-row)*self.m_iconHeight+self.m_iconHeight/2
	-- return (col-1)*iconWidth+iconWidth/2, (mapRows-row)*iconHeight+iconHeight/2
end

function GameManager:getRotation(dir)
	if 1 == dir then
		return 90
	elseif 2 == dir then
		return -180
	elseif 3 == dir then
		return -90
	elseif 4 == dir then
		return 0
	end
end


function GameManager:getPreRowColByDir(curRow, curCol, curDir)
	local index = (curDir+1)%4+1
	return curRow+dir[index][1], curCol+dir[index][2]
end

function GameManager:randomAmapByEdiitOld()
	local mapInfo = require("scripts.datas.map.map2")
	local map = mapInfo.data
	local mapRows = 7
	local mapCols = 10
	local kindNum = 5

	
	local data = {}
	local cnt = 0
	for row = 2, mapRows+1 do
		local t = {}
		for col = 2, mapCols+1 do
			--t[col] = cnt % kindNum + 1--row % kindNum + 1
			t[col] = row % kindNum + 1
			--cnt = cnt + 1
		end
		data[row] = t
	end


	local temp = nil
	for i = 1, 10 do
		--交换列
		local colIndex1 = math.random(1, mapCols)
		local colIndex2 = math.random(1, mapCols)
		for row = 1, mapRows do
			local randomRow = math.random(1, mapRows)
			temp = data[row][colIndex1]
			data[row][colIndex1] = data[randomRow][colIndex2]
			data[randomRow][colIndex2] = temp
		end
		--交换行
		local rowIndex1 = math.random(1, mapRows)
		local rowIndex2 = math.random(1, mapRows)
		temp = data[rowIndex1]
		data[rowIndex1] = data[rowIndex2]
		data[rowIndex2] = temp
	end

	local map = {}
	map.data = data
	map.iconWidth = 60
	map.iconHeight = 60
	return map
end

function GameManager:randomAmap()
	-- local a = 2--math.random(1, 3)*2
	-- local b = 1--math.random(1, 9)


	-- local rowNum = a+2
	-- local colNum = b+2
	local rowNum = 6+2
	local colNum = 8+2
	local kindNum = 10
	math.randomseed(os.time())


	local data = {}
	local cnt = 0

	local total = (rowNum-2)*(colNum-2)
	local normalNum = toint(total/(kindNum*2))*(kindNum*2)

	for row = 1, rowNum do
		local t = {}
		for col = 1, colNum do
			if col == 1 or col == colNum or
				1== row or rowNum == row then
				t[col] = 0
			else
				if cnt == normalNum + 1 then
                    local left = total-normalNum
                    --if 2 == left then
                    kindNum = 1--toint(left/4)
                    
				    --kindNum = toint()
				end
				t[col] = cnt % kindNum + 1
				cnt = cnt + 1
			end
		end
		data[row] = t
	end

	

	for i = 1, rowNum*colNum do
		local randRow1 = math.random(2, rowNum-1)
		local randCol1 = math.random(2, colNum-1)
		local randRow2 = math.random(2, rowNum-1)
		local randCol2 = math.random(2, colNum-1)
		local temp = data[randRow1][randCol1]
		data[randRow1][randCol1] = data[randRow2][randCol2]
		data[randRow2][randCol2] = temp
	end

	-- for row = 1, rowNum do
	-- 	local s = ""
	-- 	for col = 1, colNum do
	-- 		s = s .. data[row][col] ..', '
	-- 	end
	-- 	print(s)
	-- end

	local map = {}
	map.data = data
	-- map.iconWidth = 65
	-- map.iconHeight = 65
	map.iconWidth = 75
	map.iconHeight = 70
	return map
end

function GameManager:checkIsClearTheMap()
	--是否全部消除完
	for row = 2, self.m_mapRows-1 do
		for col = 2, self.m_mapCols-1 do
			if 0~=self.m_map[row][col] then
				return false
			end
		end
	end
	--print("true-------------")
	return true
end

function GameManager:getCurLevelProgressTime()
	--For Mom
	if self.m_curLevel <= 5 then
		return 90 - self.m_curLevel*2
	elseif self.m_curLevel <= 10 then
		return 75
	elseif self.m_curLevel <= 20 then
		return 70
	elseif self.m_curLevel <= 30 then
		return 65
	elseif self.m_curLevel <= 50 then
		return 60
	else
		return 50
	end
	
	--For Dad
	-- if self.m_curLevel <= 5 then
	-- 	return 140 - self.m_curLevel*2
	-- elseif self.m_curLevel <= 10 then
	-- 	return 120
	-- elseif self.m_curLevel <= 20 then
	-- 	return 110
	-- elseif self.m_curLevel <= 30 then
	-- 	return 100
	-- elseif self.m_curLevel <= 50 then
	-- 	return 90
	-- else
	-- 	return 80
	-- end
end


--------------------------------------------------------- 

---------------------------------------------------------
return GameManager