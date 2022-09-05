# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#

		#regD: contain 0x0 or 0x1 depending on nth bit being 0 or 1
		#regS: source bit pattern
		#regT bit poisiton n (0-31), be 0x0 or 0x1
        # extracts the nth bit from the pattern given
        .macro extract_nth_bit($bit, $bitPattern, $nthPosition)
        move	$s1, $bitPattern
        srav	$s1, $s1, $nthPosition
        andi	$bit, $s1, 1
        .end_macro     
     
		# regD: bit pattern in which 1 to be inserted at nth position 
		# regS: value n, from position the bit to be inserted (0-31)
		# regT register that contains 0x1 or 0x0 (bit value to insert)
		# maskReg: register to hold temporary mask
        # inserts a bit in the nth bit in a given bit pattern
        .macro  insert_to_nth_bit($bitPattern, $nthPosition, $bit, $mask)
        li	$mask, 1
        sllv	$mask, $mask, $nthPosition
        not	$mask, $mask
        and	$bitPattern, $bitPattern, $mask
        sllv	$bit, $bit, $nthPosition
        or	$bitPattern, $bit, $bitPattern	
        .end_macro
        
        # creates and stores frame, RTE
        .macro frameStore
        addi	$sp, $sp, -56
	sw	$fp, 56($sp)
	sw	$ra, 52($sp)
	sw	$a0, 48($sp)
	sw	$a1, 44($sp)
	sw	$a2, 40($sp)
	sw	$s0, 36($sp)
	sw	$s1, 32($sp)
	sw	$s2, 28($sp)
	sw	$s3, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7,  8($sp)
	addi	$fp, $sp, 56
	.end_macro
	
	# restores frames, RTE
	.macro	frameRestore
	lw	$fp, 56($sp)
	lw	$ra, 52($sp)
	lw	$a0, 48($sp)
	lw	$a1, 44($sp)
	lw	$a2, 40($sp)
	lw	$s0, 36($sp)
	lw	$s1, 32($sp)
	lw	$s2, 28($sp)
	lw	$s3, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7,  8($sp)
	addi	$sp, $sp, 56
	.end_macro
	
