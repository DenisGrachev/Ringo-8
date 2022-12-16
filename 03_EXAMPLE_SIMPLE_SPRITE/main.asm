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

	;start game
startGame:	
	;DO SOME PRE INIT HERE
	;set sprite image for sprite00
	ld hl,testSprite : ld (sprite00+SPRITE.IMAGE),hl
	;set XY coords
	ld a,12 : ld (sprite00+SPRITE.X),a
	ld a,12 : ld (sprite00+SPRITE.Y),a
	;set animation max frame
	ld a,ANIM_FRAMES_4 : ld (sprite00+SPRITE.MAX_FRAME),a
	;set animation speed
	ld a,ANIM_SPEED_2 : ld (sprite00+SPRITE.ANIM_SPEED),a

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
	ld a,(sprite00_X) : inc a : and 63 : ld (sprite00_X),a
	ld a,(sprite00_Y) : inc a : and 63 : ld (sprite00_Y),a
;
;== FRAME 2 =================================================================
	halt : ld hl,renderFrame1 : ld (intProc+1),hl	
;============================================================================			
;PLACE YOUR CODE HERE ~12000t
;============================================================================		
;		
;
;
	jp mainLoop
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
	include "../engine/loader.a80"
	IF (_ERRORS = 0)                                 		
			SHELLEXEC "main.tap"	
	ENDIF
