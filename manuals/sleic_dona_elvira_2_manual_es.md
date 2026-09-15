# Doña Elvira 2 — Manual de Servicio (SLEIC-Petaco, 1996)

Transcripción OCR del manual de servicio original en español,
[`SLEIC_1996_Dona_Elvira_2_Spanish_Service_Manual_with_schematics.pdf`](SLEIC_1996_Dona_Elvira_2_Spanish_Service_Manual_with_schematics.pdf)
— 142 páginas, escaneadas, sin capa de texto.

**Este archivo es una transcripción automática sin corregir.** Se generó con
`pdftoppm -r 300 -gray` y `tesseract -l spa --psm 3`. Contiene errores de
reconocimiento, y las tablas y figuras pierden su disposición original. Para
cualquier valor exacto —referencias de contactos, bobinas, lámparas, fusibles o
componentes— **la autoridad es el PDF**, no este archivo.

Los marcadores `<!-- PDF page N -->` dan la página del PDF, de modo que
cualquier pasaje puede comprobarse contra el original.

| Tipo de página | Cuántas | Tratamiento |
|---|---|---|
| Texto | 59 | transcritas |
| Figuras y despieces | 24 | sólo el pie de figura; el dibujo no es transcribible |
| Páginas en blanco | 5 | anotadas |
| Esquemas (págs. 88–141) | 54 | no transcritos; se indica el juego de hojas |

Las páginas 88–141 son el juego de esquemas, separadamente paginado en
siete bloques: I cableado general, II placa C.P.U. 8 bits (`011-030`),
III placa de sonido general (`011-065`), IV placa de drivers (`011-027`),
V placa de relés, VI placa de display y leds (`011-064`) y VII placa de
alimentación de sonido (`011-067`).

---

<!-- PDF page 1 -->

MANUAL DE SERVICIO

PIÉ

FABRICADO POR: SLEIC Creaciones e Investigaciones Electrónicas S.L.
AVDA. VALDELAPARRA, 3 POL.IND. DE ALCOBENDAS
28100 ALCOBENDAS (MADRID) T1f. 6619796 FAX 6616974

<!-- PDF page 2 -->

*(Página gráfica sin texto transcribible — ver PDF página 2.)*

<!-- PDF page 3 -->

MANUAL DE SERVICIO

ELVIRA 2

<!-- PDF page 4 -->

*(Página gráfica sin texto transcribible — ver PDF página 4.)*

<!-- PDF page 5 -->

Creaciones e Investigaciones Electrónicas S.L. (SLEIC) se reserva
el derecho de introducir modificaciones en el diseño mecánico,
electrónico o de software de la máquina sin previo aviso.

<!-- PDF page 6 -->

*(Página gráfica sin texto transcribible — ver PDF página 6.)*

<!-- PDF page 7 -->

Índice original del manual, tal como lo devuelve el OCR:

```
INDICE
DESCRIPCION Y CARACTERISTICAS . +. +. +... +. +. +... o... o.os 5
1.1.- DESCRIPCION GENERAL +. +. +... . . . . o... oros 5
SECCION 2... 8
3.1.2.- ESPECIALES 3 e $ 3 3156 06363502. 0. woo 18
.- PASILLOS . ... . 9. 000. + las... 18
¿«- DIANAS . . .: m5 0.0. e aga e ceo Comes es 19
.- PICABOLAS . 2455, s. ass ZO0
.- VELETA . . .1:omotsso e. sas. sanas 20
NNNNNN»YO.»yyNy
3.4.- LOTERIA . e «2 05% 21
VALORES PROGRAMABLES VET E E
4.2.1.- MONEDERO . . +. |). mes sn ds RSE 2Z
```

<!-- PDF page 8 -->

Índice original del manual, tal como lo devuelve el OCR:

```
4.2.3.- PARTIDAS POR RECORD DEL DÍA
4.2.6.- TEMPORIZACION DEL PICABOLAS
5.1.- ENTRADA EN AJUSTES Y TEST
5.2.- TEST DE CONTACTOS . o. o.
5.5b.- TEST DE CONTADORES +. +. +
DESPIECE GENERAL -. . +... +. +.
6.1.- RELACION DE PARTES . . .
6.2.1.- RELACION DE PARTES
6.3.- CONJUNTO FLIPPER . . +. +.
6.3.1.- RELACION DE PARTES
6.4.1.- RELACION DE PARTES
6.5.- PICABOLAS| . Ss DBA
6.6.- IMPULSOR 'SALIDA DE BOLAS
6.6.1.- RELACION DE PARTES
6.7.1.- RELACION DE PARTES
6.8.- UNIDAD DE FALTA Y GATE TRAMPILLA
6.8.1.- RELACION DE PARTES
6.9.- TIRADOR CON GUIAS LARGO .
6.9.1.- RELACION DE PARTES
6.10.1.- RELACION DE PARTES
6.11.- SILUETAS DEL TABLERO . .
6.11.1.- RELACION DE PARTES
6.12.- SUBCONJUNTOS DEL TABLERO (1)
6.12.1.- RELACION DE PARTES
6.13.- SUBCONJUNTOS DEL TABLERO (2)
6.13.1.- RELACION DE PARTES
```

<!-- PDF page 9 -->

Índice original del manual, tal como lo devuelve el OCR:

```
SUBCONJUNTOS DEL TABLERO (3)
.14.1.- RELACION DE PARTES
LAMPARAS ||Y PORTALAMPARAS .
15.1.- RELACION DE PARTES
DESCRIPCION ELECTRONICA
7.1.- RELACION DE ELEMENTOS
SECCION 8
NAAA SA
SS SIS;
SES
N NN
COM
PLACA CPU 8 BITS a... 3
1.1.- COMPONENTES PRINCIPALES
3.- MICROSWITCHES DE CPU 8
4.- MATRIZ DE CONMAerOs
COMPONENTES PRINCIPALES
DRIV
nue
2.- MATRIZ DE LUCES .
CONECTORES '... +. +. +.
COMPONENTES PRINCIPALES
4.2.- CONECTORES "
FUENTE DE ALIMENTACION +5/+12.
CONJUNTO PUENTES. o... o.
TABLA DEL MUEBLE |
Lo.
ESQUEMAS DE SERVICIO -.. . +... .. +... . +. +.
CABLEADO GENERAL
PLACA
PLACA
DE SONIDO GENERAL . .
PLACA DE RELES
PLACA DE ALIMENTACION DE SONIDO
CIRCUITOS DE ATAQUE A BOBINAS
IV-1
VI-1
vIt-1
```

<!-- PDF page 10 -->

Índice original del manual, tal como lo devuelve el OCR:

```
Indice de figuras
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
figura
PPP PPOASIISIIIIDOCADVADADABADAROROS
RR RRRR00J3D0D0RO0NAR RP PS. EE Dom
5buUNrRO NAGDNHARO d »
DESPIECE GENERAL
CONJUNTO BUMPER .
CONJUNTO FLIPPER
CONJUNTO TACA ., .
IMPULSOR SALIDA DE BOLAS
BANCADA DE DIANAS
UNIDAD DE FALTA .
GATE TRAMPILLA .
TIRADOR CON GUIAS LARGO
TABLERO DE JUEGO
SILUETAS DEL TABLERO
SUBCONJUNTOS DEL TABLERO
SUBCONJUNTOS DEL TABLERO
SUBCONJUNTOS DEL TABLERO
LAMPARAS Y PORTALAMPARAS
PLACA C.P.U 8 BITS
MATRIZ DE CONTACTOS
LINEA DE COMUN (SCAN)
LINEA DE RETORNO (RET)
PLACA DE DRIVERS
MATRIZ DE LUCES .
DRIVER DE FILAS LUCES
DRIVER DE COLUMNAS LUCES
CIRCUITO DE POTENCIA BOBINAS
CIRCUITO MEDIANA POTENCIA BOBINAS
CPU SONIDO GENERAL
PLACA DISPLAY . .
FUENTE ALIMENTACION +5/+12 . .
PLACA DE ALIMENTACION DE SONIDO
ALIMENTACION BOBINAS
MONEDERO ELECTRONICO
CONJUNTO PUENTES
TAELA DEL MUEBLE
```

<!-- PDF page 11 -->

## SECCION 1

DESCRIPCION Y CARACTERISTICAS

### 1.1.- DESCRIPCION GENERAL

El modelo DONA ELVIRA 2 de Sleic es una máquina recreativa
de bolas que ofrece al jugador y GUusuario una serie de
características muy notables por su sistema de juego y su
avanzada tecnología electrónica.

Es una pinball clásica en su concepción del tablero de
juego, aunque ofrece muchos de los detalles que son del gusto del
jugador actual.

Ahora bien, sigue cumpliendo la máxima del buen jugador de
pinball, en la que el jugador. "SABE EN CADA MOMENTO" cual o
cuales son los puntos a los que debe dirigir la bola para obtener
los premios o puntuaciones que desea. Sabe cuales son los puntos
fáciles y los puntos peligrosos y arriesgados y con su habilidad,
poca o mucha, llevará a la bola al lugar que le interesa sin que,
insistimos en este punto, "NADIE JUEGUE POR EL".

El juego tiene momentos en que es extremadamente rápido. El
jugador debe mantener un alto grado de atención y mostrar grandes
reflejos para superar las condiciones que las evoluciones de la
bola le imponen.

Sumado a su apasionante sistema de juego, en el que el
jugador se encuentra implicado, se han de tener en Cuenta los
importantes avances tecnológicos y facilidad de mantenimiento que
tanto preocupan al operador y que el mercado actual requiere.

