local JoyRocker = class("JoyRocker", function ()
    -- body
    return display.newLayer()
end)

function JoyRocker:ctor()
    -- self.node = node
    self.rocker_radius = 50.0
    self.rodker_vec = cc.p(0,0)
    self:initUI()
    -- self:initTouch()
    print(self.rocker_vec)
    -- 用于标识摇杆8个方向
    self.tagDirecton = {
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
self.dir = ""

-- 判断控制杆方向，用来判断精灵上、下、左、右运动
self.rocketDirection = nil

-- const PI
self.PI = 3.1415
end
--初始化点击事件
function JoyRocker:initTouch(callBack)
    -- body
    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)

        --printf("touch:%s Pos:(%0.2f,%0.2f)",event.name,event.x,event.y)
        if event.name == "began" then
            --todo
            self:touchBegan(event)
            return true
        elseif event.name == "moved" then
            --todo
            self:touchMoved(event)
            callBack(self.dir)
        elseif event.name == "ended" then
            --todo
            self:touchEnded(event)
        end

    end)
end

function JoyRocker:initUI()
    -- body
    
    self.rockerBg = display.newSprite("Direction_bc.png")
    self.rocker = display.newSprite("Direction_bt.png")
    self.rockerBg:setPosition(cc.p(200,200))
    self.rocker:setPosition(cc.p(200,200))
     self.rockerBg:setVisible(true)
    self.rocker:setVisible(true)
    self:addChild(self.rockerBg)
    self:addChild(self.rocker)
end


--[[
    点击事件的回调函数
]]
function JoyRocker:touchBegan(event)
    -- body
    --print("touch began")
    -- self:showRocker(event.x,event.y)
end

function JoyRocker:touchMoved(event,callBack)
    -- body
    --print("touch moved")
    self:refreshRocker(event.x, event.y)

    --判断四个方向
-- 得到摇杆与触屏点所形成的角度
local angle = self:getRad(cc.p(self.rockerBg:getPositionX(),self.rockerBg:getPositionY()), cc.p(event.x, event.y))

if angle >= -self.PI/4 and angle < self.PI/4 then
 self.rocketDirection = self.tagDirecton.rocker_right
 self.dir = "right"
elseif angle >= self.PI/4 and angle < 3 * self.PI/4 then
 self.rocketDirection = self.tagDirecton.rocker_up
self.dir = "up"
elseif (angle >= (3 * self.PI/4) and angle <= self.PI) or (angle >= -self.PI and angle < (-3 * self.PI/4) ) then
 self.rocketDirection = self.tagDirecton.rocker_left;
 self.dir = "left"
elseif angle >= -3 * self.PI/4 and angle < -self.PI/4 then
 self.rocketDirection = self.tagDirecton.rocker_down;
 self.dir = "down"
end


end



-- 获取当前摇杆与用户触屏点的角度
function JoyRocker:getRad( pos1, pos2 )

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


function JoyRocker:refreshRocker(x,y)
    -- body
    local bg_x = self.rockerBg:getPositionX()
    local bg_y = self.rockerBg:getPositionY()
    if cc.pGetDistance(cc.p(bg_x,bg_y),cc.p(x,y)) <= self.rocker_radius then
        --todo
        self.rocker:setPosition(x,y)
    else
        --todo
        local dis = cc.pGetDistance(cc.p(bg_x,bg_y),cc.p(x,y))
        local a = self.rocker_radius
        local b = dis - a
        local c = math.abs(y - bg_y)
        local d = a * c /(a + b)
        local e = math.sqrt(a^2-d^2)
        local aim_x = 0.0
        local aim_y = 0.0
        if bg_x == x or bg_y == y then
            --todo
            if bg_x == x then
                --todo
                aim_x = bg_x
                aim_y = y > bg_y and bg_y + self.rocker_radius or bg_y - self.rocker_radius
            elseif bg_y == y then
                --todo
                aim_x = x > bg_x and bg_x + self.rocker_radius or bg_x - self.rocker_radius
                aim_y = bg_y
            end
        else
            --todo
            if x > bg_x and y > bg_y then
                --第一象限
                aim_x = bg_x + e
                aim_y = bg_y + d
            elseif x < bg_x and y > bg_y then
                --第二象限
                aim_x = bg_x - e
                aim_y = bg_y + d
            elseif x < bg_x and y < bg_y then
                --第三象限
                aim_x = bg_x - e
                aim_y = bg_y - d
            elseif x > bg_x and y < bg_y then
                --第四象限
                aim_x = bg_x + e
                aim_y = bg_y - d
            end
        end
        self.rocker:setPosition(aim_x,aim_y)
    end
end

-- function JoyRocker:hideRocker()
--     -- body
--     self.rockerBg:setVisible(false)
--     self.rocker:setVisible(false)
--     self.rockerBg:setPosition(display.cx,display.cy)
--     self.rocker:setPosition(display.cx,display.cy)
-- end

function JoyRocker:touchEnded( event )
    -- body
    --print("touch ended")
    -- self:hideRocker()
end

--[[
显示摇杆
]]
-- function JoyRocker:showRocker(x,y)
--     -- body
--     self.rockerBg:setVisible(true)
--     self.rocker:setVisible(true)
--     self.rockerBg:setPosition(x,y)
--     self.rocker:setPosition(x,y)
-- end
--[[
隐藏摇杆
]]


return JoyRocker
