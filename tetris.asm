# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Features:
# 1. press p to pause game
# 2. implements gravity
# 3. implements game over screen, press r to restart
# 5. preview screen in top left showing next tetromino
# 6. the more lines you clear the faster the tetromino will fall, up to a maximum speed
#
# How to play:
# PRESS SPACE TO START
# PRESS W TO ROTATE TETROMINO ONCE CLOCKWISE
# PRESS A TO MOVE LEFT, D TO MOVE RIGHT
# PRESS S TO MOVE DOWN BY ONE BLOCK (TETROMINO WILL ALSO FALL AT A CONSTANT RATE)
# PRESS P TO PAUSE GAME AND P AGAIN TO UNPAUSE
# FILL IN AN ENTIRE LINE TO CLEAR IT
# PRESS Q AT ANY TIME TO QUIT
# IN GAME OVER SCREEN, PRESS R TO RESTART A NEW GAME
#
#####################################################################

##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
#TETROMINOS
T_0: .word -4,0,4,-128, T_1
T_1: .word 0,4,128,-128, T_2
T_2: .word -4,0,4,128, T_3
T_3: .word 0,-4,128,-128, T_0

L_0: .word 0,-128,128,132, L_1
L_1: .word 0,4,-4,124, L_2
L_2: .word 0,128,-128,-132, L_3
L_3: .word 0,4,-4,-124, L_0

J_0: .word 0,128,-128,124, J_1
J_1: .word 0,4,-4,-132, J_2
J_2: .word 0,128,-128,-124, J_3
J_3: .word 0,4,-4,132, J_0

O_0: .word 0,4,-128,-124, O_0

I_0: .word 0,128,256,-128, I_1
I_1: .word 0,4,8,-4, I_0

S_0: .word 0,128,-4,-132, S_1
S_1: .word 0,-4,-128,-124, S_0

Z_0: .word 0,128,4,-124, Z_1
Z_1: .word 0,4,-128,-132, Z_0


##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

main:
	jal draw_start	#draw start screen
	j start_loop
	start:
	jal clear_board	#clear display
    # Initialize the game
	lw $t0, ADDR_DSPL
	addi $t0, $t0, 520
	move $s4, $t0	#$s4 stores location of preview tetromino
	addi $t0, $t0, 312	#sets spawning location of tetrominos
	move $s0, $t0
	
	li $s7, 50	#falling speed
	
	
	#draw board and border
	jal DRAW_BOARD
	jal draw_top_bottom_borders
	jal draw_side_borders
	
	#get a tetromino and store in preview, then get another tetromino
	jal get_tetromino
	move $s1, $s5
	move $s2, $s6
	jal get_tetromino
	jal draw_preview
	#go to game loop
	j game_loop
draw_preview:

	#clear preview screen
	lw $t0, ADDR_DSPL
	addi $t0, $t0, 388
	li $t1, 0x000000
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 388($t0)
	sw $t1, 516($t0)
	
	move $t9, $s6
	
	#initailize loop variables
	add $t0, $zero, $zero
	addi $t1, $zero, 4
	preview_loop:
		beq $t0, $t1, preview_end
		sll $t2, $t0, 2		#offset
		add $t3, $t9, $t2	#get index of array
		lw $t4, 0($t3)		#get element at index
		add $t5, $t4, $s4	#get square and fill in
		sw $s5, 0($t5)
		addi $t0, $t0, 1	#increment i
		j preview_loop
	preview_end:
		jr $ra
start_loop:	#repeat loop until space key is pressed
	li $a0, 10
	li $v0, 32
	syscall
	lw $t0, ADDR_KBRD
	lw $t8, 0($t0)
        beq $t8, 1, listen_for_space
	b start_loop
listen_for_space:
	lw $a0, 4($t0)
	beq $a0, 0x20, start
	
