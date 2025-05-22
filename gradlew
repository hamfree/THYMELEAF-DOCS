#!/bin/sh

#
# Copyright © 2015-2021, autores originales.
#
# Licenciado bajo la Licencia Apache, Versión 2.0 (la "Licencia");
# No puede usar este archivo excepto de conformidad con la Licencia.
# Puede obtener una copia de la Licencia en
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# A menos que la ley aplicable lo exija o se acuerde por escrito, el software
# distribuido bajo la Licencia se distribuye "TAL CUAL",
# SIN GARANTÍAS NI CONDICIONES DE NINGÚN TIPO, ni expresas ni implícitas.
# Consulte la Licencia para conocer el idioma específico que rige los permisos y las
# limitaciones de la Licencia.
#

################################################################################
#
#   Script de inicio de Gradle para POSIX generado por Gradle.
#
#   Importante para la ejecución:
#
#   (1) Necesita una shell compatible con POSIX para ejecutar este script. Si su
#       /bin/sh no es compatible, pero tiene otra shell compatible, como ksh o
#       bash, para ejecutar este script, escriba el nombre de esa shell antes de
#       la línea de comandos, como:
#
#         ksh Gradle
#
#       Busybox y shells reducidas similares NO funcionarán, ya que este script
#       requiere todas estas características de la shell POSIX:
#         * funciones;
#         * expansiones «$var», «${var}», «${var:-default}», «${var+SET}»,
#           «${var#prefix}», «${var%suffix}» y «$( cmd )»;
#         * comandos compuestos con un estado de salida comprobable,
#           especialmente «case»;
#         * varios comandos integrados, incluyendo «command», «set» y «ulimit».
#
#   Importante para la aplicación de parches:
#
#   (2) Este script se dirige a cualquier shell POSIX, por lo que evita las
#       extensiones proporcionadas por Bash, Ksh, etc.; en particular, se evitan
#       los arrays.
#
#       La práctica "tradicional" de empaquetar múltiples parámetros en una
#       cadena separada por espacios es una fuente bien documentada de errores y
#       problemas de seguridad, por lo que se evita (en su mayoría) acumulando
#       progresivamente opciones en «$@» y pasándolas finalmente a Java.
#
#       Cuando las variables de entorno heredadas (DEFAULT_JVM_OPTS, JAVA_OPTS y
#       GRADLE_OPTS) dependen de la división de palabras, esta se realiza
#       explícitamente. Consulte los comentarios en línea para obtener más
#       información.
#
#       Existen ajustes para sistemas operativos específicos como AIX, CygWin,
#       Darwin, MinGW y NonStop.
#
#   (3) Este script se genera a partir de la plantilla Groovy
#       https://github.com/gradle/gradle/blob/master/subprojects/plugins/src/main/resources/org/gradle/api/internal/plugins/unixStartScript.txt
#       dentro del proyecto Gradle.
#
#       Puede encontrar Gradle en https://github.com/gradle/gradle/.
#
##############################################################################

# Intentar establecer APP_HOME

# Resolver enlaces: $0 puede ser un enlace
app_path=$0

# Necesita esto para enlaces simbólicos en cadena.
while
    APP_HOME=${app_path%"${app_path##*/}"}  # deja una / final; vacía si no hay una ruta principal
    [ -h "$app_path" ]
do
    ls=$( ls -ld "$app_path" )
    link=${ls#*' -> '}
    case $link in             #(
      /*)   app_path=$link ;; #(
      *)    app_path=$APP_HOME$link ;;
    esac
done

APP_HOME=$( cd "${APP_HOME:-./}" && pwd -P ) || exit

APP_NAME="Gradle"
APP_BASE_NAME=${0##*/}

# Agregue aquí las opciones predeterminadas de la JVM. También puede usar JAVA_OPTS y GRADLE_OPTS para pasar opciones de la JVM a este script.
DEFAULT_JVM_OPTS='"-Xmx64m" "-Xms64m"'

# Utilice el máximo disponible o configure MAX_FD != -1 para usar ese valor.
MAX_FD=maximum

warn () {
    echo "$*"
} >&2

die () {
    echo
    echo "$*"
    echo
    exit 1
} >&2

# Soporte específico del sistema operativo (debe ser 'true' o 'false').
cygwin=false
msys=false
darwin=false
nonstop=false
case "$( uname )" in                #(
  CYGWIN* )         cygwin=true  ;; #(
  Darwin* )         darwin=true  ;; #(
  MSYS* | MINGW* )  msys=true    ;; #(
  NONSTOP* )        nonstop=true ;;
esac

CLASSPATH=$APP_HOME/gradle/wrapper/gradle-wrapper.jar


# Determinar el comando Java a utilizar para iniciar la JVM.
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        # El JDK de IBM en AIX utiliza ubicaciones extrañas para los ejecutables
        JAVACMD=$JAVA_HOME/jre/sh/java
    else
        JAVACMD=$JAVA_HOME/bin/java
    fi
    if [ ! -x "$JAVACMD" ] ; then
        die "ERROR: JAVA_HOME está configurado en un directorio no válido: $JAVA_HOME

