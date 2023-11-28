#################################################################################
# Objeto de Jogo (12 bytes)							#
#										#
# Define um objeto genérico no mundo do jogo					#
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
	.align 2


.text
main:
	# Teste
	li $a0, 20
	move $a1, $a0
	jal create_map
	
	move $s0, $v0
	
	jal create_enemy
	move $a3, $v0
	li $a1, 13
	li $a2, 15
	move $a0, $s0
	jal set_map_obj
	
	jal get_map_obj
	
	move $a0, $v0
	jal print_object
	
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
	