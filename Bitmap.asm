# Assumindo 512x512, 4 ppu, 8x8 tiles, 16x16 map
	.data
# Cores
white:	.word 0xffffff
black:	.word 0x000000
gray:	.word 0x696969
dgray:	.word 0x242424
lgray:	.word 0xdbdbdb
red:	.word 0x9b2020
green:	.word 0x3a8a29
yellow:	.word 0xc5c220
silver:	.word 0x9f9f9f
beige:	.word 0xefcb61
blue:	.word 0x344bb2
lblue:	.word 0x556091
brown:	.word 0x915b3a
b_add:	.word 0x10000000

	.text
main:
	jal read_map_from_file
	move $s0, $v0
	
	move $a0, $s0
	jal draw_map
	
	li $v0, 10	# Finaliza o programa
	syscall
	
	.globl clear_screen
clear_screen:
	# Limpa a tela inteira
	lw $t0, b_add
	li $t1, 0
	li $t2, 16384
	lw $t3, black
clear_screen_loop:
	beq $t1, $t2, clear_screen_done
	sw $t3, ($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, 1
	j clear_screen_loop
clear_screen_done:
	jr $ra
	
	.globl get_tile_addr
get_tile_addr:
	# Recebe o mapa em $a0, a posicao em ($a1, $a2) e retorna em $v0 o endereco do primeiro pixel
	lw $t0, ($a0)
	lw $t1, 4($a0)
	lw $t2, 8($a0)
	
	# Deteccao de erro
	bltz $a1, err_oob
	bltz $a2, err_oob
	bge $a1, $t1, err_oob
	bge $a2, $t2, err_oob
	
	# addr = (pos y * largura + pos x) * 64 + base_addr
	lw $t4, b_add
	li $t5, 128
	mul $t3, $t5, $a2
	add $t3, $t3, $a1
	sll $t3, $t3, 5
	add $t3, $t3, $t4
	
	move $v0, $t3
	jr $ra
	
	.globl draw_object
draw_object:
	# Recebe o primeiro endereco em $a0 e desenha o objeto com o tipo em $a1
	beq $a1, 0, draw_floor
	beq $a1, 1, draw_wall
	beq $a1, 2, draw_player
	beq $a1, 3, draw_enemy
	j err_ut
	
	.globl draw_map
draw_map:
	# Recebe o mapa em $a0, limpa a tela e desenha o mapa na tela
	
	# Salva os $s e o $ra
	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $sp, $sp, -4
	sw $s0, ($sp)
	addi $sp, $sp, -4
	sw $s1, ($sp)
	addi $sp, $sp, -4
	sw $s2, ($sp)
	addi $sp, $sp, -4
	sw $s3, ($sp)
	addi $sp, $sp, -4
	sw $s4, ($sp)
	addi $sp, $sp, -4
	sw $s5, ($sp)
	addi $sp, $sp, -4
	sw $s6, ($sp)
	
	move $s0, $a0
	lw $s1, ($a0)
	lw $s2, 4($a0)
	lw $s3, 8($a0)
	
	li $s4, 0
	li $s5, 0
	
	jal clear_screen
draw_map_loop:
	beq $s4, $s2, draw_map_next_line
	beq $s5, $s3, draw_map_loop_end
	
	move $a0, $s0
	move $a1, $s4
	move $a2, $s5
	jal get_map_obj
	lw $s6, ($v0)
	
	move $a0, $s0
	move $a1, $s4
	move $a2, $s5
	jal get_tile_addr
	
	move $a0, $v0
	move $a1, $s6
	jal draw_object
	
	addi $s4, $s4, 1
	j draw_map_loop
draw_map_next_line:
	li $s4, 0
	addi $s5, $s5, 1
	j draw_map_loop
draw_map_loop_end:
	# Restaura os $s e o $ra
	lw $s6, ($sp)
	addi $sp, $sp, 4
	lw $s5, ($sp)
	addi $sp, $sp, 4
	lw $s4, ($sp)
	addi $sp, $sp, 4
	lw $s3, ($sp)
	addi $sp, $sp, 4
	lw $s2, ($sp)
	addi $sp, $sp, 4
	lw $s1, ($sp)
	addi $sp, $sp, 4
	lw $s0, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	.globl clear_tile
clear_tile:
	# Recebe o primeiro endereco em $a0
	lw $t2, black
	
	# Linha 1
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 2
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 3
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 5
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 6
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 7
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 8
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	
	jr $ra
		
	.globl draw_floor
draw_floor:
	# Recebe o primeiro endereco em $a0
	lw $t2, gray
	lw $t3, dgray
	
	# Linha 1
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 2
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 3
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 5
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 6
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 7
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 8
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	
	jr $ra
	
	.globl draw_wall
draw_wall:
	# Recebe o primeiro endereco em $a0
	lw $t2, dgray
	lw $t3, gray
	
	# Linha 1
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 2
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 3
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 5
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 6
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 7
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 8
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	
	jr $ra
	
	.globl draw_player
draw_player:
	# Recebe o primeiro endereco em $a0
	lw $t0, lblue
	lw $t1, silver
	lw $t2, beige
	lw $t3, black
	lw $t4, yellow
	lw $t5, brown
	
	# Linha 1
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t1, ($a0)
	addi $a0, $a0, 484
	# Linha 2
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t1, ($a0)
	addi $a0, $a0, 484
	# Linha 3
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t1, ($a0)
	addi $a0, $a0, 484
	# Linha 4
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t1, ($a0)
	addi $a0, $a0, 484
	# Linha 5
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 6
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t5, ($a0)
	addi $a0, $a0, 4
	sw $t5, ($a0)
	addi $a0, $a0, 4
	sw $t4, ($a0)
	addi $a0, $a0, 4
	sw $t5, ($a0)
	addi $a0, $a0, 4
	sw $t5, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t4, ($a0)
	addi $a0, $a0, 484
	# Linha 7
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	addi $a0, $a0, 484
	# Linha 8
	addi $a0, $a0, 4
	sw $t5, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t5, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	
	jr $ra
	
	.globl draw_enemy
draw_enemy:
	# Recebe o primeiro endereco em $a0
	lw $t0, green
	lw $t1, yellow
	lw $t2 silver
	lw $t3, gray
	lw $t4, brown
	
	# Linha 1
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 2
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t2, ($a0)
	addi $a0, $a0, 484
	# Linha 3
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t1, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t1, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 484
	# Linha 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 484
	# Linha 5
	sw $t3, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 484
	# Linha 6
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t4, ($a0)
	addi $a0, $a0, 4
	sw $t4, ($a0)
	addi $a0, $a0, 4
	sw $t4, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 484
	# Linha 7
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t3, ($a0)
	addi $a0, $a0, 484
	# Linha 8
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	addi $a0, $a0, 4
	sw $t0, ($a0)
	addi $a0, $a0, 4
	
	jr $ra
	
