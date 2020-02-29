.data
length:  .word 10

nums:  .word 10, 9, 8, 7, 6, 5, 4, 3, 2, 1	# we will store sorted array back here


.text
main:
	lui $s0, 0x1001		# 
	ori $s0, $s0, 0		# s0 now contains the address of length
	addi $k0, $s0, 4	# k0 now contains the address of the first element of nums
	lw $s0, 0($s0)		# s0 now contains length
	nop			#
	sll  $t0, $s0, 2	# we need a place on the stack for our temp array
	sub  $k1, $sp, $t0	# k1 now contains the address of the first element of temp
	
# set parameters for merge sort call 
	
	addi $a1, $s0, -1
	
# mergeSort:  	# parameters:      a1 = n, #k0 = source array 

	addi $s3, $zero, 1 	# size = 1
	sub  $t3, $s3, $a1 	# initial check for outer while loop
	bgtz $t3, final		
	addi $s1, $zero, 0 	# left = 0
while1:	sub  $s4, $s1, $a1	# initial check for inner while loop
	bgtz $s4, end		# s4 contains left - n
	
while2:	add  $s0, $s1, $s3	# these lines set mid (s0) to min(n, l + size - 1)
	addi $s0, $s0, -1
	sub  $t5, $s0, $a1
	addi $t5, $t5, 1
	blez $t5, skip1
	addi $t2, $k1, 0 	# t2 now contains pointer to L[0] nop
	addi  $s0, $a1, -1
	
skip1:	sll  $s2, $s3, 1	# these lines set right (s2) to min(n, l + 2*size)
	add  $s2, $s2, $s1
	addi $s2, $s2, -1
	sub  $t5, $s2, $a1	
	blez $t5, skip2
	sub $t0, $s0, $s1	# t0 = m - l
	add  $s2, $zero, $a1
	
skip2:	
# at this point need s0 = m s1 = l s2 = r
# merge:		
	addi $t0, $t0, 1 	# t0 now contains n1
	sub $t1, $s2, $s0 	# t1 now contains n2
	sll $t0, $t0, 2		# t0 = 4n1
	add $t3, $t0, $k1 	# t3 now contains pointer to R[0]
	sll $t4, $s1, 2		# t4 = 4 * l
	add $t4, $t4, $k0 	# t4 now points to arr[l]
	sll $t6, $s2, 2		# t6 = 4 * r
	add $t6, $k0, $t6	# t6 should point to arr[r]
	
# copy k0[l-r] into k1 (works)
copy:				
	lw $t5, 0($t4)		# loading arr[l] into t5
    	sw $t5, 0($t2)		# stores t5 into L[i]
    	addi $t2, $t2, 4	# increment L pointer
    	bne $t6, $t4, copy	
    	addi $t4, $t4, 4
    	
	sll $t4, $s1, 2		# t4 = 4 * l
    	add $t4, $t4, $k0 	# t4 now points to arr[l]
    	addi $t2, $k1, 0 	# t2 now contains pointer to L[0] remember t3 points to R[0]
    	lw $t5, 0($t2)		# t5 contains L[i]
	lw $t6, 0($t3)		# t6 contains R[j]
	sll $t1, $t1, 2		# 4 * n2
    		
    	sub $t7, $t6, $t5	# t7 contains R[j] - L[i]
    	
while:	
	bltz $t7, else		# if statement
	sw $t5, 0($t4)		# arr[k] = L[i] #will be overwritten if branch is taken
	addi $t0, $t0, -4	# subtracting 4 from 4n1
	addi $t2, $t2, 4	# adding 4 to L pointer
	lw $t5, 0($t2)		# t5 contains L[i]
	blez $t0, whileB
	addi $t4, $t4, 4	# adding 4 to arr pointer
	j while
	sub $t7, $t6, $t5	# t7 contains R[j] - L[i]
		
else:
	sw $t6, 0($t4)		# arr[k] = R[j]
	addi $t1, $t1, -4	# subtracting 4 from 4n2
	addi $t3, $t3, 4	# adding 4 to R pointer
	lw $t6, 0($t3)		# t6 contains R[j]
	blez $t1, whileA	
	addi $t4, $t4, 4	# adding 4 to arr pointer
	j while
	sub $t7, $t6, $t5	# t7 contains R[j] - L[i]
	
whileA:
	sw $t5, 0($t4)		# arr[k] = L[i]
	addi $t0, $t0, -4	# subtracting 4 from 4n1
	addi $t2, $t2, 4	# adding 4 to L pointer
	blez $t0, donemerge
	lw $t5, 0($t2)		# get next L[i]
	j whileA
	addi $t4, $t4, 4	# adding 4 to arr pointer
	
whileB:
	sw $t6, 0($t4)		# arr[k] = R[j]
	addi $t1, $t1, -4	# subtracting 4 from 4n2
	addi $t3, $t3, 4	# adding 4 to R pointer
	blez $t1, donemerge
	lw $t6, 0($t3)		# get next R[j]
	j whileB
	addi $t4, $t4, 4	# adding 4 to arr pointer
		
donemerge:	
	sll $t3, $s3, 1		#
	add $s4, $t3, $s4 	# (left - n) + 2 * size
	blez $s4, while2
	add  $s1, $s1, $t3	# increment left
		
end:    sll $s3, $s3, 1
	sub $t3, $s3, $a1
	blez $t3, while1
	addi $s1, $zero, 0 	# left = 0s
final:	
	
# PRINT
	sll $s0, $a1, 2
	add $s0, $s0, $k0	# end of array
	
L:	lw   $a0, 0($k0)	# load array[i] into a0
	addi $v0, $zero, 1	# code to print integer
	syscall
	addi  $a0, $zero, 0x20	# ascii code for space 
	addi $v0, $zero, 11	# code to print character (space)
	syscall
	bne  $k0, $s0, L	# check for end of array
	addi $k0, $k0, 4	# increment by 4
	
	addi $v0, $zero, 0xa	# terminate program
	syscall
	
	
	

