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
            compare_ge plain, 'a'
            compare_le plain, 'x'
            branch_and cond1_true
            compare_ge plain, 'A'
            compare_le plain, 'X'
            branch_and cond1_true
            jumpto else_L
            cond1_true:
                add plain, 2
                jumpto end_proc
        else_L:
            cond2:
                compare_eq plain, 'y'
                compare_eq plain, 'z'
                compare_eq plain, 'Y'
                compare_eq plain, 'Z'
                branch cond2_else
                jumpto end_proc
            cond2_else:
                subtract plain, 24
        end_proc:
            move plain, code
            move code, RV1
        return
    END PROC

    getline PROC
    ;; Implementation of the STL getline() method
    ;; Take in a pointer to a bytestring and store it into buff
        move 0, GP1
        l:
            ;;while the current character is not null and the current index is less than AR2, store the byte
            move [AR3+GP1], [AR1+GP1]   ; Move the current character at the GP1 index of AR3 into the same index at AR1
            add GP1, 1  ; Increment the counter
            compare_lt GP1, AR2 ; Check if we're within our limit
            compare_eq 0, [AR3+GP1] ; Or that the current character is not null
            branch e
            jumpto l
        e:
        return 
    END PROC

.run    ; Main code run here. Use procedures in .code
	; Print out the prompt
	move [prompt], AR1
	call WriteString
	call GetString ; GetString returns an offset to the BYTE array it created into RV1
    move [buff], AR1
    move 100, AR2
    move RV1, AR3
    call getline   ; Move the line into buff
	; do a loop (not a barrel roll) to encode each character in the buf array by passing it to the encode procedure
    move 0, GP1
    top_loop:
	    move buff[GP1], plain
	    call encode ; Encode has a return value in RV1
	    move RV1, buff[GP1] ; Move that return value to GP1
	    compare_eq 0, buff[GP1]
	    branch end_of_loop
	    add GP1, 1
	    jumpto top_loop
	end_of_loop:
	; Print out the encoded string
	move [msg], AR1
	call WriteString
	move [buff], AR1
	call WriteString
	call Newline