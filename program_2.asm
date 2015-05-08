; Have the user enter in 10 non-negative integers and sum up those non-negative integers
; and find the average
.data
sum DWORD ?
average DWORD ?
 
prompt BYTE  "Enter a non-negative integer: ",0 ;prompt for user to enter an integer
message BYTE "Average= ",0
 
.run
    move 0, GP4
    top_loop:
        move [prompt], AR1 ; Move the address of the prompt variable to the first argument register for the WriteString method to read
        call WriteString ; WriteString looks at the value of AR1 as a memory location reference and reads the values in sequential memory until it hits a null value signifying the end of a string
        call GetInt ; GetInt gets an integer value from the user and returns it to RV1
        add sum, RV1 ; Add the value to the sum
        call WriteNewline ;; Assuming built-in method. Writes a newline character to the output
        add GP4, 1  ; increment the loop counter
        compare_lt GP4, 9 ; Check for loop bounds
        branch top_loop ; Relative label addressing
        div2 sum, 10, average ; Do an integer division operation of average=sum/10
        move [message], AR1 ; 
        call WriteString    ; Assuming built-in method
        move [average], AR1
        call WriteInt       ; Assuming built-in method
        call WriteNewline   ; Assuming built-in method