.data
	input_msg1:	.asciiz "Please enter option (1: add, 2: sub, 3: mul): "
	input_msg2:	.asciiz "Please enter the first number: "
	input_msg3:	.asciiz "Please enter the second number: "
	output_msg:	.asciiz "The calculation result is: "
	newline: 	.asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:

# printf("Please enter option (1: add, 2: sub, 3: mul): ");
# print input_msg1 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg1		# load address of string into $a0
	syscall                 	# run the syscall

# scanf("%d", &op);
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $t0, $v0      		# store input in $t0 (set arugument of option type)

# print input_msg2 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg2		# load address of string into $a0
	syscall                 	# run the syscall

# scanf("%d", &a);
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a1, $v0      		# store input in $a1 (set first arugument of calculator)

# print input_msg3 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg3		# load address of string into $a0
	syscall                 	# run the syscall

# scanf("%d", &b);
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a2, $v0      		# store input in $a2 (set first arugument of calculator)
	
# calculate ans, return v0
	beq 	$t0, 1, TYPE1
	beq 	$t0, 2, TYPE2
	beq 	$t0, 3, TYPE3

#------------------------- procedure calculator -----------------------------
# load argument n in $a0, $a1, return value in $v0. 
.text
TYPE1:	
	add 	$t1, $a1, $a2
	j 	End
TYPE2:		
	sub 	$t1, $a1, $a2
	j 	End
TYPE3:
	mul 	$t1, $a1, $a2
	j 	End
End:
# print output_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
	syscall                 	# run the syscall

# print the result of procedure factorial on the console interface
	li 		$v0, 1				# call system call: print int
	move 	$a0, $t1			# move value of integer into $a0
	syscall 					# run the syscall

# print a newline at the end
 	li		$v0, 4				# call system call: print string
 	la		$a0, newline		# load address of string into $a0
 	syscall						# run the syscall

# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall