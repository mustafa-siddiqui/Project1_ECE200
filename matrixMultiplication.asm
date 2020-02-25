# variable data
.data
	matrixRows: .word 2
	matrixColumns: .word 3
	vectorRows: .word 3
	
	vectorX: .word 1, 2, 3
	vectorY: .word 1, 2, 3
	matrix: .word 5, 6, 7, 8, 9, 10
	
	product: .word
	
# instructions
.text
	# access to data from memory
	lui $s0, 0x1001
	ori $s0, $s0, 0				# s0 contains address of matrixRows
	
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
	
	add $s6, $s5, $t0			# s6 contains address for result of vector multiplication
	
	# transpose Y				# don't consider this as a necessary step
	
	# multiply X and transposeY
	lw $t8, 0($s2)				# load vectorRows in t8
	add $t9, $t9, $s3			# load address stored in s3 in t9; first element of vectorX
	add $t7, $t7, $s4			# load address stored in s4 in t7; first element of vectorY
	addi $t2, $zero, 0			# initialize counter for for-loop j (outer loop)
loopj:	addi $t3, $zero, 1			# initialize counter for for-loop i (inner loop)
	addi $t2, $t2, 1			# increment j
	
loopi:	lw $t4, 0($t9)				# load first element of vectorX in t4
	lw $t5, 0($t7)				# load first element of vectorY (transpose) in t5
	
	mult $t4, $t5
	mflo $t6				# stores multiplication result in t6; assumes result does not exceed 32 bits

	sw $t6, 0($s6)				# store result of first multiply at address in s6
	addi $s6, $s6, 4			# increment address for result
	addi $t7, $t7, 4			# increment vectorY element
	
	bne $t3, $t8, loopi			# branch for loop i (inner loop)
	addi $t3, $t3, 1			# increment i
	
	addi $t9, $t9, 4			# increment vectorX element
	
	bne $t2, $t8, loopj			# branch for loop j (outer loop)
	add $t7, $zero, $s4			# load address of first element of vectorY again for second iteration
	
	# above part correct // tested 02/25/2020
	
	
	# matrix product multiplication
	# printing the array
