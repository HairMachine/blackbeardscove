SCREEN_RES_X = 800
SCREEN_RES_Y = 600
TIL_SIZ = 32
SCREEN_TIL_X = SCREEN_RES_X / TIL_SIZ
SCREEN_TIL_Y = SCREEN_RES_Y / TIL_SIZ

screen = "title"
tiles = {}
sounds = {}
music = {}
map = {}
camera = {
    x = 10 * TIL_SIZ - SCREEN_RES_X / 2,
    y = 7 * TIL_SIZ - SCREEN_RES_Y / 2,
    width = SCREEN_TIL_X,
    height = SCREEN_TIL_Y
}
entities = {{
    x = 10 * TIL_SIZ,
    y = 7 * TIL_SIZ,
    dir = "up",
    attack = {
        delay = 0.2,
        x = 0,
        y = 0,
        flash = "attack",
        active = false,
        damage = 1
    },
    health = 3,
    maxhealth = 3,
    key = false,
    nocontrol = false,
    money = 8,
    respawn = "pirate",
    collision = "block",
    behaviour = "player",
    tile = "pirate0",
    name = "Player 1",
    moneyTotal = 0,
    kills = 0,
    deaths = 0,
    chests = 0,
    winner = false
}}
player = entities[1]
shop = {
    spawners = {},
}
events = {}
chests_unopened = 0
spawn_points = {}
endstring = "YOU LOSE!"
messages = {}
shopitems = {
    "heartcontainer::shop",
    "cutlass::shop"
}

function load_tiles()
    tiles = {
        null = love.graphics.newImage("null.png"),
        rockwall = love.graphics.newImage("rockwall.png"),
        rockfloor = love.graphics.newImage("rockfloor.png"),
        shipwall = love.graphics.newImage("shipwall.png"),
        shipfloor = love.graphics.newImage("shipfloor.png"),
        water = love.graphics.newImage("water.png"),
        shallowwater = love.graphics.newImage("water.png"),
        cannon = love.graphics.newImage("cannon.png"),
        cannonball = love.graphics.newImage("cannonball.png"),
        chest = love.graphics.newImage("chest.png"),
        key = love.graphics.newImage("key.png"),
        pirate0 = love.graphics.newImage("pirate0.png"),
        pirate1 = love.graphics.newImage("pirate1.png"),
        pirate2 = love.graphics.newImage("pirate2.png"),
        pirate3 = love.graphics.newImage("pirate3.png"),
        pirate4 = love.graphics.newImage("pirate4.png"),
        ghost = love.graphics.newImage("ghost.png"),
        monster = love.graphics.newImage("monster.png"),
        attack = love.graphics.newImage("attack.png"),
        heart = love.graphics.newImage("heart.png"),
        shopspawner = love.graphics.newImage("shopspawner.png"),
        heartcontainer = love.graphics.newImage("heartcontainer.png"),
        pieceofeight = love.graphics.newImage("pieceofeight.png"),
        pileofeight = love.graphics.newImage("pieceofeight.png")
    }
end

function load_sounds()
    sounds = {
        fanfare = love.audio.newSource("fanfare.mp3", "static"),
        coins = love.audio.newSource("coins.ogg", "static"),
        sword = love.audio.newSource("sword.wav", "static"),
        cannon = love.audio.newSource("cannon.wav", "static"),
        dead = love.audio.newSource("dead.wav", "static")
    }
end

function load_music()
    music = {
        shanty = love.audio.newSource("Salty Ditty.mp3", "stream")
    }
    music.shanty:setLooping(true)
end

function add_message(msg)
    if #messages >= 5 then
        for m = 2, #messages do
            messages[m - 1] = messages[m]
        end
        table.remove(messages, 5)
    end
    table.insert(messages, msg)
end

