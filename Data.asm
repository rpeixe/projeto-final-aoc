#################################################################################
# Objeto de Jogo (12 bytes)							#
#										#
# Define um objeto gen?rico no mundo do jogo					#
#										#
# Estrutura:									#
# Tipo - posicao 0, 4 bytes - o tipo de objeto					#
# ASCII - posicao 4, 4 bytes - o caracter ascii que representa o objeto,	#
#	  nao mais utilizado							#
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
######################### Talvez ################################################
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
oob:	.asciiz "Error: out of bounds\n"
ut:	.asciiz "Error: unknown object type\n"
nan:	.asciiz "Error: not a number\n"
re:	.asciiz "Error: read error\n"
pnf:	.asciiz "Error: player not found\n"
wi:	.asciiz "Error: wrong index\n"
file:	.asciiz "map.txt"
gm1:	.asciiz "Desafiou a masmorra, encontrou seu fim\n"
gm2:	.asciiz "Voce morreu\n"
rest:	.asciiz "Pressione r para recomecar o jogo ou q para desistir\n"
wc:	.asciiz "Letra invalida, digite novamente"
	.align 2
buf:	.space 8196	# Maximo 64x64
	.align 2
buf_s:	.word 8196
	
	.text
main:
	#jal read_map_from_file
	#move $s0, $v0
	
	#move $a0, $s0
	#li $a1, 6
	#li $a2, 6
	#jal get_map_obj	
	#move $a0, $v0
	#jal print_object

	#li $v0, 10	# Finaliza o programa
	#syscall
	
	.globl create_floor
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

	.globl create_wall
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
	
	.globl create_player
create_player:
	# Cria um player e retorna seu endereco em $v0
	li $v0, 9
	li $a0, 12
	syscall
	
	li $t0, 2
	sw $t0, ($v0)
	li $t0, 'p'
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

	.globl create_enemy
create_enemy:
	# Cria um inimigo e retorna seu endereco em $v0
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
	
create_object:
	# Cria um objeto com o tipo de $a0 e retorna em $v0
	beq $a0, 0, create_floor
	beq $a0, 1, create_wall
	beq $a0, 2, create_player
	beq $a0, 3, create_enemy
	j err_ut
	
	.globl print_object
print_object:
	# Imprime o ascii do objeto com endereco em $a0
	li $v0, 11
	lw $a0, 4($a0)
	syscall
	
	jr $ra
	
	.globl set_health
set_health:
	# Altera a vida do objeto com endereco em $a0 para $a1
	sw $a1 ($a0)
	jr $ra

	.globl create_map
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

	.globl get_map_index
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

	.globl get_map_obj
get_map_obj:
	# Retorna em $v0 o objeto do mapa $a0 na posicao ($a1, $a2)
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal get_map_index
	lw $t1, ($a0)
	add $t0, $t1, $v0
	lw $v0, ($t0)
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
	.globl get_player
get_player:
	# Busca o player no mapa $a0 e retorna em $v0
	
	# Guarda os $s e o $ra na stack
	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $sp, $sp, -4
	sw $s0, ($sp)
	addi $sp, $sp, -4
	sw $s1, ($sp)
	addi $sp, $sp, -4
	sw $s2, ($sp)
	addi $sp, $sp, -4
	sw $s3, ($sp)
	addi $sp, $sp, -4
	sw $s4, ($sp)
	
	lw $s0, ($a0)
	lw $s1, 4($a0)
	lw $s2, 8($a0)
	
	li $s3, 0
	li $s4, 0
get_player_loop:
	beq $s3, $s1, get_player_loop_line_done
	beq $s4, $s2, get_player_loop_error
	
	move $a1, $s3
	move $a2, $s4
	jal get_map_obj
	lw $t0, ($v0)
	beq $t0, 2, get_player_loop_done
	
	addi $s3, $s3, 1
	j get_player_loop
get_player_loop_line_done:
	li $s3, 0
	addi $s4, $s4, 1
	j get_player_loop
get_player_loop_done:
	# Restaura os $s e o $ra
	lw $s4, ($sp)
	addi $sp, $sp, 4
	lw $s3, ($sp)
	addi $sp, $sp, 4
	lw $s2, ($sp)
	addi $sp, $sp, 4
	lw $s1, ($sp)
	addi $sp, $sp, 4
	lw $s0, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	jr $ra
get_player_loop_error:
	j err_pnf
	
	.globl set_map_obj
set_map_obj:
	# Coloca o objeto $a3 no mapa $a0 na posicao ($a1, $a2)
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal get_map_index
	lw $t1, ($a0)
	add $t0, $t1, $v0
	sw $a3, ($t0)
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

	.globl err_oob
err_oob:
	# Erro caso tente acessar uma posicao inexistente
	li $v0, 4
	la $a0, oob
	syscall
	
	li $v0, 10
	syscall
	
	.globl err_ut
err_ut:
	# Erro caso tente usar um tipo de objeto inexistente
	li $v0, 4
	la $a0, ut
	syscall
	
	li $v0, 10
	
	.globl err_nan
