	.data
#yArea:		.asciiz "Character in area\n"
#nArea:		.asciiz "No character in area\n"
enAttkdamage1:	.asciiz "O inimigo consegue arranhar uma parte do seu corpo, causando "
enAttkdamage2:	.asciiz " de dano\n"
enAttkenem1:		.asciiz "Deixando voce com "
enAttkenem2:		.asciiz " de vida\n"

	.align 2
	.globl indice
indice:	.space 100	#salvar na main dps($s1)
	.globl aux
aux:	.space 100		#salvar na main dps($s2)
	
	.text
main:
	#Teste enemy check area and move
	jal read_map_from_file
	move $s0, $v0
	
	la $s1, indice
	la $s2, aux
	
	#just for tests
	li $t0, 6
	sw $t0, ($s1)
	li $t0, 6
	sw $t0, 4($s1)
	li $t0, 6
	sw $t0, 8($s1)
	li $t0, 5
	sw $t0, 12($s1)
	
	jal create_enemy
	move $a0, $s0
	lw $a1, ($s1) 
	lw $a2, 4($s1) 
	move $a3, $v0
	jal set_map_obj
	
	jal create_player
	move $a0, $s0
	lw $a1, 8($s1) 
	lw $a2, 12($s1) 
	move $a3, $v0
	jal set_map_obj
	#just for tests
	
	
	##########
	move $a0, $s0
	li $a1, 2	#area inimigo
	jal enemy_check_area 

	beq $v0, 1, msgArea
	
	#player nao esta na area inimigo
	
	li $v0, 10
	syscall
	
	#player esta na area inimigo
	msgArea: 	#nao esta salvando movendo certo o objeto
	
	move $a0, $s0
	li $a1, 2		#area inimigo
	jal enemy_move	#envia mapa em $a0, area $a1 e indices em $s1
	
	move $a0, $s0
	beq $v0, 2, enemy_attack
	###########
	move $a0, $s0
	li $a1, 6
	li $a2, 5
	
	jal get_map_obj
	
	lw $t1, ($v0)
	li $v0, 1
	move $a0, $t1
	syscall
	############
	li $v0, 10	# Fim
	syscall

	.globl enemy_check_area
enemy_check_area:  
   #Recebe mapa $a0, $a1 area do inimgo, indice inimigo e indice player em $s1

   #indices largura inimigo e player
   lw $t0, ($s1)
   lw $t1, 8($s1)
   li $t5, 0
   li $t2, 2

   #Checa se player esta na largura da enemy_area
   sub $t0, $t0, $a1
   sub $t0, $t0, 1
   slt $t4, $t0, $t1

   lw $t0, ($s1)   #reseta o indice largura
   add $t0, $t0, $a1
   add $t0, $t0, 1
   slt $t5, $t1, $t0

   add $t5, $t5, $t4   #t5=2 se ambos sao validos
   bne $t2, $t5, notInArea

   #indices altura inimigo e player
   lw $t0, 4($s1)
   lw $t1, 12($s1)
   li $t5, 0

   #Checa se player esta na altura da enemy_area
   sub $t0, $t0, $a1
   sub $t0, $t0, 1
   slt $t4, $t0, $t1

   lw $t0, 4($s1)   #reseta o indice largura
   add $t0, $t0, $a1
   add $t0, $t0, 1
   slt $t5, $t1, $t0

   add $t5, $t5, $t4   #t5=2 se ambos sao validos
   bne $t2, $t5, notInArea

   li $v0, 1   #flag possui player na area

   jr $ra
	
	.globl move_character
move_character:  
   #Mapa $a0, tenta mover player ou inimigo ($a1, $a2) para a direcao $a3
	addi $sp, $sp, -4
	sw $ra, ($sp)

   sw $a1, ($s2) 
   sw $a2, 4($s2)  
    
	jal new_index_direction
	#beq $v0, 0, ExitMove_character
	
   #novo indice
   sw $v0, 8($s2)
   sw $v1, 12($s2)
   
   move $a1, $v0
   move $a2, $v1
   jal get_map_obj
    
   lw $t1, ($v0)
   beq $t1, 4, victory
   beq $t1, 0, canMove
    
   li $v0, 0     #flag impossivel de mover
    
   lw $ra, ($sp)
   addi $sp, $sp, 4
   
   jr $ra
    
canMove:
	move $t8, $v0
   #inidice original
   lw $a1, ($s2)
   lw $a2, 4($s2)
   jal get_map_obj
    
   #move o tipo para a nova posicao
   lw $a1, 8($s2)
   lw $a2, 12($s2)
   move $a3, $v0
   jal set_map_obj
    
   #atualiza a antiga posicao com chao
   move $a3, $v0
   
   lw $a1, ($s2)
   lw $a2, 4($s2)
   move $a3, $t8
   jal set_map_obj
	
ExitMove_character:
	 
   li $v0, 1   #flag conseguiu mover
    
	lw $ra, ($sp)
	addi $sp, $sp, 4
   jr $ra
  
   .globl new_index_direction
