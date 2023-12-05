	.data

turno: .word 0

.text
	.globl main
main:
	jal read_map_from_file
	

turn_increment:
	#Incrementa o turno do jogo após uma ação do jogador ou inimigo

	la $t0,turno
	addi $t0,$t0,1
	sw $t0,turno

	jr $ra
