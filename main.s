# Authors: Ben Keinan 302340831 | Yovel Ben Hamo 207222118 | Guy Shitrit 318298023
# Date: 15.04.2024
# Title: Project (Proposal 3)	| Filename: m.s


################# Data segment #####################
.data
# main messages
msgMenu:	.ascii	"\n\nThe options are:\n"
			"1. Enter a number (base 10)\n"
			"2. Replace a number (base 10)\n"
			"3. DEL a number (base 10)\n"
			"4. Find a number in the array (base 10)\n"
			"5. Find average (base 2-10)\n"
			"6. Find Max (base 2-10)\n"
			"7. Print the array elements (base 2-10)\n"
			"8. Print sort array (base 2-10)\n"
			"9. END\n"
		.asciiz	"\nPlease enter an option between 1-9: "
msgInvalid:	.asciiz "\nInvalid input.\nPlease enter again.\n"
msgEND:		.asciiz  "Goodbye!\n"
msgNumber: 	.asciiz "The number "
msgExist: 	.asciiz " already exists in the array in index "
msgNotExist: 	.asciiz " does not exist in the array"
msgFull:	.asciiz "The array is full.\n"
msgEmpty:	.asciiz "The array is empty.\n"
msgBase: 	.asciiz "In which base to print? "
msgIs:		.asciiz " is "

# add_number1 messages
msgAdd: 	.asciiz "What number to add? "
msgAdded:	.asciiz " was added to the array.\n"
# REPLACE2 messages
msgReplace1:	.asciiz "What number to replace? "
msgReplace2:	.asciiz "Replace the number "
msgReplace3:	.asciiz " (in index "
msgReplace4:	.asciiz ") with what number? "
msgReplaceDone: .asciiz "Replacement done!"
# DEL3 messages
msgDelete1:	.asciiz "What number to delete? "
msgDelete2:	.asciiz " has been deleted and the array is reduced."
# find4 messages
msgFind: 	.asciiz "What number to find? "
# average5 messages
msgAverage: 	.asciiz "The average in base "
# max6 messages
msgMax1: 	.asciiz "The maximum in base "
msgMax2: 	.asciiz " and is placed in index "
# print_array7 messages
msgPrintArray:	.asciiz "The array in base "

# variables and arrays
NUM:		.byte	0
array:		.word	0:30
array1:		.word	0:30
jump_table:	.word   invalid_input0, add_number1, REPLACE2, DEL3, find4,
		        average5, max6, print_array7, sort8, END9

################# Code segment #####################
.text
.globl main

#===================== Main Menu ===================
# Description: 	This program lets you make operations on an array of numbers.
#		The array starts empty and can fill up to 30 numbers.

main:
	la	$a0,msgMenu	# print msgMenu
	li	$v0, 4		# syscall 4: print string
	syscall
	li	$v0, 5		# syscall 5: read integer
	syscall
	li   	$t0, 0  	# $t0 = default case (wrong_input0)
	bgt  	$v0, 9 , case  	
	blt 	$v0, 1 , case	# if (input < 1 or 9 < input), default case
	sll  	$t0, $v0, 2  	# $t0 = case*4
case:
 	la   	$t1, jump_table 
	add  	$t1, $t1, $t0 	# $t1 = jump_table[case*4]
	lw 	$t0, ($t1) 	# $t0 = process label
	# Caller pre-call
	lb	$a1, NUM	# argument1: NUM
	la	$a2, array	# argument2: array address
	la	$a3, array1	# argument3: array1 address
	jalr    $t0             # call the process
	j       main


#===================== Case0: invalid_input ===================
# Description: 	This procedure prints an invalid input message.
invalid_input0:
	la 	$a0, msgInvalid	# print msgInvalid
	li	$v0, 4		# syscall 4: print string
	syscall
	jr	$ra
	
	
