.include "./cs47_proj_macro.asm"
.data
mask:	.word 0x1
.text
.globl au_logical

# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
# TBD: Complete it:
	frameStore
	
	# determines with operation to perform
	beq	$a2, '+', add_logical
	beq	$a2, '-', sub_logical
	beq	$a2, '*', mul_logical_signed
	beq 	$a2, '/', div_logical_signed
add_logical:
	li $a2, 0x00000000
	j	add_sub_logical
	
sub_logical:
	li	$t9, '-'
	bne 	$t9, $a2, add_sub_logical # if the operation is positive, jump
	move 	$s0, $a0		  # stores original value of $a0 into $s0
	move	$a0, $a1		  # stores $a1 into $a0
	jal	twos_complement 	  # finds the twos complement of the 2nd number
	move 	$a0, $s0		
	move	$a1, $v0
	j	add_sub_logical
	
twos_complement:
	frameStore
	not	$a0, $a0	
	li	$a1, 0
	li $a2, 0x00000000
	jal	au_logical	
	frameRestore
	jr	$ra
	
twos_complement_if_neg:	
	frameStore
	bltz	$a0, twos_complement	
	move	$v0, $a0
	frameRestore 
	jr	$ra
twos_complement_64bit:
	frameStore
	not	$a0, $a0	# inverse of a0
	not	$a1, $a1	# inverse of a1 
	move	$s0, $a1	# saves the original value of a1
	li	$a1, 1
	jal	add_logical	# add 1 to $a0
	move	$a0, $s0
	move	$a1, $v1
	move	$s1, $v0
	jal	add_logical	# add carry to $a1
	move	$v1, $v0
	move	$v0, $s1
	frameRestore
	jr	$ra
bit_replicator:
	frameStore
	blt	$a0, 0x1, negative_one_filler	# if a0 if negative, jump
	li	$v0, 0x00000000			# fill with zero's if $a0 is positive 
	frameRestore
	jr	$ra
negative_one_filler:
	li	$v0, 0xFFFFFFFF			
	frameRestore
	jr	$ra
add_sub_logical:
	li	$t0, 0			 # sets counter $t0 = 0 (i)
	extract_nth_bit($v1, $a2, $zero) # sets the carry out bit
	j	add_loop_main
add_loop_main:
	beq	$t0, 32, end		 # if the counter is 32, end
	extract_nth_bit($t4, $a0, $t0)	 # $t4 is the value where i is in a0
	extract_nth_bit($t5, $a1, $t0)	 # $t5 is the value where i is in a1
	xor 	$t6, $t4, $t5		 # $t6 = XOR A B
	xor	$t2, $v1, $t6 		 # $t2 XOR with C = Y
	and	$t7, $t4, $t5		 # should set $t7 = $t4 AND $t5
	and	$t8, $v1, $t6
	or	$v1, $t7, $t8	
	insert_to_nth_bit($v0, $t0, $t2, $t3)
	addi	$t0, $t0, 1		 # increments i by 1
	j	add_loop_main
	
mul_logical_unsigned:
	frameStore
	li	$t0, 32		# sets counter $t0 = 32 (i)
	li	$s0, 0		# $s0 = H
	move	$s0, $a0	# M = $s0 = multiplicand
	move	$s1, $a1	# L = $s1 = multiplier
	li	$t6, 0
mul_unsigned_loop:
	beq	$t0, 0, mul_unsigned_end	# if counter is 32, end
	extract_nth_bit($t1, $s1, $t6)	# $t2 = L[0]
	move	$a0, $t2			
	jal 	bit_replicator			# replicate L[0]
	move	$t2, $v0			# R = bit replicator  L[0]
	and	$t3, $s0, $t2		# X = M & R	
	move	$a0, $s0			
	move	$a1, $t3			
	jal	add_sub_logical			# adds H and X
	move	$s0, $v0			# H = H + X
	srl	$s1, $s1, 1			# L = L >> 1
	extract_nth_bit($t4, $s0, $t6)		# $t4 = H[0]
	li	$t5, 31
	insert_to_nth_bit($s1, $t5, $t4, $t7)	# L[31] = H[0]
	srl	$s0, $s0, 1			# H = H >> 1
	addi	$t0, $t0, -1			# increments i by 1
	j	mul_unsigned_loop
	
