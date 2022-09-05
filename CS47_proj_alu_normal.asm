.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
	beq $a2, '+', add_normal
	beq $a2, '-', sub_normal
	beq $a2, '*', mul_normal 
	beq $a2, '/', div_normal
add_normal:
	add 	$v0, $a0, $a1
	j 	end
sub_normal:
	sub 	$v0, $a0, $a1
	j 	end
mul_normal:
	mul 	$v0, $a0, $a1
	mfhi	$v1
	mflo	$v0
	j 	end
div_normal:
	div 	$v0, $a0, $a1
	rem	$v1, $a0, $a1
	j	end
end:
	jr	$ra