#===================== Case1: add_number ===================
# Description: 	This operation lets you add a number to the array.
add_number1:
	# Callee prologue
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	# Callee body
	beq	$a1, 30, ArrayFull	# if (NUM == 30), jump to 'ArrayFull'
	la 	$a0, msgAdd		# print msgAdd
	li	$v0, 4			# syscall 4: print string
	syscall
	li	$v0, 5			# syscall 5: read integer
	syscall
	
	# Procedure: CHECK
	# Caller pre-call
	# Pass arguments (argument1: NUM, argument2: array address)
	move 	$a3, $v0		# $a3 = input number
	jal    	CHECK10           	# call the process
	beq	$v0, -1, AddNum		# if (index == -1), jump to 'AddNum'
	
	# Number exists in array
	move 	$t1, $v0		# save index to $t1
	la 	$a0, msgNumber		# print msgNumber
	li 	$v0, 4			# syscall 4: print string
	syscall
	move 	$a0, $a3		# print input number
	li 	$v0, 1			# syscall 1: print integer
	syscall
	la 	$a0, msgExist		# print msgExist
	li	$v0, 4			# syscall 4: print string
	syscall
	move 	$a0, $t1		# print index
	li 	$v0, 1			# syscall 1: print integer
	syscall
	j 	Exit_Add_Number		# jump to Exit_Add_Number
	
	AddNum: # Number doesn't exist in array
		sll 	$t1, $a1, 2		# $t1 = NUM*4 (for address)
		add 	$t1, $t1, $a2		# $t1 = array[NUM*4]
		sw 	$a3, ($t1)		# array[NUM*4] = input number ($a3)
		add 	$a1, $a1, 1 		# NUM++
		sb 	$a1, NUM		# Update NUM
		
		move 	$a0, $a3		# print input number
		li	$v0, 1			# syscall 1: print integer
		syscall
		la 	$a0, msgAdded		# print msgAdded
		li 	$v0, 4			# syscall 4: print string
		syscall
		j Exit_Add_Number		# jump to Exit_Add_Number
	
	ArrayFull: # Array is full
		la $a0, msgFull			# print msgFull
		li $v0, 4			# syscall 4: print string
		syscall		

	Exit_Add_Number: # Callee epilogue
		lw 	$ra, 0($sp)
		addiu	$sp, $sp, 4
    		jr      $ra
	  
	  
#===================== Case2: REPLACE ===================
# Description: 	This operation replaces a number that exists in the array.
REPLACE2:
	# Callee prologue
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	# Callee body
	beq	$a1, 0, Replace_Empty	# if (NUM == 0), jump to 'Replace_Empty'
 	la	$a0,msgReplace1		# print msgReplace1
	li 	$v0, 4			# syscall 4: print string
 	syscall
	li	$v0, 5			# syscall 5: read integer
	syscall
 
 	# Procedure: CHECK
	# Caller pre-call
	# Pass arguments (argument1: NUM, argument2: array address)
	move 	$a3, $v0		# $a3 = input number
	jal    	CHECK10           	# call the process
 	beq  	$v0,-1,Replace_Not_Exist	# if (number not in the array), jump to 'Replace_Not_Exist'
	
 	# in array
 	move 	$t2, $v0		# save index to $t2
 	la	$a0,msgReplace2		# print msgReplace2
	li 	$v0, 4			# syscall 4: print string
	syscall 
	move 	$a0,$a3 		# print the number to replace
	li	$v0, 1			# syscall 1: print integer
	syscall
	la 	$a0,msgReplace3		# print msgReplace3
	li 	$v0, 4			# syscall 4: print string
	syscall
	move 	$a0,$t2			# print the index
	li 	$v0,1			# syscall 1: print integer
	syscall
	la 	$a0,msgReplace4		# print msgReplace4
	li 	$v0, 4			# syscall 4: print string
	syscall 
	li	$v0, 5			# syscall 5: read integer
	syscall
	
	# Procedure: CHECK
	# Caller pre-call
	# Pass arguments (argument1: NUM, argument2: array address)
	move 	$a3, $v0		# $a3 = input number
	jal    	CHECK10           	# call the process
 	bne 	$v0, -1, Replace_Exist	# if (number in the array), jump to 'Replace_Exist'
 	
 	# replace
	sll 	$t2, $t2, 2		# $t2 = index*4 (for address)
	add 	$t2, $t2, $a2		# $t2 = array[index*4]
	sw 	$a3, ($t2)		# array[index*4] = input number ($a3)
	la 	$a0, msgReplaceDone	# print msgReplaceDone
	li 	$v0, 4			# syscall 4: print string
	syscall
	j	Exit_Replace
 
	Replace_Exist:
		la 	$a0,msgNumber	# print msgNumber
		li	$v0,4		# syscall 4: print string
		syscall
		move	$a0,$a3		# print input number
		li 	$v0,1		# syscall 1: print integer
		syscall
		la 	$a0,msgExist	# print msgExist
		li	$v0,4		# syscall 4: print string
		syscall
		move	$a0,$t1		# print number index
		li 	$v0,1		# syscall 1: print integer
		syscall
		j	Exit_Replace 
  
	Replace_Not_Exist:  # not in array
		la 	$a0,msgNumber	# print msgNumber
		li	$v0,4		# syscall 4: print string
		syscall
		move	$a0,$a3		# print input number
		li 	$v0,1		# syscall 1: print integer
		syscall
		la 	$a0,msgNotExist	# print msgNotExist
		li	$v0,4		# syscall 4: print string
		syscall
		j Exit_Replace		# jump to Exit_Replace
	
	Replace_Empty: # Array is empty
		la $a0, msgEmpty		# print msgEmpty
		li $v0, 4			# syscall 4: print string
		syscall	
			
 	Exit_Replace: # Callee epilogue
		lw 	$ra, 0($sp)
		addiu	$sp, $sp, 4
    		jr      $ra
      
      
