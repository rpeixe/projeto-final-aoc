	.data
yArea:		.asciiz "Character in area\n"
nArea:		.asciiz "No character in area\n"
	.align 2
indice:	.space 100
aux:	.space 100

	.text
main:
	#Teste enemy check area and move
	la $s1, indice
	la $s2, aux

	li $a0, 20
	move $a1, $a0
	jal create_map
	
	move $s0, $v0
	move $a0, $s0
	
	li $t0, 5
	sw $t0, ($s1)
	li $t0, 6
	sw $t0, 4($s1)
	li $t0, 6
	sw $t0, 8($s1)
	li $t0, 5
	sw $t0, 12($s1)
	
	move $a0, $s0
	lw $a1, ($s1) 
	lw $a2, 4($s1) 
	li $a3, 3
	jal set_map_obj
	
	move $a0, $s0
	li $a1, 5
	li $a2, 6
	jal get_map_obj
	
	move $t1, $v0
	li $v0, 1
	move $a0, $t1
	syscall
	##########
	li $a1, 2	#area inimigo
	jal enemy_check_area 

	beq $v0, 1, msgArea
	
	#personagem nao esta na area inimigo
	li $v0, 4
	la $a0, nArea
	syscall  
	
	li $v0, 10
	syscall
	
	#personagem esta na area inimigo
	msgArea: 	#nao esta salvando movendo certo o objeto
	li $v0, 4
	la $a0, yArea
	syscall
	
	move $a0, $s0
	li $a1, 2		#area inimigo
	jal enemy_move	#envia mapa em $a0, area $a1 e indices em $s1
	
	beq $v0, 2, atack_character	
	
	move $a0, $s0
	li $a1, 6
	li $a2, 5
	
	jal get_map_obj
	
	move $t1, $v0
	li $v0, 1
	move $a0, $t1
	syscall
	
	li $v0, 10	# Fim
	syscall

	.globl enemy_check_area
enemy_check_area:  
   #Recebe mapa $a0, $a1 area do inimgo, indice inimigo e indice personagem em $s1

   #indices largura inimigo e personagem
   lw $t0, ($s1)
   lw $t1, 8($s1)
   li $t5, 0
   li $t2, 2

   #Checa se personagem estï¿½ na largura da enemy_area
   sub $t0, $t0, $a1
   sub $t0, $t0, 1
   slt $t4, $t0, $t1

   lw $t0, ($s1)   #reseta o indice largura
   add $t0, $t0, $a1
   add $t0, $t0, 1
   slt $t5, $t1, $t0

   add $t5, $t5, $t4   #t5=2 se ambos sao validos
   bne $t2, $t5, notInArea

   #indices altura inimigo e personagem
   lw $t0, 4($s1)
   lw $t1, 12($s1)
   li $t5, 0

   #Checa se personagem esta na altura da enemy_area
   sub $t0, $t0, $a1
   sub $t0, $t0, 1
   slt $t4, $t0, $t1

   lw $t0, 4($s1)   #reseta o indice largura
   add $t0, $t0, $a1
   add $t0, $t0, 1
   slt $t5, $t1, $t0

   add $t5, $t5, $t4   #t5=2 se ambos sao validos
   bne $t2, $t5, notInArea

   li $v0, 1   #flag possui personagem na area

   jr $ra
	
	.globl move_character
move_character:  
   #Mapa $a0, tenta mover personagem ou inimigo ($a1, $a2) para a direcao $a3
   addi $sp, $sp, -4
	sw $ra, ($sp)

   sw $a1, ($s2) 
   sw $a2, 4($s2)
   move $t1, $a1       #largura
   move $t2, $a2       #altura
   move $t3, $a1       
   move $t4, $a2       
    
   beq $a3, 1, leftDown
   beq $a3, 2, down
   beq $a3, 3, rightDown
   beq $a3, 4, left
   beq $a3, 5, stay
   beq $a3, 6, right
   beq $a3, 7, leftUp
   beq $a3, 8, up
   beq $a3, 8, rightUp
    
leftDown:	#sw $a1, ($s1)
   sub $t1, $a1, 1
   add $t2, $a2, 1
   j ExitMove_character
        
down:
   move $t1, $a1
   add $t2, $a2, 1
   j ExitMove_character
    
rightDown:
   add $t1, $a1, 1
   add $t2, $a2, 1
   j ExitMove_character
    
left:
   sub $t1, $a1, 1
   move $t2, $a2
   j ExitMove_character
        
stay:
   li $v0, 1   #flag conseguiu mover
    
   jr $ra
        
right:
   add $t1, $a1, 1
   move $t2, $a2
   j ExitMove_character
    
leftUp:
   sub $t1, $a1, 1
   sub $t2, $a2, 1
   j ExitMove_character
    
up:
   move $t1, $a1
   sub $t2, $a2, 1
   j ExitMove_character
    
rightUp:
   add $t1, $a1, 1
   sub $t2, $a2, 1
   j ExitMove_character
   
ExitMove_character:
   #novo indice
   sw $t1, 8($s2)
   sw $t2, 12($s2)
   move $a1, $t1
   move $a2, $t2
   jal get_map_obj
    
   beq $v0, 0, canMove
    
   li $v0, 0     #flag impossivel de mover
    
   jr $ra
    
canMove:
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
   lw $a1, ($s2)
   lw $a2, 4($s2)
   li $a3, 0
   jal set_map_obj
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	 
   li $v0, 1   #flag conseguiu mover
    
   jr $ra

	.globl enemy_move
enemy_move:
   #Calcula o movimento do inimigo, recebe mapa $a0, area inimigo $a1, indice inimigo e indice personagem em $s1
	addi $sp, $sp, -4
	sw $ra, ($sp)

   jal enemy_check_area
   beq $v0, 0, endEnemyMove		#notInArea
   
   li $a1, 1
	jal enemy_check_area		#se estiver em uma area de distancia, ataque
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
	li $v0, 2		# indice que inimigo pode atacar personagem
   
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
   
endEnemyMove:
   lw $ra, ($sp)
	addi $sp, $sp, 8
	
   jr $ra

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

	.globl notInArea
notInArea:
   li $v0, 0   #flag nao possui personagem na area

   jr $ra
   
	.globl atack_character
atack_character:
	#Mapa $a0, atacante e atacado em $s1, em ordem ((x,y),(x,y))
	addi $sp, $sp, -4
	sw $ra, ($sp)

	move $a0, $s0
	lw $a1, ($s1)
	lw $a2, 4($s1)
	jal get_map_index
	
	lw $t0, 8($v0)	#ataque
	move $s2, $t0
	
	move $a0, $s0
	lw $a1, 8($s1)
	lw $a2, 12($s1)
	jal get_map_index
	
	lw $t1, 8($v0)	#defesa
	lw $t2, ($v0)	#vida atual
	move $t0, $s2
	
	sub $t1, $t1, $t0
	add $t2, $t2, $t1
	
	#beq $t2, 0, remove_object	#caso vida = 0 remova do mapa/memoria
	sw $t2, ($v0)

	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
	#.globl remove_object
#remove_object:	#Incompleto
#
#	jr $ra

#################################
