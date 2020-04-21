.model small

.stack 0100h

.data
    renderField DW 4000 DUP (' ')
    wallsMassive DB 2000 DUP (0)
    firstEnemy DB 4 DUP (0)                     ; 1 - x, 2 - y, 3 - Left/Right, 4 - Up/Down
    secondEnemy DB 4 DUP (0)                    ; 1 - x, 2 - y, 3 - Left/Right, 4 - Up/Down
    thirdEnemy DB 4 DUP (0)                     ; 1 - x, 2 - y, 3 - Left/Right, 4 - Up/Down
    fourthEnemy DB 4 DUP (0)                    ; 1 - x, 2 - y, 3 - Left/Right, 4 - Up/Down
    mine DB 4 DUP (0)                           ; 1 - x, 2 - y, 3 - Left/Right, 4 - Up/Down
    player DB 3 DUP (0)                         ; 1 - x, 2 - y, 3 - Not/Up/Right/Down/Left
    playerLine DB 2000 DUP (0)
    counter DW 4000
    speed DW 40000                              ; Скорость игры
    speedLevel DB 3                             ; Уровень Скорости игры
    live DB 0                                   ; Количество жизней
    wallsType DB 0                              ; 1 = left, 2 = middle, 3 = right, 0 = none
    skip DB 0                                   ; Флаг типа перевода пляжа в стену
    percent DW 0                                ; Процент прохождения игры
    enemyFlag DB 0                              ; Флаг отрисовки врага на карте пляжа

EnemiesFinalRender MACRO _offset                ; Отрисовка врага
    LEA DI, _offset
    XOR AX, AX
    MOV AL, [DI + 1]
    MOV BX, 80
    IMUL BX
    XOR DX, DX
    MOV Dl, [DI]
    ADD AX, DX
    LEA DI, renderField
    MOV BX, 2
    IMUL BX
    INC AX
    MOV BX, AX
    MOV [DI + BX], 64                           ; Установка ярко-красного цвета
ENDM

WallSand MACRO _offset                          ; Отрисовка стен на карте пляжа
    LEA DI, _offset
    LEA SI, playerLine
    MOV BX, 0
    MOV CX, 1840
    WallsDrawingCycle:                          ; Цикл отрисовки земли на карте пляжа
        CMP [DI + BX], 1                        ; Если на карте земли мы на клетке с землёй
        JNE NotAWall
            MOV [SI + BX], 2                    ; Помечаем эту клетку на карте пляжа    
        NotAWall:
        INC BX 
    LOOP WallsDrawingCycle
ENDM

EnemySand MACRO _offset
    LEA DI, _offset
    XOR AX, AX
    MOV AL, [DI + 1]
    MOV BX, 80
    IMUL BX
    XOR DX, DX
    MOV Dl, [DI]
    ADD AX, DX
    LEA DI, playerLine
    MOV BX, AX
    MOV [DI + BX], 3                           ; Помечаем эту клетку на карте пляжа    
ENDM

PlayerMovementDirection MACRO _offset, dirValue
    LEA DI, _offset
    MOV [DI + 2], dirValue    
ENDM

SpeedUp MACRO
    CMP WORD PTR speed, 10000
    JE HardestLevel
        SUB WORD PTR speed, 10000
        ADD BYTE PTR speedLevel, 1
    HardestLevel:
ENDM

SpeedDown MACRO
    CMP WORD PTR speed, 60000
    JE EasyestLevel
        ADD WORD PTR speed, 10000
        SUB BYTE PTR speedLevel, 1
    EasyestLevel:
ENDM

cout MACRO _offset
    MOV AH, 09H
    MOV DX, OFFSET _offset
    INT 21H
ENDM

delay MACRO _offset                             ; Задержка
    MOV CX, 0
    MOV DX, _offset
    MOV AH, 86H
    INT 15H            
ENDM
    
