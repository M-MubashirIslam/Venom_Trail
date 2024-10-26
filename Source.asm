INCLUDE irvine32.inc

GetStdHandle PROTO, nStdHandle:DWORD
WriteConsoleA PROTO, a1:DWORD, a2:PTR BYTE, a3:DWORD, a4:PTR DWORD, a5:DWORD

.DATA
hStdOut HANDLE ?
bufferSize COORD <40, 15>
windowRect SMALL_RECT <0, 0, 39, 14>

;Style
    ;Box Boundary
    boxColor db 5
    textColor db 1

    ;Grid Boundary
    brickColor db 13

    ;Snake
    snakeColor db 2

    ;Ball
    ballColor db 3

    ;DangerIndicator
    dangerColor db 4

;Global
space db " ", 0
;mid db 21
gameFlag dw 1
win db 0
temp db 0

;IntroScreen
i1 db "__   __                                            _                        _       _     ", 0    
i2 db "\ \ / /   ___    _ _      ___    _ __      o O O  | |_      _ _   __ _     (_)     | |    ", 0
i3 db " \ V /   / -_)  | ' \    / _ \  | '  \    o       |  _|    | '_| / _` |    | |     | |    ", 0
i4 db " _\_/_   \___|  |_||_|   \___/  |_|_|_|  TS__[O]  _\__|   _|_|_  \__,_|   _|_|_   _|_|_   ", 0
i5 db '_| """"|_|"""""|_|"""""|_|"""""|_|"""""| {======|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""| ', 0
i6 db '"`-0-0-`"`-0-0-`"`-0-0-`"`-0-0-`"`-0-0-`./o--000`"`-0-0-`"`-0-0-`"`-0-0-`"`-0-0-`"`-0-0-` ', 0
limit dd 8
startCol db 93
startRow db 8

;Lose Screen
gameOverr db "GAME OVER!", 0

;Win Screen
youWin db "YOU WIN!!!", 0

;Score Box
horizontal db "-", 0
edge db ".", 0
vertical db "|", 0
scoreText db "Score: ", 0
score db 0
scWidth db 100
scHeight db 50

;Danger Indicator
positive db 15
negative db 75

;Game Grid
brick db "[-]", 0
wwidth db 34
hheight db 17
leftCol db 99
row db 4

;Snake
snake dw 100 DUP (0)
snakeHead db ":O", 0
snakeBody db "|O", 0
snakeTail db "|-", 0
nodesCount dw 1
headPos dw 145DH
lastTailPos dw 145FH
dirH db -2
dirV db 0
tail db 2

;Ball
ballPos dw 0
ball db "Q", 0
ballFlag db 0


.CODE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

drawGameBoard PROC

movzx eax, brickColor
call SetTextColor

movzx ecx, wwidth
mov edx, offset brick
drawHor:
    call writeString
LOOP drawHor

movzx ecx, hheight
drawVer:
    mov dh, row
    mov dl, 0
    call Gotoxy
    mov edx, offset brick
    call writeString
    mov dh, row
    mov dl, leftCol
    call Gotoxy
    mov edx, offset brick
    call writeString
    call crlf
    INC row
LOOP drawVer

movzx ecx, wwidth
mov edx, offset brick
drawHor1:
    call writeString
LOOP drawHor1

RET
drawGameBoard ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

drawScoreBoard PROC

movzx eax, boxColor
call SetTextColor

mov edx, offset edge
call writeString

movzx ecx, scWidth
mov edx, offset horizontal
drawLine:
    call writeString
LOOP drawLine

mov edx, offset edge
call writeString
call crlf

mov edx, offset vertical
call writeString

mov dh, 1
mov dl, 101
call Gotoxy

mov edx, offset vertical
call writeString
call crlf

mov edx, offset vertical
call writeString

mov dh, 1
mov dl, 45
call Gotoxy

movzx eax, textColor
call SetTextColor
mov edx, offset scoreText
call writeString
movzx eax, score
call writeInt
movzx eax, boxColor
call SetTextColor

mov dh, 1
mov dl, 101
call Gotoxy

mov edx, offset vertical
call writeString
call crlf

mov edx, offset vertical
call writeString

mov dh, 1
mov dl, 101
call Gotoxy

mov edx, offset vertical
call writeString
call crlf

mov edx, offset edge
call writeString

movzx ecx, scWidth
mov edx, offset horizontal
drawLine1:
    call writeString
LOOP drawLine1

mov edx, offset edge
call writeString
call crlf

RET
drawScoreBoard ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


drawDangerIndicator PROC

movzx eax, boxColor
call SetTextColor

mov dh, 22
mov dl, 0
call Gotoxy

mov edx, offset edge
call writeString

movzx ecx, scWidth
mov edx, offset horizontal
drawLine:
    call writeString
LOOP drawLine

