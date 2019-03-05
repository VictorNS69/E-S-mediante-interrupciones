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
B_R_A:	DS.B	2002	* buffer de recepcion de 2000 bytes
B_T_A:	DS.B	2002	* buffer de transmision de 2000 bytes
B_R_B:	DS.B	2002	* buffer de recepcion de 2000 bytes
B_T_B:	DS.B	2002	* buffer de transmision de 2000 bytes

*** Punteros ***
P_I_R_A:	DC.L	0	* puntero de introduccion a B_R_A
P_E_R_A:	DC.L	0	* puntero de extraccion a B_R_A
P_I_T_A:	DC.L	0	* puntero de introduccion a B_T_A
P_E_T_A:	DC.L	0	* puntero de extraccion a B_T_A
P_I_R_B:	DC.L	0	* puntero de introduccion a B_R_B
P_E_R_B:	DC.L	0	* puntero de extraccion a B_R_B
P_I_T_B:	DC.L	0	* puntero de introduccion a B_T_B
P_E_T_B:	DC.L	0	* puntero de extraccion a B_T_B

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
	MOVE.L		#B_R_A,P_I_R_A
	MOVE.L		#B_R_A,P_E_R_A
	MOVE.L		#B_T_A,P_I_T_A
	MOVE.L		#B_T_A,P_E_T_A
	MOVE.L		#B_R_B,P_I_R_B
	MOVE.L		#B_R_B,P_E_R_B
	MOVE.L		#B_T_B,P_I_T_B
	MOVE.L		#B_T_B,P_E_T_B
	RTS

**************************** FIN INIT *********************************************************

**************************** RTI **************************************************************
RTI:	RTS

**************************** FIN RTI **********************************************************

**************************** LEECAR ***********************************************************
LEECAR:	AND.L		#3,D0			* Se comparan los 3 primeros bits de D0
	CMP.L		#0,D0			* Si es 0 es buffer de recepción de línea A
	BEQ		REC_A			
	CMP.L		#1,D0			* Si es 1 es buffer de recepción de línea B	
	BEQ		REC_B
	CMP.L		#2,D0			* Si es 2 es buffer de transmisión de línea A
	BEQ		TRANS_A
	CMP.L		#3,D0			* Si es 3 es buffer de transmisión de línea B
	BEQ		TRANS_B
REC_A:	BREAK
REC_B:	BREAK
TRANS_A:BREAK
TRANS_B:BREAK

**************************** FIN LEECAR *******************************************************

**************************** ESCCAR ***********************************************************
ESCCAR:	BREAK

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
