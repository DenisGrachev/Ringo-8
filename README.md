# Ringo Engine
64x48 Graphics Library For **ZX Spectrum 128KB** based on my render engine from [Ringo](https://zxonline.net/game/ringo)

## Quick Start

Grab **sjasmplus** from **z00m128** https://github.com/z00m128/sjasmplus, download Ringo Engine sources, put **sjasmplus.exe** in the right sample folder and compile **main.asm**

## Screen

Screen resolution is **64x48** with **8** bright colors from **Speccy** palette. The display is composed of two layers: **TileMap Layer** and **Sprites Layer**

## TileMap

Default **Tilemap** size is **32x16** and can be changed with **tileMapWidth** and **tileMapHeight** compiler variables.

**Tilemap** support up to **128** unique tiles. There is a special **Tiles Loookup Table** which contains information what **Tile** from **TileSet** to draw for **Tile**. It's useful for fast tiles animations. Check **SIMPLE_TILE_ANIMATION** sample for details.

**TileMap** can be scrolled in the **X** and **Y** direction by changing a variables **tileMapScroll_V** and **tileMapScroll_H**

**TileSet** stores a image with **Tiles**, use **TilesConvertor** to convert from **Png** file to engine format

## Sprites

Sprite Layer draws on top of tiles layer

**Eight** Big Sprites **11x12** and **Sixteen** Small Sprites **5x5**

animations

## Memory map

Write About virtual paging

PAGE 0 - SPRITES + FREE - check gfx/resources.a80

PAGE 1 - FREE

PAGE 2 - MAIN CODE + FREE (32768-48830)

PAGE 3 - FREE

PAGE 4 - TILES CODE 1 + FREE - check gfx/resources.a80 for details

PAGE 5 - MAIN CODE + FREE	- from 24500-32768

PAGE 6 - TILES CODE 2 + FREE - check gfx/resources.a80

PAGE 7 - FREE AFTER SCREEN2

## Advanced Users

Half of import ifx2 coord etc

## Credits

Engine Core - **Denis Grachev** (rook^retrosouls^sibkrew)

Render Optimizations - **Mikhail Vostrikov** (monster^sage)

Sprites Optimizations - **Aleksey Pichugin** (spke^lom), **Mikhail Vostrikov** (monster^sage)

Delay Routine - **Jan Bobrowski**

TapeLib by **Slavo Labsky** (busy)

Tested with **sjasmplus v1.20.1** from **z00m128** https://github.com/z00m128/sjasmplus