get_tetromino:		#gets a random tetromino and stores it as a preview tetromino
	li $a1, 7
	li $v0, 42
	syscall
	beq $a0, 0, T
	beq $a0, 1, L
	beq $a0, 2, S
	beq $a0, 3, Z
	beq $a0, 4, O
	beq $a0, 5, I
	beq $a0, 6, J
	T:
		li $s5, 0xe00a97	#COLOR
		la $s6, T_0
		jr $ra
	L:
		li $s5, 0xff7b06
		la $s6, L_0
		jr $ra
	S:
		li $s5, 0x00ff00
		la $s6, S_0
		jr $ra
	Z:
		li $s5, 0xff0000
		la $s6, Z_0
		jr $ra
	O:
		li $s5, 0xffff00
		la $s6, O_0
		jr $ra
	I:
		li $s5, 0x00ffff
		la $s6, I_0
		jr $ra
	J:
		li $s5, 0x0000ff
		la $s6, J_0
		jr $ra
draw:
	move $t9, $a2		#get address of tetromino
	add $t0, $zero, $zero	#initailize loop variables
	addi $t1, $zero, 4
	l:
		beq $t0, $t1, f_end
		sll $t2, $t0, 2	#offset
		add $t3, $t9, $t2
		lw $t4, 0($t3)
		add $t5, $t4, $a0	#get square
		sw $a1, 0($t5)		#fill square
		addi $t0, $t0, 1	#increment i
		j l
	f_end:
		jr $ra

delete:		#draws a black tetromino
	move $t9, $a2
	add $t0, $zero, $zero
	addi $t1, $zero, 4
	del_loop:
		beq $t0, $t1, del_end
		sll $t2, $t0, 2
		add $t3, $t9, $t2
		lw $t4, 0($t3)
		add $t5, $t4, $a0
		li $t6, 0x000000	#paint square color black
		sw $t6, 0($t5)
		addi $t0, $t0, 1	#increment i
		j del_loop
	del_end:
		jr $ra

game_loop:
	li $a0, 5	#sleep
	li $v0, 32
	syscall
	move $a0, $s0	#move location, address, color of tetromino to drawing parameters
	move $a2, $s2
	move $a1, $s1
	jal delete	#colors tetromino black
	
	addi $s3, $s3, 1	#after a certain number of game loops, move the tetromino down one block
	add $t0, $zero, $s7
	beq $s3, $t0, move_down
	jal DRAW_BOARD
	
	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
        lw $t8, 0($t0)                  # Load first word from keyboard
        beq $t8, 1, keyboard_input      # If first word 1, key is pressed
        jal draw		#draw tetromino
        b game_loop

keyboard_input:
        lw $a0, 4($t0)
        beq $a0, 0x71, quit
	beq $a0, 0x61, move_left
	beq $a0, 0x64, move_right
	beq $a0, 0x73, move_down
	beq $a0, 0x77, rotate
	beq $a0, 0x70, pause
	j game_loop
quit:
	li $v0, 10                      # Quit
	syscall
pause:		#press p to pause game at any time
	jal draw_p
	j pause_loop
	pause_loop:
		lw $t0, ADDR_KBRD
        	lw $t8, 0($t0)
        	beq $t8, 1, check_for_p
		j pause_loop
check_for_p:
	lw $a0, 4($t0)
        beq $a0, 0x70, unpause
        j pause_loop
unpause:		#when paused, press p again to unpause
	jal clear_p
	j game_loop
move_right:		#move tetromino right one block
	addi $s0, $s0, 4
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal check_right
	j game_loop
move_left:		#move tetromino left one block
	addi $s0, $s0, -4
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal check_left
	j game_loop
rotate:			#rotate tetromino clockwise
	move $t9, $s2
	addi $t9, $t9, 16
	lw $t8, 0($t9)
	move $s2, $t8
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal check_rotate
	j game_loop
move_down:		#move tetromino down one block
	li $s3, 0
	addi $s0, $s0, 128
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	j check_bottom
	j game_loop
