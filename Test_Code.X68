*-----------------------------------------------------------
* Title      : Test Code file for Dissasembler
* Date       : 3/14/2019
*-----------------------------------------------------------


*Start of Move test code.***************************************************
****************************************************************************
*Done
*    MOVE.L  #$123,D5
*    MOVE.L  D1,D2
*    MOVE.L  A5,D4
*    MOVE.L  (A4),D3
*    MOVE.L  (A7)+,D3
*    MOVE.L  -(A0),D7
*    MOVE.L  $0,D3
*    MOVE.L  $FFF,D1
*    MOVE.L  $8000,D2
*    MOVE.L  $20000,D3
*    
*    MOVE.L  #$123,(A4)
*    MOVE.L  D1,(A4)
*    MOVE.L  A5,(A4)
*    MOVE.L  (A4),(A4)
*    MOVE.L  (A7)+,(A4)
*    MOVE.L  -(A0),(A4)
*    MOVE.L  $0,(A4)
*    MOVE.L  $FFF,(A4)
*    MOVE.L  $8000,(A4)
*    MOVE.L  $20000,(A4)
*    
*    MOVE.L  #$123,(A4)+
*    MOVE.L  D1,(A4)+
*    MOVE.L  A5,(A4)+
*    MOVE.L  (A4),(A4)+
*    MOVE.L  (A7)+,(A4)+
*    MOVE.L  -(A0),(A4)+
*    MOVE.L  $0,(A4)+
*    MOVE.L  $FFF,(A4)+
*    MOVE.L  $8000,(A4)+
*    MOVE.L  $20000,(A4)+
*    
*    MOVE.L  #$123,-(A4)
*    MOVE.L  D1,-(A4)
*    MOVE.L  A5,-(A4)
*    MOVE.L  (A4),-(A4)
*    MOVE.L  (A7)+,-(A4)
*    MOVE.L  -(A0),-(A4)
*    MOVE.L  $0,-(A4)
*    MOVE.L  $FFF,-(A4)
*    MOVE.L  $8000,-(A4)
*    MOVE.L  $20000,-(A4)
*    
*    MOVE.L  #$123,$0
*    MOVE.L  D1,$0
*    MOVE.L  A5,$0
*    MOVE.L  (A4),$0
*    MOVE.L  (A7)+,$0
*    MOVE.L  -(A0),$0
*    MOVE.L  $0,$0
*    MOVE.L  $FFF,$0
*    MOVE.L  $8000,$0
*    MOVE.L  $20000,$0
*    
*    MOVE.L  #$123,$8000
*    MOVE.L  D1,$8000
*    MOVE.L  A5,$8000
*    MOVE.L  (A4),$8000
*    MOVE.L  (A7)+,$8000
*    MOVE.L  -(A0),$8000
*    MOVE.L  $0,$8000
*    MOVE.L  $FFF,$8000
*    MOVE.L  $8000,$8000
*    MOVE.L  $20000,$8000
*    
*    MOVE.L  #$123,$21000
*    MOVE.L  D1,$21000
*    MOVE.L  A5,$21000
*    MOVE.L  (A4),$21000
*    MOVE.L  (A7)+,$21000
*    MOVE.L  -(A0),$21000
*    MOVE.L  $0,$21000
*    MOVE.L  $FFF,$21000
*    MOVE.L  $8000,$21000
*    MOVE.L  $20000,$21000
*    
*    MOVE.W  #$123,D5
*    MOVE.W  D1,D2
*    MOVE.W  A5,D4
*    MOVE.W  (A4),D3
*    MOVE.W  (A7)+,D3
*    MOVE.W  -(A0),D7
*    MOVE.W  $0,D3
*    MOVE.W  $FFF,D1
*    MOVE.W  $8000,D2
*    MOVE.W  $20000,D3
*    
*    MOVE.W  #$123,(A4)
*    MOVE.W  D1,(A4)
*    MOVE.W  A5,(A4)
*    MOVE.W  (A4),(A4)
*    MOVE.W  (A7)+,(A4)
*    MOVE.W  -(A0),(A4)
*    MOVE.W  $0,(A4)
*    MOVE.W  $FFF,(A4)
*    MOVE.W  $8000,(A4)
*    MOVE.W  $20000,(A4)
*    
*    MOVE.W  #$123,(A4)+
*    MOVE.W  D1,(A4)+
*    MOVE.W  A5,(A4)+
*    MOVE.W  (A4),(A4)+
*    MOVE.W  (A7)+,(A4)+
*    MOVE.W  -(A0),(A4)+
*    MOVE.W  $0,(A4)+
*    MOVE.W  $FFF,(A4)+
*    MOVE.W  $8000,(A4)+
*    MOVE.W  $20000,(A4)+
*    
*    MOVE.W  #$123,-(A4)
*    MOVE.W  D1,-(A4)
*    MOVE.W  A5,-(A4)
*    MOVE.W  (A4),-(A4)
*    MOVE.W  (A7)+,-(A4)
*    MOVE.W  -(A0),-(A4)
*    MOVE.W  $0,-(A4)
*    MOVE.W  $FFF,-(A4)
*    MOVE.W  $8000,-(A4)
*    MOVE.W  $20000,-(A4)
*    
*    MOVE.W  #$123,$0
*    MOVE.W  D1,$0
*    MOVE.W  A5,$0
*    MOVE.W  (A4),$0
*    MOVE.W  (A7)+,$0
*    MOVE.W  -(A0),$0
*    MOVE.W  $0,$0
*    MOVE.W  $FFF,$0
*    MOVE.W  $8000,$0
*    MOVE.W  $20000,$0
*    
*    MOVE.W  #$123,$8000
*    MOVE.W  D1,$8000
*    MOVE.W  A5,$8000
*    MOVE.W  (A4),$8000
*    MOVE.W  (A7)+,$8000
*    MOVE.W  -(A0),$8000
*    MOVE.W  $0,$8000
*    MOVE.W  $FFF,$8000
*    MOVE.W  $8000,$8000
*    MOVE.W  $20000,$8000
*    
*    MOVE.W  #$123,$21000
*    MOVE.W  D1,$21000
*    MOVE.W  A5,$21000
*    MOVE.W  (A4),$21000
*    MOVE.W  (A7)+,$21000
*    MOVE.W  -(A0),$21000
*    MOVE.W  $0,$21000
*    MOVE.W  $FFF,$21000
*    MOVE.W  $8000,$21000
*    MOVE.W  $20000,$21000
*    
*    MOVE.B  #$13,D5
*    MOVE.B  D1,D2
*
*    MOVE.B  (A4),D3
*    MOVE.B  (A7)+,D3
*    MOVE.B  -(A0),D7
*    MOVE.B  $0,D3
*    MOVE.B  $FFF,D1
*    MOVE.B  $8000,D2
*    MOVE.B  $20000,D3
*    
*    MOVE.B  #$13,(A4)
*    MOVE.B  D1,(A4)
*    
*    MOVE.B  (A4),(A4)
*    MOVE.B  (A7)+,(A4)
*    MOVE.B  -(A0),(A4)
*    MOVE.B  $0,(A4)
*    MOVE.B  $FFF,(A4)
*    MOVE.B  $8000,(A4)
*    MOVE.B  $20000,(A4)
*    
*    MOVE.B  #$13,(A4)+
*    MOVE.B  D1,(A4)+
*
*    MOVE.B  (A4),(A4)+
*    MOVE.B  (A7)+,(A4)+
*    MOVE.B  -(A0),(A4)+
*    MOVE.B  $0,(A4)+
*    MOVE.B  $FFF,(A4)+
*    MOVE.B  $8000,(A4)+
*    MOVE.B  $20000,(A4)+
*    
*    MOVE.B  #$13,-(A4)
*    MOVE.B  D1,-(A4)
*
*    MOVE.B  (A4),-(A4)
*    MOVE.B  (A7)+,-(A4)
*    MOVE.B  -(A0),-(A4)
*    MOVE.B  $0,-(A4)
*    MOVE.B  $FFF,-(A4)
*    MOVE.B  $8000,-(A4)
*    MOVE.B  $20000,-(A4)
*   
*    MOVE.B  #$13,$0
*    MOVE.B  D1,$0
*
*    MOVE.B  (A4),$0
*    MOVE.B  (A7)+,$0
*    MOVE.B  -(A0),$0
*    MOVE.B  $0,$0
*    MOVE.B  $FFF,$0
*    MOVE.B  $8000,$0
*    MOVE.B  $20000,$0
*    
*    MOVE.B  #$0,$8000
*    MOVE.B  D1,$8000
*
*    MOVE.B  (A4),$8000
*    MOVE.B  (A7)+,$8000
*    MOVE.B  -(A0),$8000
*    MOVE.B  $0,$8000
*    MOVE.B  $FFF,$8000
*    MOVE.B  $8000,$8000
*    MOVE.B  $20000,$8000
*    
*    MOVE.B  #$FF,$21000
*    MOVE.B  D1,$21000
*
*    MOVE.B  (A4),$21000
*    MOVE.B  (A7)+,$21000
*    MOVE.B  -(A0),$21000
*    MOVE.B  $0,$21000
*    MOVE.B  $FFF,$21000
*    MOVE.B  $8000,$21000
*    MOVE.B  $20000,$21000
*    
*End of Move test code. *****************************************************
*****************************************************************************

