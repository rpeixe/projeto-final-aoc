	.data
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
	
enemy_check_area:  
    #Recebe mapa $a0, $a1 area do inimgo, indice inimigo e indice personagem em $s1

    #indices largura inimigo e personagem
    lw $t0, ($s1)
    lw $t1, 8($s1)
    li $t5, 0
    li $t2, 2

    #Checa se personagem est� na largura da enemy_area
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

    #Checa se personagem est� na altura da enemy_area
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
    #Mapa $a0, tenta mover personagem ou inimigo ($a1, $a2) para a dire�ao $a3
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

#enemy_move:	#INCOMPLETO
#    #Calcula o movimento do inimigo, recebe mapa $a0, indice inimigo e indice personagem em $s1
#    jal enemy_check_area
#    
#    beq $v0, 0, notInArea
#    
#    #largura
#    lw $t1, ($s1)
#    lw $t2, 8($s1)
#    
#    sub $t0, $t1, $t2
#    #se <0, esta na dir|se = 0, esta no mesmo indice largura|se >0, esta na esq
#    
#    #altura
#    lw $t1, 4($s1)
#    lw $t2, 12($s1)
#    
#    sub $t1, $t1, $t2
#    #se <0, esta em baixo|se = 0, esta no mesmo indice altura|se >0, esta em cima
#    
#    beq $t0, 0, sameX
#    slt $t0, 0, rightX
#    slt 0, $t0, leftX
#    
#    sameX:
#    
#    li $a3, 3
#    j endIf
#    
#    rightX:
#    
#    endIf:
#    #indice inimigo
#    lw $a1, ($s1)
#    lw $a2, 4($s1)
#    jal move_character
#    
#    beq $v0, 0, err_oob
#    
#    jr $r0
#    
#    notInArea:
#    
#    jr $r0