mov edx, offset edge
call writeString
call crlf

mov edx, offset vertical
call writeString

mov dh, 23
mov dl, 101
call Gotoxy

mov edx, offset vertical
call writeString
call crlf

mov edx, offset edge
call writeString

movzx ecx, scWidth
mov edx, offset horizontal
drawLine1:
    call writeString
LOOP drawLine1

mov edx, offset edge
call writeString
call crlf

RET
drawDangerIndicator ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

updateDangerIndicator PROC

mov bx, headPos
CMP bh, 13H
JAE highDanger
CMP bh, 05H
JBE highDanger
CMP bh, 09H
JBE lowDanger
CMP bh, 0EH
JAE lowDanger
CMP bl, 5AH
JAE highDanger
CMP bl, 08H
JBE highDanger
CMP bl, 55H
JAE lowDanger
CMP bl, 0BH
JBE lowDanger

CMP dangerColor, 1
JE noChange
mov al, 1
mov dangerColor, al
mov al, 75
mov positive, al
mov al, 15
mov negative, al
JMP outt

lowDanger:
    CMP bl, 5AH
    JAE highDanger
    CMP bl, 04H
    JBE highDanger
    CMP dangerColor, 2
    JE noChange
    mov al, 2
    mov dangerColor, al
    mov al, 50
    mov positive, al
    mov al, 40
    mov negative, al
    JMP outt

highDanger:
    CMP dangerColor, 4
    JE noChange
    mov al, 4
    mov dangerColor, al
    mov al, 15
    mov positive, al
    mov al, 75
    mov negative, al

outt:

mov dh, 23
mov dl, 5
call Gotoxy

movzx eax, DangerColor
call setTextColor

movzx ecx, negative
mov al, 'X'
drawX:
    call writeChar
LOOP drawX

movzx ecx, positive
mov al, '-'
drawY:
    call writeChar
LOOP drawY

noChange:
    RET

updateDangerIndicator ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

drawGameGrid PROC
call drawScoreBoard
call drawGameBoard
RET
drawGameGrid ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

intializeSnake PROC
    mov bx, headPos
    mov WORD PTR snake, bx
    add bx, 2
    mov WORD PTR snake[2], bx
RET
intializeSnake ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

drawSnake PROC
    call movSnake
    movzx eax, snakeColor
    call SetTextColor

    mov edi, 0
    mov dx, snake[edi]
    call Gotoxy
    mov edx, offset snakeHead
    call writeString
    add edi, 2

    movzx ecx, nodesCount
    CMP ecx, 1
    JE drawTail
    DEC ecx
    drawBody:
        mov dx, snake[edi]
        call Gotoxy
        mov edx, offset snakeBody
        call writeString
        add edi, 2
    LOOP drawBody

    drawTail:
        mov dx, snake[edi]
        call Gotoxy
        mov edx, offset snakeTail
        call writeString

        mov dx, lastTailPos
        call Gotoxy
        mov al, ' '
        call writeChar
        call writeChar
    mov eax, 150
    call Delay
    RET
drawSnake ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

movSnake PROC

call readKey
JZ noKeyPressed

cmp al, 'w'
    JE dirUp
cmp al, 'a'
    JE dirLeft
cmp al, 's'
    JE dirDown
cmp al, 'd'
    JE dirRight
    JMP noKeyPressed

    dirUp:
        CMP dirV, 0
        JNE noKeyPressed
        mov bl, 0
        mov bh, -1
        mov dirH, bl
        mov dirV, bh
        JMP noKeyPressed
    dirLeft:
        CMP dirH, 0
        JNE noKeyPressed
        mov bl, 0
        mov bh, -2
        mov dirH, bh
        mov dirV, bl
        JMP noKeyPressed
    dirDown:
        CMP dirV, 0
        JNE noKeyPressed
        mov bl, 0
        mov bh, 1
        mov dirH, bl
        mov dirV, bh
        JMP noKeyPressed
    dirRight:
        CMP dirH, 0
        JNE noKeyPressed
        mov bl, 0
        mov bh, 2
        mov dirH, bh
        mov dirV, bl

noKeyPressed:

mov ax, headPos
add al, dirH
add ah, dirV

PUSH offset snake
PUSH nodesCount
PUSH ax
call isValidPos
POP ax
POP nodesCount
POP ebx

CMP ax, 0
JE gameOver

mov headPos, ax

movzx ecx, nodesCount
movzx edi, tail
mov bx, WORD PTR snake[edi]
mov lastTailPos, bx
updateNodes:
    mov bx, WORD PTR snake[edi-2]
    mov WORD PTR snake[edi], bx
    sub edi, 2
LOOP updateNodes

mov WORD PTR snake, ax
JMP continueGame

    gameOver:
        mov edi, 0
        mov gameFlag, di
        mov al, 0
        mov win, al
        mov snakeColor, 4
    continueGame:
        RET
