# Proyecto de Arquitectura de Computadores: Sistema de Entrada/Salida curso 18/19
Realización de operaciones de Entrada/Salida en un periférico mediante interrupciones. 

## Autores
[Víctor Nieves Sánchez](https://twitter.com/VictorNS69)

Daniel Morgera Pérez

## Herramientas
La herramienta que se utiliza en la realización de esta práctica es el **simulador del MC68000 bsvc**. Este simulador incluye el programa **ensamblador 68kasm** y el fichero de configuración del computador emulado. 

Las herramientas se encuentran en el paquete comprimido [bsvc-2.1+_Estatica.tar.gz](/bsvc-2.1+_Estatica.tar.gz). 

Es recomendable seguir las instrucciones de instalación.

## Documentación
La [documentación del proyecto](/doc/manual.pdf) incluye los siguientes apartados:

- **Descripción del procesador Motorola MC68000**. Trata el modelo de programación, los modos de direccionamientos disponibles, excepciones e interrupciones y su juego de instrucciones.
- **Controlador de líneas serie MC68681 (DUART)**. Describe el controlador centrándose en el conjunto de puertos de entrada/salida que proporciona.
- **Programa ensamblador 68kasm**. Describe la sintaxis y las pseudoinstrucciones disponibles en el ensamblador 68kasm que se distribuye con el simulador bsvc.
- **Simulador bsvc**. Es un entorno de libre distribución que ejecuta sobre Tcl/tk que simula un procesador MC68000. A este procesador se le puede asociar una DUART MC68681 que controla dos líneas serie.
- **Notas de instalación del Software**.
- **Enunciado del proyecto**.

Además, se incluye una [tabla de correspondencia](/doc/tabla-correspondencia.pdf) entre sentencias ensamblador del _MC88110_ y del _MC68000_.

También hay una [tabla](/doc/tabla ascii .png) con la correspondencía entre carácteres ASCII y hexadecimales.
# Ensamblar y simular
Como se menciona en la [documentación del proyecto](/doc/manual.pdf), es aconsejable seguir los pasos de instalación para que todo funcione correctamente.
- Ensamblar:
```bash
68kasm -l practica.s
```
Lo que producirá un fichero con el listado de ensamblaje llamado _practica.lis_ y, **si no ha habido errores**, un fichero con el código objeto llamado _practica.h68_.
- Carga del computador virtual:
```bash
bsvc /usr/local/bsvc/samples/m68000/practica.setup
```
Esto cargará el fichero de configuración del computador (_practica.setup_).

Es aconsejable copiar o crear un enlace simbolico al archivo _practica.setup_ para que sea más sencillo de llamar 
```bash
bsvc practica.setup
```
Una vez ya en la interfaz, se deberá cargar el fichero objeto **_practica.h68_**.

Si todo ha salido correctamente, deberán abrirse 3 pantallas:
- interfaz bsvc
- ventana puerto A
- ventana puerto B

Para una mayor información sobre el uso de la interfaz, mire la [documentación del proyecto](/doc/manual.pdf).

# Requisitos de las herramientas
- Tener instalado `xterm` y `xtermpipe`
```bash
sudo apt install xterm
sudo apt install xtermpipe
```
- Tener instalada la herramienta `Tcl/Tk`
```bash
sudo apt install tcl
sudo apt install tclsh
```
- Asegurarse de que el directorio `/usr/local/bsvc/bin` está en el _PATH_ escribiendo en el fichero `.bashrc`
```bash
export PATH=$PATH:/usr/local/bsvc/bin
```

# Problemas con las herramientas
Para más información, consulte el apartado correspondiente en el [manual](/doc/manual.pdf).

# Licencia
[Licencia](/LICENSE).
