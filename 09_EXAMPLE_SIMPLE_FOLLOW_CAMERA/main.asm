;-----------------------------------------------------------------------------------------;
;	RINGO Engine
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
	;define PENTAGON

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
;include simple camera
	;include "../engine/simpleCamera.a80"
	include "simpleCamera.a80"

;
entityPosition:
entityX: db 64
entityY: db 64

	;start game
startGame:	
	;DO SOME PRE INIT HERE
	;set sprite image for sprite00
	ld hl,testSprite : ld (sprite00+SPRITE.IMAGE),hl
	;copy test level
	ld hl,testTileMap : ld de,tileMap : ld bc,32*16 : ldir
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

;correction
spriteSize = -(12+32-6)-(12+18)*256;
	ld hl,(entityPosition) : ld de,spriteSize : add hl,de : ld (cameraTarget),hl

	call doCamera;move camera to cameraTarget

;====================================================
	;get current scroll values
	ld hl,(tileMapScroll)
	;set sprite position in for entity
	ld a,(entityX) : sub l : ld (sprite00_X),a
	ld a,(entityY) : sub h : ld (sprite00_Y),a
;====================================================
;
;== FRAME 2 =================================================================
	halt : ld hl,renderFrame1 : ld (intProc+1),hl	
;============================================================================			
;PLACE YOUR CODE HERE ~12000t
;============================================================================		
;

	ld hl,(entityPosition)
;P	
    LD    BC,57342
    IN    A,(C)
    BIT 0,A
    jr nz,1f 
	inc l : inc l

1:
;O	
    LD    BC,57342
    IN    A,(C)
    BIT 1,A
    jr nz,1f 
	dec l : dec l
1:

    ;Q
    ld bc,64510
    in a,(c)
    BIT 0,A
    jr nz,1f 
    dec h : dec h
1:

    ;A
    ld bc,65022
    in a,(c)
    BIT 0,A
    jr nz,1f 
	inc h : inc h
1:

	ld (entityPosition),hl

;
	jp mainLoop


testTileMap:
    db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
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
    db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1


;============================================================================
;FREE SPACE TILL 48830	
;============================================================================		
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
;GENERATE SIMPLE TAP LOADER AT THE END
;============================================================================
	page 0
	include "loader.a80"
	IF (_ERRORS = 0)                                 		
			SHELLEXEC "main.tap"	
	ENDIF