Se ha introducido un complejo sistema de sonidos tanto
musicales, de efectos especiales y de voz, que proporcionan un
atractivo adicional al juego.

No son menores los aspectos puramente técnicos de su diseño
electrónico.

DONA ELVIRA 2 es un sistema electrónico gobernado por dos
microprocesadores que realizan cada uno una función bien
definida: Una unidad principal de 8 bits que controla el juego
y una unidad sécundaria de 8 bits que controla el sonido.

El sistema clásico de láminas de contactos ha sido
sustituido por! micro-interruptores de varilla, con la única
excepción de los pulsadores de los flippers, que se han mantenido
con láminas para ofrecer el "tacto" clásico al buen jugador de
pinball, y las láminas de las dianas que ofrecen Mayor
resistencia a los impactos de la bola.

Con este sistema y el hecho de que ninguno de ellos conmuta
corriente, incluidos los contactos de corte de fuerza de flippers
"libres de chispas", la duración de los contactos es
prácticamente ilimitada.

<!-- PDF page 12 -->

### 1.2.- CARACTERISTICAS
#### 1.2.1.- CARACTERISTICAS MECANICAS

Según puede apreciarse en la figura 1, las dimensiones
máximas del aparato son:

LARGO 129 em. (Sin Tirador) 135 cm. (Con Tirador)
ANCHO 65 cm, (Cabeza) 60 cm. (Frente)
Con Patas
ALTO 131 cm. (Cabeza abatida) 194 cm. (Cabeza Subida)
Sin Patas
ALTO T7 cm. (Cabeza abatida) 140 cm. (Cabeza abatida)

La máquina lembalada se encuentra en posición vertical, por
lo que las dimelisiones del embalaje son:

LARGO 77 cm.
ANCHO 70 cm.
ALTO 130 cm.
PESO 105 Kg.

E5cm
OEEZIO
| ¡Hem

figura 1-1 DIMENSIONES

<!-- PDF page 13 -->

1.2.2.- crelasmas ELECTRICAS

ALIMENTACION 220 V/50 Hz
GENERAL
POTENCIA 310 VA

¡ATENCION!
LA MAQUINA DEBE CONECTARSE A UN ENCHUFE DE RED PROVISTO DE TOMA
DE TIERRA PARA EVITAR DESCARGAS ELECTRICAS Y CALAMBRES. NO
UTILICE ENCHUFES MULTIPLES O LADRONES QUE NO DISPONGAN DE SU
CORRESPONDIENTE TOMA DE TIERRA. NN
Creaciones e Investigaciones Electrónicas S.L. (SLEIC) no: se
responsabiliza del incumplimiento de está obligación.

<!-- PDF page 14 -->

*Figura: figura 2-1 CONTACTOS — no transcrita, ver PDF página 14.*

<!-- PDF page 15 -->

#### 2.1.1.- DESCRIPCION DE CONTACTOS

Tenemos dos tipos de contactos: por matriz y directos según

puede verse en la figura 2-1.

CODIGO | NOMBRE TIPO
80 Entrada Monedas Directo
81 Pulsador de Test Directo
82 Contacto de falta Directo
83 Pulsador flipper izquierdo Directo
84 Contacto de corte de flipper izquierdo | Directo
85 Contacto de corte de flipper derecho Directo
86 Pulsador flipper derecho Directo
87 Pulsador Start Directo
00 Pasillo 1 Matriz
01 Pasillo 2 Matriz
02 Pasillo 3 Matriz
03 Estrella 1 Matriz
04 Estrella 2 Matriz
05 Pasillo Y Matriz
06 Pasillo 5 Matriz
07 Pasillo 6 Matriz
10 Diana 1 Matriz
11 Bancada 5 Matriz
12 Jiana 2 Matriz
13 Veleta Matriz
14 Bandas Inferiores Matriz
15 Diana 6 Matriz
16 Diana 7 Matriz
17 Pasillo 7 Matriz
20 Diana 5 Matriz
21 Bancada 6 Matriz
22 Diana 4 Matriz
23 Bancada 4 Matriz
24 Bancada 3 Matriz
25 Bancada 2 Matriz
26 Bancada 1 Matriz
27 Pasillo 8 Matriz

<!-- PDF page 16 -->

CODIGO | NOMBRE TIPO
30 Diana 3 Matriz
31 Bumper 2 Matriz
32 Bumper 1 Matriz
33 Picabolas Matriz
34 Bandas Superiores Matriz
35 Pasillo 9 Matriz
36  |Salida de Bolas | Matriz
MATRIZ DE CONTACTOS
RET7 RET6 RETS RET4 RET3 RET2 RET1 RETO
SCANO | PasilloG Pasillo5 Pasillo4 | Estrella2 | Estrellal Pasillo3 Pasillo2 Pasillo1
SCANI1 | Pasillo7 Diana7 Diana6 Bandalnf Veleta Diana2 | BancadaS | Dianal
SCAN2 | Pasillog | Bancadal | Bancada2 | Bancada2 | Bancada4 | Dianad4 Bancada6 | DianaS
SCAN3 VACIO SalidaBol | Pasilli9 | BandaSup | Picabolas | Bumper1 | Bumper2 Diana3
CONTACTOS DIRECTOS
BTr7 Brr6 BUrS BITA4 BII3 Brr2 BIT1 BITO
Star FlipperDer | CorteFDer | CorteFlzg | Flipperlzq Falta Test Monedero

<!-- PDF page 17 -->

*(Página en blanco.)*

<!-- PDF page 18 -->

*Figura: figura 2-2 LUCES — no transcrita, ver PDF página 18.*

<!-- PDF page 19 -->

#### 2.2.1.- LUCES FIJAS

Según puede verse en la figura 2-2 las luces marcadas con
LF se hallan repartidas por el tablero proporcionando la luz
general al juego.

#### 2.2.2.- LUCES CONTROLADAS

Refiriendonos a la figura 2-2 podemos observar los puntos
marcados con LC0O hasta LC45. Estos puntos son las luces
controladas separadamente por el juego. La descripción de sus
funciones es la que a continuación se expone:

CODIGO | NOMBRE DESCRIPCION
010 LVE Veleta: 10.000 puntos
01 LP7 Pasillo 7: Enciende Bumpers
02 LP8 Pasillo 8: Enciende Bumpers
03 LPB5 Picabolas: 100,000 puntos
o4 LPBY Picabolas: 300.000 puntos
05 LPB3 Picabolas: Bola Extra
06 LPB2 Picabolas: 5.000 puntos
07 LPB1 Picabolas: 50.000 puntos
10 LD1 Diana 1: 100.000 puntos
11 LD2 Diana 2: 300.000 puntos
12 LB11 Bumper 1: 10.010 puntos
13 L»B21 Bumper 2: 10.010 puntos
14 LB12 Especial en Combinación Bancada 1,2,5
15 LB22 Especial en Combinación Bancada 3,4,6
16 LP92 Pasillo 9: Bonos
17 LP91 Pasillo 9: 300,000 puntos
20 LE1 Estrella 1: Apaga Bumpers
21 LP2 Pasillo 2: 100.000 puntos
22 LP1 Pasillo 1: Especial
23 LDB Doble Bonos
21) LTB Triple Bonos
25 LP6 Pasillo 6: Bola Extra
26 LP5 Pasillo 5: 100.000 puntos
27 LE2 Estrella 2: Suma Bonos
30 LBO1 Bono 1
31 LBO2 Bono 2
32 1,B03 Bono 3
33 LBO4 Bono 4
311 LBO5 Bono 5

<!-- PDF page 20 -->

CODIGO | NOMBRE DESCRIPCION
35 LBO6 Bono 6
36 LBO7 Bono 7
37 LBO8 Bono 8
yO LBO1O Bono 10
41 LBO9 Bono 9
119 1.DY Diana Y: 300,000 puntos
143 LD5 Diana 5: 100.000 puntos
4 LST Start
45 LBOx100000 | Bonos x 100.000
MATRIZ DE LUCES
RET7 RET6 RETS5S RETA RET3 RET2 RET1 RETO
SCANO LPB1 LPB2 LPB3 LPB4 LPB5 LP8 LP7 LVE
SCANI LP91 1P92 LB22 LB12 LB21 LB11 LD2 LD1
SCAN2 LE2 LPS LP6 LTB LDB LP1 LP2 LE1
SCAN3 LBO8 LB07 LBO6 LBO5 LBO4 LBO3 LBO2 LBO1
SCAN4 VACIO VACIO A q ee (2) ná MS 0

<!-- PDF page 21 -->

*(Página en blanco.)*

<!-- PDF page 22 -->

*Figura: figura 2-3 BOBINAS — no transcrita, ver PDF página 22.*

<!-- PDF page 23 -->

DESCRIPCION DE BOBINAS

Según apreciamos en la figura 2-3, el aparato dispone de 10
bobinas (en los flippers hay doble bobinado lo que supone un
total de 12) en el tablero de juego.

Cada una de ellas efectúa una función que a continuación se

detalla:

BOBINA FUNCION
01 Bobina de Flipper izquierdo fuerza
02 Bobina de Flipper izquierdo mantenimiento
03 Bobina de Flipper derecho fuerza
04 Bobina de Flipper derecho mantenimiento
05 Bobina Bancada de 4
06 Bobina Bumper 2
07 Bobina Bumper 1
08 Bobina Bancada de 1 izquierda
09 Bobina Bancada de 1 derecha
10 Bobina de Taca
11 Bobina Salida de Bolas
12 Bobina Picabolas

