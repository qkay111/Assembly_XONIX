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
    speed DW 40000                              ; �������� ����
    speedLevel DB 3                             ; ������� �������� ����
    live DB 0                                   ; ���������� ������
    wallsType DB 0                              ; 1 = left, 2 = middle, 3 = right, 0 = none
    skip DB 0                                   ; ���� ���� �������� ����� � �����
    percent DW 0                                ; ������� ����������� ����
    enemyFlag DB 0                              ; ���� ��������� ����� �� ����� �����

EnemiesFinalRender MACRO _offset                ; ��������� �����
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
    MOV [DI + BX], 64                           ; ��������� ����-�������� �����
ENDM

WallSand MACRO _offset                          ; ��������� ���� �� ����� �����
    LEA DI, _offset
    LEA SI, playerLine
    MOV BX, 0
    MOV CX, 1840
    WallsDrawingCycle:                          ; ���� ��������� ����� �� ����� �����
        CMP [DI + BX], 1                        ; ���� �� ����� ����� �� �� ������ � �����
        JNE NotAWall
            MOV [SI + BX], 2                    ; �������� ��� ������ �� ����� �����    
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
    MOV [DI + BX], 3                           ; �������� ��� ������ �� ����� �����    
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

delay MACRO _offset                             ; ��������
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
        
        WallsStartZeroDrawing:                  ; ��������� ������������� ������
            MOV [DI + BX], 0
            INC BX
        LOOP WallsStartZeroDrawing
        
        XOR BX, BX
        MOV CX, 23                              ; ���������� ����� (25 - 2 �� HUD)
        
        WallsDrawVertical:
            MOV [DI + BX], 1
            INC BX
            MOV [DI + BX], 1
            ADD BX, 77                          ; ����������� 2 ����� � 2 ������ �����
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
                MOV BX, 1682                    ; 2 ��������� ������
            NotCXThree:
            PUSH CX
            MOV CX, 76                          ; ���������� ��������
            WallsRowsDrawing:
                MOV [DI + BX], 1
                INC BX
            LOOP WallsRowsDrawing
            ADD BX, 4
            POP CX
        LOOP WallsDrawHorizontal
        RET 00H                                 ; ������� � ����� ������                   
    StartWallDrawing ENDP
    
    StartSandDrawing PROC                       ; ��������� ��������� �����
        LEA DI, playerLine
        XOR BX, BX
        MOV CX, 2000
        
        StartSandZeroDrawing:
            MOV [DI + BX], 0
            INC BX
        LOOP StartSandZeroDrawing
        
        RET 00H                                 ; ������� � ����� ������
    StartSandDrawing ENDP
    
    StartEnemyProperty PROC                     ; ��������� ��������� ������� ������
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
        
        RET 00H                                 ; ������� � ����� ������
    StartEnemyProperty ENDP
    
    FinalRenderFrame PROC                       ; ��������� �����
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
                MOV BYTE PTR [DI + BX], 10H     ; ����
                JMP StartRenderingEnd
            Odd:
                ;MOV BYTE PTR [DI + BX], ' '
            StartRenderingEnd:
            LOOP StartRendering
            
        LEA DI, wallsMassive
        MOV BX, 0
        MOV CX, 2000    
        WallsFinalRender:                       ; ��������� ����
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
                MOV [DI + BX], 32               ; ��������� �� ��� ����-������� �����
                POP BX
                POP DI
            ContinueWallsFinalRender:
            INC BX
        LOOP WallsFinalRender
        
        LEA DI, playerLine
        MOV BX, 0
        MOV CX, 2000    
        SandFinalRender:                        ; ��������� �����
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
                MOV [DI + BX], 96               ; ��������� �� ��� ����-������ �����
                POP BX
                POP DI
            ContinueSandFinalRender:
            INC BX
        LOOP SandFinalRender
        
        LEA DI, player                          ; ��������� ������
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
        MOV [DI + BX], 0                        ; ��������� ������� �����      
        
        EnemiesFinalRender firstEnemy           ; ��������� 1��� �����
        EnemiesFinalRender secondEnemy          ; ��������� 2��� �����
        EnemiesFinalRender thirdEnemy           ; ��������� 3��� �����
        EnemiesFinalRender fourthEnemy          ; ��������� 4��� �����
        
        LEA DI, mine                            ; ��������� ����
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
        MOV [DI + BX], 112                      ; ��������� ������ �����
                
        RET 00H                                 ; ������� � ����� ������
    FinalRenderFrame ENDP
    
    Collision PROC                              ; ��������� ������������
        LEA DI, player                          ; ��������� ������ � ��������� ���������
        MOV [DI], 0
        MOV [DI + 1], 0
        MOV [DI + 2], 0
        
        LEA DI, mine                            ; ��������� ���� � ��������� ���������     
        MOV BYTE PTR [DI], 79
        MOV BYTE PTR [DI + 1], 22
        MOV BYTE PTR [DI + 2], 0
        MOV BYTE PTR [DI + 3], 1 
        
        CALL StartSandDrawing
        
        DEC live
        
        RET 00H                                 ; ������� � ����� ������
    Collision ENDP
    
    EnemiesMovement PROC                        ; �������� ������
        XOR AX, AX
        MOV AL, [DI + 1]
        XOR BX, BX
        MOV BL, 80
        IMUL BX
        XOR DX, DX
        MOV DL, [DI]
        ADD AX, DX
        
        MOV DL, [DI + 2]                        ; �������� ������ �� �����������
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
        
        MOV DL, [DI + 3]                        ; �������� ������ �� ���������
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
        
        LEA SI, playerLine                      ; �������� �� ������������ � ������
        XOR AX, AX
        MOV AL, [DI + 1]
        MOV BX, 80
        IMUL BX
        XOR DX, DX
        MOV Dl, [DI]
        ADD AX, DX
        MOV BX, AX
        CMP [SI + BX], 1
        JNE NotCollision                        ; ���� ���� ������������
            CALL Collision
        
        NotCollision:                           ; ���� ������������ ���
        
        RET 00H                                 ; ������� � ����� ������
    EnemiesMovement ENDP
    
    MineMovement PROC                           ; �������� ���� 
        LEA DI, mine
        XOR AX, AX
        MOV AL, [DI + 1]
        XOR BX, BX
        MOV BL, 80
        IMUL BX
        XOR DX, DX
        MOV DL, [DI]
        ADD AX, DX
        
        MOV DL, [DI + 2]                        ; �������� ���� �� �����������
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
        
        MOV DL, [DI + 3]                        ; �������� ���� �� ���������
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
        LEA SI, player                          ; �������� �� ������������ � �������
        MOV AL, BYTE PTR [DI]
        CMP BYTE PTR [SI], AL
        JNE MineNotCollision                    ; ���� ��� ������������
        MOV AL, [DI + 1]
        CMP [SI + 1], AL
        JNE MineNotCollision                    ; ���� ���� ������������
            CALL Collision                        
                  
        MineNotCollision:                       ; ���� ������������ ���
                                      
        RET 00H                                 ; ������� � ����� ������
    MineMovement ENDP    
    
    PlayerMovement PROC
        LEA DI, player
        MOV AH, [DI + 2]
        CMP AH, 1                               ; �������� �����
        JNE NotUp
            MOV AL, [DI + 1]
            CMP AL, 0
            JE StopMovement
            SUB [DI + 1], 1
            JMP NotLeft
        NotUp:
        CMP AH, 2                               ; �������� ������
        JNE NotRight
            MOV AL, [DI]
            CMP AL, 79
            JE StopMovement
            ADD [DI], 1
            JMP NotLeft
        NotRight:
        CMP AH, 3                               ; �������� ����
        JNE NotDown
            MOV AL, [DI + 1]
            CMP AL, 22
            JE StopMovement
            ADD [DI + 1], 1
            JMP NotLeft
        NotDown:
        CMP AH, 4                               ; �������� �����
        JNE NotLeft
            MOV AL, [DI]
            CMP AL, 0
            JE StopMovement
            SUB [DI], 1
            JMP NotLeft
        StopMovement:
            MOV [DI + 2], 0    
        NotLeft:
        
        LEA SI, firstEnemy                      ; �������� �� ������������ � 1�� ������
        MOV AL, [SI]
        CMP [DI], AL
        JNE NoCollisionWithFirstEnemy
            MOV AL, [SI + 1]
            CMP [DI + 1], AL
            JNE NoCollisionWithFirstEnemy
                CALL Collision
                JMP GoResult
        NoCollisionWithFirstEnemy:
        LEA SI, secondEnemy                     ; �������� �� ������������ �� 2�� ������
        MOV AL, [SI]
        CMP [DI], AL
        JNE NoCollisionWithSecondEnemy
            MOV AL, [SI + 1]
            CMP [DI + 1], AL
            JNE NoCollisionWithSecondEnemy
                CALL Collision
                JMP GoResult
        NoCollisionWithSecondEnemy:
        LEA SI, thirdEnemy                      ; �������� �� ������������ � 3�� ������
        MOV AL, [SI]
        CMP [DI], AL
        JNE NoCollisionWithThirdEnemy
            MOV AL, [SI + 1]
            CMP [DI + 1], AL
            JNE NoCollisionWithThirdEnemy
                CALL Collision
                JMP GoResult
        NoCollisionWithThirdEnemy:
        LEA SI, fourthEnemy                     ; �������� �� ������������ � 4�� ������
        MOV AL, [SI]
        CMP [DI], AL
        JNE NoCollisionWithFourthEnemy
            MOV AL, [SI + 1]
            CMP [DI + 1], AL
            JNE NoCollisionWithFourthEnemy
                CALL Collision
                JMP GoResult
        NoCollisionWithFourthEnemy:
        LEA SI, mine                            ; �������� �� ������������ � �����
        MOV AL, [SI]
        CMP [DI], AL
        JNE NoCollisionWithMine
            MOV AL, [SI + 1]
            CMP [DI + 1], AL
            JNE NoCollisionWithMine
                CALL Collision
                JMP GoResult
        NoCollisionWithMine:
                                                
        LEA DI, player                          ; �������� �� ������������ � ������
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
            
        RET 00H                                 ; ������� � ����� ������
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
        
        RET 00H                                 ; ������� � ����� ������
    SandDrawing ENDP
    
    Translate PROC                              ; ������� ������ �������� � ����� ����� �� ����� �����
        LEA DI, playerLine
        LEA SI, wallsMassive
        MOV BX, 160
        MOV CX, 1520
        
        TranslateCycle:
            CMP [DI + BX], 0                    ; ���� ���������� ������ ��� �������� �������, �� �����������
            JNE TranslateNot0
                MOV [SI + BX], 1                ; �������� ����� � ��� ������
            TranslateNot0:
            CMP [DI + BX], 1                    ; ���� � ��� ���������� ������
            JNE TranslateNot1                                         
                MOV [SI + BX], 1                ; �������� ����� � ��� ������
            TranslateNot1:
            INC BX
        LOOP TranslateCycle
        
        RET 00H                                 ; ������� � ����� ������
    Translate ENDP
    
    SandToWalls PROC                            ; ������� ����� � �����                                                 
        WallSand wallsMassive                   ; ���������� ����� �� ����� �����
        EnemySand firstEnemy                    ; ���������� ������ �� ����� �����
        EnemySand secondEnemy                   ; ���������� ������ �� ����� �����
        EnemySand thirdEnemy                    ; ���������� ������ �� ����� �����
        EnemySand fourthEnemy                   ; ���������� ������ �� ����� �����
        
        LEA DI, playerLine
        EnemiesCycle:                           ; ��������� ������ ������� ������� �� ����
            MOV BX, 160
            MOV CX, 1520
            EnemiesMultiplication:              ; ���� ��������� ������
                CMP [DI + BX], 3                ; ���� �� �� ������ � ������
                JNE NotAnEnemy
                    CMP [DI + BX - 80 - 1], 0   ; ���� �������� ����� ������� ������
                    JNE NotFree1:
                        MOV [DI + BX - 80 - 1], 3   ; ������� ����� � ��� ������ 
                        MOV enemyflag, 1        ; ������ ���� ��������
                    NotFree1:
                    CMP [DI + BX - 80], 0       ; ���� �������� ������� ������
                    JNE NotFree2:
                        MOV [DI + BX - 80], 3   ; ������� ����� � ��� ������
                        MOV enemyflag, 1        ; ������ ���� ��������
                    NotFree2:
                    CMP [DI + BX - 80 + 1], 0   ; ���� �������� ������ ������� ������
                    JNE NotFree3:
                        MOV [DI + BX - 80 + 1], 3   ; ������� ����� � ��� ������
                        MOV enemyflag, 1        ; ������ ���� ��������
                    NotFree3:
                    CMP [DI + BX - 1], 0        ; ���� ����� ������   
                    JNE NotFree4:
                        MOV [DI + BX - 1], 3    ; ������� ����� � ��� ������
                        MOV enemyflag, 1        ; ������ ���� ��������
                    NotFree4:
                    CMP [DI + BX + 1], 0        ; ���� �������� ������ ������            
                    JNE NotFree5:     
                        MOV [DI + BX + 1], 3    ; ������� ����� � ��� ������
                        MOV enemyflag, 1        ; ������ ���� ��������
                    NotFree5:
                    CMP [DI + BX + 80 - 1], 0   ; ���� �������� ����� ������ ������        
                    JNE NotFree6:     
                        MOV [DI + BX + 80 - 1], 3   ; ������� ����� � ��� ������
                        MOV enemyflag, 1        ; ������ ���� ��������
                    NotFree6:
                    CMP [DI + BX + 80], 0       ; ���� �������� ������ ������       
                    JNE NotFree7:
                        MOV [DI + BX + 80], 3   ; ������� ����� � ��� ������
                        MOV enemyflag, 1        ; ������ ���� ��������
                    NotFree7:
                    CMP [DI + BX + 80 + 1], 0   ; ���� �������� ������ ������ ������    
                    JNE NotFree8:
                        MOV [DI + BX + 80 + 1], 3   ; ������� ����� � ��� ������
                        MOV enemyflag, 1        ; ������ ���� ��������
                    NotFree8:
                NotAnEnemy:                     ; ���� �� �� �� ������ � ������
                INC BX    
            LOOP EnemiesMultiplication
            CMP enemyFlag, 1                    ; ���� ����� ����� �� ������������, �� ������� �� �����
            JNE EndEnemiesCycle
                MOV enemyflag, 0                ; ���������� ���� � �������� (0) ���������
        JMP EnemiesCycle:
        EndEnemiesCycle:
        
        CAll translate                          ; ������� ������������� �������� �� ����� �����
        CALL StartSandDrawing                   ; ��������� ��������� �����
            
        RET 00H                                 ; ������� � ����� ������
    SandToWalls ENDP
    
    PercentCount PROC                           ; ������� �������� �����������
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
        
        RET 00H                                 ; ������� � ����� ������
    PercentCount ENDP
    
    PercentRender PROC                          ; ��������� �������� �����������
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
        
        RET 00H                                 ; ������� � ����� ������
    PercentRender ENDP
    
    Render PROC                                 ; ��������� ���������
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
        MOV BYTE PTR [DI], 12                   ; ���������� ������ �������� �����
        POP DS
        
        CALL PercentRender                      ; ��������� �������� �����������
        
        RET 00H                                 ; ������� � ����� ������
    Render ENDP
    
    StartGame: 
        MOV AX, @data
        MOV DS, AX
        
        MOV AH, 00H                             ; ��������� 3 �����������
        MOV AL, 03H                             ; ��������� 3 �����������
        INT 10H                                 ; ��������� 3 �����������
        
        MOV AH, 02H                             ; �������� ������
        MOV BH, 0                               ; �������� ������
        MOV DH, 25                              ; �������� ������
        MOV DL, 0                               ; �������� ������
        INT 10H                                 ; �������� ������
        
        CALL StartWallDrawing                   ; ��������� ��������� �����
        CALL StartSandDrawing                   ; ��������� ��������� �����
        
        LEA DI, player                          ; ��������� ���������� ��������� ������
        MOV WORD PTR [DI], 0                    ; ��������� ���������� ��������� ������
        MOV WORD PTR [DI + 1], 0                ; ��������� ���������� ��������� ������
        MOV WORD PTR [DI + 2], 0                ; ��������� ���������� ��������� ������
        
        CALL StartEnemyProperty                 ; ��������� ��������� ������� ������
        
        MOV percent, 0                          ; ��������� ������� ����������� ������
        MOV live, 9                             ; ��������� ���������� ������
        
        GameCycle:
            CALL FinalRenderFrame               ; ��������� �����
            CALL Render                         ; �������� ����� �������������
            
            LEA DI, firstEnemy                  ; �������� 1��� �����
            CALL EnemiesMovement                ; �������� 1��� �����
            CMP live, 0
            JE GameOver
            LEA DI, secondEnemy                 ; �������� 2��� �����
            CALL EnemiesMovement                ; �������� 2��� �����
            CMP live, 0
            JE GameOver
            LEA DI, thirdEnemy                  ; �������� 3��� �����
            CALL EnemiesMovement                ; �������� 3��� �����
            CMP live, 0
            JE GameOver
            LEA DI, fourthEnemy                 ; �������� 4��� �����
            CALL EnemiesMovement                ; �������� 4��� �����
            CMP live, 0
            JE GameOver
            
            CALL MineMovement                   ; �������� ����
            CMP live, 0
            JE GameOver
            
            MOV AH, 01H                         ; �������� ����������
            INT 16H                             ; �������� ����������
            JZ ButtonNotPressed                 ; ���� ������� �� ���� ������
            MOV AH, 00H
            INT 16H
            CMP AL, 'a'                         ; �����
            JNE NotA
                PlayerMovementDirection player, 4
                JMP ButtonNotPressed
            NotA:
            CMP AL, 'w'                         ; �����
            JNE NotW
                PlayerMovementDirection player, 1
                JMP ButtonNotPressed
            NotW:
            CMP AL, 'd'                         ; ������
            JNE NotD
                PlayerMovementDirection player, 2
                JMP ButtonNotPressed
            NotD:
            CMP AL, 's'                         ; ����
            JNE NotS
                PlayerMovementDirection player, 3
                JMP ButtonNotPressed
            NotS:
            CMP AL, 'r'                         ; �������
            JNE NotR
                JMP StartGame
            NotR:
            CMP AL, '+'                         ; ���������� ���������
            JNE NotPlus
                SpeedUp
                JMP ButtonNotPressed
            NotPlus:
            CMP AL, '-'                         ; ���������� ���������
            JNE NotMinus
                SpeedDown
                JMP ButtonNotPressed
            NotMinus:
            CMP AL, 27                          ; ESC
            JNE ButtonNotPressed          
                JMP Exit
            ButtonNotPressed:
            
            CALL PlayerMovement                 ; ��������� �������� ������
            CMP live, 0
            JE GameOver
            CALL SandDrawing                    ; ��������� �����
            
            CALL percentCount                   ; ������ �������� �����������
            
            CMP percent, 90                     ; ���� ���� ��������
            JG YouWin                           ; ���� ���� ��������
            
            delay speed                         ; �������� �� speed �����������
            delay speed                         ; �������� �� speed �����������
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
            CMP AL, ' '                         ; ������ ������
            JNE NotSpace
                JMP StartGame
            NotSpace:
            CMP AL, 27                          ; �����
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
            CMP AL, ' '                         ; ������ ������
            JNE NotSpaceWin
                JMP StartGame
            NotSpaceWin:
            CMP AL, 27                          ; �����
            JNE NotExitWin
                JMP Exit
            NotExitWin:
                JMP GameOver
        
        Exit:
            MOV AH, 00H                         ; ��������� 2 �����������
            MOV AL, 02H                         ; ��������� 2 �����������
            INT 10H  
        
            XOR AX, AX                          ; ������� ������
            MOV AH, 07H                         ; ������� ������
            INT 10H                             ; ������� ������
        
        MOV AX, 4C00H
        INT 21H
    
    end StartGame