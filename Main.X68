*--------------------------------------------------------------------------
* Title      : 68K Disassembler 
* Written by : Midori Williams and Derek Wong-Yee
* Date       : 3/1/19
* 
* Description: 
* This is the starting file for a 68K instruction dissasembler which reads a starting and
* ending address from Config.cfg and prints the dissasembled code to Output.txt
* Responsibilities of Main.X68 are as follows:
*   -Loads included files into memory: Opcode.X68 and EA.X68
*   -Establishes/manages start and end address to dissasemble 
*   -Handles all I/O and global variables/constants/buffers
*   -Provides methods for hex-ascii conversions, adding to the print buffer, and printing to Output.txt

*---------------------------------------------------------------------------
    ORG    $1500    *location where included files are put
*---------------------------------------------------------------------------
START:      

            BRA     DISASSEMBLER    *jump to actual start of program at ORG $1000
            INCLUDE 'Midori_Williams_Opcode.X68'
            INCLUDE 'Midori_Williams_EA.X68'

*******************************************************************************
* Method Name: DISASSEMBLER
* Description: Loads starting address into register A3 and compares it to the
* ending address in A4, ends program when equal. Otherwise loops through continuously
* printing the disassembled opcode or printing the address and data for
* non-decodable words. 
* 
* General Registers:
*   A3 = pointer to current address (next address after postincrement)
*   A4 = Copy of current address in case opcode can't be decoded
*   D3 = current opcode, read only till program re-loops
*   D4 = working opcode for masking, shifting, etc.
*   D5 = good/bad flag, 1=good 0=bad
*   D6 = size for EA decode of immediate data
*
* Printing Buffers and Registers:
*   - printBuffer = address of buffer for printing final multi-string to I/O
*   A1 = Pointer to current location in printBuffer (set by opcode person, EA does not change)
*   A0 = Pointer to string/constant to be added to printBuffer. Must LEA string/constant before calling "ADD2BUFFER" method.
*   - hex2ascBuffer = converted ascii value/string stored here after calling "HexToAscii"
*
* Preconditions:  None
* Postconditions: TBD
*********************************************************************************

    ORG     $1000

DISASSEMBLER:
            MOVE.B  #50, D0
            TRAP    #15        ;close any open files
            
            MOVE.B  #51, D0
            LEA     configFile, A1
            TRAP    #15         ;open config.cfg file
            
            LEA     fileBuffer, A1  ;load file buffer
            MOVE.L  #8, D2      ;bytes to read
            MOVE.B  #53, D0     ;read from config.cfg file into buffer (first 8 bytes = start address)
            TRAP    #15
            
            JSR     AsciiToHex    ;convert it to Hex
            MOVE.L  D7, A3        ;load start addr into A3


            LEA     fileBuffer, A1  ;load file buffer
            MOVE.L  #2, D2      ;bytes to read
            MOVE.B  #53, D0     ;read from config.cfg file into buffer
            TRAP    #15         ;this just discards the 2 byte LF/CR in the file
            
            LEA     fileBuffer, A1  ;load file buffer
            MOVE.L  #8, D2      ;bytes to read
            MOVE.B  #53, D0     ;read from config.cfg file into buffer (last 8 bytes = end address)
            TRAP    #15
            
            JSR     AsciiToHex    ;convert it to Hex
            MOVE.L  D7, A5        ;load end addr into A5
            

************************* Start Dissasembler Loop *************************
DISLOOP:    
            CMPA.L  A3, A5     ; does the reading address equal the end address?
            BLE     ENDPROG    ;if so, nothing else to read, jumpt to end of program
          
            MOVE.B  #1,D5      ;set flag to good
            LEA     printBuffer,A1  ;load the printBuffer          
            MOVE.L  A3,D4     ;load address as a number to print
            CLR.L   D0          ;clear register
            MOVE.B  #16, D0         ;set address size for hex to ascii conversion
            JSR     HexToAscii      ;convert address to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0    ;load ascii buffer with address
            JSR     ADD2BUFFER     ;add address to printBuffer
            
            JSR     OPCODE      ; start to decode in opcode.x68
            
            CMP     #1,D5       ;on return, check if flag is still good
            BNE     CANTDECODE     ;if not, print undecoded data
            
            MOVE.B  #0,(A1)        ;else, successfull decode, add null deliminator to completed string
            LEA     printBuffer,A1 ;reload print buffer for printing finished string
            JSR     TrapTask13      ;print it
            
            JMP     DISLOOP     ;continue loop  
           
            
            