*Start of MOVEA test code.***************************************************
*****************************************************************************
*Done.
    MOVEA.W   D2,A2
    MOVEA.W   A5,A3
    MOVEA.W   (A4)+,A3
    MOVEA.W   -(A2),A5
    MOVEA.W   $0,A3
    MOVEA.W   $1234,A3
    MOVEA.W   $8000,A3
    MOVEA.W   $FFFFFF,A7
    MOVEA.W   #$0,A3
    MOVEA.W   #$1000,A3
    MOVEA.W   #$8000,A6
    
    MOVEA.L   D2,A2
    MOVEA.L   A5,A3
    MOVEA.L   (A4)+,A3
    MOVEA.L   -(A2),A5
    MOVEA.L   $0,A3
    MOVEA.L   $1234,A3
    MOVEA.L   $8000,A3
    MOVEA.L   $FFFFFF,A7
    MOVEA.L   #$0,A3
    MOVEA.L   #$1000,A3
    MOVEA.L   #$8000,A6
    MOVEA.L   #$FFFF8000,A6
*End of MOVEA test code.****************************************************
****************************************************************************

*Start of ADDI test code.*****************************************************************************
******************************************************************************************************
*Done
    ADDI.L   #4,D1   *Assembler changes this to ADDQ unless the number being added is greater than #8.
    ADDI.L   #9,D1
    ADDI.L   #0,D1
    ADDI.L   #$FFFFFFFF,D7
    ADDI.W   #$FFFF,D5
    ADDI.W   #$0,D5
    ADDI.W   #$9,D4
    ADDI.B   #$FF,D3
    ADDI.B   #$9,D3
    ADDI.B   #$0,D3
    
    ADDI.L   #4,(A1)
    ADDI.L   #9,(A1)
    ADDI.L   #0,(A1)
    ADDI.L   #$FFFFFFFF,(A1)
    ADDI.W   #$FFFF,(A1)
    ADDI.W   #$0,(A1)
    ADDI.W   #$9,(A1)
    ADDI.B   #$FF,(A1)
    ADDI.B   #$9,(A1)
    ADDI.B   #$0,(A1)
    
    ADDI.L   #4,(A1)+
    ADDI.L   #9,(A1)+
    ADDI.L   #0,(A1)+
    ADDI.L   #$FFFFFFFF,(A1)+
    ADDI.W   #$FFFF,(A1)+
    ADDI.W   #$0,(A1)+
    ADDI.W   #$9,(A1)+
    ADDI.B   #$FF,(A1)+
    ADDI.B   #$9,(A1)+
    ADDI.B   #$0,(A1)+
    
    ADDI.L   #4,-(A1)
    ADDI.L   #9,-(A1)
    ADDI.L   #0,-(A1)
    ADDI.L   #$FFFFFFFF,-(A1)
    ADDI.W   #$FFFF,-(A1)
    ADDI.W   #$0,-(A1)
    ADDI.W   #$9,-(A1)
    ADDI.B   #$FF,-(A1)
    ADDI.B   #$9,-(A1)
    ADDI.B   #$0,-(A1)
    
    ADDI.L   #4,$20
    ADDI.L   #9,$20000
    ADDI.L   #0,$8000
    ADDI.L   #$FFFFFFFF,$20
    ADDI.W   #$FFFF,$20
    ADDI.W   #$0,$20000
    ADDI.W   #$9,$8000
    ADDI.B   #$FF,$8000
    ADDI.B   #$9,$20000
    ADDI.B   #$0,$20