function random_pirate_name()
    local firstnames = {"Salty", "Long John", "Beardy", "Sea Dog", "Gonzalo", "Captain", "Roger", "Peg-Leg", "Davy"}
    local lastnames = {"Silver", "McBeard", "the Corsair", "the Cabin Boy", "the Peg-Leg", "Jones", "McGraw"}
    return firstnames[love.math.random(1, #firstnames)].." "..lastnames[love.math.random(1, #lastnames)]
end

-- Spawn a new entity. Entities do stuff!
function spawn_entity(name, x, y)
    if name == "cannon" then
        table.insert(entities, {x = x, y = y, tile = "cannon", collision = "block", reloading = false})
    elseif name == "key" then
        table.insert(entities, {x = x, y = y, tile = "key", collision = "pickup", respawn = "self", delay = 10})
    elseif name == "npc" then
        table.insert(entities, {x = x, y = y, tile = "pirate1", collision = "block"})
    elseif name == "ghost" then
        table.insert(entities, {
            x = x, y = y, tile = "ghost", collision = "block", behaviour = "guard", health = 50, maxhealth = 50, respawn = "self", delay = 10, speed = 1,
            attack = {
                delay = 0.5,
                x = 0,
                y = 0,
                flash = "attack",
                active = false,
                damage = 3
            },
            guarding = {
                x = x,
                y = y
            },
            kills = 0,
            deaths = 0
        })
    elseif name == "monster" then
        table.insert(entities, {
            x = x, y = y, tile = "monster", collision = "block", behaviour = "guard", health = 5, maxhealth = 5, respawn = "self", delay = 10, speed = 3,
            attack = {
                delay = 0.2,
                x = 0,
                y = 0,
                flash = "attack",
                active = false,
                damage = 2
            },
            guarding = {
                x = x,
                y = y
            },
            kills = 0,
            deaths = 0
        })
    elseif name == "heartcontainer::shop" then
        table.insert(entities, {x = x, y = y, tile = "heartcontainer", collision = "pickup", cost = 10, respawn = "shop", delay = 10})
    elseif name == "cutlass::shop" then
        table.insert(entities, {x = x, y = y, tile = "attack", collision = "pickup", cost = 15, respawn = "shop", delay = 10})
    elseif name == "chest" then
        table.insert(entities, {x = x, y = y, tile = "chest", collision = "pickup"})
        chests_unopened = chests_unopened + 1
    elseif name == "pieceofeight" then
        table.insert(entities, {x = x, y = y, tile = "pieceofeight", collision = "pickup"})
    elseif name == "pileofeight" then
        table.insert(entities, {x = x, y = y, tile = "pileofeight", collision = "pickup"})
    elseif name == "zoneswitch" then
        table.insert(entities, {x = x, y = y, collision = "zone_switch"})
    elseif name == "cannontrigger" then
        table.insert(entities, {x = x, y = y, collision = "cannon_trigger"})
    elseif name == "cannonball" then
        table.insert(entities, {x = x, y = y, tile = "cannonball", collision = "hurt", behaviour = "straight", fragile = true, speed = 6}) 
    elseif name == "pirate" then
        table.insert(entities, {
            x = x, y = y, tile = "pirate2", collision = "block", behaviour = "pirate", speed = 2, health = 3, maxhealth = 3, money = 5, respawn = "pirate",
            name = random_pirate_name(),
            attack = {
                delay = 0.2,
                x = 0,
                y = 0,
                flash = "attack",
                active = false
            },
            moneyTotal = 0,
            kills = 0,
            deaths = 0,
            chests = 0,
            winner = false
        })
    else
        error("Tried to spawn non-existent entity "..name)
    end
    -- Return handle to the added thing
    return #entities
end

function despawn_entity(entity)
    for i = #entities, 1, -1 do
        if entities[i] == entity then
            table.remove(entities, i)
        end
    end
end

-- Puts some pieces of eight on the map in free spaces.
function spawn_treasure()
    local ok = false
    local amount = love.math.random(5, 8)
    for i = 0, amount do
        local xcand = -1
        local ycand = -1
        ok = false
        while ok == false do
            xcand = love.math.random(1, #map)
            ycand = love.math.random(1, #map[1]) -- dodgy but should work fine because the map is square
            if not tile_is_blocker(map[xcand][ycand]) and not tile_is_bad(map[xcand][ycand]) then
                ok = true
            end
        end
        spawn_entity("pieceofeight", tile_pos_to_pos(xcand), tile_pos_to_pos(ycand))
    end
    -- Start an event to spawn the next set of treasure.
    spawn_event(function() 
        spawn_treasure()
    end, 60)
end

function spawn_attack(atkinfo, attacker, pos, dir)
    local atkent = {}
    atkent.tile = atkinfo.flash
    atkent.x = pos.x
    atkent.y = pos.y
    atkent.collision = "hurt"
    atkent.rotation = dir
    atkent.damage = atkinfo.damage
    atkent.parent = attacker
    table.insert(entities, atkent)
    local eid = #entities
    -- Get rid of the attack when the delay is up (if required)
    if atkinfo.delay then
        spawn_event(function()
            despawn_entity(atkent)
        end, atkinfo.delay)
    end
    sounds.sword:play()
    return eid
end

function ai_find_closest(entity, point, comparitor)
    local point1dist = math.abs(point.x - entity.x) + math.abs(point.y - entity.y)
    local point2dist = math.abs(comparitor.x - entity.x) + math.abs(comparitor.y - entity.y)
    if point1dist <= point2dist then
        return true
    else
        return false
    end
end

-- Chooses a map target for the AI.
function ai_choose_target(entity)
    local target = {x = 9000, y = 9000}
    local targetstr = ""
    local tries = 0
    while target.x == 9000 and tries < 100 do
        targetstr = "pieceofeight"
        if love.math.random(1, 6) >= 3 then
            if entity.key ~= true then
                targetstr = "key"
            else
                targetstr = "chest"
            end
        end
        -- select target
        for k,v in pairs(entities) do
            if v.tile == targetstr and ai_find_closest(entity, v, target) then
                target.x = pos_to_tile_pos(v.x) + 1
                target.y = pos_to_tile_pos(v.y) + 1
            end
        end
        tries = tries + 1
    end
    return target
end

-- Changes the state of the AI based on the current situation (pathing, fighting etc.)
function ai_set_state(entity)
    -- Pirate may randomly change its target
    if love.math.random(2000) == 1 then
        path_build(entity)
    end
    -- Pirate chooses a new target if they've reached their old one
    if pos_to_tile_pos(entity.x) + 1 == entity.pathTarget.x and pos_to_tile_pos(entity.y) + 1 == entity.pathTarget.y then
        path_build(entity)
    end
    -- TODO: Pirate detects closeness of player and switches to a beeline mode, or starts attacking if really close
    return "pirate"
end

function path_get_lowest_adjacent(pathmap, x, y)
    local res = {}
    local min = pathmap[x][y]
    for xi = x - 1, x + 1 do
        for yi = y - 1, y + 1 do
            if pathmap[xi] ~= nil and pathmap[xi][yi] ~= nil and pathmap[xi][yi] < min then
                res = {}
                res[1] = {x = xi, y = yi, min = pathmap[xi][yi]}
                min = pathmap[xi][yi]
            elseif pathmap[xi] ~= nil and pathmap[xi][yi] ~= nil and pathmap[xi][yi] == min then
                table.insert(res, {x = xi, y = yi, min = pathmap[xi][yi]})
            end
        end
    end
    return res
end

function path_build(entity)
    local target = ai_choose_target(entity)
    entity.pathTarget = target
    -- reset path map
    entity.pathmap = {}
    for x = 1, #map do
        entity.pathmap[x] = {}
        for y = 1, #map[x] do
            if x == target.x and y == target.y then
                entity.pathmap[x][y] = 0
            else
                entity.pathmap[x][y] = 99
            end
        end
    end
    -- Build dijkstra map
    local changed = true
    while changed == true do
        changed = false
        for x = 1, #entity.pathmap do
            for y = 1, #entity.pathmap[x] do
                if not tile_is_blocker(map[x][y]) and not tile_is_bad(map[x][y]) then
                    local adj = path_get_lowest_adjacent(entity.pathmap, x, y)[1]
                    if adj.min + 1 < entity.pathmap[x][y] then
                        entity.pathmap[x][y] = adj.min + 1
                        changed = true
                    end
                end
            end
        end
    end
    -- Set up other pathing data to prevent dodgy access errors
    path_choose(entity)
end

function path_choose(entity)
    local possibles = path_get_lowest_adjacent(entity.pathmap, pos_to_tile_pos(entity.x) + 1, pos_to_tile_pos(entity.y) + 1)
    local next = possibles[love.math.random(1, #possibles)]
    entity.pathing = true
    entity.path = {}
    entity.path.x = tile_pos_to_pos(next.x)
    entity.path.y = tile_pos_to_pos(next.y)
end

function path_towards_point(entity, x, y)
    local xdir = entity.x - x
    local ydir = entity.y - y
    local xspd = 0
    local yspd = 0
    local moved = false
    if xdir < 0 then 
        if try_move(entity, entity.speed, 0) then moved = true end
    end
    if xdir > 0 then 
        if try_move(entity, -entity.speed, 0) then moved = true end
    end
    if ydir < 0 then 
        if try_move(entity, 0, entity.speed) then moved = true end
    end
    if ydir > 0 then 
        if try_move(entity, 0, -entity.speed) then moved = true end
    end
    return moved
end

-- Runs through the entities and makes them do whatever they need to be doing.
function process_entities()
    for i = #entities, 1, -1 do
        local v = entities[i]
        if v.behaviour ~= nil then
            -- Make sure if we are just sitting around or whatever, we check for collisions properly
            collision_check(v)
            if v.behaviour == "straight" then
                -- If there's no line, calculate it
                if v.line == nil then
                    v.line = {}
                    v.line.m = (v.target.y - v.y) / (v.target.x - v.x)
                    v.line.b = v.target.y - (v.line.m * v.target.x)
                    if v.target.x < v.x then v.line.rate_x = -v.speed else v.line.rate_x = v.speed end
                    if v.target.y < v.y then v.line.rate_y = -v.speed else v.line.rate_y = v.speed end
                    -- Rotate the projectile to face the right ish ish ish ishsihsihsihsish not ish way
                    if v.line.rate_x > v.line.rate_y and v.line.rate_y < 0 then v.rotation = "up"
                    elseif v.line.rate_x > v.line.rate_y and v.line.rate_x > 0 then v.rotation = "right"
                    elseif v.line.rate_x < v.line.rate_y and v.line.rate_y > 0 then v.rotation = "down"
                    elseif v.line.rate_x < v.line.rate_y and v.line.rate_x < 0 then v.rotation = "left" end
                end
                -- y = mx + b
                if math.abs(v.line.m) < 1 then
                    v.x = v.x + v.line.rate_x
                    v.y = math.floor(v.line.m * v.x + v.line.b)
                else
                    v.y = v.y + v.line.rate_y
                    v.x = math.floor((v.y - v.line.b) / v.line.m)
                end
            elseif v.behaviour == "guard" and v.nocontrol ~= true then
                -- TODO: It can also attack other pirates (when they're added)
                -- Possible optimisation: cache a list of these entities when they are spawned (they are never actually despawned)
                local closestTarget = nil
                -- TODO: Bad iterator names (k, v above is quite bad as well)
                for k2, v2 in pairs(entities) do
                    if v2.respawn == "pirate" then
                        if closestTarget == nil or ai_find_closest(v, v2, closestTarget) then
                            closestTarget = v2
                        end
                    end
                end
                -- Only close on the nearest target if it is actually in range
                if closestTarget ~= nil and math.abs(v.guarding.x - closestTarget.x) < 256 and math.abs(v.guarding.y - closestTarget.y) < 256 then
                    -- Make a simple beeline
                    if not path_towards_point(v, closestTarget.x, closestTarget.y) then
                        -- start attacking if it can't reach the destination
                        v.oldBehaviour = "guard"
                        v.behaviour = "attacking"
                        v.path = {
                            x = closestTarget.x,
                            y = closestTarget.y
                        }
                    end
                else
                    path_towards_point(v, v.guarding.x, v.guarding.y)
                end
            elseif v.behaviour == "pirate" and v.nocontrol ~= true then
                if v.pathmap == nil then
                    path_build(v)
                end
                if v.x == v.path.x and v.y == v.path.y then
                    path_choose(v)
                end
                if not path_towards_point(v, v.path.x, v.path.y) then
                    v.oldBehaviour = v.behaviour
                    -- TODO: Actually check what is there! Not much point slashing wildly at the scenery, though it is kind of funny.
                    if love.math.random(1, 2) == 1 then
                        v.behaviour = "confused"
                    else
                        v.behaviour = "attacking"
                    end
                end
                ai_set_state(v)
            elseif v.behaviour == "confused" and v.nocontrol ~= true then
                if v.confusedTarget == nil then
                    v.confusedTarget = {
                        x = tile_pos_to_pos(love.math.random(pos_to_tile_pos(v.x - 1) + 1, pos_to_tile_pos(v.x + 1) + 1)), 
                        y = tile_pos_to_pos(love.math.random(pos_to_tile_pos(v.y - 1) + 1, pos_to_tile_pos(v.y + 1) + 1))
                    }
                end
                if not path_towards_point(v, v.confusedTarget.x, v.confusedTarget.y) or (v.x == v.confusedTarget.x and v.y == v.confusedTarget.y) then
                    v.behaviour = v.oldBehaviour
                    v.confusedTarget = nil
                end
            elseif v.behaviour == "attacking" and v.nocontrol ~= true then
                -- choose the direction based on which direction the entity was trying to move in
                local atkpos = {
                    x = v.x,
                    y = v.y
                }
                local dir
                if v.x < v.path.x then 
                    atkpos.x = v.x + TIL_SIZ
                    dir = "right" 
                elseif v.x > v.path.x then 
                    atkpos.x = v.x - TIL_SIZ 
                    dir = "left"
                elseif v.y < v.path.y then 
                    atkpos.y = v.y + TIL_SIZ
                    dir = "down"  
                elseif v.y > v.path.y then 
                    atkpos.y = v.y - TIL_SIZ 
                    dir = "up"
                end
                spawn_attack(v.attack, v, atkpos, dir)
                v.nocontrol = true
                spawn_event(function()
                    v.nocontrol = false
                    v.behaviour = v.oldBehaviour
                end, v.attack.delay + 0.1)
            end
        end
        if v.knockback ~= nil then
            local follow = nil
            if v == player then follow = "follow" end
            if v.knockback.dir == "up" then try_move(v, 0, -v.knockback.str, follow) 
            elseif v.knockback.dir == "right" then try_move(v, v.knockback.str, 0, follow) 
            elseif v.knockback.dir == "down" then try_move(v, 0, v.knockback.str, follow) 
            elseif v.knockback.dir == "left" then try_move(v, -v.knockback.str, 0, follow) end
            -- TODO: Maybe scale with a delay?
            if v.knockback and v.knockback.str > 0 then
                v.knockback.str = v.knockback.str - 1
            end
        end
        -- Destroy objects flying out of bounds
        if v.x < 0 or v.y < 0 or v.x > #map * TIL_SIZ or v.y > #map * TIL_SIZ then
            despawn_entity(v)
        end
    end
end

function respawn_entity(entity)
    if entity.respawn == "pirate" then
        -- Can't do nuffing if you're respawning
        entity.nocontrol = true
        -- TODO: Many 'humourous' death messages.
        add_message(entity.name.." went splat!")
        sounds.dead:play()
        -- Cancel knockback
        entity.knockback = nil
        -- Drop some loot. TODO: More loot.
        spawn_entity("pieceofeight", entity.x, entity.y)
        -- Try and actually respawn the dude
        sp = spawn_points[love.math.random(1, #spawn_points)]
        for k, v in pairs(entities) do
            -- If there's something here, abort; try again soon.
            if v ~= entity and collision_box(v.x, v.y, tile_pos_to_pos(sp.x), tile_pos_to_pos(sp.y)) then
                spawn_event(function()
                    respawn_entity(entity)
                end, 1)
                return false
            end
        end
        entity.health = entity.maxhealth    
        entity.x = tile_pos_to_pos(sp.x)
        entity.y = tile_pos_to_pos(sp.y)
        entity.pathmap = nil
        entity.nocontrol = false
        return true
    elseif entity.respawn == "self" then
        spawn_event(function()
            load_map_spawns(entity.tile)
        end, entity.delay)
        despawn_entity(entity)
        return true
    end
    return false
end

-- A trigger is a special entity that runs a function when its timer runs out.
function spawn_event(func, delay)
    table.insert(events, {func = func, time = love.timer.getTime() + delay})
end

function process_events()
    for i = #events, 1, -1 do
        local v = events[i]
        if love.timer.getTime() >= v.time then
            v.func()
            table.remove(events, i)
        end    
    end
end

function load_map()
    -- TODO: Load from a text file
    local x = 1
    local y = 1
    for line in love.filesystem.lines("cove.txt") do
        for i = 0, #line do
            if map[x] == nil then map[x] = {} end
            local c = line:sub(i, i)
            if c == "#" then
                map[x][y] = "rockwall"
            elseif c == "." then
                map[x][y] = "rockfloor"
            elseif c == "*" or c == "/" or c == "\\" then
                map[x][y] = "shipwall"
            elseif c == "," then
                map[x][y] = "shipfloor"
            elseif c == "w" then
                map[x][y] = "water"
            elseif c == "b" then
                map[x][y] = "shallowwater"
            elseif c == "$" then
                map[x][y] = "shopspawner"
                table.insert(shop.spawners, {x = tile_pos_to_pos(x), y = tile_pos_to_pos(y)})
            elseif c == "t" then
                map[x][y] = "shipfloor"
                spawn_entity("chest", tile_pos_to_pos(x), tile_pos_to_pos(y))
            elseif c == "C" then
                map[x][y] = "shipwall"
                spawn_entity("cannon", tile_pos_to_pos(x), tile_pos_to_pos(y))
            elseif c == "K" then
                map[x][y] = "rockfloor"
                spawn_entity("key", tile_pos_to_pos(x), tile_pos_to_pos(y))
            elseif c == "@" then
                map[x][y] = "shipfloor"
                spawn_entity("npc", tile_pos_to_pos(x), tile_pos_to_pos(y))
            elseif c == "G" then
                map[x][y] = "shipfloor"
                spawn_entity("ghost", tile_pos_to_pos(x), tile_pos_to_pos(y))
            elseif c == "M" then
                map[x][y] = "rockfloor"
                spawn_entity("monster", tile_pos_to_pos(x), tile_pos_to_pos(y))
            elseif c == "x" then
                map[x][y] = "rockfloor"
                spawn_entity("zoneswitch", tile_pos_to_pos(x), tile_pos_to_pos(y))
            elseif c == "X" then
                map[x][y] = "rockfloor"
                spawn_entity("cannontrigger", tile_pos_to_pos(x), tile_pos_to_pos(y))
            elseif c == "?" then
                map[x][y] = "shipfloor"
                spawn_entity("pirate", tile_pos_to_pos(x), tile_pos_to_pos(y))
                table.insert(spawn_points, {x = x, y = y})
            else
                map[x][y] = "null"
            end
            x = x + 1
        end
        y = y + 1
        x = 1
    end
end

-- Spawn entites from the map matching the given tile type 
function load_map_spawns(tile)
    local x = 1
    local y = 1
    for line in love.filesystem.lines("cove.txt") do
        for i = 0, #line do
            local c = line:sub(i, i)
            if c == "t" and tile == "chest" then
                spawn_entity("chest", tile_pos_to_pos(x), tile_pos_to_pos(y))
            elseif c == "C" and tile == "cannon" then
                spawn_entity("cannon", tile_pos_to_pos(x), tile_pos_to_pos(y))
            elseif c == "K" and tile == "key" then
                spawn_entity("key", tile_pos_to_pos(x), tile_pos_to_pos(y))
            elseif c == "@" and tile == "npc" then
                spawn_entity("npc", tile_pos_to_pos(x), tile_pos_to_pos(y))
            elseif c == "G" and tile == "ghost" then
                spawn_entity("ghost", tile_pos_to_pos(x), tile_pos_to_pos(y))
            elseif c == "M" and tile == "monster" then
                spawn_entity("monster", tile_pos_to_pos(x), tile_pos_to_pos(y))
            end
            x = x + 1
        end
        y = y + 1
        x = 1
    end
end

function pos_to_tile_pos(p)
    return math.floor(p / TIL_SIZ)
end

function tile_pos_to_pos(p)
    return (p - 1) * TIL_SIZ
end

function get_visible_tile(x, y)
    local cam_x = math.floor(pos_to_tile_pos(camera.x) + x)
    local cam_y = math.floor(pos_to_tile_pos(camera.y) + y)
    if (map[cam_x + 1] == nil or map[cam_x + 1][cam_y + 1] == nil) then
        return tiles.null
    end
    return tiles[map[cam_x + 1][cam_y + 1]]
end

function tile_is_blocker(tname)
    if (tname == "shipwall" or tname == "rockwall") then
        return true
    end
    return false
end

function tile_is_bad(tname)
    return tname == "water" or tname == "null" or tname == "shallowwater"
end

function tile_effect(entity, tname)
    if tname == "water" then
        respawn_entity(entity)
    end
end

function pos_to_tile(x, y)
    local tilx = pos_to_tile_pos(x)
    local tily = pos_to_tile_pos(y)
    if (map[tilx + 1] == nil or map[tilx + 1][tily + 1] == nil) then
        return "null"
    end
    return map[tilx + 1][tily + 1]
end

-- Focuses the camera on a given entity.
function camera_focus(entity)
    camera.x = entity.x - SCREEN_RES_X / 2
    camera.y = entity.y -  SCREEN_RES_Y / 2
end

function try_move(entity, x, y, follow)
    local oldx = entity.x
    local oldy = entity.y
    entity.x = entity.x + x
    entity.y = entity.y + y
    -- Player can be in multiple tiles (actually 4)
    local tileon = {}
    tileon[1] = pos_to_tile(entity.x, entity.y)
    tileon[2] = pos_to_tile(entity.x + TIL_SIZ - 1, entity.y)
    tileon[3] = pos_to_tile(entity.x, entity.y + TIL_SIZ - 1)
    tileon[4] = pos_to_tile(entity.x + TIL_SIZ - 1, entity.y + TIL_SIZ - 1)
    for k, v in pairs(tileon) do
        if tile_is_blocker(v) then
            entity.x = oldx
            entity.y = oldy
            return false
        end
        tile_effect(entity, v)
    end
    if not collision_check(entity) then
        entity.x = oldx
        entity.y = oldy
        return false
    end
    if follow == "follow" then
        camera_focus(entity)
    end
    return true
end

function game_controls()
    if player.nocontrol == true then
        return
    end
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") or (joystick and joystick:isGamepadDown("dpup")) then
        try_move(player, 0, -2, "follow")
        player.dir = "up"
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") or (joystick and joystick:isGamepadDown("dpright")) then
        try_move(player, 2, 0, "follow")
        player.dir = "right"
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") or (joystick and joystick:isGamepadDown("dpdown")) then
        try_move(player, 0, 2, "follow")
        player.dir = "down"
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") or (joystick and joystick:isGamepadDown("dpleft")) then
        try_move(player, -2, 0, "follow")
        player.dir = "left"
    end
    if love.keyboard.isDown("z") or love.keyboard.isDown("space") or (joystick and joystick:isGamepadDown("a")) then
        local atkpos = {
            x = player.x,
            y = player.y
        }
        if player.dir == "up" then
            atkpos.y = player.y - TIL_SIZ
        elseif player.dir == "right" then
            atkpos.x = player.x + TIL_SIZ
        elseif player.dir == "down" then
            atkpos.y = player.y + TIL_SIZ
        elseif player.dir == "left" then
            atkpos.x = player.x - TIL_SIZ
        end
        local aid = spawn_attack(player.attack, player, atkpos, player.dir)
        player.nocontrol = true
        spawn_event(function()
            player.nocontrol = false
        end, player.attack.delay + 0.1)
    end
end 

function system_controls()
    -- Nothing here yet.
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end

function item_loc_remove(x, y)
    -- TODO: Only remove items
    for i = #entities, 1, -1 do
        if x == entities[i].x and y == entities[i].y then
            table.remove(entities, i)
        end
    end
end

function check_buy_item(buying, buyer)
    if buying.cost and buyer.money then
        if buyer.money < buying.cost then
            return false
        else
            buyer.money = buyer.money - buying.cost
        end
    end
    return true
end

function pickup(subject, object)
    if not check_buy_item(object, subject) then return true end
    -- TODO: Move these out I think. There might be a neater way of doing it, though honestly this is fine (I want to keep these as data for easy saving)
    if object.tile == "key" then
        if subject.behaviour == "pirate" or subject.behaviour == "player" and not subject.key then
            subject.key = true
            -- If it's an AI pirate, find a new path!
            if subject.behaviour == "pirate" then
                add_message(subject.name.." picked up key!")
                path_build(subject)
            end
            sounds.fanfare:play()
        else 
            -- No idea why this is true and not false?
            return true 
        end
    elseif object.tile == "heartcontainer" then
        if subject.maxhealth == nil then return false end
        if subject.maxhealth >= 10 then 
            return false 
        end
        subject.maxhealth = subject.maxhealth + 1
        subject.health = subject.maxhealth
        sounds.fanfare:play()
    elseif object.tile == "attack" then
        if subject.attack == nil then return false end
        subject.attack.damage = subject.attack.damage + 1
        sounds.fanfare:play()
    elseif object.tile == "chest" then
        if not subject.key then
            return false -- chests are blocking if you can't unlock them
        end
        chests_unopened = chests_unopened - 1
        subject.chests = subject.chests + 1
        subject.key = false
        if love.math.random(0, chests_unopened * 2) == 0 then
            -- TODO: Proper win screen or endgame or something
            if subject == player then
                endstring = "YOU WIN!"
            else
                endstring = "YOU LOSE!"
            end
            subject.winner = true
            screen = "end"
        else
            spawn_entity("pileofeight", object.x, object.y)
        end
        if subject.behaviour == "pirate" then
            add_message(subject.name.." opened a chest!")
            path_build(subject)
        end
        sounds.fanfare:play()
    elseif object.tile == "pieceofeight" or object.tile == "pileofeight" then
        if subject.money == nil then return true end
        if object.tile == "pieceofeight" then
            subject.money = subject.money + 1
            subject.moneyTotal = subject.moneyTotal + 1
        elseif object.tile == "pileofeight" then
            subject.money = subject.money + 10
            subject.moneyTotal = subject.moneyTotal + 10
        end
        if subject.behaviour == "pirate" then
            -- TODO: Probably something better.
            if subject.money >= 10 then
                subject.money = subject.money + 50
                local itemroll = love.math.random(#shopitems)
                spawn_entity(shopitems[itemroll], subject.x, subject.y)
                add_message(subject.name.." got stronger!")
                subject.money = subject.money - 50
                if subject.money <= 0 then subject.money = 0 end
            else
                add_message(subject.name.." got some treasure!")
            end
            path_build(subject)
        end
        sounds.coins:play()
    end
    -- We only get to here if the pickup was successful
    despawn_entity(object)
    if object.respawn == "self" then
        spawn_event(function()
            spawn_entity(object.tile, object.x, object.y)
        end, object.delay)
    elseif object.respawn == "shop" then
        spawn_event(function()
            shop_spawn_items()
        end, object.delay)
    end
end

function fire_cannon(target)
    -- Find a cannon that can fire
    local cannonToFire = {reloading = true}
    local e = 1
    while e < #entities and cannonToFire.reloading == true do
        if entities[e].reloading ~= nil then    
            cannonToFire = entities[e]
        end
        e = e + 1
    end
    -- If we are still reloading, then there are no cannons ready! Lucky break.
    if cannonToFire.reloading == true then
        return
    end
    -- OK, now we fire.
    local cbid = spawn_entity("cannonball", cannonToFire.x, cannonToFire.y)
    entities[cbid].target = {x = target.x + love.math.random(1024) - 512, y = target.y + love.math.random(1024) - 512}
    cannonToFire.reloading = true
    spawn_event(function()
        cannonToFire.reloading = false
    end, 3.2)
    sounds.cannon:play()
end

function collision_box(x1, y1, x2, y2)
    return not(x1 + TIL_SIZ - 1 < x2 or y1 + TIL_SIZ - 1 < y2 or x2 + TIL_SIZ - 1 < x1 or y2 + TIL_SIZ - 1 < y1)
end

function collision_check(entity)
    local rval = true
    for k, v in pairs(entities) do
        if v ~= entity then
            if collision_box(v.x, v.y, entity.x, entity.y) then
                if v.collision == "pickup" then
                    pickup(entity, v)
                elseif v.collision == "block" then
                    rval = false
                elseif v.collision == "hurt" and entity.health ~= nil and entity.nocontrol ~= true then
                    local d = 1
                    if v.damage then
                        d = v.damage
                    end
                    entity.health = entity.health - d
                    if entity.health <= 0 then
                        if v.parent ~= nil then
                            v.parent.kills = v.parent.kills + 1
                        end
                        respawn_entity(entity)
                        entity.deaths = entity.deaths + 1
                    end
                    entity.nocontrol = true
                     -- TODO: Make this depend on the weapon most likely, so bigger weapons have longer hurts, harder hits
                    entity.knockback = {dir = v.rotation, str = 12}
                    spawn_event(function() 
                        entity.nocontrol = false
                        entity.knockback = nil
                    end, 0.35)
                    -- TODO: Have like some knockback stuff; basically just set a knockback dir and disable the player's controls while it's happening
                    -- TODO: This fragility is not really great
                    if v.fragile == true then
                        despawn_entity(v)
                    end
                    return false
                elseif v.collision == "cannon_trigger" then
                    fire_cannon(entity)
                end
            end
        end
    end
    return rval
end

function shop_spawn_items()
    for k, v in pairs(shop.spawners) do
        item_loc_remove(v.x, v.y)
        local itemroll = love.math.random(#shopitems)
        spawn_entity(shopitems[itemroll], v.x, v.y)
    end 
end

function love.load()
    titlescreen = love.graphics.newImage("title.png")
    load_sounds()
    load_music()
    load_tiles()
    load_map()
    joystick = love.joystick.getJoysticks()[1]
    love.graphics.setNewFont(18)
    shop_spawn_items()
    spawn_treasure()
    music.shanty:play()
end

function love.keypressed(key, scancode, isrepeat)
    if screen == "title" then
        screen = "game"
    elseif screen == "end" then
        love.event.quit()
    end
end

function love.draw()
    if screen == "title" then
        love.graphics.draw(titlescreen, 0, 0)
    elseif screen == "end" then
        love.graphics.print(endstring)
        local row = 1
        for k, v in pairs(entities) do
            if v.respawn == "pirate" then
                love.graphics.print(v.name, 0, row * TIL_SIZ)
                love.graphics.print(v.moneyTotal, 250, row * TIL_SIZ)
                love.graphics.print(v.kills, 300, row * TIL_SIZ)
                love.graphics.print(v.deaths, 350, row * TIL_SIZ)
                love.graphics.print(v.chests, 400, row * TIL_SIZ)
                if v.winner then
                    love.graphics.print("WINNER!", 450, row * TIL_SIZ)
                end
                row = row + 1
            end
        end
    else
        local offsx = camera.x % 32
        local offsy = camera.y % 32
        for x = 0, camera.width + 1 do
            for y = 0, camera.height + 1 do
                love.graphics.draw(get_visible_tile(x, y), x * TIL_SIZ - offsx, y * TIL_SIZ - offsy)
            end
        end
        for k, v in pairs(entities) do
            -- TODO: Not just drawing everything like a fecking eedjit
            if v.tile then
                -- If there's a dir rotate the sprite (used only for attacks right now)
                if v.rotation then
                    local r
                    if v.rotation == "up" then
                        r = 0
                    elseif v.rotation == "right" then
                        r = 1.5708
                    elseif v.rotation == "down" then
                        r = 3.14159
                    elseif v.rotation == "left" then
                        r = 4.71239
                    end
                    love.graphics.draw(
                        tiles[v.tile], v.x - camera.x + tiles[v.tile]:getWidth() / 2, 
                        v.y - camera.y + tiles[v.tile]:getHeight() / 2, 
                        r, 1, 1, tiles[v.tile]:getWidth() / 2, tiles[v.tile]:getHeight() / 2
                    )
                else
                    love.graphics.draw(tiles[v.tile], v.x - camera.x, v.y - camera.y)
                end
            end
        end
        -- HUD stuff
        for h = 0, player.health do
            love.graphics.draw(tiles.heart, SCREEN_RES_X - h * TIL_SIZ, 0)
        end
        love.graphics.draw(tiles.pieceofeight, SCREEN_RES_X - TIL_SIZ * 3, TIL_SIZ)
        love.graphics.print("x "..player.money, SCREEN_RES_X - TIL_SIZ * 2, TIL_SIZ)
        if player.key then
            love.graphics.draw(tiles.key, SCREEN_RES_X - TIL_SIZ * 3, TIL_SIZ * 2)
        end
        -- Message box
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", 0, 0, 400, 100)
        love.graphics.setColor(1, 1, 1, 1)
        for m = #messages, 1, -1 do
            love.graphics.print(messages[m], 0, (#messages - m) * 20) -- TODO: NO MAGIC NUMBERS!
        end
    end
end

function love.update()
    if screen == "game" then
        game_controls()
        system_controls()
        process_entities()
        process_events()
    end
end