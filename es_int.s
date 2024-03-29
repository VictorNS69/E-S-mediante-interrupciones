**** Autores:
****	Víctor Nieves Sánchez
****	Daniel Morgera Pérez

* Inicializa el SP y el PC
**************************
	ORG     $0
	DC.L    $8000           * Pila
	DC.L    INICIO          * PC
        ORG     $400

*** Buffers ***
BRA:	DS.B	2000	* buffer de recepcion de 2000 bytes
BTA:	DS.B	2000	* buffer de transmision de 2000 bytes
BRB:	DS.B	2000	* buffer de recepcion de 2000 bytes
BTB:	DS.B	2000	* buffer de transmision de 2000 bytes

*** Punteros ***
PIRA:	DS.B	4	* puntero de introduccion a BRA
PERA:	DS.B	4	* puntero de extraccion a BRA
PITA:	DS.B	4	* puntero de introduccion a BTA
PETA:	DS.B	4	* puntero de extraccion a BTA
PIRB:	DS.B	4	* puntero de introduccion a BRB
PERB:	DS.B	4	* puntero de extraccion a BRB
PITB:	DS.B	4	* puntero de introduccion a BTB
PETB:	DS.B	4	* puntero de extraccion a BTB

*** Contadores ***
CONTRA:	DC.L	0	* contador de caracteres BRA
CONTRB:	DC.L	0	* contador de caracteres BRB
CONTTA: DC.L    0	* contador de caracteres BTA
CONTTB: DC.L	0	* contador de caracteres BTB

CIMR:	DS.B	2	* Copia de IMR
FLAGA:	DS.B	1	* Flag del buffer de transmision A
FLAGB:	DS.B	1	* Flag del buffer de transmision B

* Definición de equivalencias
*********************************
*** Puerto A ***
MR1A    EQU     $effc01       * de modo A (escritura)
MR2A    EQU     $effc01       * de modo A (2º escritura)
SRA     EQU     $effc03       * de estado A (lectura)
CSRA    EQU     $effc03       * de seleccion de reloj A (escritura)
CRA     EQU     $effc05       * de control A (escritura)
TBA     EQU     $effc07       * buffer transmision A (escritura)
RBA     EQU     $effc07       * buffer recepcion A  (lectura)
ACR	EQU	$effc09	      * de control auxiliar
IMR     EQU     $effc0B       * de mascara de interrupcion A (escritura)
ISR     EQU     $effc0B       * de estado de interrupcion A (lectura)

*** Puerto B ***
MR1B    EQU     $effc11       * de modo B (escritura)
MR2B    EQU     $effc11       * de modo B (2º escritura)
SRB     EQU     $effc13       * de estado B (lectura)
CSRB    EQU     $effc13       * de seleccion de reloj B (escritura)
CRB     EQU     $effc15       * de control B (escritura)
RBB     EQU     $effc17       * buffer recepcion B (lectura)
TBB     EQU     $effc17       * buffer transmision B (escritura)
IVR     EQU     $effc19       * de vector de interrupcion

**************************** INIT *************************************************************
INIT:	MOVE.B          #%00010000,CRA      	* Reinicia el puntero MR1A
        MOVE.B          #%00010000,CRB      	* Reinicia el puntero MR1B
	MOVE.B          #%00000011,MR1A     	* 8 bits por caracter de modo A
	MOVE.B          #%00000011,MR1B     	* 8 bits por caracter de modo B
        MOVE.B          #%00000000,MR2A     	* Eco desactivado
        MOVE.B          #%00000000,MR2B     	* Eco desactivado
	MOVE.B 		#%11001100,CSRA     	* Velocidad = 38400 bps
	MOVE.B 		#%11001100,CSRB     	* Velocidad = 38400 bps
	MOVE.B 		#%00000000,ACR		* Inicializacion control auxiliar
	MOVE.B 		#%00000101,CRA		* Transmision y recepcion activados A
	MOVE.B		#%00000101,CRB 		* Transmision y recepcion activados B
	MOVE.B 		#$040,IVR		* Vector de Interrrupcion nº 40
	MOVE.B 		#%00100010,IMR		* Habilita las interrupciones de A y B
	MOVE.B		#%00100010,CIMR		* Copia de IMR
	MOVE.L 		#RTI,$100		* Inicio de RTI en tabla de interrupciones H'40*4
	MOVE.B		#0,FLAGA		* Inicializamos flag de buffer de transmision A a 0
	MOVE.B		#0,FLAGB		* Inicializamos flag de buffer de transmision B a 0
	

*** Inicializacion de buffers ***
	MOVE.L		#BRA,PIRA
	MOVE.L		#BRA,PERA
	MOVE.L		#BTA,PITA
	MOVE.L		#BTA,PETA
	MOVE.L		#BRB,PIRB
	MOVE.L		#BRB,PERB
	MOVE.L		#BTB,PITB
	MOVE.L		#BTB,PETB
	RTS

**************************** FIN INIT *********************************************************