CANTDECODE:   *opcode can't be decoded, print address and data
            LEA     printBuffer,A1  ;reload the printBuffer in case any strings were written in the decode, before failing                                                                                                
            
            MOVE.L  A4,D4           ;reload address as a number to print
            CLR.L   D0              ;clear register
            MOVE.B  #16, D0         ;set address size for hex to ascii conversion
            JSR     HexToAscii      ;convert address to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0    ;load ascii buffer with address
            JSR     ADD2BUFFER     ;add address to printBuffer
            
            LEA     dataMSG,A0     ;load message "DATA"
            JSR     ADD2BUFFER     ;add message to printBuffer

            LEA     hexSign, A0   ;load message "$"
            JSR     ADD2BUFFER    ;add message to printBuffer
            
            CLR.L   D4      ;clear register  
            CLR.L   D0      ;clear register                      
            MOVE.W  (A4),D4 ;load the undecodable word
            MOVE.B  #16,D0      ;load length of hex value
            JSR     HexToAscii  ;convert to ascii, puts in hex2ascBuffer
            LEA     hex2ascBuffer,A0  ;load ascii buffer  for printing
            JSR     ADD2BUFFER      ;add word to buffer
            
            MOVE.B  #0,(A1)         ;add null deliminator to completed string
            LEA     printBuffer,A1  ;reload print buffer for printing finished string
            JSR     TrapTask13
            
            JMP     DISLOOP     ;continue loop  



ENDPROG:    * End of the program

    SIMHALT
  
  



*********************************************************************************
* Method Name:    ADD2BUFFER
* Written by : Midori Williams
*
* Description:    Adds an ascii string from A0 to the current possition in printBuffer
*                 pointed to by A1
*
* Preconditions:  ascii/constant string address is loaded into A0
*                 printBuffer address is loaded into A1 
*
* Postconditions: ascii string/constant is now appended to printBuffer
*                 A1 postincrememnted to point to the next spot in the printBuffer   
*********************************************************************************
ADD2BUFFER:
            MOVE.B  (A0)+,(A1)+     ;copy char from A0 to buffer
            CMP.B   #$00,(A0)     ;end of input string? (null delimited)  
            BNE     ADD2BUFFER    ;if not, copy another byte        
            RTS                 ;return to caller with buffer filled        
        
        
        
    
 
