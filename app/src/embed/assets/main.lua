-- main.lua
-- «Математический параноик» — тренажёр устного счёта с троллингом.
-- Темы: арифметика, степени, логарифмы, проценты, тригонометрия.
-- Языки: русский, английский.

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
                                                                                                            local r = 45
                                                                                                            local padX = r + 40
                                                                                                            local padTop = 130
                                                                                                            local padBottom = r + 60

                                                                                                            return {
                                                                                                                { padX,     padTop + (h - padTop - padBottom) * 0.3 },
                                                                                                                { w - padX, padTop + (h - padTop - padBottom) * 0.3 },
                                                                                                                { padX,     padTop + (h - padTop - padBottom) * 0.7 },
                                                                                                                { w - padX, padTop + (h - padTop - padBottom) * 0.7 },
                                                                                                            }
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
                                                                                                                                                            stick.baseX = stick.radius + 40
                                                                                                                                                            stick.baseY = h - stick.radius - 40
                                                                                                                                                            if not stick.active then
                                                                                                                                                                stick.knobX = stick.baseX
                                                                                                                                                                stick.knobY = stick.baseY
                                                                                                                                                                end
                                                                                                                                                                end

                                                                                                                                                                local function clampToWindow()
                                                                                                                                                                local w, h = love.graphics.getDimensions()
                                                                                                                                                                if player then
                                                                                                                                                                    player.x = math.max(0, math.min(w - player.size, player.x))
                                                                                                                                                                    player.y = math.max(0, math.min(h - player.size, player.y))
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
                                                                                                                                                                        love.window.setMode(900, 700, {
                                                                                                                                                                            resizable = true,
                                                                                                                                                                            minwidth = 500,
                                                                                                                                                                            minheight = 400,
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
                                                                                                                                                                                                if stick.active then
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
                                                                                                                                                                                                                                                        player.x = math.max(30, math.min(w - 30 - player.size, player.x))
                                                                                                                                                                                                                                                        player.y = math.max(90, math.min(h - 30 - player.size, player.y))
                                                                                                                                                                                                                                                        end

                                                                                                                                                                                                                                                        if level >= levelFeatures.movingAnswers and not onTransition then
                                                                                                                                                                                                                                                            local padX = 70
                                                                                                                                                                                                                                                            local minY = 170
                                                                                                                                                                                                                                                            local maxY = h - 70
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
                                                                                                                                                                                                                                                                player.y = math.random(170, math.max(171, h - 60 - player.size))
                                                                                                                                                                                                                                                                taunt = L.wrongAnswer
                                                                                                                                                                                                                                                                tauntTimer = 2
                                                                                                                                                                                                                                                                makeProblem(level)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                break
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

                                                                                                                                                                                                                                                                -- ========================
                                                                                                                                                                                                                                                                --   МЕНЮ (динамическая раскладка)
                                                                                                                                                                                                                                                                -- ========================
                                                                                                                                                                                                                                                                local function getMenuLayout()
                                                                                                                                                                                                                                                                local w, h = love.graphics.getDimensions()

                                                                                                                                                                                                                                                                local langBtns = {}
                                                                                                                                                                                                                                                                local langW, langH = 110, 42
                                                                                                                                                                                                                                                                local langGap = 15
                                                                                                                                                                                                                                                                local langTotalW = #langList * langW + (#langList - 1) * langGap
                                                                                                                                                                                                                                                                for i, code in ipairs(langList) do
                                                                                                                                                                                                                                                                local bx = w/2 - langTotalW/2 + (i - 1) * (langW + langGap)
                                                                                                                                                                                                                                                                table.insert(langBtns, { code = code, x = bx, y = 210, w = langW, h = langH })
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                local topicBtns = {}
                                                                                                                                                                                                                                                                local cols = 3
                                                                                                                                                                                                                                                                local bw, bh = 200, 50
                                                                                                                                                                                                                                                                local gap = 15
                                                                                                                                                                                                                                                                local totalW = cols * bw + (cols - 1) * gap
                                                                                                                                                                                                                                                                local startX = w/2 - totalW/2
                                                                                                                                                                                                                                                                for i, t in ipairs(topicList) do
                                                                                                                                                                                                                                                                local col = (i - 1) % cols
                                                                                                                                                                                                                                                                local row = math.floor((i - 1) / cols)
                                                                                                                                                                                                                                                                local bx = startX + col * (bw + gap)
                                                                                                                                                                                                                                                                local by = 320 + row * (bh + gap)
                                                                                                                                                                                                                                                                table.insert(topicBtns, { topic = t, x = bx, y = by, w = bw, h = bh })
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                local rows = math.ceil(#topicList / cols)
                                                                                                                                                                                                                                                                local startY = 320 + rows * (bh + gap) + 30
                                                                                                                                                                                                                                                                local startBtn = { x = w/2 - 130, y = startY, w = 260, h = 60 }

                                                                                                                                                                                                                                                                return {
                                                                                                                                                                                                                                                                w = w, h = h,
                                                                                                                                                                                                                                                                langBtns = langBtns,
                                                                                                                                                                                                                                                                topicBtns = topicBtns,
                                                                                                                                                                                                                                                                startBtn = startBtn,
                                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                local function drawMenu()
                                                                                                                                                                                                                                                                local M = getMenuLayout()
                                                                                                                                                                                                                                                                local w, h = M.w, M.h

                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.printf(L.title, 0, 60, w, "center")
                                                                                                                                                                                                                                                                love.graphics.setColor(0.7, 0.7, 0.8)
                                                                                                                                                                                                                                                                love.graphics.printf(L.subtitle, 0, 100, w, "center")

                                                                                                                                                                                                                                                                love.graphics.setColor(0.9, 0.9, 0.9)
                                                                                                                                                                                                                                                                love.graphics.printf(L.chooseLang, 0, 180, w, "center")
                                                                                                                                                                                                                                                                for _, b in ipairs(M.langBtns) do
                                                                                                                                                                                                                                                                if b.code == lang then
                                                                                                                                                                                                                                                                love.graphics.setColor(0.3, 0.7, 1.0)
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                love.graphics.setColor(0.25, 0.25, 0.35)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 6, 6)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.printf(b.code == "ru" and "Русский" or "English",
                                                                                                                                                                                                                                                                b.x, b.y + 12, b.w, "center")
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                love.graphics.setColor(0.9, 0.9, 0.9)
                                                                                                                                                                                                                                                                love.graphics.printf(L.chooseTopic, 0, 290, w, "center")
                                                                                                                                                                                                                                                                for _, b in ipairs(M.topicBtns) do
                                                                                                                                                                                                                                                                if b.topic == topic then
                                                                                                                                                                                                                                                                love.graphics.setColor(0.3, 0.7, 1.0)
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                love.graphics.setColor(0.25, 0.25, 0.35)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 6, 6)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.printf(L.topics[b.topic], b.x, b.y + 16, b.w, "center")
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                local sb = M.startBtn
                                                                                                                                                                                                                                                                love.graphics.setColor(0.3, 0.85, 0.5)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", sb.x, sb.y, sb.w, sb.h, 8, 8)
                                                                                                                                                                                                                                                                love.graphics.setColor(0, 0, 0)
                                                                                                                                                                                                                                                                love.graphics.printf(L.start, sb.x, sb.y + 18, sb.w, "center")

                                                                                                                                                                                                                                                                love.graphics.setColor(0.6, 0.6, 0.7)
                                                                                                                                                                                                                                                                love.graphics.printf(L.controlsPC, 0, h - 60, w, "center")
                                                                                                                                                                                                                                                                love.graphics.printf(L.controlsMobile, 0, h - 35, w, "center")
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                function love.draw()
                                                                                                                                                                                                                                                                if scene == "menu" then
                                                                                                                                                                                                                                                                drawMenu()
                                                                                                                                                                                                                                                                return
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                local w, h = love.graphics.getDimensions()

                                                                                                                                                                                                                                                                if cfg.shrink then
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.3, 0.3, 0.25)
                                                                                                                                                                                                                                                                love.graphics.rectangle("line", 30, 90, w - 60, h - 120, 8, 8)
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                for _, o in ipairs(problem.options) do
                                                                                                                                                                                                                                                                love.graphics.setColor(0.15, 0.25, 0.45)
                                                                                                                                                                                                                                                                love.graphics.circle("fill", o.x, o.y, 45)
                                                                                                                                                                                                                                                                love.graphics.setColor(0.4, 0.7, 1.0)
                                                                                                                                                                                                                                                                love.graphics.circle("line", o.x, o.y, 45)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                                                                local text = tostring(o.value)
                                                                                                                                                                                                                                                                local textWidth = font:getWidth(text)
                                                                                                                                                                                                                                                                love.graphics.print(text, o.x - textWidth/2, o.y - 10)
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                local pc = { 0.3, 0.9, 0.5 }
                                                                                                                                                                                                                                                                if invertTimer > 0 then pc = { 1, 0.3, 0.3 } end
                                                                                                                                                                                                                                                                if frozenTimer > 0 then pc = { 0.5, 0.7, 1 } end
                                                                                                                                                                                                                                                                love.graphics.setColor(pc)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", player.x, player.y, player.size, player.size)

                                                                                                                                                                                                                                                                drawStick()

                                                                                                                                                                                                                                                                love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", 0, 0, w, 70)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.95, 0.6)
                                                                                                                                                                                                                                                                love.graphics.printf(problem.text, 0, 22, w, "center")

                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.print(L.level .. ": " .. level .. " / " .. maxLevel, 10, 80)
                                                                                                                                                                                                                                                                love.graphics.print(L.correct .. ": " .. score .. " " .. L.of .. " " .. needed, 10, 100)

                                                                                                                                                                                                                                                                if taunt ~= "" then
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.8, 0.3)
                                                                                                                                                                                                                                                                love.graphics.printf(taunt, 0, h - 30, w, "center")
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                if levelTransition > 0 then
                                                                                                                                                                                                                                                                local alpha = math.min(1, levelTransition * 2)
                                                                                                                                                                                                                                                                love.graphics.setColor(0, 0, 0, 0.7 * alpha)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", 0, 0, w, h)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1, alpha)
                                                                                                                                                                                                                                                                love.graphics.printf(transitionText, 0, h/2 - 20, w, "center")
                                                                                                                                                                                                                                                                love.graphics.printf(L.solve .. " " .. needed .. " " .. L.examples, 0, h/2 + 10, w, "center")
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                if fakeLag > 0 then
                                                                                                                                                                                                                                                                love.graphics.setColor(0, 0, 0, 0.9)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", 0, 0, w, h)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.printf("...", 0, h/2, w, "center")
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                if win then
                                                                                                                                                                                                                                                                love.graphics.setColor(0, 0, 0, 0.85)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", 0, 0, w, h)
                                                                                                                                                                                                                                                                love.graphics.setColor(0.4, 1, 0.5)
                                                                                                                                                                                                                                                                love.graphics.printf(L.winTitle, 0, h/2 - 110, w, "center")
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
                                                                                                                                                                                                                                                                0, h/2 - 60, w, "center")
                                                                                                                                                                                                                                                                elseif lose then
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.3, 0.3)
                                                                                                                                                                                                                                                                love.graphics.printf(L.restartHint, 0, h/2, w, "center")
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                function love.resize(w, h)
                                                                                                                                                                                                                                                                clampToWindow()
                                                                                                                                                                                                                                                                layoutStick()
                                                                                                                                                                                                                                                                -- Ключевое: пересчитываем позиции кружков под новый размер окна
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
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                stick.knobX = stick.baseX + dx
                                                                                                                                                                                                                                                                stick.knobY = stick.baseY + dy

                                                                                                                                                                                                                                                                local nx, ny = dx / maxDist, dy / maxDist
                                                                                                                                                                                                                                                                if math.sqrt(nx*nx + ny*ny) < 0.15 then
                                                                                                                                                                                                                                                                stick.dx, stick.dy = 0, 0
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                stick.dx, stick.dy = nx, ny
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
                                                                                                                                                                                                                                                                stick.dx, stick.dy = 0, 0
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
                                                                                                                                                                                                                                                                stick.dx, stick.dy = 0, 0
                                                                                                                                                                                                                                                                stick.knobX, stick.knobY = stick.baseX, stick.baseY
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
