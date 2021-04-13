# ***BulletFold***

> Simple, lightweight bullet handler for Defold.

-----

![BulletFold Demo](example/gfx/bulletfold_demo.jpg "BulletFold Demo")

-----

## **Features**

- Per Bullet ray casting and Collision Groups.

- Per Bullet hit function and hit marker behaviour.

- Per Bullet update behaviour.

- Multiple Bullet update functions based on spawn parameters.

- Two Bullet movement types: handled by [**go.animate()**] or updated using [**go.set()**] (significantly slower).

-----

## **Installation**

*TO DO...*

-----

## **Guide**

*TO DO...*

-----

## **Quick Start**

### *Module*

    local bulletfold = require "bulletfold_directory.bulletfold"

### *Initialize*

1. Default Bullet Factory:

        bulletfold.factory = "/bullets#factory"

2. Default Ray Cast Collsion Groups:

        bulletfold.raycast_groups = { hash("collision_group1"), hash("collision_group2") }

3. Default Hit Marker Function:

        bulletfold.hitmarker = function(position, bullet_id, object_id) --[[ Function ]] end

### *Spawn*

- Spawn Bullets updated using [**go.animate()**] (*Best Performance*):

        local bullet_id = bulletfold.spawn(speed, time, position, direction, accuracy, bulletfold.raycast_groups, custom_hit_function)

    or

        bulletfold.spawn(speed, time, position, direction, accuracy, { hash("col_group1") }, custom_hit_function)

- Spawn Bullets updated using [**go.set()**]:

        local bullet_id = bulletfold.spawn_update(speed, time, position, direction, accuracy, bulletfold.raycast_groups, custom_hit_function)

    or

        bulletfold.spawn_update(speed, time, position, direction, accuracy, { hash("col_group1") }, custom_hit_function)

- Custom Hit Functions:

        local custom_hit_function = function(position, bullet_id, object_id) hitmarker(position) ; bulletfold.delete(bullet_id) end

### *Update*

    bulletfold.update(dt)

### *Delete*

    bulletfold.delete(bullet_id)
