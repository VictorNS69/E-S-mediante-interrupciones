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
PIRA:	DC.L	0	* puntero de introduccion a BRA
PERA:	DC.L	0	* puntero de extraccion a BRA
PITA:	DC.L	0	* puntero de introduccion a BTA
PETA:	DC.L	0	* puntero de extraccion a BTA
PIRB:	DC.L	0	* puntero de introduccion a BRB
PERB:	DC.L	0	* puntero de extraccion a BRB
PITB:	DC.L	0	* puntero de introduccion a BTB
PETB:	DC.L	0	* puntero de extraccion a BTB

*** Contadores ***
CONTRA:	DC.W	0	* contador de caracteres BRA
CONTRB:	DC.W	0	* contador de caracteres BRB
CONTTA: DC.W    0	* contador de caracteres BTA
CONTTB: DC.W	0	* contador de caracteres BTB



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
IVR     EQU     $effc09       * de vector de interrupcion

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
	MOVE.L 		#RTI,$100		* Inicio de RTI en tabla de interrupciones H'40*4

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
RTI:	RTS

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

LRECA:	MOVE.L		CONTRA,D2		* D2 = CONTRA (contador)
	MOVE.L		#PERA,A1		* A1 = PERA
	MOVE.L		#PIRA,A2		* A2 = PIRA
	CMP.L		A1,A2			* Si los punteros coinciden miramos tamaño del buffer
	BEQ 		EMCONTRA	
	CMP		#BRA+2000,A2		* Si estamos al final del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		ERESRA	
	BRA		EFINOKRA

LRECB:	

LTRANSA:

LTRANSB:

LRERA:	

LRERB:	

LRETA:

LRETB:	

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
ERECA:	MOVE.L		CONTRA,D2		* D2 = CONTRA (contador)
	MOVE.L		#PERA,A1		* A1 = PERA
	MOVE.L		#PIRA,A2		* A2 = PIRA
	CMP.L		A1,A2			* Si los punteros coinciden miramos tamaño del buffer
	BEQ 		EMCONTRA	
	CMP		#BRA+2000,A2		* Si estamos al final del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		ERESRA	
	BRA		EFINOKRA

*** BUFFER RECEPCION LINEA B ***
ERECB:	MOVE.L		CONTRB,D2		* D2 = CONTRB (contador)
	MOVE.L		#PERB,A1		* A1 = PERB
	MOVE.L		#PIRB,A2		* A2 = PIRB
	CMP.L		A1,A2			* Si los punteros coinciden miramos tamaño del buffer
	BEQ 		EMCONTRB	
	CMP		#BRB+2000,A2		* Si estamos al final del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		ERESRB	
	BRA		EFINOKRB

*** BUFFER TRANSMISION LINEA A ***
ETRANSA:MOVE.L		CONTTA,D2		* D2 = CONTTA (contador)
	MOVE.L		#PETA,A1		* A1 = PETA
	MOVE.L		#PITA,A2		* A2 = PITA
	CMP.L		A1,A2			* Si los punteros coinciden miramos tamaño del buffer
	BEQ 		EMCONTTA	
	CMP		#BTA+2000,A2		* Si estamos al final del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		ERESTA	
	BRA		EFINOKTA

*** BUFFER TRANSMISION LINEA B ***
ETRANSB:MOVE.L		CONTTB,D2		* D2 = CONTTB (contador)
	MOVE.L		#PETB,A1		* A1 = PETB
	MOVE.L		#PITB,A2		* A2 = PITB
	CMP.L		A1,A2			* Si los punteros coinciden miramos tamaño del buffer
	BEQ 		EMCONTTB	
	CMP		#BTB+2000,A2		* Si estamos al final del buffer, apuntamos de nuevo al principio (buffer circular)
	BEQ		ERESTB	
	BRA		EFINOKTB

*************** PUNTERO EN FINAL DE BUFFER ***************
*** RESET PUNTERO EN BUFFER DE RECEPCION A ***
ERESRA:	MOVE.B 		D1,(A2)			* Inserto el caracter en el buffer
	ADD.L		#1,D2			* Aumento el contador de caracteres en el buffer
	MOVE.L		D2,CONTRA
	MOVE.L 		#BRA,PIRA		* Pongo el puntero de introduccion al principio del buffer
	MOVE.L 		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*** RESET PUNTERO EN BUFFER DE RECEPCION B ***