**************************** RTI **************************************************************
RTI:	MOVE.L		D0,-(A7)		* Salvamos todos los registros de datos
	MOVE.L		D1,-(A7)
	MOVE.L		D2,-(A7)
	MOVE.L		D3,-(A7)
	MOVE.L		D4,-(A7)
	MOVE.L		D5,-(A7)
	MOVE.L		D6,-(A7)
	MOVE.L		D7,-(A7)
	MOVE.L		A0,-(A7)		* Salvamos todos los registros de direcciones
	MOVE.L		A1,-(A7)
	MOVE.L		A2,-(A7)
	MOVE.L		A3,-(A7) 
	MOVE.L		A4,-(A7)
	MOVE.L		A5,-(A7)
	MOVE.L		A6,-(A7)
BUCRTI:	MOVE.L		#0,D1			* Reseteamos D1 por comodidad visual
	MOVE.B		CIMR,D1			* Guardamos CIMR en D1
	AND.B		ISR,D1			* Comparamos registro de estado con mascara de interrupcion
	BTST		#0,D1			* B0 --> Transmision A
	BNE		RTITA
	BTST		#1,D1			* B1 --> Recepcion A
	BNE		RTIRA
	BTST		#4,D1			* B4 --> Transmision B
	BNE		RTITB
	BTST		#5,D1			* B5 --> Recepcion B
	BNE		RTIRB
	BRA		RTIFIN

RTITA:	CMP.B		#0,FLAGA		
	BNE		ACTA
	MOVE.L		#2,D0			* Seleccionamos el buffer de transmision de A
	BSR		LEECAR	
	MOVE.B		D0,TBA			* Escribimos el caracter leido en el buffer correspondiente
	CMP.B		#13,D0			* Comprobamos que el caracter leido no sea un retorno de carro
	BNE		BUCRTI
	MOVE.B		#1,FLAGA		* Ponemos el flag A a 1
	BRA		BUCRTI

ACTA:	MOVE.B 		#0,FLAGA		* Ponemos el flag A a 0
	MOVE.B		#10,TBA			* Insertamos un salto de linea en el buffer
	MOVE.B		#2,D0
	BSR 		LINEA			* Llamada a linea para comprobar si quedan mas lineas
	CMP.L		#0,D0
	BNE		BUCRTI 
	BCLR		#0,CIMR			* Inhibimos la interrupcion en la mascara
	MOVE.B		CIMR,IMR		* Modificamos IMR
	BRA 		BUCRTI

RTIRA:	MOVE.L		#0,D0			* Seleccionamos el buffer de recepcion de A
	MOVE.B		RBA,D1			* Leemos el caracter a escribir del buffer correspondiente
	BSR		ESCCAR
	BRA		BUCRTI

RTITB:	CMP.B		#0,FLAGB		
	BNE		ACTB
	MOVE.L		#3,D0			* Seleccionamos el buffer de transmision de B
	BSR		LEECAR	
	MOVE.B		D0,TBB			* Escribimos el caracter leido en el buffer correspondiente
	CMP.B		#13,D0			* Comprobamos que el caracter leido no sea un retorno de carro
	BNE		BUCRTI
	MOVE.B		#1,FLAGB		* Ponemos el flag B a 1
	BRA		BUCRTI

ACTB:	MOVE.B 		#0,FLAGB		* Ponemos el flag B a 0
	MOVE.B		#10,TBB			* Insertamos un salto de linea en el buffer
	MOVE.B		#3,D0
	BSR 		LINEA			* Llamada a linea para comprobar si quedan mas lineas
	CMP.L		#0,D0
	BNE		BUCRTI 
	BCLR		#4,CIMR			* Inhibimos la interrupcion en la mascara
	MOVE.B		CIMR,IMR		* Modificamos IMR
	BRA 		BUCRTI

RTIRB:	MOVE.L		#1,D0			* Seleccionamos el buffer de recepcion de B
	MOVE.B		RBB,D1			* Leemos el caracter a escribir del buffer correspondiente
	BSR		ESCCAR
	BRA		BUCRTI

RTIFIN: MOVE.L		(A7)+,A6		* Restauramos los registros de direcciones
	MOVE.L		(A7)+,A5
	MOVE.L		(A7)+,A4
	MOVE.L		(A7)+,A3
	MOVE.L		(A7)+,A2
	MOVE.L		(A7)+,A1
	MOVE.L		(A7)+,A0			
	MOVE.L		(A7)+,D7
	MOVE.L		(A7)+,D6	
	MOVE.L		(A7)+,D5		 * Restauramos los registros de datos
	MOVE.L		(A7)+,D4
	MOVE.L		(A7)+,D3
	MOVE.L		(A7)+,D2
	MOVE.L		(A7)+,D1
	MOVE.L		(A7)+,D0
	RTE

**************************** FIN RTI **********************************************************