new_index_direction:
	#indice ($a1, $a2), dire�ao em $a3 e retorna o novo indice na dire�ao dada
	move $t1, $a1       #largura
   move $t2, $a2       #altura
	
	beq $a3, 1, leftDown
   beq $a3, 2, down
   beq $a3, 3, rightDown
   beq $a3, 4, left
   beq $a3, 5, stay
   beq $a3, 6, right
   beq $a3, 7, leftUp
   beq $a3, 8, up
   beq $a3, 9, rightUp
   j err_ind
    
leftDown:	#sw $a1, ($s1)
   sub $t1, $a1, 1
   add $t2, $a2, 1
   j ExitMove_new_index
        
down:
   move $t1, $a1
   add $t2, $a2, 1
   j ExitMove_new_index
    
rightDown:
   add $t1, $a1, 1
   add $t2, $a2, 1
   j ExitMove_new_index
    
left:
   sub $t1, $a1, 1
   move $t2, $a2
   j ExitMove_new_index
        
stay:
   li $v0, 1   #flag conseguiu mover
    
   jr $ra
        
right:
   add $t1, $a1, 1
   move $t2, $a2
   j ExitMove_new_index
    
leftUp:
   sub $t1, $a1, 1
   sub $t2, $a2, 1
   j ExitMove_new_index
    
up:
   move $t1, $a1
   sub $t2, $a2, 1
   j ExitMove_new_index
    
rightUp:
   add $t1, $a1, 1
   sub $t2, $a2, 1
   j ExitMove_new_index

ExitMove_new_index:
	move $v0, $t1		#largura
	move $v1, $t2		#altura

	jr $ra

	.globl enemy_move
enemy_move:
   #Calcula o movimento do inimigo, recebe mapa $a0, area inimigo $a1, indice inimigo e indice player em $s1
	addi $sp, $sp, -4
	sw $ra, ($sp)

   jal enemy_check_area
   beq $v0, 0, endEnemyMove		#notInArea
   
   li $a1, 1
	jal enemy_check_area		#se estiver em uma area 1, ataque
	bne $v0, 0, enemyCanAtack
    
   #largura
   lw $t1, ($s1)
   lw $t2, 8($s1)
    
   sub $t1, $t1, $t2
   #se <0, esta na dir|se = 0, esta no mesmo indice largura|se >0, esta na esq
   beq $t1, $zero, endLargura		#Inimigo=Personagem, mesma localização, nao precisa mover
	ble $t1, $zero, rightMove		#Inimigo<Personagem, mova para a direita
   ble $zero, $t1, leftMove		#Inimigo>Personagem, mova para a esquerda
   
enemyCanAtack:
	li $v0, 2		# indice que inimigo pode atacar player
   
   j endEnemyMove
endLargura: 
   #altura
   lw $t1, 4($s1)
   lw $t2, 12($s1)
    
   sub $t1, $t1, $t2
   #se <0, esta em baixo|se = 0, esta no mesmo indice altura|se >0, esta em cima
  
   beq $t1, $zero, endEnemyMove	#Inimigo=Personagem, mesma localização, nao precisa mover
   ble $t1, $zero, downMove		#Inimigo<Personagem, mova para a cima
   ble $zero, $t1, upMove		#Inimigo>Personagem, mova para a esquerda

rightMove:
	move $a0, $s0		#coloca em a0 o mapa salvo em $s0
	lw $a1, ($s1)
	lw $a2, 4($s1)
	li $a3, 6		#right
		
	add $t1, $a1, 1	#atualiza o indice X do inimigo
	sw $t1, ($s1)
	jal move_character
	
	j endLargura
	
leftMove:
	move $a0, $s0		#coloca em a0 o mapa salvo em $s0
	lw $a1, ($s1)
	lw $a2, 4($s1)
	li $a3, 4		#left
	
	sub $t1, $a1, 1	#atualiza o indice X do inimigo 
	sw $t1, ($s1)
	jal move_character

	j endLargura
	
upMove:
	move $a0, $s0		#coloca em a0 o mapa salvo em $s0
	lw $a1, ($s1)
	lw $a2, 4($s1)
	li $a3, 8		#up
	
	sub $t1, $a2, 1	#atualiza o indice Y do inimigo 
	sw $t1, 4($s1)
	jal move_character

	j endEnemyMove
	
downMove:
	move $a0, $s0		#coloca em a0 o mapa salvo em $s0
	lw $a1, ($s1)
	lw $a2, 4($s1)
	li $a3, 2		#down
	
	add $t1, $a2, 1	#atualiza o indice Y do inimigo 
	sw $t1, 4($s1)
	jal move_character

	j endEnemyMove
   
endEnemyMove:
   lw $ra, ($sp)
	addi $sp, $sp, 4
	
   jr $ra

	.globl notInArea
notInArea:
   li $v0, 0   #flag nao possui player na area

   jr $ra
   
   .globl enemy_attack
