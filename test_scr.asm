prototype for the Microcontroler assembler language

_start;
mov var1, 4       ;Declare value 4 on segment named var1
mov var2, 5       ;Declare value 5 on segment named var2
add var1, var2    ;Addition will only hold variable 1 and variable 2
cmp var1, var2    ;Compare valie 1 and value 2
jmp 8             ;If the values are the same
jmp 11            ;If the valuues are different
dou 54, 1         ;Send to port 54 the number 1
msg $Hello_world$ ;Send message hello world
ret 1             ;End execution and return value 1
msg $Failed_exec$ ;Send failure message
ret 0             ;End execution and return value 0