**************************** LEECAR ***********************************************************
LEECAR:	AND.L		#3,D0			* Se comparan los 3 primeros bits de D0
	CMP.L		#0,D0			* Si es 0 es buffer de recepción de línea A
	BEQ		LRECA
	CMP.L		#1,D0			* Si es 1 es buffer de recepción de línea B
	BEQ		LRECB
	CMP.L		#2,D0			* Si es 2 es buffer de transmisión de línea A
	BEQ		LTRANSA
	CMP.L		#3,D0			* Si es 3 es buffer de transmisión de línea B
	BEQ		LTRANSB

*************** ELECCION DE BUFFER ***************
*** BUFFER RECEPCION LINEA A ***
LRECA:	*MOVE.L		CONTRA,D2		* D2 = CONTRA (contador)
	MOVE.L		PERA,A1			* A1 = PERA
	MOVE.L		PIRA,A2			* A2 = PIRA
	CMP.L		A1,A2			* Si los punteros coinciden miramos tamaño del buffer
	BEQ 		LMCONTRA	
	CMP		#BRA+1999,A1		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		LRESRA	
	BRA		LFINOKRA

*** BUFFER RECEPCION LINEA B ***
LRECB:	*MOVE.L		CONTRB,D2		* D2 = CONTRB (contador)
	MOVE.L		PERB,A1			* A1 = PERB
	MOVE.L		PIRB,A2			* A2 = PIRB
	CMP.L		A1,A2			* Si los punteros coinciden miramos tamaño del buffer
	BEQ 		LMCONTRB	
	CMP		#BRB+1999,A1		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		LRESRB	
	BRA		LFINOKRB

*** BUFFER TRANSMISION LINEA A ***
LTRANSA:*MOVE.L		CONTTA,D2		* D2 = CONTTA (contador)
	MOVE.L		PETA,A1			* A1 = PETA
	MOVE.L		PITA,A2			* A2 = PITA
	CMP.L		A1,A2			* Si los punteros coinciden miramos tamaño del buffer
	BEQ 		LMCONTTA	
	CMP		#BTA+1999,A1		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		LRESTA	
	BRA		LFINOKTA

*** BUFFER TRANSMISION LINEA B ***
LTRANSB:*MOVE.L		CONTTB,D2		* D2 = CONTTB (contador)
	MOVE.L		PETB,A1			* A1 = PETB
	MOVE.L		PITB,A2			* A2 = PITB
	CMP.L		A1,A2			* Si los punteros coinciden miramos tamaño del buffer
	BEQ 		LMCONTTB	
	CMP		#BTB+1999,A1		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		LRESTB	
	BRA		LFINOKTB

*************** PUNTERO EN SCANF DE BUFFER ***************
*** RESET PUNTERO EN BUFFER DE RECEPCION A ***
LRESRA:	MOVE.B 		(A1),D0			* Extraigo el caracter del buffer
	SUB.L		#1,CONTRA		* Reduzco el contador de caracteres en el buffer
	*MOVE.L		D2,CONTRA
	MOVE.L 		#BRA,PERA		* Pongo el puntero de extraccion al principio del buffer
	RTS

*** RESET PUNTERO EN BUFFER DE RECEPCION B ***
LRESRB:	MOVE.B 		(A1),D0			* Extraigo el caracter del buffer
	SUB.L		#1,CONTRB		* Reduzco el contador de caracteres en el buffer
	*MOVE.L		D2,CONTRB
	MOVE.L 		#BRB,PERB		* Pongo el puntero de extraccion al principio del buffer
	RTS

*** RESET PUNTERO EN BUFFER DE TRANSMISION A ***
LRESTA:	MOVE.B 		(A1),D0			* Extraigo el caracter del buffer
	SUB.L		#1,CONTTA		* Reduzco el contador de caracteres en el buffer
	*MOVE.L		D2,CONTTA
	MOVE.L 		#BTA,PETA		* Pongo el puntero de extraccion al principio del buffer
	RTS

*** RESET PUNTERO EN BUFFER DE TRANSMISION B ***
LRESTB:	MOVE.B 		(A1),D0			* Extraigo el caracter del buffer
	SUB.L		#1,CONTTB		* Reduzco el contador de caracteres en el buffer
	*MOVE.L		D2,CONTTB
	MOVE.L 		#BTB,PETB		* Pongo el puntero de extraccion al principio del buffer
	RTS

*************** BUFFER LLENO Y SCANFES OK ***************
*** MIRAMOS CONTADOR Y SCANF OK EN RECEPCION DE A ***
LMCONTRA:CMP.L		#0,CONTRA		* Si el buffer esta vacio pongo 0xFFFFFFFF en D0
	BEQ		LFINVAC
	CMP		#BRA+1999,A1		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		LRESRA
	
LFINOKRA:MOVE.B		(A1)+,D0		* D0 = Caracter leido y apunto a la siguiente posicion
	SUB.L		#1,CONTRA			* Reduzco el contador de caracteres en el buffer
	*MOVE.L		D2,CONTRA
	MOVE.L 		A1,PERA			* Actualizo la posicion del puntero de introduccion
	RTS

