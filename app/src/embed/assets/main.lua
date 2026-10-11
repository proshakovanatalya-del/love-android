-- main.lua
-- Игра «Параноидальный квадрат»: собери N звёзд за уровни, а игра мешает.
-- Работает на ПК (клавиатура/мышь) и Android (тачскрин).
-- Окно растягивается. 8 уровней с нарастающей сложностью.

-- ========================
--   ОБЪЯВЛЕНИЯ
-- ========================
local player, stars, score, needed
local timeAlive, tauntTimer, taunt
local invertTimer, frozenTimer, fakeLagTimer, fakeLag
local starOffsetX, starOffsetY
local win, lose
local font

-- Уровневая система
local level = 1
local maxLevel = 8
local levelTransition = 0
local transitionText = ""

local levelFeatures = {
    movingStars  = 2,
    fakeStars    = 3,
    shrinkArena  = 5,
}

local cfg = {}

-- Виртуальный джойстик
local stick = {
    active = false,
    baseX = 0, baseY = 0,
    knobX = 0, knobY = 0,
    radius = 70,
    knobRadius = 30,
    id = nil,
    dx = 0, dy = 0,
}

-- Ложные звёзды
local fakeStars = {}

-- Арена
local arena = { x = 0, y = 0, w = 0, h = 0 }

-- Скорость звезды
local starVel = { x = 0, y = 0 }

local taunts = {
    "Ты уверен, что это правильная кнопка?",
    "Ой, я случайно подвинул цель. Извини.",
    "Ты слишком медленный. Попробуй ещё.",
    "Не доверяй зелёным квадратам.",
    "Кто вообще придумал эту игру?",
    "Хм, кажется, стрелки поменялись местами...",
    "Ты почти у цели. Почти.",
    "Я слежу за тобой.",
    "Может, стоит сдаться?",
    "Это не баг, это фича.",
    "Кажется, кто-то жульничает...",
    "Осторожно, впереди ложные звёзды!",
}

-- ========================
--   ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
--   (объявлены ДО loadLevel, иначе Lua их не найдёт)
-- ========================

local function randomStarPos()
local ax = arena.x + 60
local ay = arena.y + 60
local aw = math.max(1, arena.w - 120)
local ah = math.max(1, arena.h - 120)
return math.random(ax, ax + aw), math.random(ay, ay + ah)
end

local function resetStar()
starOffsetX = 0
starOffsetY = 0
stars.x, stars.y = randomStarPos()