enemy_attack:
	#Mapa $a0, atacante e defensor em $s1, em ordem ((x,y),(x,y))
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal atack_character
		
	li $v0, 4
	la $a0, enAttkdamage1
	syscall
	
	li $v0, 1
	move $a0, $v0
	syscall
	
	li $v0, 4
	la $a0, enAttkdamage2
	syscall
	
	li $v0, 4
	la $a0, enAttkenem1
	syscall
	
	li $v0, 1
	move $a0, $v1
	syscall
	
	li $v0, 4
	la $a0, enAttkenem2
	syscall

	lw $ra, ($sp)
	addi $sp, $sp, 4

	jr $ra
	
	.globl atack_character
atack_character:
	#Mapa $a0, atacante e defensor em $s1, em ordem ((x,y),(x,y)) e retorna o dano dado e vida do defensor
	addi $sp, $sp, -4
	sw $ra, ($sp)

	move $a0, $s0
	lw $a1, ($s1)
	lw $a2, 4($s1)
	jal get_map_obj
	
	lw $t3, 8($v0)
	lw $t8, 8($t3)	#ataque
	
	move $a0, $s0
	lw $a1, 8($s1)
	lw $a2, 12($s1)
	jal get_map_obj
	
	li $t1, 0
	lw $t3, 8($v0)
 	lw $t1, 12($t3)	#defesa	
	lw $t2, ($t3)	#vida atual
	
	sub $t8, $t8, $t1	
	sub $t2, $t2, $t8
	
	sw $t8, 16($s1)
	sw $t2, 20($s1)
	
	ble $t2, 0, remove_defender	#caso vida = 0 remova do mapa/memoria
	
	sw $t2, ($t3)	#ataualiza vida

	end_attack_character:

	lw $v0, 16($s1)		#dano dado
	lw $v1, 20($s1)		#vida do defensor depois
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
remove_defender:
	
	move $a0, $s0
	lw $a1, 8($s1)
	lw $a2, 12($s1)
	move $a3, $v0
	jal remove_object
	
	lw $a1, 8($s1)
	lw $a2, 12($s1)
	
	j end_attack_character
	
	.globl remove_object
remove_object:	
	#mapa em $a0, o objeto a ser removido em $a3, e o indice em $a1, $a2
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	li $t1, 0
	li $t2, 2
	
	lw $t3, ($a3)
	
	beq $t3, $t2, game_over	#caso esteja removendo player

	lw $t3, 8($a3)
	sw $t1, ($t3)
	sw $t1, 4($t3)
	sw $t1, 8($t3)
	sw $t3, 8($a3)
	sw $t1, ($a3)		#trasforma o objeto em chao
	
	jal set_map_obj
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	.globl enemy_ai
enemy_ai:
	# Mapa em $s0, turno em $a1, calcula os movimentos de todos os inimigos no mapa
	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $sp, $sp, -4
	sw $s3, ($sp)
	addi $sp, $sp, -4
	sw $s4, ($sp)
	addi $sp, $sp, -4
	sw $s5, ($sp)
	addi $sp, $sp, -4
	sw $s6, ($sp)
	addi $sp, $sp, -4
	sw $s7, ($sp)
	
	lw $s3, 4($s0)	# largura
	lw $s4, 8($s0)	# altura
	li $s5, 0	# x
	li $s6, 0	# y
	move $s7, $a1	# rodada atual
	
enemy_ai_loop:
	beq $s5, $s3, enemy_ai_line_done
	beq $s6, $s4, enemy_ai_done
	
	move $a0, $s0
	move $a1, $s5
	move $a2, $s6
	jal get_map_obj
	lw $t0, ($v0)
	bne $t0, 3, enemy_ai_loop_step	# Verifica se e inimigo
	lw $t1, 8($v0)
	lw $t2, 16($t1)
	beq $t2, $s7, enemy_ai_loop_step	# Verifica se o inimigo ja agiu nessa rodada
	sw $s7, 16($t1)	# Atualiza o ultimo turno do inimigo
	
	sw $s5, ($s1)
	sw $s6, 4($s1)
	lw $t3, px
	lw $t4, py
	sw $t3, 8($s1)
	sw $t4, 12($s1)
	move $a0, $s0
	li $a1, 2
	jal enemy_move	# Verifica a area e move
	bne $v0, 2, enemy_ai_loop_step	# Verifica se o inimigo pode atacar
	
	sw $s5, ($s1)
	sw $s6, 4($s1)
	lw $t3, px
	lw $t4, py
	sw $t3, 8($s1)
	sw $t4, 12($s1)
	move $a0, $s0
	li $a1, 2
	jal enemy_attack
enemy_ai_loop_step:
	addi $s5, $s5, 1
	j enemy_ai_loop
enemy_ai_line_done:
	li $s5, 0
	addi $s6, $s6, 1
	j enemy_ai_loop
enemy_ai_done:
	lw $s7, ($sp)
	addi $sp, $sp, 4
	lw $s6, ($sp)
	addi $sp, $sp, 4
	lw $s5, ($sp)
	addi $sp, $sp, 4
	lw $s4, ($sp)
	addi $sp, $sp, 4
	lw $s3, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