check_rotate:		#if rotation would cause tetromino to move into an illegal location, undo the rotation
	move $t9, $a2	#get address of tetromino
	add $t0, $zero, $zero	#initailize loop variables
	addi $t1, $zero, 4
	crt_loop:
		beq $t0, $t1, crt_done
		sll $t2, $t0, 2	#offset
		add $t3, $t9, $t2
		lw $t4, 0($t3)
		add $t5, $t4, $a0
		lw $t7, 0($t5)	#checks if color is border color or color of another tetromino
		li $t6, 0x242424
		beq $t7, $t6, reverse_rotate
		li $t6, 0x00ffff
		beq $t7, $t6, reverse_rotate
		li $t6, 0xe00a97
		beq $t7, $t6, reverse_rotate
		li $t6, 0xff7b06
		beq $t7, $t6, reverse_rotate
		li $t6, 0x00ff00
		beq $t7, $t6, reverse_rotate
		li $t6, 0xff0000
		beq $t7, $t6, reverse_rotate
		li $t6, 0x0000ff
		beq $t7, $t6, reverse_rotate
		li $t6, 0xffff00
		beq $t7, $t6, reverse_rotate
		addi $t0, $t0, 1	#increment i
		j crt_loop
	crt_done:
		jr $ra
	reverse_rotate:		#rotate 3 times to undo rotation
		move $t9, $s2
		addi $t9, $t9, 16
		lw $t8, 0($t9)
		addi $t8, $t8, 16
		lw $t9, 0($t8)
		addi $t9, $t9, 16
		lw $t8, 0($t9)
		move $s2, $t8
		jr $ra
		
check_bottom:
	move $t9, $a2	#get address of tetromino
	add $t0, $zero, $zero	#initailize loop variables
	addi $t1, $zero, 4
	cb_loop:
		beq $t0, $t1, cb_done
		sll $t2, $t0, 2	#offset
		add $t3, $t9, $t2
		lw $t4, 0($t3)
		add $t5, $t4, $a0
		lw $t7, 0($t5)	#checks if tetromino is color of border or color of another tetromino
		li $t6, 0x242424
		beq $t7, $t6, move_up_one
		li $t6, 0x00ffff
		beq $t7, $t6, move_up_one
		li $t6, 0xe00a97
		beq $t7, $t6, move_up_one
		li $t6, 0xff7b06
		beq $t7, $t6, move_up_one
		li $t6, 0x00ff00
		beq $t7, $t6, move_up_one
		li $t6, 0xff0000
		beq $t7, $t6, move_up_one
		li $t6, 0x0000ff
		beq $t7, $t6, move_up_one
		li $t6, 0xffff00
		beq $t7, $t6, move_up_one
		#increment i
		addi $t0, $t0, 1
		j cb_loop
	cb_done:
		j game_loop
	move_up_one:	#moves tetromino up one block
		addi $s0, $s0, -128
		move $a0, $s0
		jal draw
		j check_line
		
check_right:
	move $t9, $a2	#get address of tetromino
	add $t0, $zero, $zero	#initailize loop variables
	addi $t1, $zero, 4
	cr_loop:
		beq $t0, $t1, cr_done
		sll $t2, $t0, 2	#offset
		add $t3, $t9, $t2
		lw $t4, 0($t3)
		add $t5, $t4, $a0
		li $t6, 0x242424	#check if tetromino is border color or color of another tetromino
		lw $t7, 0($t5)
		beq $t7, $t6, move_left_one
		li $t6, 0x00ffff
		beq $t7, $t6, move_left_one
		li $t6, 0xe00a97
		beq $t7, $t6, move_left_one
		li $t6, 0xff7b06
		beq $t7, $t6, move_left_one
		li $t6, 0x00ff00
		beq $t7, $t6, move_left_one
		li $t6, 0xff0000
		beq $t7, $t6, move_left_one
		li $t6, 0x0000ff
		beq $t7, $t6, move_left_one
		li $t6, 0xffff00
		beq $t7, $t6, move_left_one
		addi $t0, $t0, 1	#increment i
		j cr_loop
	cr_done:
		jr $ra
	move_left_one:
		addi $s0, $s0, -4
		jr $ra
