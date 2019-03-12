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
BRA:	DS.B	2001	* buffer de recepcion de 2000 bytes
BTA:	DS.B	2001	* buffer de transmision de 2000 bytes
BRB:	DS.B	2001	* buffer de recepcion de 2000 bytes
BTB:	DS.B	2001	* buffer de transmision de 2000 bytes

*** Punteros ***
PIRA:	DC.L	0	* puntero de introduccion a BRA
PERA:	DC.L	0	* puntero de extraccion a BRA
PITA:	DC.L	0	* puntero de introduccion a BTA
PETA:	DC.L	0	* puntero de extraccion a BTA
PIRB:	DC.L	0	* puntero de introduccion a BRB
PERB:	DC.L	0	* puntero de extraccion a BRB
PITB:	DC.L	0	* puntero de introduccion a BTB
PETB:	DC.L	0	* puntero de extraccion a BTB

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

LRECA:	MOVE.L		#PIRA,A1		* A1 = Puntero a PIRA
	MOVE.L		#PERA,A2		* A2 = Puntero a PERA
	CMP.L		A1,A2			* Ambos punteros apuntan al mismo lugar, luego lista vacia
	BEQ		LFINVAC
	CMP		#BRA+2000,A2		* Si llegamos al final del buffer, asignamos de nuevo el puntero al principio
	BEQ		LRERA
	MOVE.L		(A2)+,D0
	RTS

LRECB:	MOVE.L		#PIRB,A1		* A1 = Puntero a PIRB
	MOVE.L		#PERB,A2		* A2 = puntero a PERB
	CMP.L		A1,A2			* Ambos punteros apuntan al mismo lugar, luego lista vacia
	BEQ		LFINVAC
	CMP		#BRB+2000,A2		* Si llegamos al final del buffer, asignamos de nuevo el puntero al principio
	BEQ		LRERB
	MOVE.L		(A2)+,D0
	RTS

LTRANSA:MOVE.L		#PITA,A1		* A1 = Puntero a PITA
	MOVE.L		#PETA,A2		* A2 = puntero a PETA
	CMP.L		A1,A2			* Ambos punteros apuntan al mismo lugar, luego lista vacia
	BEQ		LFINVAC
	CMP		#BTA+2000,A2		* Si llegamos al final del buffer, asignamos de nuevo el puntero al principio
	BEQ		LRETA
	MOVE.L		(A2)+,D0
	RTS

LTRANSB:MOVE.L		#PITB,A1		* A1 = Puntero a PITB
	MOVE.L		#PETB,A2		* A2 = puntero a PETB
	CMP.L		A1,A2			* Ambos punteros apuntan al mismo lugar, luego lista vacia
	BEQ		LFINVAC
	CMP		#BTB+2000,A2		* Si llegamos al final del buffer, asignamos de nuevo el puntero al principio
	BEQ		LRETB
	MOVE.L		(A2)+,D0
	RTS

LRERA:	MOVE.L		A2,D0			* D0 = dato y avanzamos puntero
	MOVE.L		#BRA,A2
	RTS

LRERB:	MOVE.L		A2,D0			* D0 = dato y avanzamos puntero
	MOVE.L		#BRB,A2
	RTS

LRETA:	MOVE.L		A2,D0			* D0 = dato y avanzamos puntero
	MOVE.L		#BTA,A2
	RTS

LRETB:	MOVE.L		A2,D0			* D0 = dato y avanzamos puntero
	MOVE.L		#BTB,A2
	RTS

LFINVAC:	MOVE.L		#$FFFFFFFF,D0		* D0 = 0xFFFFFFFF
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

ERECA:	MOVE.L		#PIRA,A1		* A1 = Puntero a PIRA
	MOVE.L		#,A3		* A3 = Puntero a PIRA auxiliar
	MOVE.L		#PERA,A2		* A2 = puntero a PERA
	CMP.L		#BRB+2001,$1(A3)
	BLE				
	RTS

ERECB:	MOVE.L		#PIRB,A1		* A1 = Puntero a PIRB
	MOVE.L		#PERB,A2		* A2 = puntero a PERB
	CMP.L		A1,A2			* Ambos punteros apuntan al mismo lugar, luego lista vacia
	BEQ		EFINVAC
	CMP		#BRB+2001,A2		* Si llegamos al final del buffer, asignamos de nuevo el puntero al principio
	BEQ		ERERB
	MOVE.L		(A2)+,D0
	RTS

ETRANSA:MOVE.L		#PITA,A1		* A1 = Puntero a PITA
	MOVE.L		#PETA,A2		* A2 = puntero a PETA
	CMP.L		A1,A2			* Ambos punteros apuntan al mismo lugar, luego lista vacia
	BEQ		EFINVAC
	CMP		#BRB+2001,A2		* Si llegamos al final del buffer, asignamos de nuevo el puntero al principio
	BEQ		ERETA
	MOVE.L		(A2)+,D0
	RTS

ETRANSB:MOVE.L		#PITB,A1		* A1 = Puntero a PITB
	MOVE.L		#PETB,A2		* A2 = puntero a PETB
	CMP.L		A1,A2			* Ambos punteros apuntan al mismo lugar, luego lista vacia
	BEQ		EFINVAC
	CMP		#BRB+2001,A2		* Si llegamos al final del buffer, asignamos de nuevo el puntero al principio
	BEQ		ERETB
	MOVE.L		(A2)+,D0
	RTS

ERERA:	MOVE.L		A2,D0			* D0 = dato y avanzamos puntero
	MOVE.L		#BRA,A2
	RTS

ERERB:	MOVE.L		A2,D0			* D0 = dato y avanzamos puntero
	MOVE.L		#BRB,A2
	RTS

ERETA:	MOVE.L		A2,D0			* D0 = dato y avanzamos puntero
	MOVE.L		#BTA,A2
	RTS

ERETB:	MOVE.L		A2,D0			* D0 = dato y avanzamos puntero
	MOVE.L		#BTB,A2
	RTS

EFINVAC:MOVE.L		#$FFFFFFFF,D0		* D0 = 0xFFFFFFFF
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
