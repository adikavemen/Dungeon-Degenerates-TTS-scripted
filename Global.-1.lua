require("vscode/console")

local GUIDs = {
    onTheRunButton = "23e797",
    resetButton = "229d71",
    clue1 = "8f7667",
    clue2 = "611dc4",
    clue3 = "6cac6f",
    clue6 = "06d850",
    lootDeck = "4e06cf",
    blockade = "ebec12",
    missionPouch = "705d85",
    lawTokens = {
        "aa2885",
        "bc117c",
        "7bc211",
        "b0a45c"
    }
}


--[[ Lua code. See documentation: http://berserk-games.com/knowledgebase/scripting/ --]]

local buttonParams = {
    onTheRun = {
        label = "On The Run",
        click_function = "setUpOnTheRun",
        position = {0, 0, 0},
        width = 1100,
        height = 500,
        font_size = 200
    },
    reset = {
        label = "Reset",
        click_function = "reset",
        position = {0, 0, 0},
        width = 1100,
        height = 500,
        font_size = 200
    }
}

local initialState = {}

function captureInitialState()
    initialState = {}
    for key, guid in pairs(GUIDs) do
        if type(guid) == "table" then
            for i, subGuid in ipairs(guid) do
                local obj = getObjectFromGUID(subGuid)
                if obj then
                    initialState[subGuid] = {
                        position = obj.getPosition(),
                        rotation = obj.getRotation(),
                        locked = obj.getLock()
                    }
                end
            end
        else
            local obj = getObjectFromGUID(guid)
            if obj then
                initialState[guid] = {
                    position = obj.getPosition(),
                    rotation = obj.getRotation(),
                    locked = obj.getLock()
                }
            end
        end
    end
end

function createButtons()
    local onTheRunButton = getObjectFromGUID(GUIDs.onTheRunButton)
    if onTheRunButton then
        onTheRunButton.createButton(buttonParams.onTheRun)
    else
        print("Error: On The Run button object not found.")
    end

    local resetButton = getObjectFromGUID(GUIDs.resetButton)
    if resetButton then
        resetButton.createButton(buttonParams.reset)
    else
        print("Error: Reset button object not found.")
    end
end

--[[ The onLoad event is called after the game save finishes loading. --]]
function onLoad()
    --[[ print('onLoad!') --]]
    captureInitialState()
    createButtons()
    -- onTheRunButton = getObjectFromGUID(onTheRunButton_GUID)
    -- onTheRunButton.createButton(onTheRunButtonParams)
    -- resetButton = getObjectFromGUID(resetButton_GUID)
    -- resetButton.createButton(resetButtonParams)
end

--[[ The onUpdate event is called once per frame. --]]
function onUpdate ()
    --[[ print('onUpdate loop!') --]]
end

function setUpOnTheRun()
    local function vec(x, y, z)
        return {x, y, z}
    end

    findCard("Soothsayer's Head")
    findCard("Fungal Parasite")

    -- List of objects to set up
    local setupConfig = {
        {guid = GUIDs.clue1, position = vec(-3.25, 1.86, 7.43), rotation = nil},
        {guid = GUIDs.clue2, position = vec(7.20, 1.86, 4.10), rotation = nil},
        {guid = GUIDs.clue3, position = vec(11.74, 1.86, -2.05), rotation = nil},
        {guid = GUIDs.clue6, position = vec(-2.90, 1.86, -2.04), rotation = nil},
        {guid = GUIDs.blockade, position = vec(-6.92, 1.86, 4.25), rotation = vec(0.00, 180.00, 0.00)},
        {guid = GUIDs.lawTokens[1], position = vec(4.20, 1.96, 2.48), rotation = nil, lock = true},
        {guid = GUIDs.lawTokens[2], position = vec(5.63, 1.96, 1.30), rotation = vec(0.00, 180.00, 180.00)},
        {guid = GUIDs.lawTokens[3], position = vec(1.99, 1.96, 0.73), rotation = nil},
        {guid = GUIDs.lawTokens[4], position = vec(4.64, 1.96, -0.49), rotation = nil}
    }

    -- Iterate over each object and set its properties
    for _, config in ipairs(setupConfig) do
        local obj = getObjectFromGUID(config.guid)
        if obj then
            obj.setPosition(config.position)
            if config.rotation then
                obj.setRotation(config.rotation)
            end
            obj.setLock(true)
        else
            print("Error: Object with GUID " .. config.guid .. " not found.")
        end
    end
end

function findCard(cardName)
    local lootDeck = getObjectFromGUID(GUIDs.lootDeck)
    local missionDeck = getObjectFromGUID(GUIDs.missionPouch)

    if lootDeck == nil then
        print("Error: Deck not found.")
        return
    end

    if missionDeck == nil then
        print("Error: Deck not found.")
        return
    end
    
    local deckContents = lootDeck.getObjects()
    for _, card in ipairs(deckContents) do
        if card.name == cardName then
            local params = {
                position = vector(23.68, 0.95, 13.71),
                index = card.index,
                smooth = true,
                callback_function = function(obj) obj.setRotation({0, 180, 180}) end -- Adjust rotation as needed
            }
            lootDeck.takeObject(params)
            print("Card '" .. cardName .. "' has been moved to the table.")
            return
        end
    end
    print("Error: Card '" .. cardName .. "' not found in the lootDeck.")
end

function reset()
    --TODO: Write reset stage
    for id, transformer in pairs(initialState) do
        local obj = getObjectFromGUID(id)
        if obj then
            obj.setPosition(transformer.position)
            obj.setRotation(transformer.rotation)
            obj.setLock(false)
        end
    end
end