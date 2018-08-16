
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    self.map = cc.TMXTiledMap:create("map.tmx")
	:align(display.BOTTOM_LEFT, display.left, display.bottom):setAnchorPoint(cc.p(0,0))
	:addTo(self)
	self.layer = display.newLayer()
    self.layer:addNodeEventListener(cc.KEYPAD_EVENT,handler(self,self.testKeypad))
    self:addChild(self.layer)
    self.layer:setKeypadEnabled(true)
	self.player = display.newSprite("player.png"):addTo(self,2):pos(display.cx,display.cy):setAnchorPoint(cc.p(0,0))
	self:loadMap()
end

function MainScene:loadMap()
	local players = self.map:getObjectGroup("players")
	local startPoint = players:getObject('startPoint')
    local endPoint = players:getObject('endPoint')
    local startPos = cc.p(startPoint.x, self:getContentSize().height-startPoint.y-32)
    local endPos = cc.p(endPoint.x, self:getContentSize().height - endPoint.y-65)
    self.barriers = self.map:getLayer('barriers')
    self.stars = self.map:getLayer('stars')
    self.playerTile = self:getTilePos(startPos);
    self.endTile = self:getTilePos(endPos);
    self:updatePlayerPos()
end

function MainScene:updatePlayerPos()
	local pos = self.barriers:getPositionAt(self.playerTile)
    self.player:setPosition(pos)
end

function MainScene:testKeypad(event)
	local  newTile = cc.p(self.playerTile.x, self.playerTile.y)
	if event.type == "Pressed" then
		if event.key == "26" then
			newTile.x = newTile.x - 1
		elseif event.key == "27" then
			newTile.x = newTile.x + 1
		elseif event.key == "28" then
			newTile.y = newTile.y - 1
		elseif event.key == "29" then
			newTile.y = newTile.y + 1
		end	
		self:tryMoveToNewTile(newTile) 
	end
end 

function MainScene:tryMoveToNewTile(newTile) 
    local width = self.map:getMapSize().width;
    local height = self.map:getMapSize().height;
    if newTile.x < 0 or newTile.x >= width then return end
    if newTile.y < 0 or newTile.y >= height then return end
    if self.barriers:getTileGIDAt(newTile) ~= 0 then
        print('This way is blocked!')
        return false;
    end
    self:tryCatchStar(newTile)
    self.playerTile = newTile
    self:updatePlayerPos()

    if self.playerTile.x == self.endTile.x and self.playerTile.y == self.endTile.y then
    	print("------------------succed-------------")
   	end
end

function MainScene:getTilePos(posInPixel) 
    local  mapSize = self:getContentSize()
    local tileSize = self.map:getTileSize()
    local x = math.floor(posInPixel.x / tileSize.width)
    local y = math.floor(posInPixel.y / tileSize.height)
    return cc.p(x, y);
 end	

function  MainScene:tryCatchStar(newTile)
    local GID = self.stars:getTileGIDAt(newTile);
    local prop = self.map:getPropertiesForGID(GID);
    if self.stars:getTileGIDAt(newTile) ~= 0 then
        self.stars:removeTileAt(newTile)
    end
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
