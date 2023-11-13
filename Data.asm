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

	.text
main:
	# Teste
	jal create_enemy
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
	