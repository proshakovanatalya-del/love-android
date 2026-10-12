-- main.lua
-- «Математический параноик» — тренажёр устного счёта с троллингом.
-- Темы: арифметика, степени, логарифмы, проценты, тригонометрия.
-- Языки: русский, английский. Адаптивное меню под любой размер экрана.
-- Плавное управление джойстиком. Совместимость с разными GPU Android
-- (нет circle("fill") и полупрозрачных заливок).

-- ========================
--   ЯЗЫКИ
-- ========================
local L = {}
local lang = "ru"

local locales = {
    ru = {
        title = "МАТЕМАТИЧЕСКИЙ ПАРАНОИК",
        subtitle = "Тренажёр устного счёта с троллингом",
        chooseLang = "Язык",
        chooseTopic = "Тема",
        start = "Начать игру",
        controlsPC = "Стрелки — движение. F11 — fullscreen. Esc — выход.",
        controlsMobile = "Водите пальцем в левом нижнем углу — движение.",
        topics = {
            arith    = "Арифметика",
            powers   = "Степени и корни",
            logs     = "Логарифмы",
            percent  = "Проценты",
            trig     = "Тригонометрия",
        },
        level = "Уровень",
        correct = "Верно",
        of = "из",
        time = "Время",
        sec = "сек",
        solve = "Реши",
        examples = "примеров",
        winTitle = "ГОТОВО! Все уровни пройдены",
        statCorrect = "Верных ответов",
        statWrong = "Ошибок",
        statAcc = "Точность",
        statFast = "Самый быстрый ответ",
        restartHint = "R или тап — сыграть заново",
        wrongAnswer = "ЭТО БЫЛ НЕПРАВИЛЬНЫЙ ОТВЕТ!",
        taunts = {
            "Ты уверен, что это правильный ответ?",
            "Ой, я случайно поменял числа местами. Извини.",
            "Ты слишком медленно считаешь.",
            "Не доверяй первому ответу.",
            "Кто вообще придумал эту математику?",
            "Хм, кажется, я перевернул управление...",
            "Ты почти у цели. Почти.",
            "Я слежу за твоим счётом.",
            "Может, посчитать на калькуляторе?",
            "Это не баг, это проверка.",
            "Ответ где-то рядом... или нет.",
            "Осторожно, среди ответов есть обманки!",
        },
    },
    en = {
        title = "MATH PARANOID",
        subtitle = "Mental arithmetic trainer with trolling",
        chooseLang = "Language",
        chooseTopic = "Topic",
        start = "Start Game",
        controlsPC = "Arrows — move. F11 — fullscreen. Esc — exit.",
        controlsMobile = "Drag finger in bottom-left corner to move.",
        topics = {
            arith    = "Arithmetic",
            powers   = "Powers & Roots",
            logs     = "Logarithms",
            percent  = "Percentages",
            trig     = "Trigonometry",
        },
        level = "Level",
        correct = "Correct",
        of = "of",
        time = "Time",
        sec = "sec",
        solve = "Solve",
        examples = "problems",
        winTitle = "DONE! All levels cleared",
        statCorrect = "Correct answers",
        statWrong = "Mistakes",
        statAcc = "Accuracy",
        statFast = "Fastest answer",
        restartHint = "R or tap — play again",
        wrongAnswer = "THAT WAS THE WRONG ANSWER!",
        taunts = {
            "Are you sure that's the right answer?",
            "Oops, I swapped the numbers. Sorry.",
            "You're counting too slowly.",
            "Don't trust the first answer.",
            "Who invented this math anyway?",
            "Hmm, I think I flipped the controls...",
            "You're almost there. Almost.",
            "I'm watching your score.",
            "Maybe use a calculator?",
            "It's not a bug, it's a feature.",
            "The answer is somewhere near... or not.",
            "Careful, some answers are decoys!",
        },
    },
}

local function setLang(code)
    lang = code
    L = locales[code]
end

-- ========================
--   ОБЪЯВЛЕНИЯ
-- ========================
local player, score, needed
local timeAlive, tauntTimer, taunt
local invertTimer, frozenTimer, fakeLagTimer, fakeLag
local win, lose
local font

