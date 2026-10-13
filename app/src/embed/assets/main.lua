-- main.lua
-- «Математический параноик» — тренажёр устного счёта с троллингом.
-- Темы: арифметика, степени, логарифмы, проценты, тригонометрия.
-- Языки: русский, английский. Адаптивное меню под любой размер экрана.
-- Плавное управление джойстиком. Совместимость с разными GPU Android.
-- Правила и главное меню — со скроллом (свайп пальцем или колесо мыши).

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
        about = "Об игре и правилах",
        aboutTitle = "ПРАВИЛА ИГРЫ",
        aboutRead = "ПРОЧИТАНО. ЗАКРЫТЬ.",
        aboutWait = "Читай. Я подожду. Пока что.",
        aboutScrollHint = "Прокрути вниз, чтобы дочитать",
        aboutScrollEnd = "Конец. Можно закрывать.",
        aboutText = [[ЗАЧЕМ ЭТО.

Это тренажёр устного счёта,
который вас не любит.

Задача простая и невыполнимая
одновременно: считать быстро,
пока игра делает всё, чтобы вы
считали медленно.

---

ЦЕЛЬ.

Собери N примеров, чтобы пройти
уровень. Собери 8 уровней —
увидишь финал.

N растёт. Вместе с ним растёт
то, что игра сделает с тобой.

---

КАК ИГРАТЬ.

1. Читай пример сверху.
2. Двигай зелёный квадрат.
3. Касайся правильного ответа.
4. Не трогай неправильные.
5. Повторяй, пока не пройдёшь.

Управление: стрелки или
джойстик в левом нижнем углу.

---

ПРАВИЛА, КОТОРЫЕ НАДО ЗНАТЬ.

• Правильный ответ +1.
• Неправильный ответ −1.
• Начать можно с нуля. Это окей.

Всё остальное ты узнаешь сам.

---

ЧЕГО ЖДАТЬ.

Игра будет мешать. Это её работа.
Она будет делать это нагло, внезапно
и без извинений.

Не злись. Это часть тренировки.
Умение считать под давлением —
навык, а не талант.

---

СОВЕТ, КОТОРЫЙ ТЕБЕ НЕ ПОМОЖЕТ.

Дыши. Считай вслух. Не паникуй.
Игра всё равно найдёт способ тебя
сбить. Но ты хотя бы попробуешь.

---

ПОЧЕМУ ЭТО ПОЛЕЗНО.

Ты тренируешь не только счёт.
Ты тренируешь голову работать,
когда всё идёт не по плану.

Этот навык пригодится на
контрольной, на экзамене,
на работе и в жизни.

---

ФИНАЛЬНОЕ ПРЕДУПРЕЖДЕНИЕ.

Дальше будет нечестно.
Но и ты не сдавайся.
Удачи. Она тебе понадобится.

---

ЖМИ "ПРОЧИТАНО" И НАЧНЁМ.
Посмотрим, насколько тебя хватит.]],
        close = "Закрыть",
        controlsPC = "Стрелки — движение. F11 — fullscreen. Esc — выход.",
        controlsMobile = "Водите пальцем в левом нижнем углу — движение.",
        menuScrollHint = "Прокрути вниз",
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
            "Калькулятор бы справился быстрее.",
            "Ты вообще учил таблицу умножения?",
            "Я не виноват, что ты медленный.",
            "Даже мой создатель решает быстрее.",
            "Чувствуешь себя уверенно? Сейчас исправлю.",
            "Ты можешь сдаться в любой момент. Правда.",
            "Может, тебе подсказать? Нет.",
            "Это задание было для второго класса.",
        },
        levelTaunts = {
            "Уровень 1. Начинаем по-лёгкому. Пока что.",
            "Уровень 2. Теперь ответы двигаются. Привыкай.",
            "Уровень 3. Появились обманки. Не тупи.",
            "Уровень 4. Ты ещё здесь? Уважаю.",
            "Уровень 5. Арена сжимается. Как твоё терпение.",
            "Уровень 6. Уже шесть. Неплохо.",
            "Уровень 7. Остался последний. Не расслабляйся.",
            "Уровень 8. Финал. Докажи, что не зря старался.",
        },
    },
    en = {
        title = "MATH PARANOID",
        subtitle = "Mental arithmetic trainer with trolling",
        chooseLang = "Language",
        chooseTopic = "Topic",
        start = "Start Game",
        about = "About & Rules",
        aboutTitle = "RULES OF THE GAME",
        aboutRead = "READ. CLOSE.",
        aboutWait = "Read. I'll wait. For now.",
        aboutScrollHint = "Scroll down to read",
        aboutScrollEnd = "The end. You can close now.",
        aboutText = [[WHY THIS EXISTS.

This is a math trainer that
doesn't like you.

The goal is simple and impossible
at the same time: count fast,
while the game does everything
to make you count slow.

---

GOAL.

Collect N problems to clear
a level. Clear 8 levels —
see the finale.

N grows. So does what the game
will do to you.

---

HOW TO PLAY.

1. Read the problem at the top.
2. Move the green square.
3. Touch the correct answer.
4. Don't touch the wrong ones.
5. Repeat until you clear it.

Controls: arrows or
joystick in the bottom-left.

---

RULES YOU SHOULD KNOW.

• Correct answer: +1.
• Wrong answer: −1.
• You can start from zero. It's fine.

Everything else you'll learn yourself.

---

WHAT TO EXPECT.

The game will interfere. That's
its job. It will do it boldly,
suddenly and without apology.

Don't rage. It's part of the training.
Counting under pressure is
a skill, not a talent.

---

A TIP THAT WON'T HELP.

Breathe. Count aloud. Don't panic.
The game will still find a way
to throw you off. But at least
you'll try.

---

WHY IT HELPS.

You're not just training math.
You're training your brain to work
when nothing goes according to plan.

This skill will help you in
an exam, at work and in life.

---

FINAL WARNING.

It's going to get unfair.
But don't give up.
Good luck. You'll need it.

---

PRESS "READ" AND LET'S GO.
Let's see how far you last.]],
        close = "Close",
        controlsPC = "Arrows — move. F11 — fullscreen. Esc — exit.",
        controlsMobile = "Drag finger in bottom-left corner to move.",
        menuScrollHint = "Scroll down",
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
            "A calculator would be faster.",
            "Did you even learn the times table?",
            "It's not my fault you're slow.",
            "Even my creator solves it faster.",
            "Feeling confident? Let me fix that.",
            "You can give up anytime. Really.",
            "Want a hint? No.",
            "This problem was for second graders.",
        },
        levelTaunts = {
            "Level 1. Starting easy. For now.",
            "Level 2. Answers now move. Get used to it.",
            "Level 3. Decoys appeared. Don't be fooled.",
            "Level 4. You're still here? Respect.",
            "Level 5. The arena shrinks. Like your patience.",
            "Level 6. Six already. Not bad.",
            "Level 7. One more. Don't relax.",
            "Level 8. The finale. Prove you're worth it.",
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

-- Правила
local showAbout = false
local aboutTimer = 0
local ABOUT_READ_TIME = 5
local rulesRead = false

-- Скролл правил
local aboutScroll = 0
local aboutScrollMax = 0
local aboutDragActive = false
local aboutDragStartY = 0
local aboutDragStartScroll = 0
local aboutTouchMoved = false

-- Скролл главного меню
local menuScroll = 0
local menuScrollMax = 0
local menuDragActive = false
local menuDragStartY = 0
local menuDragStartScroll = 0
local menuTouchMoved = false
local menuScrollVelocity = 0

-- Фейковые троллинги
local fakeWinTimer = 0
local blackoutTimer = 0
local swapTimer = 0
local speedJoltTimer = 0
local taunt2 = ""

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
--   СОХРАНЕНИЕ ФЛАГА
-- ========================
local SAVE_FILE = "settings.txt"

local function loadSettings()
    local ok, data = pcall(love.filesystem.read, SAVE_FILE)
    if ok and data then
        if data:find("rulesRead=1") then
            rulesRead = true
        end
    end
end

local function saveSettings()
    local s = ""
    if rulesRead then s = s .. "rulesRead=1\n" end
    love.filesystem.write(SAVE_FILE, s)
end

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
        blackoutEvery = math.max(8.0, 20.0 - n * 1.5),
        swapEvery     = math.max(6.0, 15.0 - n * 1.2),
        joltEvery     = math.max(5.0, 12.0 - n * 1.0),
    }

    player.speed = cfg.speed
    score = 0
    needed = cfg.needed
    timeAlive = 0
    tauntTimer = 0
    taunt = ""
    taunt2 = ""
    invertTimer = 0
    frozenTimer = 0
    fakeLagTimer = cfg.lagEvery
    fakeLag = 0
    fakeWinTimer = 0
    blackoutTimer = 0
    swapTimer = 0
    speedJoltTimer = 0
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

    local lt = L.levelTaunts
    if lt and lt[n] then
        taunt = lt[n]
        tauntTimer = 3.5
    end
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
    showAbout = false
    player = player or { x = 400, y = 300, size = 40, speed = 260 }
    loadLevel(1)
end

-- ========================
--   МЕНЮ СО СКРОЛЛОМ
-- ========================
local function getMenuContent()
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

    local y = 40

    local titleY = y
    y = y + 50
    local subtitleY = y
    y = y + 45

    y = y + 10
    local langLabelY = y
    y = y + 30

    local langBtns = {}
    local langW = narrow and math.min((w - 60 - gap) / 2, 180) or 110
    local langH = 44
    local langTotalW = #langList * langW + (#langList - 1) * gap
    local langY = y
    for i, code in ipairs(langList) do
        local bx = w/2 - langTotalW/2 + (i - 1) * (langW + gap)
        table.insert(langBtns, { code = code, x = bx, y = langY, w = langW, h = langH })
    end
    y = y + langH + 20

    local topicLabelY = y
    y = y + 30

    local topicBtns = {}
    local startX = w/2 - (cols * bw + (cols - 1) * gap) / 2
    local topicStartY = y
    for i, t in ipairs(topicList) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local bx = startX + col * (bw + gap)
        local by = topicStartY + row * (bh + gap)
        table.insert(topicBtns, { topic = t, x = bx, y = by, w = bw, h = bh })
    end
    local rows = math.ceil(#topicList / cols)
    y = topicStartY + rows * (bh + gap) + 20

    local startW = narrow and math.min(w - 60, 300) or 260
    local startBtn = {
        x = w/2 - startW/2,
        y = y,
        w = startW,
        h = 60,
    }
    y = y + 60 + 10

    local aboutBtn = {
        x = w/2 - startW/2,
        y = y,
        w = startW,
        h = 44,
    }
    y = y + 44 + 20

    local lineH = font:getHeight() + 4
    local hintY = y
    y = y + lineH * 2 + 20

    local contentHeight = y

    return {
        w = w, h = h,
        narrow = narrow,
        hasTouch = hasTouch,
        titleY = titleY,
        subtitleY = subtitleY,
        langLabelY = langLabelY,
        topicLabelY = topicLabelY,
        langBtns = langBtns,
        topicBtns = topicBtns,
        startBtn = startBtn,
        aboutBtn = aboutBtn,
        hintY = hintY,
        lineH = lineH,
        contentHeight = contentHeight,
    }
end

local function updateMenuScrollMax()
    local C = getMenuContent()
    local w, h = love.graphics.getDimensions()
    menuScrollMax = math.max(0, C.contentHeight - h + 20)
end

local function drawMenu()
    local C = getMenuContent()
    local w, h = C.w, C.h

    love.graphics.push()
    love.graphics.translate(0, -menuScroll)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(L.title, 20, C.titleY, w - 40, "center")
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.printf(L.subtitle, 20, C.subtitleY, w - 40, "center")

    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.printf(L.chooseLang, 0, C.langLabelY, w, "center")

    for _, b in ipairs(C.langBtns) do
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
    love.graphics.printf(L.chooseTopic, 0, C.topicLabelY, w, "center")

    for _, b in ipairs(C.topicBtns) do
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

    local sb = C.startBtn
    love.graphics.setColor(0.3, 0.85, 0.5)
    love.graphics.rectangle("fill", sb.x, sb.y, sb.w, sb.h, 8, 8)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(L.start, sb.x, sb.y + 18, sb.w, "center")

    local ab = C.aboutBtn
    local pulse = 1.0
    if not rulesRead then
        pulse = 0.8 + 0.2 * math.sin(love.timer.getTime() * 4)
    end
    love.graphics.setColor(0.15 * pulse, 0.15 * pulse, 0.25 * pulse)
    love.graphics.rectangle("fill", ab.x, ab.y, ab.w, ab.h, 6, 6)
    if not rulesRead then
        love.graphics.setColor(1.0, 0.6, 0.2)
    else
        love.graphics.setColor(0.5, 0.6, 0.9)
    end
    love.graphics.rectangle("line", ab.x, ab.y, ab.w, ab.h, 6, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(L.about, ab.x, ab.y + 12, ab.w, "center")

    love.graphics.setColor(0.6, 0.6, 0.7)
    local hint = C.hasTouch and L.controlsMobile or L.controlsPC
    love.graphics.printf(hint, 20, C.hintY, w - 40, "center")

    love.graphics.pop()

    if menuScrollMax > 0 then
        local trackX = w - 6
        local trackY = 60
        local trackH = h - 120
        local trackW = 3

        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", trackX, trackY, trackW, trackH)

        local visibleRatio = h / (h + menuScrollMax)
        local knobH = math.max(30, trackH * visibleRatio)
        local knobY = trackY + (trackH - knobH) * (menuScroll / menuScrollMax)
        love.graphics.setColor(0.5, 0.7, 1.0)
        love.graphics.rectangle("fill", trackX, knobY, trackW, knobH)

        if menuScroll < menuScrollMax - 10 then
            love.graphics.setColor(0.5, 0.5, 0.6)
            love.graphics.printf(L.menuScrollHint, 0, h - 30, w, "center")
        end
    end
end

-- ========================
--   ПЛАШКА "ОБ ИГРЕ"
-- ========================
local function getAboutGeometry()
    local w, h = love.graphics.getDimensions()
    local margin = 16
    local boxX = margin
    local boxY = 30
    local boxW = w - margin * 2
    local boxH = h - 60

    local titleH = 40
    local btnW = math.min(280, w - 60)
    local btnH = 50
    local btnX = w/2 - btnW/2
    local btnY = boxY + boxH - btnH - 12

    local textX = boxX + 16
    local textY = boxY + titleH + 8
    local textW = boxW - 32
    local textH = btnY - textY - 10

    return {
        w = w, h = h,
        boxX = boxX, boxY = boxY, boxW = boxW, boxH = boxH,
        titleH = titleH,
        textX = textX, textY = textY, textW = textW, textH = textH,
        btnX = btnX, btnY = btnY, btnW = btnW, btnH = btnH,
    }
end

local function updateAboutScrollMax()
    local G = getAboutGeometry()
    local _, wrappedLines = font:getWrap(L.aboutText, G.textW)
    local lineH = font:getHeight()
    local totalH = #wrappedLines * lineH
    aboutScrollMax = math.max(0, totalH - G.textH)
end

local function drawAbout()
    local G = getAboutGeometry()

    love.graphics.setColor(0.03, 0.03, 0.06)
    love.graphics.rectangle("fill", 0, 0, G.w, G.h)

    love.graphics.setColor(0.1, 0.1, 0.18)
    love.graphics.rectangle("fill", G.boxX, G.boxY, G.boxW, G.boxH, 10, 10)
    love.graphics.setColor(0.3, 0.5, 0.9)
    love.graphics.rectangle("line", G.boxX, G.boxY, G.boxW, G.boxH, 10, 10)

    love.graphics.setColor(1, 0.9, 0.5)
    love.graphics.printf(L.aboutTitle, G.boxX, G.boxY + 12, G.boxW, "center")

    love.graphics.setScissor(G.textX, G.textY, G.textW, G.textH)
    love.graphics.push()
    love.graphics.translate(0, -aboutScroll)
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.printf(L.aboutText, G.textX, G.textY, G.textW, "left")
    love.graphics.pop()
    love.graphics.setScissor()

    if aboutScrollMax > 0 then
        local trackX = G.textX + G.textW + 4
        local trackY = G.textY
        local trackH = G.textH
        local trackW = 4

        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", trackX, trackY, trackW, trackH)

        local visibleRatio = G.textH / (G.textH + aboutScrollMax)
        local knobH = math.max(20, trackH * visibleRatio)
        local knobY = trackY + (trackH - knobH) * (aboutScroll / aboutScrollMax)
        love.graphics.setColor(0.5, 0.7, 1.0)
        love.graphics.rectangle("fill", trackX, knobY, trackW, knobH)
    end

    if aboutScrollMax > 0 then
        if aboutScroll < aboutScrollMax - 10 then
            love.graphics.setColor(0.6, 0.6, 0.7)
            love.graphics.printf(L.aboutScrollHint, G.boxX, G.btnY - 22, G.boxW, "center")
        else
            love.graphics.setColor(0.4, 0.85, 0.5)
            love.graphics.printf(L.aboutScrollEnd, G.boxX, G.btnY - 22, G.boxW, "center")
        end
    end

    if aboutTimer > 0 then
        love.graphics.setColor(0.15, 0.15, 0.2)
        love.graphics.rectangle("fill", G.btnX, G.btnY, G.btnW, G.btnH, 8, 8)
        love.graphics.setColor(0.4, 0.4, 0.5)
        love.graphics.rectangle("line", G.btnX, G.btnY, G.btnW, G.btnH, 8, 8)
        love.graphics.setColor(0.8, 0.8, 0.8)
        local waitText = L.aboutWait .. " (" .. math.ceil(aboutTimer) .. ")"
        love.graphics.printf(waitText, G.btnX, G.btnY + 15, G.btnW, "center")
    else
        love.graphics.setColor(0.3, 0.85, 0.5)
        love.graphics.rectangle("fill", G.btnX, G.btnY, G.btnW, G.btnH, 8, 8)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(L.aboutRead, G.btnX, G.btnY + 15, G.btnW, "center")
    end
end

-- ========================
--   LÖVE CALLBACKS
-- ========================
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

local function menuClick(x, y)
    if showAbout then
        if aboutTimer > 0 then return end
        local G = getAboutGeometry()
        if aboutTouchMoved then return end
        if x >= G.btnX and x <= G.btnX + G.btnW and y >= G.btnY and y <= G.btnY + G.btnH then
            showAbout = false
        end
        return
    end

    local C = getMenuContent()
    local cy = y + menuScroll

    for _, b in ipairs(C.langBtns) do
        if x >= b.x and x <= b.x + b.w and cy >= b.y and cy <= b.y + b.h then
            setLang(b.code)
            return
        end
    end

    for _, b in ipairs(C.topicBtns) do
        if x >= b.x and x <= b.x + b.w and cy >= b.y and cy <= b.y + b.h then
            topic = b.topic
            return
        end
    end

    local sb = C.startBtn
    if x >= sb.x and x <= sb.x + sb.w and cy >= sb.y and cy <= sb.y + sb.h then
        startGame()
        return
    end

    local ab = C.aboutBtn
    if x >= ab.x and x <= ab.x + ab.w and cy >= ab.y and cy <= ab.y + ab.h then
        showAbout = true
        aboutTimer = 0
        aboutScroll = 0
        updateAboutScrollMax()
        return
    end
end

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

    loadSettings()

    if not rulesRead then
        showAbout = true
        aboutTimer = ABOUT_READ_TIME
        aboutScroll = 0
    end

    updateMenuScrollMax()
    updateAboutScrollMax()
end

function love.update(dt)
    if showAbout and aboutTimer > 0 then
        aboutTimer = aboutTimer - dt
        if aboutTimer <= 0 then
            aboutTimer = 0
            rulesRead = true
            saveSettings()
        end
    end

    -- Инерция главного меню
    if scene == "menu" and not showAbout then
        if not menuDragActive and math.abs(menuScrollVelocity) > 0.5 then
            menuScroll = menuScroll + menuScrollVelocity * dt
            menuScrollVelocity = menuScrollVelocity * 0.92
            if menuScroll < 0 then
                menuScroll = 0
                menuScrollVelocity = 0
            end
            if menuScroll > menuScrollMax then
                menuScroll = menuScrollMax
                menuScrollVelocity = 0
            end
        end
    end

    if scene == "menu" then return end
    if showAbout then return end

    if levelTransition > 0 then
        levelTransition = levelTransition - dt
    end

    if win or lose then
        if love.keyboard.isDown("r") then startGame() end
        return
    end

    if fakeWinTimer > 0 then
        fakeWinTimer = fakeWinTimer - dt
        return
    end

    timeAlive = timeAlive + dt
    tauntTimer = tauntTimer - dt
    invertTimer = invertTimer - dt
    frozenTimer = frozenTimer - dt
    fakeLagTimer = fakeLagTimer - dt
    blackoutTimer = blackoutTimer - dt
    swapTimer = swapTimer - dt
    speedJoltTimer = speedJoltTimer - dt

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

    if blackoutTimer <= -cfg.blackoutEvery and math.random() < 0.02 then
        blackoutTimer = 0.35
        taunt2 = L.taunts[math.random(#L.taunts)]
    end

    if swapTimer <= -cfg.swapEvery and math.random() < 0.02 and #problem.options >= 4 then
        swapTimer = 3.0
        local a = math.random(#problem.options)
        local b = math.random(#problem.options)
        if a ~= b then
            local oa = problem.options[a]
            local ob = problem.options[b]
            oa.x, ob.x = ob.x, oa.x
            oa.y, ob.y = ob.y, oa.y
            if correctIndex == a then correctIndex = b
            elseif correctIndex == b then correctIndex = a end
            taunt2 = L.taunts[math.random(#L.taunts)]
        end
    end

    if speedJoltTimer <= -cfg.joltEvery and math.random() < 0.015 then
        speedJoltTimer = 1.5
        player.speed = cfg.speed * 2.2
        taunt2 = L.taunts[math.random(#L.taunts)]
    end
    if speedJoltTimer > 0 then
        if speedJoltTimer < 0.1 then
            player.speed = cfg.speed
        end
    else
        player.speed = cfg.speed
    end

    if level >= 4 and math.random() < 0.0008 then
        fakeWinTimer = 0.8
        taunt2 = L.taunts[math.random(#L.taunts)]
        return
    end

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

function love.draw()
    if scene == "menu" then
        drawMenu()
        if showAbout then
            updateAboutScrollMax()
            drawAbout()
        end
        return
    end

    local w, h = love.graphics.getDimensions()
    local safeTop = math.max(40, math.floor(h * 0.055))
    local topBarH = 60

    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, w, safeTop + topBarH)

    love.graphics.setColor(1, 0.95, 0.6)
    love.graphics.printf(problem.text, 20, safeTop + 18, w - 40, "center")

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

    local pc = { 0.3, 0.9, 0.5 }
    if invertTimer > 0 then pc = { 1, 0.3, 0.3 } end
    if frozenTimer > 0 then pc = { 0.5, 0.7, 1 } end
    if speedJoltTimer > 0 then pc = { 1, 0.9, 0.2 } end
    love.graphics.setColor(pc)
    love.graphics.rectangle("fill", player.x, player.y, player.size, player.size)

    drawStick()

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(L.level .. ": " .. level .. " / " .. maxLevel, 10, safeTop + topBarH + 10)
    love.graphics.print(L.correct .. ": " .. score .. " " .. L.of .. " " .. needed, 10, safeTop + topBarH + 30)

    local tauntY = h - stick.radius * 2 - 70
    if tauntY < safeTop + topBarH + 60 then tauntY = safeTop + topBarH + 60 end
    if taunt ~= "" then
        love.graphics.setColor(1, 0.8, 0.3)
        love.graphics.printf(taunt, 20, tauntY, w - 40, "center")
    end
    if taunt2 ~= "" then
        love.graphics.setColor(1, 0.4, 0.4)
        love.graphics.printf(taunt2, 20, tauntY + 25, w - 40, "center")
    end

    if levelTransition > 0 then
        love.graphics.setColor(0.05, 0.05, 0.1)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(transitionText, 20, h/2 - 20, w - 40, "center")
        love.graphics.printf(L.solve .. " " .. needed .. " " .. L.examples,
            20, h/2 + 10, w - 40, "center")
    end

    if blackoutTimer > 0 then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.printf("?...", 0, h/2 - 20, w, "center")
    end

    if fakeLag > 0 then
        love.graphics.setColor(0.05, 0.05, 0.1)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("...", 0, h/2, w, "center")
    end

    if fakeWinTimer > 0 then
        love.graphics.setColor(0.05, 0.05, 0.1)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setColor(0.4, 1, 0.5)
        love.graphics.printf(L.winTitle, 20, h/2 - 60, w - 40, "center")
        love.graphics.setColor(1, 0.4, 0.4)
        love.graphics.printf("...нет, шутка.", 20, h/2 + 20, w - 40, "center")
    end

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
    if showAbout then
        updateAboutScrollMax()
    end
    updateMenuScrollMax()
end

function love.keypressed(key)
    if key == "escape" then
        if showAbout then
            showAbout = false
        elseif scene == "game" then
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
        updateMenuScrollMax()
    elseif key == "r" and scene == "game" and (win or lose) then
        startGame()
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if scene == "menu" then
        if showAbout then
            local G = getAboutGeometry()
            if x >= G.textX and x <= G.textX + G.textW
               and y >= G.textY and y <= G.textY + G.textH then
                aboutDragActive = true
                aboutDragStartY = y
                aboutDragStartScroll = aboutScroll
                aboutTouchMoved = false
            end
        else
            menuDragActive = true
            menuDragStartY = y
            menuDragStartScroll = menuScroll
            menuTouchMoved = false
            menuScrollVelocity = 0
        end
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
    if showAbout and aboutDragActive then
        local dy = aboutDragStartY - y
        aboutScroll = aboutDragStartScroll + dy
        aboutScroll = math.max(0, math.min(aboutScrollMax, aboutScroll))
        if math.abs(dy) > 8 then
            aboutTouchMoved = true
        end
        return
    end

    if scene == "menu" and menuDragActive then
        local dy = menuDragStartY - y
        if math.abs(dy) > 8 then
            menuTouchMoved = true
        end
        menuScroll = menuDragStartScroll + dy
        menuScroll = math.max(0, math.min(menuScrollMax, menuScroll))
        return
    end

    if stick.active and id == stick.id then
        updateStickVector(x, y)
    end
end

function love.touchreleased(id, x, y)
    if showAbout then
        if aboutDragActive and aboutTouchMoved then
            aboutDragActive = false
            return
        end
        aboutDragActive = false
        if not aboutTouchMoved then
            menuClick(x, y)
        end
        aboutTouchMoved = false
        return
    end

    if scene == "menu" and menuDragActive then
        local dy = menuDragStartY - y
        menuScrollVelocity = dy * 2
        menuScrollVelocity = math.max(-2000, math.min(2000, menuScrollVelocity))

        if not menuTouchMoved then
            menuClick(x, y)
        end
        menuDragActive = false
        menuTouchMoved = false
        return
    end

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
        if showAbout then
            local G = getAboutGeometry()
            if x >= G.textX and x <= G.textX + G.textW
               and y >= G.textY and y <= G.textY + G.textH then
                aboutDragActive = true
                aboutDragStartY = y
                aboutDragStartScroll = aboutScroll
                aboutTouchMoved = false
            end
        else
            menuDragActive = true
            menuDragStartY = y
            menuDragStartScroll = menuScroll
            menuTouchMoved = false
            menuScrollVelocity = 0
        end
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
    if showAbout and aboutDragActive then
        local dy = aboutDragStartY - y
        aboutScroll = aboutDragStartScroll + dy
        aboutScroll = math.max(0, math.min(aboutScrollMax, aboutScroll))
        if math.abs(dy) > 8 then
            aboutTouchMoved = true
        end
        return
    end

    if scene == "menu" and menuDragActive then
        local dy = menuDragStartY - y
        if math.abs(dy) > 8 then
            menuTouchMoved = true
        end
        menuScroll = menuDragStartScroll + dy
        menuScroll = math.max(0, math.min(menuScrollMax, menuScroll))
        return
    end

    if stick.active and stick.id == "mouse" then
        updateStickVector(x, y)
    end
end

function love.mousereleased(x, y, button)
    if showAbout then
        aboutDragActive = false
        if not aboutTouchMoved then
            menuClick(x, y)
        end
        aboutTouchMoved = false
        return
    end

    if scene == "menu" and menuDragActive then
        local dy = menuDragStartY - y
        menuScrollVelocity = dy * 2
        menuScrollVelocity = math.max(-2000, math.min(2000, menuScrollVelocity))

        if not menuTouchMoved then
            menuClick(x, y)
        end
        menuDragActive = false
        menuTouchMoved = false
        return
    end

    if button == 1 and stick.active and stick.id == "mouse" then
        stick.active = false
        stick.id = nil
        stick.targetDx = 0
        stick.targetDy = 0
        stick.knobX, stick.knobY = stick.baseX, stick.baseY
    end
end

function love.wheelmoved(dx, dy)
    if showAbout then
        aboutScroll = aboutScroll - dy * 40
        aboutScroll = math.max(0, math.min(aboutScrollMax, aboutScroll))
    elseif scene == "menu" then
        menuScroll = menuScroll - dy * 60
        menuScroll = math.max(0, math.min(menuScrollMax, menuScroll))
    end
end
