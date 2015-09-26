--TODO:还没用
local SelectModeLayer = CCLayer:create()

function SelectModeLayer:init()
	local layer = CCLayerColor:create(ccc4(0, 123, 12, 255))
    layer:setContentSize(300, 300)
    layer:setPosition(10, 10)
    self:addChild(layer)

	local tableView = CCTableView:create(CCSizeMake(300, 300))
	tableView:setDirection(kCCScrollViewDirectionHorizontal)
	tableView:setPosition(10, 10)
	self:addChild(tableView)
	tableView:registerScriptHandler(SelectModeLayer.scrollViewDidScroll,CCTableView.kTableViewScroll)
    tableView:registerScriptHandler(SelectModeLayer.scrollViewDidZoom,CCTableView.kTableViewZoom)
    tableView:registerScriptHandler(SelectModeLayer.tableCellTouched,CCTableView.kTableCellTouched)
    tableView:registerScriptHandler(SelectModeLayer.cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    tableView:registerScriptHandler(SelectModeLayer.tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    tableView:registerScriptHandler(SelectModeLayer.numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    tableView:reloadData()
end

function SelectModeLayer.scrollViewDidScroll(view)
    print("scrollViewDidScroll")
end

function SelectModeLayer.scrollViewDidZoom(view)
    print("scrollViewDidZoom")
end

function SelectModeLayer.tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function SelectModeLayer.cellSizeForTable(table,idx) 
    return 71,64
end

function SelectModeLayer.tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = CCTableViewCell:new()

        local sprite = CCSprite:create("menu1.png")
        sprite:setAnchorPoint(CCPointMake(0,0))
        sprite:setPosition(CCPointMake(0, 0))
        cell:addChild(sprite)

        local sprite2 = CCSprite:create("menu1.png")
        sprite2:setAnchorPoint(CCPointMake(0,0))
        sprite2:setPosition(CCPointMake(0, 0))
        sprite2:setColor(ccc3(50, 125, 5))]
        sprite2:setVisible(false)
        sprite2:setTag(20)
        cell:addChild(sprite2)

        label = CCLabelTTF:create(strValue, "Helvetica", 20.0)
        label:setPosition(CCPointMake(0,0))
        label:setAnchorPoint(CCPointMake(0,0))
        label:setTag(123)
        cell:addChild(label)
    else
        label = tolua.cast(cell:getChildByTag(123),"CCLabelTTF")
        if nil ~= label then
            label:setString(strValue)
        end
    end

    return cell
end

function SelectModeLayer.numberOfCellsInTableView(table)
   return 25
end


return SelectModeLayer