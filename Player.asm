#################################################################
# Código de controle do jogador 
# Cria o jogador no mapa e executa suas funções:
#  - Andar
#  - Atacar
#  - Defender
#  - Fugir
#################################################################
	.data
wmove:			.asciiz "Voce tenta se mover, mas um obstaculo impenetravel bloqueia seu caminho\n"
cmove:			.asciiz "Seu caminho esta livre! Você dá um passo à frente\n"
noneattk:		.asciiz "Voce tenta atacar uma mosca na caverna, errando e acertando nada\n"
wallattk:		.asciiz "*TUCK!*, voce acertou a parede\n"
plAttkdamage1:	.asciiz "Voce consegue atacar uma parte do monstro, causando "
plAttkdamage2:	.asciiz " de dano\n"
plAttkenem1:		.asciiz "Deixando o inimigo com "
plAttkenem2:		.asciiz " de vida\n"

	.globl Player	
Player: .space 28

	.text

main:
	
	li $v0, 10
	syscall

	.globl player_move
player_move:
	#Mapa $a0, tenta mover player($a1, $a2) para a direcao $a3
	jal move_character
	
	beq $v0, 0, player_wrong_move
	
	li $v0, 4
	la $a0, cmove	
	syscall
	
	li $v0, 1	#flag conseguiu mover
	
	jr $ra
	
	player_wrong_move:
	li $v0, 4
	la $a0, wmove
	syscall
	
	li $v0, 0	#flag nao conseguiu mover
	
	jr $ra			#volta para receber o indice denovo de açao na main

	.globl player_attack
player_attack:
	#Mapa $a0, indice player($a1, $a2) e direção ataque $a3
	
	sw $a1, ($s2)
	sw $a2, 4($s2)
	
	jal new_index_direction
	sw $v0, 8($s2)
	sw $v1, 12($s2)
	
	move $a0, $s0
	move $a1, $v0
   move $a2, $v1
   jal get_map_obj
   
   lw $t0, ($v0)

   li $t1, 1
   li $t3, 3
   beq $t0, 0, playerAttackNone
   beq $t0, $t1, playerAttackWall
   beq $t0, $t3, playerAttackEnemy
	
	playerAttackNone:
	li $v0, 4
	la $a0, noneattk		#talvez mover esta mesagem de erro pra main
	syscall
	
	li $v0, 0	#nao conseguiu atacar
	jr $ra
	
	playerAttackWall:
	li $v0, 4
	la $a0, wallattk		#talvez mover esta mesagem de erro pra main
	syscall
	
	li $v0, 0	#nao conseguiu atacar
	jr $ra

	playerAttackEnemy:
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
	
	li $v0, 4
	la $a0, plAttkdamage1
	syscall
	
	li $v0, 1
	move $a0, $v0
	syscall
	
	li $v0, 4
	la $a0, plAttkdamage2
	syscall
	
	li $v0, 4
	la $a0, plAttkenem1
	syscall
	
	li $v0, 1
	move $a0, $v1
	syscall
	
	li $v0, 4
	la $a0, plAttkenem2
	syscall
	
	li $v0, 1	#conseguiu atacar
	jr $ra

#player_defense:

#player_dash:
	
	