*** MIRAMOS CONTADOR Y SCANF OK EN RECEPCION DE B ***
LMCONTRB:CMP.L		#0,CONTRB		* Si el buffer esta vacio pongo 0xFFFFFFFF en D0
	BEQ		LFINVAC
	CMP		#BRB+1999,A1		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		LRESRB
	
LFINOKRB:MOVE.B		(A1)+,D0		* D0 = Caracter leido y apunto a la siguiente posicion
	SUB.L		#1,CONTRB			* Reduzco el contador de caracteres en el buffer
	*MOVE.L		D2,CONTRB
	MOVE.L 		A1,PERB			* Actualizo la posicion del puntero de introduccion
	RTS

*** MIRAMOS CONTADOR Y SCANF OK EN TRANSMISION DE A ***
LMCONTTA:CMP.L		#0,CONTTA		* Si el buffer esta vacio pongo 0xFFFFFFFF en D0
	BEQ		LFINVAC
	CMP		#BTA+1999,A1		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		LRESTA	

LFINOKTA:MOVE.B		(A1)+,D0		* D0 = Caracter leido y apunto a la siguiente posicion
	SUB.L		#1,CONTTA		* Reduzco el contador de caracteres en el buffer
	*MOVE.L		D2,CONTTA
	MOVE.L 		A1,PETA			* Actualizo la posicion del puntero de introduccion
	RTS

*** MIRAMOS CONTADOR Y SCANF OK EN TRANSMISION DE B ***
LMCONTTB:CMP.L		#0,CONTTB		* Si el buffer esta vacio pongo 0xFFFFFFFF en D0
	BEQ		LFINVAC
	CMP		#BTB+1999,A1		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		LRESTB	

LFINOKTB:MOVE.B		(A1)+,D0		* D0 = Caracter leido y apunto a la siguiente posicion
	SUB.L		#1,CONTTB		* Reduzco el contador de caracteres en el buffer
	*MOVE.L		D2,CONTTB
	MOVE.L 		A1,PETB			* Actualizo la posicion del puntero de introduccion
	RTS

*************** SCANF CON BUFFER VACIO ***************
LFINVAC:MOVE.L		#$FFFFFFFF,D0		* D0 = 0xFFFFFFFF
	RTS
**************************** FIN LEECAR *******************************************************

**************************** ESCCAR ***********************************************************
ESCCAR:	AND.L		#3,D0			* Se comparan los 3 primeros bits de D0
	CMP.L		#0,D0			* Si es 0 es buffer de recepción de línea A
	BEQ		ERECA
	CMP.L		#1,D0			* Si es 1 es buffer de recepción de línea B
	BEQ		ERECB
	CMP.L		#2,D0			* Si es 2 es buffer de transmisión de línea A
	BEQ		ETRANSA
	CMP.L		#3,D0			* Si es 3 es buffer de transmisión de línea B
	BEQ		ETRANSB

*************** ELECCION DE BUFFER ***************
*** BUFFER RECEPCION LINEA A ***
ERECA:	*MOVE.L		CONTRA,D2		* D2 = CONTRA (contador)
	MOVE.L		PERA,A1		* A1 = PERA
	MOVE.L		PIRA,A2		* A2 = PIRA
	CMP.L		A1,A2			* Si los punteros coinciden miramos tamaño del buffer
	BEQ 		EMCONTRA	
	CMP		#BRA+1999,A2		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		ERESRA	
	BRA		EFINOKRA

*** BUFFER RECEPCION LINEA B ***
ERECB:	*MOVE.L		CONTRB,D2		* D2 = CONTRB (contador)
	MOVE.L		PERB,A1		* A1 = PERB
	MOVE.L		PIRB,A2		* A2 = PIRB
	CMP.L		A1,A2			* Si los punteros coinciden miramos tamaño del buffer
	BEQ 		EMCONTRB	
	CMP		#BRB+1999,A2		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		ERESRB	
	BRA		EFINOKRB

*** BUFFER TRANSMISION LINEA A ***
ETRANSA:*MOVE.L		CONTTA,D2		* D2 = CONTTA (contador)
	MOVE.L		PETA,A1		* A1 = PETA
	MOVE.L		PITA,A2		* A2 = PITA
	CMP.L		A1,A2			* Si los punteros coinciden miramos tamaño del buffer
	BEQ 		EMCONTTA	
	CMP		#BTA+1999,A2		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		ERESTA	
	BRA		EFINOKTA

*** BUFFER TRANSMISION LINEA B ***
ETRANSB:*MOVE.L		CONTTB,D2		* D2 = CONTTB (contador)
	MOVE.L		PETB,A1		* A1 = PETB
	MOVE.L		PITB,A2		* A2 = PITB
	CMP.L		A1,A2			* Si los punteros coinciden miramos tamaño del buffer
	BEQ 		EMCONTTB	
	CMP		#BTB+1999,A2		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		ERESTB	
	BRA		EFINOKTB

