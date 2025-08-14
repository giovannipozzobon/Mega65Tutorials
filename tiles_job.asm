// ============================================
// KickAssembler - MEGA65
// Processa solo le righe pari della mappa
// ============================================

.const MAP_WIDTH   = 20
.const MAP_HEIGHT  = 25

// Tabelle in memoria (puoi cambiare indirizzi)
// Mappa: MAP_WIDTH x MAP_HEIGHT, 2 byte per tile
// TileTable: 4 byte per tile
// Schermo: 20 colonne x 25 righe, 2 caratteri per byte

// ============================================
// Zero-page vars
// ============================================



// ============================================
// Programma
// ============================================

ProcessEvenRows:
    // Partenza mappa e schermo
    lda #<Map
    sta mapPtrLo
    lda #>Map
    sta mapPtrHi

    lda #<SCREEN_BASE
    sta scrPtrLo
    lda #>SCREEN_BASE
    sta scrPtrHi

    //Salva il valore 4 nella memoria
    lda #4
    sta value_Lo



    ldy #0       // Riga pari iniziale
RowLoop:
    ldx #0       // Colonna

ColLoop:
    // --- Legge codice tile (2 byte) ---
    // Facciamo l'assunzione che ci siano solo 256 tiles quindi da zero a 255 anche se nel file le tiles
    // sono rappresetate da una word. Prendiamo come da file solo il primo byte della word quindi tileCodeLo
    /*lda (mapPtrLo),y
    sta tileCodeLo
    iny
    lda (mapPtrLo),y
    sta tileCodeHi
    iny */

    // --- Legge codice tile (2 byte) ---
     _set16(mapPtrLo, tileCodeLo)
    

    // --- Calcola indirizzo tile: TILE_PTR + (tileIndex * 4) ---
    /*lda tileCodeLo
    asl           // *2
    rol tileCodeHi
    asl           // *4
    rol tileCodeHi
    clc
    adc #<TILE_PTR
    sta tilePtrLo
    lda tileCodeHi
    adc #>TILE_PTR
    sta tilePtrHi */
    // D = C + (A * B)
    //_mul16(A,B,C,D)
    _mul16(tileCodeLo,value_Lo,Tiles,tilePtrLo)



    // --- Scrive carattere superiore nella riga corrente ---
    // prendo il placeholder del carattere e lo aggiungo alla l'indirizzo della
    // tabella dei caratteri divisa per 64
    ldy #0
    lda tilePtrLo
    clc
    adc #Chars/64
    sta (scrPtrLo),y
 
    // --- Scrive carattere inferiore nella riga sotto ---
    /*lda scrPtrLo
    clc
    adc #(MAP_WIDTH*2)   // salta una riga (20 celle * 2 byte)
    sta tmpLo
    lda scrPtrHi
    adc #0
    sta tmpHi*/
    _add16im(scrPtrLo, (MAP_WIDTH*2) , tmpLo)

    iny
    lda tilePtrLo+2
    clc
    adc #Chars/64
    sta (tmpLo),y


    inx
    cpx #MAP_HEIGHT*MAP_WIDTH*2
    beq exit

    // --- Vai alla tile successiva della mappa---
    lda mapPtrLo
    clc
    adc #2   // ogni tile è formata da una word 
    sta mapPtrLo
    lda mapPtrHi
    adc #0
    sta mapPtrHi

    lda scrPtrLo
    clc
    adc #(MAP_WIDTH)   // salta due righe di schermo
    sta scrPtrLo
    lda scrPtrHi
    adc #0
    sta scrPtrHi

    jsr ColLoop

exit:

    rts

