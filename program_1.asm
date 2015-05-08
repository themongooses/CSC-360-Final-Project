.data
    plain BYTE ?    ; I like this syntax
    code BYTE ?
    prompt BYTE "Enter a string: ", 0
    msg BYTE "The encoded string is:", 0

    buff BYTE ?100 ; comparable to x86's DUP(100)?

.code   ; Keep procedures here
    encode PROC
        ; Encode a character
        cond1: ; if(( plain >= 'a' && plain <= 'x') || (plain => 'A' && plain <= 'X'))
            ; ( plain >= 'a' && plain <= 'x')
            move 0, TF
            comp_ge plain, 'a'
            comp_le plain, 'x'
            branch_and cond1_true
            move 0, TF
            comp_ge plain, 'A'
            comp_le plain, 'X'
            branch_and cond1_true
            move 0, TF 
            jump else_L
            cond1_true:
                ;add plain, 2, plain			;;;;;;;;;;;;;;;;
                add plain, 2, GP4
                move GP4, plain
                jump end_proc
        else_L:
            cond2:
                comp_eq plain, 'y'
                comp_eq plain, 'z'
                comp_eq plain, 'Y'
                comp_eq plain, 'Z'
                branch_or cond2_else
                jump end_proc
            cond2_else:
                move 0, TF
                sub plain, 24, GP4
                move GP4, plain
        end_proc:
            move plain, code
            STK code
    END PROC

.run    ; Main code run here. Use procedures in .code
	; Print out the prompt
	move [prompt], AR1
	call WriteString
	call GetString
	POP buff ; Move the inputted value to buff (takes care of the cin.getline() method)
	; do a loop (not a barrel roll) to encode each character in the buf array by passing it to the encode procedure
	top_loop:
	    move 0, GP1
	    move buff[GP1], plain
	    call encode
	    POP buff[GP1]
	    comp 0, buff[GP1]
	    branch_eq end_of_loop
	    add GP1, 1, GP1
	    jump top_loop
	end_of_loop:
	; Print out the encoded string
	move [message], AR1
	call WriteString
	move [buff], AR1
	call WriteString
	call Newline