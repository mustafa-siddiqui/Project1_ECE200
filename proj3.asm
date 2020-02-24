.data
length:  .word 10
min:  .word 0
max:  .word 0
median:  .word 0
nums:  .word 92, 31, 92, 6, 54, 54, 62, 33, 8, 52
temp:  .word 0:10
.text

main:
	# first we need to get access to our data
lui $s0, 0x1001		# 
ori $s0, $s0, 0		# s0 now contains the address of length
addi $k0, $s0, 16	# k0 now conatins the address of nums
addi $k1, $s0, 56	# k1 now contains the address of temp
lw $s0, 0($s0)		# s0 now contains length

#setting parameters for merge sort call
addi $a0, $zero, 0
addi $a1, $s0, -1

#sort
## Call merge sort function here. I won't copy paste it until it has been optimized

lw $t0, 0($k0)
addi $s0, $s0, -1 ###optimize this line
sll $t1, $s0, 2
add $t1, $t1, $k0
lw $t1, 0($t1)
srl $t2, $s0, 1
sll $t2, $t2, 2
add $t2, $t2, $k0
lw $t2, 0($t2)

addi $k0, $k0, -4
sw $t2, 0($k0)

addi $k0, $k0, -4
sw $t1, 0($k0)

addi $k0, $k0, -4
sw $t0, 0($k0)