#===================== Case3: DEL ===================
# Description: 	This operation deletes a number that exists in the array.  
DEL3:
	# Callee prologue
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	# Callee body
	beq	$a1, 0, Delete_Empty	# if (NUM == 0), jump to 'Delete_Empty'
 	la	$a0,msgDelete1		# print msgDelete1
	li 	$v0, 4			# syscall 4: print string
 	syscall
	li	$v0, 5			# syscall 5: read integer
	syscall
 
 	# Procedure: CHECK
	# Caller pre-call
	# Pass arguments (argument1: NUM, argument2: array address)
	move 	$a3, $v0		# $a3 = input number
	jal    	CHECK10           	# call the process
 	move 	$t2, $v0 	# t2 is temp hold the index from check
	
	# Print the number
	la 	$a0,msgNumber	# print msgNumber
	li	$v0,4		# syscall 4: print string
	syscall
	move	$a0,$a3		# print input number
	li 	$v0,1		# syscall 1: print integer
	syscall
 	beq  	$t2,-1,Delete_Not_Exist	# if (number not in the array), jump to 'Delete_Not_Exist'

 	# Procedure: reduction
	# Caller pre-call
	# Pass arguments (argument1: NUM, argument2: array address)
	move 	$a3, $t2		# $a3 = input number index
	jal    	reduction11          	# call the process
 	
 	# in array
	la 	$a0,msgDelete2	# print msgDelete2
	li	$v0,4		# syscall 4: print string
	syscall
 	j	Exit_Delete 

	Delete_Not_Exist:  # not in array
		la 	$a0,msgNotExist	# print msgNotExist
		li	$v0,4		# syscall 4: print string
		syscall
		j Exit_Delete		# jump to Exit_Delete
	
	Delete_Empty: # Array is empty
		la $a0, msgEmpty		# print msgEmpty
		li $v0, 4			# syscall 4: print string
		syscall	
			
 	Exit_Delete: # Callee epilogue
		lw 	$ra, 0($sp)
		addiu	$sp, $sp, 4
    		jr      $ra
       
       