<!-- PDF page 24 -->

### 3.1.- EVENTOS

#### 3.1.1.- BOLAS

## SECCION 3

DESCRIPCION DEL JUEGO

EXTRA

#### 3.1.2.- ESPECIALES

En el Pasillo 1 y por combinación de Dianas.

También

se dan especiales por puntuación (ver apartado
superar el Record del Día (ver apartados 4.2.3 y

### 3.2.- ACTUACIONES DE LOS CONTACTOS

#### 3.2.1.- PASILLOS

PASILLOS Con luz Sin luz
Pasil!lol Especial 300,000 puntos
Pasillo2 100.000 puntos 5,000 puntos
Pasillo3 5.000 puntos y avance de bonos
Pasillo4 5.000 puntos y avance de bonos
Pasillo5 100.000 puntos 5.000 puntos
Pasillo6 Bola Extra 300.000 puntos
Pasillo7 Da 5.000 puntos
Enciende Bumpers, Estrellas y LP7
Si LP7 y LP8 encendidas, enciende LP92, LD2 y LD4
Pasillo8 Da 5.000 puntos
Enciende Bumpers, Estrellas y LP8
Si LP7 y LP8 encendidas, enciende LP92, LD2 y LD!

Pasillo9 Sin luz: 50.000 puntos

Con LP9 1: 300.000 puntos

Con LP9_2: 50.000 puntos y 2 avance de bonos
Estrellal Da 5.000 puntos

Apaga Bumpers,LP7,LP8,LD2,LD4
Estrella2 Da 5.000 puntos

Apaga Bumpers,LP7,LP8,LD2,LDY

<!-- PDF page 25 -->

#### 3.2.2.- BANCADAS

BANCADAS
Bancada 1 Da 10.000 puntos y enciende LP2 (100.000 puntos)
Bancada 2 Da 10.000 puntos y enciende LD5 (100.000 puntos)
Bancada 3 Da 10.000 puntos y enciende LP5 (100.000 puntos)
Bancada Y | Da 10.000 puntos y enciende LD1 (100.000 puntos)
Bancada 5 |Da 10.000 puntos
Bancada 6 | Da 10.000 puntos
Combinaciones de Dianas de bancadas:

COMBINACIONES DE DIANAS DE BANCADAS

Enciende LVE (300.000 puntos)

Bancadas 1,2,5

Sin LBU1:;
Si esta encendida Bonosx100.000 la
apaga y enciende LDB (Doble Bonos)
Enciende LP91 (300.000 puntos)

Con LBU1:
Da especial.

Bancadas 3,4,6

Sin LBU2:
Si esta encendida Bonosx100.000 la
apaga y enciende LDB (Doble Bonos)
Enciende LP91 (300.000 puntos)

Con LBU2:
Da especial.

Bancadas 1,2,3,4,5 Si esta encendida LDB (Doble Bonos), la apaga y
enciende LTB (Triple Bonos)
Bancadas 1,2.3.4.5.6 | Enciende LBU1 (Especial) y LBU2 (Especial)

#### 3.2.3.- DIANAS

DÍANAS | CON LUZ SIN LUZ

Dianal | 50.000 puntos 5.000 puntos

Diana2 | Avance de bonos Avance de bonos
300.000 puntos 50,000 puntos

Diana3 50.000 puntos

Dianall | Avance de bonos Avance de bonos
300,000 puntos 50,000 puntos

Diana5 | 100.000 puntos 5.000 puntos

Dianab 10.000 puntos

Diana7 10,000 puntos

<!-- PDF page 26 -->

#### 3.2.4.- BANDAS

BANDAS

Superiores | Dan 5.010 puntos

Inferiores | Dan 1.010 puntos

#### 3.2.5.- BUMPERS

BUMPERS

CON LUZ -

SIN LUZ

Bumperl

10.010 puntos

1.010 puntos

Bumper2

10.010 puntos

1.010 puntos

#### 3.2.6.- PICABOLAS

Da avance [te Bonos.

Dependien

en la luz que se pare da:

LUCES PICABOLAS

Da 50.000 puntos

Da 5.000 puntos

Enciende LP6 de Bola Extra

Da 300,000 puntos

Da 100.000 puntos

#### 3.2.7.- VELETA

CON LUZ

SIN LUZ

Veleta

10.000 puntos

1.000 puntos

#### 3.2.8.- FALTA

El aparato dispone de un péndulo de Falta para evitar que
el jugador zarandee o levante la máquina para obligar a la bola

a pasar por un lugar que le conviene.

Fi] número de veces permitido hacer falta al jugador es

programable (ver apartado 4.2.5).

AL cumplirse este número de veces, se apagan las luces del

tablero de juego y la bola no puntúa.

Una vez que ha llegado a la salida, se pasa a la siguiente
bola (si la hubiera), perdiéndose la puntuación de Bonos obtenida
y las posibles Bolas Extras que se hubieran conseguido en esa

bola.

<!-- PDF page 27 -->

### 3.3.- PUNTUACIONES
La puntuación del jugador pasados los 9.999.999 de puntos
parpadea.

### 3.4.- LOTERIA

Una vez terminada la partida, aparece la pantalla de

Lotería.
Si el número que sale en ésta coincide con dos ultimas

cifras de los jugadores se da Partida por lotería.
Esto ocurre aproximadamente en un 20% de las partidas.

<!-- PDF page 28 -->

## SECCION 4
VALORES PROGRAMABLES
### 4.1.- SIGNIFICADO DE LOS MICROSWITCHES
Los microswitches situados en la placa CPU 8 BITS son los

que srleccionan los valores programables de la maquina. El
significado de dichos microswitches es el siguiente:

MICROSWITCHES | SIGNIFICADO

1-2 Monedero

3 Bolas por partida

Y Partida por Record del Día

5-6 Puntuaciones para partida por puntos
7 Falta

8 Temporizacion luces del picabolas

### 4.2.- PROGRAMACIÓN

#### 4.2.1.- MONEDERO

Los Microswitches 1 y 2 sirven para programar cuántos
créditos dan las diferentes monedas.

MONEDERO
MICROSWITCHES CREDITOS
M1=0N  M2=0N 1 DE 50$=1 CRED 1 DE 100$=2 CRED | 1 DE 200$=4 CRED
M1=0FF M2=0N 1 DE 505$=1 CRED 1 DE 100$=3 CRED | 1 DE 200$=6 CRED
M1=0N  M2=0FF | 2 DE 50$=1 CRED 1 DE 100$=1 CRED | 1 DE 200$=2 CRED
M1=0FF M2=0FF | 2 DE 50$=1 CRED 1 DE 100$=1 CRED | 1 DE 200$=3 CRED

#### 4.2.2.- BOLAS POR PARTIDA

El Miícroswitch 3 sirve para programar cuántas bolas se van
a jugar por partida.

BOLAS POR PARTIDA
MICROSWITCHES BOLAS
M3=0N Tres Bolas
M3=0FEF Cinco Bolas

<!-- PDF page 29 -->

#### 4.2.3.- PARTIDAS POR RECORD DEL DÍA

El Microswitch 4 sirve para programar cuántas partidas se
van a dar por Record.

#### 4.2.4.- PARTIDAS

Los Microswitches del
a partir de los cuales se

PARTIDAS POR RECORD DEL DÍA

MICROSWITCHES PARTIDAS
M4=0ON Una Partida
MY=0FF Tres partidas

partida por puntos.

#### 4.2.5.- FALTAS

PARTIDAS
MICROSWITCHES | 1% PARTIDA | 2% PARTIDA

5 y 6 sirven para programar los puntos
dará la primera partida y la segunda

El Microswitch 7 sirve para programar el número de faltas

permitidas,

antes de dar falta.

FALTAS
MICROSWITCHES FALTAS
M7=0N Una Falta
M7=0FF Dos Faltas

<!-- PDF page 30 -->

#### 4.2.6.- TEMPORIZACION DEL PICABOLAS

El Microswitch 8 sirve para programar la velocidad de cambio
de las luces asociadas al picabolas, que seleccionan el premio
obtenido en éste.

TEMPORIZACION PICABOLAS
MICROSWITCHES TEMPORIZADOR
M8=0N Rápido
M8=0FF : Lento

<!-- PDF page 31 -->

## SECCION 5
AJUSTES Y TEST
### 5.1.- ENTRADA EN AJUSTES Y TEST
Para entrar en ajustes y test basta con pulsar el botón de
TEST situado dentro de la máquina en la Caja de Red. Se entra en
el primer Test, que es el Test de Contactos.

### 5.2.- TEST DE CONTACTOS

Nos permite verificar 'el correcto funcionamiento de los
contactos del tpblero y de la máquina. Se muestra en pantalla:

TEST 1  cont=

Según vamos actuando sobre los contactos, éstos van
apareciendo con el código referido en el apartado 2.1.1.
Para salir del test de contactos basta con pulsar el botón

de TEST.

### 5.3.- TEST DE LUCES

Al elegirla nos aparece en pantalla:

| TEST 2 LAMP=00

Cada vez que se pulse el flipper derecho se encenderá la luz
siguiente y cuando se pulse el flipper izquierdo se encenderá la
luz anterior, apareciendo su número en pantalla. Los códigos de
las luces son los descritos en el apartado 2.2.2.

Al pulsar Test se va al test siguiente.

### 5.4.- TEST DE BOBINAS

Al entrar en esta opción aparece en la pantalla:

TEST 3 Slnd=00

Cada vez que se pulse el flipper derecho se activará la
bobinas siguiente y aparece su número en pantalla. Los códigos
de las bobinas son los descritos en el apartado 2.3.1.

Se puede pasar al Test siguiente en cualquier momento de
Test, apretando el pulsador de TEST.

<!-- PDF page 32 -->

pone al
en este

cambian

EST DE CONTADORES

entrar en esta opción aparece en la pantalla:

RECORD 5000000
C-ELECT 00000018

primer valor es el valor actual del Record del Día. Se

valor mínimo cambiando el Microswitch 1 cuando se está

Test. El valor mínimo es 5.000.000.

segundo valor son los créditos actuales. Se pone a cero
do el Microswitch 2 cuando se está en este Test.

tercer valor es el contador electrónico de monedas que

se incrementa con cada 508 que se meten en la maquina. Se pone

a cero
Microsw
maquina

cambiando el Microswitch 3 cuando se está en este Test.
maquina resetea todos los valores cambiando el
itch 4 cuando se está en este test. Al hacer esto la
se reinicializa y sale de Test.
puede salir de Test, apretando el pulsador de TEST.

<!-- PDF page 33 -->

*(Página en blanco.)*

<!-- PDF page 34 -->

*Figura: figura 6-1 28 — no transcrita, ver PDF página 34.*

<!-- PDF page 35 -->

### 6.1.- RELACION DE PARTES

NUM | CONCEPTO CLAVE
1 | Cabeza [Pinball serigrafiada DONA ELVIRA 2 029-008A
2 | Rejilla aireación 150x150 003-265
3 | Escuadra cierre puerta luces 001-0854
4 | Escuadra refuerzo giro cabeza 003-3442
5|C.P.U. Sonido General 011-065A
6 | Placa Alimentacion Sonido 011-067A
7 | Placa drivers DONA ELVIRA 2 011-027B
8 |C.P.U. 8 bits 011-030B
10 | Fuente Alimentación 10 A. FAL10A
11 | Tornillo DIN 931 M10x100 931-10X100
12 | Tabla bombillas 011-511
13 | Soporte Placa Display DONA ELVIRA 2 029-031
14 | Bombilla inyectable 6.3V 150mA 013-016
15 | Chapa sujeción luna frontal 025-105
16 | Portalámparas Inyectable T10 060037
17 | Portafusible y Fusible 6x32 PF2320
18 | Cierre puerta luces 001-085
19 | Metacrilato serigraf. frontal DONA ELVIRA 2 029-010
20 | Perfil U-52 mm. 018-061
21 | Rejilla altavoz 4" 001-043
22 | Altavoz RT.141M SQUAWKER, 4P 35W 034-012
22b | Altavoz T.30F16G TWEETER, 8W 025-064
23 | Puerta Display Serigrafiada DONA ELVIRA 2 295-010
23b | Cerradura Serie 100-010
2 | Placa completa Display DONA ELVIRA 2 011-0644
25 | Metacrilato Serigrafiado puerta display 029-012
26 | Bisagra puerta luces 025-102
28 | Mueble Pinball Serigrafiado DONA ELVIRA 2 029-0094
29 | Tablero de juego completo DONA ELVIRA 2 029-015
30 | Chapa Fondo Tablero 027-034
31 | Cierre de acero pintado 01-2305
32 | Escuadra enganche de fijación 003-368
34 | Escuadra giro tablero derecha-izquierda 003-246
36 | Escuadra giro cabeza izquierda 000-001
37 | Escuadra giro cabeza derecha 000-001B
HOA | Escuadra giro tablero derecha 003-377
HOB | Escuadra giro tablero izquierda 003-376
41 | Cable de Red 010-010

<!-- PDF page 36 -->

NUM | CONCEPTO CLAVE
42 | "U" trasera mueble 001-038
43 | Banda lateral de 1140 mm. izq. 003-258A

113A | Banda lateral de 1140 mm. dcha. 003-258
44 | Guía cristal 1100 mm, 018-017
145 | Compás [sujeción tablero 003-381
16 | "U" sujeción compás 003-382
17 | Base de cierre completa 041-631
48 | Guía tope pulsador 001-039
19 | Cuerpo guía pulsador flipper 018-019
50 | Grupo contacto flipper 051-103
51 | Pulsador de Flipper rojo tras. 018-020
52 | Pulsador redondo med. empotrado RM-E 068-423
53 | Tirador con guías largo 041-112
54 | Altavoz 8" 30W WOOFER 8AG/1N
55 | Rejilla altavoz 200x200 001-046
56 | Placa Relés DONA ELVIRA 2 030-001
57 | Transformador Pinball DONA ELVIRA 2 029-013
58 | Conjunto puentes de diodos 021-1624
59 | Unidad de Falta 298-004
60 | Caja Red portafusible y pulsadores 069-305
61 | Interruptor bipolar rabillo corto 013-462
62 | Chapa perforada 50x50 12 mm. 003-349

ú 63 | Chapa sujeción patas 001-033

mn 04 | Tornillo sujeción patas 933 M10x70 933-10X70
65 | Pata de mueble negra 026-032
66 | Conjunto Taca 041-601
67 | Fusible 6x32 4A 35-UA
68 | Fusible 6x32 8A 35-8A
69 | Fusible 6x32 8A 35-84
70 | Fusible 6x32 104 35-104
73 | Conjunto placas portadocumentos 110-081
74 | Luna Templalux 5 mm.  1098x538 010-061
75 | Puerta "Williams" una entrada 068-403
76 | Monedero electrónico AZKOYEN N-50
717 | Cajón de monedas 025-032
78 | Escuadra fijación cajón monedas 003-821

<!-- PDF page 37 -->

*(Página en blanco.)*

<!-- PDF page 38 -->

*Figura: figura 6-2 página 32 — no transcrita, ver PDF página 38.*

<!-- PDF page 39 -->

#### 6.2.1.- RELACION DE PARTES

NUM | CONCEPTO CLAVE
CONJUNTO BUMPER 058-503
1 | Chapita de fleje de 0,5 mm. 001-511
2 | Tope de métrica 5 001-644
4 | Arandela de bumper 001-888
5|U de bumper 001-889
6 | Chasis de bumper 001-890
7 [Muelle recuperador cono 017-079
8 | Muglle accionador contacto 017-080
9 | Maríguito de 5 mm, 018-276
10 | Tubo bobina de 43,5 018-277
11 | Cabeza bumper blanca 018-3644
12 | Tapa bumper blanca 018-382A
13 | Balancin de bumper 018-387
14 | Cono de bumper alto 018-390
15 | Accionador contacto bumper largo 018-391
16 | Base de bumper alta 018-392
17 | Arandelas de latón 023-025
18 | Bobina blanca 050-205
19 | Grupo contacto bumper 051-733
20 | Arandela din 6798 M-4 6798-4
21 | Arandela din 6799 M-8 6799-8
22 | Arandela din 125 M-4 125-4
23 | Tuerca din 985 M-5 985-5
24 | Lámpara tubular 6.3V 250 mm A GE44
25 | Hilo de cobre 0,50 mm. rojo HO5ORO

<!-- PDF page 40 -->

*Figura: figura 6-3 CONJUNTO FLIPPER — no transcrita, ver PDF página 40.*

<!-- PDF page 41 -->

#### 6.3.1.- RELACION DE PARTES

NUM | CONCEPTO CLAVE
GRUPO BOBINA FLIPPER IZQUIERDA 056-509
GRUPO BOBINA FLIPPER DERECHA 056-510
1 | Escuadra fijación bobina 001-806
2 | Núcleo de 78 con alojamiento 001-811
3 | Chasis de flipper izquierdo 003-810
U | Chasis de flipper derecho 003-813
5 | Goma negra de flipper 015-046
6 | Muelle grupo flipper 017-070
7 | Arandela latón con cuello 025-107
8 | Tubo bobina de 43,5 018-277
9 | Disco biela flipper 018-334
10 | Casquillo autofijación de 6 mm. 018-335
11 | Cojinete de flipper 018-338
12 | Cabeza flipper blanca 018-339
13 | Arandelas de latón 023-005
14 | Biela de flipper izquierdo 056-106
15 | Biela de flipper derecho 056-108
16 | Biela flipper esp. con eje largo 056-206
17 | Tope M-5 001-644
18 | Pasador din 1481 3x6 1481-3x6
19 | Arandela din 6798 M-4 6798-14
20 | Tornillo din 7981 3,9 x 16 7981-7x5/8
21 | Prisionero din 914 5x8 914-5x8
22 | Tornillo din 985 M-4x8 985-4x8
23 | Tuerca din 985 M-5 985-5
24 | Bobina Flipper negra B55-750
25 | Escuádra Tope completa 025-147

<!-- PDF page 42 -->

*Figura: figura 6-4 CONJUNTO TACA — no transcrita, ver PDF página 42.*

<!-- PDF page 43 -->

#### 6.4.1.- RELACION DE PARTES

NUM | CONCEPTO CLAVE
TACA 041-601
1 | Bastidor del taca 001-064
2 | Escuadra sujeción bobina taca 001-065
3 | Goma cónica de tope 015-009
4 | Tubo bobina de 75 018-046
5 | Núcleo de 53 hueco con punta 041-110
6 | Bobina blanca 050-205
7 | Arandela DIN 125 M-4 125-4
8 | Arandela DIN 6798 M-4 6798-4
9 | Tornillo' DIN 933 M-4x8 933-4x8

<!-- PDF page 44 -->

*Figura: figura 6-5 página 38 — no transcrita, ver PDF página 44.*

<!-- PDF page 45 -->

*(Página gráfica sin texto transcribible — ver PDF página 45.)*

<!-- PDF page 46 -->

*(Página gráfica sin texto transcribible — ver PDF página 46.)*

<!-- PDF page 47 -->

#### 6.6.1.- RELACIÓN DE PARTES

NUM | CONCEPTO CLAVE
CONJUNTO SALIDA DE BOLAS "Se suministra completo" | 255000
3 | Carril salida de bolas 01-2344
8 | Bobina blanca 050-205
18 | Tornillo DIN 7985 M-2x10 7985-2x10
19 | Chapa accesorio micro 025-061
20 | Alambre micro salida de bolas 025-026
21 | Minirruptor 1WD5 83170
22 | Diodo 1N4001 1N4001
23 | Escuadra alambre pasillo 001-309

<!-- PDF page 48 -->

*(Página gráfica sin texto transcribible — ver PDF página 48.)*

<!-- PDF page 49 -->

figura 6-7 BANCADA DE DIANAS

#### 6.7.1.- RELACION DE PARTES

NUM | CONCEPTO CLAVE
(1) BANCADA DIANAS 5 ELEMENTOS "Se suministra completo" 074-3184
18 | Grupo contacto € al descender diana 051-718
28 | Tornillo DIN 933 M-3x20 933-3x20
(2) BANCADA DIANA 1 ELEMENTO "Se suministra completo" 029-022

<!-- PDF page 50 -->

*Figura: figura 6-8A UNIDAD DE FALTA — no transcrita, ver PDF página 50.*

<!-- PDF page 51 -->

figura 6-8B GATE TRAMPILLA

#### 6.8.1.- RELACION DE PARTES

NUM | CONCEPTO CLAVE
UNIDAD DE FALTA 298-004
1 | Escuadra de Péndulo 001-112
2 | Varilla de Péndulo 001-113
3 | Escuadra de masa de péndulo 001-017
4 | Péndulo 010-013
5 | Tornillo DIN 933 M-4x8 933-4X8
GATE TRAMPILLA DE 185 mm. 029-021
(Se suministra completo)

<!-- PDF page 52 -->

*Figura: figura 6-9 TIRADOR CON GUIAS LARGO — no transcrita, ver PDF página 52.*

<!-- PDF page 53 -->

#### 6.9.1.- RELACION DE PARTES

NUM | CONCEPTO CLAVE
TIRADOR CON GUIAS LARGO 044-112
1 | Arandela del tirador 001-057
2 | Chapa sujeción tirador 001-059
3 | Goma punta tirador 015-004
4 | Muelle tope tirador 017-001
5 | Muelie recuperador tirador 017-003
6 | Cojinete tirador 018-026
7 | Eje con empuñadura 041-108
8 | Escudo con guías 041-113
9 |lÁrandela DIN 6799 M-9 6799-9
10 | lArandela DIN 6798 M-3 6798-5
11 | Tuerca DIN 934 M-5 934-5

<!-- PDF page 54 -->

*Figura: figura 6-10 TABLERO DE JUEGO — no transcrita, ver PDF página 54.*

<!-- PDF page 55 -->

#### 6.10.1.- RELACION DE PARTES

NUM CONCEPTO CLAVE
1 | Chapa mecanizada Fondo Tablero 027-034
la | Adhesivo fondo tablero DONA ELVIRA 2 029-029
2 | Escuadra giro tablero izquierda 003-376
> 3 | Escuadra giro tablero derecha 003-377
y | uy" Sujeción compás 003-382
5 | Compás sujeción tablero ' 003-381
6 | Escuadra giro compás 003-380
7 | Autoblocante M-5 958-5
8 | Tornillo DIN 84 M-5x25 84-5x25
9 | Tuerca ciega M-4 1587-4
10 | Puente alambre tarjetero 025-022
11 | Tarjetero serigrafiado DONA ELVIRA 2 029-018
12 | Metacrilato serigraf. S. Bolas inc. Juego Siluetas 029-016
13 | Separador SR56-4UN
14 | Complemento salida de bolas 01-2298
16 | Tornillo DIN 933M-4x6 933-4x6
16 | Arandela DIN 6798 m-4 6798-4
17 | Escuadra sujeción embellecedor 001-296
18 | Espárrago M-4x80 025-029
19 | Tuerca DIN 934M-4 934-4
20 | Escuadra enganche fijación 003-368
21 | Lateral derecho salida bolas 001-301
22 | Tablero de juego mecanizado DONA ELVIRA 2 050-0014
22a | Metacrilato Serigrafiado y Mecanizado DONA ELVIRA 2 [025-011

<!-- PDF page 56 -->

*Figura: figura 6-11 SILUETAS DEL TABLERO — no transcrita, ver PDF página 56.*

<!-- PDF page 57 -->

*(Página gráfica sin texto transcribible — ver PDF página 57.)*

<!-- PDF page 58 -->

*Figura: figura 6-12 SUBCONJUNTOS DEL TABLERO (1) — no transcrita, ver PDF página 58.*

<!-- PDF page 59 -->

#### 6.12.1.- RELACIÓN DE PARTES

NUM | CONCEPTO CLAVE
(1) CONTACTO DE PASILLO COMPLETO 017-026
1 | Escuadra alambre pasillo 001-309
2 | Alambre pasillo metal para soldar 017-016
MM | Diodo 1N4001 INHOO1
5 | Tornillo DIN 7985 M-2x10 7985-2x10
6 | Minirruptor IWDS * 83170
1 | Pirulo Rojo Traslucido 018-066
2 | Pirulo nylon rojo 018-202
3 | Soporte barra nylon rojo 108-106
(3) MICRO VELETA COMPLETO
1 Tornillo DIN 7985 M-2x10 7985-2x10
2 | Chapa accesorio micro 025-061
3 | Accesorio 170-A 41 mm. 170-A1
4 | Minirruptor IWD5 83170
Ú 5 | Diodo 1N4001 INYOO1
Ñ 6 | Escuadra suj. Micro Veleta/Rampa 025-021
(4) CONTACTO DIANA INDIVIDUAL 051-781
Opción a | Circuito diana redonda roja 051-781
Opción b | Circuito diana redonda amarilla 051-782
Opción c | Circuito diana redonda verde 051-783
(5) GRUPO CONTACTO DE FLIPPER 051-103
Grupo Contacto banda 051-726
Grupo Contacto banda escuadra invertida 051-726A
(7) TIRAFONDO DE PIRULO DE 46 021-203
1] Tuerca ciega M-4 1587-4
2 | Tirafondo de pirulo c/ esp. 46 021-205

<!-- PDF page 60 -->

*Figura: figura 6-13 SUBCONJUNTOS DEL TABLERO (2) — no transcrita, ver PDF página 60.*

<!-- PDF page 61 -->

#### 6.13.1.- RELACION DE PARTES

NUM | CONCEPTO CLAVE
(1) PUENTES
1 | Puente nylon de 38 rojo 018-179
2 | Puente nylon ESTR rojo 54 018-182
(2) TRAMPILLAS S/BOLAS
Trampilla salida de bolas derecha 029-023
2 | Trampilla salida de bolas izquierda 029-024
(3) ANILLOS GOMA
ANILLOS GOMA BLANCA
ANILLOS GOMA NEGRA

<!-- PDF page 62 -->

*Figura: figura 6-14 SUBCONJUNTOS DEL TABLERO (3) — no transcrita, ver PDF página 62.*

<!-- PDF page 63 -->

#### 6.14.1.- RELACION DE PARTES

NUM | CONCEPTO CLAVE
1) Puente alambre 99 mm 029-002
(2) Puente almabre 100 mm 029-003

(3) Banda lateral 029-005

UN Banda lateral 029-006

(5) Banda lateral 029-007

(6) Puente acero inoxidable veleta 029-004

(7) Alambre veleta 029-001

Goma cónica negra 029-025
Pirulo metálico rebote bola 029-030

(9) Bola acero rodamiento 26,98 mm BOL2698

(10) Plástico varilla PVC 6mm PO299

Base estrella roja 029-026
Estrella blanca 029-027

<!-- PDF page 64 -->

*Figura: figura 6-15 LAMPARAS Y PORTALAMPARAS — no transcrita, ver PDF página 64.*

<!-- PDF page 65 -->

#### 6.15.1.- RELACION DE PARTES

NUM | CONCEPTO CLAVE
(2) |Portalamparas Plano 070-001
(1)A | Portalamparas L 070-003
(1)B | Portalamparas Z de 14Ymm 070-006
(1)C | Portalamparas Z de 30mm 070-005
(3) | Lampara tubular 6,3V 250 mA GE44
(4) Lampara inyectable 12V 0,25A 013-014
(4) | Lampara inyectable 6,3V 1,5W 013-015
(5) Conjunto Flash
1 | Píloto rojo traslúcido 025-006
1 | Piloto verde traslúcido 025-006
1 | Piloto blanco traslúcido 025-006
ll | Lámpara inyectable 13V/8.97W 025-001
5 | Soporte portalámparas coin 025-002
6 | Escuadra coin 26 mm. 025-005
7 | Tornillo DIN 84 M-3x10 84-3x10
8 | Tuerca DIN 84 M-3x10 934-3

<!-- PDF page 66 -->

## SECCION 7

DESCRIPCION ELECTRONICA

### 7.1.- RELACION DE ELEMENTOS

La electrónica de DONA ELVIRA 2 está compuesta de varias
placas y elementos electrónicos con funciones especificas que a
continuación se detallan:

ELEMENTO FUNCION CLAVE SITUACION
C.P.U. 8 BITS Control, Audio, Video 011-030 Cabeza
C.P.U. SONIDO GENERAL | Control de Sonido 011-065 Cabeza
DRIVERS Ataque Luces y Bobinas 011-027 Cabeza
FUENTE ALIM, +5/+12 Aliment. de Lógica FALIOA Cabeza
PLACA DISPLAY Y LEDS Pantalla 011-064 Cabeza
ALIMENTACION SONIDO Alimentación Sonido 011-067 Cabeza
ALTMENTACION BOBINAS Alimentación Bobinas 011-028 Mueble
MONEDERO ELECTRON. Entrada de monedas N-50 Puerta
CAJA DE RED Contador,Fus. Test 069-305 Mueble
CONJUNTO PUENTES Rectificación 44V;18V 021-162 Mueble
ALTAVOZ 3"  5Ww Audio tonos Agudos 025-064 Cabeza
ALTAVOZ 4" 35w Audio tonos Medios 034-012 Cabeza
ALTAVOZ 8" 30W Audio tonos Graves 8AG/1N Mueble
FUSIBLES GENERALES Protección General Varios Mueble
FUSIBLES DEDICADOS Protección Bob.luz,etc. Varios Cabeza
TRANSFORMADOR | Suministro tensiones 029-013 Mueble

### 7.2.- DESCRIPCIÓN DE ELEMENTOS

A continuación se dispone de una descripción detallada de
los elementos relacionados en el apartado 7.1 que su importancia
merece, destacando sus características principales y los puntos
de atención para el correcto mantenimiento y servicio de la
máquina.

#### 7.2.1.- PLACA CPU 8 BITS

Se encarga de todas las funciones de juego,controla los
contactos del tablero y mueble, las luces fijas y controladas y
la activación de las bobinas.

Puede verse en la figura 7-1.

<!-- PDF page 67 -->

SYNIEOE sanaT
AWIASIO YNTE SULATSO WINIE SUMAIEO VINTIE
ROTICIIMAMOS ROIIOIRNROS ROTILOTHAROO
| 1173] Goaccssson) E(fovosocoo) COEDOCDERS EOI SSO)
¡ eno ardor cV.sas AMES sooS DO0TS0Sos DODOCOLIte “ Soon os.
o| jo ooooc09000€. Yovoconooco 0900600000 Yogoroconoro oso00nooo |
pan |
1] o o ae sz; o00coo0o.o.o 000600600000 “p¿eocrococaco co059006000000 :
d) o o Losoonocooo NATI e vco9on0200. esoococona os cos. noc. |
Led. £s A AS Emo a) JOTo cuz anos
ze o ¿Zoow0o000. an 92o0o0o0o0o0coVoocoovoa. oc0900000000 SE BER Elo j=to, L pe
y oa 2 8 _____]3 553 it ds 1555 mala
o. . : 8 Sl d3 538 eyóc8 58 loli zage an-1e
] o o oooozo0os OMS ovo0ooDo 1
o o vcocorsconanoos | yISY 1A-18
ojo o AobovcoVr..o voccoococono so. o 91H IA-OY
o o OTTO cOD ooo
o e
Elo o oboVocoo.. ¿SEL OY
ES GOTO
e 1012 1c13 CIO) vPocsoococo 130 TA
E cvooovos g0000000 aJD YW
5 Elo EN OVILLO 900000 coco Ga YN
= c00006000 90000000 2 trol TUYIS En
1 gococos «Beosonos Aococronnsa oo0coo0V0VL..o. ovuococoos,
pDod2oocococo 2 00LGPOSUES ¡DA— |ZNYOS YO
E sc%0
y [Sp2 E-8 h o000000000 Z GEORGIA
OEA” Lé - EORERCCCCO CITI 3

VI GND

TVEENTO OOINOS MED

NOIIMDINOROO

PLACA C.P.U 8 BITS

figura 7-1

página

<!-- PDF page 68 -->

#### 7.2.1.1.- COMPONENTES PRINCIPALES
IC1 | Microprocesador Z80A-6 | Zilog/SGS
IC5 Memoria EPROM 270256 | Texas/SGS DONA ELVIRA 2V1.1

swi0 | Regleta Microswitches. Ver Apartado 7.2.1.3

#### 7.2.1.2.- CONECTORES
J1 | Alimentación +5V/Masa/+12V Molex 6 vias
T2 Comunicación Drivers Matriz de Luces. Cinta Plana 20 vias
233 | Comunicación C.P.U Sonido General Cinta Plana 20 vias
J4 | Comunicación Drivers Bobinas Cinta Plana 20 vias
J5 | Comunicación Plata Display Cinta Plana 10 vias
J6 | Salida Comunes Matriz de Contactos (Scan) Molex 8 vias
J7 | Entrada Contactos Directos Molex 8 vias
38 LEntrada Retornos de Matriz de Contactos (Ret) | Molex 8 vias

#### 7.2.1.3.- MICROSWITCHES DE CPU 8

función

La regleta de microswitches de la placa de 8 bits tiene la

máquina. A saber:

MICROSWITCHES | SIGNIFICADO
1 Monedero
2 Monedero
3 Bolas por partida
Y Partidas por Record del Dia
5 Puntuáaciohes para partida por puntos
6 | Puntuaciones para partida por puntos
Ñ Falta
8 | Temporizacion luces del picabolas

En el aportado 4.1 se explica es significado
diferentes combinaciones de Microswitches.

de poner varias condiciones en el funcionamiento de la

las

<!-- PDF page 69 -->

#### 7.2.1.4.- MATRIZ DE CONTACTOS

La matriz de contactos tiene la topología que aparece en la
figura 7-2. Las líneas comunes (0-7) lanzan sucesivamente pulsos
en alta por medio del circuito de la figura 7-3. Estos pulsos son
recogidos por las líneas de retorno (0-3) mediante el circuito
de la figura 7-4.

RO-NE VI-AM BL-NE BL-RO BL-VE BL-AM  RO-VI AM-VE

A7 RETO RET1  RET2 RET 3  RET4 RET5 RET6 RET7

GR i
START  FD CFD CFI FI FALTA TEST MON

figura 7-2 MATRIZ DE CONTACTOS

<!-- PDF page 70 -->

*Figura: figura 7-3 LINEA DE COMUN (SCAN) — no transcrita, ver PDF página 70.*

<!-- PDF page 71 -->

DRIVERS

La placa de Drivers se encarga de dar el ataque de potencia
a parte de las bobinas y a las luces de la matriz. Dispone además
de los fusibles de protección dedicada.

#### 7.2.2.1.- COMPARE NTES PRINCIPALES

a) DRIVERS DE POTENCIA BOBINAS
119 | Transistor PNP TIP36C | Flipper Izquierdo Fuerza
T22 Transistor PNP TIP36C Flipper Derecho Fuerza
T25 | Transistor PNP TIP36C | Bancada de 4
THL— | Transistor PNP TIP36C | Bumper 1
UN | Transistor PNP TIP36C | Bumper 2
“146 | Transistor PNP TIP36C | Bancada de 1 izquierda
T5O | Transistor PNP TIP36C | Bancada de 1 derecha

