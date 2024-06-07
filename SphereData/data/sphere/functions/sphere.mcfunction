summon minecraft:text_display ~ ~ ~ {see_through:true,billboard:center,transformation:[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0],Tags:[sphere]}
execute store result storage sphere:time gametime int 1 run time query gametime
data modify entity @e[tag=sphere,limit=1] background set from storage sphere:time gametime
