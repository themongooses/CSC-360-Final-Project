; Have the user enter in 10 non-negative integers and sum up those non-negative integers
; and find the average
.data
array DWORD ?10     ;Array of 10 integers
sum DWORD ?
average DWORD ?
 
prompt BYTE  "Enter a non-negative integer: ",0 ;prompt for user to enter an integer
message BYTE "Average= ",0
 
.run
move 0, GP4
    top_loop:
        move [prompt], AR1 ; Move the address of the prompt variable to the first argument register for the WriteString method to read
        call WriteString ; WriteString looks at the value of AR1 as a memory location reference and reads the values in sequential memory until it hits a null value signifying the end of a string
        call GetInt ; GetInt gets an integer value from the user and pushes it to the top of the stack
        POP GP1 ; Move the top of the stack to GP1
        move sum, GP2
        add GP2, GP1, sum ; Add the value to the sum
        add GP4, 1, GP4
        comp GP4, 9
        branch_lt top_loop ; Relative label addressing
        intdiv sum, 10, average ; Do an integer division operation of average=sum/10
        move [message], AR1 ; 
        call WriteString    ; Assuming built-in method
        move [average], AR1
        call WriteInt       ; Assuming built-in method