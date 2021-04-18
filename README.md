# ***BulletFold***

> Simple, lightweight bullet handler for Defold.

-----

![BulletFold Demo](example/gfx/bulletfold_demo.png "BulletFold Demo")

![BulletFold Profiler Demo](example/gfx/bulletfold_profiler.png "BulletFold Profiler Demo")

-----

## **Features**

- Central Bullet handler module.

- Per Bullet ray casting and Collision Groups.

- Per Bullet hit response functions and hit marker functions.

- Per Bullet update behaviour.

- Two Bullet movement types: handled by [**go.animate()**] or updated using [**go.set()**] (significantly slower).

-----

## **Installation**

*TO DO...*

-----

## **Guide**

*TO DO...*

-----

## **Quick Start**

Please see the **[quick_start.script_snippet](quick_start.script_snippet)** for a basic implementation.

### *GameObjects*

- **Bullets**: Create a GameObject named "*bullets*" and create a Factory component named "*factory*" within the GameObject.

- **Hit Markers**: Create a GameObject named "*hit_markers*" and create a Factory component named "*factory*" within the GameObject.

### *Module*

```lua
local bulletfold = require "bulletfold_directory.bulletfold"
```

### *Initialize*

1. Default Bullet Factory:

    ```lua
    bulletfold.factory = "/bullets#factory"
    ```

2. Default Ray Cast Collsion Groups:

    ```lua
    bulletfold.raycast_groups = { hash("collision_group1"), hash("collision_group2") }
    ```

3. (**Optional**) Default Hit Marker Function. If not initialized, spawns a default hit marker:

    ```lua
    bulletfold.hitmarker = function(position, bullet_id, object_id) factory.create("/hit_markers#factory", position) end
    ```

    *Parameters*

    - [***position***] `vmath.vector3` The Bullet collision position.

    - [***bullet_id***] `hash` The Bullet GameObject ID.

    - [***object_id***] `hash` The ID of the GameObject the Bullet collided with.

### *Spawn*

- Spawn a Bullet updated using [**go.animate()**] (*Best Performance*):

    ```lua
    bullet_id = bulletfold.spawn(speed, time, position, direction, accuracy, [raycast_groups], [factory], [hit_response])
    ```

- Spawn a Bullet updated using [**go.set()**] (*Slower, Full Control Over Movement*):

    ```lua
    bullet_id = bulletfold.spawn_update(speed, time, position, direction, accuracy, [raycast_groups], [factory], [hit_response])
    ```

- Custom Bullet hit response function:

    ```lua
    hit_response = function(bullet_id, result) hitmarker(result.position) ; bulletfold.delete(bullet_id) end
    ```

### *Update*

- Update the BulletFold buffer:

    ```lua
    function update(self, dt)
        bulletfold.update(dt)
    end
    ```

-----

## **API**

### *Properties*

## bulletfold.bullets `table`

- The Bullet buffer. Contains all active bullets. Bullet GameObject ID hashes are used as table keys. 

    *Bullet Parameters*

    - [***time***] `double` The time remaining before the Bullet is deleted.

    - [***speed***] `double` The Bullet speed.

    - [***position***] `vmath.vector3` The current Bullet position. If spawned using `bulletfold.spawn()` and is not ray casting, the position is not updated after spawning (improves performance).

    - [***direction***] `vmath.vector3` The current Bullet travel direction. Can only be changed if the Bullet was spawned using `bulletfold.spawn_update()`.

    - [***raycast_groups***] `hash table` The Collision Groups the Bullet ray cast can collide with. `nil` to disable ray casting.

    - [***hit***] `function` The function called when the Bullet hits an object. Default calls the Bullet Hit Marker function and deletes the Bullet.

    - [***hitmark***] `function` The function called when the Bullet hits an object, if a custom hit response function was not provided.

## bulletfold.bullet_count `unsigned int`

- The number of Bullets in the `bulletfold.bullets` buffer.

## bulletfold.factory `URL string`

- Default Bullet Factory. Used if no Factory is provided during spawning.

    ```lua
    bulletfold.factory = "/game_object#factory_component"
    ```

## bulletfold.raycast_groups `hash table`

- Default Ray Cast Collsion Groups. Used if no table of Collision Groups is provided during spawning.

    ```lua
    bulletfold.raycast_groups = { hash("collision_group1"), hash("collision_group2") }
    ```

## bulletfold.hitmarker `function`

