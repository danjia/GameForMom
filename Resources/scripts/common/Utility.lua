
--[[
@brief 获取utf-8字符串的长度
utf-8
0xxxxxxx
110xxxxx 10xxxxxx
1110xxxx 10xxxxxx 10xxxxxx
11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx

0xxxxxxx >= 0
110xxxxx >= 0xc0
1110xxxx >= 0xe0
11110xxx >= 0xf0
111110xx >= 0xf8
1111110x >= 0xfc

https://en.wikipedia.org/wiki/UTF-8
]]

function getUtf8len(str)
	local len = string.len(str)
	local compare = {0xfc, 0xf8, 0xf0, 0xe0, 0xc0, 0}
	local cnt = 0
	local i = 1
	while true do
		if i > len then
			break
		end
		local asciiValue = string.byte(str, i)
		for j = 1, #compare do
			if asciiValue >= compare[j] then
				--跳过 7-j 个字符
				i = i + 7-j
				cnt = cnt + 1
				break
			end
		end
	end
	return cnt
end

--[[
@brief 四舍五入
-1.4 => -1
-1.6 => -2
 1.4 => 1
 1.6 => 2
]]
function toRound(n)
	return math.floor(n + 0.5)
end

--[[
@brief 将number转为整数(即将小数部分截断)
]]
function toint(n)
	local a = math.modf(n)
	return a
end

--[[
@brief 克隆table
]]
function cloneTable(t)
	local newT = {}
	for k, v in pairs(t) do
		if "type" == type(v) then
			newT[k] = cloneTable(v)
		else
			newT[k] = v
		end
	end
	return newT
end

--[[
打印table

local t = {
	name = 1,
	info = {
		age=2,
		level={1, 2, 3},
		nickName="eee",
		args={},
		func=function()
		end
	}
}
==>
printTable(t, “”)

name=1,
info={
  args={
  },
  age=2,
  level={
    1=1,
    2=2,
    3=3,
  },
  func=function: 0051AFD0,
  nickName="eee",
},
]]
function printTable(t, offset)
	for k, v in pairs(t) do
		if "table" == type(v) then
			print(offset..k.."={")
			printTable(v, offset.."  ")
			print(offset.."},")
		elseif "string" == type(v) then
			print(offset..k..'="'..v..'",')
		else
			print(offset..k.."="..tostring(v)..",")
		end
	end
end

--[[
@brief 检测文件是否存在
@example isFileExist("fileName.lua")
]]
function isFileExist(filePath)
	local f = io.open(filePath, "r")
	if f then
		io.close(f)
		return true
	end
	return false
end