check_left:
	move $t9, $a2	#get address of tetromino
	add $t0, $zero, $zero	#initailize loop variables
	addi $t1, $zero, 4
	cl_loop:
		beq $t0, $t1, cl_done
		sll $t2, $t0, 2		#offset
		add $t3, $t9, $t2
		lw $t4, 0($t3)
		add $t5, $t4, $a0
		li $t6, 0x242424
		lw $t7, 0($t5)
		beq $t7, $t6, move_right_one	#check if tetromino is border color or color of another tetromino
		li $t6, 0x00ffff
		beq $t7, $t6, move_right_one
		li $t6, 0xe00a97
		beq $t7, $t6, move_right_one
		li $t6, 0xff7b06
		beq $t7, $t6, move_right_one
		li $t6, 0x00ff00
		beq $t7, $t6, move_right_one
		li $t6, 0xff0000
		beq $t7, $t6, move_right_one
		li $t6, 0x0000ff
		beq $t7, $t6, move_right_one
		li $t6, 0xffff00
		beq $t7, $t6, move_right_one
		addi $t0, $t0, 1	#increment i
		j cl_loop
	cl_done:
		jr $ra
	move_right_one:
		addi $s0, $s0, 4
		jr $ra

generate_new_tetromino:		#retrieves a new tetromino from preview and then generates a new tetromino in preview
	move $s1, $s5
	move $s2, $s6
	jal get_tetromino
	jal draw_preview
	lw $t0, ADDR_DSPL
	addi $t0, $t0, 832
	move $s0, $t0
	j check_game_over
check_game_over:		#if starting location of tetromino is occupied, then game over
	lw $t9, 0($s0)
	bne $t9, 0x545454, game_over
	j game_loop
	game_over:
		jal clear_board
		jal draw_game_over
		j game_over_loop
game_over_loop:		#waits for r to restart, can also press q to quit
	lw $t0, ADDR_KBRD
        lw $t8, 0($t0)
        beq $t8, 1, check_for_r
        j game_over_loop
check_for_r:
	lw $a0, 4($t0)
        beq $a0, 0x72, restart
        beq $a0, 0x71, quit
        j game_over_loop
restart:		#clears board and jumps back to top of main to restart
	jal clear_board
	j main
