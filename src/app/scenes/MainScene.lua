
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    self.NpcList = {}
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
    local endPos = cc.p(endPoint.x, self:getContentSize().height - endPoint.y)
    self.barriers = self.map:getLayer('barriers')   --障碍
    self.stars = self.map:getLayer('stars')   --星星道具
    self.playerTile = self:getTilePos(startPos);
    self.endTile = self:getTilePos(endPos);
    self:updatePlayerPos()
    self:loadNpc()
end

function MainScene:updatePlayerPos()
	local pos = self.barriers:getPositionAt(self.playerTile)
    dump(pos)
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

function MainScene:loadNpc()
    local Npc = self.map:getObjectGroup('NPC')
    for k,v in pairs(Npc:getObjects()) do
        local pos1 = self:getTilePos(cc.p(v.x+32,self:getContentSize().height- 32 -v.y))
        local pos2 = self.barriers:getPositionAt(pos1)
        local npc = display.newSprite("Npc.png"):setPosition(pos2):addTo(self,2):setAnchorPoint(cc.p(0,0)):setName(v.name)
        table.insert(self.NpcList, npc)
    end
end

function MainScene:tryMoveToNewTile(newTile) 
    local width = self.map:getMapSize().width;
    local height = self.map:getMapSize().height;
    if newTile.x < 0 or newTile.x >= width then return end
    if newTile.y < 0 or newTile.y >= height then return end
    if self.barriers:getTileGIDAt(newTile) ~= 0 then
        -- print('This way is blocked!')
        return false;
    end
    
    self:tryCatchStar(newTile)
    self.playerTile = newTile
    self:updatePlayerPos()
    print(self.player:getPositionX(),self.player:getPositionY())
    for k,v in pairs(self.NpcList) do
        if math.abs(self.player:getPositionX() - v:getPositionX()) ==0 and math.abs(self.player:getPositionY() - v:getPositionY()) ==0 then
            if v:getName() == 'NPC1' then
                self:talkNpc(1)
            elseif v:getName() == 'NPC2' then
                self:talkNpc(2)
            elseif v:getName() == 'NPC3' then
                self:talkNpc(3)
            end
        end
    end
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

function MainScene:talkNpc(index)
    print("talk--------",index)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