ERESRB:	MOVE.B 		D1,(A2)			* Inserto el caracter en el buffer
	ADD.L		#1,D2			* Aumento el contador de caracteres en el buffer
	MOVE.L		D2,CONTRB
	MOVE.L 		#BRB,PIRB		* Pongo el puntero de introduccion al principio del buffer
	MOVE.L 		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*** RESET PUNTERO EN BUFFER DE TRANSMISION A ***
ERESTA:	MOVE.B 		D1,(A2)			* Inserto el caracter en el buffer
	ADD.L		#1,D2			* Aumento el contador de caracteres en el buffer
	MOVE.L		D2,CONTTA
	MOVE.L 		#BTA,PITA		* Pongo el puntero de introduccion al principio del buffer
	MOVE.L 		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*** RESET PUNTERO EN BUFFER DE TRANSMISION B ***
ERESTB:	MOVE.B 		D1,(A2)			* Inserto el caracter en el buffer
	ADD.L		#1,D2			* Aumento el contador de caracteres en el buffer
	MOVE.L		D2,CONTTB
	MOVE.L 		#BTB,PITB		* Pongo el puntero de introduccion al principio del buffer
	MOVE.L 		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*************** BUFFER LLENO Y FINALES OK ***************
*** MIRAMOS CONTADOR Y FINAL OK EN RECEPCION DE A ***
EMCONTRA:CMP.L		#2000,D2		* Si el buffer esta lleno pongo 0xFFFFFFFF en D0
	BEQ		EFINLLE

EFINOKRA:MOVE.B		D1,(A2)+		* Inserto el caracter en el buffer y apunto a la siguiente posicion
	ADD.L		#1,D2			* Aumento el contador de caracteres en el buffer
	MOVE.L		D2,CONTRA
	MOVE.L 		A2,PIRA			* Actualizo la posicion del puntero de introduccion
	MOVE.L		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*** MIRAMOS CONTADOR Y FINAL OK EN RECEPCION DE B ***
EMCONTRB:CMP.L		#2000,D2		* Si el buffer esta lleno pongo 0xFFFFFFFF en D0
	BEQ		EFINLLE

EFINOKRB:MOVE.B		D1,(A2)+		* Inserto el caracter en el buffer y apunto a la siguiente posicion
	ADD.L		#1,D2			* Aumento el contador de caracteres en el buffer
	MOVE.L		D2,CONTRB
	MOVE.L 		A2,PIRB			* Actualizo la posicion del puntero de introduccion
	MOVE.L		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*** MIRAMOS CONTADOR Y FINAL OK EN TRANSMISION DE A ***
EMCONTTA:CMP.L		#2000,D2		* Si el buffer esta lleno pongo 0xFFFFFFFF en D0
	BEQ		EFINLLE

EFINOKTA:MOVE.B		D1,(A2)+		* Inserto el caracter en el buffer y apunto a la siguiente posicion
	ADD.L		#1,D2			* Aumento el contador de caracteres en el buffer
	MOVE.L		D2,CONTTA
	MOVE.L 		A2,PITA			* Actualizo la posicion del puntero de introduccion
	MOVE.L		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*** MIRAMOS CONTADOR Y FINAL OK EN TRANSMISION DE B ***
EMCONTTB:CMP.L		#2000,D2		* Si el buffer esta lleno pongo 0xFFFFFFFF en D0
	BEQ		EFINLLE

EFINOKTB:MOVE.B		D1,(A2)+		* Inserto el caracter en el buffer y apunto a la siguiente posicion
	ADD.L		#1,D2			* Aumento el contador de caracteres en el buffer
	MOVE.L		D2,CONTTB
	MOVE.L 		A2,PITB			* Actualizo la posicion del puntero de introduccion
	MOVE.L		#0,D0			* D0 = 0 (introduccion correcta)
	RTS

*************** FINAL CON BUFFER LLENO ***************
EFINLLE:MOVE.L		#$FFFFFFFF,D0		* D0 = 0xFFFFFFFF
	RTS


**************************** FIN ESCCAR *******************************************************

**************************** LINEA ************************************************************
LINEA:	BREAK

**************************** FIN LINEA ********************************************************

**************************** PRINT ************************************************************
PRINT:  BREAK

**************************** FIN PRINT ********************************************************

**************************** SCAN *************************************************************
SCAN:   BREAK

**************************** FIN SCAN *********************************************************

**************************** PROGRAMA PRINCIPAL ***********************************************
INICIO: BSR	INIT
	BREAK

**************************** FIN PROGRAMA PRINCIPAL *******************************************
