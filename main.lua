io = require "io"
inspect = require "inspect"
bit32 = require "bit"

file = io.open('video.bin', 'rb')
data = {}
while true do
    local c = file:read(1)
    if c == nil then
        break
    end
    table.insert(data, c:byte(1))
end

frame = 1

TARGET_FPS = 24

framebuffer = {}
for y=0,61 do
    framebuffer[y] = {}
    for x=0,81 do
        framebuffer[y][x] = false
    end
end

function convert(t)
    local o = {}
    for i=7,0,-1 do
        o[i+1] = bit32.band(bit32.rshift(t, i), 1)
    end
    return o
end

function love.load()
    min_dt = 1/TARGET_FPS
    next_time = love.timer.getTime()
end

function love.update(a)
    next_time = next_time + min_dt
    love.window.setTitle('TetrisVideo Player - '..love.timer.getFPS()..' FPS - '..frame)

    if not data[frame] then
        return
    end

    local place = 0
    for i=0,600 do
        local h = convert(data[(frame * 600) + i + 1])
        for _, j in ipairs(h) do
            local y = math.floor(place / 80)
            local x = (place % 80)
            framebuffer[y+1][x+1] = (j == 0)
            place = place + 1
        end
    end

    frame = frame + 1
end

function love.draw()
    love.graphics.setColor(0,0,0,1)
    love.graphics.clear(1,1,1)
    for y, a in ipairs(framebuffer) do
        for x, b in ipairs(a) do
            if b then
                love.graphics.rectangle('fill', (x-1)*8, (y-1)*8, 8, 8)
            end
        end
    end
    local cur_time = love.timer.getTime()
    if next_time <= cur_time then
       next_time = cur_time
       return
    end
    love.timer.sleep(next_time - cur_time)
end