err_nan:
	# Erro caso o caracter nao seja um numero
	li $v0, 4
	la $a0, nan
	syscall
	
	li $v0, 10
	syscall
	
	.globl err_re
err_re:
	# Erro lendo o arquivo
	li $v0, 4
	la $a0, re
	syscall
	
	li $v0, 10
	syscall
	
	.globl err_ind
err_ind:
	# Erro indice errado
	li $v0, 4
	la $a0, wi
	syscall
	
	li $v0, 10
	syscall

	.globl err_pnf
err_pnf:
	# Erro caso player nao seja encontrado
	li $v0, 4
	la $a0, pnf
	syscall
	
	li $v0, 10
	syscall
	

	.globl read_map_from_file
read_map_from_file:
	# Le o mapa do arquivo "Map.dat" e retorna o endereco em $v0
	
	# Salva os $s e o $ra
	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $sp, $sp, -4
	sw $s0, ($sp)
	addi $sp, $sp, -4
	sw $s1, ($sp)
	addi $sp, $sp, -4
	sw $s2, ($sp)
	addi $sp, $sp, -4
	sw $s3, ($sp)
	addi $sp, $sp, -4
	sw $s4, ($sp)
	addi $sp, $sp, -4
	sw $s5, ($sp)
	addi $sp, $sp, -4
	sw $s6, ($sp)
	
	li $v0, 13	# Abrir arquivo
	la $a0, file	# Nome do arquivo
	li $a1, 0	# Somente leitura
	li $a2,0
	syscall	
	bltz $v0, err_re
	
	move $a0, $v0	# Descritor de arquivo
	li $v0, 14	# Ler arquivo
	la $a1, buf	# Buffer
	lw $a2, buf_s	# Tamanho do buffer
	syscall
	bltz $v0, err_re
	
	move $s0, $a0	# Salva descritor
	move $a0, $a1
	jal convert_line
	move $s1, $v0	# Largura
	addi $a0, $v1, 1	# Posicao final mais um
	jal convert_line
	move $s2, $v0	# Altura
	
	move $a0, $s1
	move $a1, $s2
	jal create_map	# Cria um mapa com a largura e altura definidas
	move $s5, $v0	# Salva o mapa
	
	addi $s6, $v1, 1
	li $s3, 0	# x atual
	li $s4, 0	# y atual
read_loop:
	beq $s4, $s2, read_done
	beq $s3, $s1, line_done
	lb $t0, ($s6)
	# Verificacoes
	beq $t0, 10, next_char	# LF
	beq $t0, 13, next_char	# CR
	beq $t0, 32, next_char	# SP
	blt $t0, 48, err_nan	# NaN
	bgt $t0, 57, err_nan	# NaN
	
	addi $a0, $t0, -48	# Converte em inteiro
	jal create_object
	move $a0, $s5
	move $a1, $s3
	move $a2, $s4
	move $a3, $v0
	jal set_map_obj
	
	addi $s3, $s3, 1
next_char:
	addi $s6, $s6, 1	# Adiciona no endereco da string
	j read_loop
line_done:
	addi $s4, $s4, 1	# Adiciona no y atual
	li $s3, 0	# Reseta o x atual
	j read_loop
read_done:
	li $v0, 16	# Fecha arquivo
	move $a0, $s0	# Descritor de arquivo
	syscall
	
	move $v0, $s5	# Retorna o mapa

	# Restaura os $s e o $ra
	lw $s6, ($sp)
	addi $sp, $sp, 4
	lw $s5, ($sp)
	addi $sp, $sp, 4
	lw $s4, ($sp)
	addi $sp, $sp, 4
	lw $s3, ($sp)
	addi $sp, $sp, 4
	lw $s2, ($sp)
	addi $sp, $sp, 4
	lw $s1, ($sp)
	addi $sp, $sp, 4
	lw $s0, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
convert_line:
	# Le a string em $a0 e retorna um inteiro correspondente em $v0, e a posicao final em $v1
	li   $v0, 0	# Valor inicial 0
	li   $t0, 10	# Base 10
convert_loop:
	lb   $t1, ($a0)
	beq  $t1, 13, convert_done	# Fim da linha

	addi  $t1, $t1, -48	# Converte em inteiro
	mul  $v0, $v0, $t0	# Multiplica pela base
	add  $v0, $v0, $t1	# Adiciona digito

	addi $a0, $a0, 1
	j    convert_loop
convert_done:
	addi $a0, $a0, 1
	move $v1, $a0	# Posicao final
	jr   $ra
	
	.globl game_over
game_over:
	li $v0, 4
	la $a0, gm1
	syscall
	
	li $v0, 4
	la $a0, gm2
	syscall
	
	loopGM:
	
	li $t0, 'r'
	li $t1, 'q'
	
	li $v0, 4
	la $a0, rest
	syscall 
	
	li $v0, 12
	syscall
	
	beq $t0, $v0, main	#restarta todo o game
	
	beq $t0, $v0, end
	
	li $v0, 4
	la $a0, wc
	syscall
	
	j loopGM
	
	end:
	li $v0, 10	# Finaliza o jogo
	syscall