if cfg.starSpeed and cfg.starSpeed > 0 then
    local ang = math.random() * math.pi * 2
    starVel.x = math.cos(ang) * cfg.starSpeed
    starVel.y = math.sin(ang) * cfg.starSpeed
    else
        starVel.x, starVel.y = 0, 0
        end
        end

        local function resetFakeStars()
        fakeStars = {}
        if not cfg.fakeStarCount or cfg.fakeStarCount == 0 then return end
            for i = 1, cfg.fakeStarCount do
                local fx, fy = randomStarPos()
                table.insert(fakeStars, { x = fx, y = fy, size = 22 })
                end
                end

                local function layoutStick()
                local w, h = love.graphics.getDimensions()
                stick.baseX = stick.radius + 40
                stick.baseY = h - stick.radius - 40
                if not stick.active then
                    stick.knobX = stick.baseX
                    stick.knobY = stick.baseY
                    end
                    end

                    local function clampToWindow()
                    local w, h = love.graphics.getDimensions()

                    player.x = math.max(0, math.min(w - player.size, player.x))
                    player.y = math.max(0, math.min(h - player.size, player.y))

                    stars.x = math.max(60, math.min(w - 60, stars.x))
                    stars.y = math.max(60, math.min(h - 60, stars.y))

                    arena.x, arena.y, arena.w, arena.h = 0, 0, w, h
                    end

                    -- ========================
                    --   УРОВНИ
                    -- ========================
                    local function loadLevel(n)
                    level = n

                    cfg = {
                        needed     = 5 + n * 2,
                        speed      = 220 + n * 15,
                        tauntEvery = math.max(1.2, 3.0 - n * 0.2),
                        invertEvery = math.max(4.0, 8.0 - n * 0.4),
                        frozenEvery = math.max(5.0, 10.0 - n * 0.5),
                        lagEvery    = math.max(6.0, 12.0 - n * 0.6),
                        starSpeed   = 0,
                        shrink      = false,
                        fakeStarCount = 0,
                    }

                    if n >= levelFeatures.movingStars then
                        cfg.starSpeed = 40 + (n - levelFeatures.movingStars) * 20
                        end
                        if n >= levelFeatures.fakeStars then
                            cfg.fakeStarCount = math.min(n - levelFeatures.fakeStars + 1, 4)
                            end
                            if n >= levelFeatures.shrinkArena then
                                cfg.shrink = true
                                end

                                player.speed = cfg.speed
                                score = 0
                                needed = cfg.needed
                                timeAlive = 0
                                tauntTimer = 0
                                taunt = ""
                                invertTimer = 0
                                frozenTimer = 0
                                fakeLagTimer = cfg.lagEvery
                                fakeLag = 0
                                win = false
                                lose = false

                                local w, h = love.graphics.getDimensions()
                                arena.x, arena.y, arena.w, arena.h = 0, 0, w, h

                                resetStar()
                                resetFakeStars()

                                transitionText = "УРОВЕНЬ " .. n .. (n == maxLevel and " — ФИНАЛ!" or "")
                                levelTransition = 1.6
                                end

                                local function nextLevel()
                                if level >= maxLevel then
                                    win = true
                                    return
                                    end
                                    loadLevel(level + 1)
                                    end

                                    local function restartGame()
                                    loadLevel(1)
                                    end

                                    -- ========================
                                    --   LÖVE CALLBACKS
                                    -- ========================
                                    function love.load()
                                    love.window.setMode(800, 600, {
                                        resizable = true,
                                        minwidth = 400,
                                        minheight = 300,
                                    })
                                    love.window.setTitle("Параноидальный квадрат")
                                    love.graphics.setBackgroundColor(0.08, 0.08, 0.12)

                                    local ok, loaded = pcall(love.graphics.newFont, "font.ttf", 16)
                                    if ok then
                                        font = loaded
                                        else
                                            font = love.graphics.newFont(16)
                                            print("ВНИМАНИЕ: font.ttf не найден, использую встроенный шрифт.")
                                            end
                                            love.graphics.setFont(font)

                                            player = { x = 400, y = 300, size = 40, speed = 260 }
                                            stars = { x = 0, y = 0, size = 22 }
                                            layoutStick()
                                            loadLevel(1)
                                            end

                                            local function getInputDirection()
                                            local dx, dy = 0, 0

                                            if love.keyboard.isDown("right") then dx = dx + 1 end
                                                if love.keyboard.isDown("left")  then dx = dx - 1 end
                                                    if love.keyboard.isDown("down")  then dy = dy + 1 end
                                                        if love.keyboard.isDown("up")    then dy = dy - 1 end

                                                            if stick.active then
                                                                dx, dy = stick.dx, stick.dy
                                                                end

                                                                local len = math.sqrt(dx*dx + dy*dy)
                                                                if len > 1 then dx, dy = dx / len, dy / len end
                                                                    return dx, dy
                                                                    end

                                                                    function love.update(dt)
                                                                    if levelTransition > 0 then
                                                                        levelTransition = levelTransition - dt
                                                                        end

                                                                        if win or lose then
                                                                            if love.keyboard.isDown("r") then restartGame() end
                                                                                return
                                                                                end

                                                                                timeAlive = timeAlive + dt
                                                                                tauntTimer = tauntTimer - dt
                                                                                invertTimer = invertTimer - dt
                                                                                frozenTimer = frozenTimer - dt
                                                                                fakeLagTimer = fakeLagTimer - dt

                                                                                if tauntTimer <= 0 then
                                                                                    taunt = taunts[math.random(#taunts)]
                                                                                    tauntTimer = cfg.tauntEvery
                                                                                    end

                                                                                    if invertTimer <= -cfg.invertEvery and math.random() < 0.02 then
                                                                                        invertTimer = 3.5
                                                                                        taunt = "УПРАВЛЕНИЕ ПЕРЕВЁРНУТО! ха-ха"
                                                                                        tauntTimer = 3.5
                                                                                        end

                                                                                        if frozenTimer <= -cfg.frozenEvery and math.random() < 0.015 then
                                                                                            frozenTimer = 1.2
                                                                                            taunt = "ЗАМОРОЗКА!"
                                                                                            tauntTimer = 1.5
                                                                                            end

                                                                                            if fakeLagTimer <= 0 then
                                                                                                fakeLag = 0.4
                                                                                                fakeLagTimer = cfg.lagEvery
                                                                                                taunt = "...зависла? Шутка"
                                                                                                tauntTimer = 2
                                                                                                end
                                                                                                if fakeLag > 0 then fakeLag = fakeLag - dt end

                                                                                                    local inverted = invertTimer > 0
                                                                                                    local frozen = frozenTimer > 0
                                                                                                    local faking = fakeLag > 0
                                                                                                    local onTransition = levelTransition > 0

                                                                                                    if not frozen and not faking and not onTransition then
                                                                                                        local dx, dy = getInputDirection()
                                                                                                        if inverted then dx, dy = -dx, -dy end

                                                                                                            player.x = player.x + dx * player.speed * dt
                                                                                                            player.y = player.y + dy * player.speed * dt
                                                                                                            end

                                                                                                            local w, h = love.graphics.getDimensions()
                                                                                                            player.x = math.max(0, math.min(w - player.size, player.x))
                                                                                                            player.y = math.max(0, math.min(h - player.size, player.y))

                                                                                                            if cfg.shrink and not onTransition then
                                                                                                                local minX, minY = 20, 20
                                                                                                                local maxX, maxY = w - 20, h - 20
                                                                                                                player.x = math.max(minX, math.min(maxX - player.size, player.x))
                                                                                                                player.y = math.max(minY, math.min(maxY - player.size, player.y))
                                                                                                                end

                                                                                                                if cfg.starSpeed and cfg.starSpeed > 0 and not onTransition then
                                                                                                                    stars.x = stars.x + starVel.x * dt
                                                                                                                    stars.y = stars.y + starVel.y * dt

                                                                                                                    if stars.x < 60 or stars.x > w - 60 then starVel.x = -starVel.x end
                                                                                                                        if stars.y < 60 or stars.y > h - 60 then starVel.y = -starVel.y end
                                                                                                                            stars.x = math.max(60, math.min(w - 60, stars.x))
                                                                                                                            stars.y = math.max(60, math.min(h - 60, stars.y))
                                                                                                                            end

                                                                                                                            if math.random() < 0.01 then
                                                                                                                                starOffsetX = math.random(-20, 20)
                                                                                                                                starOffsetY = math.random(-20, 20)
                                                                                                                                end

                                                                                                                                local px, py = player.x + player.size/2, player.y + player.size/2
                                                                                                                                local sx, sy = stars.x + stars.size/2, stars.y + stars.size/2
                                                                                                                                if math.abs(px - sx) < 30 and math.abs(py - sy) < 30 and not onTransition then
                                                                                                                                    score = score + 1
                                                                                                                                    if score >= needed then
                                                                                                                                        nextLevel()
                                                                                                                                        else
                                                                                                                                            resetStar()
                                                                                                                                            if math.random() < 0.4 then
                                                                                                                                                player.x = math.random(0, w - player.size)
                                                                                                                                                player.y = math.random(0, h - player.size)
                                                                                                                                                taunt = "БУ! Испугался?"
                                                                                                                                                tauntTimer = 2
                                                                                                                                                end
                                                                                                                                                end
                                                                                                                                                end

                                                                                                                                                if not onTransition then
                                                                                                                                                    for i = #fakeStars, 1, -1 do
                                                                                                                                                        local f = fakeStars[i]
                                                                                                                                                        local fx = f.x + f.size/2
                                                                                                                                                        local fy = f.y + f.size/2
                                                                                                                                                        if math.abs(px - fx) < 30 and math.abs(py - fy) < 30 then
                                                                                                                                                            score = math.max(0, score - 1)
                                                                                                                                                            table.remove(fakeStars, i)
                                                                                                                                                            local nfx, nfy = randomStarPos()
                                                                                                                                                            table.insert(fakeStars, { x = nfx, y = nfy, size = 22 })
                                                                                                                                                            player.x = math.random(0, w - player.size)
                                                                                                                                                            player.y = math.random(0, h - player.size)
                                                                                                                                                            taunt = "ЭТО БЫЛА ЛОЖНАЯ ЗВЕЗДА!"
                                                                                                                                                            tauntTimer = 2
                                                                                                                                                            end
                                                                                                                                                            end
                                                                                                                                                            end
                                                                                                                                                            end

                                                                                                                                                            local function drawStick()
                                                                                                                                                            love.graphics.setColor(1, 1, 1, 0.12)
                                                                                                                                                            love.graphics.circle("fill", stick.baseX, stick.baseY, stick.radius)
                                                                                                                                                            love.graphics.setColor(1, 1, 1, 0.35)
                                                                                                                                                            love.graphics.circle("line", stick.baseX, stick.baseY, stick.radius)

                                                                                                                                                            love.graphics.setColor(1, 1, 1, stick.active and 0.7 or 0.35)
                                                                                                                                                            love.graphics.circle("fill", stick.knobX, stick.knobY, stick.knobRadius)
                                                                                                                                                            end

                                                                                                                                                            function love.draw()
                                                                                                                                                            local w, h = love.graphics.getDimensions()

                                                                                                                                                            if cfg.shrink then
                                                                                                                                                                love.graphics.setColor(1, 0.3, 0.3, 0.25)
                                                                                                                                                                love.graphics.rectangle("line", 20, 20, w - 40, h - 40, 8, 8)
                                                                                                                                                                end

                                                                                                                                                                for _, f in ipairs(fakeStars) do
                                                                                                                                                                    love.graphics.setColor(1, 1, 1, 0.25)
                                                                                                                                                                    love.graphics.circle("fill", f.x + f.size/2, f.y + f.size/2, f.size/2)
                                                                                                                                                                    end

                                                                                                                                                                    local sx = stars.x + starOffsetX
                                                                                                                                                                    local sy = stars.y + starOffsetY
                                                                                                                                                                    love.graphics.setColor(1, 0.9, 0.2)
                                                                                                                                                                    love.graphics.circle("fill", sx + stars.size/2, sy + stars.size/2, stars.size/2)
                                                                                                                                                                    love.graphics.setColor(1, 1, 1, 0.4)
                                                                                                                                                                    love.graphics.circle("line", sx + stars.size/2, sy + stars.size/2, stars.size/2 + 4)

                                                                                                                                                                    local pc = { 0.3, 0.9, 0.5 }
                                                                                                                                                                    if invertTimer > 0 then pc = { 1, 0.3, 0.3 } end
                                                                                                                                                                        if frozenTimer > 0 then pc = { 0.5, 0.7, 1 } end
                                                                                                                                                                            love.graphics.setColor(pc)
                                                                                                                                                                            love.graphics.rectangle("fill", player.x, player.y, player.size, player.size)

                                                                                                                                                                            drawStick()

                                                                                                                                                                            love.graphics.setColor(1, 1, 1)
                                                                                                                                                                            love.graphics.print("Уровень: " .. level .. " / " .. maxLevel, 10, 10)
                                                                                                                                                                            love.graphics.print("Собрано: " .. score .. " / " .. needed, 10, 30)
                                                                                                                                                                            love.graphics.print("Время: " .. string.format("%.1f", timeAlive) .. " сек", 10, 50)

                                                                                                                                                                            if taunt ~= "" then
                                                                                                                                                                                love.graphics.setColor(1, 0.8, 0.3)
                                                                                                                                                                                love.graphics.printf(taunt, 10, h - 30, w - 160, "left")
                                                                                                                                                                                end

                                                                                                                                                                                if levelTransition > 0 then
                                                                                                                                                                                    local alpha = math.min(1, levelTransition * 2)
                                                                                                                                                                                    love.graphics.setColor(0, 0, 0, 0.7 * alpha)
                                                                                                                                                                                    love.graphics.rectangle("fill", 0, 0, w, h)
                                                                                                                                                                                    love.graphics.setColor(1, 1, 1, alpha)
                                                                                                                                                                                    love.graphics.printf(transitionText, 0, h/2 - 20, w, "center")
                                                                                                                                                                                    love.graphics.printf("Собери " .. needed .. " звёзд", 0, h/2 + 10, w, "center")
                                                                                                                                                                                    end

                                                                                                                                                                                    if fakeLag > 0 then
                                                                                                                                                                                        love.graphics.setColor(0, 0, 0, 0.9)
                                                                                                                                                                                        love.graphics.rectangle("fill", 0, 0, w, h)
                                                                                                                                                                                        love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                        love.graphics.printf("НЕ ОТВЕЧАЕТ...", 0, h/2, w, "center")
                                                                                                                                                                                        end

                                                                                                                                                                                        if win then
                                                                                                                                                                                            love.graphics.setColor(0, 0, 0, 0.75)
                                                                                                                                                                                            love.graphics.rectangle("fill", 0, 0, w, h)
                                                                                                                                                                                            love.graphics.setColor(0.4, 1, 0.5)
                                                                                                                                                                                            love.graphics.printf("ПОБЕДА! Ты выжил все уровни!", 0, h/2 - 50, w, "center")
                                                                                                                                                                                            love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                            love.graphics.printf("Итог: " .. maxLevel .. " уровней за " ..
                                                                                                                                                                                            string.format("%.1f", timeAlive) .. " сек\n" ..
                                                                                                                                                                                            "R или тап — сыграть заново", 0, h/2, w, "center")
                                                                                                                                                                                            elseif lose then
                                                                                                                                                                                                love.graphics.setColor(1, 0.3, 0.3)
                                                                                                                                                                                                love.graphics.printf("Ты проиграл. R или тап — попробовать снова.", 0, h/2, w, "center")
                                                                                                                                                                                                end
                                                                                                                                                                                                end

                                                                                                                                                                                                function love.resize(w, h)
                                                                                                                                                                                                clampToWindow()
                                                                                                                                                                                                layoutStick()
                                                                                                                                                                                                end

                                                                                                                                                                                                function love.keypressed(key)
                                                                                                                                                                                                if key == "escape" then
                                                                                                                                                                                                    love.event.quit()
                                                                                                                                                                                                    elseif key == "f11" then
                                                                                                                                                                                                        local full = love.window.getFullscreen()
                                                                                                                                                                                                        love.window.setFullscreen(not full, "desktop")
                                                                                                                                                                                                        clampToWindow()
                                                                                                                                                                                                        layoutStick()
                                                                                                                                                                                                        elseif key == "r" and (win or lose) then
                                                                                                                                                                                                            restartGame()
                                                                                                                                                                                                            end
                                                                                                                                                                                                            end

                                                                                                                                                                                                            -- =======================
                                                                                                                                                                                                            --   СЕНСОРНОЕ УПРАВЛЕНИЕ
                                                                                                                                                                                                            -- =======================

                                                                                                                                                                                                            function updateStickVector(x, y)
                                                                                                                                                                                                            local dx = x - stick.baseX
                                                                                                                                                                                                            local dy = y - stick.baseY
                                                                                                                                                                                                            local dist = math.sqrt(dx*dx + dy*dy)

                                                                                                                                                                                                            local maxDist = stick.radius
                                                                                                                                                                                                            if dist > maxDist then
                                                                                                                                                                                                                dx = dx / dist * maxDist
                                                                                                                                                                                                                dy = dy / dist * maxDist
                                                                                                                                                                                                                end

                                                                                                                                                                                                                stick.knobX = stick.baseX + dx
                                                                                                                                                                                                                stick.knobY = stick.baseY + dy

                                                                                                                                                                                                                local deadzone = 0.15
                                                                                                                                                                                                                local nx = dx / maxDist
                                                                                                                                                                                                                local ny = dy / maxDist
                                                                                                                                                                                                                local nlen = math.sqrt(nx*nx + ny*ny)
                                                                                                                                                                                                                if nlen < deadzone then
                                                                                                                                                                                                                    stick.dx = 0
                                                                                                                                                                                                                    stick.dy = 0
                                                                                                                                                                                                                    else
                                                                                                                                                                                                                        stick.dx = nx
                                                                                                                                                                                                                        stick.dy = ny
                                                                                                                                                                                                                        end
                                                                                                                                                                                                                        end

                                                                                                                                                                                                                        function love.touchpressed(id, x, y, dx, dy, pressure)
                                                                                                                                                                                                                        if win or lose then
                                                                                                                                                                                                                            restartGame()
                                                                                                                                                                                                                            return
                                                                                                                                                                                                                            end

                                                                                                                                                                                                                            local dist = math.sqrt((x - stick.baseX)^2 + (y - stick.baseY)^2)
                                                                                                                                                                                                                            if not stick.active and dist <= stick.radius * 1.6 then
                                                                                                                                                                                                                                stick.active = true
                                                                                                                                                                                                                                stick.id = id
                                                                                                                                                                                                                                stick.knobX = x
                                                                                                                                                                                                                                stick.knobY = y
                                                                                                                                                                                                                                updateStickVector(x, y)
                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                function love.touchmoved(id, x, y, dx, dy, pressure)
                                                                                                                                                                                                                                if stick.active and id == stick.id then
                                                                                                                                                                                                                                    updateStickVector(x, y)
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                    function love.touchreleased(id, x, y, dx, dy, pressure)
                                                                                                                                                                                                                                    if stick.active and id == stick.id then
                                                                                                                                                                                                                                        stick.active = false
                                                                                                                                                                                                                                        stick.id = nil
                                                                                                                                                                                                                                        stick.dx = 0
                                                                                                                                                                                                                                        stick.dy = 0
                                                                                                                                                                                                                                        stick.knobX = stick.baseX
                                                                                                                                                                                                                                        stick.knobY = stick.baseY
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        end

                                                                                                                                                                                                                                        -- =======================
                                                                                                                                                                                                                                        --   МЫШЬ (для ПК)
                                                                                                                                                                                                                                        -- =======================

                                                                                                                                                                                                                                        function love.mousepressed(x, y, button)
                                                                                                                                                                                                                                        if button ~= 1 then return end

                                                                                                                                                                                                                                            if win or lose then
                                                                                                                                                                                                                                                restartGame()
                                                                                                                                                                                                                                                return
                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                local dist = math.sqrt((x - stick.baseX)^2 + (y - stick.baseY)^2)
                                                                                                                                                                                                                                                if dist <= stick.radius * 1.6 then
                                                                                                                                                                                                                                                    stick.active = true
                                                                                                                                                                                                                                                    stick.id = "mouse"
                                                                                                                                                                                                                                                    stick.knobX = x
                                                                                                                                                                                                                                                    stick.knobY = y
                                                                                                                                                                                                                                                    updateStickVector(x, y)
                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                                    function love.mousemoved(x, y)
                                                                                                                                                                                                                                                    if stick.active and stick.id == "mouse" then
                                                                                                                                                                                                                                                        updateStickVector(x, y)
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                        end

                                                                                                                                                                                                                                                        function love.mousereleased(x, y, button)
                                                                                                                                                                                                                                                        if button == 1 and stick.active and stick.id == "mouse" then
                                                                                                                                                                                                                                                            stick.active = false
                                                                                                                                                                                                                                                            stick.id = nil
                                                                                                                                                                                                                                                            stick.dx = 0
                                                                                                                                                                                                                                                            stick.dy = 0
                                                                                                                                                                                                                                                            stick.knobX = stick.baseX
                                                                                                                                                                                                                                                            stick.knobY = stick.baseY
                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                            end