*End of ADDI test code.*****************************************************
****************************************************************************

*Start of NOP test code.****************************************************
****************************************************************************
*Done
*    NOP
*End of NOP test code.******************************************************
****************************************************************************

*Start of RTS test code.****************************************************
****************************************************************************
*Done
*    RTS
*End of RTS test code.
****************************************************************************

*Start of LEA test code.****************************************************
****************************************************************************
*Done
    LEA $0,A0
    LEA $1000,A1
    LEA $8000,A2
    LEA $FFFF0000,A3
    LEA (A4),A5  
*End of LEA test code.******************************************************
****************************************************************************

*Start of CLR test code.****************************************************
****************************************************************************
*Done
    CLR.B   D0
    CLR.B   (A2)
    CLR.B   (A3)+
    CLR.B   -(A4)
    CLR.B   $0
    CLR.B   $1000
    CLR.B   $8000
    CLR.B   $FFEF0000
    
    CLR.W   D0
    CLR.W   (A2)
    CLR.W   (A3)+
    CLR.W   -(A4)
    CLR.W   $0
    CLR.W   $1000
    CLR.W   $8000
    CLR.W   $FFEF0000
    
    CLR.L   D0
    CLR.L   (A2)
    CLR.L   (A3)+
    CLR.L   -(A4)
    CLR.L   $0
    CLR.L   $1000
    CLR.L   $8000
    CLR.L   $FFEF0000
    