b) DRIVERS INTERMEDIOS Y DE MEDIANA POTENCIA BOBINAS
T18 | Transistor NPN BDX53C | Flipper Izquierdo Fuerza
T21 Transistor NPN BDX53C | Flipper Derecho Fuerza
T24-— | Transistor NPN BDX53C | Bancada de l
T30 Transistor NPN BDX53C | Flipper Izquierdo Mantenimiento
T32 Transistor NPN BDX53C | Flipper Derecho Mantenimiento
T34 | Transistor NPN BDX53C | Flash 1 (izquierda)
136 | Transistor NPN BDX53C | Flash 2 (derecha)
0 Transistor NPN BDX53C | Bumper 1
3 | Transistor NPN BDX53C | Bumper 2
147 Transistor NPN BDX53C Bancada de 1 izquierda
TH9 | Transistor NPN BDX53C | Bancada de 1 derecha
T52 Transistor NPN BDX53C | Bobina de Taca
T54 | Transistor NPN BDX53C | Salida de Bolas
T56 | Transistor NPN BDX53C | Picabolas
158 | Transistor NPN BDX53C | Relé de Bobinas
c) INTERFACE DE DRIVERS

T17 | Transistor PNP 2N5401 Flipper Izquierdo Fuerza
T20 | Transistor PNP 2N5401 Flipper Derecho Fuerza
T23 | Transistor PNP 2N5401 Bancada de Y
T29 | Transistor PNP 2N5401 Flipper Izquierdo Mantenimiento
'T31 | Transistor PNP 2N5401 Flipper Derecho Mantenimiento
133 | Transistor PNP 2N5401 Flash 1 (izquierda)
T35 | Transistor PNP 2N5401 Flash 2 (derecha)

