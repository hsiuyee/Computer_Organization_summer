.data
	input_msg:	.asciiz "Please input a number: "
	output_msg1:	.asciiz "It's a prime\n"
	output_msg2:	.asciiz "It's not a prime\n"
	newline: 	.asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg		# load address of string into $a0
	syscall                 	# run the syscall
 
# scanf("%d", &n);
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a0, $v0      		# store input in $a0 (set arugument of prime test)

# jump to procedure prime
	jal 	prime
	move 	$t0, $v0			# save return value in t0 (because v0 will be used by system call) 

# print output_msg on the console interface
	bne 	$t0, $zero, primeOutput # prime
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg2	# load address of string into $a0
	syscall                 	# run the syscall
	j End

primeOutput:
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg1	# load address of string into $a0
	syscall                 	# run the syscall

End:
# print a newline at the end
#	li		$v0, 4				# call system call: print string
#	la		$a0, newline		# load address of string into $a0
#	syscall						# run the syscall
# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall

#------------------------- procedure prime -----------------------------
# load argument n in $a0, return value in $v0. 
.text
prime:	
	addi 	$sp, $sp, -8		# adiust stack for 2 items
	sw 		$ra, 4($sp)			# save the return address
	sw 		$a0, 0($sp)			# save the argument n
	slti 	$s0, $a0, 2			# test for n == 1
	addi 	$t1, $zero, 2 		# initial i = 2 as test factor
	bne 	$s0, 1, prime_test	# n >= 2
	beq 	$s0, 1, not_prime	# n <  2
	
not_prime:
	addi 	$v0, $zero, 0
	addi 	$sp, $sp, 8
	jr 		$ra

is_prime:
	addi 	$v0, $zero, 1
	addi 	$sp, $sp, 8
	jr 		$ra

prime_test:
	mul		$t0, $t1, $t1
	slt 	$t2, $a0, $t0			# check a0 < t1 * t1
	bne 	$t2, $zero, is_prime	# not factor

	div 	$a0, $t1				# reminder is store in HI register
	mfhi 	$t3						# take HI register data to $t3

	beq 	$t3, $zero, not_prime	# remainder == 0
	addi	$t1, $t1, 1				# i = i + 1
	j prime_test					# continue the loop