*End of CLR test code.******************************************************
****************************************************************************

*Start of JSR test code.****************************************************
****************************************************************************
*Done
    JSR     (A6)
    JSR     $0
    JSR     $1000
    JSR     $8000
    JSR     $FFEE0000
*End of JSR test code.******************************************************
****************************************************************************

*Start of MOVEM test code.**************************************************
****************************************************************************
*Done
    MOVEM.W     (A7),D1-D7
    MOVEM.L     (A6),D2-D7
    MOVEM.W     (A7),A1-A7
    MOVEM.L     (A6),A2-A7
    MOVEM.W     (A5)+,D3-D7
    MOVEM.L     (A4)+,D7-D7
    MOVEM.W     (A5)+,A3-A7
    MOVEM.L     (A4)+,A7-A7
    MOVEM.W     $20000,D1-D7
    MOVEM.L     $20000,D2-D7
    MOVEM.W     $100,A1-A7
    MOVEM.L     $100,A2-A7
    
    MOVEM.L     D1-D7,-(A3)
    MOVEM.L     A1-A7,-(A2)
    MOVEM.W     D3-D4,-(A1)
    MOVEM.W     A1-A7,-(A0)
    MOVEM.L     D1-D7,(A3)
    MOVEM.L     A1-A7,(A2)
    MOVEM.W     D3-D4,(A1)
    MOVEM.W     A1-A7,(A0)
    MOVEM.L     D1-D7,$20000
    MOVEM.L     A1-A7,$100
    MOVEM.W     D3-D4,$20000
    MOVEM.W     A1-A7,$100
*End of MOVEM test code.******************************************************
******************************************************************************

*Start of ADDQ test code.*****************************************************
******************************************************************************
*Done
    ADDQ.B      #1,D0

    ADDQ.B      #3,(A6)
    ADDQ.B      #4,(A5)+
    ADDQ.B      #5,-(A4)
    ADDQ.B      #7,$0
    ADDQ.B      #8,$1000
    ADDQ.B      #8,$8000
    ADDQ.B      #8,$FFFF0001
    
    ADDQ.W      #1,D0
    ADDQ.W      #2,A7
    ADDQ.W      #3,(A6)
    ADDQ.W      #4,(A5)+
    ADDQ.W      #5,-(A4)
    ADDQ.W      #7,$0
    ADDQ.W      #8,$1000
    ADDQ.W      #8,$8000
    ADDQ.W      #8,$FFFF0001
    
    ADDQ.L      #1,D0
    ADDQ.L      #2,A7
    ADDQ.L      #3,(A6)
    ADDQ.L      #4,(A5)+
    ADDQ.L      #5,-(A4)
    ADDQ.L      #7,$0
    ADDQ.L      #8,$1000
    ADDQ.L      #8,$8000
    ADDQ.L      #8,$FFFF0001
*End of ADDQ test code.*******************************************************
******************************************************************************

