# Zoonami
A mod for Minetest that allows you to collect and train monsters that can be used in battles.

Version 0.3.1

## Warning
This mod is incomplete, has bugs, and can cause server crashes. Only use it for testing 
and experimenting. There is not a lot of content to explore and enjoy at this time.

## Description
This mod adds monsters that you can collect, train, and use in battles. The battles
use a formspec interface that looks and feels similar to a true 2D RPG. It takes 
advantage of the latest additions in Minetest 5.4.0 to control font sizes, styling, 
and animated images in the battle formspec.

New players that join the world will be given a few monsters for testing purposes.
At some point, a proper way for choosing a starter monster will be made. Monsters 
can be found roaming the world or spawned in via creative mode spawn eggs.
Right clicking on a monster will initate a battle. If you need to immediately exit
a battle, you can press ESC or whatever key you would normally use to exit a
formspec.

## Requirements
This mod requires Minetest 5.4.0 or later.  
It also requires [fsc](https://forum.minetest.net/viewtopic.php?t=19203) and [mobs redo](https://forum.minetest.net/viewtopic.php?t=9917) mods. The [sfinv](https://forum.minetest.net/viewtopic.php?t=19765) mod is currently optional, but it may become required in the future.

## Main Goals
- [ ] Ensure all formspecs are secure and cannot be used to crash a server
- [ ] Fully implement player vs. computer battles
- [ ] Fully implement player vs. player battles
- [ ] Add a large amount of monsters to collect
- [ ] Balance monster stats
- [ ] Add details to monster spawning conditions (time of day, biomes, etc)

## Bug reports and ideas
Bugs and ideas can be submitted [here](https://forum.minetest.net/viewtopic.php?f=9&t=25356&sid=1ffebc6a6c8b35653d939a376a067a7f), or [here](https://github.com/isaiah658/zoonami/issues/new).

## Links
* [Minetest Forums](https://forum.minetest.net/viewtopic.php?f=9&t=25356&sid=1ffebc6a6c8b35653d939a376a067a7f)
* [GitHub](http://github.com/isaiah658/zoonami/)

## Licensing
License Links:  
(CC0) https://creativecommons.org/publicdomain/zero/1.0/

License of Media:  
Monster RPG 2 (https://opengameart.org/content/42-monster-rpg-2-music-tracks) (CC0)
	sounds/zoonami_battle.ogg (Edited to seemlessly loop by isaiah658)

isaiah658 (CC0)
	All sounds and textures not listed above were created by isaiah658 and are licensed as CC0.

License of Code:  
Copyright 2020 isaiah658

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