- (**Optional**) Default Hit Marker function, called if no hit response function is provided during spawning. If not initialized, spawns a default hit marker using the function below.

    *Parameters*

    - [***position***] `vmath.vector3` The Bullet collision position.

    - [***bullet_id***] `hash` The Bullet GameObject ID.

    - [***object_id***] `hash` The ID of the GameObject the Bullet collided with.

    ```lua
    bulletfold.hitmarker = function(position, bullet_id, object_id)
	    local hitmark_id = factory.create("/hit_markers#factory", position)
	    go.animate(msg.url(nil, hitmark_id, "sprite"), "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_LINEAR, 1, 0, function() go.delete(hitmark_id) end)
    end 
    ```

### *Spawn Functions*

## bulletfold.spawn(speed, time, position, direction, accuracy, [raycast_groups], [factory], [hit_response])

- Spawn a Bullet updated using [**go.animate()**] (*Best Performance*):

    *Parameters*

    - [***speed***] `double` The Bullet speed.

    - [***time***] `double` The Bullet life time, in seconds.

    - [***position***] `vmath.vector3` The Bullet spawn position.

    - [***direction***] `vmath.vector3` The Bullet travel direction.

    - [***accuracy***] `double` The Bullet accuracy, used to randomize the direction. 0 for perfect accuracy.

    - [***raycast_groups***] `hash table` (**Optional**) The Collision Groups the Bullet ray cast can collide with. `nil` to disable ray casting.

    - [***factory***] `string` (**Optional**) The URL string of the Factory component used to spawn the Bullet GameObject. Default is the BulletFold Factory.

    - [***hit_response***] `function` (**Optional**) The function called when the Bullet hits an object. Default calls the Bullet Hit Marker function and deletes the Bullet.

        *Parameters*

        - [***bullet_id***] `hash` The Bullet GameObject ID.

        - [***result***] `table` The result of the Bullet ray cast collision.

            - [***normal***] `vmath.vector3` The surface normal of the Collision Object the Bullet collided with.

            - [***fraction***] `double` The fraction along the ray cast where the collision occured. 0 is the start, 1 is the end.

            - [***position***] `vmath.vector3` The collision position.

            - [***group***] `hash` The Collision Group ID of the Collision Object.

            - [***id***] `hash` The ID of the GameObject the Bullet collided with.

    *Returns*

    - [***bullet_id***] `hash` The Bullet GameObject ID.

    ```lua
    bullet_id = bulletfold.spawn(speed, time, position, direction, accuracy, [raycast_groups], [factory], [hit_response])
    ```

## bulletfold.spawn_update(speed, time, position, direction, accuracy, [raycast_groups], [factory], [hit_response])

- Spawn a Bullet updated using [**go.set()**] (*Slower, Full Control Over Movement*):

    *Parameters*

    - [***speed***] `double` The Bullet speed.

    - [***time***] `double` The Bullet life time, in seconds.

    - [***position***] `vmath.vector3` The Bullet spawn position.

    - [***direction***] `vmath.vector3` The Bullet travel direction.

    - [***accuracy***] `double` The Bullet accuracy, used to randomize the direction. 0 for perfect accuracy.

    - [***raycast_groups***] `hash table` (**Optional**) The Collision Groups the Bullet ray cast can collide with. `nil` to disable ray casting.

    - [***factory***] `string` (**Optional**) The URL string of the Factory component used to spawn the Bullet GameObject. Default is the BulletFold Factory.

    - [***hit_response***] `function` (**Optional**) The function called when the Bullet hits an object. Default calls the Bullet Hit Marker function and deletes the Bullet.

        *Parameters*

        - [***bullet_id***] `hash` The Bullet GameObject ID.

        - [***result***] `table` The result of the Bullet ray cast collision.

            - [***normal***] `vmath.vector3` The surface normal of the Collision Object the Bullet collided with.

            - [***fraction***] `double` The fraction along the ray cast where the collision occured. 0 is the start, 1 is the end.

            - [***position***] `vmath.vector3` The collision position.

            - [***group***] `hash` The Collision Group ID of the Collision Object.

            - [***id***] `hash` The ID of the GameObject the Bullet collided with.

    *Returns*

    - [***bullet_id***] `hash` The Bullet GameObject ID.

    ```lua
    bullet_id = bulletfold.spawn_update(speed, time, position, direction, accuracy, [raycast_groups], [factory], [hit_response])
    ```

### *Update Functions*

## bulletfold.update(dt)

- Updates the BulletFold buffer.

    *Parameters*

    - [***dt***] `double` The time elapsed since the previous frame.

### *Delete Functions*

## bulletfold.delete(bullet_id)

- Deletes a Bullet and removes it from the BulletFold buffer.

    *Parameters*

    - [***bullet_id***] `hash` The Bullet GameObject ID.

## bulletfold.clear()

- Deletes every Bullet from the BulletFold buffer.

-----

## Credits

BulletFold is based on [DefBullet](https://github.com/subsoap/defbullet) by [SubSoap](https://github.com/subsoap).