.code
    StartWallDrawing PROC
        LEA DI, wallsMassive
        
        XOR BX, BX
        MOV CX, 2000
        
        WallsStartZeroDrawing:                  ; Начальная инициализация нулями
            MOV [DI + BX], 0
            INC BX
        LOOP WallsStartZeroDrawing
        
        XOR BX, BX
        MOV CX, 23                              ; Количество строк (25 - 2 на HUD)
        
        WallsDrawVertical:
            MOV [DI + BX], 1
            INC BX
            MOV [DI + BX], 1
            ADD BX, 77                          ; Закрашиваем 2 левых и 2 правых стены
            MOV [DI + BX], 1
            INC BX
            MOV [DI + BX], 1
            INC BX
        LOOP WallsDrawVertical
            
        MOV BX, 2
        MOV CX, 4
        
        WallsDrawHorizontal:
            CMP CX, 2
            JNE NotCXThree:
                MOV BX, 1682                    ; 2 Последние строки
            NotCXThree:
            PUSH CX
            MOV CX, 76                          ; Количество столбцов
            WallsRowsDrawing:
                MOV [DI + BX], 1
                INC BX
            LOOP WallsRowsDrawing
            ADD BX, 4
            POP CX
        LOOP WallsDrawHorizontal
        RET 00H                                 ; Возврат в точку вызова                   
    StartWallDrawing ENDP
    
    StartSandDrawing PROC                       ; Начальное состояние пляжа
        LEA DI, playerLine
        XOR BX, BX
        MOV CX, 2000
        
        StartSandZeroDrawing:
            MOV [DI + BX], 0
            INC BX
        LOOP StartSandZeroDrawing
        
        RET 00H                                 ; Возврат в точку вызова
    StartSandDrawing ENDP
    
    StartEnemyProperty PROC                     ; Установка начальных свойств врагов
        LEA DI, firstEnemy
        MOV BYTE PTR [DI], 33
        MOV BYTE PTR [DI + 1], 5
        MOV BYTE PTR [DI + 2], 1
        MOV BYTE PTR [DI + 3], 1
        
        LEA DI, secondEnemy
        MOV BYTE PTR [DI], 71
        MOV BYTE PTR [DI + 1], 11
        MOV BYTE PTR [DI + 2], 0
        MOV BYTE PTR [DI + 3], 0
        
        LEA DI, thirdEnemy
        MOV BYTE PTR [DI], 14
        MOV BYTE PTR [DI + 1], 16
        MOV BYTE PTR [DI + 2], 1
        MOV BYTE PTR [DI + 3], 0
        
        LEA DI, fourthEnemy
        MOV BYTE PTR [DI], 68
        MOV BYTE PTR [DI + 1], 19
        MOV BYTE PTR [DI + 2], 0
        MOV BYTE PTR [DI + 3], 1
        
        LEA DI, mine
        MOV BYTE PTR [DI], 79
        MOV BYTE PTR [DI + 1], 22
        MOV BYTE PTR [DI + 2], 0
        MOV BYTE PTR [DI + 3], 1
        
        RET 00H                                 ; Возврат в точку вызова
    StartEnemyProperty ENDP
    
    FinalRenderFrame PROC                       ; Отрисовка кадра
        MOV CX, counter
        SUB CX, 320
        LEA DI, renderField
        StartRendering:
            MOV BX, CX
            DEC BX
            MOV AX, CX
            AND AX, 1
            CMP AX, 0
            JNE Odd
                MOV BYTE PTR [DI + BX], 10H     ; Море
                JMP StartRenderingEnd
            Odd:
                ;MOV BYTE PTR [DI + BX], ' '
            StartRenderingEnd:
            LOOP StartRendering
            
        LEA DI, wallsMassive
        MOV BX, 0
        MOV CX, 2000    
        WallsFinalRender:                       ; Отрисовка стен
            CMP [DI + BX], 1
            JNE ContinueWallsFinalRender
                PUSH DI
                PUSH BX
                MOV AX, BX
                LEA DI, renderField
                MOV BX, 2
                IMUL BX
                INC AX
                MOV BX, AX
                MOV [DI + BX], 32               ; Установка на фон ярко-зелёного цфета
                POP BX
                POP DI
            ContinueWallsFinalRender:
            INC BX
        LOOP WallsFinalRender
        
        LEA DI, playerLine
        MOV BX, 0
        MOV CX, 2000    
        SandFinalRender:                        ; Отрисовка пляжа
            CMP [DI + BX], 1
            JNE ContinueSandFinalRender
                PUSH DI
                PUSH BX
                MOV AX, BX
                LEA DI, renderField
                MOV BX, 2
                IMUL BX
                INC AX
                MOV BX, AX
                MOV [DI + BX], 96               ; Установка на фон ярко-жёлтого цфета
                POP BX
                POP DI
            ContinueSandFinalRender:
            INC BX
        LOOP SandFinalRender
        
        LEA DI, player                          ; Отрисовка игрока
        XOR AX, AX
        XOR BX, BX
        MOV AL, [DI + 1]
        MOV BX, 80
        IMUL BX
        XOR DX, DX
        MOV Dl, [DI]
        ADD AX, DX
        LEA DI, renderField
        MOV BX, 2
        IMUL BX
        INC AX
        MOV BX, AX
        MOV [DI + BX], 0                        ; Установка чёрного цвета      
        
        EnemiesFinalRender firstEnemy           ; Отрисовка 1ого врага
        EnemiesFinalRender secondEnemy          ; Отрисовка 2ого врага
        EnemiesFinalRender thirdEnemy           ; Отрисовка 3его врага
        EnemiesFinalRender fourthEnemy          ; Отрисовка 4ого врага
        
        LEA DI, mine                            ; Отрисовка мины
        XOR AX, AX
        XOR BX, BX
        MOV AL, [DI + 1]
        MOV BX, 80
        IMUL BX
        XOR DX, DX
        MOV Dl, [DI]
        ADD AX, DX
        LEA DI, renderField
        MOV BX, 2
        IMUL BX
        INC AX
        MOV BX, AX
        MOV [DI + BX], 112                      ; Установка белого цвета
                
        RET 00H                                 ; Возврат в точку вызова
    FinalRenderFrame ENDP
    
    Collision PROC                              ; Обработка столкновений
        LEA DI, player                          ; Установка игрока в начальное положение
        MOV [DI], 0
        MOV [DI + 1], 0
        MOV [DI + 2], 0
        
        LEA DI, mine                            ; Установка мины в начальное положение     
        MOV BYTE PTR [DI], 79
        MOV BYTE PTR [DI + 1], 22
        MOV BYTE PTR [DI + 2], 0
        MOV BYTE PTR [DI + 3], 1 
        
        CALL StartSandDrawing
        
        DEC live
        
        RET 00H                                 ; Возврат в точку вызова
    Collision ENDP
    
    EnemiesMovement PROC                        ; Движение врагов
        XOR AX, AX
        MOV AL, [DI + 1]
        XOR BX, BX
        MOV BL, 80
        IMUL BX
        XOR DX, DX
        MOV DL, [DI]
        ADD AX, DX
        
        MOV DL, [DI + 2]                        ; Движение врагов по горизонтали
        CMP DL, 1
        JNE EnemyLeft
            ADD AX, 1 
            PUSH DI
            LEA DI, wallsMassive
            MOV BX, AX
            CMP [DI + BX], 0
            JNE EnemyRightWall
                POP DI
                ADD [DI], 1
                JMP EnemyRightResult
            EnemyRightWall:
                POP DI
                SUB [DI], 1
                MOV [DI + 2], 0
                SUB AX, 2
            EnemyRightResult:
                JMP EnemyMovementHorResult
        EnemyLeft:
            SUB AX, 1
            PUSH DI
            LEA DI, wallsMassive
            MOV BX, AX
            CMP [DI + BX], 0
            JNE EnemyLeftWall
                POP DI
                SUB [DI], 1
                JMP EnemyLeftResult
            EnemyLeftWall:
                POP DI
                ADD [DI], 1
                MOV [DI + 2], 1
                ADD AX, 2
            EnemyLeftResult:
        EnemyMovementHorResult:
        
        MOV DL, [DI + 3]                        ; Движение врагов по вертикали
        CMP DL, 1
        JNE EnemyDown
            SUB AX, 80
            PUSH DI
            LEA DI, wallsMassive
            MOV BX, AX
            CMP [DI + BX], 0
            JNE EnemyUpWall
                POP DI
                SUB [DI + 1], 1
                JMP EnemyUpResult
            EnemyUpWall:
                POP DI
                ADD [DI + 1], 1
                MOV [DI + 3], 0
            EnemyUpResult:
                JMP EnemyMovementVerResult
        EnemyDown:
            ADD AX, 80
            PUSH DI
            LEA DI, wallsMassive
            MOV BX, AX
            CMP [DI + BX], 0
            JNE EnemyDownWall
                POP DI
                ADD [DI + 1], 1
                JMP EnemyDownResult
            EnemyDownWall:
                POP DI
                SUB [DI + 1], 1
                MOV [DI + 3], 1
            EnemyDownResult:
        EnemyMovementVerResult:
        
        LEA SI, playerLine                      ; Проверка на столкновение с пляжем
        XOR AX, AX
        MOV AL, [DI + 1]
        MOV BX, 80
        IMUL BX
        XOR DX, DX
        MOV Dl, [DI]
        ADD AX, DX
        MOV BX, AX
        CMP [SI + BX], 1
        JNE NotCollision                        ; Если есть столкновение
            CALL Collision
        
        NotCollision:                           ; Если столкновения нет
        
        RET 00H                                 ; Возврат в точку вызова
    EnemiesMovement ENDP
    
    MineMovement PROC                           ; Движение мины 
        LEA DI, mine
        XOR AX, AX
        MOV AL, [DI + 1]
        XOR BX, BX
        MOV BL, 80
        IMUL BX
        XOR DX, DX
        MOV DL, [DI]
        ADD AX, DX
        
        MOV DL, [DI + 2]                        ; Движение мины по горизонтали
        CMP DL, 1
        JNE MineLeft
            PUSH DI
            CMP [DI], 79
            JE MineRightWall 
            LEA DI, wallsMassive
            ADD AX, 1
            MOV BX, AX
            CMP [DI + BX], 1
            JNE MineRightWall
                POP DI
                ADD [DI], 1
                JMP MineRightResult
            MineRightWall:
                POP DI
                SUB [DI], 1
                MOV [DI + 2], 0
                SUB AX, 1
            MineRightResult:
                JMP MineMovementHorResult
        MineLeft:
            PUSH DI
            CMP [DI], 0
            JE MineLeftWall
            LEA DI, wallsMassive
            SUB AX, 1
            MOV BX, AX
            CMP [DI + BX], 1
            JNE MineLeftWall
                POP DI
                SUB [DI], 1
                JMP MineLeftResult
            MineLeftWall:
                POP DI
                ADD [DI], 1
                MOV [DI + 2], 1
                ADD AX, 1
            MineLeftResult:
        MineMovementHorResult:
        
        MOV DL, [DI + 3]                        ; Движение мины по вертикали
        CMP DL, 1
        JNE MineDown
            PUSH DI
            CMP [DI + 1], 0
            JE MineUpWall
            LEA DI, wallsMassive
            SUB AX, 80
            MOV BX, AX
            CMP [DI + BX], 1
            JNE MineUpWall
                POP DI
                SUB [DI + 1], 1
                JMP MineUpResult
            MineUpWall:
                POP DI
                ADD [DI + 1], 1
                MOV [DI + 3], 0
            MineUpResult:
                JMP MineMovementVerResult
        MineDown:
            PUSH DI
            CMP [DI + 1], 22
            JE MineDownWall
            LEA DI, wallsMassive
            ADD AX, 80
            MOV BX, AX
            CMP [DI + BX], 1
            JNE MineDownWall
                POP DI
                ADD [DI + 1], 1
                JMP MineDownResult
            MineDownWall:
                POP DI
                SUB [DI + 1], 1
                MOV [DI + 3], 1
            MineDownResult:
        MineMovementVerResult:
        
        LEA DI, mine
        LEA SI, player                          ; Проверка на столкновение с игроком
        MOV AL, BYTE PTR [DI]
        CMP BYTE PTR [SI], AL
        JNE MineNotCollision                    ; Если нет столкновения
        MOV AL, [DI + 1]
        CMP [SI + 1], AL
        JNE MineNotCollision                    ; Если есть столкновение
            CALL Collision                        
                  
        MineNotCollision:                       ; Если столкновения нет
                                      
        RET 00H                                 ; Возврат в точку вызова
    MineMovement ENDP    
    
    PlayerMovement PROC
        LEA DI, player
        MOV AH, [DI + 2]
        CMP AH, 1                               ; Движение вверх
        JNE NotUp
            MOV AL, [DI + 1]
            CMP AL, 0
            JE StopMovement
            SUB [DI + 1], 1
            JMP NotLeft
        NotUp:
        CMP AH, 2                               ; Движение вправо
        JNE NotRight
            MOV AL, [DI]
            CMP AL, 79
            JE StopMovement
            ADD [DI], 1
            JMP NotLeft
        NotRight:
        CMP AH, 3                               ; Движение вниз
        JNE NotDown
            MOV AL, [DI + 1]
            CMP AL, 22
            JE StopMovement
            ADD [DI + 1], 1
            JMP NotLeft
        NotDown:
        CMP AH, 4                               ; Движение влево
        JNE NotLeft
            MOV AL, [DI]
            CMP AL, 0
            JE StopMovement
            SUB [DI], 1
            JMP NotLeft
        StopMovement:
            MOV [DI + 2], 0    
        NotLeft:
        
        LEA SI, firstEnemy                      ; Проверка на столкновение с 1ым врагом
        MOV AL, [SI]
        CMP [DI], AL
        JNE NoCollisionWithFirstEnemy
            MOV AL, [SI + 1]
            CMP [DI + 1], AL
            JNE NoCollisionWithFirstEnemy
                CALL Collision
                JMP GoResult
        NoCollisionWithFirstEnemy:
        LEA SI, secondEnemy                     ; Проверка на столкновение со 2ым врагом
        MOV AL, [SI]
        CMP [DI], AL
        JNE NoCollisionWithSecondEnemy
            MOV AL, [SI + 1]
            CMP [DI + 1], AL
            JNE NoCollisionWithSecondEnemy
                CALL Collision
                JMP GoResult
        NoCollisionWithSecondEnemy:
        LEA SI, thirdEnemy                      ; Проверка на столкновение с 3им врагом
        MOV AL, [SI]
        CMP [DI], AL
        JNE NoCollisionWithThirdEnemy
            MOV AL, [SI + 1]
            CMP [DI + 1], AL
            JNE NoCollisionWithThirdEnemy
                CALL Collision
                JMP GoResult
        NoCollisionWithThirdEnemy:
        LEA SI, fourthEnemy                     ; Проверка на столкновение с 4ым врагом
        MOV AL, [SI]
        CMP [DI], AL
        JNE NoCollisionWithFourthEnemy
            MOV AL, [SI + 1]
            CMP [DI + 1], AL
            JNE NoCollisionWithFourthEnemy
                CALL Collision
                JMP GoResult
        NoCollisionWithFourthEnemy:
        LEA SI, mine                            ; Проверка на столкновение с миной
        MOV AL, [SI]
        CMP [DI], AL
        JNE NoCollisionWithMine
            MOV AL, [SI + 1]
            CMP [DI + 1], AL
            JNE NoCollisionWithMine
                CALL Collision
                JMP GoResult
        NoCollisionWithMine:
                                                
        LEA DI, player                          ; Проверка на столкновение с пляжем
        XOR AX, AX
        MOV AL, [DI + 1]
        MOV BX, 80
        IMUL BX
        XOR DX, DX
        MOV Dl, [DI]
        ADD AX, DX
        MOV BX, AX
        LEA DI, playerLine
        CMP [DI + BX], 1
        JNE NoCollisionWithSand
            CALL Collision
            JMP GoResult    
        NoCollisionWithSand:
            
        LEA DI, player
        XOR AX, AX
        MOV AL, [DI + 1]
        MOV BX, 80
        IMUL BX
        XOR DX, DX
        MOV Dl, [DI]
        ADD AX, DX
        MOV BX, AX
        CMP [DI + 2], 1
        JNE Go2
            LEA DI, wallsMassive
            CMP [DI + BX], 1
            JNE GoResult
            ADD BX, 80
            CMP [DI + BX], 0
            JNE GoResult
                CALL SandToWalls
            JMP GoResult
        Go2:
        CMP [DI + 2], 2
        JNE Go3
            LEA DI, wallsMassive
            CMP [DI + BX], 1
            JNE GoResult
            SUB BX, 1
            CMP [DI + BX], 0
            JNE GoResult
                CALL SandToWalls
            JMP GoResult
        Go3:
        CMP [DI + 2], 3
        JNE Go4
            LEA DI, wallsMassive
            CMP [DI + BX], 1
            JNE GoResult
            SUB BX, 80
            CMP [DI + BX], 0
            JNE GoResult
                CALL SandToWalls
            JMP GoResult
        Go4:
        CMP [DI + 2], 4
        JNE GoResult
            LEA DI, wallsMassive
            CMP [DI + BX], 1
            JNE GoResult
            ADD BX, 1
            CMP [DI + BX], 0
            JNE GoResult
            CALL SandToWalls    
        
        GoResult:    
            
        RET 00H                                 ; Возврат в точку вызова
    PlayerMovement ENDP
    
    SandDrawing PROC
        LEA DI, player
        XOR AX, AX
        XOR BX, BX
        MOV AL, [DI + 1]
        MOV BX, 80
        IMUL BX
        XOR DX, DX
        MOV Dl, [DI]
        ADD AX, DX
        
        LEA DI, wallsMassive
        MOV BX, AX
        CMP [DI + BX], 0
        JNE NotASee
            LEA DI, playerLine
            MOV [DI + BX], 1    
        NotASee:
        
        RET 00H                                 ; Возврат в точку вызова
    SandDrawing ENDP
    
    Translate PROC                              ; Перевод нужных участков с карты пляжа на карту земли
        LEA DI, playerLine
        LEA SI, wallsMassive
        MOV BX, 160
        MOV CX, 1520
        
        TranslateCycle:
            CMP [DI + BX], 0                    ; Если встретился нужный для закраски участок, то закрашиваем
            JNE TranslateNot0
                MOV [SI + BX], 1                ; Помещаем стену в эту клетку
            TranslateNot0:
            CMP [DI + BX], 1                    ; Если у нас встретился контур
            JNE TranslateNot1                                         
                MOV [SI + BX], 1                ; Помещаем стену в эту клетку
            TranslateNot1:
            INC BX
        LOOP TranslateCycle
        
        RET 00H                                 ; Возврат в точку вызова
    Translate ENDP
    
    SandToWalls PROC                            ; Перевод пляжа в стену                                                 
        WallSand wallsMassive                   ; Отображаем стены на карте пляжа
        EnemySand firstEnemy                    ; Отображаем врагов на карте пляжа
        EnemySand secondEnemy                   ; Отображаем врагов на карте пляжа
        EnemySand thirdEnemy                    ; Отображаем врагов на карте пляжа
        EnemySand fourthEnemy                   ; Отображаем врагов на карте пляжа
        
        LEA DI, playerLine
        EnemiesCycle:                           ; Заполняем пустые области врагами до краёв
            MOV BX, 160
            MOV CX, 1520
            EnemiesMultiplication:              ; Цикл умножения врагов
                CMP [DI + BX], 3                ; Если мы на клетке с врагом
                JNE NotAnEnemy
                    CMP [DI + BX - 80 - 1], 0   ; Если свободна левая верхняя клетка
                    JNE NotFree1:
                        MOV [DI + BX - 80 - 1], 3   ; Заносим врага в эту клетку 
                        MOV enemyflag, 1        ; Делаем флаг активным
                    NotFree1:
                    CMP [DI + BX - 80], 0       ; Если свободна верхняя клетка
                    JNE NotFree2:
                        MOV [DI + BX - 80], 3   ; Заносим врага в эту клетку
                        MOV enemyflag, 1        ; Делаем флаг активным
                    NotFree2:
                    CMP [DI + BX - 80 + 1], 0   ; Если свободна правая верхняя клетка
                    JNE NotFree3:
                        MOV [DI + BX - 80 + 1], 3   ; Заносим врага в эту клетку
                        MOV enemyflag, 1        ; Делаем флаг активным
                    NotFree3:
                    CMP [DI + BX - 1], 0        ; Если левая клетка   
                    JNE NotFree4:
                        MOV [DI + BX - 1], 3    ; Заносим врага в эту клетку
                        MOV enemyflag, 1        ; Делаем флаг активным
                    NotFree4:
                    CMP [DI + BX + 1], 0        ; Если свободна правая клетка            
                    JNE NotFree5:     
                        MOV [DI + BX + 1], 3    ; Заносим врага в эту клетку
                        MOV enemyflag, 1        ; Делаем флаг активным
                    NotFree5:
                    CMP [DI + BX + 80 - 1], 0   ; Если свободна левая нижняя клетка        
                    JNE NotFree6:     
                        MOV [DI + BX + 80 - 1], 3   ; Заносим врага в эту клетку
                        MOV enemyflag, 1        ; Делаем флаг активным
                    NotFree6:
                    CMP [DI + BX + 80], 0       ; Если свободна нижняя клетка       
                    JNE NotFree7:
                        MOV [DI + BX + 80], 3   ; Заносим врага в эту клетку
                        MOV enemyflag, 1        ; Делаем флаг активным
                    NotFree7:
                    CMP [DI + BX + 80 + 1], 0   ; Если свободна нижняя правая клетка    
                    JNE NotFree8:
                        MOV [DI + BX + 80 + 1], 3   ; Заносим врага в эту клетку
                        MOV enemyflag, 1        ; Делаем флаг активным
                    NotFree8:
                NotAnEnemy:                     ; Если мы не на клетке с врагом
                INC BX    
            LOOP EnemiesMultiplication
            CMP enemyFlag, 1                    ; Если новые враги не отрисовались, то выходим из цикла
            JNE EndEnemiesCycle
                MOV enemyflag, 0                ; Возвращаем флаг в исходное (0) состояние
        JMP EnemiesCycle:
        EndEnemiesCycle:
        
        CAll translate                          ; Перевод незакрашенных участков на карту земли
        CALL StartSandDrawing                   ; Начальная отрисовка пляжа
            
        RET 00H                                 ; Возврат в точку вызова
    SandToWalls ENDP
    
    PercentCount PROC                           ; Рассчёт процента прохождения
        LEA DI, wallsMassive
        XOR AX, AX
        XOR BX, BX
        MOV CX, 2000
        
        ProcWallCycle:
            CMP [DI + BX], 1
            JNE NotWallEq1
                INC AX
            NotWallEq1:
                INC BX
        LOOP ProcWallCycle
        
        SUB AX, 396
        
        MOV BX, 100
        MUL BX
        
        MOV BX, 1444
        DIV BX
        MOV percent, AX
        
        RET 00H                                 ; Возврат в точку вызова
    PercentCount ENDP
    
    PercentRender PROC                          ; Отрисовка процента прохождения
        MOV AX, percent
        MOV BX, 10
        DIV BX
        
        ADD AL, '0'
        ADD Dl, '0'
        
        PUSH DS
        PUSH 0B800H
        POP DS
        MOV DI, 3960
        MOV [DI], AL
        INC DI
        MOV [DI], 11
        INC DI
        MOV [DI], DL
        INC DI
        MOV [DI], 11
        INC DI
        INC DI
        INC DI
        MOV [DI], '%'
        INC DI
        MOV [DI], 11
        INC DI
        
        POP DS
        
        RET 00H                                 ; Возврат в точку вызова
    PercentRender ENDP
    
    Render PROC                                 ; Финальная отрисовка
        PUSH 0B800H
        POP ES
        MOV CX, counter
        MOV DI, 0
        LEA SI, renderField
        REP MOVSB
        
        MOV DI, 3972
        MOV AL, live
        ADD AL, '0'
        MOV BL, speedLevel
        ADD BL, '0'
        PUSH DS
        PUSH 0B800H
        POP DS
        
        MOV [DI], 'D'
        INC DI
        MOV [DI], 13
        INC DI
        MOV [DI], 'I'
        INC DI
        MOV [DI], 13
        INC DI
        MOV [DI], 'F'
        INC DI
        MOV [DI], 13
        INC DI
        MOV [DI], 'F'
        INC DI
        MOV [DI], 13
        INC DI
        MOV [DI], ':'
        INC DI
        MOV [DI], 13
        INC DI
        MOV [DI], BL
        INC DI
        MOV [DI], 13
        INC DI
        INC DI
        INC DI
        INC DI
        INC DI
        
        MOV [DI], 'L'
        INC DI
        MOV [DI], 12
        INC DI
        MOV [DI], 'I'
        INC DI
        MOV [DI], 12
        INC DI
        MOV [DI], 'V'
        INC DI
        MOV [DI], 12
        INC DI
        MOV [DI], 'E'
        INC DI
        MOV [DI], 12
        INC DI
        MOV [DI], ':'
        INC DI
        MOV [DI], 12
        INC DI
        MOV [DI], AL
        INC DI
        MOV BYTE PTR [DI], 12                   ; Количество жизней красного цвета
        POP DS
        
        CALL PercentRender                      ; Отрисовка процента прохождения
        
        RET 00H                                 ; Возврат в точку вызова
    Render ENDP
    
    StartGame: 
        MOV AX, @data
        MOV DS, AX
        
        MOV AH, 00H                             ; Установка 3 видеорежима
        MOV AL, 03H                             ; Установка 3 видеорежима
        INT 10H                                 ; Установка 3 видеорежима
        
        MOV AH, 02H                             ; Скрываем курсор
        MOV BH, 0                               ; Скрываем курсор
        MOV DH, 25                              ; Скрываем курсор
        MOV DL, 0                               ; Скрываем курсор
        INT 10H                                 ; Скрываем курсор
        
        CALL StartWallDrawing                   ; Начальная отрисовка стены
        CALL StartSandDrawing                   ; Начальная отрисовка пляжа
        
        LEA DI, player                          ; Установка начального положения игрока
        MOV WORD PTR [DI], 0                    ; Установка начального положения игрока
        MOV WORD PTR [DI + 1], 0                ; Установка начального положения игрока
        MOV WORD PTR [DI + 2], 0                ; Установка начального положения игрока
        
        CALL StartEnemyProperty                 ; Установка начальных свойств врагов
        
        MOV percent, 0                          ; Начальный процент прохождения уровня
        MOV live, 9                             ; Начальное количество жизней
        
        GameCycle:
            CALL FinalRenderFrame               ; Отрисовка кадра
            CALL Render                         ; Отправка кадра видеоадаптеру
            
            LEA DI, firstEnemy                  ; Движение 1ого врага
            CALL EnemiesMovement                ; Движение 1ого врага
            CMP live, 0
            JE GameOver
            LEA DI, secondEnemy                 ; Движение 2ого врага
            CALL EnemiesMovement                ; Движение 2ого врага
            CMP live, 0
            JE GameOver
            LEA DI, thirdEnemy                  ; Движение 3его врага
            CALL EnemiesMovement                ; Движение 3его врага
            CMP live, 0
            JE GameOver
            LEA DI, fourthEnemy                 ; Движение 4ого врага
            CALL EnemiesMovement                ; Движение 4ого врага
            CMP live, 0
            JE GameOver
            
            CALL MineMovement                   ; Движение мины
            CMP live, 0
            JE GameOver
            
            MOV AH, 01H                         ; Проверка клавиатуры
            INT 16H                             ; Проверка клавиатуры
            JZ ButtonNotPressed                 ; Если клавиша не была нажата
            MOV AH, 00H
            INT 16H
            CMP AL, 'a'                         ; Влево
            JNE NotA
                PlayerMovementDirection player, 4
                JMP ButtonNotPressed
            NotA:
            CMP AL, 'w'                         ; Вверх
            JNE NotW
                PlayerMovementDirection player, 1
                JMP ButtonNotPressed
            NotW:
            CMP AL, 'd'                         ; Вправо
            JNE NotD
                PlayerMovementDirection player, 2
                JMP ButtonNotPressed
            NotD:
            CMP AL, 's'                         ; Вниз
            JNE NotS
                PlayerMovementDirection player, 3
                JMP ButtonNotPressed
            NotS:
            CMP AL, 'r'                         ; Рестарт
            JNE NotR
                JMP StartGame
            NotR:
            CMP AL, '+'                         ; Увеличение сложности
            JNE NotPlus
                SpeedUp
                JMP ButtonNotPressed
            NotPlus:
            CMP AL, '-'                         ; Уменьшение сложности
            JNE NotMinus
                SpeedDown
                JMP ButtonNotPressed
            NotMinus:
            CMP AL, 27                          ; ESC
            JNE ButtonNotPressed          
                JMP Exit
            ButtonNotPressed:
            
            CALL PlayerMovement                 ; Обработка движений игрока
            CMP live, 0
            JE GameOver
            CALL SandDrawing                    ; Обработка пляжа
            
            CALL percentCount                   ; Расчёт процента прохождения
            
            CMP percent, 90                     ; Если игра пройдена
            JG YouWin                           ; Если игра пройдена
            
            delay speed                         ; Задержка на speed микросекунд
            delay speed                         ; Задержка на speed микросекунд
        JMP GameCycle
        
        YouWin:
            PUSH DS
            PUSH 0B800H
            POP DS
            MOV DI, 3840
            
            MOV [DI], 'Y'
            INC DI
            MOV [DI], 15
            INC DI
            MOV [DI], 'O'
            INC DI
            MOV [DI], 15
            INC DI
            MOV [DI], 'U'
            INC DI
            MOV [DI], 15
            INC DI
            INC DI
            INC DI
            MOV [DI], 'W'
            INC DI
            MOV [DI], 15
            INC DI
            MOV [DI], 'I'
            INC DI
            MOV [DI], 15
            INC DI
            MOV [DI], 'N'
            INC DI
            MOV [DI], 15
            INC DI
            MOV [DI], '!'
            INC DI
            MOV [DI], 15
            INC DI    
            POP DS
            
            MOV AH, 00H
            INT 16H
            CMP AL, ' '                         ; Начать заново
            JNE NotSpace
                JMP StartGame
            NotSpace:
            CMP AL, 27                          ; Выход
            JNE NotExit
                JMP Exit
            NotExit:
                JMP YouWin
            
        GameOver:
            PUSH DS
            PUSH 0B800H
            POP DS
            MOV DI, 3840
            
            MOV [DI], 'G'
            INC DI
            MOV [DI], 15
            INC DI
            MOV [DI], 'A'
            INC DI
            MOV [DI], 15
            INC DI
            MOV [DI], 'M'
            INC DI
            MOV [DI], 15
            INC DI
            MOV [DI], 'E'
            INC DI
            MOV [DI], 15
            INC DI
            INC DI
            INC DI
            MOV [DI], 'O'
            INC DI
            MOV [DI], 15
            INC DI
            MOV [DI], 'V'
            INC DI
            MOV [DI], 15
            INC DI
            MOV [DI], 'E'
            INC DI
            MOV [DI], 15
            INC DI
            MOV [DI], 'R'
            INC DI
            MOV [DI], 15
            INC DI
            MOV [DI], '!'
            INC DI
            MOV [DI], 15
            INC DI 
            POP DS 
        
            MOV AH, 00H
            INT 16H
            CMP AL, ' '                         ; Начать заново
            JNE NotSpaceWin
                JMP StartGame
            NotSpaceWin:
            CMP AL, 27                          ; Выход
            JNE NotExitWin
                JMP Exit
            NotExitWin:
                JMP GameOver
        
        Exit:
            MOV AH, 00H                         ; Установка 2 видеорежима
            MOV AL, 02H                         ; Установка 2 видеорежима
            INT 10H  
        
            XOR AX, AX                          ; Очистка экрана
            MOV AH, 07H                         ; Очистка экрана
            INT 10H                             ; Очистка экрана
        
        MOV AX, 4C00H
        INT 21H
    
    end StartGame