local level = 1
local maxLevel = 8
local levelTransition = 0
local transitionText = ""

local scene = "menu"
local topic = "arith"
local topicList = { "arith", "powers", "logs", "percent", "trig" }
local langList = { "ru", "en" }

local levelFeatures = {
    movingAnswers = 2,
    fakeAnswers   = 3,
    shrinkArena   = 5,
}

local cfg = {}

local problem = {
    text = "",
    answer = 0,
    options = {},
    isString = false,
}
local correctIndex = 1

local stats = { correct = 0, wrong = 0, fastest = math.huge }

local stick = {
    active = false,
    baseX = 0, baseY = 0,
    knobX = 0, knobY = 0,
    radius = 70,
    knobRadius = 30,
    id = nil,
    dx = 0, dy = 0,
    targetDx = 0, targetDy = 0,
}

local arena = { x = 0, y = 0, w = 0, h = 0 }

-- ========================
--   ГЕНЕРАТОРЫ
-- ========================
local function makeOptions(ans, spread, allowNegative)
    local opts = { ans }
    local used = { [ans] = true }
    local attempts = 0
    while #opts < 4 and attempts < 100 do
        attempts = attempts + 1
        local delta = math.random(-spread, spread)
        if delta == 0 then delta = 1 end
        local fake = ans + delta
        if not allowNegative and fake < 0 then fake = math.abs(fake) end
        if not used[fake] then
            used[fake] = true
            table.insert(opts, fake)
        end
    end
    while #opts < 4 do
        local fake = ans + #opts
        if not used[fake] then
            used[fake] = true
            table.insert(opts, fake)
        end
    end
    return opts
end

local function genArith(n)
    local kind
    local r = math.random()
    if n <= 1 then kind = "add"
    elseif n <= 3 then kind = (r < 0.5) and "add" or "sub"
    elseif n <= 5 then kind = (r < 0.4) and "add" or (r < 0.8 and "sub" or "mul")
    else kind = (r < 0.25) and "add" or (r < 0.5) and "sub" or (r < 0.8) and "mul" or "div"
    end

    local a, b, ans, text
    if kind == "add" then
        local m = 5 + n * 3
        a, b = math.random(1, m), math.random(1, m)
        ans = a + b
        text = a .. " + " .. b .. " = ?"
    elseif kind == "sub" then
        local m = 5 + n * 3
        a = math.random(2, m)
        b = math.random(1, a - 1)
        ans = a - b
        text = a .. " − " .. b .. " = ?"
    elseif kind == "mul" then
        local m = 3 + math.min(n, 7)
        a, b = math.random(2, m), math.random(2, m)
        ans = a * b
        text = a .. " × " .. b .. " = ?"
    else
        b = math.random(2, 3 + math.min(n, 6))
        ans = math.random(2, 3 + math.min(n, 6))
        a = ans * b
        text = a .. " ÷ " .. b .. " = ?"
    end
    return text, ans, 3, false
end

local function genPowers(n)
    local kind = math.random()
    local a, b, ans, text
    if kind < 0.5 then
        local maxA = 3 + math.min(n, 6)
        local maxB = 2 + math.min(math.floor(n / 2), 3)
        a = math.random(2, maxA)
        b = math.random(2, maxB)
        ans = a ^ b
        text = a .. "^" .. b .. " = ?"
    elseif kind < 0.8 then
        a = math.random(2, 5 + n)
        ans = a
        text = "√" .. (a * a) .. " = ?"
    else
        a = math.random(2, 3 + math.floor(n / 2))
        ans = a
        text = "∛" .. (a * a * a) .. " = ?"
    end
    return text, ans, math.max(2, math.floor(ans * 0.15)), false
end