check_line:
	lw $t0, ADDR_DSPL
	addi $t0, $t0, 684	#start at 684
	addi $t1, $t0, 2816	#stop at 2688
	add $t2, $zero, $zero	#counter
	checkline_loop:
		beq $t0, $t1, generate_new_tetromino	#if reached bottom, generate new tetromino
		lw $t3, 0($t0)	#store value of square in $t3
		j check_color	#checks color
		return_color_check:
		addi $t0, $t0, 4	#increment
		addi $t2, $t2, 4
		beq $t2, 40, clear	#if counter reaches the end, it means there is a completed row
		j checkline_loop
	jump_next_line:	#jumps down one line and continues loop
		sub $t0, $t0, $t2
		addi $t0, $t0, 128
		add $t2, $zero, $zero
		j checkline_loop
	clear:
		move $t1, $t0
		sub $t0, $t0, 40	#go back to beginning of row
		clear_loop:	#sets entire row black
			beq $t0, $t1, shift
			li $t2, 0x000000	#load black
			sw $t2, 0($t0)	#set square to black
			addi $t0, $t0, 4	#increment
			j clear_loop
	shift:		#loops through display shifting every colored square down
		jal update_speed	#evertime a line is cleared update the speed
		lw $t0, ADDR_DSPL
		addi $t0, $t0, 684	#start at 684
		shift_loop:
			#upon shifting, check for a completed line again
			#keep value of $t1 from clear
			beq $t0, $t1, check_line
			#store value of square in t2
			lw $t2, 0($t1)
			#if square is colored, shift square down one
			beq $t2, 0xff7b06, shift_square
			beq $t2, 0xe00a97, shift_square
			beq $t2, 0x00ff00, shift_square
			beq $t2, 0xff0000, shift_square
			beq $t2, 0xffff00, shift_square
			beq $t2, 0x00ffff, shift_square
			beq $t2, 0x0000ff, shift_square
			#increment
			addi $t1, $t1, -4
			j shift_loop
		shift_square:
			#store black in $t4
			li $t4, 0x000000
			#set square black
			sw $t4, 0($t1)
			#set $t5 to be square below $t0
			addi $t5, $t1, 128
			#colors new square
			sw $t2, 0($t5)
			#increment and jump back to shift_loop
			addi $t1, $t1, -4
			j shift_loop
	check_color:	#checks if square is color of a tetromino
		bne $t3, 0xff7b06, second
		j return_color_check
		second:
			bne $t3, 0xe00a97, third
			j return_color_check
		third:
			bne $t3, 0x00ff00, fourth
			j return_color_check
		fourth:
			bne $t3, 0xff0000, fifth
			j return_color_check
		fifth:
			bne $t3, 0xffff00, sixth
			j return_color_check
		sixth:
			bne $t3, 0x00ffff, seventh
			j return_color_check
		seventh:
			bne $t3, 0x0000ff, jump_next_line
			j return_color_check
	update_speed:	#updates speed, but if speed is already at max speed (10) then do nothing
		beq $s7, 10, no_change
		subi $s7, $s7, 5
		no_change:
			jr $ra
							
clear_board:		#clears display
	lw $t0, ADDR_DSPL
	addi $t1, $t0, 4092
	li $t2, 0x000000
	clear_board_loop:
		beq $t0, $t1, board_cleared
		sw $t2, 0($t0)
		addi $t0, $t0, 4
		j clear_board_loop
	board_cleared:
		jr $ra
	
draw_top_bottom_borders:
	li $t7, 0x242424
        lw $t0, ADDR_DSPL
        #draw top border
        sw $t7, 552($t0)
	sw $t7, 556($t0)
        sw $t7, 560($t0)
	sw $t7, 564($t0)
	sw $t7, 568($t0)
	sw $t7, 572($t0)
	sw $t7, 576($t0)
	sw $t7, 580($t0)
	sw $t7, 584($t0)
	sw $t7, 588($t0)
	sw $t7, 592($t0)
	sw $t7, 596($t0)
	#draw bottom border
	sw $t7, 3496($t0)
	sw $t7, 3500($t0)
        sw $t7, 3504($t0)
	sw $t7, 3508($t0)
	sw $t7, 3512($t0)
	sw $t7, 3516($t0)
	sw $t7, 3520($t0)
	sw $t7, 3524($t0)
	sw $t7, 3528($t0)
	sw $t7, 3532($t0)
	sw $t7, 3536($t0)
	sw $t7, 3540($t0)
	jr $ra
DRAW_BOARD:
        li $t8, 0xd3d3d3	#two colors of board grid
        li $t9, 0x545454
        lw $t0, ADDR_DSPL
        
        addi $t0, $t0, 684
	addi $t1, $t0, 2816
	#counter variable in $t2
	add $t2, $zero, $zero
	db_loop:
	beq $t0, $t1, done
	#checks if square is valid and then draws board
	j check_1
	db_back:
	addi $t2, $t2, 1
	beq $t2, 5, new_line
	addi $t0, $t0, 8
	j db_loop
	new_line:
		add $t2, $zero, $zero
		addi $t0, $t0, 224
		j db_loop
	check_1:
		lw $t3, 0($t0)
        	beq $t3, 0x000000, draw_grid_1
        	j check_2
        draw_grid_1:
        	sw $t9, 0($t0)
        	j check_2
        check_2:
		lw $t3, 4($t0)
        	beq $t3, 0x000000, draw_grid_2
        	j check_3
        draw_grid_2:
        	sw $t8, 4($t0)
        	j check_3
        check_3:
		lw $t3, 132($t0)
        	beq $t3, 0x000000, draw_grid_3
        	j check_4
        draw_grid_3:
        	sw $t9, 132($t0)
        	j check_4
        check_4:
		lw $t3, 128($t0)
        	beq $t3, 0x000000, draw_grid_4
        	j db_back
        draw_grid_4:
        	sw $t8, 128($t0)
        	j db_back
	
	done:
		jr $ra
