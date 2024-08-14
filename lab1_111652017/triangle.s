.data
	input_msg1:	.asciiz "Please enter option (1: triangle, 2: inverted triangle): "
	input_msg2:	.asciiz "Please input a triangle size: "
	output_msg1:	.asciiz " "
	output_msg2:	.asciiz "*"
	newline: 	.asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg1 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg1		# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a1, $v0      		# store input in $a1 (set arugument of type1, type2)

# print input_msg2 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg2		# load address of string into $a0
	syscall                 	# run the syscall

# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a2, $v0      		# store input in $a2 (set arugument of size)

	addi	$s7, $zero, -1		# store i = -1

ForLoop: # for (int i = 0; i < n; i++) {
	addi	$s7, $s7, 1
	slt		$t1, $s7, $a2
	beq		$t1, $zero, End

	add		$t2, $zero, 1
	bne		$a1, $t2, print_layer1 	# a1 = 1
	beq		$a1, $t2, print_layer2	# a2 = 2
	j ForLoop

print_layer1:
	move	$s0, $a2			# s0 = n
	sub		$s1, $a2, $s7		# s1 = n - l
	addi	$s1, $s1, -1		# s1 = n - l - 1
	j		print_layer

print_layer2:
	move	$s0, $a2			# s0 = n
	move	$s1, $s7			# s1 = l
	j		print_layer


End:
# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall

#------------------------- procedure factorial -----------------------------
# load argument n in $a0, return value in $v0. 
.text
print_layer:	
	# print_layer1
	addi	$s2, $zero, 1		# s2 = j (= 1)
	sub		$s3, $s0, $s1		# s3 = n - l
	# print_layer2
	add		$s4, $s0, $s1		# s4 = n + l
	addi	$s4, $s4, 1			# s4 = n + l + 1

space:
	slt 	$t7, $s2, $s3		# j < n - l ?
	beq		$t7, $zero, star
	# print
	li		$v0, 4				# call system call: print string
	la		$a0, output_msg1	# load address of string into $a0
	syscall						# run the syscall
	addi	$s2, $s2, 1
	j space

star:
	slt 	$t7, $s2, $s4		# j < n + l + 1 ?
	beq		$t7, $zero, line
	# print
	li		$v0, 4				# call system call: print string
	la		$a0, output_msg2	# load address of string into $a0
	syscall						# run the syscall
	addi	$s2, $s2, 1
	j star

line:
	li		$v0, 4				# call system call: print string
	la		$a0, newline		# load address of string into $a0
	syscall						# run the syscall
	j ForLoop