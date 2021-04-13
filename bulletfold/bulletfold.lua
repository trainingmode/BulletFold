--//////////////////////////////////////////////////////////////////////////////////////////////////
--
-- |[?""""`   BulletFold   - -~ => ((+))
--
----------------------------------------------------------------------------------------------------
-- Simple, lightweight bullet handler.
----------------------------------------------------------------------------------------------------
--  Setup:
--    1.  local bulletfold = require "bulletfold_directory.bulletfold"
--  Initialize:
--    2.  bulletfold.factory = "/bullets#factory"
--    3a. (Enable)  bulletfold.raycast_groups = { hash("collision_group1"), hash("collision_group2") }
--    3b. (Disable) bulletfold.raycast_groups = nil
--    4a. (Enable)  bulletfold.hitmarker = function(position, bullet_id, object_id) --[[Function]] end
--    4b. (Disable) bulletfold.hitmarker = nil
--  Spawn:
--    5a. bullet_id = bulletfold.spawn(speed, time, position, direction, accuracy, bulletfold.raycast_groups, custom_hit_function)
--    5b. bullet_id = bulletfold.spawn(speed, time, position, direction, accuracy, { hash("custom_group1") }, custom_hit_function)
--  Update:
--    6.  bulletfold.update(dt)
--  Delete:
--    7.  bulletfold.delete(bullet_id)
----------------------------------------------------------------------------------------------------
-- v1.0 | Apr 08, 2021 | Please, Donuts Touch | DefBullet by SubSoap <3 BulletFold by Tubcake Games
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- BulletFold
----------------------------------------------------------------------------------------------------
local bulletfold = {}
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- BulletFold Properties
----------------------------------------------------------------------------------------------------
bulletfold.bullets = {} -- Bullet Buffer
bulletfold.bullet_count = 0 -- Bullet Buffer Size

bulletfold.factory = "/bullets#factory" -- Bullet Factory URL

bulletfold.raycast_groups = { hash("default") } -- Default Bullet Ray Cast Collision Group IDs, List of Hashes
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Internal Properties
----------------------------------------------------------------------------------------------------
local bullet_raysult = {} -- Cache the Result of Each Ray Casted During [update_bullet_raycast()]
local bullet_position_old = vmath.vector3() -- Cache the Previous Position of a Bullet Updated During [update_bullet()]
local bullet_spawn_id = vmath.vector3() -- Cache the GameObject ID of the Bullet Spawned During [bulletfold.spawn()]
local bullet_spawn_direction = vmath.vector3() -- Cache the Direction of the Bullet Spawned During [bulletfold.spawn()]
local bullet_rotation_sin, bullet_rotation_cos = 0, 0 -- Cache the Rotation of the Bullet Direction During [rotate()]
local bullet_update_behaviour = function() end -- Cache the Internal Bullet Update Function Stored During [bulletfold.spawn()]
local bullet_hit_behaviour = function() end -- Cache the Internal Bullet Hit Function Stored During [bulletfold.spawn()]
local debug_line_color = vmath.vector4(1, 1, 1, 1) -- Color used to Render Bullet Ray Cast Debug Lines
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Internal Messaging
----------------------------------------------------------------------------------------------------
local __msg = {}
-- Internal Message IDs
__msg.id_renderer    = "@render:"
__msg.id_sprite      = "sprite"
__msg.id_hitmarkers  = "/hit_marker#factory"
-- Outgoing Message IDs
__msg.out_draw_line  = "draw_line"
__msg.out_hit_object = "hit_object"
-- Message Property IDs
__msg.prop_position  = "position"
__msg.prop_rotation  = "rotation"
__msg.prop_tintalpha = "tint.w"
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- BulletFold Default Hit Marker
----------------------------------------------------------------------------------------------------
--
-- Factory spawn a Hit Marker, animate the transparency, then delete once the animation has concluded.
--
bulletfold.hitmarker = function(position, bullet_id, object_id)
	local hitmark_id = factory.create(__msg.id_hitmarkers, position)
	go.animate(msg.url(nil, hitmark_id, __msg.id_sprite), __msg.prop_tintalpha, go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_LINEAR, 1, 0, function() go.delete(hitmark_id) end)
end 
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Internal Functions
----------------------------------------------------------------------------------------------------

--
-- Genrates a random angle used for the Bullet Direction offset amount.
--
local function spread(accuracy) return (math.random(1,1000) - 500) * accuracy end

--
-- Rotates a vector by the specified angle.
--
local function rotate(vector, theta)
	bullet_rotation_sin = math.sin(theta) ; bullet_rotation_cos = math.cos(theta)
	return vector.x * bullet_rotation_cos - vector.y * bullet_rotation_sin, vector.x * bullet_rotation_sin + vector.y * bullet_rotation_cos
end

----------------------------------------------------------------------------------------------------
-- Internal Bullet Functions
----------------------------------------------------------------------------------------------------

--
-- Spawns a new Bullet into the BulletFold Buffer.
--
local function bullet_spawn(speed, time, position, raycast_groups)
	bulletfold.bullet_count = 1+bulletfold.bullet_count
	-- Spawn a New Bullet into the Bullet Buffer
	bullet_spawn_id = factory.create(bulletfold.factory, position, vmath.quat_rotation_z(math.atan2(bullet_spawn_direction.y, bullet_spawn_direction.x)))
	bulletfold.bullets[bullet_spawn_id] = {
		-- Bullet Properties
		time = time, -- The Bullet Life Time
		speed = speed, -- The Initial Bullet Speed
		position = position, -- The Initial Bullet Position
		direction = bullet_spawn_direction, -- The Initial Bullet Direction
		velocity = bullet_spawn_direction * speed, -- The Initial Bullet Velocity
		raycast_groups = raycast_groups, -- The Collision Group IDs used by the Bullet Ray Cast
		--[[
			Add Your Custom Bullet Properties Here
		]]
		
		-- Bullet Functions
		update = bullet_update_behaviour, -- The Bullet Update Function
		hit = bullet_hit_behaviour, -- The Bullet Hit Function
		hitmark = bulletfold.hitmarker -- The Bullet Hit Marker Function
		--[[
			Add Your Custom Bullet Functions Here
		]]
	}
end

--
-- Animation callback that deletes the specified Bullet and removes it from the BulletFold Buffer.
--
local function bullet_delete(self, bullet_url, property)
	go.cancel_animations(bullet_url.path, __msg.prop_position)
	go.delete(bullet_url.path)
	bulletfold.bullets[bullet_url.path] = nil
	bulletfold.bullet_count = bulletfold.bullet_count - 1
end

--
-- Handles the specified BulletFold Bullet hitting another object and spawns a hit marker.
--
local function bullet_hit(position, bullet_id, object_id)
	--if bulletfold.hitmarker_factory then factory.create(bulletfold.hitmarker_factory, position) end
	bulletfold.bullets[bullet_id].hitmark(position, bullet_id, object_id)
	bulletfold.delete(bullet_id)
	--print(object_id.." was hit.")
end

--
-- Ray casts the specified BulletFold Bullet and properly handles collisions.
--
local function bullet_raycast(bullet, bullet_id, previous_bullet_position)
	bullet_raysult = physics.raycast(previous_bullet_position, bullet.position, bullet.raycast_groups, { all = false })
	if bullet_raysult then bulletfold.bullets[bullet_id].hit(bullet_raysult[#bullet_raysult].position, bullet_id, bullet_raysult[#bullet_raysult].id) end
	--msg.post(__msg.id_renderer, __msg.out_draw_line, { start_point = bullet.position, end_point = bullet_position_old, color = debug_line_color } ) -- Draw Ray Cast Debug Line
end

----------------------------------------------------------------------------------------------------
-- Internal Bullet Functions
----------------------------------------------------------------------------------------------------

--
-- Updates a single BulletFold Bullet.
--
local function bullet_update(bullet, bullet_id, dt)	
	-- Update the Bullet Life Time
	bullet.time = bullet.time - dt
end

--
-- Updates a single BulletFold Bullet and ray casts its path to handle collisions.
--
local function bullet_update_raycast(bullet, bullet_id, dt)	
	-- Update the Bullet Life Time
	bullet.time = bullet.time - dt
	-- Update the Bullet Position
	bullet_position_old = bullet.position
	bullet.position = bullet.position + bullet.velocity * dt
	
	-- Ray Cast the Bullet and Handle Collisions if Ray Cast Groups were Specified
	bullet_raycast(bullet, bullet_id, bullet_position_old)
end

--
-- Updates a single BulletFold Bullet and registers updates using [go.set()].
--
local function bullet_update_full(bullet, bullet_id, dt)	
	-- Update the Bullet Life Time
	bullet.time = bullet.time - dt

	-- Update the Bullet if the Life Timer is Active
	if 0 < bullet.time then
		-- Update the Bullet Position
		bullet_position_old = bullet.position
		--bullet.position = bullet.position + bullet.direction * bullet.speed * dt
		bullet.position = bullet.position + bullet.velocity * dt
		go.set(bullet_id, __msg.prop_position, bullet.position)

	-- Delete the Bullet if the Life Timer has Concluded
	else bullet_delete(self, msg.url(nil, bullet_id, nil) , __msg.prop_position) end
end

--
-- Updates a single BulletFold Bullet, ray casts its path to handle collisions,
-- and registers updates using [go.set()].
--
local function bullet_update_full_raycast(bullet, bullet_id, dt)	
	-- Update the Bullet Life Time
	bullet.time = bullet.time - dt

	-- Update the Bullet if the Life Timer is Active
	if 0 < bullet.time then
		-- Update the Bullet Position
		bullet_position_old = bullet.position
		--bullet.position = bullet.position + bullet.direction * bullet.speed * dt
		bullet.position = bullet.position + bullet.velocity * dt
		go.set(bullet_id, __msg.prop_position, bullet.position)
		
		-- Ray Cast the Bullet and Handle Collisions if Ray Cast Groups were Specified
		bullet_raycast(bullet, bullet_id, bullet_position_old)

	-- Delete the Bullet if the Life Timer has Concluded
	else bullet_delete(self, msg.url(nil, bullet_id, nil) , __msg.prop_position) end
end

----------------------------------------------------------------------------------------------------
-- BulletFold Functions
----------------------------------------------------------------------------------------------------

--
-- Updates each Bullet within the BulletFold Buffer.
--
-- [dt] The time elapsed since the previous frame.
--
function bulletfold.update(dt) for bullet_id, bullet in pairs(bulletfold.bullets) do bullet.update(bullet, bullet_id, dt) end end

--
-- Spawns a new Bullet into the BulletFold Buffer.
--
-- [speed] The speed of the Bullet.
-- [time] The life time of the Bullet, in seconds.
-- [position] The position to spawn the Bullet, as a [vmath.vector3].
-- [direction] The direction the Bullet will travel, as a [vmath.vector3]. Randomized based on the input accuracy.
-- [accuracy] The random spread of the initial Bullet direction. 0 for perfect accuracy.
-- [raycast_groups] The Collision Group IDs the Bullet ray cast will respond to, as a list of hashes.
-- [hit_function] The function called if the Bullet collides with an object specified in the [raycast_groups]. Default is the internal [bullet_hit()] function.
-- RETURNS: [bullet_spawn_id] The ID of the Bullet GameObject spawned by the Bullet Factory.
--
function bulletfold.spawn(speed, time, position, direction, accuracy, raycast_groups, hit_function)
	-- Randomize the Bullet Direction if the Input Accuracy is Not Perfect
	if accuracy ~= 0 then bullet_spawn_direction.x, bullet_spawn_direction.y = rotate(direction, spread(accuracy))
	else bullet_spawn_direction.x = direction.x ; bullet_spawn_direction.y = direction.y end

	-- Set the Bullet Update Function According to the Specified Ray Cast Behvaiour
	bullet_update_behaviour = raycast_groups and bullet_update_raycast or bullet_update
	-- Set the Bullet Hit Function According to the Specified Hit Function
	bullet_hit_behaviour = hit_function and hit_function or bullet_hit
	
	---------------------------------------------------------------------------------------------------
	-- Spawn a New Bullet into the Bullet Buffer
	bullet_spawn(speed, time, position, raycast_groups)
	-- Propel the Bullet Forward and Delete Once the Life Timer has Concluded
	go.animate(bullet_spawn_id, __msg.prop_position, go.PLAYBACK_ONCE_FORWARD, position + bullet_spawn_direction * speed * time, go.EASING_LINEAR, time, 0 --[[delay]], bullet_delete)

	-- Reset the Spawn Properties
	bullet_spawn_direction = vmath.vector3()

	-- Return the Spawned Bullet ID
	return bullet_spawn_id
end

--
-- Spawns a new Bullet updated using [go.set()] into the BulletFold Buffer.
-- Significantly slower than [bulletfold.spawn()].
--
-- [speed] The speed of the Bullet.
-- [time] The life time of the Bullet, in seconds.
-- [position] The position to spawn the Bullet, as a [vmath.vector3].
-- [direction] The direction the Bullet will travel, as a [vmath.vector3]. Randomized based on the input accuracy.
-- [accuracy] The random spread of the initial Bullet direction. 0 for perfect accuracy.
-- [raycast_groups] The Collision Group IDs the Bullet ray cast will respond to, as a list of hashes.
-- [hit_function] The function called if the Bullet collides with an object specified in the [raycast_groups]. Default is the internal [bullet_hit()] function.
-- [update_full] (NOT USED) Update the Bullet using [go.set()] (significantly slower). Default updates the Bullet using [go.animate()].
-- RETURNS: [bullet_spawn_id] The ID of the Bullet GameObject spawned by the Bullet Factory.
--
function bulletfold.spawn_update(speed, time, position, direction, accuracy, raycast_groups, hit_function)
	-- Randomize the Bullet Direction if the Input Accuracy is Not Perfect
	if accuracy ~= 0 then bullet_spawn_direction.x, bullet_spawn_direction.y = rotate(direction, spread(accuracy))
	else bullet_spawn_direction.x = direction.x ; bullet_spawn_direction.y = direction.y end

	-- Set the Bullet Update Function According to the Specified Ray Cast Behvaiour
	bullet_update_behaviour = raycast_groups and bullet_update_full_raycast or bullet_update_full
	-- Set the Bullet Hit Function According to the Specified Hit Function
	bullet_hit_behaviour = hit_function and hit_function or bullet_hit
	
	---------------------------------------------------------------------------------------------------
	-- Spawn a New Bullet into the Bullet Buffer
	bullet_spawn(speed, time, position, raycast_groups)

	-- Reset the Spawn Properties
	bullet_spawn_direction = vmath.vector3()

	-- Return the Spawned Bullet ID
	return bullet_spawn_id
end

--
-- Deletes the specified Bullet from the BulletFold Buffer.
--
-- [bullet_id] The ID of the Bullet to delete from the BulletFold Buffer.
--
function bulletfold.delete(bullet_id) bullet_delete(nil, msg.url(nil, bullet_id, nil) , __msg.prop_position) end

----------------------------------------------------------------------------------------------------
-- BulletFold LUA Module
----------------------------------------------------------------------------------------------------
return bulletfold
----------------------------------------------------------------------------------------------------
