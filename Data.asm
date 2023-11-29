#################################################################################
# Objeto de Jogo (12 bytes)							#
#										#
# Define um objeto genÃ©rico no mundo do jogo					#
#										#
# Estrutura:									#
# Tipo - posicao 0, 4 bytes - o tipo de objeto					#
# ASCII - posicao 4, 4 bytes - o caracter ascii que representa o objeto		#
# Ref - posicao 8, 4 bytes - endereco de memoria que contem objeto especifico	#
#										#
# Tipos:									#
# 0 - Chao (vazio)								#
# 1 - Parede (impassavel)							#
# 2 - Player									#
# 3 - Inimigo									#
#################################################################################
# Player (28 bytes)								#
#										#
# Define um inimigo no mundo do jogo						#
#										#
# Estrutura:									#
# Vida atual - posicao 0, 4 bytes						#
# Vida maxima - posicao 4, 4 bytes						#
# Dano - posicao 8, 4 bytes							#
# Armadura - posicao 12, 4 bytes - reducao de dano				#
# Forca - posicao 16, 4 bytes							#
# Destreza - posicao 20, 4 bytes						#
# Inteligencia - posicao 24, 4 bytes						#
#################################################################################
# Inimigo (16 bytes)								#
#										#
# Define um inimigo no mundo do jogo						#
#										#
# Estrutura:									#
# Vida atual - posicao 0, 4 bytes						#
# Vida maxima - posicao 4, 4 bytes						#
# Dano - posicao 8, 4 bytes							#
# Armadura - posicao 12, 4 bytes - reducao de dano				#
#################################################################################
#################################################################################
# Mapa (12 bytes)								#
#										#
# Define o mapa do jogo								#
#										#
# Estrutura:									#
# Grid - posicao 0, 4 bytes - vetor que mapeia posicoes do jogo			#
# Largura - posicao 4, 4 bytes							#
# Altura - posicao 8, 4 bytes							#
#################################################################################

.data
oob:	.asciiz "Erro: out of bounds\n"
yes:	.asciiz "Personagem na area\n"
no:	.asciiz "Nao ha ninguem na area\n"
	.align 2
	
aux:	.space 100


.text
main:
	la $s1, aux

	# Teste
	li $a0, 20
	move $a1, $a0
	jal create_map
	
	move $a0, $v0
	
	li $t0, 5
	sw $t0, ($s1)
	li $t0, 6
	sw $t0, 4($s1)
	li $t0, 7
	sw $t0, 8($s1)
	li $t0, 5
	sw $t0, 12($s1)
	li $a1, 2	#area
	
	jal enemy_check_area

	beq $v0, 1, yestem
	
	#no
	li $v0, 4
	la $a0, no
	syscall
	
	li $v0, 10
	syscall
	
	yestem:
	li $v0, 4
	la $a0, yes
	syscall
	
	li $v0, 10	# Fim
	syscall
	
create_floor:
	# Cria chao e retorna seu endereco em $v0
	li $v0, 9
	li $a0, 12
	syscall
	
	li $t0, 0
	sw $t0, ($v0)
	li $t0, 183
	sw $t0, 4($v0)
	
	jr $ra

create_wall:
	# Cria uma parede e retorna seu endereco em $v0
	li $v0, 9
	li $a0, 12
	syscall
	
	li $t0, 1
	sw $t0, ($v0)
	li $t0, '#'
	sw $t0, 4($v0)
	
	jr $ra
	
create_enemy:
	# Cria uma parede e retorna seu endereco em $v0
	li $v0, 9
	li $a0, 12
	syscall
	
	li $t0, 3
	sw $t0, ($v0)
	li $t0, 'e'
	sw $t0, 4($v0)
	
	move $t1, $v0
	li $v0, 9
	li $a0, 16
	syscall
	
	# 3 de vida, 1 de dano, 0 de armadura
	li $t0, 3
	sw $t0, ($v0)
	sw $t0, 4($v0)
	li $t0, 1
	sw $t0, 8($v0)
	sw $v0, 8($t1)
	
	move $v0, $t1
	jr $ra
	
print_object:
	# Imprime o ascii do objeto com endereco em $a0
	li $v0, 11
	lw $a0, 4($a0)
	syscall
	
	jr $ra
	
set_health:
	# Altera a vida do objeto com endereco em $a0 para $a1
	sw $a1 ($a0)
	jr $ra

create_map:
	# Cria o mapa do jogo com largura $a0 e altura $a1 e retorna em $v0
	move $t2, $a0
	move $t3, $a1
	
	li $v0, 9
	li $a0, 12
	syscall
	
	move $t0, $v0
	sw $t2, 4($t0)
	sw $t3, 8($t0)
	
	mul $t1, $t2, $t3
	sll $t1, $t1, 2
	
	li $v0, 9
	move $a0, $t1
	syscall
	
	sw $v0, ($t0)
	move $v0, $t0
	jr $ra

