local Fence = class("Fence")
		
function Fence:fenceGenerator(node,bound,callback)
	for i = -bound,bound do
		local  sp = cc.Sprite:create("res/fence.png")
		local posx,posy = callback(i)
		sp:setPosition(posx,posy)
		node:addChild(sp)
		-- 插入蛇精灵的数组
		 table.insert(self.fenceSpArray,sp)
	end
end

function Fence:ctor(rowBound,colBound,node)
	self.rowBound = rowBound -- 屏幕中心往上往下有几个格子
	self.colBound = colBound -- 屏幕中间往左往右有几个格子
	self.node = node 
	self.fenceSpArray = {}
	-- print("======>>>>"..self.fenceSpArray)

	self:fenceGenerator(node,colBound,function (i)
		return Grid2Pos(i, rowBound)
	end)

	self:fenceGenerator(node,colBound,function (i)
		return Grid2Pos(i, -rowBound)
	end)

	self:fenceGenerator(node,rowBound,function (i)
		return Grid2Pos(colBound, i)
	end)

	self:fenceGenerator(node,rowBound,function (i)
		return Grid2Pos(-colBound, i)
	end)

end

-- 判断是否与围墙相撞
function Fence:CheckCollide(x,y)
	return x == self.colBound or x == - self.colBound or y == self.rowBound or y == - self.rowBound
end

function Fence:Reset( )
	for _,sp in ipairs(self.fenceSpArray)do
		self.node:removeChild(sp)
	end
end


return Fence