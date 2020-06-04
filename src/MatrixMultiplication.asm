# NOTE: Delayed Branching is enabled.
# variable data
.data
	space: .asciiz " "
	
	matrixRows: .word 2
	matrixColumns: .word 3
	vectorRows: .word 3
	# Row Vectors always have 1 row, so no need to specify for our purposes
	
	vectorX: .word 1, 2, 3
	vectorY: .word 1, 2, 3
	matrix: .word 5, 6, 7, 8, 9, 10
	
	initialProduct: .word

	matrixProduct: .word
	
# instructions
.text
	# access to data from memory
	lui $k1, 0x1001
	ori $k1, $k1, 0				# k1 contains address of space
	
	addi $s0, $k1, 4			# s0 contains address of matrixRows
	
	addi $s1, $s0, 4			# s1 contains address of matrixColumns
	
	addi $s2, $s1, 4			# s2 contains address of vectorRows
	
	addi $s3, $s2, 4			# s3 contains address of first index of vectorX
	
	lw $t0, 0($s2)				# load vectorRows (value) in t1
	sll $t1, $t0, 2				# multiply by 4 by shifting left by 2
	
	add $s4, $s3, $t1			# s4 contains address of first index of VectorY >> address(vectorX[0]) + 4n
	
	add $s5, $s4, $t1			# s5 contains address of first index of matrix
	
	lw $t0, 0($s0)				# load matrixRows in t0
	lw $t1, 0($s1)				# load matrixColumns in t1
	mult $t0, $t1				# multiply to get size of matrix
	mflo $t0				# load multiplication result in t0
	sll $t0, $t0, 2				# multiply by 4
	
	add $s6, $s5, $t0			# s6 contains address for result of vector multiplication (initialProduct)
	
	# transpose Y				# don't consider this as a necessary step
	
	# multiply X and transposeY
	add $s7, $s6, $zero			# store address in s6 in s7; we need s6 later
	lw $t8, 0($s2)				# load vectorRows in t8
	add $t9, $t9, $s3			# load address stored in s3 in t9; first element of vectorX
	add $t7, $t7, $s4			# load address stored in s4 in t7; first element of vectorY
	addi $t2, $zero, 1			# initialize counter for for-loop j (outer loop)
loopj:	addi $t3, $zero, 1			# initialize counter for for-loop i (inner loop)
	add $t7, $zero, $s4			# load address of first element of vectorY again for second iteration
	
loopi:	lw $t4, 0($t9)				# load first element of vectorX in t4
	lw $t5, 0($t7)				# load first element of vectorY (transpose) in t5
	
	mult $t4, $t5
	mflo $t6				# stores multiplication result in t6; assumes result does not exceed 32 bits
	
	sw $t6, 0($s7)				# store result of first multiply at address in s6
	addi $s7, $s7, 4			# increment address for result
	addi $t7, $t7, 4			# increment vectorY element
	
	bne $t3, $t8, loopi			# branch for loop i (inner loop)
	addi $t3, $t3, 1			# increment i
	
	addi $t9, $t9, 4			# increment vectorX element
	
	bne $t2, $t8, loopj			# branch for loop j (outer loop)
	addi $t2, $t2, 1			# increment j
	
	# above part correct // tested 02/25/2020
	
	# matrix product multiplication
	addi $s7, $s7, 4			# get address for matrix multiplication product
	#					# t8 contains vectorRows already
	lw $t0, 0($s0)				# load matrixRows in t0
	lw $t1, 0($s1)				# load matrixColumns in t1
	add $t9, $zero, $s7			# load location of first index of matrix result in t9
	
	addi $t2, $zero, 0			# initialize counter for loop i (outer loop)
loop2i:	addi $t3, $zero, 0			# initialize counter for loop j (middle loop)
loop2j:	addi $t4, $zero, 0			# initialize counter for loop k (inner loop)
	
	# t5, t6, t7 temp var for mult
	# address = baseAddress + 4*(i*matrixRows + j) -> mapping 2D into 1D using row-extension
	
	# load matrix element
loop2k:	mult $t2, $t1				# multiply i with matrixColumns
	mflo $t5				# move multiplication result to t5; assumes result doesn't exceed 32 bits
	add $t5, $t5, $t4			# add product to k
	sll $t5, $t5, 2				# multiply with 4 (size of a word)
	
	add $t5, $s5, $t5			# load address of element to accessed of matrix in t6
	lw $t6, 0($t5)				# load element at address in t5
	
	# load initialProduct element
	mult $t4, $t8				# multiply k with vectorRows
	mflo $t5				# move result to t5; same assumption
	add $t5, $t5, $t3			# add product to j
	sll $t5, $t5, 2				# multiply with 4 (size of word)
	
	add $t5, $s6, $t5			# load address of element to be accessed of initialProduct in t6
	lw $t7, 0($t5)				# load element at address in t5
	
	# perform multiplication
	mult $t6, $t7				# multiply the elements
	mflo $t5				# move result in t5, same assumption
	add $k0, $k0, $t5			# result matrix[index] += multiplication result
	
	addi $t4, $t4, 1			# increment k
	bne $t4, $t8, loop2k			# branch for loop k (inner loop)
	nop
	
	sw $k0, 0($t9)				# store result in address specified by t9
	addi $t9, $t9, 4
	add $k0, $zero, $zero			# reset k0 to 0
	
	addi $t3, $t3, 1			# increment j
	bne $t3, $t1, loop2j			# branch for loop j (middle loop)
	nop
	
	addi $t2, $t2, 1			# increment i
	bne $t2, $t0, loop2i			# branch for loop i (outer loop)
	nop
	
	# printing matrix
	# note: vectorRows specifies the columns in the final matrix
	lw $k0, 0($s0)				# load size of matrix in $k0
	lw $t3, 0($s2)				# load vectorRows in t3
	addi $t0, $zero, 1			# initialize loop counter (outer)
loop:	addi $t2, $zero, 1			# initialize loop counter (inner)
	#					# s7 contains address of first element of result matrix
loopin:	lw $t1, 0($s7)				# load first element of matrix in t1
	addi $v0, $zero, 1			# load 1 into v0 for integer printing
	add $a0, $zero, $t1
	syscall					# print element in matrix
	addi $v0, $zero, 4			# load 4 into v0 for string printing
	add $a0, $zero, $k1
	syscall					# print space
	addi $s7, $s7, 4			# move to the next element in matrix
	bne $t2, $t3, loopin
	addi $t2, $t2, 1			# increment inner loop index
	addi $a0, $zero, 0xA			# load ASCII for newline character (\n = 10)
	addi $v0, $zero, 11			# system call 11 prints lower 8 bits of a0 as an ASCII character
	syscall					# print newline character at end of row
	bne $t0, $k0, loop
	addi $t0, $t0, 1			# increment outer loop index; make use of delayed branching

	# exit program
	addi $v0, $zero, 0xA			# load 10 in v0 to exit
	syscall