<!-- PDF page 72 -->

c) INTERFACE DE DRIVERS

1139 | Transistor PNP 2N5401

Bumper 1

TH2 | Transistor PNP 2N5401

Bumper 2

T4YS | Transistor PNP 2N5401

Bancada de 1 izquierda

T48 | Transistor PNP 2N5401

Bancada de 1 derecha

T51 | Transistor PNP 2N5401

Taca

153 | Transistor PNP 2N5401

Salida de Bolas

155 | Transistor PNP 2N5401

Picabolas

757 | Transistor PNP 2N5401'

Relé de Bobinas

e) DRIVERS DE MATRIZ DE LUCES

Transistor PNP BDX54C (COLUMNAS)

Transistor NPN BDX53C(FILAS)

f) FUSIBLES : Ver Apartado 7.2.11

<!-- PDF page 73 -->

os*o

5 ASIS 1515
18) com[aaooaddada] com | .4un PP
oso
isa NA
e AT
BL pupeErizouItraO FUERZA | |] 418Y AM
VI HIUPPER DERECHO MERZA_ | o MESA
AZ MANCADA DEA lo
NA FUPPER DERE o y2
RO FLASH 1(IZO! o 7
RO GrMeCR 1 (Aba), als pias
vr peris] O] | Jus
AZ BANCADA DEA (DEJA E 410
GR SALIDA DE_BOtAS pre o
Az RELE DE ROBNLA, pa
| os
e) SLEIC PDRV-93 $