#===================== Case4: find ===================
# Description: 	This operation finds a number in the array.   
find4:
	# Callee prologue
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	# Callee body
	la	$a0,msgFind	# print msgFind
	li	$v0,4		# syscall 4: print string
	syscall
	li 	$v0,5		# syscall 5: read integer
	syscall			

	# Procedure: CHECK
	# Caller pre-call
	# Pass arguments (argument1: NUM, argument2: array address)
	move 	$a3, $v0	# $a3 = input number
	jal    	CHECK10         # call the process
 	move 	$t1, $v0 	# t1 is temp hold the index from check
	
	# Print message
	la 	$a0,msgNumber	# print msgNumber
	li	$v0,4		# syscall 4: print string
	syscall
	move	$a0,$a3		# print input number
	li 	$v0,1		# syscall 1: print integer
	syscall
	bne 	$t1, -1, Find_Exists	# if (number in the array), jump to 'Find_Exists'
	
	# not in array:
	la 	$a0,msgNotExist	# print msgNotExist
	li	$v0,4		# syscall 4: print string
	syscall
	j 	Exit_Find 
	
	Find_Exists:
		la 	$a0,msgExist	# print msgExist
		li	$v0,4		# syscall 4: print string
		syscall
		move 	$a0,$t1 	# print index
		li 	$v0,1		# syscall 1: print integer
		syscall

	Exit_Find: # Callee epilogue
 		lw 	$ra, 0($sp)
		addiu 	$sp, $sp, 4
    		jr      $ra
        
        
#===================== Case5: average ===================
# Description: 	This operation returns the avergae of the array. 
average5: 
	# Callee prologue
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	# Callee body	
	beq	$a1, 0, Average_Empty	# if (NUM == 0), jump to 'Average_Empty'
	li	$t1, 0			# counter=0
	li	$t3, 0			# sum=0
	
	ArraySum:
		sll	$t2, $t1, 2		# $t2 = counter*4 (for address)
		add	$t2, $t2, $a2		# $t2 = array[counter*4]
        	lw	$t2, ($t2) 		# $t2 = the number array[counter*4]
        	add	$t3, $t3 ,$t2		# sum ++
           	add	$t1,$t1 ,1      	# counter ++
           	bne 	$t1,$a1,ArraySum	# Loop while counter!=NUM
        
        # average: sum/NUM
	div 	$t3,$a1			# sum/NUM
	mflo 	$a1     		# $a1 = average (base 10)
	
	Average_Base:
		la	$a0,msgBase		# print msgBase
		li 	$v0, 4			# syscall 4: print string
 		syscall
		li	$v0, 5			# syscall 5: read integer
		syscall

		# check valid base(2-10)
		blt  	$v0, 2 , Average_Invalid  	
		bgt 	$v0, 10 , Average_Invalid	# if (input < 2 or 10 < input), jump to 'Average_Invalid'
		
	Average_Print:
		move 	$a2, $v0 		# save base to $a2
		la	$a0,msgAverage		# print msgAverage
		li 	$v0, 4			# syscall 4: print string
 		syscall
 		move 	$a0, $a2 		# print base
		li 	$v0,1			# syscall 1: print integer
		syscall
 		la	$a0,msgIs		# print msgIs
		li 	$v0, 4			# syscall 4: print string
 		syscall
 		
	# Procedure: print_num
	# Caller pre-call
	# Pass arguments (argument1: average, argument2: base)
	jal    	print_num12           	# call the process
	j 	Exit_Average		# jump to Exit_Average
	
	Average_Invalid:
		# Procedure: invalid_input0
		# Caller pre-call
		jal    	invalid_input0    # call the process
		j	Average_Base	# ask base again
		
	Average_Empty: # Array is empty
		la $a0, msgEmpty		# print msgEmpty
		li $v0, 4			# syscall 4: print string
		syscall	
		
	Exit_Average: # Callee epilogue
 		lw 	$ra, 0($sp)
		addiu 	$sp, $sp, 4
    		jr      $ra
    		
    		
