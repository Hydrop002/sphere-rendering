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

![0](img/2024-05-21_16.22.10.png)

![1-1](img/2024-05-21_17.26.26.png)

![1-2](img/2024-05-21_17.28.08.png)

![2](img/2024-05-21_17.22.21.png)
