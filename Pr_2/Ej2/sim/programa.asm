# Prog de prueba para Pr?ctica 2. Ej 1

.data 0x00002000
num0: .word 1 # posic 0
num1: .word 2 # posic 4
num2: .word 4 # posic 8 
num3: .word 8 # posic 12 
num4: .word 16 # posic 16 
num5: .word 32 # posic 20
num6: .word 0 # posic 24
num7: .word 0 # posic 28
num8: .word 0 # posic 32
num9: .word 0 # posic 36
num10: .word 0 # posic 40
num11: .word 0 # posic 44

.text 0
main:
 # RIESGOS BRANCH
  addi $t8, $t8, 0xFFFFFFFF #guardamos en r24 todo 1s para el control de errores
  lw $t1, 0($zero) # en r9 guarda un 1
  lw $t2, 0($zero) # en r10 guarda un 1
  beq $t1, $t2, d1 # si r9 y r10 son iguales (salto efectivo) salta a d1
  or $t9, $t9, $t8 # esta instruccion no deberia ejecutarse. Si r25 tiene 1s en vez de 0s es que ha fallado
  or $t9, $t9, $t8 # esta instruccion no deberia ejecutarse. Si r25 tiene 1s en vez de 0s es que ha fallado
  or $t9, $t9, $t8 # esta instruccion no deberia ejecutarse. Si r25 tiene 1s en vez de 0s es que ha fallado
  nop
  nop
  nop
  d1: lw $t1, 8($zero) # en r9 guarda un 4
  beq $t1, $t2, d1 # si r9 y r10 son iguales (salto no efectivo) salta a d1
  nop
  nop
  nop
  add $t2, $t2, $t2 # se guarda en r9 un 2
  add $t2, $t2, $t2 # se guarda en r9 un 4
  beq $t1, $t2, d2 # si r9 y r10 son iguales (salto efectivo) salta a d3
  or $t9, $t9, $t8 # esta instruccion no deberia ejecutarse. Si r25 tiene 1s en vez de 0s es que ha fallado
  or $t9, $t9, $t8 # esta instruccion no deberia ejecutarse. Si r25 tiene 1s en vez de 0s es que ha fallado
  or $t9, $t9, $t8 # esta instruccion no deberia ejecutarse. Si r25 tiene 1s en vez de 0s es que ha fallado
  nop
  nop
  nop
  d2: add $t1, $t1, $t1 # se guarda en r9 un 8
  beq $t1, $t2, d1 # si r9 y r10 son iguales (salto no efectivo) salta a d1 (bucle infinito)
  nop
  nop
  nop
  j d3
  or $t9, $t9, $t8 # esta instruccion no deberia ejecutarse. Si r25 tiene 1s en vez de 0s es que ha fallado
  or $t9, $t9, $t8 # esta instruccion no deberia ejecutarse. Si r25 tiene 1s en vez de 0s es que ha fallado
  or $t9, $t9, $t8 # esta instruccion no deberia ejecutarse. Si r25 tiene 1s en vez de 0s es que ha fallado
  or $t9, $t9, $t8 # esta instruccion no deberia ejecutarse. Si r25 tiene 1s en vez de 0s es que ha fallado
  or $t9, $t9, $t8 # esta instruccion no deberia ejecutarse. Si r25 tiene 1s en vez de 0s es que ha fallado
  or $t9, $t9, $t8 # esta instruccion no deberia ejecutarse. Si r25 tiene 1s en vez de 0s es que ha fallado
  nop 
  nop
  nop
  d3: addi $s7, $zero, 0xFFFFFFFF # control de que el programa ha llegado al final (r23 = -1)
  nop
  nop
  nop
  d4: beq $zero, $zero, d4
  nop
  nop
  
  