#===================== Case6: max ===================
# Description: 	This operation returns the max number in the array.    
max6:
	# Callee prologue
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	# Callee body
	beq	$a1, 0, Max_Empty	# if (NUM == 0), jump to 'Max_Empty'
	li	$t0, 0			# counter=0
 	lw 	$t2,($a2)  		# t2 = max (first number)
 	addi 	$t0,$t0,1 		# counter++
	ArrayMax:
		sll	$t1, $t0, 2		# $t1 = counter*4 (for address)
		add	$t1, $t1, $a2		# $t1 = array[counter*4]
           	lw 	$t3,($t1)  		# $t3 = iteration number in array
           	blt 	$t3,$t2, Max_Skip	# if (iteration < max), skip
           	move 	$t2,$t3          	# $t2 = iteration number (new max)
           	move	$t4,$t0			# $t4 = new max index
           	Max_Skip:
           		add 	$t0,$t0,1          	# counter++
           		bne $t0,$a1,ArrayMax 		# loop (while counter != NUM)
	move	$a1, $t2			# save max to $a1
	
	Max_Base:
		la	$a0,msgBase		# print msgBase
		li 	$v0, 4			# syscall 4: print string
 		syscall
		li	$v0, 5			# syscall 5: read integer
		syscall

		# check valid base(2-10)
		blt  	$v0, 2, Max_Invalid  	
		bgt 	$v0, 10, Max_Invalid	# if (input < 2 or 10 < input), jump to 'Max_Invalid'
	
	Max_Print:
		move 	$a2, $v0 		# save base to $a2
		la	$a0, msgMax1		# print msgMax1
		li 	$v0, 4			# syscall 4: print string
 		syscall
 		move 	$a0, $a2 		# print base
		li 	$v0,1			# syscall 1: print integer
		syscall
 		la	$a0,msgIs		# print msgIs
		li 	$v0, 4			# syscall 4: print string
 		syscall
 		
	# Procedure: print_num
	# Caller pre-call
	# Pass arguments (argument1: max, argument2: base)
	jal    	print_num12           	# call the process
	
	# print index
	la	$a0, msgMax2		# print msgMax2
	li 	$v0, 4			# syscall 4: print string
 	syscall
 	move 	$a0, $t4 		# print index
	li 	$v0,1			# syscall 1: print integer
	syscall
	j 	Exit_Max		# jump to Exit_Max
			
	Max_Invalid:
		# Procedure: invalid_input0
		# Caller pre-call
		jal    	invalid_input0    # call the process
		j	Max_Base	  # ask base again
		
	Max_Empty: # Array is empty
		la $a0, msgEmpty		# print msgEmpty
		li $v0, 4			# syscall 4: print string
		syscall
		
	Exit_Max: # Callee epilogue
 		lw 	$ra, 0($sp)
		addiu 	$sp, $sp, 4
    		jr      $ra


#===================== Case7: Print_Array ===================
# Description: 	This operation prints the array in a requested base(2-10). 
print_array7:
	# Callee prologue
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	# Callee body
	beqz 	$a1, Print_Array_Empty		# if (NUM == 0), jump to 'Print_Array_Empty'
	# Save arguments for print num loop:
 	li 	$t1,0 				# $t1 = counter
 	move 	$t3,$a1 			# $t3 = NUM
 	move 	$t4,$a2 			# $t4 = array address
 	
	Print_Array_Base:
		la	$a0,msgBase			# print msgBase
		li 	$v0, 4				# syscall 4: print string
 		syscall
		li	$v0, 5				# syscall 5: read integer
		syscall

		# check valid base(2-10)
		blt  	$v0, 2, Print_Array_Invalid  	
		bgt 	$v0, 10, Print_Array_Invalid	# if (input < 2 or 10 < input), jump to 'Print_Array_Invalid'
	
	Print_Array_Print:
		move 	$a2, $v0 			# save base to $a2
		la	$a0, msgPrintArray		# print msgPrintArray
		li 	$v0, 4				# syscall 4: print string
 		syscall
 		move 	$a0, $a2 			# print base
		li 	$v0,1				# syscall 1: print integer
		syscall
 		la	$a0,msgIs			# print msgIs
		li 	$v0, 4				# syscall 4: print string
 		syscall
 	
	Print_Array_Loop:
 		sll 	$t2, $t1, 2 			# $t2 = counter*4 (for address)
 		add 	$t2, $t2, $t4 			# $t2 = array[counter*4]
 		lw 	$a1, ($t2) 			# $a1 = iteration number in array
 	
		# Procedure: print_num
		# Caller pre-call
		# Pass arguments (argument1: iteration number, argument2: Base to print)
		jal     print_num12          		# call the process
		addi 	$t1,$t1,1 			# counter++
		beq 	$t1, $t3, Exit_Print_Array	# if (counter == NUM), jump to 'Exit_Print_Array'
		
		la 	$a0,','				# print comma for seperation
 		li 	$v0,11				# syscall 11: print char
 		syscall
 		j 	Print_Array_Loop
 		
 	Print_Array_Invalid:
		# Procedure: invalid_input0
		# Caller pre-call
		jal    	invalid_input0    # call the process
		j	Print_Array_Base	# ask base again
		
 	Print_Array_Empty:
		la $a0, msgEmpty		# print msgEmpty
		li $v0, 4			# syscall 4: print string
		syscall

        Exit_Print_Array: 	# Callee epilogue
 		lw 	$ra, 0($sp)
		addiu 	$sp, $sp, 4
    		jr      $ra
    	
    	