*************** PUNTERO EN SCANF DE BUFFER ***************
*** RESET PUNTERO EN BUFFER DE RECEPCION A ***
ERESRA:	MOVE.B 		D1,(A2)			* Inserto el caracter en el buffer
	ADD.L		#1,CONTRA		* Aumento el contador de caracteres en el buffer
	*MOVE.L		D2,CONTRA
	MOVE.L 		#BRA,PIRA		* Pongo el puntero de introduccion al principio del buffer
	MOVE.L 		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*** RESET PUNTERO EN BUFFER DE RECEPCION B ***
ERESRB:	MOVE.B 		D1,(A2)			* Inserto el caracter en el buffer
	ADD.L		#1,CONTRB		* Aumento el contador de caracteres en el buffer
	*MOVE.L		D2,CONTRB
	MOVE.L 		#BRB,PIRB		* Pongo el puntero de introduccion al principio del buffer
	MOVE.L 		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*** RESET PUNTERO EN BUFFER DE TRANSMISION A ***
ERESTA:	MOVE.B 		D1,(A2)			* Inserto el caracter en el buffer
	ADD.L		#1,CONTTA			* Aumento el contador de caracteres en el buffer
	*MOVE.L		D2,CONTTA
	MOVE.L 		#BTA,PITA		* Pongo el puntero de introduccion al principio del buffer
	MOVE.L 		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*** RESET PUNTERO EN BUFFER DE TRANSMISION B ***
ERESTB:	MOVE.B 		D1,(A2)			* Inserto el caracter en el buffer
	ADD.L		#1,CONTTB			* Aumento el contador de caracteres en el buffer
	*MOVE.L		D2,CONTTB
	MOVE.L 		#BTB,PITB		* Pongo el puntero de introduccion al principio del buffer
	MOVE.L 		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*************** BUFFER LLENO Y SCANFES OK ***************
*** MIRAMOS CONTADOR Y SCANF OK EN RECEPCION DE A ***
EMCONTRA:CMP.L		#2000,CONTRA		* Si el buffer esta lleno pongo 0xFFFFFFFF en D0
	BEQ		EFINLLE
	CMP		#BRA+1999,A2		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		ERESRA
	
EFINOKRA:MOVE.B		D1,(A2)+		* Inserto el caracter en el buffer y apunto a la siguiente posicion
	ADD.L		#1,CONTRA			* Aumento el contador de caracteres en el buffer
	*MOVE.L		D2,CONTRA
	MOVE.L 		A2,PIRA			* Actualizo la posicion del puntero de introduccion
	MOVE.L		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*** MIRAMOS CONTADOR Y SCANF OK EN RECEPCION DE B ***
EMCONTRB:CMP.L		#2000,CONTRB		* Si el buffer esta lleno pongo 0xFFFFFFFF en D0
	BEQ		EFINLLE
	CMP		#BRB+1999,A2		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		ERESRB
	
EFINOKRB:MOVE.B		D1,(A2)+		* Inserto el caracter en el buffer y apunto a la siguiente posicion
	ADD.L		#1,CONTRB			* Aumento el contador de caracteres en el buffer
	*MOVE.L		D2,CONTRB
	MOVE.L 		A2,PIRB			* Actualizo la posicion del puntero de introduccion
	MOVE.L		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*** MIRAMOS CONTADOR Y SCANF OK EN TRANSMISION DE A ***
EMCONTTA:CMP.L		#2000,CONTTA		* Si el buffer esta lleno pongo 0xFFFFFFFF en D0
	BEQ		EFINLLE
	CMP		#BTA+1999,A2		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		ERESTA	

EFINOKTA:MOVE.B		D1,(A2)+		* Inserto el caracter en el buffer y apunto a la siguiente posicion
	ADD.L		#1,CONTTA			* Aumento el contador de caracteres en el buffer
	*MOVE.L		D2,CONTTA
	MOVE.L 		A2,PITA			* Actualizo la posicion del puntero de introduccion
	MOVE.L		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*** MIRAMOS CONTADOR Y SCANF OK EN TRANSMISION DE B ***
EMCONTTB:CMP.L		#2000,CONTTB		* Si el buffer esta lleno pongo 0xFFFFFFFF en D0
	BEQ		EFINLLE
	CMP		#BTB+1999,A2		* Si estamos al SCANF del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		ERESTB

EFINOKTB:MOVE.B		D1,(A2)+		* Inserto el caracter en el buffer y apunto a la siguiente posicion
	ADD.L		#1,CONTTB			* Aumento el contador de caracteres en el buffer
	*MOVE.L		D2,CONTTB
	MOVE.L 		A2,PITB			* Actualizo la posicion del puntero de introduccion
	MOVE.L		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*************** SCANF CON BUFFER LLENO ***************
EFINLLE:MOVE.L		#$FFFFFFFF,D0		* D0 = 0xFFFFFFFF
	RTS

**************************** FIN ESCCAR *******************************************************

