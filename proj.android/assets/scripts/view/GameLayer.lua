--@brief 游戏主场景

require "AudioEngine" 

local GameLayer = class("GameLayer", function()
    return CCLayer:create()
end)

-- local GameLayer = CCLayer:create()
local g_scheduler = CCDirector:sharedDirector():getScheduler()

function GameLayer:initMap(mapId)
    --加载map
    local mapInfo = nil
    local mapPicFolderName = nil
    if isFileExist("datas.map."..mapId..".lua") then
        mapInfo = require("datas.map."..mapId)
        mapPicFolderName = mapId
    else
        mapInfo = sgGameManager:randomAmap()
        mapPicFolderName = "default"..math.random(1, 3)
    end

    --加载map
    local map = mapInfo.data
    
    --设置map
    sgGameManager:setMap(mapInfo.data, mapInfo.iconWidth, mapInfo.iconHeight)

    --获取map的信息
    local iconWidth, iconHeight = sgGameManager:getIconSize()
    local mapRows, mapCols = sgGameManager:getMapSize()

    --创建存储地图的Layer
    if not self.m_mapLayer then
        self.m_mapLayer = CCLayer:create()
        --self.m_mapLayer = CCLayerColor:create(ccc4(0, 0, 0, 255))
        self.m_mapLayer:ignoreAnchorPointForPosition(false)
        self.m_mapLayer:setAnchorPoint(0.5, 0.5)
        self.m_mapLayer:setPosition(CENTER_X, CENTER_Y-20)
        self:addChild(self.m_mapLayer)
    end
    self.m_mapLayer:setContentSize(iconWidth*mapCols, iconHeight*mapRows)

    --创建小图
    local  cnt = 1
    for row = 2, mapRows-1 do
        for col = 2, mapCols-1 do
            if 0 ~= map[row][col] then
                --print(cnt)
                cnt = cnt + 1
                local icon = CCSprite:create("ui/"..mapPicFolderName.."/"..map[row][col]..".png")
                icon:setPosition(sgGameManager:getPositionByIndex(row, col))
                icon:setTag(sgGameManager:getTagByRowCol(row, col)) --设置标志
                icon:setScale(1.13)
                self.m_mapLayer:addChild(icon)

                local cover = CCSprite:create("ui/cover.png")
                cover:setAnchorPoint(0, 0)
                cover:setPosition(0, 0)
                icon:addChild(cover, 1)
            end
        end
    end

    --DEBUG
    --显示icon坐标
    -- for row = 1, mapRows do
    --     for col = 1, mapCols do
    --         local label = CCLabelTTF:create("("..row..","..col..")", "Arial", 20)
    --         label:setPosition((col-1)*iconWidth+iconWidth/2, 
    --             (mapRows-row)*iconHeight+iconHeight/2)
    --         self.m_mapLayer:addChild(label)
    --     end
    -- end
end

function GameLayer:initUI()
    --背景
    local randomIndx = math.random(1, 3)
    self.m_background = CCSprite:create("ui/background/bg"..randomIndx..".png")
    self.m_background:setPosition(CENTER_X, CENTER_Y)
    self:addChild(self.m_background)

    --关卡
    local spriteLevelName = CCSprite:create("ui/Level.png")
    spriteLevelName:setPosition(45, HEIGHT-30)
    self:addChild(spriteLevelName)

    --关卡数字
    self.m_bmfLevelNumber = CCLabelBMFont:create("99", "fonts/LevelNumber.fnt")
    --self.m_bmfLevelNumber:setAnchorPoint(0, 0.5)
    self.m_bmfLevelNumber:setScale(0.5)
    self.m_bmfLevelNumber:setPosition(spriteLevelName:getContentSize().width+20, HEIGHT-18)
    self:addChild(self.m_bmfLevelNumber)

    --血条背景
    local progressBloodBg = CCSprite:create("ui/ProgressBloodBg.png")
    progressBloodBg:setPosition(CENTER_X+30, HEIGHT-30)
    progressBloodBg:setScaleX(0.8)
    self:addChild(progressBloodBg)

    --血条
    self.m_progressBlood = CCProgressTimer:create(CCSprite:create("ui/ProgressBlood.png"))
    self.m_progressBlood:setType(kCCProgressTimerTypeBar)
    self.m_progressBlood:setMidpoint(CCPointMake(0, 0))
    self.m_progressBlood:setBarChangeRate(CCPointMake(1, 0))
    self.m_progressBlood:setPosition(CCPointMake(CENTER_X+30, HEIGHT-30))
    self.m_progressBlood:setScaleX(0.8)
    self:addChild(self.m_progressBlood)

    


    --暂停按钮
    local  spritePauseNormal  = CCSprite:create("ui/Pause.png")
    local  spritePauseSelected = CCSprite:create("ui/Pause.png")
    spritePauseSelected:setColor(ccc3(50,50,50))
    local  spritePauseDisabled = CCSprite:create("ui/Pause.png")
    spritePauseDisabled:setColor(ccc3(50,50,50))
    local  menuItemPause = CCMenuItemSprite:create(
        spritePauseNormal, spritePauseSelected, spritePauseDisabled)
    menuItemPause:registerScriptTapHandler(function()
        -- if STATE_PAUSE == sgGameManager:getCurState() then
        --     sgGameManager:setState(STATE_RESUME)
        -- else
        --     sgGameManager:setState(STATE_PAUSE)
        -- end
        sgGameManager:setState(STATE_PAUSE)

    end)
    menuItemPause:setScale(0.7)
    menuItemPause:setPosition(WIDTH-40, HEIGHT-30)
    local arr = CCArray:create()
    arr:addObject(menuItemPause)
    local menu = CCMenu:createWithArray(arr)
    menu:setPosition(0, 0)
    self:addChild(menu)


    --选中框
    self.m_selectSprite = self:createAnimationSprite(
        "SelectEffect.plist", "SelectEffect%d", 0.08, true)
    self.m_selectSprite:setPosition(0, 0)
    self.m_selectSprite:setVisible(false)
    self:addChild(self.m_selectSprite, 2)

    --连线Layer
    self.m_lineLayer = CCLayer:create()
    self:addChild(self.m_lineLayer, 2)