#===================== Case8: sort ===================
# Description: 	This operation prints a sorted array from small to big. 
sort8:
	# Callee prologue
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	# Callee body
	beqz 	$a1, Sort_Empty		# if (NUM == 0), jump to 'Sort_Empty'
	li	$t0, 1			# $t0 = counter
	li 	$t5, 0			# $t5 = array1 counter
	lw 	$t1, ($a2)		# $t1 = first number in array, array min
	move 	$t2, $t1		# $t2 = array max
	
	First_Min_Max:
		sll 	$t3, $t0, 2 		# $t3 = counter*4 (for address)
 		add 	$t3, $t3, $a2 		# $t3 = array[counter*4]
 		lw 	$t3, ($t3) 		# $t3 = iteration number in array
 		
 		bge	$t3, $t1, Not_First_Min	# if (number >= iteration), jump to 'Not_First_Min'
 		move	$t1, $t3		# iteration min: min = $t3
 		Not_First_Min:
 			ble	$t3, $t2, Not_Max	# if (number <= iteration), jump to 'Not_Max'
 			move	$t2, $t3		# iteration max: max = $t3
 		Not_Max:
 			add	$t0, $t0, 1		# counter++
 			bne	$t0, $a1, First_Min_Max	# loop (while counter != NUM)
 	
 	Array_Add:
 		sll 	$t3, $t5, 2 		# $t3 = counter*4 (for address)
 		add 	$t3, $t3, $a3 		# $t3 = array1[counter*4]
 		sw 	$t1, ($t3) 		# $t3 = iteration number in array
 		beq	$t5, $a1, Sort_Print	# if (array1 counter == NUM), jump to 'Sort_Print'
 		
 		move 	$t4, $t1		# last min
 		move	$t1, $t2		# next min = max
		li 	$t0, 0			# $t0 = counter
 		Next_Min:
			sll 	$t3, $t0, 2 		# $t3 = counter*4 (for address)
 			add 	$t3, $t3, $a2 		# $t3 = array[counter*4]
 			lw 	$t3, ($t3) 		# $t3 = iteration number in array
 		
 			bge	$t3, $t1, Check_Next	# if (iteration >= next min), jump to 'Check_Next'
 			ble	$t3, $t4, Check_Next	# if (iteration <= last min), jump to 'Check_Next'
 			move	$t1, $t3		# iteration min: next min = $t3
 			Check_Next:
				add	$t0, $t0, 1		# counter++
 				bne	$t0, $a1, Next_Min	# loop (while counter != NUM)
 				add	$t5, $t5, 1		# array1 counter++
 				j	Array_Add
 			
 	Sort_Print:
 		move $a2, $a3
 		# Procedure: print_array7
		# Caller pre-call
		jal    	print_array7    # call the process
		j	Exit_Sort		

	Sort_Empty:
		la $a0, msgEmpty		# print msgEmpty
		li $v0, 4			# syscall 4: print string
		syscall

	Exit_Sort: 	# Callee epilogue
 		lw 	$ra, 0($sp)
		addiu 	$sp, $sp, 4
    		jr      $ra
    		
    		
