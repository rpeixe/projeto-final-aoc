	.data

turno: .word 0

.text
	.globl main
main:
	jal read_map_from_file
	move $s0, $v0
	
	move $a0, $s0
	li $a1, 6
	li $a2, 6
	jal get_map_obj
	move $a0, $v0
	jal print_object
	

	li $v0, 10	# Finaliza o programa
	syscall
	

#turn_increment:
	#Incrementa o turno do jogo após uma ação do jogador ou inimigo

	#la $t0,turno
	#addi $t0,$t0,1
	#sw $t0,turno

	#jr $ra
