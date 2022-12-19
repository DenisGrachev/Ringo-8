;-----------------------------------------------------------------------------------------;
;	RINGO-8
;-----------------------------------------------------------------------------------------
;	Engine Core - Denis Grachev (rook^retrosouls^sibkrew)
;	Render Optimizations - Mikhail Vostrikov(monster^sage)
;	Sprites Optimizations - Aleksey Pichugin(spke^lom),Mikhail Vostrikov(monster^sage)
;	Delay Routine - Jan Bobrowski
;	TapeLib by Slavo Labsky(busy)
;	Tested with sjasmplus v1.20.1 from z00m128
;	https://github.com/z00m128/sjasmplus
;-----------------------------------------------------------------------------------------


;MEMORY MAP
;PAGE 0 - SPRITES + FREE - check gfx/resources.a80
;PAGE 1 - FREE
;PAGE 2 - MAIN CODE + FREE (32768-48830)
;PAGE 3 - FREE
;PAGE 4 - TILES CODE 1 + FREE - check gfx/resources.a80 for details
;PAGE 5 - MAIN CODE + FREE	- from 24500-32768
;PAGE 6 - TILES CODE 2 + FREE - check gfx/resources.a80
;PAGE 7 - FREE AFTER SCREEN2

;uncomment define for Pentagon timings	
;	define PENTAGON

    device ZXSPECTRUM128	

;============================================================================
;24500 - 32768                                                              
;============================================================================
	page 0
	org 24500
start:
	;set stack and black border
	di : ld sp,24499 : xor a : out (254),a
	;detect hardware and set fast/slow pages	
	call initHardware
	;fill screens with black
	call fillScreens
	;this one generates shifted copies of tiles and prepare screen for render
	call initTiles	
	;enable main interrupt, check sys.a80 for details
	ld hl,mainInterrupt  : call IMON	
	;start game
	jp startGame

;============================================================================
;32768 - 48830
;============================================================================
	page 0
	org 32768
;============================================================================
;ENGINE CORE	
;============================================================================
;DEFAULT SETTINGS
	include "../engine/defaultSettings.a80"
;ENGINE CORE MUST BE IN FAST MEMORY
	include "../engine/core.a80"
;============================================================================
	;start game
startGame:	
	;COPY TESTING MAP TO TILEMAP
	ld hl,testTileMap : ld de,tileMap : ld bc,32*16 : ldir
	;ATTACH SPRITES IMAGE - run code from page 1
	ld a,1 : call swapPage : call initSprites
	;DO SOME PRE INIT HERE	

	;enable render
	call enableRender
	;Game render work in 2 frames, so you have 2 bottom borders time for game logic
	;It's ~12000*2 tStates	
	;main loop	
mainLoop:
;== FRAME 1 =================================================================
	halt : ld hl,renderFrame2 : ld (intProc+1),hl	
;============================================================================		
;PLACE YOUR CODE HERE ~12000t
;============================================================================	
;
;
	;move tilemap - run code from page 1
	ld a,1 : call swapPage
	call doSinScroll	

	;move sprites - run code from page 3
	ld a,3 : call swapPage
	call moveSprites

;
;
;== FRAME 2 =================================================================
	halt : ld hl,renderFrame1 : ld (intProc+1),hl	
;============================================================================			
;PLACE YOUR CODE HERE ~12000t
;============================================================================		
;
;
;
;
;
	jp mainLoop
;============================================================================
;FREE SPACE TILL 48830	
;============================================================================		


testTileMap:
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,0,1,0,0,0,1,0,1,1,1,1,0,1
    db 1,0,0,1,0,0,1,0,0,0,1,0,0,0,0,1,0,0,1,0,1,1,0,0,1,0,1,0,0,0,0,1
    db 1,0,0,1,0,0,1,1,0,0,1,1,1,0,0,1,0,0,1,0,1,0,1,0,1,0,1,0,1,1,0,1
    db 1,0,0,1,0,0,1,0,0,0,0,0,1,0,0,1,0,0,1,0,1,0,0,1,1,0,1,0,0,1,0,1
    db 1,0,0,1,0,0,1,1,1,0,1,1,1,0,0,1,0,0,1,0,1,0,0,0,1,0,1,1,1,1,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,2,2,2,0,2,2,2,0,2,2,2,0,2,2,2,0,2,0,2,0,0,0,2,0,2,2,2,2,0,1
    db 1,0,0,2,0,0,2,0,0,0,2,0,0,0,0,2,0,0,2,0,2,2,0,0,2,0,2,0,0,0,0,1
    db 1,0,0,2,0,0,2,2,0,0,2,2,2,0,0,2,0,0,2,0,2,0,2,0,2,0,2,0,2,2,0,1
    db 1,0,0,2,0,0,2,0,0,0,0,0,2,0,0,2,0,0,2,0,2,0,0,2,2,0,2,0,0,2,0,1
    db 1,0,0,2,0,0,2,2,2,0,2,2,2,0,0,2,0,0,2,0,2,0,0,0,2,0,2,2,2,2,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1    
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1


	;WAARNING IF HIT IM TABLE
	assert $<48830, Program code leaks into IM2 vector area
	;display free space till #bebe
	display "FREE SPACE TILL VECTOR TABLE: ",/d,48830-$
