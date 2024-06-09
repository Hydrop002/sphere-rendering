execute as @e[type=minecraft:item,nbt={Item:{id:"minecraft:tnt"}},limit=1] at @s store result score @s thrower run data get entity @s Thrower
execute as @e[scores={thrower=4},nbt={Age:1s}] store result entity @s Motion[0] double 0.001 run data get entity @s Motion[0] 10000
execute as @e[scores={thrower=4},nbt={Age:1s}] store result entity @s Motion[1] double 0.0005 run data get entity @s Motion[1] 10000
execute as @e[scores={thrower=4},nbt={Age:1s}] store result entity @s Motion[2] double 0.001 run data get entity @s Motion[2] 10000

execute as @e[scores={thrower=4},nbt={OnGround:1b}] at @s unless entity @e[tag=sphere] run function sphere:sphere
kill @e[scores={thrower=4},nbt={OnGround:1b}]
scoreboard players add @e[tag=sphere] timer 1
kill @e[tag=sphere,scores={timer=100}]
