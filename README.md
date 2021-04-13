# ***BulletFold***

> Simple, lightweight bullet handler for Defold.

-----

![BulletFold Demo](example/gfx/bulletfold_demo.jpg "BulletFold Demo")

-----

## **Features**

- Per Bullet ray casting and Collision Groups.

- Per Bullet hit function behaviour.

- Per Bullet update behaviour.

- Multiple Bullet update functions based on spawn parameters.

- Two Bullet movement types: handled by [go.animate()] or updated using [go.set()] (significantly slower).

-----

## **Installation**

*TO DO...*

-----

## **Quick Setup**

### *Module*

1.  local bulletfold = require "bulletfold_directory.bulletfold"

### *Initialize*

2.  bulletfold.factory = "/bullets#factory"

3. a. (**Enable**)  bulletfold.raycast_groups = { hash("collision_group1"), hash("collision_group2") }

3. b. (**Disable**) bulletfold.raycast_groups = nil

4. a. (**Enable**)  bulletfold.hitmarker = function(position, bullet_id, object_id) --[[ Function ]] end

4. b. (**Disable**) bulletfold.hitmarker = nil

### *Spawn*

5. a. bullet_id = bulletfold.spawn(speed, time, position, direction, accuracy, bulletfold.raycast_groups, custom_hit_function)

5. b. bullet_id = bulletfold.spawn(speed, time, position, direction, accuracy, { hash("custom_group1") }, custom_hit_function)

### *Update*

6.  bulletfold.update(dt)

### *Delete*

7.  bulletfold.delete(bullet_id)