**************************** LINEA ************************************************************
LINEA:	MOVE.L		#0,D2			* Inicializo contador de caracteres de la linea
	AND.L		#3,D0			* Se comparan los 3 primeros bits de D0
	CMP.L		#0,D0			* Si es 0 es buffer de recepción de línea A
	BEQ		LIRECA
	CMP.L		#1,D0			* Si es 1 es buffer de recepción de línea B
	BEQ		LIRECB
	CMP.L		#2,D0			* Si es 2 es buffer de transmisión de línea A
	BEQ		LITRANSA
	CMP.L		#3,D0			* Si es 3 es buffer de transmisión de línea B
	BEQ		LITRANSB

*************** ELECCION DE BUFFER ***************
*** BUFFER RECEPCION LINEA A ***
LIRECA:	MOVE.L		PERA,A1		* A1 = PERA
	MOVE.L		PIRA,A2		* A2 = PIRA
	CMP 		A1,A2		* Si los punteros coinciden miramos el contador global de caracteres
	BNE		BUCLIRA
	CMP		#0,CONTRA	* Si el contador global esta a 0
	BNE		BUCLIRA
	BRA		LIFINZ	
	
BUCLIRA:MOVE.B		(A1),D4
	CMP.B		#13,D4		* Si el caracter es el ASCII 13 salimos del bucle
	BEQ		LIFINOK
	CMP		#BRA+1999,A1	* Si estamos al SCANF del buffer
	BEQ		LIRESRA
	ADD.L		#1,D2		* Aumento el contador de caracteres de linea
	ADD.L		#1,A1		* Avanzo el puntero de linea
	BRA		LICOINRA

LIRESRA:MOVE.L		#BRA,A1		* Coloco el puntero al inicio del buffer
	ADD.L		#1,D2		* Aumento el contador de caracteres de linea
	BRA		LICOINRA

LICOINRA:CMP 		A1,A2		* Si los punteros coinciden, D0 = 0 y acabo
	BEQ		LIFINZ
	BRA		BUCLIRA

*** BUFFER RECEPCION LINEA B ***
LIRECB:	MOVE.L		PERB,A1		* A1 = PERB
	MOVE.L		PIRB,A2		* A2 = PIRB
	CMP 		A1,A2		* Si los punteros coinciden miramos el contador global de caracteres
	BNE		BUCLIRB
	CMP		#0,CONTRB	* Si el contador global esta a 0
	BNE		BUCLIRB
	BRA		LIFINZ	
	
BUCLIRB:MOVE.B		(A1),D4
	CMP.B		#13,D4		* Si el caracter es el ASCII 13 salimos del bucle
	BEQ		LIFINOK
	CMP		#BRB+1999,A1	* Si estamos al SCANF del buffer
	BEQ		LIRESRB
	ADD.L		#1,D2		* Aumento el contador de caracteres de linea
	ADD.L		#1,A1		* Avanzo el puntero de linea
	BRA		LICOINRB

LIRESRB:MOVE.L		#BRB,A1		* Coloco el puntero al inicio del buffer
	ADD.L		#1,D2		* Aumento el contador de caracteres de linea
	BRA		LICOINRB

LICOINRB:CMP 		A1,A2		* Si los punteros coinciden, D0 = 0 y acabo
	BEQ		LIFINZ
	BRA		BUCLIRB

*** BUFFER TRANSMISION LINEA A ***
LITRANSA:MOVE.L		PETA,A1		* A1 = PETA
	MOVE.L		PITA,A2		* A2 = PITA
	CMP 		A1,A2		* Si los punteros coinciden miramos el contador global de caracteres
	BNE		BUCLITA
	CMP		#0,CONTTA	* Si el contador global esta a 0
	BNE		BUCLITA
	BRA		LIFINZ	
	
BUCLITA:MOVE.B		(A1),D4
	CMP.B		#13,D4		* Si el caracter es el ASCII 13 salimos del bucle
	BEQ		LIFINOK
	CMP		#BTA+1999,A1	* Si estamos al SCANF del buffer
	BEQ		LIRESTA
	ADD.L		#1,D2		* Aumento el contador de caracteres de linea
	ADD.L		#1,A1		* Avanzo el puntero de linea
	BRA		LICOINTA

LIRESTA:MOVE.L		#BTA,A1		* Coloco el puntero al inicio del buffer
	ADD.L		#1,D2		* Aumento el contador de caracteres de linea
	BRA		LICOINTA

LICOINTA:CMP 		A1,A2		* Si los punteros coinciden, D0 = 0 y acabo
	BEQ		LIFINZ
	BRA		BUCLITA

*** BUFFER TRANSMISION LINEA B ***
LITRANSB:MOVE.L		PETB,A1		* A1 = PETB
	MOVE.L		PITB,A2		* A2 = PITB
	CMP 		A1,A2		* Si los punteros coinciden miramos el contador global de caracteres
	BNE		BUCLITB
	CMP		#0,CONTTB	* Si el contador global esta a 0
	BNE		BUCLITB
	BRA		LIFINZ	
	
