
INCLUDE "hardware.inc"


SECTION "Memcpy", ROM0[$0000]

Memcpy:
    ld a, [hli]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c 
    jr nz, Memcpy
; 0008
    ret


SECTION "Header", ROM0[$100]

EntryPoint:
    di
    jr Start
    nop

    ; Header
    ds $150 - $104


Start:
    ldh a, [rLY]
    cp SCRN_Y
    jr c, Start

    xor a
    ldh [rLCDC], a


    ; Unlock SRAM to store dump
    ld a, CART_RAM_ENABLE
    ld [rRAMG], a


    ; Dump VRAM
    xor a
    ld [rRAMB], a
    ld de, _SRAM

    ld hl, _VRAM
    ld bc, $2000
    call Memcpy


    ; Dump WRAM
    ld a, 1
    ld [rRAMB], a
    ld de, _SRAM

    ld hl, _RAM
    ld bc, $2000
    call Memcpy


    ; Dump OAM, FEXX, IO and HRAM
    ld a, 2
    ld [rRAMB], a
    ld de, _SRAM

    ld hl, _OAMRAM
    ld bc, $200
    call Memcpy


    ; Lock and display finish
    xor a
    ld [rRAMG], a

    ldh [rBGP], a
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a

.lock
    ld bc, LOW(rLY)
.wait
    ld a, [$ff00+c]
    cp b
    jr z, .wait
    cp SCRN_Y - 1
    jr z, .lock

    ldh a, [rBGP]
    cpl
    ldh [rBGP], a
    jr .wait
