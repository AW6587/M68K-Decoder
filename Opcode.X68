*-----------------------------------------------------------
* Title      : Opcodes
* Date       : 3/6/19
* Description: 2nd file in a Dissasembler reads Opword bits
* 6-15 to determine the Opcode, returns control to caller in Main.X68
*-----------------------------------------------------------





*********************************************************************************
* Method Name: OPCODE
* Description: reads first 4 bits of current opcode (loaded into D3), compares to
* each of 13 decodable operation categories to find a match. If no match found,
* returns to Main.X68 
*
* General Registers:
*   A3 = pointer to current address (next address after postincrement)
*   A4 = Copy of current address in case opcode can't be decoded
*   D3 = current opcode, read only till program re-loops
*   D4 = working opcode for masking, shifting, etc.
*   D5 = good/bad flag, 1=good 0=bad
*   D6 = size for EA decode of immediate data (#8, #16, or #32)
*
* Printing Buffers and Registers:
*   - printBuffer = address of buffer for printing final multi-string to I/O
*   A1 = Pointer to current location in printBuffer (set by opcode person, EA does not change)
*   A0 = Pointer to string/constant to be added to printBuffer. Must LEA string/constant before calling ADD2BUFFER method.
*   - hex2ascBuffer = converted ascii value/string stored here after calling HexToAscii*
*
* Preconditions: A3 is preloaded with current address to read
* Postconditions: A3 now points to next address. Opcode can be decoded and is 
* loaded into buffer for printing, or cannot and prints the address and word of data
*********************************************************************************

OPCODE:     
            CLR.L   D4      ;clear D4 & D6 just to be safe
            CLR.L   D6      
            MOVE.L  A3, A4      *make a backup copy of the address before postincrementing pointer in A3     
            MOVE.W  (A3)+, D3    ;D3 is now my opcode word (16B)
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #12, D0     ;shift count for D4
            LSR.L   D0, D4      ;shift leading hex code (bits 15-12) to the far right to isolate for decoding
            AND.L   #$F, D4      ;mask uneeded bits/set to zeros
            
****** start making opcode comparisons on bits 15-12 to see if it is decodable ******
            CMPI.B  #$00, D4
            BEQ     OP0
            CMPI.B  #$03, D4
            BLE     OP1            
            CMPI.B  #$04, D4
            BEQ     OP4            
            CMPI.B  #$05, D4
            BEQ     OP5            
            CMPI.B  #$06, D4
            BEQ     OP6            
            CMPI.B  #$08, D4
            BEQ     OP8            
            CMPI.B  #$09, D4
            BEQ     decSUB            
            CMPI.B  #$0B, D4
            BEQ     OPB            
            CMPI.B  #$0C, D4
            BEQ     decMULS            
            CMPI.B  #$0D, D4
            BEQ     OPD            
            CMPI.B  #$0E, D4
            BEQ     OPE
            
            JMP     BADFLAG  ;none of the above, can't decode




* Check if it's ORI, CMPI, BCLR, or ANDI  
OP0:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4      ;is it BCLR with data reg as the source?
            BEQ     decBCLRdr
   
            *Nope, not BCLRdr, moveing along...
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #9, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 11-9 to the far right to isolate for decoding
            AND.L   #7, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #0, D4      ;is it ORI? 
            BEQ     decORI   
            
            CMP.B   #3, D4      ;is it ADDI? 
            BEQ     decADDI   
            
            CMP.B   #4, D4      ;is it BCLR with immediate as the source?
            BEQ     decBCLRim   
            
            CMP.B   #6, D4      ;is it CMPI?
            BEQ     decCMPI     
            
            JMP     BADFLAG     ;else can't be decoded

 
* Check if it's MOVE or MOVEA
OP1:        
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #6, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 8-6 to the far right to isolate for decoding Mode
            AND.L   #7, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it MOVEA?
            BEQ     decMOVEA    ;if yes, decode MOVEA
            JMP     decMOVE     ;must be MOVE then, decode that instead  

* Check if it's CLR, NEG, RTS, JSR, MOVEM, LEA, or CHK
OP4:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            CMP.W   #$4E75, D4  ;is it RTS?
            BEQ     decRTS
            
            *Nope, not RTS, moveing along....
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4      ;is it LEA or CHK? 
            BEQ     OP4_1   
            
            *Nope, not LEA or CHK, moveing along....
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #9, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 11-9 to the far right to isolate for decoding
            AND.L   #7, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it CLR?
            BEQ     decCLR
            
            CMP.B   #2, D4      ;is it NEG?
            BEQ     decNEG

            CMP.B   #7, D4      ;is it JSR?   
            BEQ     decJSR
            
            CMP.B   #4, D4      ;is it MOVEM register to memory?
            BEQ     decMOVEMr2m
            
            CMP.B   #6, D4      ;is it MOVEM memory to register?
            BEQ     decMOVEMm2r
            
OP4_1:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #6, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 6 to the far right to isolate for decoding
            AND.L   #1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it LEA?
            BEQ     decLEA
            
            CMP     #0, D4      ;is it CHK?
            BEQ     decCHK     
            
            JMP     BADFLAG     ;can't be decoded  




* Check if it's ADDQ or SUBQ
OP5:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #0, D4      ;is it ADDQ?
            BEQ     decADDQ
            BRA     decSUBQ     ;else, it's SUBQ



* Check if it's BRA or Bcc
OP6:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 11-8 to the far right to isolate for decoding condition code
            AND.L   #$F, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4      ;make sure 4 bits are 0 or between 2-15 range for Bcc conditions
            BNE     BCC_DECODE  ;if yes, start decoding which branch instruction it is! 
            JMP     BADFLAG     ;if not, can't decode
            
            

* Check if it's DIVS(word) or OR
OP8:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #6, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 7-6 to the far right to isolate for decoding            
            AND.L   #$3, D4      ;mask uneeded bits/set to zeros

            CMP.B   #3, D4      ;is it DIVS?
            BEQ     decDIVS     ;if yes, jump to decoding 
            JMP     decOR       ;else it's OR, jumpt to decode that




                                    
* Check if it's EOR or CMP
OPB:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding            
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it EOR?
            BEQ     decEOR     ;if yes, jump to decoding 
            JMP     decCMP      ;else it's CMP, jumpt to decode that



            

* Check if it's ADD or ADDA
OPD:        
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #6, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 7-6 to the far right to isolate for decoding            
            AND.L   #$3, D4      ;mask uneeded bits/set to zeros

            CMP.B   #3, D4      ;is it ADDA?
            BEQ     decADDA     ;if yes, jump to decoding 
            JMP     decADD     ;else jump to ADD to decode that

            

* Chekc if it's ASL/ASR, LSL/LSR, or ROL/ROR
OPE:    
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #6, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 7-6 to the far right to isolate for decoding operation type (dirrect or memory)
            AND.L   #$3, D4      ;mask uneeded bits/set to zeros

            CMP.B   #3, D4      ;is it a memory operation?
            BNE     OPE_skip    ;if no, jump to next decoding refinement 
            
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #9, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 11-9 to the far right to isolate for decoding            
            AND.L   #$7, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #0, D4     ;is it ASL/ASR?
            BEQ     decASL
            CMP.B   #1, D4     ;is it LSL/LSR?
            BEQ     decLSL
            CMP.B   #3, D4     ;is it ROL/ROR?
            BEQ     decROL

            JMP     BADFLAG     ;if not those, can't decode

OPE_skip    *must be a dirrect operation
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #3, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 5-3 to the far right to isolate for decoding            
            AND.L   #$3, D4      ;mask uneeded bits/set to zeros

            CMP.B   #0, D4     ;is it ASL/ASR using register?
            BEQ     decASLreg
            CMP.B   #1, D4     ;is it LSL/LSR using register?
            BEQ     decLSLreg
            CMP.B   #3, D4     ;is it ROL/ROR using register?
            BEQ     decROLreg

            JMP     BADFLAG     ;if not those, can't decode






*************************** ORI decode ***************************           
decORI: 
            LEA     oriMSG, A0     ;load message "ORI"
            JSR     ADD2BUFFER     ;add message to printBuffer
            JSR     GET_IM_SIZE    ;find the size in bits 7-6 (.b, .w, or .l) and append to printBuffer
            JSR     EA          ;jump to EA code for decoding destination EA and appending to printBuffer
            RTS                 ;return to Main.X68 

          

*************************** ADDI decode ***************************           
decADDI: 
            LEA     addiMSG, A0     ;load message "ADDI"
            JSR     ADD2BUFFER     ;add message to printBuffer
            JSR     GET_IM_SIZE    ;find the size in bits 7-6 (.b, .w, or .l) and append to printBuffer
            JSR     EA          ;jump to EA code for decoding destination EA and appending to printBuffer
            RTS                 ;return to Main.X68 

          


*************************** CMPI decode ***************************
decCMPI:    
            LEA     cmpiMSG, A0     ;load message "CMPI"
            JSR     ADD2BUFFER     ;add message to printBuffer
            JSR     GET_IM_SIZE    ;find the size in bits 7-6 (.b, .w, or .l) and append to printBuffer            
            JSR     EA      ;jump to EA code for decoding destination EA and appending to printBuffer
            RTS             ;return to Main.X68 

                      
           
**************** BCLR decode with data register as source ****************           
decBCLRdr:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #6, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 7-6 to the far right to isolate for decoding
            AND.L   #3, D4      ;mask uneeded bits/set to zeros
            CMP.B   #%10, D4    ;compare last needed bits to varify it's actually this opcode
            BNE     BADFLAG     ;if != can't decode
            
            *Now we know it's BCLR with data reg as source, start decoding
            LEA     bclrMSG, A0     ;load message "BCLR"
            JSR     ADD2BUFFER      ;add message to printBuffer
            JSR     DECODE_DN   ;decode and load message for the source data register, append to printBuffer
            LEA     comma, A0   ;load message ", "
            JSR     ADD2BUFFER  ;append to printBuffer
            
*            MOVE.B  #32,D6   ;set size for EA
            JSR     EA      ;jump to EA.X68 to decode destination EA and append to printBuffer
            RTS             ;return to Main.X68 


        
****************** BCLR decode with immediate val as source ******************
decBCLRim:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #6, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 7-6 to the far right to isolate for decoding
            AND.L   #3, D4      ;mask uneeded bits/set to zeros
            CMP.B   #%10, D4    ;compare last needed bits to varify it's actually this opcode
            BNE     BADFLAG     ;if != can't decode
            
            *Now we know it's BCLR with immediate as source, load buffers and start decoding
            LEA     bclrMSG, A0     ;load message "BCLR"
            JSR     ADD2BUFFER      ;append message to printBuffer
            LEA     hashtag, A0     ;load "#"
            JSR     ADD2BUFFER      ;append message to printBuffer
            LEA     hexSign, A0     ;load "$"
            JSR     ADD2BUFFER
            
            CLR.L   D4              ;clear register  
            CLR.L   D0              ;clear register
            MOVE.W  D3, D7          ;backup current opcode word before reading next 2 bytes
            MOVE.W  A3, A4          ;update address pointer incase opcode still can't be decoded at some point
            MOVE.W  (A3)+, D3       ;grab the immediate data from the word after the opcode
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #8,D0           ;load length of hex value
            JSR     HexToAscii      ;convert to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;append immediate value to buffer
           
            LEA     comma, A0   ;load message ", "
            JSR     ADD2BUFFER  ;append to printBuffer
            
            MOVE.W  D7, D3   ;restore opcode for EA to read 
            JSR     EA      ;jump to EA.X68 to decode destination EA and append to printBuffer
            RTS             ;return to Main.X68 


*************************** MOVEA Decode ***************************
decMOVEA:   
            LEA     moveaMSG, A0     ;load message "MOVEA"
            JSR     ADD2BUFFER     ;add message to printBuffer
            
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #12, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 13-12 to the far right to isolate for decoding size (.b, .w, .l)
            AND.L   #3, D4      ;mask uneeded bits/set to zeros

            CMP.B   #3, D4  ;is it .W?
            BNE     ma_skip1 ;skip if not
            
            LEA     wordMSG, A0   ;if yes, load ".W "
            JSR     ADD2BUFFER    ;add message to printBuffer
            MOVE.B  #16, D6       ;set size for EA to decode immediate data
            JSR     EA          ;decode source from EA.X68, load to printBuffer
            LEA     comma, A0   ;add a comma ", "
            JSR     ADD2BUFFER  ;add it to printBuffer
            JSR     MOVE_EA     ;decode destination Address register in EA.X68, load to printBuffer
            RTS             ;return to Main.X68
ma_skip1
            CMP.B   #2, D4  ;is it .L?
            BNE     ma_skip2 ;skip if not
            
            LEA     longMSG, A0   ;if yes, load ".L "
            JSR     ADD2BUFFER    ;add message to printBuffer
            MOVE.B  #32, D6       ;set size for EA to decode immediate data
            JSR     EA          ;decode source from EA.X68, load to printBuffer
            LEA     comma, A0   ;add a comma ", "
            JSR     ADD2BUFFER  ;add it to printBuffer
            JSR     MOVE_EA     ;decode destination address register in EA.X68, load to printBuffer
            RTS
ma_skip2    
            JSR     BADFLAG     ;invalid size, can't decode            
            

*************************** MOVE Decode ***************************
decMOVE:
            LEA     moveMSG, A0     ;load message "MOVEA"
            JSR     ADD2BUFFER     ;add message to printBuffer
            
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #12, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 13-12 to the far right to isolate for decoding size (.b, .w, .l)
            AND.L   #3, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4  ;is it .B?
            BNE     m_skip1 ;skip if not
            
            LEA     wordMSG, A0   ;if yes, load ".B "
            JSR     ADD2BUFFER    ;add message to printBuffer
            MOVE.B  #8, D6       ;set size for EA to decode immediate data
            JSR     EA          ;decode source from EA.X68, load to printBuffer
            LEA     comma, A0   ;add a comma ", "
            JSR     ADD2BUFFER  ;add it to printBuffer
            JSR     MOVE_EA     ;decode destination Address register in EA.X68, load to printBuffer
            RTS             ;return to Main.X68 
            
m_skip1     
            CMP.B   #3, D4  ;is it .W?
            BNE     m_skip2 ;skip if not 
      
            LEA     wordMSG, A0   ;if yes, load ".W "
            JSR     ADD2BUFFER    ;add message to printBuffer
            MOVE.B  #16, D6       ;set size for EA to decode immediate data
            JSR     EA          ;decode source from EA.X68, load to printBuffer
            LEA     comma, A0   ;add a comma ", "
            JSR     ADD2BUFFER  ;add it to printBuffer
            JSR     MOVE_EA     ;decode destination Address register in EA.X68, load to printBuffer
            RTS             ;return to Main.X68
m_skip2
            CMP.B   #2, D4  ;is it .L?
            BNE     m_skip3 ;skip if not
            
            LEA     longMSG, A0   ;if yes, load ".L "
            JSR     ADD2BUFFER    ;add message to printBuffer
            MOVE.B  #32, D6       ;set size for EA to decode immediate data
            JSR     EA          ;decode source from EA.X68, load to printBuffer
            LEA     comma, A0   ;add a comma ", "
            JSR     ADD2BUFFER  ;add it to printBuffer
            JSR     MOVE_EA     ;decode destination address register in EA.X68, load to printBuffer
            RTS
m_skip3    
            JSR     BADFLAG     ;invalid size, can't decode     



*************************** CLR Decode ***************************
decCLR:  
            LEA     clrMSG, A0  ;load "CLR" message
            JSR     ADD2BUFFER  ;add message to buffer
            JSR     GET_SIZE    ;get size (.b, .w, or .l) and append to printBuffer
            JSR     EA  ;jump to EA.X68 to decode destination EA and append to printBuffer
            RTS         ;return to MAIN.X68 for printing



*************************** NEG Decode ***************************
decNEG:  
            LEA     negMSG, A0  ;load "NEG" message
            JSR     ADD2BUFFER  ;add message to buffer
            JSR     GET_SIZE    ;get size (.b, .w, or .l) and append to printBuffer
            JSR     EA          ;jump to EA.X68 to decode destination EA and append to printBuffer
            RTS         ;return to MAIN.X68 for printing
            


*************************** RTS Decode ***************************
decRTS:
            LEA     rtsMSG, A0      ;load "RTS" message
            JSR     ADD2BUFFER      ;add message to printBuffer
            RTS                 ;return to MAIN.X68 for printing
      

      
*************************** JSR Decode ***************************
decJSR:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #6, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 7-6 to the far right to isolate for decoding Address reg
            AND.L   #7, D4      ;mask uneeded bits/set to zeros
            
            CMP     #2, D4      ;last check to make sure it's actually JSR
            BNE     BADFLAG     ;if not, can't decode
            
            LEA     jsrMSG, A0     ;load message "jsr"
            JSR     ADD2BUFFER     ;add message to printBuffer
            LEA     space, A0      ;load text spaceing
            JSR     ADD2BUFFER     ;add message to printBuffer
            JSR     EA          ;jump to EA.X68 to decode source EA and append to printBuffer
            
            RTS                 ;return to MAIN.X68 for printing

************************** MOVEM Decode **************************
************** Register to Memory ***
decMOVEMr2m: 
            LEA     movemMSG, A0     ;load message "MOVEM"
            JSR     ADD2BUFFER     ;add message to printBuffer

            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #6, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 7-6 to the far right to isolate for decoding size
            AND.L   #3, D4      ;mask uneeded bits/set to zeros
r2m_word            
            CMP     #2, D4      ;is it .W?
            BNE     r2m_long    ;if not, try .L
            
            LEA     wordMSG, A0     ;load message ".W "
            JSR     ADD2BUFFER     ;add message to printBuffer
            
            MOVE.W  D3, D7      ;make opcode copy since reg decode increments pointer
            MOVE.W  A3, A4          ;update address pointer incase opcode still can't be decoded at some point
            MOVE.W  (A3)+, D3       ;grab register list from the word AFTER opcode, store in D7 so D3 still holds current opcode for EA
            JSR     movem_decode_regs ;skip over to decoding source register list, appends to printBuffer
            
            LEA     comma, A0   ;load message ", "
            JSR     ADD2BUFFER  ;append to printBuffer
            
            MOVE.W  D7, D3   ;restore opcode for EA to read
            JSR     EA       ;decode EA for the destination, appends to printBuffer
            RTS              ;return to Main.X68
            
r2m_long    CMP     #3, D4      ;is it .L?
            BNE     BADFLAG     ;if not, can't decode
            
            LEA     longMSG, A0     ;load message ".L "
            JSR     ADD2BUFFER     ;add message to printBuffer
            
            MOVE.W  D3, D7      ;make opcode copy since reg decode increments pointer
            MOVE.W  A3, A4          ;update address pointer incase opcode still can't be decoded at some point
            MOVE.W  (A3)+, D3       ;grab register list from the word AFTER opcode, store in D7 so D3 still holds current opcode for EA
            JSR     movem_decode_regs ;skip over to decoding source register list, appends to printBuffer

            LEA     comma, A0   ;load message ", "
            JSR     ADD2BUFFER  ;append to printBuffer

            MOVE.W  D7, D3   ;restore opcode for EA to read
            JSR     EA       ;decode EA for the destination, appends to printBuffer
            RTS              ;return to Main.X68

************** Memory to Register ***
decMOVEMm2r:
            LEA     movemMSG, A0     ;load message "MOVEM"
            JSR     ADD2BUFFER     ;add message to printBuffer

            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #6, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 7-6 to the far right to isolate for decoding size
            AND.L   #3, D4      ;mask uneeded bits/set to zeros
m2r_word            
            CMP     #2, D4      ;is it .W?
            BNE     m2r_long    ;if not, try .L
            
            LEA     wordMSG, A0     ;load message ".W "
            JSR     ADD2BUFFER     ;add message to printBuffer
            
            MOVE.W  A3, A4          ;update address pointer incase opcode still can't be decoded at some point
            MOVE.W  (A3)+, D7       ;grab register list from the word AFTER opcode, store in D7 so D3 still holds current opcode for EA            
            JSR     EA           ;decode EA for the source, appends to printBuffer

            LEA     comma, A0   ;load message ", "
            JSR     ADD2BUFFER  ;append to printBuffer  
 
            MOVE.W  D7, D3      ;update D3 so it now holds register list         
            JSR     movem_postD0 ;skip over to decoding source register list, appends to printBuffer

            RTS                 ;return to Main.X68
                
m2r_long    CMP     #3, D4      ;is it .L?
            BNE     BADFLAG     ;if not, can't decode
            
            LEA     longMSG, A0     ;load message ".L "
            JSR     ADD2BUFFER     ;add message to printBuffer
            
            MOVE.W  A3, A4          ;update address pointer incase opcode still can't be decoded at some point
            MOVE.W  (A3)+, D7       ;grab register list from the word AFTER opcode, store in D7 so D3 still holds current opcode for EA   
            JSR     EA            ;decode EA for the source, appends to printBuffer
            
            LEA     comma, A0     ;load message ", "
            JSR     ADD2BUFFER    ;append to printBuffer 

            MOVE.W  D7, D3        ;update D3 so it now holds register list                    
            JSR     movem_postD0 ;skip over to decoding source register list, appends to printBuffer

            RTS              ;return to Main.X68
           
** Decode Registers D0-D7 & A0-A7 **
movem_decode_regs
            MOVE.W  D7, D4      ;make a temp copy of opcode in D4 for manipulation
            MOVE.B  #3, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 5-3 to far right for decoding mode/reg list masking order
            AND.L   #7, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #4, D4      ;if mode is -(An) predecrement, then bit order is msb - lsb, reg D0-D7/A0-A7
            BNE     movem_postD0 ;else bit order is postincrement, lsb - msb, reg A7-A0/D7-D0
movem_preD0
            MOVE.W  D3, D4      ;make a temp copy of reg list in D4 for manipulation
            MOVE.B  #15, D0     ;shift count for D4
            LSR.L   D0, D4      ;shift bit 15 to the far right to isolate for decoding D0
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preD1
            
            LEA     d0MSG, A0    ;load message "D0"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_preD1
            MOVE.W  D3, D4      ;make a temp copy of reg list in D4 for manipulation
            MOVE.B  #14, D0     ;shift count for D4
            LSR.L   D0, D4      ;shift bit 14 to the far right to isolate for decoding D0
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preD2
            
            LEA     d1MSG, A0    ;load message "D1"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_preD2
            MOVE.W  D3, D4      ;make a temp copy of reg list in D4 for manipulation
            MOVE.B  #13, D0     ;shift count for D4
            LSR.L   D0, D4      ;shift bit 13 to the far right to isolate for decoding D0
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preD3
            
            LEA     d2MSG, A0    ;load message "D2"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_preD3 
            MOVE.W  D3, D4      ;make a temp copy of reg list in D4 for manipulation
            MOVE.B  #12, D0     ;shift count for D4
            LSR.L   D0, D4      ;shift bit 12 to the far right to isolate for decoding D3
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preD4
            
            LEA     d3MSG, A0    ;load message "D3"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check      
movem_preD4
            MOVE.W  D3, D4      ;make a temp copy of reg list in D4 for manipulation
            MOVE.B  #11, D0     ;shift count for D4
            LSR.L   D0, D4      ;shift bit 11 to the far right to isolate for decoding D4
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preD5
            
            LEA     d4MSG, A0    ;load message "D4"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_preD5
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #10, D0     ;shift count for D4
            LSR.L   D0, D4      ;shift bit 10 to the far right to isolate for decoding D5
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preD6
            
            LEA     d5MSG, A0    ;load message "D5"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_preD6
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #9, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 9 to the far right to isolate for decoding D6
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preD7
            
            LEA     d6MSG, A0    ;load message "D6"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0   ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_preD7
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #8, D0     ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding D7
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preA0
            
            LEA     d7MSG, A0    ;load message "D7"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_preA0
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #7, D0     ;shift count for A0
            LSR.L   D0, D4      ;shift bit 7 to the far right to isolate for decoding A0
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preA1
            
            LEA     ar0MSG, A0    ;load message "A0"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_preA1
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #6, D0     ;shift count for A1
            LSR.L   D0, D4      ;shift bit 6 to the far right to isolate for decoding A1
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preA2
            
            LEA     ar1MSG, A0    ;load message "A1"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_preA2
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #5, D0     ;shift count for A2
            LSR.L   D0, D4      ;shift bit 5 to the far right to isolate for decoding A2
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preA3
            
            LEA     ar2MSG, A0    ;load message "A2"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_preA3
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #4, D0     ;shift count for A3
            LSR.L   D0, D4      ;shift bit 4 to the far right to isolate for decoding A3
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preA4
            
            LEA     ar3MSG, A0    ;load message "A3"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_preA4
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #7, D0     ;shift count for A4
            LSR.L   D0, D4      ;shift bit 3 to the far right to isolate for decoding A4
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preA5
            
            LEA     ar4MSG, A0    ;load message "A4"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_preA5
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #2, D0     ;shift count for A5
            LSR.L   D0, D4      ;shift bit 2 to the far right to isolate for decoding A5
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preA6
            
            LEA     ar5MSG, A0    ;load message "A5"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_preA6
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #1, D0     ;shift count for A6
            LSR.L   D0, D4      ;shift bit 1 to the far right to isolate for decoding A6
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preA7
            
            LEA     ar6MSG, A0    ;load message "A6"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_preA7
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            AND.L   #1, D4      ;mask uneeded bits/set to zeros to decode A7
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_preEnd
            
            LEA     ar7MSG, A0    ;load message "A7"
            JSR     ADD2BUFFER  ;add it to printBuffer
            
movem_preEnd             
            RTS        ;return to movem caller



** Decode Registers A7-A0 & D7-D0 **
movem_postD0
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4      ;is bit set?
            BNE     movem_postD1
            
            LEA     d0MSG, A0    ;load message "D0"
            JSR     ADD2BUFFER   ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check 
movem_postD1
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #1, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 14 to the far right to isolate for decoding D0
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4      ;is bit set?
            BNE     movem_postD2
            
            LEA     d1MSG, A0    ;load message "D1"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check 
movem_postD2
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #2, D0     ;shift count for D4
            LSR.L   D0, D4      ;shift bit 13 to the far right to isolate for decoding D0
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_postD3
            
            LEA     d2MSG, A0    ;load message "D2"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_postD3
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #3, D0     ;shift count for D4
            LSR.L   D0, D4      ;shift bit 12 to the far right to isolate for decoding D3
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_postD4
            
            LEA     d3MSG, A0    ;load message "D3"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_postD4
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #4, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 9 to the far right to isolate for decoding D6
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_postD5
            
            LEA     d4MSG, A0    ;load message "D6"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_postD5
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #5, D0     ;shift count for D4
            LSR.L   D0, D4      ;shift bit 10 to the far right to isolate for decoding D5
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_postD6
            
            LEA     d5MSG, A0    ;load message "D5"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check           
movem_postD6
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #6, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 9 to the far right to isolate for decoding D6
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_postD7
            
            LEA     d6MSG, A0    ;load message "D6"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_postD7
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #7, D0     ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding D7
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_postA0
            
            LEA     d7MSG, A0    ;load message "D7"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_postA0
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #8, D0     ;shift count for A0
            LSR.L   D0, D4      ;shift bit 7 to the far right to isolate for decoding A0
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_postA1
            
            LEA     ar0MSG, A0    ;load message "A0"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_postA1
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #9, D0     ;shift count for A1
            LSR.L   D0, D4      ;shift bit 6 to the far right to isolate for decoding A1
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_postA2
            
            LEA     ar1MSG, A0    ;load message "A1"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check 
movem_postA2
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #10, D0      ;shift count for A2
            LSR.L   D0, D4      ;shift bit 5 to the far right to isolate for decoding A2
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_postA3
            
            LEA     ar2MSG, A0    ;load message "A2"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_postA3
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #11, D0      ;shift count for A3
            LSR.L   D0, D4      ;shift bit 4 to the far right to isolate for decoding A3
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_postA4
            
            LEA     ar3MSG, A0    ;load message "A3"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_postA4
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #12, D0     ;shift count for A4
            LSR.L   D0, D4      ;shift bit 3 to the far right to isolate for decoding A4
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_postA5
            
            LEA     ar4MSG, A0    ;load message "A4"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_postA5
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #13, D0     ;shift count for A5
            LSR.L   D0, D4      ;shift bit 2 to the far right to isolate for decoding A5
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_postA6
            
            LEA     ar5MSG, A0    ;load message "A5"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_postA6
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #14, D0     ;shift count for A6
            LSR.L   D0, D4      ;shift bit 1 to the far right to isolate for decoding A6
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_postA7
            
            LEA     ar6MSG, A0    ;load message "A6"
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     forwardSlash, A0    ;load "/"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *continue with next bit check
movem_postA7
            MOVE.W  D3, D4      ;make a temp copy in D4 for manipulation
            MOVE.B  #15, D0     ;shift count for A6
            LSR.L   D0, D4      ;shift bit 1 to the far right to isolate for decoding A7
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            
            
            CMP.B   #1, D4     ;is bit set?
            BNE     movem_postEnd
            
            LEA     ar7MSG, A0    ;load message "A7"
            JSR     ADD2BUFFER  ;add it to printBuffer
            *end of bit read
movem_postEnd
            RTS         ;return to movem caller

 


*************************** LEA Decode ***************************
decLEA: 
            LEA     leaMSG, A0     ;load message "LEA"
            JSR     ADD2BUFFER     ;add message to printBuffer
            LEA     space, A0      ;load text spaceing
            JSR     ADD2BUFFER     ;add message to printBuffer
            JSR     EA          ;jump to EA.X68 to decode source EA and append to printBuffer
            LEA     comma, A0   ;load ", "
            JSR     ADD2BUFFER  ;add message to printBuffer
            
            JSR     DECODE_AN   ;find destination address register and add to printBuffer
            
            RTS                 ;return to MAIN.X68 for printing   

  
*************************** CHK Decode ***************************
decCHK:
            LEA     chkMSG, A0     ;load message "CHK"
            JSR     ADD2BUFFER     ;add message to printBuffer

            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #7, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 8-7 to the far right to isolate for decoding Address reg
            AND.L   #3, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #3, D4      ;is the size a word?
            BEQ     load_w
            CMP.B   #2, D4      ;is the size a long?
            BEQ     load_l
            
            JMP     BADFLAG     ;can't decode if it's not one of those
load_w:     
            MOVE.B  #16, D6       ;set size for EA to decode immediate data
            LEA     wordMSG, A0   ;load ".W " message
            JSR     ADD2BUFFER    ;add message to printBuffer
            JMP     endCHK        ;finish the decode
            
load_l:                 
            MOVE.B  #32, D6       ;set size for EA to decode immediate data
            LEA     longMSG, A0   ;load ".L " message
            JSR     ADD2BUFFER    ;add message to printBuffer

endCHK:            
            JSR     EA          ;jump to EA.X68 to decode source EA and append to printBuffer
            LEA     comma, A0   ;load ", "
            JSR     ADD2BUFFER  ;add message to printBuffer
            JSR     DECODE_DN   ;find destination data register and add to printBuffer
            
            RTS                 ;return to MAIN.X68 for printing     


*************************** SUBQ Decode ***************************
decSUBQ:    
            LEA     subqMSG, A0 ;load "SUBQ" message
            JSR     ADD2BUFFER  ;put message in printBuffer
            JSR     GET_SIZE    ;get the size and append it to printBuffer
            LEA     hashtag, A0
            JSR     ADD2BUFFER  ;append "#" to printBuffer
            LEA     hexSign, A0
            JSR     ADD2BUFFER  ;append "$" to printBuffer
            
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #9, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 11-9 to the far right to isolate for decoding data
            AND.L   #7, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #0, D4       ;if it's zero, it needs to be adjusted to 8 first
            BNE     subq_hex_conv
            ADDI.B  #8, D4       ;change to 8, then continue with hex conversion
subq_hex_conv
            MOVE.B  #4, D0      ;bit length for ascii conversion
            JSR     HexToAscii  ;converted number loaded into hex2ascBuffer
            LEA     hex2ascBuffer, A0   ;load ascii buffer
            JSR     ADD2BUFFER  ;append ascii data to printBuffer
            LEA     comma, A0   ;load ", "
            JSR     ADD2BUFFER  ;add message to printBuffer
            
            JSR     EA         ;jump to EA.X68 to decode destination EA and append to printBuffer
            RTS              ;return to MAIN.X68 for printing 
            


*************************** ADDQ Decode ***************************
decADDQ
            LEA     addqMSG, A0 ;load "ADDQ" message
            JSR     ADD2BUFFER  ;put message in printBuffer
            JSR     GET_SIZE    ;get the size and append it to printBuffer
            LEA     hashtag, A0
            JSR     ADD2BUFFER  ;append "#" to printBuffer
            LEA     hexSign, A0
            JSR     ADD2BUFFER  ;append "$" to printBuffer
            
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #9, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 11-9 to the far right to isolate for decoding data
            AND.L   #7, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #0, D4       ;if it's zero, it needs to be adjusted to 8 first
            BNE     subq_hex_conv
            ADDI.B  #8, D4       ;change to 8, then continue with hex conversion
addq_hex_conv
            MOVE.B  #4, D0      ;bit length for ascii conversion
            JSR     HexToAscii  ;converted number loaded into hex2ascBuffer
            LEA     hex2ascBuffer, A0   ;load ascii buffer
            JSR     ADD2BUFFER  ;append ascii data to printBuffer
            LEA     comma, A0   ;load ", "
            JSR     ADD2BUFFER  ;add message to printBuffer
            
            JSR     EA         ;jump to EA.X68 to decode destination EA and append to printBuffer
            RTS              ;return to MAIN.X68 for printing 



*************************** Bcc Decode ***************************
BCC_DECODE: 
            
decBRA      CMP.B   #0, D4   ;is it BRA?
            BNE     decBHI
            LEA     braMSG, A0
            JSR     ADD2BUFFER
            BRA     b_skip
            
decBHI      CMP.B   #2, D4  ;is it BHI?
            BNE     decBLS
            LEA     bhiMSG, A0
            JSR     ADD2BUFFER
            BRA     b_skip       

decBLS      CMP.B   #3, D4  ;is it BLS?
            BNE     decBCC
            LEA     blsMSG, A0
            JSR     ADD2BUFFER
            BRA     b_skip

decBCC      CMP.B   #4, D4  ;is it BCC?
            BNE     decBCS
            LEA     bccMSG, A0
            JSR     ADD2BUFFER
            BRA     b_skip
            
decBCS      CMP.B   #5, D4  ;is it BCS?
            BNE     decBNE
            LEA     bcsMSG, A0
            JSR     ADD2BUFFER
            BRA     b_skip

decBNE      CMP.B   #6, D4  ;is it BNE?
            BNE     decBEQ
            LEA     bneMSG, A0
            JSR     ADD2BUFFER
            BRA     b_skip
            
decBEQ      CMP.B   #7, D4  ;is it BEQ?
            BNE     decBVC
            LEA     beqMSG, A0
            JSR     ADD2BUFFER
            BRA     b_skip
            
decBVC      CMP.B   #8, D4  ;is it BVC?
            BNE     decBVS
            LEA     bvcMSG, A0
            JSR     ADD2BUFFER
            BRA     b_skip
            
decBVS      CMP.B   #9, D4  ;is it BVS?
            BNE     decBPL
            LEA     bvsMSG, A0
            JSR     ADD2BUFFER
            BRA     b_skip
            
decBPL      CMP.B   #10, D4  ;is it BPL?
            BNE     decBMI
            LEA     bplMSG, A0
            JSR     ADD2BUFFER
            BRA     b_skip

decBMI      CMP.B   #11, D4  ;is it BMI?
            BNE     decBGE
            LEA     bmiMSG, A0
            JSR     ADD2BUFFER
            BRA     b_skip

decBGE      CMP.B   #12, D4  ;is it BGE? 
            BNE     decBLT
            LEA     bgeMSG, A0
            JSR     ADD2BUFFER
            BRA     b_skip

decBLT      CMP.B   #13, D4  ;is it BLT?
            BNE     decBGT
            LEA     bltMSG, A0
            JSR     ADD2BUFFER
            BRA     b_skip

decBGT      CMP.B   #14, D4  ;is it BGT?
            BNE     decBLE
            LEA     bgtMSG, A0
            JSR     ADD2BUFFER
            BRA     b_skip
            
decBLE      LEA     bleMSG, A0 ;it has to be BLE then
            JSR     ADD2BUFFER
            

b_skip      LEA     hexSign, A0 ;append "$" to printBuffer
            JSR     ADD2BUFFER
            
            CLR.L   D4              ;clear register  
            CLR.L   D0              ;clear register
            MOVE.W  D3, D4       ;make a temp copy of opword in D4 for manipulation
            AND.L   #$FF, D4      ;mask uneeded bits/set to zeros to isolate for decoding displacement size

            
word_dsp    CMP.B   #$0, D4     ;word displacement?
            BNE     long_dsp  
            
            MOVE.W  A3, A4          ;update address pointer incase opcode still can't be decoded at some point
            MOVE.W  (A3)+, D3       ;grab the displacement data from the WORD after the opcode
            MOVE.W  D3, D4          ;make a temp copy in D4 for manipulation
            ADD.W   A4, D4          ;add program pointer to Displacement(opcode addr +2, ie A4 after postincrement)
  
            MOVE.B  #16, D0         ;load length of hex value
            JSR     HexToAscii      ;convert to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;append to printBuffer
            RTS         ;return to MAIN.X68 for printing    
            
long_dsp    CMP.B   #$FF,D4         ;long displacement?
            BNE     byte_dsp
            
            MOVE.W  A3, A4          ;update address pointer incase opcode still can't be decoded at some point
            MOVE.L  (A3)+, D3       ;grab the displacement data from the LONG after the opcode
            MOVE.L  D3, D4          ;make a temp copy in D4 for manipulation
            ADD.L   A4, D4          ;add program pointer to Displacement(opcode addr +2, ie A4 after postincrement)            
            
            MOVE.B  #32, D0         ;load length of hex value
            JSR     HexToAscii      ;convert to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;append to printBuffer
            RTS         ;return to MAIN.X68 for printing
            
byte_dsp          ;byte displacement then
            EXT.W   D4
            ADD.W   A3, D4          ;add program pointer to Displacement(opcode addr +2, ie A3)
            MOVE.B  #16,D0           ;load length of hex value
            JSR     HexToAscii      ;convert to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;append to printBuffer
            RTS         ;return to MAIN.X68 for printing 



*************************** DIVS Decode ***************************
decDIVS:
            LEA     divsMSG, A0   ;load "DIVS" message
            JSR     ADD2BUFFER  ;put it in the printBuffer
            
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to far right to isolate for last check it is actually DIVS
            AND.L   #1, D4      ;mask uneeded bits/set to zeros
            CMP.B   #1, D4      ;is it DIVS?
            BNE     BADFLAG     ;if not, can't be decoded
            
            LEA     wordMSG, A0 ;load ".W " message
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     EA          ;jump to EA.X68 to decode source EA and append to printBuffer
            LEA     comma, A0   ;load a comma ", "
            JSR     ADD2BUFFER  ;append to printBuffer            
            JSR     DECODE_DN   ;decode destination data register, append to printBuffer
            RTS         ;return to MAIN.X68 for printing 

            


*************************** OR Decode ***************************
decOR:
            LEA     orMSG, A0   ;load "OR" message
            JSR     ADD2BUFFER  ;put it in the printBuffer
            
            CMP.B   #0, D4  ;is the size .B?
            BNE     o_skip1  ;skip to next cmp if not   
            
            MOVE.B  #8, D6     ;set size for EA decoing
            LEA     byteMSG, A0  ;load ".B " message
            JSR     ADD2BUFFER  ;append it to printBuffer
            BRA     o_direction ;skip to decoding the EA direction
o_skip1
            CMP.B   #1, D4  ;is the size .W?
            BNE     o_skip2  ;skip to next cmp if not   
            
            MOVE.B  #16, D6     ;set size for EA decoing
            LEA     wordMSG, A0  ;load ".W " message
            JSR     ADD2BUFFER  ;append it to printBuffer
            BRA     o_direction ;skip to decoding the EA direction
o_skip2
            MOVE.B  #32, D6     ;set size for EA decoing
            LEA     longMSG, A0  ;else it has to be a .L, load ".L " message
            JSR     ADD2BUFFER  ;append it to printBuffer

o_direction
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding EA order
            AND.L   #1, D4      ;mask uneeded bits/set to zeros

o_mem2reg   CMP.B   #0, D4    ;is it <ea> -> Dn?
            BNE     o_reg2mem ;if not, skip 
            
            JSR     EA         ;jump to EA.X68 to decode source EA and append to printBuffer
            LEA     comma, A0   ;load a comma ", " 
            JSR     ADD2BUFFER  ;append it to printBuffer
            JSR     DECODE_DN   ;find destination data register and add to printBuffer
            
            RTS                 ;return to MAIN.X68 for printing 
            
o_reg2mem   *must be Dn -> <ea>
            JSR     DECODE_DN   ;find source data register and add to printBuffer
            LEA     comma, A0   ;load a comma ", "
            JSR     ADD2BUFFER  ;append it to printBuffer
            JSR     EA         ;jump to EA.X68 to decode destination EA and append to printBuffer
            
            RTS                 ;return to MAIN.X68 for printing    

          
*************************** SUB Decode ***************************
decSUB:
            LEA     subMSG, A0  ;load "SUB" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            JSR     GET_SIZE    ;get and load the size into printBuffer (.b, .w, .l)
            
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding addressing direction
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #0, D4        ;is it (DN - <ea>) -> DN?
            BNE     ED2E ;if no, skip to (<ea> - DN) -> <ea> direction
            *(DN - <ea>) -> DN direction
            JSR     EA      ;jump to EA code for decoding source EA and appending to printBuffer
            LEA     comma, A0   ;load a comma ", "
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     DECODE_DN   ;decode destination data register, append to printBuffer
            
            RTS         ;return to MAIN.X68
ED2E:       *(<ea> - DN) -> <ea> direction
            JSR     DECODE_DN   ;decode source data register, append to printBuffer
            LEA     comma, A0   ;load a comma ", "
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     EA      ;jump to EA code for decoding destination EA and appending to printBuffer
            
            RTS         ;return to MAIN.X68



*************************** EOR Decode ***************************
decEOR:
            LEA     eorMSG, A0          ;load "EOR" message
            JSR     ADD2BUFFER          ;add it to printBuffer
            JSR     GET_SIZE            ;get and load the size into printBuffer (.b, .w, .l)
            JSR     DECODE_DN           ;ecode source data register, append to printBuffer
            LEA     comma, A0           ;load a comma ", "
            JSR     ADD2BUFFER          ;append to printBuffer
            JSR     EA                  ;jump to EA code for decoding destination EA and appending to printBuffer
            
            RTS         ;return to MAIN.X68

*************************** CMP Decode ***************************
decCMP:
            LEA     cmpMSG, A0          ;load "CMP" message
            JSR     ADD2BUFFER          ;add it to printBuffer
            JSR     GET_SIZE            ;get and load the size into printBuffer (.b, .w, .l)
            JSR     EA                  ;jump to EA code for decoding source EA and appending to printBuffer
            LEA     comma, A0           ;load a comma ", "
            JSR     ADD2BUFFER          ;append to printBuffer
            JSR     DECODE_DN           ;ecode destination data register, append to printBuffer
            
            RTS         ;return to MAIN.X68


*************************** MULS Decode ***************************
decMULS:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #6, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 7-6 to the far right to isolate for decoding            AND.L   #$3, D4      ;mask uneeded bits/set to zeros
            AND.L   #$7, D4      ;mask uneeded bits/set to zeros

            CMP.B   #7, D4      ;is it for sure MULS?
            BNE     BADFLAG     ;if not, can't decode 
            
            LEA     mulsMSG, A0  ;load "SUB" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     wordMSG, A0 ;load ".W "
            JSR     ADD2BUFFER  ;append to printBuffer
            MOVE.B  #16,D6      ;set up size for EA decodeing
            JSR     EA      ;jump to EA code for decoding source EA and appending to printBuffer
            LEA     comma, A0           ;load a comma ", "
            JSR     ADD2BUFFER          ;append to printBuffer
            JSR     DECODE_DN   ;decode destination data register, append to printBuffer
            
            RTS         ;return to Main.X68
            
            
*************************** ADD Decode ***************************
decADD:
            LEA     addMSG, A0  ;load "ADD" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            JSR     GET_SIZE    ;get and load the size into printBuffer (.b, .w, .l)
            
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding addressing direction
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #0, D4        ;is it (DN - <ea>) -> DN?
            BNE     D2E         ;if no, skip to (<ea>-DN)-><ea> direction
            *(DN - <ea>) -> DN direction
            JSR     EA          ;jump to EA code for decoding source EA and appending to printBuffer
            LEA     comma, A0   ;load a comma ", "
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     DECODE_DN   ;decode destination data register, append to printBuffer
            
            RTS                 ;return to MAIN.X68
            
D2E:       *(<ea> - DN) -> <ea> direction
            JSR     DECODE_DN   ;decode source data register, append to printBuffer
            LEA     comma, A0   ;load a comma ", "
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     EA          ;jump to EA code for decoding destination EA and appending to printBuffer
            
            RTS                 ;return to MAIN.X68

            
            
*************************** ADDA Decode ***************************
decADDA:
            LEA     addaMSG, A0  ;load "ADDA" message
            JSR     ADD2BUFFER  ;add it to printBuffer

            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding size
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #0, D4      ;is it .W?
            BNE     add_l       ;if no, skip to long
            
            LEA     wordMSG, A0   ;load ".W " message
            JSR     ADD2BUFFER  
            MOVE.B  #16, D6     ;set size for EA decodeing
            JSR     EA          ;jump to EA code for decoding source EA and appending to printBuffer
            
            LEA     comma, A0   ;load ", "
            JSR     ADD2BUFFER  ;add message to printBuffer
            
            JSR     DECODE_AN   ;decode destination address register, append to printBuffer
            RTS                 ;return to MAIN.X68
add_l:
            LEA     longMSG, A0   ;load ".L " message
            JSR     ADD2BUFFER  ;append to printBuffer
            MOVE.B  #32, D6     ;set size for EA decodeing
            JSR     EA          ;jump to EA code for decoding source EA and appending to printBuffer

            LEA     comma, A0   ;load ", "
            JSR     ADD2BUFFER  ;add message to printBuffer

            JSR     DECODE_AN   ;decode destination address register, append to printBuffer
            RTS                 ;return to MAIN.X68







*************************** ASL/ASR Decode ***************************
decASL:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding size
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it rotate left?
            BNE     decASR       ;if no, skip to ASR
            
            LEA     aslMSG, A0  ;load "ASL" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     wordMSG, A0   ;load ".W " message
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     EA          ;jump to EA code for decoding source EA and appending to printBuffer
            RTS              ;return to MAIN.X68

decASR:
            LEA     asrMSG, A0  ;load "ASR" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     wordMSG, A0   ;load ".W " message
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     EA          ;jump to EA code for decoding source EA and appending to printBuffer
            RTS              ;return to MAIN.X68


decASLreg:  *** Decode ASL with reg or immediate as shift count ***
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding size
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it rotate left?
            BNE     decASRreg    ;if no, skip to ASR
            
            LEA     aslMSG, A0  ;load "ASL" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            JSR     GET_SIZE    ;get and load the size into printBuffer (.b, .w, .l)
            
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #5, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 5 to the far right to isolate for decoding shift count source
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it data reg as shift count source?
            BNE     asl_im      ;if no, skip to immediate shift count
            
            JSR     DECODE_DN   ;get data register as source and append to printBuffer
            LEA     comma, A0   ;load ", "
            JSR     ADD2BUFFER  ;add message to printBuffer
            JSR     V2DECODE_DN   ;get data register as destination opperand and append to printBuffer
            RTS                 ;return to MAIN.X68


asl_im              *find immediate shift number 
            LEA     hashtag, A0 ;load "#" for immidiate
            JSR     ADD2BUFFER  ;append to printBuffer
            LEA     hexSign, A0 ;load  "$" for hex
            JSR     ADD2BUFFER  ;append to printBuffer
    
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #9, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 11-9 to the far right to isolate for decoding shift count (1-8)
            AND.L   #$7, D4      ;mask uneeded bits/set to zeros
           
            CMP.B   #0, D4       ;if it's zero, it needs to be adjusted to 8 first
            BNE     asl_hex_conv
            ADDI.B  #8, D4       ;change to 8, then continue with hex conversion
asl_hex_conv            
            MOVE.B  #8,D0         ;load length of hex value
            JSR     HexToAscii    ;convert num in D4 to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add immediate value to buffer
            LEA     comma, A0   ;load ", "
            JSR     ADD2BUFFER  ;add message to printBuffer
            JSR     V2DECODE_DN     ;get data register as destination opperand and append to printBuffer
            RTS                 ;return to MAIN.X68




decASRreg:  *** Decode ASR with reg or immediate as shift count ***
            LEA     asrMSG, A0  ;load "ASR" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            JSR     GET_SIZE    ;get and load the size into printBuffer (.b, .w, .l)

            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #5, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 5 to the far right to isolate for decoding shift count source
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it data reg as shift count source?
            BNE     asr_im    ;if no, skip to immediate shift count
            
            JSR     DECODE_DN   ;get data register as source and append to printBuffer
            LEA     comma, A0   ;load ", "
            JSR     ADD2BUFFER  ;add message to printBuffer
            JSR     V2DECODE_DN   ;get data register as destination opperand and append to printBuffer
            RTS                 ;return to MAIN.X68


asr_im              *find immediate shift number
            LEA     hashtag, A0 ;load "#" for immidiate
            JSR     ADD2BUFFER  ;append to printBuffer
            LEA     hexSign, A0 ;load  "$" for hex
            JSR     ADD2BUFFER  ;append to printBuffer
     
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #9, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 11-9 to the far right to isolate for decoding shift count (1-8)
            AND.L   #$7, D4      ;mask uneeded bits/set to zeros
           
            CMP.B   #0, D4       ;if it's zero, it needs to be adjusted to 8 first
            BNE     asr_hex_conv
            ADDI.B  #8, D4       ;change to 8, then continue with hex conversion
asr_hex_conv            
            MOVE.B  #8,D0         ;load length of hex value
            JSR     HexToAscii    ;convert num in D4 to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add immediate value to buffer
            LEA     comma, A0   ;load ", "
            JSR     ADD2BUFFER  ;add message to printBuffer
            JSR     V2DECODE_DN     ;get data register as destination opperand and append to printBuffer
            RTS                 ;return to MAIN.X68



*************************** LSL/LSR Decode ***************************
decLSL:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding size
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it rotate left?
            BNE     decLSR       ;if no, skip to LSR
            
            LEA     lslMSG, A0  ;load "LSL" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     wordMSG, A0   ;load ".W " message
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     EA          ;jump to EA code for decoding source EA and appending to printBuffer
           
            RTS              ;return to MAIN.X68

decLSR:
            LEA     lsrMSG, A0  ;load "LSR" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     wordMSG, A0   ;load ".W " message
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     EA          ;jump to EA code for decoding source EA and appending to printBuffer

            RTS              ;return to MAIN.X68




decLSLreg:  *** Decode LSL with reg or immediate as shift count ***
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding size
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it rotate left?
            BNE     decLSRreg    ;if no, skip to LSR
            
            LEA     lslMSG, A0  ;load "LSL" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            JSR     GET_SIZE    ;get and load the size into printBuffer (.b, .w, .l)
            
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #5, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 5 to the far right to isolate for decoding shift count source
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it data reg as shift count source?
            BNE     lsl_im    ;if no, skip to immediate shift count
            
            JSR     DECODE_DN   ;get data register as source and append to printBuffer
            LEA     comma, A0   ;load a comma ", "
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     V2DECODE_DN   ;get data register as destination opperand and append to printBuffer
            RTS                 ;return to MAIN.X68


lsl_im              *find immediate shift number  
            LEA     hashtag, A0 ;load "#" for immidiate
            JSR     ADD2BUFFER  ;append to printBuffer
            LEA     hexSign, A0 ;load  "$" for hex
            JSR     ADD2BUFFER  ;append to printBuffer
   
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #9, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 11-9 to the far right to isolate for decoding shift count (1-8)
            AND.L   #$7, D4      ;mask uneeded bits/set to zeros
           
            CMP.B   #0, D4       ;if it's zero, it needs to be adjusted to 8 first
            BNE     lsl_hex_conv
            ADDI.B  #8, D4       ;change to 8, then continue with hex conversion
lsl_hex_conv            
            MOVE.B  #8,D0         ;load length of hex value
            JSR     HexToAscii    ;convert num in D4 to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add immediate value to buffer
            LEA     comma, A0   ;load a comma ", "
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     V2DECODE_DN     ;get data register as destination opperand and append to printBuffer
            RTS                 ;return to MAIN.X68
          



decLSRreg:  *** Decode LSR with reg or immediate as shift count ***
            LEA     lsrMSG, A0  ;load "LSR" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            JSR     GET_SIZE    ;get and load the size into printBuffer (.b, .w, .l)

            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #5, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 5 to the far right to isolate for decoding shift count source
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it data reg as shift count source?
            BNE     lsr_im      ;if no, skip to immediate shift count
            
            JSR     DECODE_DN   ;get data register as source and append to printBuffer
            LEA     comma, A0   ;load a comma ", "
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     V2DECODE_DN   ;get data register as destination opperand and append to printBuffer
            RTS                 ;return to MAIN.X68


lsr_im              *find immediate shift number  
            LEA     hashtag, A0 ;load "#" for immidiate
            JSR     ADD2BUFFER  ;append to printBuffer
            LEA     hexSign, A0 ;load  "$" for hex
            JSR     ADD2BUFFER  ;append to printBuffer
   
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #9, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 11-9 to the far right to isolate for decoding shift count (1-8)
            AND.L   #$7, D4      ;mask uneeded bits/set to zeros
           
            CMP.B   #0, D4       ;if it's zero, it needs to be adjusted to 8 first
            BNE     lsr_hex_conv
            
            ADDI.B  #8, D4       ;change to 8, then continue with hex conversion
lsr_hex_conv            
            MOVE.B  #8,D0         ;load length of hex value
            JSR     HexToAscii    ;convert num in D4 to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add immediate value to buffer
            LEA     comma, A0   ;load a comma ", "
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     V2DECODE_DN     ;get data register as destination opperand and append to printBuffer
            RTS                 ;return to MAIN.X68






*************************** ROL/ROR Decode ***************************
decROL:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding size
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it rotate left?
            BNE     decROR       ;if no, skip to ROR
            
            LEA     rolMSG, A0  ;load "ROL" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     wordMSG, A0   ;load ".W " message
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     EA          ;jump to EA code for decoding source EA and appending to printBuffer
            RTS              ;return to MAIN.X68
            
decROR:
            LEA     rorMSG, A0  ;load "ROR" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            LEA     wordMSG, A0   ;load ".W " message
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     EA          ;jump to EA code for decoding source EA and appending to printBuffer
            RTS              ;return to MAIN.X68



decROLreg:  *** Decode ROL with reg or immediate as shift count ***
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #8, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 8 to the far right to isolate for decoding size
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it rotate left?
            BNE     decRORreg    ;if no, skip to ROR
            
            LEA     rolMSG, A0  ;load "ROL" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            JSR     GET_SIZE    ;get and load the size into printBuffer (.b, .w, .l)
            
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #5, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 5 to the far right to isolate for decoding shift count source
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it data reg as shift count source?
            BNE     rol_im    ;if no, skip to immediate shift count
            
            JSR     DECODE_DN   ;get data register as source and append to printBuffer
            LEA     comma, A0   ;load a comma ", "
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     V2DECODE_DN   ;get data register as destination opperand and append to printBuffer
            RTS                 ;return to MAIN.X68


rol_im              *find immediate shift number 
            LEA     hashtag, A0 ;load "#" for immidiate
            JSR     ADD2BUFFER  ;append to printBuffer
            LEA     hexSign, A0 ;load  "$" for hex
            JSR     ADD2BUFFER  ;append to printBuffer
    
            MOVE.W  D3, D4       ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #9, D0       ;shift count for D4
            LSR.L   D0, D4       ;shift bits 11-9 to the far right to isolate for decoding shift count (1-8)
            AND.L   #$7, D4      ;mask uneeded bits/set to zeros
           
            CMP.B   #0, D4       ;if it's zero, it needs to be adjusted to 8 first
            BNE     rol_hex_conv
            ADDI.B  #8, D4       ;change to 8, then continue with hex conversion
rol_hex_conv            
            MOVE.B  #8,D0           ;load length of hex value
            JSR     HexToAscii      ;convert num in D4 to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add immediate value to buffer
            LEA     comma, A0       ;load a comma ", "
            JSR     ADD2BUFFER      ;append to printBuffer
            JSR     V2DECODE_DN     ;get data register as destination opperand and append to printBuffer
            RTS                 ;return to MAIN.X68



decRORreg:  *** Decode ROR with reg or immediate as shift count ***
            LEA     rorMSG, A0  ;load "ROR" message
            JSR     ADD2BUFFER  ;add it to printBuffer
            JSR     GET_SIZE    ;get and load the size into printBuffer (.b, .w, .l)

            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #5, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bit 5 to the far right to isolate for decoding shift count source
            AND.L   #$1, D4      ;mask uneeded bits/set to zeros

            CMP.B   #1, D4      ;is it data reg as shift count source?
            BNE     ror_im      ;if no, skip to immediate shift count
            
            JSR     DECODE_DN   ;get data register as source and append to printBuffer
            LEA     comma, A0   ;load a comma ", "
            JSR     ADD2BUFFER  ;append to printBuffer
            JSR     V2DECODE_DN   ;get data register as destination opperand and append to printBuffer
            RTS                 ;return to MAIN.X68


ror_im              *find immediate shift number 
            LEA     hashtag, A0 ;load "#" for immidiate
            JSR     ADD2BUFFER  ;append to printBuffer
            LEA     hexSign, A0 ;load  "$" for hex
            JSR     ADD2BUFFER  ;append to printBuffer
              
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #9, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 11-9 to the far right to isolate for decoding shift count (1-8)
            AND.L   #$7, D4      ;mask uneeded bits/set to zeros
           
            CMP.B   #0, D4       ;if it's zero, it needs to be adjusted to 8 first
            BNE     ror_hex_conv
            
            ADDI.B  #8, D4       ;change to 8, then continue with hex conversion
ror_hex_conv            
            MOVE.B  #8,D0         ;load length of hex value
            JSR     HexToAscii    ;convert num in D4 to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add immediate value to buffer
            LEA     comma, A0       ;load a comma ", "
            JSR     ADD2BUFFER      ;append to printBuffer
            JSR     V2DECODE_DN     ;get data register as destination opperand and append to printBuffer
            RTS                 ;return to MAIN.X68





            
            
*********************************************************************************
*
* Method Name:   BADFLAG
*
* Description:   If a word in memory is determined to be un-decodable, method sets 
*                flag to bad, then returns to Main.X68. If flag = 0 (bad), Main method
*                will print out the undecoded data before re-looping program.
*
* Preconditions:    None, flag is set to good by Main.
* Postconditions:   Flag is set to bad, returns to Main.X68
*
*********************************************************************************

BADFLAG:    
            MOVE.B #0,D5  ;set flag to bad, can't decode
            RTS     ;return to caller in Main.X68 to print address and word value







*********************************************************************************
*
* Method Name:   -- HELPER METHODS --
*
* Description:    methods to cut down repetative tasks 
*
*********************************************************************************
      
      

*************** Decode Data Register Bits 11-9 ***************
DECODE_DN:  
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #9, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 11-9 to far right to isolate for data register decode
            AND.L   #7, D4      ;mask uneeded bits/set to zeros
D_zero:
            CMP.B   #0, D4       ;is it D0?
            BNE     D_one       ;if not try D1
            LEA     d0MSG, A0    ;else load D0 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS
D_one: 
            CMP.B   #1, D4       ;is it D1?
            BNE     D_two       ;if not try D2
            LEA     d1MSG, A0    ;else load D1 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

D_two:  
            CMP.B   #2, D4       ;is it D2?
            BNE     D_three     ;if not try D3
            LEA     d2MSG, A0    ;else load D2 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

D_three:
            CMP.B   #3, D4       ;is it D3?
            BNE     D_four      ;if not try D4
            LEA     d3MSG, A0    ;else load D3 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

D_four: 
            CMP.B   #4, D4       ;is it D4?
            BNE     D_five      ;if not try D5
            LEA     d4MSG, A0    ;else load D4 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

D_five:
            CMP.B   #5, D4       ;is it D5?
            BNE     D_six       ;if not try D6
            LEA     d5MSG, A0    ;else load D5 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

D_six       
            CMP.B   #6, D4       ;is it D6?
            BNE     D_seven     ;if not, try D7
            LEA     d6MSG, A0    ;else load D6 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS
            
D_seven:
            LEA     d7MSG, A0    ;is has to be D7 then. Load D7 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS



*************** V2 Decode Data Register Bits 2-0 for shifting ops ***************
V2DECODE_DN:  
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            AND.L   #7, D4      ;mask uneeded bits/set to zeros
V2D_zero:
            CMP.B   #0, D4       ;is it D0?
            BNE     V2D_one       ;if not try D1
            LEA     d0MSG, A0    ;else load D0 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS
V2D_one: 
            CMP.B   #1, D4       ;is it D1?
            BNE     V2D_two       ;if not try D2
            LEA     d1MSG, A0    ;else load D1 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

V2D_two:  
            CMP.B   #2, D4       ;is it D2?
            BNE     V2D_three     ;if not try D3
            LEA     d2MSG, A0    ;else load D2 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

V2D_three:
            CMP.B   #3, D4       ;is it D3?
            BNE     V2D_four      ;if not try D4
            LEA     d3MSG, A0    ;else load D3 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

V2D_four: 
            CMP.B   #4, D4       ;is it D4?
            BNE     V2D_five      ;if not try D5
            LEA     d4MSG, A0    ;else load D4 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

V2D_five:
            CMP.B   #5, D4       ;is it D5?
            BNE     V2D_six       ;if not try D6
            LEA     d5MSG, A0    ;else load D5 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

V2D_six       
            CMP.B   #6, D4       ;is it D6?
            BNE     V2D_seven     ;if not, try D7
            LEA     d6MSG, A0    ;else load D6 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS
            
V2D_seven:
            LEA     d7MSG, A0    ;is has to be D7 then. Load D7 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

     

*************** decode Address register ***************
DECODE_AN:  
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #9, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 11-9 to far right to isolate for address register decode
            AND.L   #7, D4      ;mask uneeded bits/set to zeros

         
            CMP.B   #0,D4       ;is it A0?
            BNE     A_one       ;if not, try A1
            LEA     ar0MSG,A0    ;else load A0 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS
A_one: 
            CMP.B   #1,D4       ;is it A1?
            BNE     A_two       ;if not, try A2
            LEA     ar1MSG,A0    ;else load A1 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

A_two:  
            CMP.B   #2,D4       ;is it A2?
            BNE     A_three     ;if not, try A3
            LEA     ar2MSG,A0    ;else load A2 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

A_three:
            CMP.B   #3,D4       ;is it A3?
            BNE     A_four      ;if not, try A4
            LEA     ar3MSG,A0    ;else load A3 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

A_four: 
            CMP.B   #4,D4       ;is it A4?
            BNE     A_five      ;if not, try A5
            LEA     ar4MSG,A0    ;else load A4 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

A_five:
            CMP.B   #5,D4       ;is it A5?
            BNE     A_six       ;if not, try A6
            LEA     ar5MSG,A0    ;else load A5 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

A_six       
            CMP.B   #6,D4       ;is it A6?
            BNE     A_seven     ;if not, try A7
            LEA     ar6MSG,A0    ;else load A6 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS

A_seven:
            LEA     ar7MSG,A0    ;is has to be A7 then. Load A7 message
            JSR     ADD2BUFFER  ;add message to printBuffer
            RTS
            

***************** Decode the Size in bits 7-6 *******************
GET_SIZE:            
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #6, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 7-6 to the far right to isolate for decoding size
            AND.L   #3, D4      ;mask uneeded bits/set to zeros
            
            CMP.B   #0, D4      ;is it a byte?
            BEQ     sByte      
            CMP.B   #1, D4      ;is it a word?
            BEQ     sWord
            CMP.B   #2, D4      ;is it a long?
            BEQ     sLong
            JMP     BADFLAG     ;if not these, can't decode
sByte:
            LEA     byteMSG, A0 ;load ".B " message
            JSR     ADD2BUFFER  ;append to printBuffer
            MOVE.B  #8, D6     ;set size for EA decodeing
            RTS         
sWord:
            LEA     wordMSG, A0 ;load ".B " message
            JSR     ADD2BUFFER  ;append to printBuffer
            MOVE.B  #16, D6     ;set size for EA decodeing
            RTS     
sLong:            
            LEA     longMSG, A0 ;load ".B " message
            JSR     ADD2BUFFER  ;append to printBuffer
            MOVE.B  #32, D6     ;set size for EA decodeing 
            RTS        




***************** Decode Size of Immediate data, add Imm data to printBuffer *****************            
GET_IM_SIZE:
            MOVE.W  D3, D4      ;make a temp copy of opword in D4 for manipulation
            MOVE.B  #6, D0      ;shift count for D4
            LSR.L   D0, D4      ;shift bits 7-6 to the far right to isolate for decoding size
            AND.L   #3, D4      ;mask uneeded bits/set to zeros
            CMP.B   #0, D4      ;is it a byte?
            BNE     size_w      ;if no, skip to next comparison
            
size_b:
            LEA     byteMSG, A0   ;load message ".B "
            JSR     ADD2BUFFER    ;add message to printBuffer            
            LEA     hashtag, A0   ;load message "#"
            JSR     ADD2BUFFER    ;add message to printBuffer           
            LEA     hexSign, A0   ;load message "$"
            JSR     ADD2BUFFER    ;add message to printBuffer

            CLR.L   D4            ;clear register  
            CLR.L   D0            ;clear register
            MOVE.W  A3, A4        ;update address pointer incase opcode still can't be decoded at some point
            MOVE.W  (A3)+, D4     ;grab the immediate data from the word after the opcode
            MOVE.B  #8,D0         ;load length of hex value
            JSR     HexToAscii    ;convert to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add immediate value to buffer
            
            LEA     comma, A0    ;load message ", " 
            JSR     ADD2BUFFER   ;add to buffer
            RTS             

size_w:
            CMP.B   #1, D4      ;is it a word?
            BNE     size_l   ;if no, skip to next comparison
            
            LEA     wordMSG, A0   ;load message ".W "
            JSR     ADD2BUFFER    ;add message to printBuffer          
            LEA     hashtag, A0   ;load message "#"
            JSR     ADD2BUFFER    ;add message to printBuffer           
            LEA     hexSign, A0   ;load message "$"
            JSR     ADD2BUFFER    ;add message to printBuffer
            
            CLR.L   D4            ;clear register  
            CLR.L   D0            ;clear register
            MOVE.W  A3, A4        ;update address pointer incase opcode still can't be decoded at some point
            MOVE.W  (A3)+, D4     ;grab the immediate data from the word after the opcode
            MOVE.B  #16, D0        ;load length of hex value
            JSR     HexToAscii    ;convert to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer, A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add immediate value to buffer
            
            LEA     comma, A0    ;load message ", " 
            JSR     ADD2BUFFER   ;add to buffer
            RTS         


size_l:            
            CMP.B   #2, D4      ;is it a long?
            BNE     BADFLAG    ;if no, can't be decoded   
         
            LEA     longMSG, A0   ;load message ".L "
            JSR     ADD2BUFFER    ;add message to printBuffer                        
            LEA     hashtag, A0   ;load message "#"
            JSR     ADD2BUFFER    ;add message to printBuffer            
            LEA     hexSign, A0   ;load message "$"
            JSR     ADD2BUFFER    ;add message to printBuffer
            
            CLR.L   D4            ;clear register  
            CLR.L   D0            ;clear register
            MOVE.W  A3, A4        ;update address pointer incase opcode still can't be decoded at some point
            MOVE.L  (A3)+, D4     ;grab the immediate data from the long after the opcode
            MOVE.B  #32,D0        ;load length of hex value
            JSR     HexToAscii    ;convert to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer, A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add immediate value to buffer
            
            LEA     comma, A0    ;load message ", " 
            JSR     ADD2BUFFER   ;add to buffer
            RTS
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    




*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
