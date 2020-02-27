.data
	length:  .word 10
	str1:	.asciiz "  min: "
	str2:	.asciiz "  max: "
	str3:	.asciiz "  median: "
	min:  .word 0
	max:  .word 0
	median:  .word 0
	nums:  .word 92, 31, 92, 6, 54, 54, 62, 33, 8, 52

.text

main:
	# first we need to get access to our data
	lui $s0, 0x1001		# 
	ori $s0, $s0, 0		# s0 now contains the address of length
	addi $k0, $s0, 44	# k0 now contains the address of nums
	lw $s0, 0($s0)		# s0 now contains length

#setting parameters for merge sort call
	addi $a0, $zero, 0
	addi $a1, $s0, -1
	sll  $t0, $s0, 2	#we need a place on the stack for our temp array
	sub  $sp, $sp, $t0	
	add  $k1, $zero, $sp	# k1 now contains the address of the first element of temp
	

	jal mergeSort
	sw $s0, -4($sp)
#sort

	lw $t0, 0($k0)	#load smallest element(first in array)
	addi $s0, $s0, -1 #load max element(last in array)
	sll $t1, $s0, 2
	add $t1, $t1, $k0
	lw $t1, 0($t1)
	srl $t2, $s0, 1	   #load median (arr[len/2])
	sll $t2, $t2, 2
	add $t2, $t2, $k0
	lw $t2, 0($t2)
	
	addi $k0, $k0, -4 #store min, max, and median in proper places in memory
	sw $t2, 0($k0)

	addi $k0, $k0, -4
	sw $t1, 0($k0)

	addi $k0, $k0, -4
	sw $t0, 0($k0)
		
	
	#print min, max and median
	addi $k0, $zero, 0	#getting address for the strings
	lui  $k0, 0x1001
	
	addi $v0, $zero, 4	#print first string
	addi $a0, $k0, 4
	syscall
	
	addi $v0, $zero, 1	#print min
	addi $a0, $t0, 0
	syscall
	
	addi $v0, $zero, 4	#print second string
	addi $a0, $k0, 12
	syscall
	
	addi $v0, $zero, 1	#print max
	addi $a0, $t1, 0
	syscall
	
	addi $v0, $zero, 4	#print third string
	addi $a0, $k0, 20
	syscall
	
	addi $v0, $zero, 1	#print median
	addi $a0, $t2, 0
	syscall
	
	addi $v0, $zero, 10	#END
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
	


