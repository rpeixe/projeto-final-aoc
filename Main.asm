	.data

turno: .word 0

.text
	.globl main
main:
	# $s0: Mapa
	# $s1: Player
	# $s2: Player X
	# $s3: Player Y
	# $s4: Bit pronto
	# $s5: Tecla apertada

	jal read_map_from_file	# Le o mapa do arquivo map.txt na pasta raiz do Mars
	move $s0, $v0
	
	move $a0, $s0
	jal get_player_pos
	move $s2, $v0
	move $s3, $v1
	
	move $a0, $s0
	move $a1, $s2
	move $a2, $s3
	jal get_map_obj
	move $s1, $v0
	
	move $s1, $v0
	
	li $s4, 0xffff0000	# Ready bit
	li $s5, 0xffff0004	# Tecla apertada
	li $s6, 0	# Flag se o turno do player acabou
	
player_turn:	# Inicio do turno do player
	move $a0, $s0
	jal draw_map	# Atualiza o bitmap display
	li $s6, 0
wait_input:
	lw $t0, ($s4)
	beq $t0, 0, wait_input	# Pooling de entrada
input_received:
	sw $zero, ($s4)
	move $a0, $s1
	jal print_object
	j player_turn

	li $v0, 10	# Finaliza o programa
	syscall
	
