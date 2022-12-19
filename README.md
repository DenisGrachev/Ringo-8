# Ringo-8

**Ringo-8** is a **64x48** Graphics Library For **ZX Spectrum 128KB** based on my render engine from [Ringo](https://zxonline.net/game/ringo)

## Quick Start

Grab **sjasmplus** from **z00m128** https://github.com/z00m128/sjasmplus, download **Ringo-8** sources, put **sjasmplus.exe** in the right sample folder and compile **main.asm**

## Screen

Screen resolution is **64x48** with **8** bright colors from **Speccy** palette. The display is composed of two layers: **TileMap Layer** and **Sprites Layer**

## Render

**Ringo-8** Render works in two frames, so you have two bottom borders time (~12000tStates) for game logic. Check samples for details.

You can imagine that your speccy is a fantasy console running at **25FPS** with Z80 limited with **~24000tStates** and **TileSpriteUnit**

## TileMap

Default **Tilemap** size is **32x16** and can be changed with **tileMapWidth** and **tileMapHeight** compiler variables.

**Tilemap** support up to **128** unique tiles. There is a special **Tiles Loookup Table** which contains information what **Tile** from **TileSet** to draw for **Tile**. It's useful for fast tiles animations. Check **SIMPLE_TILE_ANIMATION** sample for details.

There is also support for **256 Tiles Mode**, but availabled memory only for **186**. It's possible to reduce tile memory size but this breaks cheap vertical tiles animation and vertical parallax become a harder. Check **TILE_256_MODE** sample for details.

**TileMap** can be scrolled in the **X** and **Y** direction by changing a variables **tileMapScroll_V** and **tileMapScroll_H**

**TileSet** stores a image with **Tiles**, use **TilesConvertor** to convert from **Png** file to engine format.

## Sprites

Sprite Layer draws on top of tiles layer

**Eight** Big Sprites **11x12** and **Sixteen** Small Sprites **5x5**

Big sprites support auto animation, you need to specify a **MAX_FRAME** and **ANIM_SPEED** variables with predefined speeds and max frame constants. Check **SPRITE_ANIMATION** sample for details.

There is a 3 sprite modes supported:

**MODE 0** - all small sprites **ABOVE** big sprites

**MODE 1** - all small sprites **BELOW** big sprites

**MODE 2** - 8 small sprites **BELOW** big sprites and 8 small sprites **ABOVE** big sprites

Sprites mode can be changed via **SPRITE_MODE** compiler variable

Check **SPRITE_MODES** sample for details

Use **SpritesConvertor** to convert from **Png** file to engine format, any color that don't match a speccy bright palette will be a transparent.


## Memory map

**PAGE 0** - SPRITES + FREE - check gfx/resources.a80

**PAGE 1** - FREE

**PAGE 2** - MAIN CODE + FREE (32768-48830)

**PAGE 3** - FREE

**PAGE 4** - TILES CODE 1 + FREE - check gfx/resources.a80 for details

**PAGE 5** - MAIN CODE + FREE	- from 24500-32768

**PAGE 6** - TILES CODE 2 + FREE - check gfx/resources.a80

**PAGE 7** - FREE AFTER SCREEN2

Please use **swapPage** function from engine core, check **PAGED_CODE** sample for details

## Credits

Engine Core - **Denis Grachev** (rook^retrosouls^sibkrew)

Render Optimizations - **Mikhail Vostrikov** (monster^sage)

Sprites Optimizations - **Aleksey Pichugin** (spke^lom), **Mikhail Vostrikov** (monster^sage)

Delay Routine - **Jan Bobrowski**

TapeLib by **Slavo Labsky** (busy)

Tested with **sjasmplus v1.20.1** from **z00m128** https://github.com/z00m128/sjasmplus


