.data
length:  .word 10
target:  .word 8
notfound: .asciiz "Target not found.  "
nums:  .word 1, 2, 3, 4 ,5, 6, 7, 8, 9, 10

.text
main:
# first we need to get access to our data
lui $s0, 0x1001		
ori $s0, $s0, 0		# s0 now contains the address of length (need to store this as r)
addi $s1, $s0, 4	# s1 now contains the address of target (need to store this as x
addi $t9, $s0, 28	# t9 now contains the address of the first element of the array
addi $s2, $s0, 8	# s2 now contains the address of the first character of the string 
lw $a1, 0($s0)		# a1 now contains r
lw $a2, 0($s1)		# a2 now contains x
addi $a0, $zero, 0
addi $a1, $a1, -1
sub $a1, $a1, $a0
Func:   # a0 = l a1 = r - l a2 = x t9 = pointer to arr
bltz $a1, returnno
srl $t1, $a1, 1 	# if branch is taken we don't need this result
add $t4, $t1, $a0 	# mid is now in t4
add $a1, $a1, $a0
sll $t1, $t4, 2 	# multiply by offset by 4
add $t2, $t1, $t9 
lw $t2, 0($t2)  	# arr[mid] is now in t2
nop
beq $t2, $a2, returnmid
sub $t3, $t2, $a2  	# t3 <- arr[mid]-x
bgtz $t3, returna
addi $t4, $t4, -1
addi $a0, $t4, 2 	# run func(mid+1, r, x)
j Func
sub $a1, $a1, $a0

returna:
addi $a1, $t4, 0 	# run func(l, mid -1, x)
j Func
sub $a1, $a1, $a0

returnmid:
addi $a0, $t4, 0
addi $v0, $zero, 1
syscall
# exiting
addi $v0, $zero, 10
syscall
returnno:
addi $v0, $zero, 4
add $a0, $zero, $s2
syscall
# exiting
addi $v0, $zero, 10
syscall