;============================================================================
;ENGINE RESOURCES IN DIFFERENT PAGES
;check memory map and resources.a80 for details
;============================================================================
	;include resources in pages
	include "gfx/resources.a80"



	page 1
	org 49152

initSprites:

	;BIG SPRITES IMAGES
	ld ix,spritesList :	ld hl,testSprite : ld de,SPRITE
	ld b,8
1:
	;attach image
	ld (ix+SPRITE.IMAGE),l : ld (ix+SPRITE.IMAGE+1),h
	;static X	
	ld a,b :  add a,a : add a,a : add a,a : add 3 : ld (ix+SPRITE.X),a
	add ix,de
	djnz 1b


	;SMALL SPRITES IMAGES
	ld ix,spritesList+8*SPRITE : ld hl,testSmallSprite : ld de,SPRITE
	ld b,8
1:
	;attach image
	ld (ix+SPRITE.IMAGE),l : ld (ix+SPRITE.IMAGE+1),h
	;static Y	
	ld a,b : add a,a : add a,a : add a,b : add a,b : add 7 : ld (ix+SPRITE.Y),a
	add ix,de
	djnz 1b	

	;SMALL SPRITES IMAGES
	ld ix,spritesList+16*SPRITE : ld hl,testSmallSprite : ld de,SPRITE
	ld b,8
1:
	;attach image
	ld (ix+SPRITE.IMAGE),l : ld (ix+SPRITE.IMAGE+1),h
	;static Y	
	ld a,b : add a,a : add a,a : add a,b : add a,b : add 7 : ld (ix+SPRITE.Y),a
	add ix,de
	djnz 1b	

	ret


doSinScroll:
	;calculate some sinus and apply to scroll 'registers'
sinPointerX:	
	ld hl,sin+192 : inc l : ld (sinPointerX+1),hl
	ld a,(hl) : add 4 : ld (tileMapScroll_H),a
sinPointerY:	
	ld hl,sin : inc l : ld (sinPointerY+1),hl
	ld a,(hl) : srl a : srl a : add 4 : ld (tileMapScroll_V),a
	ret	
	;include SINUS table
	align 256
sin:
	align 256
	incbin "data/sin.bin"



	page 3
	org 49152
sinX:
	align 256
	incbin "data/sin01.bin"
sinY:
	align 256
	incbin "data/sin02.bin"	

moveSprites:

;move big sprites
sinPointer: ld hl,sinY : inc l : inc l : inc l : ld (sinPointer+1),hl
	ld ix,spritesList+0*SPRITE
	ld de,SPRITE

	ld b,8
1:
;move Y
	ld a,(hl) : ld (ix+SPRITE.Y),a : inc l : inc l : inc l : inc l
	add ix,de
	djnz 1b

;move small sprites
sinPointer2: ld hl,sinX : inc l : inc l : inc l : ld (sinPointer2+1),hl

	ld b,8
1:
;move X
	ld a,(hl) : ld (ix+SPRITE.X),a : inc l : inc l : inc l : inc l
	add ix,de
	djnz 1b


	ld a,64 : add l : ld l,a

	ld b,8	
1:
;move X
	ld a,(hl) : ld (ix+SPRITE.X),a : inc l : inc l : inc l : inc l
	add ix,de
	djnz 1b

	ret





;GENERATE SIMPLE TAP LOADER AT THE END
;============================================================================
	page 0
	include "../engine/loader.a80"
	IF (_ERRORS = 0)                                 		
			SHELLEXEC "main.tap"	
	ENDIF
