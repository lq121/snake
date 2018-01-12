-- 创建一个蛇
local Body = class("Body")

function Body:ctor(snake,x,y,node,isHead)
	-- body
	self.snake = snake
	self.x = x
	self.y = y
	-- 根据是否为头部，创建不同的图片
	if isHead then
		self.sp = cc.Sprite:create("res/head.png");
	else
		self.sp = cc.Sprite:create("res/body.png");
	end
	node:addChild(self.sp)
	self:Update()
end


-- 更新自己的位置
function Body:Update()
	-- body
	local posx,posy = Grid2Pos(self.x,self.y)
	self.sp:setPosition(posx,posy)
end


return Body