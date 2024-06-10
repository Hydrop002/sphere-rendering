# sphere-rendering

This repository attempts to render sphere in Minecraft 1.20.6.

## Forward pass value

How to forward pass values without losing precision is the key to this repository. Here is my solution. Requires glsl version 400 or higher.
```mermaid
graph LR
	floatBitsToUint --> bitfieldExtract
	bitfieldExtract --> bitfieldInsert
	bitfieldInsert --> uintBitsToFloat
```

## Gallery

![0](img/2024-06-10_17.13.45.png)
