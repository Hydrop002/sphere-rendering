# execute as @a run function sphere:player with entity @s
# x -> $(UUID).x

execute if entity @p unless entity @e[tag=pixel1] run summon minecraft:text_display ~ ~1 ~ {see_through:true,billboard:center,transformation:[100.0,0.0,0.0,-1.25,0.0,100.0,0.0,-1.25,0.0,0.0,100.0,0.0,0.0,0.0,0.0,1.0],Tags:[pixel1]}
execute if entity @p unless entity @e[tag=pixel2] run summon minecraft:text_display ~ ~1 ~ {see_through:true,billboard:center,transformation:[100.0,0.0,0.0,-1.25,0.0,100.0,0.0,-1.25,0.0,0.0,100.0,0.0,0.0,0.0,0.0,1.0],Tags:[pixel2]}
execute if entity @p unless entity @e[tag=pixel3] run summon minecraft:text_display ~ ~1 ~ {see_through:true,billboard:center,transformation:[100.0,0.0,0.0,-1.25,0.0,100.0,0.0,-1.25,0.0,0.0,100.0,0.0,0.0,0.0,0.0,1.0],Tags:[pixel3]}

execute as @p store result score @s pos run data get entity @s Pos[0] 255
scoreboard players add @p pos 8355840
scoreboard players operation @p pos_part = @p pos
scoreboard players operation @p pos_part %= 255 math
scoreboard players operation @p pos_comp = @p pos_part
scoreboard players operation @p pos /= 255 math
scoreboard players operation @p pos_part = @p pos
scoreboard players operation @p pos_part %= 255 math
scoreboard players operation @p pos_part *= 256 math
scoreboard players operation @p pos_comp += @p pos_part
scoreboard players operation @p pos /= 255 math
scoreboard players operation @p pos_part = @p pos
scoreboard players operation @p pos_part %= 255 math
scoreboard players operation @p pos_part *= 65536 math
scoreboard players operation @p pos_comp += @p pos_part
execute store result storage sphere:pos x long 1 run scoreboard players get @p pos_comp

execute as @p store result score @s pos run data get entity @s Pos[1] 255
scoreboard players add @p pos 8355840
scoreboard players operation @p pos_part = @p pos
scoreboard players operation @p pos_part %= 255 math
scoreboard players operation @p pos_comp = @p pos_part
scoreboard players operation @p pos /= 255 math
scoreboard players operation @p pos_part = @p pos
scoreboard players operation @p pos_part %= 255 math
scoreboard players operation @p pos_part *= 256 math
scoreboard players operation @p pos_comp += @p pos_part
scoreboard players operation @p pos /= 255 math
scoreboard players operation @p pos_part = @p pos
scoreboard players operation @p pos_part %= 255 math
scoreboard players operation @p pos_part *= 65536 math
scoreboard players operation @p pos_comp += @p pos_part
scoreboard players add @p pos_comp 16777216
execute store result storage sphere:pos y long 1 run scoreboard players get @p pos_comp

execute as @p store result score @s pos run data get entity @s Pos[2] 255
scoreboard players add @p pos 8355840
scoreboard players operation @p pos_part = @p pos
scoreboard players operation @p pos_part %= 255 math
scoreboard players operation @p pos_comp = @p pos_part
scoreboard players operation @p pos /= 255 math
scoreboard players operation @p pos_part = @p pos
scoreboard players operation @p pos_part %= 255 math
scoreboard players operation @p pos_part *= 256 math
scoreboard players operation @p pos_comp += @p pos_part
scoreboard players operation @p pos /= 255 math
scoreboard players operation @p pos_part = @p pos
scoreboard players operation @p pos_part %= 255 math
scoreboard players operation @p pos_part *= 65536 math
scoreboard players operation @p pos_comp += @p pos_part
scoreboard players add @p pos_comp 33554432
execute store result storage sphere:pos z long 1 run scoreboard players get @p pos_comp

execute as @p at @s rotated as @s anchored eyes run function sphere:pixel with storage sphere:pos
