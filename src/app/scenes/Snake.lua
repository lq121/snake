-- 创建一个蛇类
local Body = require("app.scenes.Body")
local Snake = class("Snake")

local cInitLen = 3 -- 初始化蛇长度为3

function Snake:ctor(node)
 	-- body
 	self.BodyArray = {} -- body对象数组
 	self.node = node
 	self.MoveDir = "left" -- 初始化移动方向

 	for i=1,cInitLen do
 		self:Grow(i == 1)
 	end
 end 

 -- 获取蛇尾
 function Snake:GetTailGrid(  )
 	-- body
 	if #self.BodyArray == 0 then -- 蛇头的位置
 		--todo
 		return 0,0
 	end
 	local tail = self.BodyArray[#self.BodyArray]
 	return tail.x,tail.y
 end


 -- 蛇变长
 function Snake:Grow( isHead)
 	-- body
 	local tailX,tailY = self:GetTailGrid()
 	local body = Body.new(self,tailX,tailY,self.node,isHead)
 	table.insert(self.BodyArray,body)
 end

 -- 根据方向更改坐标
 local function OffsetGridByDir( x,y,dir)
 	-- body
 	if dir == "left" then
 		return x-1,y
 	elseif dir == "right" then
 		return x+1,y
 	elseif dir == "up" then
 		return x,y+1
 	elseif dir == "down" then
 		return x,y-1
 	end
 	print("unkonw dir",dir)
 	return x,y
end
 	

 -- 根据蛇移动，更新蛇
 function Snake:Update()
 	if #self.BodyArray == 0 then
 		return
 	end
 	for i=#self.BodyArray,1,-1 do
 		local body = self.BodyArray[i]
 		if i == 1 then -- 设置蛇头方向，得到一个新位置
 			body.x,body.y = OffsetGridByDir(body.x,body.y,self.MoveDir)
 		else
 			local front = self.BodyArray[i - 1]
 			body.x,body.y = front.x,front.y
 		end
 		body:Update();
 	end
 end

 -- 取出蛇头
 function Snake:GetHeadGrid(  )
 	if #self.BodyArray == 0 then
 		return nil
 	end

 	local head = self.BodyArray[1]
 	return head.x,head.y
 end

-- 设置方向
function Snake:setDir( dir )
	local hvTable = {
	["left"] = "h",
	["right"] = "h",
	["up"] = "v",
	["down"] = "v"
	}
	if hvTable[dir] == hvTable[self.MoveDir] then
		return
		else
			self.MoveDir = dir
			local head = self.BodyArray[1]

			-- 顺时针旋转
			local rotTable = {
			["left"] = 0,
			["up"] = 90,
			["right"] = 180,
			["down"] = -90
		}
		head.sp:setRotation(rotTable[self.MoveDir])
	end
end

-- 碰到自己
function Snake:CheckCollideSelf( )
	if #self.BodyArray < 2 then
		return false
	end

	local headX ,headY = self.BodyArray[1].x, self.BodyArray[1].y
	for i = 2, #self.BodyArray  do
		local body = self.BodyArray[i]

		if body.x == headX and body.y == headY then
			return true
		end
	end
	return false
end

-- 蛇死亡后的效果
function Snake:Blink(callback)
	for index,body in ipairs(self.BodyArray) do
		local blink = cc.Blink:create(3, 5)
		if index == 1 then -- 蛇头
			local a = cc.Sequence:create(blink,cc.CallFunc:create(callback))
			body.sp:runAction(a)
		else
			body.sp:runAction(blink)
		end
	end
end

-- 死亡销毁
function Snake:Kill(  )
	for _,body in ipairs(self.BodyArray) do
		self.node:removeChild(body.sp)
	end
end

return Snake