*Start of required BCC test code.*********************************************
******************************************************************************
*Done
    BCC         $6100
    BCC         $20
    BCC         $FF
    BCC         $FFFFFF00
    
    BGT         $6100
    BGT         $20
    BGT         $FF
    BGT         $FFFFFF00
    
    BLE         $6100
    BLE         $20
    BLE         $FF
    BLE         $FFFFFF00

    BHI         $6100
    BHI         $20
    BHI         $FF
    BHI         $FFFFFF00
    
    BLS         $6100
    BLS         $20
    BLS         $FF
    BLS         $FFFFFF00
    
    BCS         $6100
    BCS         $20
    BCS         $FF
    BCS         $FFFFFF00
    
    BNE         $6100
    BNE         $20
    BNE         $FF
    BNE         $FFFFFF00
    
    BEQ         $6100
    BEQ         $20
    BEQ         $FF
    BEQ         $FFFFFF00
    
    BVC         $6100
    BVC         $20
    BVC         $FF
    BVC         $FFFFFF00
    
    BVS         $6100
    BVS         $20
    BVS         $FF
    BVS         $FFFFFF00
    
    BPL         $6100
    BPL         $20
    BPL         $FF
    BPL         $FFFFFF00
    
    BMI         $6100
    BMI         $20
    BMI         $FF
    BMI         $FFFFFF00
    
    BGE         $6100
    BGE         $20
    BGE         $FF
    BGE         $FFFFFF00
    
    BLT         $6100
    BLT         $20
    BLT         $FF
    BLT         $FFFFFF00
    
        BMI         $8FF0
    BMI         $8FEF
    BMI         $8FEE
    BMI         $8FED    
    
    BGE         $9000
    BGE         $9010
    BGE         $9011
    BGE         $9012
    
    BLT         $8FFE
    BLT         $9000
    BLT         $9000
    BLT         $9000
    
    BNE         $6100
    BNE         $6100
    BNE         $6100
    BNE         $6100
    
    BEQ         $6100
    BEQ         $6100
    BEQ         $6100
    BEQ         $6100

    BMI         $FFFE
    BMI         $FFFE
    BMI         $FFFE
    BMI         $FFFE
    BMI         $FFFE
    BMI         $FFFE
    
*End of BCC test code.**************************************************
******************************************************************************

*Start of OR test code.*******************************************************
******************************************************************************
**Done
*    OR.B        D1,D4
*    OR.B        (A5),D5
*    OR.B        (A3)+,D6
*    OR.B        -(A2),D7
*    OR.B        $0,D6
*    OR.B        $1000,D0
*    OR.B        $8000,D1
*    OR.B        $FF0FF0FF,D2
*    OR.B        #0,D3
*    OR.B        #$FF,D4
*    OR.B        D0,(A1)
*    OR.B        D2,(A3)+
*    OR.B        D4,-(A5)
*    OR.B        D6,$0
*    OR.B        D0,$1000
*    OR.B        D1,$8000
*    OR.B        D2,$FF0FF0FF
*    
*    OR.W        D1,D4
*    OR.W        (A5),D5
*    OR.W        (A3)+,D6
*    OR.W        -(A2),D7
*    OR.W        $0,D6
*    OR.W        $1000,D0
*    OR.W        $8000,D1
*    OR.W        $FF0FF0FF,D2
*    OR.W        #0,D3
*    OR.W        #$FF,D4
*    OR.W        #$23FF,D4
*    OR.W        D0,(A1)
*    OR.W        D2,(A3)+
*    OR.W        D4,-(A5)
*    OR.W        D6,$0
*    OR.W        D0,$1000
*    OR.W        D1,$8000
*    OR.W        D2,$FF0FF0FF
**    
*    OR.L        D1,D4
*    OR.L        (A5),D5
*    OR.L        (A3)+,D6
*    OR.L        -(A2),D7
*    OR.L        $0,D6
*    OR.L        $1000,D0
*    OR.L        $8000,D1
*    OR.L        $FF0FF0FF,D2
*    OR.L        #0,D3
*    OR.L        #$FF,D4
*    OR.L        #$23FF,D4
*    OR.L        #$FF0023FF,D4
*    OR.L        D0,(A1)
*    OR.L        D2,(A3)+
*    OR.L        D4,-(A5)
*    OR.L        D6,$0
*    OR.L        D0,$1000
*    OR.L        D1,$8000
*    OR.L        D2,$FF0FF0FF

