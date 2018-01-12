local HRocker = class("HRocker", function ( )
	-- body
	return display.newLayer("HRocker")
	end)


function HRocker:ctor( )
	-- 用于标识摇杆与摇杆背景
	self.tagForHRcoker = {
	tag_rocker = 0,
	tag_rockerBG = 1
}

	-- 用于标识摇杆8个方向
	self.tagDirection = {
	rocker_stay = 0,
	rocker_right = 1,
	rocker_up = 2,
	rocker_left = 3,
	rocker_down = 4,
	rocker_left_up = 5,
	rocker_left_down = 6,
	rocker_right_up = 7,
	rocker_right_down = 8
}

-- 判断控制杆方向，用来判断精灵上、下、左、右运动
self.rocketDirection = nil
-- 是否可操作摇杆
self.isCanMove = false
-- 摇杆背景的坐标
self.rockerBGPosition = nil
-- const PI
self.PI = 3.1415

end


function HRcoker:createHRocker(node,position,rockerImageName,rockerBGImage)
	local layer = HRocker:new()
	if layer then
		layer:rockerInit(rockerImageName,rockerBGImageName,position)
		return layer
	end
	return  nil
end


-- privete 
-- 自定义初始化函数 ， 1 按钮，  2 背景图
function HRocker:rockerInit( rockerImageName, rockerBGImageName, position )
	local spRockerBG = display.newSprite(rockerBGImageName)
	spRockerBG:setPosition( position )
	self:addChild(spRockerBG, 0, self.tagForHRocker.tag_rockerBG)
	spRockerBG:setVisible(false)
	local spRocker = display.newSprite(rockerImageName)
	spRocker:setPosition( position )
	self:addChild(spRocker, 1, self.tagForHRocker.tag_rocker)
	spRocker:setVisible(false)
	self.rockerBGPosition = position
	self.rockerBGR = spRockerBG:getContentSize().width * 0.3
-- 表示摇杆方向不变
self.rocketDirection = self.tagDirecton.rocker_stay

end


-- 启动摇杆(显示摇杆、监听摇杆触屏事件)
function HRocker:startRocker( _isStopOther )
	local rocker = self:getChildByTag(self.tagForHRocker.tag_rocker)
	rocker:setVisible(true)
	local rockerBG = self:getChildByTag(self.tagForHRocker.tag_rockerBG)
	rockerBG:setVisible(true)
-- 这里开启了点击事件
self:setTouchEnabled(true)
self.touchId = self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.addTouchEvent))
self:setTouchSwallowEnabled(true)
end

-- 停止摇杆（隐藏摇杆， 取消摇杆的触屏监听）
function HRocker:stopRocker()
	local rocker = self:getChildByTag(self.tagForHRocker.tag_rocker)
	rocker:setVisible(false)
	local rockerBG = self:getChildByTag(self.tagForHRocker.tag_rockerBG)
	rockerBG:setVisible(false)
-- 这里移除了点击事件
self:removeNodeEventListener(self.touchId)

end


-- 获取当前摇杆与用户触屏点的角度
function HRocker:getRad( pos1, pos2 )

	local px1 = pos1.x
	local py1 = pos1.y

	local px2 = pos2.x
	local py2 = pos2.y

-- 得到两点x的距离
local x = px2 - px1
-- 得到两点y的距离 
local y = py1 - py2
-- 算出斜边的长度
local xie = math.sqrt(math.pow(x, 2) + math.pow(y, 2))
-- 得到这个角度的余弦值（通过三角函数中的定里：角度余弦值 ＝ 斜边/斜边
local cosAngle = x / xie
-- 通过反余弦定理获取到期角度的弧度
local rad = math.acos(cosAngle)
-- 注意：当触屏的位置Y坐标<摇杆的Y坐标，我们要去反值-0~-180
if py2 < py1 then
	rad = -rad
end
return rad
end


function HRocker:getAngelePosition( r, angle )

-- ccp( r *      cos( angle ), r *      sin(angle));
return cc.p( r * math.cos( angle ), r * math.sin(angle))

end

function HRocker:addTouchEvent( event )

	local x, y = event.x, event.y
	local location = cc.p(x, y)
	if event.name == "began" then
		local isBool = self:touchBegan(location)
		return isBool
		elseif event.name == "moved" then
			self:touchMoved(location)
			elseif event.name == "ended" then
			self:touchEnded(location)
		end
	end

-- 抬起事件
function HRocker:touchBegan( _pTouch )
	local point = _pTouch
	local rocker = self:getChildByTag(self.tagForHRocker.tag_rocker)
	if cc.rectContainsPoint(rocker:getBoundingBox(), point) then
		self.isCanMove = true
	end
	return true
end