figura 7-5 PLACA DE DRIVERS

<!-- PDF page 74 -->

#### 7.2.2.2.- MATRIZ DE LUCES

La figura 7-6 nos proporciona la topología de la matriz de
luces.

Con el circliito de la figura 7-7 se mandan las informaciones
correspondientes a las filas de la matriz, que se activan sucesi-—
vamente mediante los pulsos enviados por las columnas mediante
el circuito de la figura 7-8.

AM-RO VI-AM AM-VE MA-AZ NE-AZ VE-RO RO-NE  BL-MA
ROWO  ROW1  ROW2 ROW 3 ROWA4 ROWS5 ROW6 ROW7

figura 7-6 MATRIZ DE LUCES

<!-- PDF page 75 -->

» FILA
figura 7-7 DRIVER DE FILAS LUCES
FUSIBLE
COMUN |
> COLUMNA

figura 7-8 DRIVER DE COLUMNAS LUCES

<!-- PDF page 76 -->

#### 7.2.2.3. CONECTORES

J1 Alimentación Bobinas +44V/Masa

J2 Comunicación C.P.U. 8 bits (J2).Cinta plana 20 vías

33 Alimentación +5V/+18V/Masa
J4 Comunicación C.P.U. 8 bits (J4).Cinta plana 20 vías