*End of OR test code.*********************************************************
******************************************************************************

*Start of SUB test code.******************************************************
******************************************************************************
*Done
*    SUB.B        D1,D4
*    SUB.B        (A5),D5
*    SUB.B        (A3)+,D6
*    SUB.B        -(A2),D7
*    SUB.B        $0,D6
*    SUB.B        $1000,D0
*    SUB.B        $8000,D1
*    SUB.B        $FF0FF0FF,D2
*    SUB.B        D0,(A1)
*    SUB.B        D2,(A3)+
*    SUB.B        D4,-(A5)
*    SUB.B        D6,$0
*    SUB.B        D0,$1000
*    SUB.B        D1,$8000
*    SUB.B        D2,$FF0FF0FF
*    
*    SUB.W        D1,D4
**    SUB.W        A1,D0        FOR SOME REASON THIS BRAKES THINGS
*    SUB.W        (A5),D5
*    SUB.W        (A3)+,D6
*    SUB.W        -(A2),D7
*    SUB.W        $0,D6
*    SUB.W        $1000,D0
*    SUB.W        $8000,D1
*    SUB.W        $FF0FF0FF,D2
*    SUB.W        D0,(A1)
*    SUB.W        D2,(A3)+
*    SUB.W        D4,-(A5)
*    SUB.W        D6,$0
*    SUB.W        D0,$1000
*    SUB.W        D1,$8000
*    SUB.W        D2,$FF0FF0FF
*    
*    SUB.L        D1,D4
**    SUB.L        A2,D0
*    SUB.L        (A5),D5
*    SUB.L        (A3)+,D6
*    SUB.L        -(A2),D7
*    SUB.L        $0,D6
*    SUB.L        $1000,D0
*    SUB.L        $8000,D1
*    SUB.L        $FF0FF0FF,D2
*    SUB.L        D0,(A1)
*    SUB.L        D2,(A3)+
*    SUB.L        D4,-(A5)
*    SUB.L        D6,$0
*    SUB.L        D0,$1000
*    SUB.L        D1,$8000
*    SUB.L        D2,$FF0FF0FF
    
*End of SUB test code.********************************************************
******************************************************************************

*Start of CMP test code.******************************************************
******************************************************************************

    CMP.B        D1,D4
    CMP.B        (A5),D5
    CMP.B        (A3)+,D6
    CMP.B        -(A2),D7
    CMP.B        $0,D6
    CMP.B        $1000,D0
    CMP.B        $8000,D1
    CMP.B        $FF0FF0FF,D2
    CMP.B        #0,D3
    CMP.B        #$FF,D4
    
    CMP.W        D1,D4
*    CMP.W        A1,D0        FOR SOME REASON THIS BRAKES THINGS
    CMP.W        (A5),D5
    CMP.W        (A3)+,D6
    CMP.W        -(A2),D7
    CMP.W        $0,D6
    CMP.W        $1000,D0
    CMP.W        $8000,D1
    CMP.W        $FF0FF0FF,D2
    CMP.W        #0,D3
    CMP.W        #$FF,D4
    CMP.W        #$23FF,D4
    
    CMP.L        D1,D4
*    CMP.L        A2,D0        FOR SOME REASON THIS BRAKES THINGS
    CMP.L        (A5),D5
    CMP.L        (A3)+,D6
    CMP.L        -(A2),D7
    CMP.L        $0,D6
    CMP.L        $1000,D0
    CMP.L        $8000,D1
    CMP.L        $FF0FF0FF,D2
    CMP.L        #0,D3
    CMP.L        #$FF,D4
    CMP.L        #$23FF,D4
    CMP.L        #$FF0023FF,D4
*End of CMP test code.********************************************************
******************************************************************************

