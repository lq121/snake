local Snake = require("app.scenes.Snake")
local Fence = require("app.scenes.Fence")
local AppleFactory = require("app.scenes.AppleFactory")
local JoyRocker = require("app.scenes.JoyRocker")

local cGridSize = 33*2
local scaleRate = 1 / display.contentScaleFactor 
local cMoveSpeed = 0.3
local rowBound = 8
local colBound = 10

local MainScene = class("MainScene", function()
	return display.newScene("MainScene")
	end)

-- 坐标转换，根据自定义坐标得到实际应该显示的cocos2d-x坐标位置
function Grid2Pos(x,y)
	-- body
	local visibleSize = cc.Director:getInstance():getVisibleSize() -- 手机屏幕尺寸
	local origin = cc.Director:getInstance():getVisibleOrigin() -- 手机原点坐标

	local finalX = origin.x + visibleSize.width * 0.5 + x * cGridSize * scaleRate
	local finalY = origin.y + visibleSize.height * 0.5 + y * cGridSize * scaleRate
	return finalX,finalY
end

function MainScene:ctor()
	cc.LayerColor:create(cc.c4b(120, 135, 156, 255)):addTo(self)
end

function MainScene:CreateScoreBoard()
	display.newSprite("res/applesign.png")
	:setPosition(display.right - 80,display.cy + 150)
	:addTo(self)

	
	local ttfConfig = {}
	ttfConfig.fontFilePath = "res/Arial.ttf"
	ttfConfig.fontSize = 30
	local score  = cc.Label:createWithTTF(ttfConfig,"0")
	self:addChild(score)
	score:setPosition(display.right - 80,display.cy + 80)
	self.scoreLabel = score
end

-- 设置分数
function MainScene:SetScore(s)
	self.scoreLabel:setString(string.format("%d",s))
end

function MainScene:onEnter()
	self.joyRocker = JoyRocker:new():addTo(self)
	self.joyRocker:initTouch(function(dir)
	self.snake:setDir(dir)
		end)
	self:ProcessKeyInput() -- 键盘touch事件
	-- self:ProcessInput() -- 鼠标touch事件	-- 创建一条蛇
	self:CreateScoreBoard()
	self:Reset()
	
	local tick = function()
	if self.stage == "running" then
		self.snake:Update()

		local headX,headY = self.snake:GetHeadGrid()
		if self.fence:CheckCollide(headX,headY) or self.snake:CheckCollideSelf() then
			self.stage = "dead"
			self.snake:Blink(function ( )
				-- body
				self:Reset()
				end)
			elseif self.apple:CheckCollide(headX,headY) then
			self.apple:Generate() -- 产生新苹果
			self.snake:Grow()-- 蛇变长
			self.score = self.score + 1
			self:SetScore(self.score)
		end
	end
end
cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick,cMoveSpeed,false)
end

function MainScene:onExit()
end

local function vector2Dir(x,y)
	-- body
	if math.abs(x) > math.abs(y) then
		if x < 0 then
			return "left"
		else
			return "right"
		end
	else
		if y > 0 then
			return "up"
		else
			return "down"
		end
	end
end


-- 鼠标控制
-- function MainScene:ProcessInput()
-- 	self:setTouchEnabled(true)
-- 	-- body
-- 	local function onTouchMoved(touch, event)
-- 		dump(event)
-- 		-- print("$$$$$$",event)
-- 		-- local dir = self.joyRocker:getCurrentDriation()
-- 		-- print("***********",dir)
-- 	end

-- local listener = cc.EventListenerTouchOneByOne:create()
-- listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
-- local eventDispatcher = self:getEventDispatcher()
-- eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

-- end

-- 键盘控制
function MainScene:ProcessKeyInput( )
	local function keyboardPressed(keyCode,evnet)
		if keyCode == 28 or keyCode == 146 then
			self.snake:setDir("up")
		elseif keyCode == 29 or keyCode == 142 then
				self.snake:setDir("down")
		elseif keyCode == 26 or keyCode == 124 then
				self.snake:setDir("left")
		elseif keyCode == 27 or keyCode == 127 then
				self.snake:setDir("right")
		elseif keyCode == 139 then
				cc.Director:getInstance():pause()
		elseif keyCode == 141 then
				cc.Director:getInstance():resume()
		end
	end

	local listener = cc.EventListenerKeyboard:create()
	listener:registerScriptHandler(keyboardPressed,cc.Handler.EVENT_KEYBOARD_PRESSED)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end


-- 游戏结束
function MainScene:Reset()
	if self.apple ~= nil then
		self.apple:Reset()
	end
	if self.snake ~= nil then
		self.snake:Kill()
	end

	if self.fence ~= nil then
		self.fence:Reset()
	end

	self.snake = Snake.new(self)
	self.fence = Fence.new(rowBound,colBound,self)
	self.stage = "running"
	self.apple = AppleFactory.new(rowBound,colBound,self)
	self.score = 0
	self:SetScore(self.score)
end


return MainScene















