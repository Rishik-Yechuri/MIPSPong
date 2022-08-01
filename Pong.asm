.data
#Stores data for program
.eqv WIDTH 64
.eqv HEIGHT 32

#Used for the bitmap
frameBuffer: 	.space 	0x80000	


.text

#Loads white into $a2
li $a2, 0x00FFFFFF  

#Saves Y position of left paddle
li $s3, 13         
li $s4, 13
 
#Saves Y position of right paddle
 li $s5,13
 li $s6,13
 #Initializes $t8,which is ussed to keep track of paddle size
li $t8, 0

#main:

	
#Erases left paddle
blackout:
#mul $t8,$t8,0
li $a2, 0x00000000 
#Erases one pixel as long as it hasn't reached bottom of paddle
blt $t8, 6 blackoutInner 
#Otherwise resets registers
beq $t8,6,moveBack

#Resets registers for left paddle
moveBack:
mul $t8,$t8,0
sub $s4,$s4,6
j blackoutRight

#Resets registers for right paddle
moveBackRight:
mul $t8,$t8,0
sub $s6,$s6,6
j loop

#Deletes one pixel from left paddle
blackoutInner:
li $a2, 0x00000000  
mul $t0,$t0,0
sll   $t0, $s4, 6       
addu  $t0, $t0, $s0      
sll   $t0, $t0, 2        
addu  $t0, $gp, $t0      
sw    $a2, ($t0)        
addi $s4, $s4, 1 
add $t8,$t8,1
j blackout

#Erases right paddle
blackoutRight:
li $a2, 0x00000000 
#If it hasn't reached bottom of paddle draws another pixel
blt $t8, 6 blackoutInnerRight 
#Otherwises resets registers
beq $t8,6,moveBackRight

#Erases one pixel from right paddle
blackoutInnerRight:
#Loads black into $a2
li $a2, 0x00000000  
mul $t0,$t0,0
sll   $t0, $s6, 6       
addu  $t0, $t0, 63      
sll   $t0, $t0, 2        
addu  $t0, $gp, $t0      
sw    $a2, ($t0)        
addi $s6, $s6, 1 
add $t8,$t8,1
j blackoutRight
#Draws left paddle
loop:
   blt $t8, 6 DrawPixel # while the head isnt in the first limit (100) draws a pixel in (s0,s1)
   beq $t8,6,refreshBetweenPaddles
#Does most of the calculations
mainLoop:
   	#Resets $t8
	mul $t8,$t8,0
		#Take input from keyboard
		lw 	$t0, 0xffff0000  
		#If there is no input keep going
    		beq 	$t0, 0, blackout   
	
		#Checks input
		lw 	$s1, 0xffff0004	
		#beq	$s1, 32, exit
		#W inputted, move left paddle up
		beq	$s1, 119, leftPaddleUp 	
		#S inputted, move left paddle down
		beq	$s1, 115, leftPaddleDown 	
		#O inputted, move right paddle up
		beq	$s1, 111, rightPaddleUp 
		#L inputted,move right paddle down	
		beq	$s1, 108, rightPaddleDown 	
	#Go to blackout
	j blackout
#Old coord moved to $s4, and $s3 is updated
leftPaddleUp:
add $s4,$s3,$0
sub $s3,$s3,1
j mainLoop
#Old coord moved to $s4, and $s3 is updated
leftPaddleDown:
add $s4,$s3,$0
add $s3,$s3,1
j mainLoop
#Old coord moved to $s6, and $s5 is updated
rightPaddleUp:
add $s6,$s5,$0
sub $s5,$s5,1
j mainLoop
#Old coord moved to $s6, and $s5 is updated
rightPaddleDown:
add $s6,$s5,$0
add $s5,$s5,1
j mainLoop

#Draws one pixel for left paddle
DrawPixel:
#Loads white into $a2
li $a2, 0x00FFFFFF 
#Resets $t0
mul $t0,$t0,0
#Draws one pixel and increases Y value by 1
sll   $t0, $s3, 6       
addu  $t0, $t0, $s0      
sll   $t0, $t0, 2        
addu  $t0, $gp, $t0      
sw    $a2, ($t0)         
addi $s3, $s3, 1 

#increases $t8, which storees number of pixels drawn
add $t8,$t8,1
j loop                   

#Resets $t8
refreshBetweenPaddles:
mul $t8,$t8,0
j loopRight

#Draws right paddle
loopRight:
   #Draws a pixel if it hasn't reached bottom of paddle
   blt $t8, 6 DrawPixelRight 
   #Otherwise pauses
   beq $t8,6,pause
  
#Draws one pixel for the right paddle
DrawPixelRight:
#Loads wwhite into $a2
li $a2, 0x00FFFFFF  
#Resets $t0
mul $t0,$t0,0

#Draws pixel and increases Y value by 1
sll   $t0, $s5, 6       
#Adds 63 to x value(To be on right side instead of left)
addu  $t0, $t0, 63      
sll   $t0, $t0, 2        
addu  $t0, $gp, $t0      
sw    $a2, ($t0)        
addi $s5, $s5, 1 

#Increases $t8 by 1
add $t8,$t8,1

j loopRight                 

#Pauses and resets some registers
pause:
		#Reset registers
		sub $s3,$s3,6
		sub $s5,$s5,6
		#Set FPS 
		li	$v0, 32		# $v0 is set to 32
		#FPS = 1000/$a0
		li	$a0, 50	# Set it to 60FPS
		syscall
		
		j mainLoop
#Exits the program		
exit:
   		li	$v0, 10
		syscall
