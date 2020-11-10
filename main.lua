--[[ I used the iPad Pro emulator, but I configured the config.lua file,
so it can display correctly on any device ]]--

display.setStatusBar(display.HiddenStatusBar)
local widget = require("widget")
local csv = require('csv');
local csv_path = system.pathForFile('car.csv');
local balls={};
local f = csv.open(csv_path)
-- local f = csv.open('car.csv', system.ResourceDirectory)



local function createBall(fields)
    
    local radius = fields[2]/110;
    local x = radius + 550 * math.random(); 
    local y = radius + 670 * math.random();
    
    local ball = display.newCircle(x, y, radius, weight, mileage, typeOfCar);
    ball.weight = fields[2]
    ball.mileage = fields[4] 
    ball.radius = radius
    ball.typeOfCar = fields[6]
    local group = display.newGroup()
    group:insert(ball)
    
    local text = display.newText(fields[1], ball.x, ball.y, native.systemFont, 20)
    text:setFillColor(0,0.7,0.9,1)
    group:insert(text)

    if(fields[6] == "Small") then
        ball:setFillColor(0, 1, 0, 0.8); -- Green
        text:setFillColor(1,1,1,0.8)
    elseif (fields[6] == "Sporty") then
        ball:setFillColor(1,0.2,0.9, 0.8); -- Pink
    elseif (fields[6] == "Compact") then
        ball:setFillColor(0,0.1,0.9, 0.8); -- Blue
        text:setFillColor(1,1,1,0.8)
    elseif (fields[6] == "Medium") then
        ball:setFillColor(0.9,0.9,0.9,0.85); -- Gray
    elseif (fields[6] == "Large") then
        ball:setFillColor(1,0.1,0, 0.9); -- Red
    elseif (fields[6] == "Van") then
        ball:setFillColor(1,0.9,0, 0.9); -- Yellow
    end

    speed = tonumber(fields[4]);
    group.radius = radius
    group.deltaX = speed/9
    group.deltaY = speed/9
    group.text = text;
    group.anchorX = 0;
    group.anchorY = 0;

    table.insert(balls, group)

end



count = 0
for fields in f:lines() do
    -- remove the headeings
    if (count == 0) then
        count = 1
    else
	--print(fields[1])
	--print(tonumber(fields[2]))
    local ball = createBall(fields);
    end

end


function update()
    local offset = 400;
    for _, ball in ipairs(balls) do -- why need _, ??? BECAUSE for varName = from_exp, to_exp, [step_exp] do block end
        if (ball[1].x + ball.deltaX > display.contentWidth - ball.radius) or (ball[1].x + ball.deltaX < ball.radius) then
            ball.deltaX = -ball.deltaX;
        end
        -- Insert offset to create room for gui component
        if (ball[1].y + ball.deltaY > display.contentHeight - offset - ball.radius) or (ball[1].y + ball.deltaY < ball.radius) then
            ball.deltaY = -ball.deltaY;
        end
        -- each item in the ball group so the circle and the text needs to change direction
        ball[1].x = ball[1].x + ball.deltaX;
        ball[1].y = ball[1].y + ball.deltaY;
        ball[2].x = ball[2].x + ball.deltaX;
        ball[2].y = ball[2].y + ball.deltaY;
    end
end





local function sliderListener(event)
    filterBalls()
    updateText()
end

minSlider = widget.newSlider({
    top = 900,
    left = 140,
    width = 240,
    id = "minSlider",
    value = 0,
    listener = sliderListener
})

maxSlider = widget.newSlider({
    top = 1000,
    left = 140,
    width = 240,
    id = "maxSlider",
    value = 100,
    listener = sliderListener
})

local minLabel = display.newText("Min", 80, 920, native.systemFont, 40)
local maxLabel = display.newText("Max", 80, 1020, native.systemFont, 40)
local minValue = display.newText(minSlider.value .. " %", 460, 920, native.systemFont, 40)
local maxValue = display.newText(maxSlider.value .. " %", 460, 1020, native.systemFont, 40)


local function onSwitchPress( event )
    filterBalls()
    updateText()
end


local weightBtn = widget.newSwitch(
    {
        left = 650,
        top = 820,
        style = "radio",
        id = "weightBtn",
        initialSwitchState = true,
        onPress = onSwitchPress
    }
)

local mileageBtn = widget.newSwitch(
    {
        left = 650,
        top = 920,
        style = "radio",
        id = "mileageBtn",
        initialSwitchState = false,
        onPress = onSwitchPress
    }
)

local weightBtnLabel = display.newText("Weight", 660, 780, native.systemFont, 40)
local mileageBtnLabel = display.newText("Mileage", 670, 890, native.systemFont, 40)


-- if user hits toggle button first raw values will have been calculated
weightMin = 1845 + minSlider.value * 20.1;
weightMax = 1845 + maxSlider.value * 20.1;
mileageMin = 18 + minSlider.value * 0.19;
mileageMax = 18 + maxSlider.value * 0.19;



local function onSwitchPressCheck( event )
    updateText()
end

local function colorFilter( event )
    updateScreen()
end




local sheetOptions = {
    width = 100,
    height = 100,
    numFrames = 4,
    sheetContentWidth = 400,
    sheetContentHeight = 100
}
local checkboxSheet = graphics.newImageSheet( "checkboxSheet.png", sheetOptions )




-- Toggle widget
local toggleBtn = widget.newSwitch(
    {
        left = 650,
        top = 1060,
        style = "checkbox",
        id = "toggleBtn",
        initialSwitchState = true,
        onPress = onSwitchPressCheck,
    }
)

