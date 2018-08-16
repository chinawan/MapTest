if not scheduler then scheduler = require("framework.scheduler") end   
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)
local ReSetPos ={{1,0},{-1,0},{0,1},{0,-1}}
function MainScene:ctor()
    self.NpcList = {}
    self.EmemyPropertyList= {}
    self.EmemyList= {}
    self.map = cc.TMXTiledMap:create("map.tmx")
	:align(display.BOTTOM_LEFT, display.left, display.bottom):setAnchorPoint(cc.p(0,0))
	:addTo(self)
	self.layer = display.newLayer()
    self:addChild(self.layer)
    
    self.PreKeyBoard = 0  --获取最后一个按键
	self.player = display.newSprite("player.png"):addTo(self,2):pos(display.cx,display.cy):setAnchorPoint(cc.p(0,0))
	self:loadMap()
    self:getKeyBoradListen()
end

function MainScene:loadMap()
    local players = self.map:getObjectGroup("players")
    self.MaxLife = players:getProperty("life")
    self.myLife = players:getProperty("life")
    self.myAttack = players:getProperty("attack")
	local startPoint = players:getObject('startPoint')
    local endPoint = players:getObject('endPoint')
    local startPos = cc.p(startPoint.x, self:getContentSize().height-startPoint.y-32)
    local endPos = cc.p(endPoint.x, self:getContentSize().height - endPoint.y -32)
    self.barriers = self.map:getLayer('barriers')   --障碍
    self.stars = self.map:getLayer('stars')   --星星道具
    self.attackProp = self.map:getLayer('attack')  --增加攻击力
    self.playerTile = self:getTilePos(startPos);
    self.endTile = self:getTilePos(endPos);
    dump(self.playerTile)
    dump(self.endTile)
    self:updatePlayerPos()
    self:loadNpc()
    self:loadEmemy()
end

function MainScene:updatePlayerPos()
	local pos = self.barriers:getPositionAt(self.playerTile)
    self.player:setPosition(pos)
end

function MainScene:loadNpc()
    local Npc = self.map:getObjectGroup('NPC')
    for k,v in pairs(Npc:getObjects()) do
        local pos1 = self:getTilePos(cc.p(v.x+32,self:getContentSize().height- 32 -v.y))
        local pos2 = self.barriers:getPositionAt(pos1)
        local npc = display.newSprite("Npc.png"):setPosition(pos2):addTo(self,2):setAnchorPoint(cc.p(0,0))
        pos1.name = v.name
        table.insert(self.NpcList, pos1)
    end
end

function MainScene:loadEmemy()
    local Ememy = self.map:getObjectGroup('Enemy')
    for k,v in pairs(Ememy:getObjects()) do
        local pos1 = self:getTilePos(cc.p(v.x+32,self:getContentSize().height- 32 -v.y))
        local pos2 = self.barriers:getPositionAt(pos1)
        local em = display.newSprite("Am.png"):setPosition(pos2):addTo(self,2):setAnchorPoint(cc.p(0,0))
        pos1.name = v.name
        pos1.life = v.life
        pos1.attack = v.attack
        table.insert(self.EmemyPropertyList, pos1)
        table.insert(self.EmemyList,em)
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
    self:tryCatchAttack(newTile)
    self.playerTile = newTile
    self:talkNpc()
    self:attackEmeny()
    self:updatePlayerPos()
    self:isEnd()
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
        self.myLife = self.myLife + 50
        if tonumber(self.myLife) > tonumber(self.MaxLife) then
            self.myLife = self.MaxLife
        end
        print("--------myLife",self.myLife)
        self.stars:removeTileAt(newTile)
    end
end

function  MainScene:tryCatchAttack(newTile)
    local GID = self.attackProp:getTileGIDAt(newTile);
    local prop = self.map:getPropertiesForGID(GID);
    if self.attackProp:getTileGIDAt(newTile) ~= 0 then
        self.myAttack = self.myAttack + 5
        print("--------myAttack",self.myAttack)
        self.attackProp:removeTileAt(newTile)
    end
end

function MainScene:isEnd()
    if self.playerTile.x == self.endTile.x and self.playerTile.y == self.endTile.y then
        print("------------------succed-------------")
    end
end

function MainScene:talkNpc()
    for k,v in pairs(self.NpcList) do
        if  v.x - self.playerTile.x == 0 and v.y-self.playerTile.y == 0 then
            self.playerTile.x = self.playerTile.x + ReSetPos[self.PreKeyBoard][1]
            self.playerTile.y = self.playerTile.y + ReSetPos[self.PreKeyBoard][2]
            print("--------talk with ",v.name)
            return false
        end
    end
end

function MainScene:attackEmeny()
    for k,v in pairs(self.EmemyPropertyList) do
        if  v.x - self.playerTile.x == 0 and v.y-self.playerTile.y == 0 then
            self:closeKeyBoradListen()
            self.playerTile.x = self.playerTile.x + ReSetPos[self.PreKeyBoard][1]
            self.playerTile.y = self.playerTile.y + ReSetPos[self.PreKeyBoard][2]
            print("attack with",v.name)
            self:attackEffect(v,k)
            return false
        end
    end
end

function MainScene:testKeypad(event)
    local  newTile = cc.p(self.playerTile.x, self.playerTile.y)
    if event.type == "Pressed" then
        if event.key == "26" then
            newTile.x = newTile.x - 1
            self.PreKeyBoard = 1
        elseif event.key == "27" then
            newTile.x = newTile.x + 1
            self.PreKeyBoard = 2
        elseif event.key == "28" then
            newTile.y = newTile.y - 1
            self.PreKeyBoard = 3
        elseif event.key == "29" then
            newTile.y = newTile.y + 1
            self.PreKeyBoard = 4
        end 
        self:tryMoveToNewTile(newTile) 
    end
end 

--getKeyBoardListen
function MainScene:getKeyBoradListen()
    print("---------get KeyBoard")
    self.layer:addNodeEventListener(cc.KEYPAD_EVENT,handler(self,self.testKeypad))
    self.layer:setKeypadEnabled(true)
end

--closeKeyBoardListen
function MainScene:closeKeyBoradListen()
    self.layer:removeAllNodeEventListeners()
end

function MainScene:attackEffect(emenyProperty,emeny)
    dump(emenyProperty)
    local Attackschedule 
    Attackschedule = scheduler.scheduleGlobal(function(dt)
        self.myLife = self.myLife - emenyProperty.attack
        emenyProperty.life = emenyProperty.life - self.myAttack
        print("my life",self.myLife)
        print("emeny life",emenyProperty.life)
    if self.myLife <= 0 or emenyProperty.life <= 0 then
        scheduler.unscheduleGlobal(Attackschedule)
        print(self.myLife > 0 and "emeny is died ,delete enemy" or "you are died,game over") 
        if self.myLife > 0 then
            self:getKeyBoradListen()
            self.EmemyList[emeny]:removeFromParent()
            table.remove(self.EmemyList,emeny)
            table.remove(self.EmemyPropertyList,emeny)
        end
    end
    end, 1)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
