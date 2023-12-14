	.data

px:	.space 4
py:	.space 4

.text
	.globl main
main:
	# $s0: Mapa
	# $s1: Auxiliar
	# $s2: Auxiliar
	# $s3: Player
	# $s4: Bit pronto
	# $s5: Tecla apertada
	# $s6: Flag se o turno do player acabou
	# $s7: Flag de ataque

	jal read_map_from_file	# Le o mapa do arquivo map.txt na pasta raiz do Mars
	move $s0, $v0
	
	la $s1, indice
	la $s2, aux
	
	move $a0, $s0
	jal get_player_pos
	sw $v0, px
	sw $v1, py
	
	move $a0, $s0
	lw $a1, px
	lw $a2, py
	jal get_map_obj
	move $s3, $v0
	
	li $s6, 0	# Flag se o turno do player acabou
	li $s7, 0	# Flag de ataque
	
	move $a0, $s0
	jal draw_map	# Atualiza o bitmap display
	
player_turn:	# Inicio do turno do player
	beq $s6, $zero, wait_input	# Verifica se o turno do player ja acabou
	li $s7, 0
	j enemy_turn
wait_input:
	lw $s4, 0xffff0000
	beq $s4, 0, wait_input	# Pooling de entrada
input_received:
	sw $zero, 0xffff0000	# Limpa o ready bit
	lw $s5, 0xffff0004
	sw $zero, 0xffff0004	# Limpa o input
	sge $t0, $s5, 48
	sle $t1, $s5, 57
	and $t0, $t0, $t1
	bne $t0, $zero, direction	# Verifica se e direcao
	
	beq $s5, 65, attack
	beq $s5, 97, attack
	
	beq $s5, 67, cancel
	beq $s5, 99, cancel
	
	j wait_input	# Comando nao reconhecido

attack:
	li $s7, 1
	j player_turn

cancel:
	li $s7, 0
	j player_turn

direction:
	beq $s5, 53, enemy_turn	# Pular turno
	move $a0, $s0
	lw $a1, px
	lw $a2, py
	addi $a3, $s5, -48
	bne $s7, $zero, attack_direction	# Ataque pressionado
move_direction:
	jal player_move
	beq $v0, $zero, player_turn	# Movimento falhou
	
	lw $a1, px
	lw $a2, py
	addi $a3, $s5, -48
	jal new_index_direction	# Atualiza posicao do player
	sw $v0, px
	sw $v1, py
	
	li $s6, 1	# Termina o turno
	j player_turn
	
attack_direction:
	jal player_attack
	beq $v0, $zero, player_turn	# Ataque falhou
	
	li $s6, 1	# Termina o turno
	j player_turn
	
enemy_turn:
end_turn:
	move $a0, $s0
	jal draw_map	# Atualiza o bitmap display
	
	li $s6, 0
	j player_turn

exit:
	li $v0, 10	# Finaliza o programa
	syscall
	
