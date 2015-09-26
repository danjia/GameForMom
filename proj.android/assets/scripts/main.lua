-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end

--
sgGameManager = nil


local function main()
	collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    math.randomseed(os.time())


    --Set global variable
    require("scripts.common.CommonDef")
    require("scripts.common.Utility")
    require("scripts.common.class")
    sgGameManager = require("scripts.logic.GameManager")
    sgGameManager:init()

    --GameLayer
    -- local gameLayer = require("scripts.view.GameLayer")
    -- gameLayer:init()

    --GameStartLayer
    local StartGameLayer = require("scripts.view.StartGameLayer")
    local layer = StartGameLayer:create()

    --Scene
    local sceneGame = CCScene:create()
    sceneGame:addChild(layer)
    --Run the Scene
    CCDirector:sharedDirector():runWithScene(sceneGame)
end


xpcall(main, __G__TRACKBACK__)