get_map_index:
	# Retorna em $v0 o o indice no grid do mapa $a0 na posicao ($a1, $a2)
	lw $t0, ($a0)
	lw $t1, 4($a0)
	lw $t2, 8($a0)
	
	# Deteccao de erro
	bltz $a1, err_oob
	bltz $a2, err_oob
	bge $a1, $t1, err_oob
	bge $a2, $t2, err_oob
	
	# pos = pos y * largura + pos x
	mul $t3, $t1, $a2
	add $t3, $t3, $a1
	sll $t3, $t3, 2
	
	move $v0, $t3
	jr $ra

get_map_obj:
	# Retorna em $v0 o objeto do mapa $a0 na posicao ($a1, $a2)
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal get_map_index
	add $t0, $a0, $v0
	lw $v0, ($t0)
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
set_map_obj:
	# Coloca o objeto $a3 no mapa $a0 na posicao ($a1, $a2)
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal get_map_index
	add $t0, $a0, $v0
	sw $a3, ($t0)
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

err_oob:
	# Erro caso tente acessar uma posicao inexistente
	li $v0, 4
	la $a0, oob
	syscall
	
	li $v0, 10
	syscall
	

enemy_check_area:  
    #Recebe mapa $a0, $a1 area do inimgo, indice inimigo e indice personagem em $s1

    #indices largura inimigo e personagem
    lw $t0, ($s1)
    lw $t1, 8($s1)
    li $t5, 0
    li $t2, 2

    #Checa se personagem está na largura da enemy_area
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

    #Checa se personagem está na altura da enemy_area
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

    notInArea:

    li $v0, 0   #flag nao possui personagem na area

    jr $ra
	
move_character:  
    #Mapa $a0, tenta mover personagem ou inimigo ($a1, $a2) para a direçao $a3
    move $t1, $a1       #largura
    move $t2, $a2       #altura
    
    beq $a3, 1, left
    beq $a3, 2, leftUp
    beq $a3, 3, up
    beq $a3, 4, rightUp
    beq $a3, 5, right
    beq $a3, 6, rightDown
    beq $a3, 7, down
    beq $a3, 8, leftDown
    
    left:
    sub $t3, $t1, 1
    j Exit
    
    leftUp:
    sub $t3, $t1, 1
    add $t4, $t2, 1
    j Exit
    
    up:
    add $t4, $t2, 1
    j Exit
    
    rightUp:
    add $t3, $t1, 1
    add $t4, $t2, 1
    j Exit
    
    right:
    add $t3, $t1, 1
    j Exit
    
    rightDown:
    add $t3, $t1, 1
    sub $t4, $t2, 1
    j Exit
    
    down:
    sub $t4, $t2, 1
    j Exit
    
    leftDown:
    sub $t3, $t1, 1
    sub $t4, $t2, 1
    j Exit
    
    Exit:
    #novo indice
    move $a1, $t3
    move $a2, $t4
    jal get_map_obj
    
    beq $v0, 0, canMove
    
    li $v0, 0     #flag impossivel de mover
    
    jr $ra
    
    canMove:
    #inidice original
    move $a1, $t1
    move $a2, $t2
    jal get_map_obj
    
    #move o tipo para a nova posicao
    move $a3, $v0
    move $a1, $t3
    move $a2, $t4
    jal set_map_obj
    
    #atualiza a antiga posicao com chao
    li $a3, 0
    move $a1, $t1
    move $a2, $t2
    jal set_map_obj
    
    li $v0, 1   #flag conseguiu mover
    
    jr $ra

enemy_move:	#INCOMPLETO
    #Calcula o movimento do inimigo, recebe mapa $a0, indice inimigo e indice personagem em $s1
    jal enemy_check_area
    
    beq $v0, 0, notInArea
    
    #largura
    lw $t1, ($s1)
    lw $t2, 8($s1)
    
    sub $t0, $t1, $t2
    #se <0, esta na dir|se = 0, esta no mesmo indice largura|se >0, esta na esq
    
    #altura
    lw $t1, 4($s1)
    lw $t2, 12($s1)
    
    sub $t1, $t1, $t2
    #se <0, esta em baixo|se = 0, esta no mesmo indice altura|se >0, esta em cima
    
    beq $t0, 0, sameX
    slt $t0, 0, rightX
    slt 0, $t0, leftX
    
    sameX:
    
    li $a3, 3
    j endIf
    
    rightX:
    
    endIf:
    #indice inimigo
    lw $a1, ($s1)
    lw $a2, 4($s1)
    jal move_character
    
    beq $v0, 0, err_oob
    
    jr $r0
    
    notInArea:
    
    jr $r0