BUCLITB:MOVE.B		(A1),D4
	CMP.B		#13,D4		* Si el caracter es el ASCII 13 salimos del bucle
	BEQ		LIFINOK
	CMP		#BTB+1999,A1	* Si estamos al SCANF del buffer
	BEQ		LIRESTB
	ADD.L		#1,D2		* Aumento el contador de caracteres de linea
	ADD.L		#1,A1		* Avanzo el puntero de linea
	BRA		LICOINTB

LIRESTB:MOVE.L		#BTB,A1		* Coloco el puntero al inicio del buffer
	ADD.L		#1,D2		* Aumento el contador de caracteres de linea
	BRA		LICOINTB

LICOINTB:CMP 		A1,A2		* Si los punteros coinciden, D0 = 0 y acabo
	BEQ		LIFINZ
	BRA		BUCLITB
*************** SCANFES DE SUBRUTINA ***************
LIFINOK:ADD.L		#1,D2		* Avanzamos contador porque el ASCII 13 tambien se cuenta
	MOVE.L		D2,D0		* D0 = CONTADOR LINEA
	RTS

LIFINZ:	MOVE.L		#0,D0		* D0 = 0
	RTS

**************************** FIN LINEA ********************************************************

**************************** PRINT ************************************************************
PRINT:  LINK 	A6,#0			* Creacion del marco de pila
	MOVE.W	14(A6),D1		* Tamaño en D1
	MOVE.W	12(A6),D2		* Descriptor en D2
	MOVE.L 	8(A6),A0		* Puntero a buffer en A0
	CMP.L	#0,D1			* Si Tamaño < 0
	BLT	PRINTE
	BEQ	PRINTF
	MOVE.L	#0,D1			* Reseteamos D1 para comodidad visual
	MOVE.L	#0,-(A7)		* Guardo contador en pila
	MOVE.L 	A0,-(A7)		* Guardo puntero a buffer en pila
	CMP.L	#0,D2			* Si Descriptor = 0
	BEQ	PRINTA
	CMP.L	#1,D2			* Si Descriptor = 1
	BEQ	PRINTB
	MOVE.L	#$FFFFFFFF,D0		* D0 = 0xFFFFFFFF
	MOVE.L	(A7)+,D7
	MOVE.L	(A7)+,D7
	UNLK 	A6
	RTS

PRINTA:	MOVE.L  -8(A6),A1		* Puntero a buffer en A1
	MOVE.B	(A1),D1			* Caracter de puntero de buffer en D1
	CMP.B	#13,D1			* Si el caracter es un retorno de carro
	BEQ	RETA
	MOVE.L	#2,D0			* Selecciono Buffer de transmision de A
	BSR	ESCCAR
	CMP	#0,D0			* Si el buffer interno esta lleno
	BNE	PRINTF
	ADD.L	#1,-4(A6)		* Aumento contador
	ADD.L	#1,-8(A6)		* Avanzo puntero
	MOVE.L	-4(A6),D1		* Contador a D1
	MOVE.W	14(A6),D2		* Tamaño a D2
	CMP.L	D2,D1			* Si contador = tamaño
	BEQ	PRINTF
	BRA	PRINTA

RETA:	MOVE.L	#2,D0			* Selecciono Buffer de transmision de A
	BSR	ESCCAR
	CMP	#0,D0			* Si el buffer interno esta lleno
	BNE	PRINTF
	MOVE.W	#$2700,SR		* Inhabilitamoso interrupciones
	BSET	#0,CIMR			* Activo interrupcion de transmision de A
	MOVE.B	CIMR,IMR
	MOVE.W	#$2000,SR		* Habilitamoso interrupciones
	ADD.L	#1,-4(A6)		* Aumento contador
	ADD.L	#1,-8(A6)		* Avanzo puntero
	MOVE.L	-4(A6),D1		* Contador a D1
	MOVE.W	14(A6),D2		* Tamaño a D2
	CMP.L	D2,D1			* Si contador = tamaño
	BEQ	PRINTF
	BRA	PRINTA

	
PRINTB: MOVE.L  -8(A6),A1		* Puntero a buffer en A1
	MOVE.B	(A1),D1			* Caracter de puntero de buffer en D1
	CMP.B	#13,D1			* Si el caracter es un retorno de carro
	BEQ	RETB
	MOVE.L	#3,D0			* Selecciono Buffer de transmision de B
	BSR	ESCCAR
	CMP	#0,D0			* Si el buffer interno esta lleno
	BNE	PRINTF
	ADD.L	#1,-4(A6)		* Aumento contador
	ADD.L	#1,-8(A6)		* Avanzo puntero
	MOVE.L	-4(A6),D1		* Contador a D1
	MOVE.W	14(A6),D2		* Tamaño a D2
	CMP.L	D2,D1			* Si contador = tamaño
	BEQ	PRINTF
	BRA	PRINTB