*Start of ADD test code.******************************************************
******************************************************************************
*Done
    ADD.B        D1,D4
    ADD.B        (A5),D5
    ADD.B        (A3)+,D6
    ADD.B        -(A2),D7
    ADD.B        $0,D6
    ADD.B        $1000,D0
    ADD.B        $8000,D1
    ADD.B        $FF0FF0FF,D2
    ADD.B        #0,D3
    ADD.B        #$FF,D4
    ADD.B        D0,(A1)
    ADD.B        D2,(A3)+
    ADD.B        D4,-(A5)
    ADD.B        D6,$0
    ADD.B        D0,$1000
    ADD.B        D1,$8000
    ADD.B        D2,$FF0FF0FF
    
    ADD.W        D1,D4
    ADD.W        A1,D0
    ADD.W        (A5),D5
    ADD.W        (A3)+,D6
    ADD.W        -(A2),D7
    ADD.W        $0,D6
    ADD.W        $1000,D0
    ADD.W        $8000,D1
    ADD.W        $FF0FF0FF,D2
    ADD.W        #0,D3
    ADD.W        #$FF,D4
    ADD.W        #$23FF,D4
    ADD.W        D0,(A1)
    ADD.W        D2,(A3)+
    ADD.W        D4,-(A5)
    ADD.W        D6,$0
    ADD.W        D0,$1000
    ADD.W        D1,$8000
    ADD.W        D2,$FF0FF0FF
    
    ADD.L        D1,D4
    ADD.L        A2,D0
    ADD.L        (A5),D5
    ADD.L        (A3)+,D6
    ADD.L        -(A2),D7
    ADD.L        $0,D6
    ADD.L        $1000,D0
    ADD.L        $8000,D1
    ADD.L        $FF0FF0FF,D2
    ADD.L        #0,D3
    ADD.L        #$FF,D4
    ADD.L        #$23FF,D4
    ADD.L        #$FF0023FF,D4
    ADD.L        D0,(A1)
    ADD.L        D2,(A3)+
    ADD.L        D4,-(A5)
    ADD.L        D6,$0
    ADD.L        D0,$1000
    ADD.L        D1,$8000
    ADD.L        D2,$FF0FF0FF
*End of ADD test code.********************************************************
******************************************************************************

*Start of ADDA test code *************************************************
**************************************************************************
*Done.
    ADDA.L   #$11111111,A2
    ADDA.L   #$8000,A2
    ADDA.L   #$0,A2
    ADDA.L   #$1111,A2
    ADDA.L   $11111111,A2
    ADDA.L   $1111,A2
    ADDA.L   $0,A2
    ADDA.L   $1111,A1
    ADDA.L   D1,A7
    ADDA.L   A1,A6
    ADDA.L   (A0),A5
    ADDA.L   (A7)+,A4
    ADDA.L   -(A7),A4
    
    ADDA.W   #$1111,A2
    ADDA.W   #$8000,A2
    ADDA.W   #$0,A2
    ADDA.W   #$1111,A2
    ADDA.W   $11111111,A2
    ADDA.W   $1111,A2
    ADDA.W   $0,A2
    ADDA.W   $1111,A1
    ADDA.W   D1,A7
    ADDA.W   A1,A6
    ADDA.W   (A0),A5
    ADDA.W   (A7)+,A4
    ADDA.W   -(A7),A4
    
*End of ADDA test code.*****************************************************
****************************************************************************

*Start of MULS test code.*****************************************************
******************************************************************************
    MULS        D1,D7
    MULS        (A3),D6
    MULS        (A1)+,D3
    MULS        -(A7),D4
    MULS        $0,D6
    MULS        $1000,D4
    MULS        $8000,D4
    MULS        $FE00FE00,D4
    MULS        #$FFFF,D4
    MULS        #$FF,D4
*End of MULS test code.*******************************************************
******************************************************************************