end

function GameLayer:init()
    
    --sgGameManager:setState(STATE_NONE)

    self:initUI()

    --Touch
    self:initTouch()

    --update
    -- if not self.m_schedulerEntity then
    --     g_scheduler:unscheduleScriptEntry(self.m_schedulerEntity)
    --     self.m_schedulerEntity = nil
    -- end
    -- self.m_schedulerEntity = g_scheduler:scheduleScriptFunc(function(dt)
    --         self:update(dt)
    --     end, 
    --     0.1, false)


    self:registerScriptHandler(function(event)
            if event == "enter" then
                self.m_schedulerEntity = g_scheduler:scheduleScriptFunc(function(dt)
                    self:update(dt)
                end, 
                0.1, false)
            elseif event == "exit" then
                if self.m_schedulerEntity then
                    g_scheduler:unscheduleScriptEntry(self.m_schedulerEntity)
                    self.m_schedulerEntity = nil
                end
            end
        end)

    -- self:registerScriptKeypadHandler(function(strEvent)
    --     print(strEvent)
    --     if "backClicked" == strEvent then
    --         print("backClicked")
    --         sgGameManager:setState(STATE_FAILE)
    --     end
    -- end)

    self:reloadData()
end

function GameLayer:reloadData()
    --设置游戏状态为什么都不是
    sgGameManager:setState(STATE_NONE)

    --背景音乐
    if math.random(1, 2) then
        AudioEngine.playMusic(MUSIC_BACKGROUND1, true)
    else
        AudioEngine.playMusic(MUSIC_BACKGROUND2, true)
    end

    self:initMap("map12")

    --背景
    local randomIndx = math.random(1, 2)
    self.m_background:setDisplayFrame(CCSprite:create("ui/background/bg"..randomIndx..".png"):displayFrame())


    --关卡数字
    self.m_bmfLevelNumber:setString(tostring(sgGameManager:getCurLevel()))

    --血条
    self.m_progressBlood:setPercentage(100)
    local array = CCArray:create()
    array:addObject(CCProgressFromTo:create(sgGameManager:getCurLevelProgressTime(), 100, 0))
    array:addObject(CCCallFunc:create(function()
        sgGameManager:setState(STATE_TIME_OVER)
    end))
    self.m_progressBloodAction = CCSequence:create(array)
    CCDirector:sharedDirector():getActionManager():addAction(self.m_progressBloodAction, self.m_progressBlood, false)

    --设置游戏状态为进行中
    sgGameManager:setState(STATE_GAME_PLAYING)
end

--@brief Touch
function GameLayer:initTouch()
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            --点击音效
            AudioEngine.playEffect(SOUND_ICON_CLICK)
            return self:_onTouchBegan(x, y)
        elseif eventType == "moved" then
            return self:_onTouchMoved(x, y)
        else
            return self:_onTouchEnded(x, y)
        end
    end
    self:registerScriptTouchHandler(onTouch)
    self:setTouchEnabled(true)
end

