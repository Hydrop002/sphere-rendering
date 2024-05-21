# sphere-rendering

This repository attempts to render sphere in Minecraft 1.20.6.

## Currently problems

* Although I extracted the rotation information from the ModelViewMat when rendering the text_display entity, there was still twitching when the player rotated. I've tried using more pixels to improve the precision of the rotation, but that doesn't seem to work.
* Since commands are executed every gt, and tps is often lower than fps, the position information passed from forward rendering needs to be interpolated. I tried simulating partialTicks with `fract(Time*20.0)` but that doesn't seem to work either.

## Gallery

![0](img/2024-05-21_16.22.10.png)

![1-1](img/2024-05-21_17.26.26.png)

![1-2](img/2024-05-21_17.28.08.png)

![2](img/2024-05-21_17.22.21.png)
