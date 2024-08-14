.data
	input_msg:	.asciiz "Please input a number: "
	output_msg:	.asciiz "The result of fibonacci(n) is "
	newline: 	.asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg		# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a0, $v0      		# store input in $a0 (set arugument of procedure fibonacci)

# jump to procedure fibonacci
	jal 	fibonacci
	move 	$t0, $v0			# save return value in t0 (because v0 will be used by system call) 

# print output_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
	syscall                 	# run the syscall

# print the result of procedure fibonacci on the console interface
	move 	$a0, $t0			# move value of integer into $a0
	li 		$v0, 1				# call system call: print int
	syscall 					# run the syscall

# print a newline at the end
	li		$v0, 4				# call system call: print string
	la		$a0, newline		# load address of string into $a0
	syscall						# run the syscall

# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall

#------------------------- procedure factorial -----------------------------
# load argument n in $a0, return value in $v0. 
.text
fibonacci:	
	addi 	$sp, $sp, -12		# adiust stack for 3 items
	sw 		$ra, 8($sp)			# save the return address
	sw 		$s1, 4($sp)			# save the f(n-1)
	sw 		$s0, 0($sp)			# save the argument n

	li		$v0, 0
	beq		$a0, 0, End
	
	li 		$v0, 1
	move	$s0, $a0			# save the argument n
	slti	$t1, $a0, 2
	bne 	$t1, $zero, End

	addi	$a0, $a0, -1		# n = n - 1
	jal fibonacci
	move 	$s1, $v0

	addi	$a0, $s0, -2		# n = n - 2
	jal fibonacci

	add		$v0, $v0, $s1		# f(n) = f(n-2) + f(n-1) 	
	
End:		
	lw 		$ra, 8($sp)			# store the return address
	lw 		$s1, 4($sp)			# store the argument n-1
	lw 		$s0, 0($sp)			# store the argument n
	addi 	$sp, $sp, 12		# adiust stack for 3 items
	jr 		$ra					# return to the caller