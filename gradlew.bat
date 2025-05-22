@rem
@rem Copyright 2015 del autor o autores originales.
@rem
@rem Licenciado bajo la Licencia Apache, Versión 2.0 (la "Licencia");
@rem No puede usar este archivo excepto de conformidad con la Licencia.
@rem Puede obtener una copia de la Licencia en
@rem
@rem https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem A menos que la ley aplicable lo exija o se acuerde por escrito, el software
@rem distribuido bajo la Licencia se distribuye "TAL CUAL",
@rem SIN GARANTÍAS NI CONDICIONES DE NINGÚN TIPO, ni expresas ni implícitas.
@rem Consulte la Licencia para conocer el idioma específico que rige los permisos y las
@rem limitaciones de la Licencia.
@rem

@if "%DEBUG%"=="" @echo off
@rem ##########################################################################
@rem
@rem  Script de inicio de Gradle para Windows
@rem
@rem ##########################################################################

@rem Establecer el ámbito local para las variables con el shell de Windows NT
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%"=="" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%

@rem Resuelva cualquier "." y ".." en APP_HOME para hacerlo más corto.
for %%i in ("%APP_HOME%") do set APP_HOME=%%~fi

@rem Agregue aquí las opciones predeterminadas de la JVM. También puede usar JAVA_OPTS y GRADLE_OPTS para pasar opciones de la JVM a este script.
set DEFAULT_JVM_OPTS="-Xmx64m" "-Xms64m"

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if %ERRORLEVEL% equ 0 goto execute

echo.
echo ERROR: JAVA_HOME no está configurado y no se pudo encontrar ningún comando 'java' en su PATH.
echo.
echo Configure la variable JAVA_HOME en su entorno para que coincida con la
echo ubicación de su instalación de Java.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto execute

echo.
echo ERROR: JAVA_HOME está configurado en un directorio no válido: %JAVA_HOME%
echo.
echo Configure la variable JAVA_HOME en su entorno para que coincida con la
echo ubicación de su instalación de Java.

goto fail

:execute
@rem Configurar la línea de comandos

set CLASSPATH=%APP_HOME%\gradle\wrapper\gradle-wrapper.jar


@rem Ejecuta Gradle
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %GRADLE_OPTS% "-Dorg.gradle.appname=%APP_BASE_NAME%" -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*

:end
@rem Finalizar el ámbito local de las variables con el shell de Windows NT
if %ERRORLEVEL% equ 0 goto mainEnd

:fail
rem ¡Establezca la variable GRADLE_EXIT_CONSOLE si necesita el código de retorno _script_ en lugar de
rem el código de retorno _cmd.exe /c_!
set EXIT_CODE=%ERRORLEVEL%
if %EXIT_CODE% equ 0 set EXIT_CODE=1
if not ""=="%GRADLE_EXIT_CONSOLE%" exit %EXIT_CODE%
exit /b %EXIT_CODE%

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