-- 移动事件
function HRocker:touchMoved( _pTouch )
	if not self.isCanMove then
		return
	end
	local point = _pTouch
	local rocker = self:getChildByTag(self.tagForHRocker.tag_rocker)
-- 得到摇杆与触屏点所形成的角度
local angle = self:getRad(self.rockerBGPosition, point)

-- 两个圆的圆心距
local kf = math.sqrt(math.pow( self.rockerBGPosition.x - point.x, 2) + math.pow( self.rockerBGPosition.y - point.y, 2))

-- 判断两个圆的圆心距是否大于摇杆背景的半径
if kf >= self.rockerBGR then
-- 保证内部小圆运动的长度限制
rocker:setPosition(cc.pAdd(self:getAngelePosition(self.rockerBGR, angle), cc.p(self.rockerBGPosition.x, self.rockerBGPosition.y)))
else
-- 当没有超过，让摇杆跟随用户触屏点移动即可
rocker:setPosition(point)

end


-- 判断八个方向 


-- local rockerBG = self:getChildByTag(self.tagForHRocker.tag_rockerBG)
-- local p_dian = {x = rockerBG:getPositionX(), y = rockerBG:getPositionY()}


-- local move_x = p_dian.x - point.x
-- local move_y = p_dian.y - point.y


-- -- printf("movex == %f, movey == %f", move_x, move_y)


-- if move_x >= 10 and move_y <= -10 then
-- --左上
-- self.rocketDirection = self.tagDirecton.rocker_left_up
-- -- print("左上 左上 左上 左上 左上 左上 左上 左上")
-- self.rocketRun = true


-- elseif move_x >= 10 and move_y >= 10 then
-- -- 左下
-- self.rocketDirection = self.tagDirecton.rocker_left_down
-- -- print("左下 左下 左下 左下 左下 左下 左下 左下")
-- self.rocketRun = true


-- elseif move_x <= -10 and move_y <= -10 then
-- -- 右上
-- self.rocketDirection = self.tagDirecton.rocker_right_up
-- -- print("右上 右上 右上 右上 右上 右上 右上 右上")
-- self.rocketRun = false


-- elseif move_x <= -10 and move_y >= 10 then
-- -- 右下
-- self.rocketDirection = self.tagDirecton.rocker_right_down
-- -- print("右下 右下 右下 右下 右下 右下 右下 右下")
-- self.rocketRun = false


-- elseif move_x > -10 and move_x < 10 and move_y > 0 then
-- -- 下
-- self.rocketDirection = self.tagDirecton.rocker_down
-- -- print("下 下  下  下  下  下  下  下  下  下  下 ")


-- elseif move_x > -10 and move_x < 10 and move_y < 0 then
-- -- 上
-- self.rocketDirection = self.tagDirecton.rocker_up
-- -- print("上 上 上 上  上 上  上 上  上 上  上 上 上")


-- elseif move_x > 0 and move_y > -10 and move_y < 10 then
-- -- 左
-- self.rocketDirection = self.tagDirecton.rocker_left
-- -- print("左 左 左 左 左 左 左 左 左 左 左 左 左 左 左")
-- self.rocketRun = true


-- elseif move_x < 0 and move_y > -10 and move_y < 10 then
-- -- 右
-- self.rocketDirection = self.tagDirecton.rocker_right
-- -- print("右 右 右 右 右 右 右 右 右 右 右 右 右 右 右")
-- self.rocketRun = false


-- end




--判断四个方向


if angle >= -self.PI/4 and angle < self.PI/4 then

 self.rocketDirection = self.tagDirecton.rocker_right
 self.rocketRun = false


elseif angle >= self.PI/4 and angle < 3 * self.PI/4 then


 self.rocketDirection = self.tagDirecton.rocker_up


elseif (angle >= (3 * self.PI/4) and angle <= self.PI) or (angle >= -self.PI and angle < (-3 * self.PI/4) ) then

 self.rocketDirection = self.tagDirecton.rocker_left;
        self.rocketRun = true


elseif angle >= -3 * self.PI/4 and angle < -self.PI/4 then


 self.rocketDirection = self.tagDirecton.rocker_down;


end


end


-- 离开事件
function HRocker:touchEnded( _pTouch )


	if not self.isCanMove then
		return
	end


	local rockerBG = self:getChildByTag(self.tagForHRocker.tag_rockerBG)
	local rocker = self:getChildByTag(self.tagForHRocker.tag_rocker)


	rocker:stopAllActions()


	transition.moveTo(rocker, { x = rockerBG:getPositionX(), y = rockerBG:getPositionY(), time = 0.08 })


	self.isCanMove = false
	self.rocketDirection = self.tagDirecton.rocker_stay
end



return HRocker