J5 Comunicación C.P.U. 8 bits (J5).Cinta plana 10 vías

J6 Salida Bobinas (Flippers) y Flashes

37 Salida Bobinas (Resto)

CON1 | Salida Filas Matriz Luces

CON2 | Salida Columnas Matriz Luces

#### 7.2.2.4.- CIRCUITOS DE ATAQUE A BOBINAS

Las placas de Drivers poseen dos tipos de circuitos de

ataque de bobinas.
La figura 7-9 muestra el circuito de potencia.
La figura 7-10 muestra el circuito de mediana potencia.

El circuito de potencia se utiliza en:

) Flipper Izquierdo Fuerza
) Flipper Derecho Fuerza

f) Bancada de 1 izquierda
g) Bancada de 1 derecha

El circuito de mediana potencia de utiliza en:

) Flipper Izquierdo Mantenimiento
) Flipper Derecho Mantenimiento
) Flash 1 (izquierda)
) Flash 2 (derecha)
) Taca

) Salida de Bolas

Picabolas

Relé de Bobinas

<!-- PDF page 77 -->

pol |
Í a
figura 7-9

———J BOBINA

TIP 36C

FUSIBLE

CIRCUITO DÉ POTENCIA BOBINAS

-—— 3” BOBINA

(_ FUSIBLE

figura 7-10 CIRCUITO MEDIANA POTENCIA BOBINAS

<!-- PDF page 78 -->

#### 7.2.3.- CPU DE SONIDO GENERA
Se encarga de todas '148 fUNGie de sonido incorporando un
amplificador de audio de alta: t1 pl

ales, uno dé sonidos
“ro de sonidos agudos

graves que tiene su altavó
con dos altavoces en el 6

' salíza un filtro activo
una sonoridad perfecta. $ pe

En la figura 7-11.

componentes.

ii.

se la disposición de los

+ culo

co, A

O ad!

CAD o... o > ojo o| lo
) ETA

Es a pp]a of] E o of TTolrlo .”,0
B SEI Cde ao) Me est
"| GND
VE| meca] O

<!-- PDF page 79 -->

NDIIoA

#### 7.2.3.1.- COMPONENTES PRINCIPALES |
ICi Microprocesador  Z80B+6 "11 Zilog/SGS
1C41 Sintetizador Voz ¿6376 OKI
1C5 Memoria EPROM 27C10 ' AMD (ELVSONO)
IC42 Memoria EPROM 27C40 11! AMD (ELVSON1)
1C43 Memoria EPROM 27C40': AMD (ELVSON2)
IC44 Memoria EPROM 27C40 AMD (ELVSON3)
1IC45 Memoria EPROM 27C40 '* AMD (ELVSON4)
1C60 Amplificador Operacional -TL8Y Texas da,
1C61,1C62 | Amplificador Integrado. TDA2030 SGS / TELEFUNKEN me
#### 7.2.3.2.- CONECTORES NS .
31 [Alimentación C.A. +18V/=184/Mása'
328 |Comunicación CPU 8 Bits UPA
td. ¡AE
33 Altavoz de Graves (Mueblé8) UT,
J4 Altavoces de |Medios y Apuúdos” (Cabeza)
ly |

<!-- PDF page 80 -->

#### 7.2.4.- PLACA DE DISPLAY

Se encarga de todas las funciones de visualizacion de
máquina por medio de displays de 7 segmentos.

RO VI
+5 GND

a. 000 eno orde ori [me eo] pure oo or re oo Ph eno eno.

ta le

COMUNICACION
CPUB  —

figura bon DISPLAY

ca NL

#### 7.2.4.1.- COMPONENTES PRINCIPALES

DIGIT1A-1E DISPLAY 7 SEGMENTOS HDSP 3901
DIGIT3A-3E Ae SN:

DIGIT11-19 UTA Y

DIGIT31-39 ALIS Ed

DIGIT2D-2E DISPLAY 7, SEGMENTOS HDSP H101
DIGIT22-29 o

1C2.1C5,1C8 | PROM: ERA 6331

#### 7.2.4.2.- CONECTORES

J1 Comunicación SEU AOIAES 10 Vias
J2 Conector de Alimentátion Molex 4 Pines

<!-- PDF page 81 -->

#### 7.2.5.- FUENTE DE ALIMENTACION +5/+12

El conexionado de la fuente' de alimentación de +5V y de +12V
puede verse en la figura 7- -13.

el— +5V RO
61l1|- MASA vi
a) A
Cónb

figura 7-13 ANE ALIMENTACION +5/+12

bel:
#### 7.2.6.- ALIMENTACION DE SONIDO

El conexionado de la AA de alimentación de Sonido puede
verse en la figura 7-14. PENE gia

61) SLEIC=PETACO 011-067 E)

figura 7-14 PLACA DE ALIMENTACION DE SONIDO

<!-- PDF page 82 -->

#### 7.2.7.- ALIMENTACION BOBINAS

La placa de alimentación de 'bobinas, que puede verse en la
figura 7-15, sirve para dar tensión por medio de un relé a las
bobinas.

ta es

+49 DC CND  +24e0C LUZGEN  BOBON

SLEIC—PETACO

O0o00o0oOo0ooOoOoCoQ.q
0O0O0OO0OO0OO0oos

Ev AC  63wvACT  CND

IMACO DA ACA UND SO App+ 30 ep CNO

figura 7-15 ALIMENTACION BOBINAS

<!-- PDF page 83 -->

#### 7.2.8.- MONEDERO ELECTRONICO

1 ENTRADA 12V
ALIMENTACION AM-0,25 |¿

2 ENTRADA HABILITACIO
MONEDERO (MASA) NE-0,25

6 ENTRADA MASA
ALIMENTACION NE-0,25

CONECTOR VISTO DE FRENTE

figura 7-16 MONEDERO ELECTRONICO

<!-- PDF page 84 -->

#### 7.2.9.- CAJA DE RED

La llamada caja de red se encuentra situada en el mueble.
Es accesible desde la puerta de monedero y contiene los
siguientes elementos:

a) Contador de monedas

b) Fusible general de Red (FO)
c) Pulsador de TEST

Base de enchufe para servicio

La distribución de éstos puede verse en la figura 7-17.

CONTADOR

OTTT1TT]

ARA |

FUSIBLE

ENCHUFE RED

figura 7-17 CAJA DE RED

NUMERO | CONCEPTO CODIGO CANTIDAD
CAJA DE RED COMPLETA 069-305 ñ
1 PORTAFUSIBLES 5x20 013-003 a
2 CONTADOR 12v CLIP 041-607 q
3 PULSADOR DE TEST 041-608 ñ
ON BASE EMPOTRABLE 220v 070-305 í
e “FUSIBLE FO 5x20 3A 26-34 1

<!-- PDF page 85 -->

### 2.10.- CONJUNTO PUENTES

figura 7-18 CONJUNTO PUENTES

NUMERO CONCEPTO CODIGO CANTIDAD

CONJUNTO PUENTES 021-162 1
1 RADIADOR 041-610 1
2 ARANDELA DIN 125 MY 125-4 2
3 ARANDELA DIN 6798 mf 6798-4 2
Y TORNILLO DIN 933 MY 933-4X25 2
5 TUERCA DIN 934 MUY 934-4 2
6 PUENTE RECTIFICADOR 10A/200V FB1002 2