*Start of Shift operation tests.**********************************************
******************************************************************************
*Done
    LSL.W     #1,D2
    ASR.W     #1,D2
    ASL.W     #1,D2
    ROL.W     #1,D2
    ROR.W     #1,D2
    LSL.W     #8,D2
    ASR.W     #8,D2
    ASL.W     #8,D2
    ROL.W     #8,D2
    ROR.W     #8,D2
     
    LSL.B     #1,D2
    ASR.B     #1,D2
    ASL.B     #1,D2
    ROL.B     #1,D2
    ROR.B     #1,D2
    LSL.B     #8,D2
    ASR.B     #8,D2
    ASL.B     #8,D2
    ROL.B     #8,D2
    ROR.B     #8,D2
    
    LSL.L     #1,D2
    ASR.L     #1,D2
    ASL.L     #1,D2
    ROL.L     #1,D2
    ROR.L     #1,D2
    LSL.L     #8,D2
    ASR.L     #8,D2
    ASL.L     #8,D2
    ROL.L     #8,D2
    ROR.L     #8,D2
    
    LSL.W     #1,D2
    ASR.W     #1,D2
    ASL.W     #1,D2
    ROL.W     #1,D2
    ROR.W     #1,D2
    LSL.W     #8,D2
    ASR.W     #8,D2
    ASL.W     #8,D2
    ROL.W     #8,D2
    ROR.W     #8,D2
     
    LSL.B     #1,D2
    ASR.B     #1,D2
    ASL.B     #1,D2
    ROL.B     #1,D2
    ROR.B     #1,D2
    LSL.B     #8,D2
    ASR.B     #8,D2
    ASL.B     #8,D2
    ROL.B     #8,D2
    ROR.B     #8,D2
    
    LSL.L     #1,D2
    ASR.L     #1,D2
    ASL.L     #1,D2
    ROL.L     #1,D2
    ROR.L     #1,D2
    LSL.L     #8,D2
    ASR.L     #8,D2
    ASL.L     #8,D2
    ROL.L     #8,D2
    ROR.L     #8,D2
    
    LSL.W     D1,D2
    ASR.W     D1,D2
    ASL.W     D1,D2
    ROL.W     D1,D2
    ROR.W     D1,D2
    LSL.W     D1,D2
    ASR.W     D1,D2
    ASL.W     D1,D2
    ROL.W     D1,D2
    ROR.W     D1,D2
     
    LSL.B     D5,D2
    ASR.B     D5,D2
    ASL.B     D5,D2
    ROL.B     D5,D2
    ROR.B     D5,D2
    LSL.B     D5,D2
    ASR.B     D5,D2
    ASL.B     D5,D2
    ROL.B     D5,D2
    ROR.B     D5,D2
    
    LSL.L     D7,D2
    ASR.L     D7,D2
    ASL.L     D7,D2
    ROL.L     D7,D2
    ROR.L     D7,D2
    LSL.L     D7,D2
    ASR.L     D7,D2
    ASL.L     D7,D2
    ROL.L     D7,D2
    ROR.L     D7,D2
       
    LSL      $0 *Word is only valid case.
    LSR      $0
    ASL      $0
    ASR      $0
    ROL      $0
    ROR      $0
       
    LSL      $10000 *Word is only valid case.
    LSR      $10000
    ASL      $10000
    ASR      $10000
    ROL      $10000
    ROR      $10000
       
    LSL      (A1) *Word is only valid case.
    LSR      (A1)
    ASL      (A1)
    ASR      (A1)
    ROL      (A1)
    ROR      (A1)
       
    LSL      (A1)+ *Word is only valid case.
    LSR      (A1)+
    ASL      (A1)+
    ASR      (A1)+
    ROL      (A1)+
    ROR      (A1)+
       
    LSL      -(A1) *Word is only valid case.
    LSR      -(A1)
    ASL      -(A1)
    ASR      -(A1)
    ROL      -(A1)
    ROR      -(A1)
*End of Shift operation tests.********************************************
**************************************************************************

*Extra test code   
    OR.L     D1,D0
       
    SUB.L    D0,D1
       
    CMP.W    D1,D2

    BRA      SKIP
       
    CLR.L    D1
       
    JSR      DUMMY_SUB
       
    ADDQ.B   #1,D0
              
    DIVU.W   D1,D0
    
    BRA     DO_NOTHING
    CMP     #0,D3
    BEQ     DO_NOTHING
    
    DIVU   D3,D4

    MULS    D3,D4
    
    SUB.B   #68,D1
    SUB.B   D3,D4
    SUB.B   (A3),D6
    SUB.B   -(A3),D5
    SUB.B   D7,-(A3)
    
    CLR.L   D1
    CLR.B   D2
    CLR.W   D5
    CLR.L   (A4)
    CLR.W   (A4)+
    CLR.W   -(A4)
    
    MOVEA.L   #$11111111,A2
    MOVEA.L   #$1111,A2
    
    ADD.L    D1,D2
    ADD.B    D5,D7
    ADD.W    D3,D4
    ADD.L    #34,D6
    ADD.L    D1,D2
    ADD.B    D5,D7
    ADD.W    D3,D4
    ADD.L    #34,D6
    ADD.B   #4,D1

       
    MULS.W   D1,D2
    MULS.W   D1,D2













*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