-- CheckBoxes for Car Filtering
-- Small 
local smallCarBtn = widget.newSwitch(
    {
        left = 60,
        top = 820,
        style = "checkbox",
        id = "smallCarBtn",
        initialSwitchState = true,
        onPress = colorFilter,
        sheet = checkboxSheet,
        frameOff = 3,
        frameOn = 4
    }
)

-- Sporty
local sportyCarBtn = widget.newSwitch(
    {
        left = 140,
        top = 820,
        style = "checkbox",
        id = "sportyCarBtn",
        initialSwitchState = true,
        onPress = colorFilter,
        sheet = checkboxSheet,
        frameOff = 3,
        frameOn = 4
    }
)


-- Compact
local compactCarBtn = widget.newSwitch(
    {
        left = 230,
        top = 820,
        style = "checkbox",
        id = "compactCarBtn",
        initialSwitchState = true,
        onPress = colorFilter,
        sheet = checkboxSheet,
        frameOff = 3,
        frameOn = 4
    }
)

-- Medium
local mediumCarBtn = widget.newSwitch(
    {
        left = 320,
        top = 820,
        style = "checkbox",
        id = "MediumCarBtn",
        initialSwitchState = true,
        onPress = colorFilter,
        sheet = checkboxSheet,
        frameOff = 3,
        frameOn = 4
    }
)

-- Large
local largeCarBtn = widget.newSwitch(
    {
        left = 400,
        top = 820,
        style = "checkbox",
        id = "largeCarBtn",
        initialSwitchState = true,
        onPress = colorFilter,
        sheet = checkboxSheet,
        frameOff = 3,
        frameOn = 4
    }
)

-- Van
local vanCarBtn = widget.newSwitch(
    {
        left = 460,
        top = 820,
        style = "checkbox",
        id = "vanCarBtn",
        initialSwitchState = true,
        onPress = colorFilter,
        sheet = checkboxSheet,
        frameOff = 3,
        frameOn = 4
    }
)


local toggleLabel = display.newText("Toggle (% or Raw Val)", 680, 1020, native.systemFont, 28)
local smallCarLabel = display.newText("Small", 80, 780, native.systemFont, 22)
local sportyCarLabel = display.newText("Sporty", 150, 780, native.systemFont, 22)
local compactCarLabel = display.newText("Compact", 240, 780, native.systemFont, 22)
local mediumCarLabel = display.newText("Medium", 340, 780, native.systemFont, 22)
local largeCarLabel = display.newText("Large", 420, 780, native.systemFont, 22)
local vanCarLabel = display.newText("Van", 480, 780, native.systemFont, 22)


function updateScreen()
    for _, ball in ipairs(balls) do
        if ((ball[1].typeOfCar == "Small") and (smallCarBtn.isOn == false)) then
            ball[1].isVisible = false
            ball[2].isVisible = false
        elseif((ball[1].typeOfCar == "Sporty") and (sportyCarBtn.isOn == false)) then
            ball[1].isVisible = false
            ball[2].isVisible = false
        elseif((ball[1].typeOfCar == "Compact") and (compactCarBtn.isOn == false)) then
            ball[1].isVisible = false
            ball[2].isVisible = false
        elseif((ball[1].typeOfCar == "Medium") and (mediumCarBtn.isOn == false)) then
            ball[1].isVisible = false
            ball[2].isVisible = false
        elseif((ball[1].typeOfCar == "Large") and (largeCarBtn.isOn == false)) then
            ball[1].isVisible = false
            ball[2].isVisible = false
        elseif((ball[1].typeOfCar == "Van") and (vanCarBtn.isOn == false)) then
            ball[1].isVisible = false
            ball[2].isVisible = false
        else
            ball[1].isVisible = true
            ball[2].isVisible = true
        end
    end
end

function updateText()
    if(minSlider.value > maxSlider.value) then
        minSlider.value = maxSlider.value
        minSlider:setValue(minSlider.value) -- this is a percentage
    end
    if(toggleBtn.isOn) then
        minValue.text =  minSlider.value .. " %";
        maxValue.text =  maxSlider.value .. " %";
    else
        if(weightBtn.isOn) then
            if (weightMin > weightMax) then
                weightMin = weightMax
            end
            minValue.text = weightMin
            maxValue.text = weightMax
        else
            if (mileageMin > mileageMax) then
                mileageMin = mileageMax
            end
            minValue.text = mileageMin
            maxValue.text = mileageMax
        end
    end
end

function filterBalls(ball)
    timer.pause("moveLoop")
    --[[ The offset is multiplied to normalize, 
    to make the sliders inclusive at same percentages ]]
    weightMin = 1845 + minSlider.value * 20.1; -- diff of max and min / 100 to normalize
    weightMax = 1845 + maxSlider.value * 20.1;
    mileageMin = 18 + minSlider.value * 0.19;
    mileageMax = 18 + maxSlider.value * 0.19;

    for _, ball in ipairs(balls) do -- why need _, ??? BECAUSE for varName = from_exp, to_exp, [step_exp] do block end
        if (weightBtn.isOn and (tonumber(ball[1].weight) >= weightMin) and ((tonumber(ball[1].weight) <= weightMax))) then
            ball.isVisible = true;
        elseif (mileageBtn.isOn and (tonumber(ball[1].mileage) >= mileageMin) and ((tonumber(ball[1].mileage) <= mileageMax))) then
            ball.isVisible = true;
        else
            ball.isVisible = false;
        end

    end
    timer.resume("moveLoop")
end

timer.performWithDelay(15, update, 0, "moveLoop");





