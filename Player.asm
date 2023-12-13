#################################################################
# Código de controle do jogador 
# Cria o jogador no mapa e executa suas funções:
#  - Andar
#  - Atacar
#  - Defender
#  - Fugir
#################################################################
	.data
wmove:	.asciiz "You cannot move to this direction!\n"
wattk:	.asciiz "You cannot attack this direction!\n"
	.globl Player	
Player: .space 28

	.text

main:
	
	li $v0, 10
	syscall

player_move:
	#Mapa $a0, tenta mover player($a1, $a2) para a direcao $a3
	jal move_character
	
	beq $v0, 0, player_wrong_move
	
	li $v0, 1	#flag conseguiu mover
	
	jr $ra
	
	player_wrong_move:
	li $v0, 4
	la $a0, wmove		#talvez mover esta mesagem de erro pra main
	syscall
	
	li $v0, 0	#flag nao conseguiu mover
	
	jr $ra			#volta para receber o indice denovo de açao na main

player_attack:
	#Mapa $a0, indice player($a1, $a2) e direção ataque $a3
	
	sw $a1, ($s2)
	sw $a2, 4($s2)
	
	jal new_index_direction
	sw $v0, 8($s2)
	sw $v1, 12($s2)
	
	lw $a0, $s0
	move $a1, $v0
   move $a2, $v1
   jal get_map_obj
   
   li $t0, 3
   lw $t1, ($v0)
   beq $t1, $t0, playerCanAttack
	
	li $v0, 4
	la $a0, wattk		#talvez mover esta mesagem de erro pra main
	syscall
	
	li $v0, 0	#nao conseguiu atacar
	jr $ra

	playerCanAttack:
	#indice player(atacante)
	lw $t0, ($s2)
	sw $t0, ($s1)
	lw $t0, 4($s2)
	sw $t0, 4($s1)
	
	#indice inimigo(defensor)
	lw $t0, 8($s2)
	sw $t0, 8($s1)
	lw $t0, 12($s2)
	sw $t0, 12($s1)
	
	move $a0, $s0
	
	jal atack_character
	
	li $v0, 1	#conseguiu atacar
	jr $ra

#player_defense:

#player_dash:
	
	