RETB:	MOVE.L	#3,D0			* Selecciono Buffer de transmision de B
	BSR	ESCCAR
	CMP	#0,D0			* Si el buffer interno esta lleno
	BNE	PRINTF
	MOVE.W	#$2700,SR		* Inhabilitamoso interrupciones
	BSET	#4,CIMR			* Activo interrupcion de transmision de B
	MOVE.B	CIMR,IMR
	MOVE.W	#$2000,SR		* Habilitamos interrupciones
	ADD.L	#1,-4(A6)		* Aumento contador
	ADD.L	#1,-8(A6)		* Avanzo puntero
	MOVE.L	-4(A6),D1		* Contador a D1
	MOVE.W	14(A6),D2		* Tamaño a D2
	CMP.L	D2,D1			* Si contador = tamaño
	BEQ	PRINTF
	BRA	PRINTB

PRINTF:	MOVE.L	-4(A6),D0		* SCANF devolviendo el contador
	MOVE.L	(A7)+,D7
	MOVE.L	(A7)+,D7
	UNLK	A6
	RTS

PRINTE:	MOVE.L	#$FFFFFFFF,D0		* D0 = 0xFFFFFFFF
	UNLK 	A6
	RTS

**************************** FIN PRINT ********************************************************

**************************** SCAN *************************************************************
SCAN:     LINK      A6,#-12             * Creamos marco de pila
          MOVE.L    #0,D1
          MOVE.L    #0,D2
          MOVE.W    $e(A6),D1           * Tamaño a D1
          MOVE.W    $c(A6),D2           * Descriptor a D2
          CMP.L     #1,D2               * Si descriptor > 1
          BGT       SCANE
          CMP       #1,D2               * Si Descriptor = 1
          BEQ       SCANB            

SCANA:    MOVE.L    #0,D0
          BSR       LINEA
          CMP.L     #0,D0
          BEQ       SCAN0
          MOVE.W    $e(A6),D1           * Tamaño a D1
          CMP.L     D1,D0
          BGT       SCAN0
          MOVE.L    $8(A6),D3           * Buffer a D3
          MOVE.L    #0,-8(A6)           * Inicializamos contador
          MOVE.L    D3,-12(A6)          * Guardamos puntero a buffer en marco de pila
          MOVE.L    D0,-4(A6)           * Guardamos tamaño de linea en marco de pila
SBUCA:   MOVE.L    #0,D0		* Seleccionamos buffer de recepcion de A
          BSR       LEECAR             
          MOVE.L    -12(A6),D1          * Puntero a buffer en D1
          MOVE.L    D1,A0              
          MOVE.B    D0,(A0)             * Introducimos el caracter leido en el buffer
          ADD.L     #1,-12(A6)          * Avanzamos el puntero
          ADD.L     #1,-8(A6)           * Aumentamos el contador
          SUB.L     #1,-4(A6)           * Restamos uno al tamaño de linea
          CMP.L     #0,-4(A6)           * Comprobamos si hemos llegado al SCANF
          BNE       SBUCA              * Si no es el SCANF volvemos al bucle
          MOVE.L    -8(A6),D0           * Contador en D0
          BRA       SCANF

SCANB: MOVE.L    #1,D0
          BSR       LINEA
          CMP.L     #0,D0
          BEQ       SCAN0
          MOVE.W    $e(A6),D1           * Tamaño a D1
          CMP.L     D1,D0
          BGT       SCAN0
          MOVE.L    $8(A6),D3           * Buffer a D3
          MOVE.L    #0,-8(A6)           * Inicializamos contador
          MOVE.L    D3,-12(A6)          * Guardamos puntero a buffer en marco de pila
          MOVE.L    D0,-4(A6)           * Guardamos tamaño de linea en marco de pila
SBUCB:   MOVE.L    #1,D0		* Seleccionamos buffer de recepcion de B
          BSR       LEECAR              
          MOVE.L    -12(A6),D1          * Puntero a buffer en D1
          MOVE.L    D1,A0               
          MOVE.B    D0,(A0)             * Introducimos el caracter leido en el buffer
          ADD.L     #1,-12(A6)          * Avanzamos el puntero
          ADD.L     #1,-8(A6)           * Aumentamos el contador
          SUB.L     #1,-4(A6)           * Restamos uno al tamaño de linea
          CMP.L     #0,-4(A6)           * Comprobamos si hemos llegado al SCANF
          BNE       SBUCB              * Si no es el SCANF volvemos al bucle
          MOVE.L    -8(A6),D0           * Contador en D0

SCANF:    UNLK      A6                  *Destruccion del marco de pila
          RTS


SCANE:   MOVE.L   #$ffffffff,D0
                UNLK     A6
                RTS

SCAN0:          MOVE.L   #0,D0
                UNLK     A6
		RTS

**************************** FIN SCAN *********************************************************

**************************** PROGRAMA PRINCIPAL ***********************************************

INICIO:	BSR INIT	
	BREAK


**************************** FIN PROGRAMA PRINCIPAL ********************************************