draw_side_borders:	#draws side borders
	addi $t0, $t0, 680
	addi $t1, $t0, 2816
	side_loop:
	beq $t0, $t1, sides_done
	sw $t7, 0($t0)
	sw $t7, 44($t0)
	addi $t0, $t0, 128
	j side_loop
	sides_done:
		jr $ra
draw_game_over:
	lw $t0, ADDR_DSPL
	li $t1, 0xffffff
	addi $t0, $t0, 1052
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	
	sw $t1, 128($t0)
	sw $t1, 148($t0)
	sw $t1, 156($t0)
	sw $t1, 168($t0)
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	sw $t1, 188($t0)
	
	sw $t1, 256($t0)
	sw $t1, 264($t0)
	sw $t1, 276($t0)
	sw $t1, 280($t0)
	sw $t1, 284($t0)
	sw $t1, 296($t0)
	sw $t1, 300($t0)
	sw $t1, 304($t0)
	sw $t1, 316($t0)
	sw $t1, 320($t0)
	sw $t1, 324($t0)
	
	sw $t1, 384($t0)
	sw $t1, 392($t0)
	sw $t1, 404($t0)
	sw $t1, 412($t0)
	sw $t1, 424($t0)
	sw $t1, 432($t0)
	sw $t1, 444($t0)
	
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 532($t0)
	sw $t1, 540($t0)
	sw $t1, 552($t0)
	sw $t1, 560($t0)
	sw $t1, 572($t0)
	sw $t1, 576($t0)
	sw $t1, 580($t0)
	
	sw $t1, 896($t0)
	sw $t1, 900($t0)
	sw $t1, 904($t0)
	sw $t1, 916($t0)
	sw $t1, 924($t0)
	sw $t1, 936($t0)
	sw $t1, 940($t0)
	sw $t1, 944($t0)
	sw $t1, 956($t0)
	sw $t1, 960($t0)
	sw $t1, 964($t0)
	
	sw $t1, 1024($t0)
	sw $t1, 1032($t0)
	sw $t1, 1044($t0)
	sw $t1, 1052($t0)
	sw $t1, 1064($t0)
	sw $t1, 1084($t0)
	sw $t1, 1092($t0)
	
	sw $t1, 1152($t0)
	sw $t1, 1160($t0)
	sw $t1, 1172($t0)
	sw $t1, 1180($t0)
	sw $t1, 1192($t0)
	sw $t1, 1196($t0)
	sw $t1, 1200($t0)
	sw $t1, 1212($t0)
	sw $t1, 1216($t0)
	
	sw $t1, 1280($t0)
	sw $t1, 1288($t0)
	sw $t1, 1300($t0)
	sw $t1, 1308($t0)
	sw $t1, 1320($t0)
	sw $t1, 1340($t0)
	sw $t1, 1348($t0)
	
	sw $t1, 1408($t0)
	sw $t1, 1412($t0)
	sw $t1, 1416($t0)
	sw $t1, 1432($t0)
	sw $t1, 1448($t0)
	sw $t1, 1452($t0)
	sw $t1, 1456($t0)
	sw $t1, 1468($t0)
	sw $t1, 1476($t0)
	
	jr $ra
draw_p:	#draws a red dot in top left signifying game is paused
	lw $t0, ADDR_DSPL
	li $t1, 0xff0000
	sw $t1, 0($t0)
	jr $ra