<!-- PDF page 86 -->

#### 7.2.1] FUSIBLES

Los distintos fusibles de que dispone la máquina quedan
descritos en cuanto a valor, función y situación en la tabla

siguiente:

FUSIBLE VALOR FUNCION SITUACION

FO 3,154 | General de Red 220 V Caja de Red
F1 3,154 | - 18 V sonido Ampli. Audio

E2 3,154 | + 18 V sonido Ampli. Audio

F3 10A | Luces Controladas Drivers

FY 6,3A | Flipper Izquierdo Drivers

FS 6,34 | Flipper Derecho Drivers

F10 5A | Bancada 1 Drivers

F11 5A | Bancada 2 Drivers

F12 5A | Taca Drivers

F13 5A | Salida de Bolas Drivers

F14 5A | PicaBolas Drivers

F15 5A | Relé de Bobinas Drivers

F16 || 8A General Bobinas Mueble

F17 184 | General Luces Control. Mueble

FE20 10A | Luces Fijas Mueble

F21 NA | Luces de Flash Mueble

<!-- PDF page 87 -->

#### 7.2.12.- TABLA DEL MUEBLE

La tabla del mueble contiene los siguientes elementos:

(1) Conjunto de fusibles generales de F16 a F21.
(2) Placa de Alimentación Luces y Bobinas.
(3) Transformador,

(1) Conjunto Puentes.

po] GR
O mi
DY TAT
BL. Q)
BL RO
CER pers

figura 7-19 TABLA DEL MUEBLS

<!-- PDF page 88 -->

*Esquema, juego I — Cableado general. Hoja no transcrita — ver PDF página 88.*

<!-- PDF page 89 -->

*Esquema, juego I — Cableado general. Hoja no transcrita — ver PDF página 89.*

<!-- PDF page 90 -->

*Esquema, juego I — Cableado general. Hoja no transcrita — ver PDF página 90.*

<!-- PDF page 91 -->

*Esquema, juego I — Cableado general. Hoja no transcrita — ver PDF página 91.*

<!-- PDF page 92 -->

*Esquema, juego I — Cableado general. Hoja no transcrita — ver PDF página 92.*

<!-- PDF page 93 -->

*Esquema, juego II — Placa C.P.U. 8 bits (011-030). Hoja no transcrita — ver PDF página 93.*

<!-- PDF page 94 -->

*Esquema, juego II — Placa C.P.U. 8 bits (011-030). Hoja no transcrita — ver PDF página 94.*

<!-- PDF page 95 -->

*Esquema, juego II — Placa C.P.U. 8 bits (011-030). Hoja no transcrita — ver PDF página 95.*

<!-- PDF page 96 -->

*Esquema, juego II — Placa C.P.U. 8 bits (011-030). Hoja no transcrita — ver PDF página 96.*

<!-- PDF page 97 -->

*Esquema, juego II — Placa C.P.U. 8 bits (011-030). Hoja no transcrita — ver PDF página 97.*

<!-- PDF page 98 -->

*Esquema, juego II — Placa C.P.U. 8 bits (011-030). Hoja no transcrita — ver PDF página 98.*

<!-- PDF page 99 -->

*Esquema, juego II — Placa C.P.U. 8 bits (011-030). Hoja no transcrita — ver PDF página 99.*

<!-- PDF page 100 -->

*Esquema, juego II — Placa C.P.U. 8 bits (011-030). Hoja no transcrita — ver PDF página 100.*

<!-- PDF page 101 -->

*Esquema, juego II — Placa C.P.U. 8 bits (011-030). Hoja no transcrita — ver PDF página 101.*

<!-- PDF page 102 -->

*Esquema, juego II — Placa C.P.U. 8 bits (011-030). Hoja no transcrita — ver PDF página 102.*

<!-- PDF page 103 -->

*Esquema, juego II — Placa C.P.U. 8 bits (011-030). Hoja no transcrita — ver PDF página 103.*

<!-- PDF page 104 -->

*Esquema, juego II — Placa C.P.U. 8 bits (011-030). Hoja no transcrita — ver PDF página 104.*

<!-- PDF page 105 -->

*Esquema, juego III — Placa de sonido general (011-065). Hoja no transcrita — ver PDF página 105.*

<!-- PDF page 106 -->

*Esquema, juego III — Placa de sonido general (011-065). Hoja no transcrita — ver PDF página 106.*

<!-- PDF page 107 -->

*Esquema, juego III — Placa de sonido general (011-065). Hoja no transcrita — ver PDF página 107.*

<!-- PDF page 108 -->

*Esquema, juego III — Placa de sonido general (011-065). Hoja no transcrita — ver PDF página 108.*

<!-- PDF page 109 -->

*Esquema, juego III — Placa de sonido general (011-065). Hoja no transcrita — ver PDF página 109.*

<!-- PDF page 110 -->

*Esquema, juego III — Placa de sonido general (011-065). Hoja no transcrita — ver PDF página 110.*

<!-- PDF page 111 -->

*Esquema, juego III — Placa de sonido general (011-065). Hoja no transcrita — ver PDF página 111.*

<!-- PDF page 112 -->

*Esquema, juego III — Placa de sonido general (011-065). Hoja no transcrita — ver PDF página 112.*

<!-- PDF page 113 -->

*Esquema, juego IV — Placa de drivers (011-027). Hoja no transcrita — ver PDF página 113.*

<!-- PDF page 114 -->

*Esquema, juego IV — Placa de drivers (011-027). Hoja no transcrita — ver PDF página 114.*

<!-- PDF page 115 -->

*Esquema, juego IV — Placa de drivers (011-027). Hoja no transcrita — ver PDF página 115.*

<!-- PDF page 116 -->

*Esquema, juego IV — Placa de drivers (011-027). Hoja no transcrita — ver PDF página 116.*

<!-- PDF page 117 -->

*Esquema, juego IV — Placa de drivers (011-027). Hoja no transcrita — ver PDF página 117.*

<!-- PDF page 118 -->

*Esquema, juego IV — Placa de drivers (011-027). Hoja no transcrita — ver PDF página 118.*

<!-- PDF page 119 -->

*Esquema, juego IV — Placa de drivers (011-027). Hoja no transcrita — ver PDF página 119.*

<!-- PDF page 120 -->

*Esquema, juego IV — Placa de drivers (011-027). Hoja no transcrita — ver PDF página 120.*

<!-- PDF page 121 -->

*Esquema, juego V — Placa de relés. Hoja no transcrita — ver PDF página 121.*

<!-- PDF page 122 -->

*Esquema, juego V — Placa de relés. Hoja no transcrita — ver PDF página 122.*

<!-- PDF page 123 -->

*Esquema, juego V — Placa de relés. Hoja no transcrita — ver PDF página 123.*

<!-- PDF page 124 -->

*Esquema, juego V — Placa de relés. Hoja no transcrita — ver PDF página 124.*

<!-- PDF page 125 -->

*Esquema, juego V — Placa de relés. Hoja no transcrita — ver PDF página 125.*

<!-- PDF page 126 -->

*Esquema, juego V — Placa de relés. Hoja no transcrita — ver PDF página 126.*

<!-- PDF page 127 -->

*Esquema, juego VI — Placa de display y leds (011-064). Hoja no transcrita — ver PDF página 127.*

<!-- PDF page 128 -->

*Esquema, juego VI — Placa de display y leds (011-064). Hoja no transcrita — ver PDF página 128.*

<!-- PDF page 129 -->

*Esquema, juego VI — Placa de display y leds (011-064). Hoja no transcrita — ver PDF página 129.*

<!-- PDF page 130 -->

*Esquema, juego VI — Placa de display y leds (011-064). Hoja no transcrita — ver PDF página 130.*

<!-- PDF page 131 -->

*Esquema, juego VI — Placa de display y leds (011-064). Hoja no transcrita — ver PDF página 131.*

<!-- PDF page 132 -->

*Esquema, juego VI — Placa de display y leds (011-064). Hoja no transcrita — ver PDF página 132.*

<!-- PDF page 133 -->

*Esquema, juego VI — Placa de display y leds (011-064). Hoja no transcrita — ver PDF página 133.*

<!-- PDF page 134 -->

*Esquema, juego VI — Placa de display y leds (011-064). Hoja no transcrita — ver PDF página 134.*

<!-- PDF page 135 -->

*Esquema, juego VII — Placa de alimentación de sonido (011-067). Hoja no transcrita — ver PDF página 135.*

<!-- PDF page 136 -->

*Esquema, juego VII — Placa de alimentación de sonido (011-067). Hoja no transcrita — ver PDF página 136.*

<!-- PDF page 137 -->

*Esquema, juego VII — Placa de alimentación de sonido (011-067). Hoja no transcrita — ver PDF página 137.*

<!-- PDF page 138 -->

*Esquema, juego VII — Placa de alimentación de sonido (011-067). Hoja no transcrita — ver PDF página 138.*

<!-- PDF page 139 -->

*Esquema, juego VII — Placa de alimentación de sonido (011-067). Hoja no transcrita — ver PDF página 139.*

<!-- PDF page 140 -->

*Esquema, juego VII — Placa de alimentación de sonido (011-067). Hoja no transcrita — ver PDF página 140.*

<!-- PDF page 141 -->

*Esquema, juego VII — Placa de alimentación de sonido (011-067). Hoja no transcrita — ver PDF página 141.*

<!-- PDF page 142 -->

*(Contraportada — ver PDF página 142.)*
