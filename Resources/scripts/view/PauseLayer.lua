--@brief 暂停界面

-- local PauseLayer = CCLayer:create()
local PauseLayer = class("PauseLayer", function()
    return CCLayer:create()
end)



function PauseLayer:init()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/plist/Pause.plist")

    local startX = 100
    local spriteP = CCSprite:createWithSpriteFrameName("P.png")
    spriteP:setPosition(startX, CENTER_Y+30)
    self:addChild(spriteP)
    self:setUpAndDownAction(spriteP, 35, 0, 0.3, false)
    
    local spriteA = CCSprite:createWithSpriteFrameName("a.png")
    spriteA:setPosition(startX + 75, CENTER_Y+30)
    self:addChild(spriteA)
	self:setUpAndDownAction(spriteA, 35, 0.1, 0.3, false)

    local spriteU = CCSprite:createWithSpriteFrameName("u.png")
    spriteU:setPosition(startX + 140, CENTER_Y+30)
    self:addChild(spriteU)
	self:setUpAndDownAction(spriteU, 35, 0.2, 0.3, false)

    local spriteS = CCSprite:createWithSpriteFrameName("s.png")
    spriteS:setPosition(startX + 210, CENTER_Y+30)
    self:addChild(spriteS)
	self:setUpAndDownAction(spriteS, 35, 0.3, 0.3, false)

    local spriteE = CCSprite:createWithSpriteFrameName("e.png")
    spriteE:setPosition(startX + 280, CENTER_Y+30)
    self:addChild(spriteE)
	self:setUpAndDownAction(spriteE, 35, 0.4, 0.3, false)

    local spriteDot1 = CCSprite:createWithSpriteFrameName("dot1.png")
    spriteDot1:setPosition(startX + 340, CENTER_Y+30)
    self:addChild(spriteDot1)
	self:setUpAndDownAction(spriteDot1, 35, 0.5, 0.3, true, 0.1)

    local spriteDot2 = CCSprite:createWithSpriteFrameName("dot2.png")
    spriteDot2:setPosition(startX + 385, CENTER_Y+30)
    self:addChild(spriteDot2)
	self:setUpAndDownAction(spriteDot2, 35, 0.6, 0.3, true, 0.2)

    local spriteDot3 = CCSprite:createWithSpriteFrameName("dot3.png")
    spriteDot3:setPosition(startX + 430, CENTER_Y+30)
    self:addChild(spriteDot3)
	self:setUpAndDownAction(spriteDot3, 35, 0.7, 0.3, true, 0.3)


	--播放按钮
    local  spritePlayButtonNormal  = CCSprite:create("ui/PlayButton.png")
    local  spritePlayButtonSelected = CCSprite:create("ui/PlayButton.png")
    spritePlayButtonSelected:setColor(ccc3(50,50,50))
    local  spritePlayButtonDisabled = CCSprite:create("ui/PlayButton.png")
    spritePlayButtonDisabled:setColor(ccc3(50,50,50))
    local  menuItemPause = CCMenuItemSprite:create(spritePlayButtonNormal, spritePlayButtonSelected, spritePlayButtonDisabled)
    menuItemPause:registerScriptTapHandler(function()
    	
        --self:getParent():removeChild(self, true)
        --CCDirector:sharedDirector():getRunningScene():removeChild(self, true)
        sgGameManager:setState(STATE_RESUME)
        self:setVisible(false)
    	self:setTouchEnabled(false)
    end)
    menuItemPause:setScale(0.6)
    menuItemPause:setPosition(CENTER_X, CENTER_Y-80)
    local arr = CCArray:create()
    arr:addObject(menuItemPause)
    local menu = CCMenu:createWithArray(arr)
    menu:setPosition(0, 0)
    self:addChild(menu)



	self:initTouch()
end	



function PauseLayer:setUpAndDownAction(sprite, upDistance, preDelayTime, costTime, isLoop, suffixDelayTime)
    local array = CCArray:create()
    array:addObject(CCDelayTime:create(preDelayTime))
    array:addObject(CCMoveBy:create(costTime, ccp(0, upDistance)))
    array:addObject(CCMoveBy:create(costTime, ccp(0, -upDistance)))
    if isLoop then
    	array:addObject(CCDelayTime:create(suffixDelayTime))
    	sprite:runAction(CCRepeatForever:create(CCSequence:create(array)))
    else
    	sprite:runAction(CCSequence:create(array))
    end
end

--@brief Touch
function PauseLayer:initTouch()
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- --点击音效
            -- AudioEngine.playEffect(SOUND_ICON_CLICK)
            return self:_onTouchBegan(x, y)
        elseif eventType == "moved" then
            return self:_onTouchMoved(x, y)
        else
            return self:_onTouchEnded(x, y)
        end
    end
    self:registerScriptTouchHandler(onTouch, false, -128, true)
    self:setTouchEnabled(true)
end

function PauseLayer:_onTouchBegan(x, y)
    --print("onTouchBegan: %0.2f, %0.2f", x, y)
    return true
end

function PauseLayer:_onTouchMoved(x, y)
    --print("onTouchMoved: %0.2f, %0.2f", x, y)
end

function PauseLayer:_onTouchEnded(x, y)
end


return PauseLayer