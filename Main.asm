	.data

turno: .word 0

.text
	.globl main
main:
	# $s0: Mapa
	# $s1: Player
	# $s2: Bit pronto
	# $s3: Tecla apertada

	jal read_map_from_file	# Le o mapa do arquivo map.txt na pasta raiz do Mars
	move $s0, $v0
	
	move $a0, $s0
	jal get_player
	move $s1, $v0
	
	li $s2, 0xffff0000	# Ready bit
	li $s3, 0xffff0004	# Tecla apertada
	
player_turn:	# Inicio do turno do player
	move $a0, $s0
	jal draw_map	# Atualiza o bitmap display
wait_input:
	lw $t0, ($s2)
	beq $t0, 0, wait_input	# Pooling de entrada
input_received:
	sw $zero, ($s2)
	move $a0, $s1
	jal print_object
	j player_turn

	li $v0, 10	# Finaliza o programa
	syscall
	
