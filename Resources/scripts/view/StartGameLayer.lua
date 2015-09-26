--@brief 开始游戏界面

local StartGameLayer = class("StartGameLayer", function()
	return CCLayer:create()
end) 

function StartGameLayer:init()
	local arrowSprite = CCSprite:create("ui/GameStartBackground.png")
    arrowSprite:setPosition(CENTER_X, CENTER_Y)
    self:addChild(arrowSprite)

    local topSprite = CCSprite:create("ui/sprite1.png")
    topSprite:setPosition(250, 340)
    self:addChild(topSprite)

    local leftSprite = CCSprite:create("ui/sprite2.png")
    leftSprite:setPosition(100, 100)
    self:addChild(leftSprite)

    local rightSprite = CCSprite:create("ui/sprite1.png")
    rightSprite:setPosition(WIDTH-100, 100)
    self:addChild(rightSprite)

    --暂停按钮
    local  spriteStartGameButtonNormal  = CCSprite:create("ui/StartGameButton.png")
    local  spriteStartGameSelected = CCSprite:create("ui/StartGameButton.png")
    spriteStartGameSelected:setColor(ccc3(30,50,50))
    local  spriteStartGameDisabled = CCSprite:create("ui/StartGameButton.png")
    spriteStartGameDisabled:setColor(ccc3(30,50,50))
    local  menuItemStartGame = CCMenuItemSprite:create(spriteStartGameButtonNormal, spriteStartGameSelected, spriteStartGameDisabled)
    menuItemStartGame:registerScriptTapHandler(function()
    	--移除开始游戏界面
    	self:getParent():removeChild(self, true)
   	    --运行游戏界面
   	    local GameLayer = require("scripts.view.GameLayer")
	    local layer = GameLayer:create()
	    CCDirector:sharedDirector():getRunningScene():addChild(layer)
    end)
    --menuItemStartGame:setScale(0.6)
    menuItemStartGame:setPosition(CENTER_X, CENTER_Y-40)
    local arr = CCArray:create()
    arr:addObject(menuItemStartGame)
    local menu = CCMenu:createWithArray(arr)
    menu:setPosition(0, 0)
    self:addChild(menu)

    -- self:registerScriptKeypadHandler(function(strEvent)
    --     print(strEvent)
    --     if "backClicked" == strEvent then
    --         print("backClicked")
    --         CCDirector:sharedDirector():endTolua()
    --     end
    -- end)

end

return StartGameLayer