tp @e[tag=pixel1] ^ ^ ^1
tp @e[tag=pixel2] ^ ^ ^1
tp @e[tag=pixel3] ^ ^ ^1

$data modify entity @e[tag=pixel1,limit=1] background set value $(x)L
$data modify entity @e[tag=pixel2,limit=1] background set value $(y)L
$data modify entity @e[tag=pixel3,limit=1] background set value $(z)L