#===================== Case9: END ===================
# Description: 	This operation closes the program. 
END9: 
	la 	$a0, msgEND	# print msgEND
	li	$v0, 4		# syscall 4: print string
	syscall        
        li      $v0,10		# syscall 10: exit program
        syscall
        
        
#===================== Case10: CHECK ===================
# Description: 	This operation checks if a number exists in the array.
#		Returns ($v0): the index if the number exists in the
#		array, else returns '-1'.
CHECK10:
	# Callee prologue
	addiu	$sp, $sp, -8
	sw	$t1, 4($sp)
	sw	$t2, 0($sp)
	
	# Callee body
	li 	$t1, 0			# t1 is Counter Index
	beq 	$a1, 0, Check_False	# if (NUM == 0), jump to 'False'
    	Check:
	    	sll 	$t2,$t1,2		# $t2 = index*4 (for address)
    		add 	$t2,$t2,$a2  		# $t2 = array[index*4]
    		lw 	$t2,($t2) 		# $t2 = array number
    		beq 	$t2,$a3,Check_True	# if (input number already in array), jump to 'Check_True'
   		addi 	$t1,$t1,1	
    		bne 	$t1,$a1,Check	# if (index != NUM), continue loop
    	Check_False:
    		li 	$v0, -1
    		j 	Exit_Check
   	Check_True: # Find the same number in array
    		move 	$v0, $t1
    		
    	Exit_Check: # Callee epilogue
		lw 	$t2, 0($sp)
		lw 	$t1, 4($sp)
		addiu	$sp, $sp, 8
		jr      $ra


#===================== Case11: reduction ===================
# Description: 	This operation erases a number from the array
#		and reduces the array gap.
reduction11:
	# Callee prologue
	addiu	$sp, $sp, -8
	sw	$t1, 4($sp)
	sw	$t2, 0($sp)
	
	# Callee body
	sll 	$t1,$a3,2 	# make index to word index 
	add 	$t1, $t1, $a2 	# $t1 point address what we need to del
	reduction_loop:
		lw 	$t2,4($t1) 	# $t2 is the word to fill
		sw	$t2,($t1) 	# put the next word in the gap
		addi 	$t1,$t1,4 	# point to the next word
		addi 	$a3,$a3,1 	# +1 to index counter for the loop
		bne	$a3, $a1, reduction_loop
		sub 	$a1, $a1, 1 	# NUM-1
		sb 	$a1, NUM	# Update NUM
	
	# Callee epilogue
	lw 	$t2, 0($sp)
	lw 	$t1, 4($sp)
	addiu	$sp, $sp, 8
	jr      $ra
	
	
#===================== Case12: print_num ===================
# Description: 	This operation prints a number in a different base(2-10). 
print_num12:
	# Callee prologue
	addiu	$sp, $sp, -8
	sw	$t1, 4($sp)
	sw	$t2, 0($sp)
	
	# Callee body
	li	$t2, 0 			# $t2 = push_counter
	bgez	$a1, Base_Push		# if (0 <= number), jump to 'Base_Push'
	
	Negative:
		la 	$a0,'-'			# print minus
 		li 	$v0,11			# syscall 11: print char
 		syscall
		abs 	$a1,$a1			# absolute number
	
	Base_Push:
		div 	$a1,$a2
		mflo 	$a1			# $a1 = number after division
		mfhi 	$t1 			# $t1 = stock push
		addiu 	$sp,$sp, -4		
		sw 	$t1,($sp)		# push
		addiu	$t2,$t2,1 		# push_counter++
		bnez 	$a1, Base_Push		# loop (while $a1 != 0)
		
	Base_Pop:
		lw 	$a0,($sp)		# print pop
		li 	$v0,1			# syscall 1: print integer
	 	syscall
	 	addiu 	$sp,$sp, 4
 		addiu 	$t2,$t2 ,-1 		# push_counter--
 		bnez	$t2, Base_Pop		# # loop (while push_counter != 0)
 	
	# Callee epilogue
	lw 	$t2, 0($sp)
	lw 	$t1, 4($sp)
	addiu	$sp, $sp, 8
	jr      $ra
 
 