clear_p:	#removes red dot when unpaused
	lw $t0, ADDR_DSPL
	li $t1, 0x000000
	sw $t1, 0($t0)
	jr $ra
draw_start:
	lw $t0, ADDR_DSPL
	li $t1, 0xffffff
	addi $t0, $t0, 656
	#draw "SPACE TO START"

	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)

	
	sw $t1, 128($t0)
	sw $t1, 148($t0)
	sw $t1, 156($t0)
	sw $t1, 168($t0)
	sw $t1, 176($t0)
	sw $t1, 188($t0)
	sw $t1, 208($t0)
	
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 276($t0)
	sw $t1, 280($t0)
	sw $t1, 284($t0)
	sw $t1, 296($t0)
	sw $t1, 300($t0)
	sw $t1, 304($t0)
	sw $t1, 316($t0)
	sw $t1, 336($t0)
	sw $t1, 340($t0)
	sw $t1, 344($t0)
	
	sw $t1, 392($t0)
	sw $t1, 404($t0)
	sw $t1, 424($t0)
	sw $t1, 432($t0)
	sw $t1, 444($t0)
	sw $t1, 464($t0)
	
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 532($t0)
	sw $t1, 552($t0)
	sw $t1, 560($t0)
	sw $t1, 572($t0)
	sw $t1, 576($t0)
	sw $t1, 580($t0)
	sw $t1, 592($t0)
	sw $t1, 596($t0)
	sw $t1, 600($t0)
	
	sw $t1, 1024($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1044($t0)	
	sw $t1, 1048($t0)
	sw $t1, 1052($t0)
	
	sw $t1, 1156($t0)	
	sw $t1, 1172($t0)
	sw $t1, 1180($t0)
	
	sw $t1, 1284($t0)	
	sw $t1, 1300($t0)
	sw $t1, 1308($t0)
	
	sw $t1, 1412($t0)	
	sw $t1, 1428($t0)
	sw $t1, 1436($t0)
	
	sw $t1, 1540($t0)	
	sw $t1, 1556($t0)
	sw $t1, 1560($t0)
	sw $t1, 1564($t0)
	
	sw $t1, 1920($t0)	
	sw $t1, 1924($t0)
	sw $t1, 1928($t0)
	sw $t1, 1940($t0)
	sw $t1, 1944($t0)	
	sw $t1, 1948($t0)
	sw $t1, 1960($t0)
	sw $t1, 1964($t0)
	sw $t1, 1968($t0)	
	sw $t1, 1980($t0)
	sw $t1, 1984($t0)
	sw $t1, 1988($t0)
	sw $t1, 2000($t0)	
	sw $t1, 2004($t0)
	sw $t1, 2008($t0)
	
	sw $t1, 2048($t0)	
	sw $t1, 2072($t0)
	sw $t1, 2088($t0)
	sw $t1, 2096($t0)
	sw $t1, 2108($t0)	
	sw $t1, 2116($t0)
	sw $t1, 2132($t0)
	
	sw $t1, 2176($t0)	
	sw $t1, 2180($t0)
	sw $t1, 2184($t0)
	sw $t1, 2200($t0)
	sw $t1, 2216($t0)	
	sw $t1, 2220($t0)
	sw $t1, 2224($t0)
	sw $t1, 2236($t0)	
	sw $t1, 2240($t0)
	sw $t1, 2260($t0)
	
	sw $t1, 2312($t0)	
	sw $t1, 2328($t0)
	sw $t1, 2344($t0)
	sw $t1, 2352($t0)
	sw $t1, 2364($t0)	
	sw $t1, 2372($t0)
	sw $t1, 2388($t0)
	
	sw $t1, 2432($t0)	
	sw $t1, 2436($t0)
	sw $t1, 2440($t0)
	sw $t1, 2456($t0)
	sw $t1, 2472($t0)	
	sw $t1, 2480($t0)
	sw $t1, 2492($t0)
	sw $t1, 2500($t0)	
	sw $t1, 2516($t0)

	jr $ra