mul_logical_signed:
	bne	$t3, 1, end
	frameStore
	li	$s0, 0
	li	$s4, 31
	move	$s1, $a0		# N1 = $a0
	move	$s2, $a1		# N2 = $a1
	move	$s3, $a0		# sets aside og value of $a0
	move	$s4, $a1		# sets aside og value of $a1 
	jal	twos_complement_if_neg	# determines if N1 is negative
	move	$s1, $v0		# updates 2's complement of N1
	move	$a0, $s2		# $a0 = N2
	jal	twos_complement_if_neg	# determines if N2 is negative
	move	$s2, $v0		# updates 2's complement of N2
	move	$a0, $s1		
	move	$a1, $s2
	jal	mul_logical_unsigned	# finds multiplication of N1 and N2
	move	$a0, $v0
	move	$a1, $v1
	extract_nth_bit($s1, $s3, $s4) 	# extracts $a0[31]
	extract_nth_bit($s2, $s4, $s4)  # extracts $a1[31]
	xor $s3, $s1, $s2 		# S, XOR $a0[31], $a1[31]
	jal twos_complement_64bit
	frameRestore
	
mul_unsigned_end:
	move	$v0, $s1	# v0 = Lo
	move	$v1, $s0	# v1 = Hi
	frameRestore
	jr	$ra
div_logical_unsigned:
	frameStore
	li	$t0, 0		# t0 increment i
	move 	$s0, $a0	# s0 = Q 
	move 	$s1, $a1	# s1 = D 
	move	$s2, $zero	# s2 = remainder R
	li	$t4, 31
div_unsigned_loop:
	beq 	$t0, 32, div_unsigned_end
	sll	$s2, $s2, 1		# R = R << 1
	extract_nth_bit($t1, $s0, $t4)	# t1 = Q[31] MSB
	insert_to_nth_bit($s2, $zero, $t1, $t2)	# R[0] = Q[31]
	sll	$s0, $s0, 1		# Q = Q << 1
	move	$a0, $s2
	move	$a1, $s1
	jal	sub_logical	# S = R - D
	bltz	$v0, div_resume	# is S negative
	move 	$s3, $v0        # moves $v0 to so $s3 to be S
	li	$t3, 1
	insert_to_nth_bit($s0, $zero, $t3, $t2) # Q[0] = 1
div_resume:
	addi	$t0, $t0, 1
	j	div_unsigned_loop
div_logical_signed:
	frameStore
	move	$s0, $a0   # N1 = $a0
	move 	$s1, $a1   # N2 = $a1
	move	$s2, $a0   # keeping aside original value of $a0
	move	$s2, $a1   # keeping aside original value of $a1
	li	$t1, 31
	jal	twos_complement_if_neg 	# check if N1 is negative
	move	$s0, $v0 # moves the 2's complement of N1 --> $s0
	move	$a0, $s1		# moves N2 to $a0 
	jal	twos_complement_if_neg	# checks if N2 is negative 
	move 	$s1, $v0 # moves the 2's complement of N2 --> $s1
	move	$a0, $s0
	move	$a1, $s1
	jal	div_logical_unsigned  # unsigned divison with N1 & N2
	move 	$s4, $v0	# stores Q
	move	$s5, $v1	# stores R
	extract_nth_bit($t0, $s2, $t1)	# extracts $a0[31]
	extract_nth_bit($t2, $s3, $t1)	# extracts $a1[31]
	xor	$t3, $t0, $t2		# S
	beq	$t3, 1, div_neg	 # if S is 1, jump to negative 
	extract_nth_bit($t4, $s2, $t1)	# extract $a0[31] and gives it to S
	bne	$t4, 1, div_signed_end	# if S is one jump to end
	move	$a0, $s5
	jal	twos_complement  # finds the complement of R
	move	$s5, $v0	 # two's complement of R is stored
	j	div_unsigned_end
div_neg:
	move	$a0, $s4		# moves Q into $a0
	jal	twos_complement		# finds twos complement of Q
	j	div_signed_end
div_unsigned_end:
	move	$v0, $s0	# v0 = Q
	move	$v1, $s2	# v1 = R
	frameRestore
	jr	$ra
div_signed_end:
	move	$v0, $s4	# v0 = Q
	move 	$v1, $s5	# v1 = R
	frameRestore
	jr	$ra
end:	
	frameRestore
	jr	$ra


