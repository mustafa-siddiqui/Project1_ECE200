.data
length:  .word 10

#nums:  .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
nums:  .word 10, -7, 8, 255, 6, 5, 4, 922, 10, -1##we will store sorted array back here
#nums: .word 5, 3, 7, 1, 2
temp: .word 0:9

.text
main:
	lui $s0, 0x1001		# 
	ori $s0, $s0, 0		# s0 now contains the address of length
	addi $k0, $s0, 4	# k0 now contains the address of the first element of nums
	addi $k1, $s0, 68	# k1 now contains the address of the first element of temp
	lw $s0, 0($s0)		# s0 now contains length
#set parameters for first merge sort call
	addi $a0, $zero, 0
	addi $a1, $s0, -1
	jal mergeSort
	sw $s0, -4($sp)
#PRINT
	
	sll $s0, $s0, 2
	add $s0, $s0, $k0
	
L:	addi $v0, $zero, 1
	lw   $a0, 0($k0)
	syscall
	addi  $a0, $zero, 0x20
	addi $v0, $zero, 11
	addi $k0, $k0, 4
	bne  $k0, $s0, L
	syscall
	
	
	
	addi $v0, $zero, 10
	syscall
	
mergeSort:  	#parameters:      a0 = 1, #a1 = r #k0 = source array 

####need to save and restore s0 s1 and s2 as well as return address
	
	sw $s1, -8($sp)
	sw $s2, -12($sp)
	sw $ra, -16($sp)
	addi $sp, $sp, -16


	sub $s0, $a1, $a0 	#s0 = r - l
	blez $s0, done
	srl $s0, $s0, 1
	add $s0, $s0, $a0 	#s0 now contains m
	addi $s1, $a0, 0  	#s1 now conatains l
	addi $s2, $a1, 0  	#s2 now conatains r

	addi $a1, $s0, 0 	#setting parameters for mergeSort(l, m)
	jal mergeSort
	sw $s0, -4($sp)
	addi $a1, $s2, 0 	#setting parameters for mergeSort(m+1, r)
	addi $a0, $s0, 1 	#setting m+1
	jal mergeSort
	sw $s0, -4($sp)

#merge:			#from here on we use t reg because we don't care if they get overwritten
	sub $t0, $s0, $s1	#t0 = m - l
	addi $t0, $t0, 1 	#t0 now contains n1
	sub $t1, $s2, $s0 	#t1 now contains n2
	addi $t2, $k1, 0 	#t2 now contains pointer to L[0]
	addi $t3, $t0, 0
	sll $t3, $t3, 2
	add $t3, $t3, $k1 	#t3 now contains pointer to R[0]
	sll $t4, $s1, 2		#t4 = 4 * l
	add $t4, $t4, $k0 	#t4 now points to arr[l]
	sll $t6, $s2, 2		#t6 = 4 * r
	add $t6, $t6, $t4	#t6 should point to arr[l + r]
	
#copy k0[l-r] into k1 (works)
copy:				#can be optimized
	lw $t5, 0($t4)
    	sw $t5, 0($t2)
    	addi $t2, $t2, 4
    	bne $t6, $t4, copy
    	addi $t4, $t4, 4
    	
    	
    	
	sll $t4, $s1, 2		#t4 = 4 * l
    	add $t4, $t4, $k0 	#t4 now points to arr[l]
    	addi $t2, $k1, 0 	#t2 now contains pointer to L[0] remember t3 points to R[0]
    	#blez $t0, whileB		#this is initial check for while loop. Can be removed because m >= l so t0 >= 1
    	sll $t0, $t0, 2		#4*n1
    	#blez $t1, whileA		#don't need this either because r-m >= 1
    	lw $t5, 0($t2)		#t5 contains L[i]
	lw $t6, 0($t3)		#t6 contains R[j]
	sll $t1, $t1, 2		#4*n2
    		
while:	
	sub $t7, $t6, $t5	#t7 contains R[j] - L[i]
	bltz $t7, else		#if statement
	sw $t5, 0($t4)		#arr[k] = L[i] #will be overwritten if branch is taken
	addi $t0, $t0, -4	#subtracting 4 from 4n1
	addi $t2, $t2, 4	#adding 4 to L pointer
	lw $t5, 0($t2)		#t5 contains L[i]
	blez $t0, whileB
	j while
	addi $t4, $t4, 4	#adding 4 to arr pointer
	
	
else:
	sw $t6, 0($t4)		#arr[k] = R[j]
	addi $t1, $t1, -4	#subtracting 4 from 4n2
	addi $t3, $t3, 4	#adding 4 to R pointer
	lw $t6, 0($t3)		#t6 contains R[j]
	blez $t1, whileA
	j while
	addi $t4, $t4, 4	#adding 4 to arr pointer

	
whileA:
	sw $t5, 0($t4)		#arr[k] = L[i]
	addi $t0, $t0, -4	#subtracting 4 from 4n1
	addi $t2, $t2, 4	#adding 4 to L pointer
	blez $t0, done
	lw $t5, 0($t2)		#get next L[i]
	j whileA
	addi $t4, $t4, 4	#adding 4 to arr pointer
	
	

whileB:
	sw $t6, 0($t4)		#arr[k] = R[j]
	addi $t1, $t1, -4	#subtracting 4 from 4n2
	addi $t3, $t3, 4	#adding 4 to R pointer
	blez $t1, done
	lw $t6, 0($t3)		#get next R[j]
	j whileB
	addi $t4, $t4, 4	#adding 4 to arr pointer
done:				#restore all regsters s0-3 and return
	addi $sp, $sp, 16
	lw $ra, -16($sp)	
	lw $s0, -4($sp)
	lw $s1, -8($sp)
	jr $ra
	lw $s2, -12($sp)
	

