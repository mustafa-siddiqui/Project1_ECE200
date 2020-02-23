.data
length:  .word 10
#nums:  .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
nums:  .word 10,9,8,7,6,5,4,3,2,1 ##we will store sorted array back here
temp: .word 0:10

.text
main:
	lui $s0, 0x1001		# 
	ori $s0, $s0, 0		# s0 now contains the address of length
	addi $k0, $s0, 4	# k0 now contains the address of the first element of nums
	addi $k1, $s0, 44	# k1 now contains the address of the first element of temp
	lw $s0, 0($s0)		# s0 now contains length
#set parameters for first merge sort call
	addi $a0, $zero, 0
	addi $a1, $s0, -1

mergeSort:  	#parameters:      a0 = 1, #a1 = r #k0 = source array 

####need to save and restore s0 s1 and s2 as well as return address
	sw $s0, -4($sp)
	sw $s1, -8($sp)
	sw $s2, -12($sp)
	sw $ra, -16($sp)
	addi $sp, $sp, -16


	sub $s0, $a1, $a0 	#s0 = r - l
	bltz $s0, done
	srl $s0, $s0, 1
	add $s0, $s0, $a0 	#s0 now contains m
	addi $s1, $a0, 0  	#s1 now conatains l
	addi $s2, $a1, 0  	#s2 now conatains r

	addi $a1, $s0, 0 	#setting parameters for mergeSort(l, m)
	jal mergeSort
	nop
	addi $a1, $s2, 0 	#setting parameters for mergeSort(m+1, r)
	addi $a0, $s0, 1 	#setting m+1
	jal mergeSort
	nop

#merge:				#from here on we use t reg because we don't care if they get overwritten
	sub $t0, $s0, $s1
	addi $t0, $t0, 1 	#t0 now contains n1
	sub $t1, $s2, $s0 	#t1 now contains n2
	addi $t2, $k1, 0 	#t2 now contains pointer to L
	addi $t3, $t2, 1
	add $t3, $t3, $s0 	#t3 now contains pointer to R
#TODO: copy k0 int k1
copy:
	



done:
	jr $ra
	nop