--@brief 创建动画精灵
function GameLayer:createAnimationSprite(plistName, frameName, frameTime, isLoop, delayTime)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/plist/"..plistName)
    --选中框
    local sprite = CCSprite:createWithSpriteFrameName(string.format(frameName..".png", 1))
    local array = CCArray:create()
    local pngIndex = 1
    while true do
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( string.format(frameName..".png", pngIndex) )
        if not frame then
            break
        end
        array:addObject(frame)
        pngIndex = pngIndex + 1
    end
    local animation = CCAnimation:createWithSpriteFrames(array, frameTime)

    local seqArray = CCArray:create()
    --等待几秒
    if delayTime then
        seqArray:addObject(CCDelayTime:create(delayTime))
    end
    --动画
    seqArray:addObject(CCAnimate:create(animation))
    if isLoop then
        sprite:runAction(CCRepeatForever:create(CCSequence:create(seqArray)))
    else
        seqArray:addObject(CCCallFunc:create(function()
            sprite:getParent():removeChild(sprite, true)
        end))
        sprite:runAction(CCSequence:create(seqArray))
    end
    return sprite
end

function GameLayer:_onTouchBegan(x, y)
    --print("onTouchBegan: %0.2f, %0.2f", x, y)
    return true
end

function GameLayer:_onTouchMoved(x, y)
    --print("onTouchMoved: %0.2f, %0.2f", x, y)
end

