*-----------------------------------------------------------
* Title      :  EA decoder
* Written by :  Midori Williams
* Date       :  3/9/19
* Description:  3rd file in a Dissasembler reads Opword bits
* 0-5 to determine EA Mode and Xn, returns control to caller
*-----------------------------------------------------------


*******************************************************************************
* Method Name: EA
* Description: 
*
* General Registers:
*   A3 = pointer to the next address to be read (not the current word), use if next addr contains info for EA (A3)+
*   A4 = Copy of current address in case opcode can't be decoded (EA shouldn't need this))
*   D2 = EA/MODE_EA Flag 1= EA, 0 = MOVE_EA
*   D3 = current opcode, read only till program re-loops
*   D4 = working opcode for masking, shifting, etc, (change all you need)
*   D5 = good/bad flag, 1=good 0=bad (EA sets to bad if can't decode)
*   D6 = size of instruction for EA to decode immediate data (read only)
*
* Printing Buffers and Registers:
*   - printBuffer = address of buffer for printing final multi-string to I/O
*   A1 = Pointer to current location in printBuffer (set by opcode person, EA does not change)
*   A0 = Pointer to string/constant to be added to printBuffer. Must LEA string/constant before calling "ADD2BUFFER" method.
*   - hex2ascBuffer = converted ascii value/string stored here after calling "HexToAscii" (see method in Main for preconditions)
* 
* Preconditions:  None
* Postconditions: TBA
*********************************************************************************

EA:

        MOVE.W  D3, D4      ;Copy of D3 to D4 for manipulation
        LSR.W   #3, D4      ;Shift data 3 times to the right
        ANDI.W  #$0007, D4  ;Bit masking for 3 from the LSB
        MOVE.B  #$1, D2     ;Set a flag for EA
        JSR     MODE
        RTS





************************************************
* MOVE_EA
*
* This will decode MOVE EA OP code by shifting
* the appropriate amount of times when called
************************************************
MOVE_EA:
        MOVE.W  D3, D4      ;Copy data from D3 to D4
        LSR.W   #6, D4      ;Shift data 6 times to the right
        ANDI.W  #$0007,D4   ;Bit mask for 3 from the LSB
        MOVE.B  #$0, D2     ;Flag set to 0 indicating MOVE_EA
        JSR     MODE        
        RTS    


*********MODE***********
*
*   Comparison for:
*
*   Data Register
*   Address Register
*   Address
*   Address with Postincrement
*   Address with Predecrement
*
*
***********************    
MODE:
            
            CMP.W  #$00,D4      ;compare 0x00 to D4
            BEQ    DATAREG      ;if equal, branch to data register
            
            CMP.W  #$01,D4      ;compare 0x01 to D4
            BEQ    ADDRREG      ;if equal, branch to address register
            
            CMP.W  #$02,D4      ;compare 0x02 to D4
            BEQ    ADDRESS      ;if equal, branch to address   
            
            CMP.W  #$03,D4      ;compare 0x03 to D4
            BEQ    ADDRPOST     ;if equal, branch to address with postincrement 
             
            CMP.W  #$04,D4      ;compare 0x04 to D4
            BEQ    ADDRPRE      ;if equal, branch to address with predecrement     
            
            CMP.W  #$07,D4      ;compare 0x07 to D4
            BEQ    ABSOLUTE     ;if equal, branch to Absolute/Immediate
    
            BNE    BADFLAG      ;if it does not equal set flag
            
            RTS
            
*********Comparison for Address*************

ABSOLUTE:

            MOVE.W D3, D4       ;Move another copy to D4
            ANDI.W #$0007, D4   ;Bit mask for address
                        
            CMP.W  #$00,D4      ;compare 0x00 to D4
            BEQ    ABSSHORT     ;if equal, branch to absolute short
            
            CMP.W  #$01,D4      ;compare 0x01 to D4
            BEQ    ABSLONG      ;if equal, branch to absolute long
            
            CMP.W  #$04,D4      ;compare 0x04 to D4
            BEQ    IMMED        ;if equal, branch to immediate
            
            BNE    BADFLAG      ;if it does not equal any values above, then branch to BADFLAG           

            RTS

**********************************************
* If value does not match, it cannot be decoded 
* and should return raw value plus set the flag
**********************************************
CANNOTDECODE:
            
            JMP BADFLAG


           
************************************************
* DATA Register = Mode 000
*
* Find the data register number and load the value
* into the buffer and return to subroutine
*
************************************************
DATAREG:
            
        MOVE.W  D3, D4      ;Move a copy of D3 into D4 for manipulation
        
        CMP.B   #$1, D2     ; Check if move flag set
        BEQ     Bitm_d      ; branch if equal to bit masking
        MOVE.B  #$9,D0      ; Move 9 into register D0
        LSR.W   D0, D4      ; Shift right 9 times for move_ea
        BRA     Bitm_d      ; branch to bit masking
        
        
        
Bitm_d  ANDI.W  #$0007,D4   ;Bit mask 3 bits from LSB  
        CLR.W   D2          ;Clear the flag
Data0:
        CMP.B   #$00,D4     ;If 0, place string 'D0' into print buffer
        BNE     Data1       
        LEA     d0MSG,A0    
        JSR     ADD2BUFFER
        RTS

Data1:  
        CMP.B   #$1,D4      ;If 1, place string 'D1' into print buffer
        BNE     Data2       
        LEA     d1MSG,A0    
        JSR     ADD2BUFFER
        RTS
        
Data2:  
        CMP.B   #$2,D4      ;If 2, place string 'D2' into print buffer    
        BNE     Data3       
        LEA     d2MSG,A0    
        JSR     ADD2BUFFER
        RTS

Data3:      
        CMP.B   #$3,D4      ;If 3, place string 'D3' into print buffer 
        BNE     Data4
        LEA     d3MSG,A0
        JSR     ADD2BUFFER
        RTS
        
Data4:  
        CMP.B   #$4,D4      ;If 4, place string 'D4' into print buffer 
        BNE     Data5
        LEA     d4MSG,A0
        JSR     ADD2BUFFER
        RTS
    
Data5:  
        CMP.B   #$5,D4      ;If 5, place string 'D5' into print buffer 
        BNE     Data6
        LEA     d5MSG,A0
        JSR     ADD2BUFFER
        RTS

Data6:  
        CMP.B   #$6,D4      ;If 6, place string 'D6' into print buffer 
        BNE     Data7
        LEA     d6MSG,A0
        JSR     ADD2BUFFER
        RTS

Data7:  
        CMP.B   #$7,D4      ;If 7, place string 'D7' into print buffer 
        LEA     d7MSG,A0
        JSR     ADD2BUFFER
        RTS





************************************************
* Address Register = Mode 001
*
* Find the address register number and load the value
* into the buffer and return to subroutine
*
************************************************
ADDRREG:
            
        MOVE.W  D3, D4      ;Move a copy of D3 into D4 for manipulation
        
        CMP.B   #$1, D2     ; Check if move flag set
        BEQ     Bitm_ar     ; branch if equal to bit masking
        MOVE.B  #$9,D0      ; Move 9 into register D0
        LSR.W   D0, D4      ; Shift right 9 times for move_ea
        BRA     Bitm_ar     ; branch to bit masking
        
        
Bitm_ar  ANDI.W  #$0007,D4  ;Bit mask 3 bits from LSB  
         CLR.W   D2         ;Clear the flag        
        
        
Ar0:
        CMP.B   #$0,D4      ;If 0, place string 'A0' into print buffer 
        BNE     Ar1
        LEA     ar0MSG,A0
        JSR     ADD2BUFFER
        RTS

Ar1:  
        CMP.B   #$1,D4      ;if 1, place string 'A1' into print buffer
        BNE     Ar2
        LEA     ar1MSG,A0
        JSR     ADD2BUFFER
        RTS
        
Ar2:  
        CMP.B   #$2,D4      ;if 2, place string 'A2' into print buffer
        BNE     Ar3
        LEA     ar2MSG,A0
        JSR     ADD2BUFFER
        RTS

Ar3:  
        CMP.B   #$3,D4      ;if 3, place string 'A3' into print buffer
        BNE     Ar4
        LEA     ar3MSG,A0
        JSR     ADD2BUFFER
        RTS
        
Ar4:  
        CMP.B   #$4,D4      ;if 4, place string 'A4' into print buffer
        BNE     Ar5
        LEA     ar4MSG,A0
        JSR     ADD2BUFFER
        RTS
    
Ar5:  
        CMP.B   #$5,D4      ;if 5, place string 'A5' into print buffer
        BNE     Ar6
        LEA     ar5MSG,A0
        JSR     ADD2BUFFER
        RTS

Ar6:  
        CMP.B   #$6,D4      ;if 6, place string 'A6' into print buffer
        BNE     Ar7
        LEA     ar6MSG,A0
        JSR     ADD2BUFFER
        RTS

Ar7:  
        CMP.B   #$7,D4      ;if 7, place string 'A7' into print buffer
        LEA     ar7MSG,A0
        JSR     ADD2BUFFER
        RTS



************************************************
* Address = Mode 010
*
* Find the address number and load the value
* into the buffer and return to subroutine
*
************************************************
ADDRESS:
        
        MOVE.W  D3, D4      ;Move a copy of D3 into D4 for manipulation
        
        CMP.B   #$1, D2     ; Check if move flag set
        BEQ     Bitm_a      ; branch if equal to bit masking
        MOVE.B  #$9,D0      ; Move 9 into register D0
        LSR.W   D0, D4      ; Shift right 9 times for move_ea
        BRA     Bitm_a      ; branch to bit masking
        
        
Bitm_a  ANDI.W  #$0007,D4  ;Bit mask 3 bits from LSB  
        CLR.W   D2         ;Clear the flag 
        
Ari0:
        CMP.B   #$0,D4      ;if 0, place string '(A0)' into print buffer
        BNE     Ari1
        LEA     ari0MSG,A0
        JSR     ADD2BUFFER
        RTS

Ari1:  
        CMP.B   #$1,D4      ;if 1, place string '(A1)' into print buffer
        BNE     Ari2
        LEA     ari1MSG,A0
        JSR     ADD2BUFFER
        RTS
        
Ari2:  
        CMP.B   #$2,D4      ;if 2, place string '(A2)' into print buffer
        BNE     Ari3
        LEA     ari2MSG,A0
        JSR     ADD2BUFFER
        RTS

Ari3:  
        CMP.B   #$3,D4      ;if 3, place string '(A3)' into print buffer
        BNE     Ari4
        LEA     ari3MSG,A0
        JSR     ADD2BUFFER
        RTS
        
Ari4:  
        CMP.B   #$4,D4      ;if 4, place string '(A4)' into print buffer
        BNE     Ari5
        LEA     ari4MSG,A0
        JSR     ADD2BUFFER
        RTS
    
Ari5:  
        CMP.B   #$5,D4      ;if 5, place string '(A5)' into print buffer
        BNE     Ari6
        LEA     ari5MSG,A0
        JSR     ADD2BUFFER
        RTS

Ari6:  
        CMP.B   #$6,D4      ;if 6, place string '(A6)' into print buffer
        BNE     Ari7
        LEA     ari6MSG,A0
        JSR     ADD2BUFFER
        RTS

Ari7:  
        CMP.B   #$7,D4      ;if 7, place string '(A7)' into print buffer
        LEA     ari7MSG,A0
        JSR     ADD2BUFFER
        RTS





************************************************
* Address Postincrement = Mode 011
*
* Find the address register number and load the value
* into the buffer and return to subroutine
*
************************************************

ADDRPOST:
                
        MOVE.W  D3, D4      ;Move a copy of D3 into D4 for manipulation
        
        CMP.B   #$1, D2     ; Check if move flag set
        BEQ     Bitm_ap     ; branch if equal to bit masking
        MOVE.B  #$9,D0      ; Move 9 into register D0
        LSR.W   D0, D4      ; Shift right 9 times for move_ea
        BRA     Bitm_ap     ; branch to bit masking
        
        
Bitm_ap  ANDI.W  #$0007,D4  ;Bit mask 3 bits from LSB  
         CLR.W   D2         ;Clear the flag   
        
Arpi0:
        CMP.B   #$0,D4      ;if 0, place string '(A0)+' into print buffer
        BNE     Arpi1
        LEA     arpi0MSG,A0
        JSR     ADD2BUFFER
        RTS

Arpi1:  
        CMP.B   #$1,D4      ;if 1, place string '(A1)+' into print buffer
        BNE     Arpi2
        LEA     arpi1MSG,A0
        JSR     ADD2BUFFER
        RTS
        
Arpi2:  
        CMP.B   #$2,D4      ;if 2, place string '(A2)+' into print buffer
        BNE     Arpi3
        LEA     arpi2MSG,A0
        JSR     ADD2BUFFER
        RTS

Arpi3:  
        CMP.B   #$3,D4      ;if 3, place string '(A3)+' into print buffer
        BNE     Arpi4
        LEA     arpi3MSG,A0
        JSR     ADD2BUFFER
        RTS
        
Arpi4:  
        CMP.B   #$4,D4      ;if 4, place string '(A4)+' into print buffer
        BNE     Arpi5
        LEA     arpi4MSG,A0
        JSR     ADD2BUFFER
        RTS
    
Arpi5:  
        CMP.B   #$5,D4      ;if 5, place string '(A5)+' into print buffer
        BNE     Arpi6
        LEA     arpi5MSG,A0
        JSR     ADD2BUFFER
        RTS

Arpi6:  
        CMP.B   #$6,D4      ;if 6, place string '(A6)+' into print buffer
        BNE     Arpi7
        LEA     arpi6MSG,A0
        JSR     ADD2BUFFER
        RTS

Arpi7:  
        CMP.B   #$7,D4      ;if 7, place string '(A7)+' into print buffer
        LEA     arpi7MSG,A0
        JSR     ADD2BUFFER
        RTS
        
************************************************
* Address Predecrement = Mode 100
*
* Find the address register number and load the value
* into the buffer and return to subroutine
*
************************************************
ADDRPRE:
        
        MOVE.W  D3, D4      ; Move a copy of D3 into D4 for manipulation
        
        CMP.B   #$1, D2     ; Check if move flag set
        BEQ     Bitm_apre   ; Branch if equal to bit masking
        MOVE.B  #$9,D0      ; Move 9 into register D0
        LSR.W   D0, D4      ; Shift right 9 times for move_ea
        BRA     Bitm_apre   ; Branch to bit masking
        
        
Bitm_apre   ANDI.W  #$0007,D4  ; Bit mask 3 bits from LSB  
            CLR.W   D2         ; Clear the flag
        
Adrpi0:
        CMP.B   #$0,D4      ;if 0, place string '-(A0)' into print buffer
        BNE     Adrpi1
        LEA     arpd0MSG,A0
        JSR     ADD2BUFFER
        RTS

Adrpi1:  
        CMP.B   #$1,D4      ;if 1, place string '-(A1)' into print buffer
        BNE     Adrpi2
        LEA     arpd1MSG,A0
        JSR     ADD2BUFFER
        RTS
        
Adrpi2:  
        CMP.B   #$2,D4      ;if 2, place string '-(A2)' into print buffer
        BNE     Adrpi3
        LEA     arpd2MSG,A0
        JSR     ADD2BUFFER
        RTS

Adrpi3:  
        CMP.B   #$3,D4      ;if 3, place string '-(A3)' into print buffer
        BNE     Adrpi4
        LEA     arpd3MSG,A0
        JSR     ADD2BUFFER
        RTS
        
Adrpi4:  
        CMP.B   #$4,D4      ;if 4, place string '-(A4)' into print buffer
        BNE     Adrpi5
        LEA     arpd4MSG,A0
        JSR     ADD2BUFFER
        RTS
    
Adrpi5:  
        CMP.B   #$5,D4      ;if 5, place string '-(A5)' into print buffer
        BNE     Adrpi6
        LEA     arpd5MSG,A0
        JSR     ADD2BUFFER
        RTS

Adrpi6:  
        CMP.B   #$6,D4      ;if 6, place string '-(A6)' into print buffer
        BNE     Adrpi7
        LEA     arpd6MSG,A0
        JSR     ADD2BUFFER
        RTS

Adrpi7:  
        CMP.B   #$7,D4      ;if 7, place string '-(A7)' into print buffer
        LEA     arpd7MSG,A0
        JSR     ADD2BUFFER
        RTS







*************************************************
* Absolute Short (xxx).W = 000
*
*
*************************************************
ABSSHORT:
            
            
            LEA     hexSign, A0   ;load message "$"
            JSR     ADD2BUFFER    ;add message to printBuffer


            CLR.L   D4      ;clear register  
            CLR.L   D0      ;clear register                      
            MOVE.W  (A3)+,D4 ;load the word
            MOVE.B  #16,D0      ;load length of hex value
            JSR     HexToAscii  ;convert to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add word to buffer

            RTS


**************************************************
* Absolute Long (xxx).L = 001
*
*
**************************************************
ABSLONG:
        
            LEA     hexSign, A0   ;load message "$"
            JSR     ADD2BUFFER    ;add message to printBuffer


            CLR.L   D4      ;clear register  
            CLR.L   D0      ;clear register                      
            MOVE.L  (A3)+,D4 ;load the long
            MOVE.B  #32,D0      ;load length of hex value
            JSR     HexToAscii  ;convert to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add word to buffer

            RTS


***************************************************
* Immediate Xn = 100
* #<data>
*
***************************************************
IMMED:      
            LEA     hashtag, A0   ;load message "#"
            JSR     ADD2BUFFER    ;add message to printBuffer           
            LEA     hexSign, A0   ;load message "$"
            JSR     ADD2BUFFER    ;add message to printBuffer
            
            CMP.B   #8, D6        ;is it a byte?
            BNE     size_word     ;if no, skip to next comparison            
size_byte:
            CLR.L   D4            ;clear register  
            CLR.L   D0            ;clear register
            MOVE.W  A3, A4        ;update address pointer incase opcode still can't be decoded at some point
            MOVE.W  (A3)+, D4     ;grab the immediate data from the word after the opcode
            MOVE.B  #8,D0         ;load length of hex value
            JSR     HexToAscii    ;convert to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add immediate value to buffer
            
            RTS             

size_word:
            CMP.B   #16, D6       ;is it a word?
            BNE     size_long     ;if no, skip to next comparison
            
            CLR.L   D4            ;clear register  
            CLR.L   D0            ;clear register
            MOVE.W  A3, A4        ;update address pointer incase opcode still can't be decoded at some point
            MOVE.W  (A3)+, D4     ;grab the immediate data from the word after the opcode
            MOVE.B  #16, D0       ;load length of hex value
            JSR     HexToAscii    ;convert to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer, A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add immediate value to buffer

            RTS         


size_long:            
            CMP.B   #32, D6      ;is it a long?
            BNE     BADFLAG      ;if no, can't be decoded   
            
            CLR.L   D4            ;clear register  
            CLR.L   D0            ;clear register
            MOVE.W  A3, A4        ;update address pointer incase opcode still can't be decoded at some point
            MOVE.L  (A3)+, D4     ;grab the immediate data from the long after the opcode
            MOVE.B  #32,D0        ;load length of hex value
            JSR     HexToAscii    ;convert to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer, A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add immediate value to buffer

            RTS








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