*----------------------------------------------------------------------------------
* Method Name: HexToAscii
* Written by : Midori Williams
*
* Description: Converts hex vals 0-9,A-F a byte at a tiFe to Ascii chars '0'-'9' and 'A'-'F' 
*              Transforms 1, 2, or 4 Bytes in D4 into 
*              its 2, 4, or 8 Byte (8 bits each) equivalent Ascii value 
*              Number size is stored in D0
*  
*  Preconditions & Input:
*       D4 (input) stores value to be converted 
*       D0 stores bit value length (#4, #8, #16, or #32)
*       Assumptions: D0 contains valid length
*       This function calls another function (add_ascii)
*
*  Postconditions & Output:
*       hex2ascBuffer (output) points to a memory buffer holding ascii chars (null-terminated)
*----------------------------------------------------------------------------------
HexToAscii     
            **initialize variables**
            LEA hex2ascBuffer,A6 *load buffer
            CLR.L   D2      *empty contents for use as temp number storage for conversion
            CLR.L   D1      *empty contents for use as bit-shift counter in convLoop
            MOVE.B  D0,D1   *copy number length
            SUBI.B  #4,D1   *value is shifted 1x fewer than the bit length of number
           
convLoop    
            **start looping**
            MOVE.L  D4,D2   *copy hex value into D2 for 4-bit masking
            LSR.L   D1,D2   *shift 4 decode bits to far right to isolate
            AND.L   #$0000000F,D2  *mask all but 4 decode bits
            JSR     add_ascii   *do 4 bit conversion to ascii, new value is 8 bits (Byte)    
            MOVE.B  D2,(A6)+    *add to buffer
            
            SUBI.B  #4,D0   *decrement our size/loop variable
            BEQ     convDone   *skip to end if we are done 

            SUBI.B  #4,D1  *decrease bit-shift counter
            BRA     convLoop   *repeat loop on next 4 bits      

convDone
            MOVE.B  #0,(A6) *set null deliminator
            RTS
**********************************************************************
* SUBROUTINE for HexToAscii: add_ascii
* add the ascii code to the digits 0-9 or A-F
* Input Parameters: <D3> = 4 bit Hex value
*
* Return parameters: D3.B = number 0...F, returned as $30-$39 or $41-$46
* Registers used internally: D3
* Assumptions: D3 contains 0-9 or A-F
*
***********************************************************************
add_ascii
            CMP.B #$A,D2 * Is it A...F?
            BGE add37 * Its A...F
            CMP.B #$0,D2 * Is it in range of 0-9?
            BGE add30 * Its a number
            BRA ret_a2h * Go back
add37       ADD.B #$37,D2 * Add 37
            BRA ret_a2h * Go back
add30       ADD.B #$30,D2 * Add 30
ret_a2h     RTS * Go back







*********************************************************************************
* Method Name:  TrapTask13
* Description:  Creates a file if none exists, and appends bytes to that file
*               while also echoing the written bytes to the screen.  You shouldn't 
*               need to change this code.
*
* Calling Convention: Callee-Saved 
*
* Preconditions & Method Input:
*   A1 points to the null-terminated buffer to write (newline will be added for you)
*
* Postconditions & Output:
*   ALL files that were previously open will be CLOSED (FileIDs will be invalid)
*   See 'Output.txt' in directory for the results, also piped to the console
*
*
*  A2 holds a pointer to null terminated string to write (input)
*  A3 points to the null-terminated file name
*  D3 holds the number of bytes already in the file to write
*
*  D5 holds number of bytes to write
********************************************************************************
toSave REG D0-D5/A2-A3
TrapTask13:
    *******************************************************************
    * Method initialization, regsiter spilling, parameter saving, etc.
    *******************************************************************
    MOVEM.L toSave, -(SP)   ;  Callee-Saved, so save and restore     
    
    MOVEA.L A1, A2 ; save this buffer to write
    LEA outFilename, A3  ; save this for later, too
      
    move #50,d0   
    trap #15 ; close all files, suggested to begin any IO 
    *******************************************************************
    * End Method Init
    *******************************************************************

    ******************************************************************************************
    * Calculate the number of bytes to write by searching for the null in the target buffer A0
    ******************************************************************************************
    CLR.L D5 *D5 is now the number of bytes to write
nullLoop:
    MOVE.B (A1)+, D0
    CMPI.B #0,D0  * compare to null
    BEQ findNullLoopDone
    ADDI.W #1, D5
    BRA nullLoop
    
findNullLoopDone:
    MOVEA.L A3, A1 * reset A1 so it points to the file to write to (to open, next)
    
    ;check if file exists, and open with task 51 if so, otherwise 52
    ;(precondition here is A1 points to the null-terminated filename )
    MOVE.B #51, D0      ;open file (task 51 is existing, 52 is new)
    trap #15
      
    if.w D0 <NE> #0 then.s         ; if file error (404, not found)
        MOVE.B #52, D0             ; open new file (52 is new)
        trap #15
    endi
    
    ********************************************************************************************************* 
    * Seek to END of FILE by counting the number of bytes, closing, reopening, then seeking.
    *    (first, count number of bytes already in the file to obtain seek position)
    *********************************************************************************************************
    Clr.L D3   ;TODO: reg save, D3 is now our count of bytes read
    MOVE.L #1, D2 ; read one byte at a time
    LEA byteRead, A1
    
countLoop:
    MOVE.B #53, D0 ; try to read one byte (TODO: move out of loop)
    trap #15
    
    CMPI.W #1,D0  ;1 == EOF
    BEQ countDone
    ADDI #1, D3
    BRA countLoop
    
countDone:    
    * close this file
     move #56,d0  
     trap #15 
     
     * reopen the target file
     MOVE.L A3,A1
     MOVE #51, D0
     trap #15
     
    * seek to right position, then continue with writing
    MOVE.L D3, D2 ; move the number of bytes found in the file to D2
    MOVE #55, D0  ; position file task
    trap #15

    ******************************************************************************
    * Actually write the buffer to the file, after caculating the number of bytes 
    *  to write and after seeking to the right location in the file for append
    ******************************************************************************

    MOVE.L D5, D2 ; restore this for the actually writing the buffer 
    ; assumes A0 hasnt changed since handed to this method      
    MOVEA.L A2, A1 ; load the address of the buffer we want to write to disk
    ; assumes file ID is still stored in D1.L  
    MOVE.B #54, D0 ; subtask 54 is write to open file (append, or?), assumes D2 holds # of bytes
    trap #15

    ; add a newline to the file output
    LEA NEWLINE, A1
    MOVE.B #54, D0 
    MOVE.B #2,D2  ; kills # of bytes to write from input param
    trap #15
    
    ; finally, close only this file
    MOVE.B #56, D0 ; close file task
    trap #15
  
    ; report to screen
    MOVEA.L A2, A1 ; load the address of the buffer we want to write to disk & screen
    MOVE.B #13, D0
    trap #15
      
    ; restore context
    MOVEM.L (SP)+, toSave
    
    RTS

  
*----------------------------------------------------------------------------------
* Method Name: AsciiToHex
* Written by : Berger, Modified by Nash
* Date       : 3/1/2019
* Description: Converts chars '0'-'9' and 'a'-'f' to 0-9,a-F
*              Transforms/unpacks 8 chars (8b each) pointed to by A1 into 
*              its (4b each) equivalent hex value 
*  
*  Preconditions & Input
*       A1 (input) points to a memory buffer holding 8 ascii chars (not null-terminated) 
*       This function calls another function (strip_ascii)
*
*  Postconditions & Output
*       D7 (output) holds the converted value 
*       Caller-Saved : D0 is temp, D6 is a loop var
*----------------------------------------------------------------------------------
AsciiToHexRegList REG D0,D6
AsciiToHex     
    MOVEM.L d6, -(SP)  *save context
    CLR.L D7 * clear our return value
    MOVE.L #8, D6 ; and set up our loop counter

chrLoop
    MOVE.B (A1)+,D0 * Get the first byte
    jsr strip_ascii * Get rid of the ascii code    
    OR.W D0,D7 * Load the bits into D7
    
    subI.B #1,D6  *decrement our loop variable
    BEQ chrDone   *skip shifting if we are done
    
    ASL.L #4,D7 * shift left 4 bits to prepare for next byte
    BRA chrLoop

chrDone
    MOVEM.L (SP)+,d6 
    RTS

**********************************************************************
* SUBROUTINE: strip_ascii
* remove the ascii code from the digits 0-9,a-f, or A-F
* Input Parameters: <D0> = ascii code
*
* Return parameters: D0.B = number 0...F, returned as 00...0F
* Registers used internally: D0
* Assumptions: D0 contains $30-$39, $41-$46 or $61-66
*
***********************************************************************
strip_ascii
      CMP.B #$39,D0 * Is it in range of 0-9?
      BLE sub30 * Its a number
      CMP.B #$46,D0 * Is is A...F?
      BLE sub37 * Its A...F
      SUB.B #$57,D0 * Its a...f
      BRA ret_sa * Go back
sub37 SUB.B #$37,D0 * Strip 37
      BRA ret_sa * Go back
sub30 SUB.B #$30,D0 * Strip 30
ret_sa RTS * Go back




***********************************************************************    
* Required variables and constants go here for your Disassembler
***********************************************************************

CR                  EQU $0D
LF                  EQU $0A
  
MSG1                DC.B 'MOVE.L D4,D5',0
MSG2                DC.B 'ADD.B D0,D1',0

outFilename         DC.B 'Output.txt',0
configFile          DC.B 'Config.cfg',0

fileBuffer          DS.B 20             ;a buffer for the Config.cfg file
byteRead            DS.B 1
ascii_val           DC.B $31,$41,$30,$30,$31,$41,$30,$30 * Test value $1A001A00

* Storage buffers,poainters, and flags
storeAddr       DS.L    1       ;temp address storage
immSize         DS.B    1       ;size of immediate value, set by Opcode person so EA person knows how big (B, W, or L)
flag            DS.B    1       ;good/bad flag, 1 means readable, 0 means can't decode
printBuffer     DS.W    40      ;storage buffer for printing data/addresses/opcodes, null terminated
hex2ascBuffer   DS.L    2       ;temp buffer for storing hex to ascii conversions before loading into printBuffer, null terminated

* Misc characters
NEWLINE         DC.B CR,LF,0
comma           DC.B    ', ',0      ;print a comma and space
hashtag         DC.B    '#',0       ;print # sign for immediate data
hexSign         DC.B    '$',0       ;print $ for hex values
forwardSlash    DC.B    '/',0       ;print $ for movem register lists
space           DC.B    ' ',0
* Opcodes for printing
dataMSG         DC.B    '  DATA  ',0
oriMSG          DC.B    '  ORI',0
addiMSG         DC.B    '  ADDI',0
cmpiMSG         DC.B    '  CMPI',0
bclrMSG         DC.B    '  BCLR ',0
moveaMSG        DC.B    '  MOVEA',0
moveMSG         DC.B    '  MOVE',0
clrMSG          DC.B    '  CLR',0
negMSG          DC.B    '  NEG',0
rtsMSG          DC.B    '  RTS',0
jsrMSG          DC.B    '  JSR ',0
movemMSG        DC.B    '  MOVEM',0
leaMSG          DC.B    '  LEA ',0
chkMSG          DC.B    '  CHK',0
addqMSG         DC.B    '  ADDQ',0
subqMSG         DC.B    '  SUBQ',0
braMSG          DC.B    '  BRA ',0
bccMSG          DC.B    '  BCC ',0
bcsMSG          DC.B    '  BCS ',0
beqMSG          DC.B    '  BEQ ',0
bgeMSG          DC.B    '  BGE ',0
bgtMSG          DC.B    '  BGT ',0
bhiMSG          DC.B    '  BHI ',0
bleMSG          DC.B    '  BLE ',0
blsMSG          DC.B    '  BLS ',0
bltMSG          DC.B    '  BLT ',0
bmiMSG          DC.B    '  BMI ',0
bneMSG          DC.B    '  BNE ',0
bplMSG          DC.B    '  BPL ',0
bvcMSG          DC.B    '  BVC ',0
bvsMSG          DC.B    '  BVS ',0
divsMSG         DC.B    '  DIVS',0
orMSG           DC.B    '  OR',0
subMSG          DC.B    '  SUB',0
eorMSG          DC.B    '  EOR',0
cmpMSG          DC.B    '  CMP',0
mulsMSG         DC.B    '  MULS',0
addMSG          DC.B    '  ADD',0
addaMSG         DC.B    '  ADDA',0
aslMSG          DC.B    '  ASL',0
asrMSG          DC.B    '  ASR',0
lslMSG          DC.B    '  LSL',0
lsrMSG          DC.B    '  LSR',0
rolMSG          DC.B    '  ROL',0
rorMSG          DC.B    '  ROR',0

* Size operations for printing
byteMSG         DC.B    '.B ',0
wordMSG         DC.B    '.W ',0
longMSG         DC.B    '.L ',0

* EA Modes for printing
d0MSG           DC.B    'D0',0
d1MSG           DC.B    'D1',0
d2MSG           DC.B    'D2',0
d3MSG           DC.B    'D3',0
d4MSG           DC.B    'D4',0
d5MSG           DC.B    'D5',0
d6MSG           DC.B    'D6',0
d7MSG           DC.B    'D7',0

ar0MSG          DC.B    'A0',0          
ar1MSG          DC.B    'A1',0          
ar2MSG          DC.B    'A2',0
ar3MSG          DC.B    'A3',0
ar4MSG          DC.B    'A4',0
ar5MSG          DC.B    'A5',0
ar6MSG          DC.B    'A6',0
ar7MSG          DC.B    'A7',0        

ari0MSG         DC.B    '(A0)',0
ari1MSG         DC.B    '(A1)',0
ari2MSG         DC.B    '(A2)',0
ari3MSG         DC.B    '(A3)',0
ari4MSG         DC.B    '(A4)',0
ari5MSG         DC.B    '(A5)',0
ari6MSG         DC.B    '(A6)',0
ari7MSG         DC.B    '(A7)',0

arpi0MSG        DC.B    '(A0)+',0
arpi1MSG        DC.B    '(A1)+',0
arpi2MSG        DC.B    '(A2)+',0
arpi3MSG        DC.B    '(A3)+',0
arpi4MSG        DC.B    '(A4)+',0
arpi5MSG        DC.B    '(A5)+',0
arpi6MSG        DC.B    '(A6)+',0
arpi7MSG        DC.B    '(A7)+',0
          
arpd0MSG        DC.B    '-(A0)',0
arpd1MSG        DC.B    '-(A1)',0
arpd2MSG        DC.B    '-(A2)',0
arpd3MSG        DC.B    '-(A3)',0
arpd4MSG        DC.B    '-(A4)',0
arpd5MSG        DC.B    '-(A5)',0
arpd6MSG        DC.B    '-(A6)',0
arpd7MSG        DC.B    '-(A7)',0          







   END    START        ; last line of source











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