function GameLayer:_onTouchEnded(x, y)
    --print("onTouchEnded: %0.2f, %0.2f", x, y)
    if STATE_GAME_PLAYING ~= sgGameManager:getCurState() then
        return
    end

    local localPosition = self.m_mapLayer:convertToNodeSpace(ccp(x, y))
    local row, col = sgGameManager:getMapAddress(localPosition.x, localPosition.y)
    --print(row, col)
    sgGameManager:setClickPos(row, col)

    local clickPos = sgGameManager:getClickPos()

    if clickPos[1] then
        self.m_selectSprite:setVisible(true)
        local posX, posY = sgGameManager:getPositionByIndex(clickPos[1][1], clickPos[1][2])
        local worldClickPos = self.m_mapLayer:convertToWorldSpace(ccp(posX, posY)) 
        self.m_selectSprite:setPosition(worldClickPos.x, worldClickPos.y)
    end

    if clickPos[1] and clickPos[2] then
        -- local isExistWay, path = sgGameManager:findTheWay(2, 2, 2, 9, 0, 0) 
        local isExistWay, mapDir = sgGameManager:findTheWay2(clickPos[1][1], clickPos[1][2],
                                                        clickPos[2][1], clickPos[2][2])
        if isExistWay then
             --连接音效
            AudioEngine.playEffect(SOUND_ICON_CONNECT1)
            local path = {}
            local curRow, curCol = clickPos[2][1], clickPos[2][2]
            local preRow, preCol = nil, nil
            while true do
                path[#path+1] = {curRow, curCol}
                if curRow == clickPos[1][1] and curCol == clickPos[1][2] then
                    break
                end
                preRow, preCol = sgGameManager:getPreRowColByDir(
                                    curRow, curCol, mapDir[curRow][curCol][1])
                curRow, curCol = preRow, preCol
            end

            local preX, preY = sgGameManager:getPositionByIndex(path[#path][1], path[#path][2])
            local curX, curY = nil, nil
            for i = #path-1, 1, -1 do
                curX, curY = sgGameManager:getPositionByIndex(path[i][1], path[i][2])
                --print("preX:"..preX..",preY:"..preY)
                --print("curX:"..curX..",curY:"..curY)

                local arrowSprite = CCSprite:create("ui/Arrow4.png")
                local worldPos = self.m_mapLayer:convertToWorldSpace(ccp((curX+preX)/2, (curY+preY)/2)) 
                arrowSprite:setPosition(worldPos.x, worldPos.y)
                arrowSprite:setRotation(sgGameManager:getRotation(mapDir[path[i][1]][path[i][2]][1]))
                arrowSprite:setVisible(false)
                self.m_lineLayer:addChild(arrowSprite)
                local array = CCArray:create()
                array:addObject(CCDelayTime:create(0.03*(#path-i)))                
                array:addObject(CCShow:create())
                array:addObject(CCDelayTime:create(0.3))
                array:addObject(CCCallFunc:create(function()
                    self.m_lineLayer:removeChild(arrowSprite, true)

                    --删除起始的icon
                    local iconStart = self.m_mapLayer:getChildByTag(
                        sgGameManager:getTagByRowCol(path[1][1], path[1][2]))
                    self.m_mapLayer:removeChild(iconStart, true)

                    --删除结束的icon
                    local iconEnd = self.m_mapLayer:getChildByTag(
                        sgGameManager:getTagByRowCol(path[#path][1], path[#path][2]))
                    self.m_mapLayer:removeChild(iconEnd, true)

                    --删除map上点击到的icon的数据
                    sgGameManager:setTheMapCell(path[1][1], path[1][2], 0)
                    sgGameManager:setTheMapCell(path[#path][1], path[#path][2], 0)

                end))
                arrowSprite:runAction(CCSequence:create(array))
                preX, preY = curX, curY
            end
        else
            --print("sorry, can't find the way!!!!")
        end
        self.m_selectSprite:setVisible(false)
        sgGameManager:clearClickPos()
    end
end

--@brief 更新
function GameLayer:update(dt)
    --要设置的状态
    local state = sgGameManager:getState()
    --当前的状态
    local curState = sgGameManager:getCurState()           

    --时间到
    if STATE_TIME_OVER == state then
        if curState ~= state then
            sgGameManager:setCurState(state)
            --sgGameManager:setState(STATE_NONE)
            local sprite = self:createAnimationSprite(
                "TimeOverEffect.plist", "TimeOverEffect%d", 0.08, false)
            sprite:setPosition(CENTER_X*1.5, CENTER_Y)
            self:addChild(sprite)

            --是否清除了地图了
            if sgGameManager:checkIsClearTheMap() then
                --设置胜利状态
                sgGameManager:setState(STATE_WIN)
            else
                --设置失败状态
                sgGameManager:setState(STATE_FAILE)
            end
        end
        

    --暂停
    elseif STATE_PAUSE == state then
        if curState ~= state then
            sgGameManager:setCurState(state)
            --暂停计时
            CCDirector:sharedDirector():getActionManager():pauseTarget(self.m_progressBlood)

            --如果暂停界面还未创建
            if not self.m_pauseLayer then
                local PauseLayer = require("scripts.view.PauseLayer")
                self.m_pauseLayer = PauseLayer:create()
                --self:addChild(pauseLayer, 10)
                CCDirector:sharedDirector():getRunningScene():addChild(self.m_pauseLayer, 10)
            else
                self.m_pauseLayer:setVisible(true)
            end 
        end
        
    --重新开始
    elseif STATE_RESUME == state then
        if curState ~= state then
            sgGameManager:setCurState(state)
            if self.m_pauseLayer then
                self.m_pauseLayer:setVisible(false)
            end

            CCDirector:sharedDirector():getActionManager():resumeTarget(self.m_progressBlood)
            
            sgGameManager:setState(STATE_GAME_PLAYING)
        end
        
    --胜利
    elseif STATE_WIN == state then
        if curState ~= state then
            sgGameManager:setCurState(state)
            --print("win")
            --音效
            AudioEngine.playEffect(SOUND_SUCCESS)
            local sprite = self:createAnimationSprite(
                "WinEffect.plist", "WinEffect%d", 0.08, false)
            sprite:setPosition(CENTER_X, CENTER_Y)
            self:addChild(sprite)

            local array = CCArray:create()
            array:addObject(CCDelayTime:create(3))
            array:addObject(CCCallFunc:create(function()
                sgGameManager:increaseCurLevel()
                self:reloadData()    
            end))
            self:runAction(CCSequence:create(array))
        end
        
    
    --失败
    elseif STATE_FAILE == state then
        if curState ~= state then
            sgGameManager:setCurState(state)
            --音效
            AudioEngine.playEffect(SOUND_FAILE)
            local sprite = self:createAnimationSprite(
                "FaileEffect.plist", "FaileEffect%d", 0.08, false, 1)
            sprite:setPosition(CENTER_X, CENTER_Y)
            self:addChild(sprite)

            local array = CCArray:create()
            array:addObject(CCDelayTime:create(3.0))
            array:addObject(CCCallFunc:create(function()
                    --移除游戏界面
                    CCDirector:sharedDirector():getRunningScene():removeChild(self, true)
                    --运行开始游戏界面
                    local StartGameLayer = require("scripts.view.StartGameLayer")
                    local layer = StartGameLayer:create()
                    CCDirector:sharedDirector():getRunningScene():addChild(layer)
                end))
            sprite:runAction(CCSequence:create(array))

        end
        

    --游戏进行中
    elseif STATE_GAME_PLAYING == state then
        if curState ~= state then
            sgGameManager:setCurState(state)
        end
        --是否清除了地图了
        if sgGameManager:checkIsClearTheMap() then
            self.m_progressBlood:stopAction(self.m_progressBloodAction)
            --print("win")
            --设置胜利状态
            sgGameManager:setState(STATE_WIN)
        end
    end
end

return GameLayer