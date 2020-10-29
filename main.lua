--[[ I used the iPad Pro, but I configured the config.lua file,
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
    local x = radius + 550 * math.random(); -- ideally I would like to not use hard coded values
    local y = radius + 670 * math.random();
    
    local ball = display.newCircle(x, y, radius, weight, mileage);
    ball.weight = fields[2]
    ball.mileage = fields[4] 
    ball.radius = radius;
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
        left = 350,
        top = 800,
        style = "radio",
        id = "weightBtn",
        initialSwitchState = true,
        onPress = onSwitchPress
    }
)

local mileageBtn = widget.newSwitch(
    {
        left = 650,
        top = 800,
        style = "radio",
        id = "mileageBtn",
        initialSwitchState = false,
        onPress = onSwitchPress
    }
)

local weightBtnLabel = display.newText("Weight", 360, 760, native.systemFont, 40)
local mileageBtnLabel = display.newText("Mileage", 660, 760, native.systemFont, 40)


-- if user hits toggle button first raw values will have been calculated
weightMin = 1845 + minSlider.value * 20.1;
weightMax = 1845 + maxSlider.value * 20.1;
mileageMin = 18 + minSlider.value * 0.19;
mileageMax = 18 + maxSlider.value * 0.19;



local function onSwitchPressCheck( event )
    updateText()
end

-- Create the widget
local toggleBtn = widget.newSwitch(
    {
        left = 650,
        top = 1000,
        style = "checkbox",
        id = "toggleBtn",
        initialSwitchState = true,
        onPress = onSwitchPressCheck
    }
)


local toggleLabel = display.newText("Toggle (% or Raw Val)", 680, 960, native.systemFont, 28)


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