Configure la variable JAVA_HOME en su entorno para que coincida con la
ubicación de su instalación de Java."
    fi
else
    JAVACMD=java
    which java >/dev/null 2>&1 || die "ERROR: JAVA_HOME no está configurado y no se encontró ningún comando 'java' en su PATH.

Configure la variable JAVA_HOME en su entorno para que coincida con la ubicación
de su instalación de Java."
fi

# Aumente el máximo de descriptores de archivos si podemos.
if ! "$cygwin" && ! "$darwin" && ! "$nonstop" ; then
    case $MAX_FD in #(
      max*)
        MAX_FD=$( ulimit -H -n ) ||
            warn "No se pudo consultar el límite máximo de descriptores de archivos"
    esac
    case $MAX_FD in  #(
      '' | soft) :;; #(
      *)
        ulimit -n "$MAX_FD" ||
            warn "No se pudo establecer el límite máximo de descriptor de archivo en $MAX_FD"
    esac
fi

# Recopila todos los argumentos para el comando java, apilándolos en orden inverso:
# * argumentos de la línea de comandos
# * el nombre de la clase principal
# * -classpath
# * -D...appname configuración
# * --module-path (solo si es necesario)
# * Variables de entorno DEFAULT_JVM_OPTS, JAVA_OPTS y GRADLE_OPTS.

# Para Cygwin o MSYS, cambie las rutas al formato de Windows antes de ejecutar Java
if "$cygwin" || "$msys" ; then
    APP_HOME=$( cygpath --path --mixed "$APP_HOME" )
    CLASSPATH=$( cygpath --path --mixed "$CLASSPATH" )

    JAVACMD=$( cygpath --unix "$JAVACMD" )

    # Ahora convertimos los argumentos - un truco para limitarnos a /bin/sh
    for arg do
        if
            case $arg in                                #(
              -*)   false ;;                            # No te metas con las opciones #(
              /?*)  t=${arg#/} t=/${t%%/*}              # Parece una ruta de archivo POSIX
                    [ -e "$t" ] ;;                      #(
              *)    false ;;
            esac
        then
            arg=$( cygpath --path --ignore --mixed "$arg" )
        fi
        # Gira la lista de argumentos exactamente tantas veces como el número de
        # argumentos, de modo que cada argumento vuelva a la posición inicial,
        # pero posiblemente modificado.
        #
        # Nota: un bucle `for` captura su lista de iteraciones antes de
        # comenzar, por lo que cambiar los parámetros posicionales aquí no
        # afecta ni al número de iteraciones ni a los valores presentados en
        # `arg`.
        shift                   # elimina el argumento anterior
        set -- "$@" "$arg"      # empuja el reemplzao del argumento
    done
fi

# Recopilar todos los argumentos para el comando java;
#   * $DEFAULT_JVM_OPTS, $JAVA_OPTS y $GRADLE_OPTS pueden contener fragmentos
#     de script de shell, incluyendo comillas y sustituciones de variables, así
#     que colóquelos entre comillas dobles para asegurarse de que se vuelvan a
#     expandir; y
#   * poner todo lo demás entre comillas simples para que no se vuelva a
#     expandir.
set -- \
        "-Dorg.gradle.appname=$APP_BASE_NAME" \
        -classpath "$CLASSPATH" \
        org.gradle.wrapper.GradleWrapperMain \
        "$@"

# Stop when "xargs" is not available.
if ! command -v xargs >/dev/null 2>&1
then
    die "xargs no está disponible"
fi
# Usa "xargs" para analizar argumentos entre comillas.
#
# Con -n1, se genera un argumento por línea, sin comillas ni barras invertidas.
#
# En Bash, podríamos simplemente:
#
#   readarray ARGS < <( xargs -n1 <<<"$var" ) &&
#   set -- "${ARGS[@]}" "$@"
#
# Pero la shell POSIX no tiene matrices ni sustitución de comandos, así que, en
# su lugar,  posprocesamos cada argumento (como una línea de entrada a sed) para
# escapar con una barra invertida cualquier carácter que pueda ser un
# metacarácter de shell, luego usamos eval para revertir ese proceso
# (manteniendo la separación entre argumentos) y encapsular todo en una sola
#  sentencia "set".
#
# Esto, por supuesto, fallará si alguna de estas variables contiene una nueva
# línea o una comilla no coincidente.
#

eval "set -- $(
        printf '%s\n' "$DEFAULT_JVM_OPTS $JAVA_OPTS $GRADLE_OPTS" |
        xargs -n1 |
        sed ' s~[^-[:alnum:]+,./:=@_]~\\&~g; ' |
        tr '\n' ' '
    )" '"$@"'

exec "$JAVACMD" "$@"