local function genLogs(n)
    local kind = math.random()
    local base, arg, ans, text
    if kind < 0.6 then
        local bases = { 2, 3, 5, 10 }
        base = bases[math.random(#bases)]
        local k = math.random(1, 3 + math.min(n, 4))
        arg = base ^ k
        ans = k
        text = "log_" .. base .. "(" .. arg .. ") = ?"
    elseif kind < 0.85 then
        local k = math.random(1, 4 + math.min(n, 3))
        arg = 10 ^ k
        ans = k
        text = "lg(" .. arg .. ") = ?"
    else
        local k = math.random(1, 3 + math.min(n, 3))
        ans = k
        text = "ln(e^" .. k .. ") = ?"
    end
    return text, ans, 2, false
end

local function genPercent(n)
    local kind = math.random()
    local a, p, ans, text
    if kind < 0.5 then
        local percents = { 5, 10, 20, 25, 50, 75 }
        p = percents[math.random(#percents)]
        a = math.random(1, 10 + n * 4) * 20
        ans = math.floor(a * p / 100)
        text = p .. "% от " .. a .. " = ?"
    else
        local percents = { 10, 20, 25, 50 }
        p = percents[math.random(#percents)]
        ans = math.random(2, 6 + n) * 20
        a = math.floor(ans * p / 100)
        text = a .. " — это " .. p .. "% от ?"
    end
    return text, ans, math.max(2, math.floor(ans * 0.2)), false
end

local function genTrig(n)
    local kind = math.random()
    local text, ans
    if kind < 0.5 then
        local angles = {
            { a = 0,   sin = "0", cos = "1", tg = "0" },
            { a = 30,  sin = "1/2", cos = "√3/2", tg = "1/√3" },
            { a = 45,  sin = "√2/2", cos = "√2/2", tg = "1" },
            { a = 60,  sin = "√3/2", cos = "1/2", tg = "√3" },
            { a = 90,  sin = "1", cos = "0", tg = "—" },
        }
        local pick = angles[math.random(#angles)]
        local func = ({"sin", "cos", "tg"})[math.random(3)]
        if func == "sin" then
            text = "sin(" .. pick.a .. "°) = ?"
            ans = pick.sin
        elseif func == "cos" then
            text = "cos(" .. pick.a .. "°) = ?"
            ans = pick.cos
        else
            text = "tg(" .. pick.a .. "°) = ?"
            ans = pick.tg
        end
        return text, ans, 0, true
    else
        text = "sin²x + cos²x = ?"
        ans = "1"
        return text, ans, 0, true
    end
end

local generators = {
    arith   = genArith,
    powers  = genPowers,
    logs    = genLogs,
    percent = genPercent,
    trig    = genTrig,
}

-- ========================
--   РАССТАНОВКА ВАРИАНТОВ
-- ========================
local function getOptionPositions()
    local w, h = love.graphics.getDimensions()
    local r = math.min(45, math.floor(w * 0.11))
    r = math.max(r, 30)

    local padX = r + 30
    local safeTop = math.max(40, math.floor(h * 0.055))
    local padTop = safeTop + 100
    local padBottom = 190
    local usableH = math.max(100, h - padTop - padBottom)

    return {
        { padX,     padTop + usableH * 0.25 },
        { w - padX, padTop + usableH * 0.25 },
        { padX,     padTop + usableH * 0.75 },
        { w - padX, padTop + usableH * 0.75 },
    }, r
end

local function repositionOptions()
    if not problem.options or #problem.options == 0 then return end
    local positions = getOptionPositions()
    for i, o in ipairs(problem.options) do
        if positions[i] then
            o.x = positions[i][1]
            o.y = positions[i][2]
            if level >= levelFeatures.movingAnswers then
                local spd = 30 + (level - levelFeatures.movingAnswers) * 15
                local ang = math.random() * math.pi * 2
                o.vx = math.cos(ang) * spd
                o.vy = math.sin(ang) * spd
            end
        end
    end
end

local function makeProblem(n)
    local gen = generators[topic] or genArith
    local text, ans, spread, isString = gen(n)

    problem.text = text
    problem.answer = ans
    problem.isString = isString

    local opts
    if isString then
        local pool = { "0", "1", "1/2", "√2/2", "√3/2", "1/√3", "√3", "—" }
        opts = { ans }
        local used = { [ans] = true }
        while #opts < 4 do
            local cand = pool[math.random(#pool)]
            if not used[cand] then
                used[cand] = true
                table.insert(opts, cand)
            end
        end
    else
        opts = makeOptions(ans, math.max(2, spread), false)
    end

    for i = #opts, 2, -1 do
        local j = math.random(i)
        opts[i], opts[j] = opts[j], opts[i]
    end

    for i, v in ipairs(opts) do
        if v == ans then correctIndex = i break end
    end

    problem.options = {}
    for _, v in ipairs(opts) do
        table.insert(problem.options, {
            x = 0, y = 0,
            value = v,
            vx = 0, vy = 0,
        })
    end

    repositionOptions()
end

-- ========================
--   ВСПОМОГАТЕЛЬНЫЕ
-- ========================
local function layoutStick()
    local w, h = love.graphics.getDimensions()
    stick.radius = math.min(70, math.floor(w * 0.18))
    stick.radius = math.max(stick.radius, 45)
    stick.knobRadius = math.floor(stick.radius * 0.43)

    stick.baseX = stick.radius + 30
    stick.baseY = h - stick.radius - 60
    if not stick.active then
        stick.knobX = stick.baseX
        stick.knobY = stick.baseY
    end
end

local function clampToWindow()
    local w, h = love.graphics.getDimensions()
    if player then
        player.x = math.max(0, math.min(w - player.size, player.x))
        player.y = math.max(80, math.min(h - player.size - 80, player.y))
    end
    arena.x, arena.y, arena.w, arena.h = 0, 0, w, h
end

-- ========================
--   УРОВНИ
-- ========================
local function loadLevel(n)
    level = n

    cfg = {
        needed      = 5 + n,
        speed       = 260 + n * 15,
        tauntEvery  = math.max(1.5, 3.5 - n * 0.2),
        invertEvery = math.max(5.0, 10.0 - n * 0.5),
        frozenEvery = math.max(6.0, 12.0 - n * 0.6),
        lagEvery    = math.max(7.0, 14.0 - n * 0.7),
        shrink      = (n >= levelFeatures.shrinkArena),
    }

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

    stats = { correct = 0, wrong = 0, fastest = math.huge }

    local w, h = love.graphics.getDimensions()
    arena.x, arena.y, arena.w, arena.h = 0, 0, w, h

    player.x = w/2 - player.size/2
    player.y = h/2 - player.size/2

    makeProblem(n)

    transitionText = L.level .. " " .. n .. (n == maxLevel and " — FINAL!" or "")
    levelTransition = 1.6
end

local function nextLevel()
    if level >= maxLevel then
        win = true
        return
    end
    loadLevel(level + 1)
end

local function startGame()
    scene = "game"
    player = player or { x = 400, y = 300, size = 40, speed = 260 }
    loadLevel(1)
end

-- ========================
--   LÖVE CALLBACKS
-- ========================
function love.load()
    love.window.setMode(720, 1280, {
        resizable = true,
        minwidth = 400,
        minheight = 500,
    })
    love.window.setTitle("Math Paranoid / Математический параноик")
    love.graphics.setBackgroundColor(0.08, 0.08, 0.12)

    local ok, loaded = pcall(love.graphics.newFont, "font.ttf", 18)
    if ok then
        font = loaded
    else
        font = love.graphics.newFont(18)
        print("WARNING / ВНИМАНИЕ: font.ttf not found, using default font.")
    end
    love.graphics.setFont(font)

    setLang("ru")
    player = { x = 450, y = 350, size = 40, speed = 260 }
    layoutStick()
end

local function getInputDirection()
    local dx, dy = 0, 0
    if love.keyboard.isDown("right") then dx = dx + 1 end
    if love.keyboard.isDown("left")  then dx = dx - 1 end
    if love.keyboard.isDown("down")  then dy = dy + 1 end
    if love.keyboard.isDown("up")    then dy = dy - 1 end

    if stick.active
        or math.abs(stick.dx) > 0.01
        or math.abs(stick.dy) > 0.01 then
        dx, dy = stick.dx, stick.dy
    end

    local len = math.sqrt(dx*dx + dy*dy)
    if len > 1 then dx, dy = dx / len, dy / len end
    return dx, dy
end

function love.update(dt)
    if scene == "menu" then return end

    if levelTransition > 0 then
        levelTransition = levelTransition - dt
    end

    if win or lose then
        if love.keyboard.isDown("r") then startGame() end
        return
    end

    timeAlive = timeAlive + dt
    tauntTimer = tauntTimer - dt
    invertTimer = invertTimer - dt
    frozenTimer = frozenTimer - dt
    fakeLagTimer = fakeLagTimer - dt

    if tauntTimer <= 0 then
        local list = L.taunts
        taunt = list[math.random(#list)]
        tauntTimer = cfg.tauntEvery
    end

    if invertTimer <= -cfg.invertEvery and math.random() < 0.02 then
        invertTimer = 3.5
        taunt = L.taunts[math.random(#L.taunts)]
        tauntTimer = 3.5
    end

    if frozenTimer <= -cfg.frozenEvery and math.random() < 0.015 then
        frozenTimer = 1.2
        taunt = L.taunts[math.random(#L.taunts)]
        tauntTimer = 1.5
    end

    if fakeLagTimer <= 0 then
        fakeLag = 0.4
        fakeLagTimer = cfg.lagEvery
        taunt = L.taunts[math.random(#L.taunts)]
        tauntTimer = 2
    end
    if fakeLag > 0 then fakeLag = fakeLag - dt end

    local inverted = invertTimer > 0
    local frozen = frozenTimer > 0
    local faking = fakeLag > 0
    local onTransition = levelTransition > 0

    local accelSpeed = 12
    local smoothFactor = math.min(1, accelSpeed * dt)
    stick.dx = stick.dx + (stick.targetDx - stick.dx) * smoothFactor
    stick.dy = stick.dy + (stick.targetDy - stick.dy) * smoothFactor

    if not stick.active then
        stick.targetDx = 0
        stick.targetDy = 0
    end

    if not frozen and not faking and not onTransition then
        local dx, dy = getInputDirection()
        if inverted then dx, dy = -dx, -dy end
        player.x = player.x + dx * player.speed * dt
        player.y = player.y + dy * player.speed * dt
    end

    local w, h = love.graphics.getDimensions()
    local safeTop = math.max(40, math.floor(h * 0.055))
    player.x = math.max(0, math.min(w - player.size, player.x))
    player.y = math.max(safeTop + 70, math.min(h - player.size - 90, player.y))

    if cfg.shrink and not onTransition then
        player.x = math.max(30, math.min(w - 30 - player.size, player.x))
        player.y = math.max(safeTop + 90, math.min(h - 90 - player.size, player.y))
    end

    if level >= levelFeatures.movingAnswers and not onTransition then
        local padX = 70
        local minY = safeTop + 130
        local maxY = h - 200
        for _, o in ipairs(problem.options) do
            o.x = o.x + o.vx * dt
            o.y = o.y + o.vy * dt
            if o.x < padX or o.x > w - padX then o.vx = -o.vx end
            if o.y < minY or o.y > maxY then o.vy = -o.vy end
            o.x = math.max(padX, math.min(w - padX, o.x))
            o.y = math.max(minY, math.min(maxY, o.y))
        end
    end

    if not onTransition then
        local px = player.x + player.size/2
        local py = player.y + player.size/2
        for i, o in ipairs(problem.options) do
            local ddx = px - o.x
            local ddy = py - o.y
            if ddx*ddx + ddy*ddy < 45*45 then
                if i == correctIndex then
                    score = score + 1
                    stats.correct = stats.correct + 1
                    if timeAlive < stats.fastest then stats.fastest = timeAlive end
                    if score >= needed then
                        nextLevel()
                    else
                        makeProblem(level)
                        player.x = w/2 - player.size/2
                        player.y = h/2 - player.size/2
                    end
                else
                    stats.wrong = stats.wrong + 1
                    score = math.max(0, score - 1)
                    player.x = math.random(60, math.max(61, w - 60 - player.size))
                    player.y = math.random(safeTop + 110, math.max(safeTop + 111, h - 100 - player.size))
                    taunt = L.wrongAnswer
                    tauntTimer = 2
                    makeProblem(level)
                end
                break
            end
        end
    end
end

-- Джойстик: только circle("line"), без заливки
local function drawStick()
    local rings = math.max(8, math.floor(stick.radius / 2))
    for i = rings, 1, -1 do
        local rr = stick.radius * (i / rings)
        love.graphics.setColor(1, 1, 1, 0.10)
        love.graphics.circle("line", stick.baseX, stick.baseY, rr)
    end
    love.graphics.setColor(1, 1, 1, 0.4)
    love.graphics.circle("line", stick.baseX, stick.baseY, stick.radius)

    local knobRings = math.max(5, math.floor(stick.knobRadius / 2))
    local knobAlpha = stick.active and 0.7 or 0.35
    for i = knobRings, 1, -1 do
        local rr = stick.knobRadius * (i / knobRings)
        love.graphics.setColor(1, 1, 1, knobAlpha)
        love.graphics.circle("line", stick.knobX, stick.knobY, rr)
    end
end

-- ========================
--   АДАПТИВНОЕ МЕНЮ
-- ========================
local function getMenuLayout()
    local w, h = love.graphics.getDimensions()

    local narrow = w < 600
    local cols = narrow and 1 or 3

    local bw = narrow and math.min(w - 60, 400) or 200
    local bh = narrow and 56 or 50
    local gap = 12

    local hasTouch = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
    if love.touch and love.touch.getTouches then
        local touches = love.touch.getTouches()
        if #touches > 0 then hasTouch = true end
    end

    local langBtns = {}
    local langW = narrow and math.min((w - 60 - gap) / 2, 180) or 110
    local langH = 44
    local langTotalW = #langList * langW + (#langList - 1) * gap
    local langY = 170
    for i, code in ipairs(langList) do
        local bx = w/2 - langTotalW/2 + (i - 1) * (langW + gap)
        table.insert(langBtns, { code = code, x = bx, y = langY, w = langW, h = langH })
    end

    local topicBtns = {}
    local startX = w/2 - (cols * bw + (cols - 1) * gap) / 2
    local topicStartY = 260
    for i, t in ipairs(topicList) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local bx = startX + col * (bw + gap)
        local by = topicStartY + row * (bh + gap)
        table.insert(topicBtns, { topic = t, x = bx, y = by, w = bw, h = bh })
    end

    local rows = math.ceil(#topicList / cols)
    local startY = topicStartY + rows * (bh + gap) + 20
    local startW = narrow and math.min(w - 60, 300) or 260
    local startBtn = {
        x = w/2 - startW/2,
        y = startY,
        w = startW,
        h = 60,
    }

    return {
        w = w, h = h,
        narrow = narrow,
        hasTouch = hasTouch,
        langBtns = langBtns,
        topicBtns = topicBtns,
        startBtn = startBtn,
    }
end

-- Меню: непрозрачные заливки + рамки (совместимо с любым GPU)
local function drawMenu()
    local M = getMenuLayout()
    local w, h = M.w, M.h

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(L.title, 20, 40, w - 40, "center")
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.printf(L.subtitle, 20, 90, w - 40, "center")

    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.printf(L.chooseLang, 0, 145, w, "center")

    for _, b in ipairs(M.langBtns) do
        if b.code == lang then
            love.graphics.setColor(0.3, 0.7, 1.0)
            love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 6, 6)
            love.graphics.setColor(0, 0, 0)
        else
            love.graphics.setColor(0.15, 0.15, 0.2)
            love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 6, 6)
            love.graphics.setColor(0.4, 0.4, 0.5)
            love.graphics.rectangle("line", b.x, b.y, b.w, b.h, 6, 6)
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(b.code == "ru" and "Русский" or "English",
            b.x, b.y + 12, b.w, "center")
    end

    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.printf(L.chooseTopic, 0, 228, w, "center")

    for _, b in ipairs(M.topicBtns) do
        if b.topic == topic then
            love.graphics.setColor(0.3, 0.7, 1.0)
            love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 6, 6)
            love.graphics.setColor(0, 0, 0)
        else
            love.graphics.setColor(0.15, 0.15, 0.2)
            love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 6, 6)
            love.graphics.setColor(0.4, 0.4, 0.5)
            love.graphics.rectangle("line", b.x, b.y, b.w, b.h, 6, 6)
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(L.topics[b.topic], b.x, b.y + (b.h - 18) / 2, b.w, "center")
    end

    local sb = M.startBtn
    love.graphics.setColor(0.3, 0.85, 0.5)
    love.graphics.rectangle("fill", sb.x, sb.y, sb.w, sb.h, 8, 8)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(L.start, sb.x, sb.y + 18, sb.w, "center")

    local startBottom = sb.y + sb.h
    local hintY = startBottom + 25
    local lineH = font:getHeight() + 4
    love.graphics.setColor(0.6, 0.6, 0.7)
    local hint = M.hasTouch and L.controlsMobile or L.controlsPC
    if hintY + lineH > h - 10 then hintY = h - lineH - 10 end
    love.graphics.printf(hint, 20, hintY, w - 40, "center")
end

-- Отрисовка игры: без circle("fill"), без полупрозрачных заливок
function love.draw()
    if scene == "menu" then
        drawMenu()
        return
    end

    local w, h = love.graphics.getDimensions()
    local safeTop = math.max(40, math.floor(h * 0.055))
    local topBarH = 60

    -- Панель примера: полностью непрозрачная
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, w, safeTop + topBarH)

    -- Текст примера
    love.graphics.setColor(1, 0.95, 0.6)
    love.graphics.printf(problem.text, 20, safeTop + 18, w - 40, "center")

    -- Кружки с ответами: концентрические линии вместо заливки
    local positions, r = getOptionPositions()
    for _, o in ipairs(problem.options) do
        local rings = math.max(8, math.floor(r / 2))
        for i = rings, 1, -1 do
            local rr = r * (i / rings)
            love.graphics.setColor(0.15, 0.25, 0.45)
            love.graphics.circle("line", o.x, o.y, rr)
        end
        love.graphics.setColor(0.4, 0.7, 1.0)
        love.graphics.circle("line", o.x, o.y, r)
        love.graphics.setColor(1, 1, 1)
        local text = tostring(o.value)
        local textWidth = font:getWidth(text)
        local textHeight = font:getHeight()
        love.graphics.print(text, o.x - textWidth/2, o.y - textHeight/2)
    end

    -- Игрок
    local pc = { 0.3, 0.9, 0.5 }
    if invertTimer > 0 then pc = { 1, 0.3, 0.3 } end
    if frozenTimer > 0 then pc = { 0.5, 0.7, 1 } end
    love.graphics.setColor(pc)
    love.graphics.rectangle("fill", player.x, player.y, player.size, player.size)

    drawStick()

    -- UI
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(L.level .. ": " .. level .. " / " .. maxLevel, 10, safeTop + topBarH + 10)
    love.graphics.print(L.correct .. ": " .. score .. " " .. L.of .. " " .. needed, 10, safeTop + topBarH + 30)

    -- Фраза троллинга над джойстиком
    if taunt ~= "" then
        love.graphics.setColor(1, 0.8, 0.3)
        local tauntY = h - stick.radius * 2 - 70
        if tauntY < safeTop + topBarH + 60 then tauntY = safeTop + topBarH + 60 end
        love.graphics.printf(taunt, 20, tauntY, w - 40, "center")
    end

    -- Заставка уровня: непрозрачный фон
    if levelTransition > 0 then
        love.graphics.setColor(0.05, 0.05, 0.1)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(transitionText, 20, h/2 - 20, w - 40, "center")
        love.graphics.printf(L.solve .. " " .. needed .. " " .. L.examples,
            20, h/2 + 10, w - 40, "center")
    end

    -- Фейк-лаг
    if fakeLag > 0 then
        love.graphics.setColor(0.05, 0.05, 0.1)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("...", 0, h/2, w, "center")
    end

    -- Победа
    if win then
        love.graphics.setColor(0.05, 0.05, 0.1)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setColor(0.4, 1, 0.5)
        love.graphics.printf(L.winTitle, 20, h/2 - 110, w - 40, "center")
        love.graphics.setColor(1, 1, 1)
        local total = stats.correct + stats.wrong
        local accuracy = total > 0 and math.floor(stats.correct / total * 100) or 0
        local fastestText = stats.fastest < math.huge
            and string.format("%.2f %s", stats.fastest, L.sec) or "—"
        love.graphics.printf(
            L.statCorrect .. ": " .. stats.correct .. "\n" ..
            L.statWrong .. ": " .. stats.wrong .. "\n" ..
            L.statAcc .. ": " .. accuracy .. "%\n" ..
            L.statFast .. ": " .. fastestText .. "\n\n" ..
            L.restartHint,
            20, h/2 - 60, w - 40, "center")
    elseif lose then
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.printf(L.restartHint, 20, h/2, w - 40, "center")
    end
end

function love.resize(w, h)
    clampToWindow()
    layoutStick()
    repositionOptions()
end

function love.keypressed(key)
    if key == "escape" then
        if scene == "game" then
            scene = "menu"
        else
            love.event.quit()
        end
    elseif key == "f11" then
        local full = love.window.getFullscreen()
        love.window.setFullscreen(not full, "desktop")
        clampToWindow()
        layoutStick()
        repositionOptions()
    elseif key == "r" and scene == "game" and (win or lose) then
        startGame()
    end
end

-- =======================
--   КЛИКИ / ТАЧИ В МЕНЮ
-- =======================
local function menuClick(x, y)
    local M = getMenuLayout()

    for _, b in ipairs(M.langBtns) do
        if x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h then
            setLang(b.code)
            return
        end
    end

    for _, b in ipairs(M.topicBtns) do
        if x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h then
            topic = b.topic
            return
        end
    end

    local sb = M.startBtn
    if x >= sb.x and x <= sb.x + sb.w and y >= sb.y and y <= sb.y + sb.h then
        startGame()
        return
    end
end

-- =======================
--   СЕНСОРНОЕ УПРАВЛЕНИЕ
-- =======================
local function updateStickVector(x, y)
    local dx = x - stick.baseX
    local dy = y - stick.baseY
    local dist = math.sqrt(dx*dx + dy*dy)
    local maxDist = stick.radius
    if dist > maxDist then
        dx = dx / dist * maxDist
        dy = dy / dist * maxDist
        dist = maxDist
    end
    stick.knobX = stick.baseX + dx
    stick.knobY = stick.baseY + dy

    local nx, ny = dx / maxDist, dy / maxDist
    local mag = math.sqrt(nx*nx + ny*ny)
    local deadzone = 0.12

    if mag < deadzone then
        stick.targetDx = 0
        stick.targetDy = 0
    else
        local t = (mag - deadzone) / (1 - deadzone)
        local curve = t * t * (3 - 2 * t)
        stick.targetDx = (nx / mag) * curve
        stick.targetDy = (ny / mag) * curve
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if scene == "menu" then
        menuClick(x, y)
        return
    end
    if win or lose then
        startGame()
        return
    end
    local dist = math.sqrt((x - stick.baseX)^2 + (y - stick.baseY)^2)
    if not stick.active and dist <= stick.radius * 1.6 then
        stick.active = true
        stick.id = id
        stick.knobX, stick.knobY = x, y
        updateStickVector(x, y)
    end
end

function love.touchmoved(id, x, y)
    if stick.active and id == stick.id then
        updateStickVector(x, y)
    end
end

function love.touchreleased(id, x, y)
    if stick.active and stick.id == id then
        stick.active = false
        stick.id = nil
        stick.targetDx = 0
        stick.targetDy = 0
        stick.knobX, stick.knobY = stick.baseX, stick.baseY
    end
end

function love.mousepressed(x, y, button)
    if button ~= 1 then return end
    if scene == "menu" then
        menuClick(x, y)
        return
    end
    if win or lose then
        startGame()
        return
    end
    local dist = math.sqrt((x - stick.baseX)^2 + (y - stick.baseY)^2)
    if dist <= stick.radius * 1.6 then
        stick.active = true
        stick.id = "mouse"
        stick.knobX, stick.knobY = x, y
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
        stick.targetDx = 0
        stick.targetDy = 0
        stick.knobX, stick.knobY = stick.baseX, stick.baseY
    end
end