movSnake ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

isValidPos PROC
mov ebp, esp
mov bx, [ebp+4] ;bh = row, bl = col
CMP bh, 21
JE notValid
CMP bh, 3
JE notValid
CMP bl, 1
JE notValid
CMP bl, 99
JE notValid

movzx ecx, WORD PTR [ebp+6]
mov esi, [ebp+8]
checkBody:
    CMP bx, WORD PTR [esi+2]
    JE notValid
    add esi, 2
LOOP checkBody
JMP valid

notValid:
    mov WORD PTR [ebp+4], 0
    mov ebp, 0
valid:
    RET
isValidPos ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

generateBall PROC
mov al, ballFlag
CMP al, 0
JNE outt
    mov eax, 18
    call RandomRange
    add al, 4
    mov BYTE PTR ballPos+1, al
    mov eax, 98
    call randomRange
    TEST al, 01
    JNZ odd
    add al, 1
    odd: mov BYTE PTR ballPos, al
    mov al, 1
    mov ballFlag, al
    movzx eax, ballColor
    call SetTextColor
    mov dx, ballPos
    call Gotoxy
    mov edx, offset ball
    call writeString
outt:
    RET
generateBall ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gamePlay PROC
    
    gameLoop:
        call drawSnake
        call generateBall
        call eatBall
        call updateDangerIndicator
        CMP gameFlag, 1
    JE gameLoop
    CMP win, 1
    JNE loose
        call winScreen
    loose:
        call loseScreen
    mov dh, 25
    mov dl, 0
    call Gotoxy
RET
gamePlay ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

eatBall PROC
mov al, ballFlag
CMP al, 1
JNE outt
    mov ax, ballPos
    CMP ax, headPos
    JNE outt
    mov ax, 0
    mov ballPos, ax
    mov ballFlag, al
    INC score
    call addNode
    mov dh, 1
    mov dl, 45
    call Gotoxy
    movzx eax, textColor
    call SetTextColor
    mov edx, offset scoreText
    call writeString
    movzx eax, score
    call writeInt
outt:
    RET
eatBall ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

loseScreen PROC

mov eax, 4
call setTextColor

mov dh, 23
mov dl, 5
call Gotoxy

mov ecx, 40
mov al, '*'
draw:
    call writeChar
LOOP draw

mov edx, offset gameOverr
call writeString

mov ecx, 40
mov al, '*'
draw1:
    call writeChar
LOOP draw1
RET

loseScreen ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

introScreen PROC

mov eax, 13
call setTextColor

mov dh, 7
mov dl, 11
call Gotoxy
mov edx, offset i1
call WriteString
call crlf
mov bl, startCol

animation:
    mov bh, startRow
    mov dh, bh
    mov dl, bl
    call Gotoxy
    invoke GetStdHandle, -11
    invoke WriteConsoleA, eax, offset i2, limit, offset temp, 0
    call crlf
    INC bh
    mov dh, bh
    mov dl, bl
    call Gotoxy
    invoke GetStdHandle, -11
    invoke WriteConsoleA, eax, offset i3, limit, offset temp, 0
    call crlf
    INC bh
    mov dh, bh
    mov dl, bl
    call Gotoxy
    invoke GetStdHandle, -11
    invoke WriteConsoleA, eax, offset i4, limit, offset temp, 0
    call crlf
    INC bh
    mov dh, bh
    mov dl, bl
    call Gotoxy
    invoke GetStdHandle, -11
    invoke WriteConsoleA, eax, offset i5, limit, offset temp, 0
    call crlf
    INC bh
    mov dh, bh
    mov dl, bl
    call Gotoxy
    invoke GetStdHandle, -11
    invoke WriteConsoleA, eax, offset i6, limit, offset temp, 0
    call crlf
    DEC bl
    mov eax, 40
    call Delay
    INC limit
    CMP limit, 90
JBE animation

add bh, 5
mov dh, bh
mov dl, 40
call Gotoxy
call WaitMsg
call ClrScr

RET

introScreen ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

winScreen PROC

mov eax, 3
call setTextColor

mov dh, 23
mov dl, 5
call Gotoxy

mov ecx, 40
mov al, '*'
draw:
    call writeChar
LOOP draw

mov edx, offset youWin
call writeString

mov ecx, 40
mov al, '*'
draw1:
    call writeChar
LOOP draw1
RET

winScreen ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

addNode PROC

mov bx, lastTailPos
mov al, 2
add tail, al
movzx edi, tail
mov WORD PTR snake[edi], bx
INC nodesCount
RET

addNode ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main proc
call introScreen
call intializeSnake
call drawGameGrid
call drawDangerIndicator
call gamePlay
INVOKE ExitProcess, 0
main endp
END main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
