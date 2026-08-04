---
title: Guía de migración de Thymeleaf 3 en diez minutos
---


¿Eres usuario de Thymeleaf 2 y quieres probar la nueva versión **Thymeleaf 3.0**?

Tenemos buenas noticias: tus plantillas de Thymeleaf actuales son casi 100% 
compatibles con Thymeleaf 3, así que solo tendrás que hacer algunas 
modificaciones en tu configuración.

Veamos rápidamente los nuevos conceptos y características más importantes que 
trae esta versión:


Cambios en la plantilla
----------------

El único cambio que *recomendamos* hacer en tus plantillas es eliminar cualquier 
atributo `th:inline="text"` que puedas tener, ya que ya no son necesarios para 
que las expresiones de salida se inserten en línea en las plantillas HTML o XML. 
Y es solo una recomendación; las plantillas funcionarán de todos modos. Sin 
embargo, te beneficiarás de un mejor rendimiento de procesamiento si los 
eliminas.

Consulta más información al respecto en la sección *Mecanismo de inserción en línea mejorado*.


Cambios de configuración
---------------------

Veamos un ejemplo de configuración de Thymeleaf 3 utilizando el paquete de 
integración *thymeleaf-spring4* y la configuración Java, ya que es la opción más 
común entre los usuarios de Thymeleaf.

Primero, las dependencias Maven actualizadas para obtener Thymeleaf 3 (core):

```xml
<dependency>
  <groupId>org.thymeleaf</groupId>
  <artifactId>thymeleaf</artifactId>
  <version>3.0.0.RELEASE</version>
</dependency>
```

Y el paquete de integración Spring 4 (que podría ser todo lo que necesita en una 
aplicación Spring):

```xml
<dependency>
  <groupId>org.thymeleaf</groupId>
  <artifactId>thymeleaf-spring4</artifactId>
  <version>3.0.0.RELEASE</version>
</dependency>
```

En segundo lugar, la configuración de Spring:

```java
@Configuration
@EnableWebMvc
@ComponentScan("com.thymeleafexamples")
public class ThymeleafConfig extends WebMvcConfigurerAdapter implements ApplicationContextAware {

  private ApplicationContext applicationContext;

  public void setApplicationContext(ApplicationContext applicationContext) {
    this.applicationContext = applicationContext;
  }

  @Bean
  public ViewResolver viewResolver() {
    ThymeleafViewResolver resolver = new ThymeleafViewResolver();
    resolver.setTemplateEngine(templateEngine());
    resolver.setCharacterEncoding("UTF-8");
    return resolver;
  }

  @Bean
  public TemplateEngine templateEngine() {
    SpringTemplateEngine engine = new SpringTemplateEngine();
    engine.setEnableSpringELCompiler(true);
    engine.setTemplateResolver(templateResolver());
    return engine;
  }

  private ITemplateResolver templateResolver() {
    SpringResourceTemplateResolver resolver = new SpringResourceTemplateResolver();
    resolver.setApplicationContext(applicationContext);
    resolver.setPrefix("/WEB-INF/templates/");
    resolver.setTemplateMode(TemplateMode.HTML);
    return resolver;
  }
}
```

La primera diferencia con la configuración de Thymeleaf 2 es que ahora el 
resolvedor de plantillas recomendado para aplicaciones Spring es 
`SpringResourceTemplateResolver`. Este necesita una referencia al 
`ApplicationContext` de Spring, por lo que el bean de configuración debe 
implementar la interfaz `ApplicationContextAware`.

La segunda diferencia es que el modo de plantilla tiene un valor de 
`TemplateMode.HTML`. Los modos de plantilla ya no son cadenas de texto y los 
valores posibles son ligeramente diferentes a los de Thymeleaf 2. Lo veremos en 
breve.

Si necesita agregar dialectos adicionales, puede usar el método 
`engine.addDialect(...)`, pero primero asegúrese de que ya exista una versión 
compatible con Thymeleaf 3.

Puedes consultar y descargar el código fuente de ejemplos sencillos de 
"¡Hola Mundo!" en [Thymeleaf 3 + Spring 4 + ejemplo de configuración Java](https://github.com/jmiguelsamper/thymeleaf3-spring-helloworld), 
[Thymeleaf 3 + Spring 4 + ejemplo de configuración XML](https://github.com/jmiguelsamper/thymeleaf3-spring-xml-helloworld) y 
[Thymeleaf 3 + ejemplo de Servlet 3](https://github.com/jmiguelsamper/thymeleaf3-servlet-helloworld).

También encontrarás información adicional (enlaces a binarios y documentación 
Javadoc) en [el anuncio de Thymeleaf 3.0.0.BETA03](http://forum.thymeleaf.org/Thymeleaf-3-0-0-BETA03-just-published-td4029622.html).


Compatibilidad total con el marcado HTML5
-------------------------

Thymeleaf 3.0 ya no se basa en XML gracias a su nuevo sistema de análisis, por 
lo que ya no es necesario escribir código HTML válido para XML (aunque seguimos 
recomendándolo por motivos de legibilidad). En modo HTML, Thymeleaf es mucho más 
permisivo con las etiquetas de cierre, los atributos entre comillas, etc.

Así pues, esta es una plantilla de Thymeleaf perfectamente procesable (aunque algo fea):

```html
<div><p th:text=${mytext} ng-app>Lo que sea
```

Para obtener una explicación del nuevo sistema de análisis, consulte 
[Compatibilidad total con HTML5, nueva infraestructura de análisis](https://github.com/thymeleaf/thymeleaf/issues/390).


Modos de plantilla
--------------

Thymeleaf 3 reemplaza el conjunto de modos de plantilla de las versiones 
anteriores. Los nuevos modos de plantilla son:

 - `HTML`
 - `XML`
 - `TEXT`
 - `JAVASCRIPT`
 - `CSS`
 - `RAW`

Existen dos modos de plantilla de *marcado* (`HTML` y `XML`), tres modos de 
plantilla de *texto* (`TEXT`, `JAVASCRIPT` y `CSS`) y un modo de plantilla *sin 
operación* (`RAW`).

El modo de plantilla `HTML` admite cualquier tipo de marcado HTML, incluyendo 
**HTML5**, HTML4 y XHTML. No se realiza ninguna validación de marcado ni 
comprobación de corrección de formato, y la estructura del código del marcado de 
la plantilla se respeta en la mayor medida posible en la salida.

Para obtener una explicación detallada de los diferentes modos de plantilla, 
consulte [Conjunto de modos de plantilla de Thymeleaf 3.0](https://github.com/thymeleaf/thymeleaf/issues/391).

Puede ver un ejemplo sencillo que muestra el funcionamiento de los nuevos modos 
de plantilla en:
[https://github.com/jmiguelsamper/thymeleaf3-template-modes-example](https://github.com/jmiguelsamper/thymeleaf3-template-modes-example).

### Modos de plantilla de texto

Los nuevos modos de plantilla de texto permiten a Thymeleaf generar código 
**CSS**, **JavaScript** y **texto plano**. Esto resulta útil si se desea 
utilizar los valores de variables del servidor en archivos CSS y JavaScript, o 
generar contenido de texto plano, como por ejemplo al redactar un correo 
electrónico.

Para que todas las funciones de Thymeleaf estén disponibles en los modos de 
texto, se ha introducido una nueva sintaxis. Por ejemplo, se puede iterar de la 
siguiente manera:

```text
[# th:each="item : ${items}"]
  - [# th:utext="${item}" /]
[/]
```

Para obtener una explicación completa de esta nueva sintaxis, consulte 
[Nueva sintaxis para los modos de plantillas de texto](https://github.com/thymeleaf/thymeleaf/issues/395).

### Mecanismo de alineación mejorado

A veces resulta útil poder generar datos sin usar etiquetas o atributos 
adicionales, como en:

```html
<p>Este producto se llama [[${product.name}]] ¡Y es genial!</p>
```
Esta funcionalidad, denominada *inlining*, se ha mejorado notablemente y ahora 
cuenta con un soporte mucho mejor en Thymeleaf 3. Consulte 
[Expresiones de salida en línea](https://github.com/thymeleaf/thymeleaf/issues/394) para obtener más detalles.

El mecanismo de inlining existente también se adapta a los nuevos modos de 
plantilla y, de hecho, hace innecesario el atributo `th:inline="text"`, ya que 
el inlining ahora está presente en el propio modo `HTML`. Consulte la discusión 
sobre [Refactorización del mecanismo de inlining](https://github.com/thymeleaf/thymeleaf/issues/396).


Expresiones de fragmentos
--------------------

Thymeleaf 3.0 introduce un nuevo tipo de expresión como parte del sistema general 
de *Expresiones Estándar de Thymeleaf*: *Expresiones de Fragmento*.

Tienen este aspecto: `~{commons::footer}` y, efectivamente, son extremadamente 
similares a la sintaxis que se podía usar dentro de `th:replace` y `th:include` 
(ahora `th:insert`) desde hace tiempo... porque utilizan exactamente *esa* 
sintaxis, pero generalizada para que ahora se pueda usar en otros ámbitos.

¿Cuál es la ventaja? Bueno, en primer lugar, y lo más útil, ahora podemos pasar 
fragmentos de marcado como parámetros a otros fragmentos. Véase `th:replace` a 
continuación:

```html
<head th:replace="base :: common_header(~{::title},~{::link})">
  <title>Impresionante - Principal</title>
  <link rel="stylesheet" th:href="@{/css/bootstrap.min.css}">
  <link rel="stylesheet" th:href="@{/themes/smoothness/jquery-ui.css}">
</head>
```

Ahí le pasamos a nuestro fragmento `common_header` otros dos fragmentos de 
marcado que contienen nuestras etiquetas `<title>` y `<link>`, que luego se 
pueden usar fácilmente en nuestro `common_header`:

```html
<head th:fragment="common_header(title,links)">
  <title th:replace="${title}">La aplicación increíble</title>

  <!-- Estilos comunes y scripts -->
  <link rel="stylesheet" type="text/css" media="all" th:href="@{/css/awesomeapp.css}">
  <link rel="shortcut icon" th:href="@{/images/favicon.ico}">
  <script type="text/javascript" th:src="@{/sh/scripts/codebase.js}"></script>

  <!--/* Espacio reservado por página para enlaces adicionales */-->
  <th:block th:replace="${links}" />
</head>
```

Como puedes ver, gracias a esto, muchas técnicas de **diseño** (o **composición 
de página**) se han simplificado enormemente en Thymeleaf 3.0.

Pero las posibilidades no terminan aquí: podemos usar expresiones de fragmento 
para mucho más, como puedes aprender aquí: [Expresiones de fragmento](https://github.com/thymeleaf/thymeleaf/issues/451).


El token de no operación
----------------------
Otra novedad de las *expresiones estándar de Thymeleaf* 3.0 es el token NO-OP 
(sin operación), representado por un guion bajo (`_`), que básicamente 
significa *"no hacer nada"*.

Usar *"no hacer nada"* como resultado de una expresión es más útil de lo que 
parece a primera vista. Por ejemplo, puede ayudarnos a reducir considerablemente 
la complejidad de nuestro código de plantilla, permitiéndonos usar nuestro 
*código de prototipado* como *valores predeterminados*.

Vea este ejemplo sencillo:

```html
<span th:text="${user.name} ?: _">Ningún usuario autenticado</span>
```
En el código anterior no necesitamos especificar qué se debe mostrar si nuestro 
`user` no tiene nombre: en ese caso, Thymeleaf no hará nada. ¿El resultado? El 
texto que hemos escrito como cuerpo de la etiqueta: `Ningún usuario autenticado`, 
que en este caso también servirá como texto para que nuestra plantilla se vea 
bien, como prototipo y valor predeterminado para `th:text` en caso de que no 
haya ningún usuario autenticado.

Obtén más información sobre esta nueva funcionalidad aquí: [El token NO-OP](https://github.com/thymeleaf/thymeleaf/issues/452).


Lógica de plantillas desacopladas
------------------------

Thymeleaf 3.0 permite el *desacoplamiento* completo (y opcional) de la lógica de 
las plantillas en los modos `HTML` y `XML`, lo que da como resultado plantillas 
100% libres de lógica y sin Thymeleaf.

Ahora, el marcado de un archivo de plantilla `home.html` puede ser tan limpio 
como esto:

```html
<!DOCTYPE html>
<html>
  <body>
    <table id="usersTable">
      <tr>
        <td class="username">Jeremías Pomelo</td>
        <td class="usertype">Usuario normal</td>
      </tr>
      <tr>
        <td class="username">Alicia Sandía</td>
        <td class="usertype">Administradora</td>
      </tr>
    </table>
  </body>
</html>
```

Y lo único que Thymeleaf necesitará para usar ese HTML como plantilla es otro 
archivo a su lado, un `home.th.xml`, con este aspecto:

```xml
<?xml version="1.0"?>
<thlogic>
  <attr sel="#usersTable" th:remove="all-but-first">
    <attr sel="/tr[0]" th:each="user : ${users}">
      <attr sel="td.username" th:text="${user.name}" />
      <attr sel="td.usertype" th:text="#{|user.type.${user.type}|}" />
    </attr>
  </attr>
</thlogic>
```
Esta *lógica desacoplada* especifica los atributos que deben *inyectarse* 
durante el análisis en partes específicas de la plantilla (seleccionadas por los 
*selectores de marcado* en sus atributos `sel`). El resultado será idéntico a 
una plantilla que contuviera dichos atributos desde el principio.

Poder procesar plantillas HTML sin código Thymeleaf incrustado supone una gran 
ventaja al usar archivos HTML puros como artefactos de diseño: ahora, 
diseñadores u otros miembros del equipo pueden crearlos, modificarlos y 
comprenderlos sin necesidad de tener conocimientos de Thymeleaf. Pero eso no es 
todo: también permite procesar como plantillas marcado creado por herramientas o 
sistemas externos sin necesidad de modificarlo.

Para obtener más información, consulte [Lógica de plantillas desacopladas](https://github.com/thymeleaf/thymeleaf/issues/465).


Mejoras en el rendimiento
------------------------

A pesar de todas las nuevas y excelentes características, el principal logro de 
Thymeleaf 3.0 es una **mejora muy significativa en el rendimiento**, un tema 
recurrente en las versiones anteriores.

Hasta la versión 2.1, Thymeleaf, al ser un motor de plantillas basado en XML, 
ofrecía la posibilidad de implementar muchas funciones excelentes, pero a veces 
a costa del rendimiento. Si bien el tiempo de renderizado de Thymeleaf era 
insignificante para la gran mayoría de los proyectos, este inconveniente se hacía 
notar en proyectos con características especiales (por ejemplo, sitios web con 
mucho tráfico que manejan tablas con decenas de miles de filas).

El motor de Thymeleaf 3 se ha reescrito desde cero, centrándose principalmente 
en el rendimiento. Thymeleaf 3 ofrece un rendimiento mucho mejor que las 
versiones anteriores, por lo que esperamos que satisfaga las necesidades de un 
número cada vez mayor de proyectos. Pero el rendimiento de Thymeleaf 3 no se 
limita al tiempo de renderizado: también se ha diseñado específicamente para 
tener un bajo consumo de memoria y ayudar a reducir la latencia en escenarios de 
alta concurrencia.

Para un análisis técnico de la nueva arquitectura de Thymeleaf 3, consulte 
[Nuevo motor de procesamiento de plantillas basado en eventos](https://github.com/thymeleaf/thymeleaf/issues/389).

Pero las mejoras de rendimiento no se limitan al nivel arquitectónico: la versión 
3.0 también incluye algunas *mejoras de rendimiento*, como la posibilidad de 
habilitar el compilador SpringEL (*Spring Expression Language* o *SpEL*), que, 
desde la versión 4.2.4 del Spring Framework, Thymeleaf puede utilizar para 
optimizar el rendimiento del procesamiento de plantillas en entornos Spring. 
Consulte [Configuración del compilador SpringEL](https://github.com/thymeleaf/thymeleaf-spring/issues/95).

Y si no utilizas Spring y, por lo tanto, tu lenguaje de expresiones es OGNL, 
también hemos realizado algunas mejoras de rendimiento en ese aspecto, incluso 
haciendo un par de contribuciones al código fuente de OGNL que deberían 
beneficiar el rendimiento de Thymeleaf en entornos como los basados en el nuevo 
estándar MVC1.0 (JSR371).


Independencia de la API de Servlet
---------------------------------

Las versiones anteriores a Thymeleaf 3.0 ya eran *independientes de la API de 
Java Servlet* en el sentido de que Thymeleaf permitía la *ejecución offline* del 
motor de plantillas, es decir, el procesamiento de plantillas sin que la 
aplicación se ejecutara en un contenedor web. Esto resultaba útil en escenarios 
como el procesamiento de plantillas de correo electrónico.

Sin embargo, Thymeleaf 3.0 incluye una serie de mejoras que permiten que 
Thymeleaf sea verdaderamente independiente de la API de Servlet 
**en entornos web** que no utilizan Java Servlets, como muchos de los frameworks 
*reactivos* disponibles actualmente (más información en la siguiente sección), 
los cuales ahora podrán integrarse con Thymeleaf de una manera más sencilla y 
elegante.

Para obtener más información, consulte: 
[Nuevo punto de extensión: Link Builders](https://github.com/thymeleaf/thymeleaf/issues/458) y 
[Generalización del mecanismo IEngineContext](https://github.com/thymeleaf/thymeleaf/issues/459).


Integración en marcos y arquitecturas reactivas
------------------------------------------------------

*Reactivo* es uno de los términos clave del momento, y las arquitecturas 
reactivas cuentan hoy en día con muchos actores importantes en el ecosistema 
Java, como [vert.x](http://vertx.io/), [RatPack](https://ratpack.io/), 
[Play Framework](https://www.playframework.com/) o el próximo 
[Spring Reactive](https://spring.io/blog/2016/02/09/reactive-spring).

Thymeleaf 3.0 mejora enormemente las posibilidades de integración para estos 
frameworks, no solo al proporcionar una mayor independencia de la API de 
Servlet, como se mencionó anteriormente, sino también mediante una nueva 
funcionalidad llamada [limitación de motor](https://github.com/thymeleaf/thymeleaf/issues/487).

La limitación de recursos del motor permite que Thymeleaf ejecute de forma 
*parcial* y *bajo demanda* las solicitudes de *contrapresión* de los canales de 
salida, enviándoles búferes con la salida de la plantilla. Todo esto se ejecuta 
en un único hilo.

Pero eso no es todo: el nuevo motor Thymeleaf también puede aplicar la 
*limitación de recursos* de forma *basada en datos*, identificando una variable 
de contexto como *emisora* de datos (las implementaciones pueden variar según el 
framework anfitrión) y generando una salida parcial en respuesta a los eventos 
de publicación de datos provenientes de dicha emisora. Esto convierte a 
Thymeleaf en una forma altamente eficiente de publicar marcado orientado a 
datos y generado reactivamente desde el servidor.


Nuevo sistema de dialectos
------------------

Thymeleaf 3 incluye un sistema de dialectos totalmente nuevo. Si desarrollaste 
un dialecto para una versión anterior de Thymeleaf, tendrás que adaptarlo para 
que sea compatible con Thymeleaf 3.

La nueva interfaz de dialectos es realmente sencilla...

```java
public interface IDialect {

  public String getName();

}
```

...pero puedes añadirle muchas funciones adicionales según las subinterfaces 
específicas de `IDialect` que implementes.

Destacemos algunas mejoras del nuevo sistema de dialectos:

- No solo existen *procesadores*, sino también *preprocesadores* y 
  *postprocesadores*, por lo que el contenido de la plantilla se puede modificar 
  antes y después de su procesamiento. Por ejemplo, podríamos usar un preprocesador 
  para servir contenido en caché o un postprocesador para minimizar y comprimir 
  la salida.
- La *precedencia de dialectos* es un concepto nuevo que permite ordenar los 
  procesadores entre dialectos. Ahora, la precedencia de los procesadores se 
  considera relativa a la precedencia de dialectos, de modo que cada procesador 
  de un dialecto específico se puede configurar para que se ejecute antes que 
  cualquier procesador de un dialecto diferente, simplemente estableciendo los 
  valores correctos para dicha precedencia.
- Los *dialectos de objetos de expresión* proporcionan nuevos objetos de 
  expresión u objetos de utilidad de expresión que se pueden usar en expresiones 
  en cualquier parte de las plantillas, como `#strings`, `#numbers`, `#dates`, 
  etc., proporcionados por el dialecto estándar.

Para obtener una explicación más detallada de estas características, consulte:

 - [Nueva IPA de Dialecto](https://github.com/thymeleaf/thymeleaf/issues/401)
 - [Nuevas IPAs de Preprocesadores y Postprocesadores](https://github.com/thymeleaf/thymeleaf/issues/400)
 - [Nueva IPA de Procesador](https://github.com/thymeleaf/thymeleaf/issues/399)


Refactorización de las API principales
----------------------------

Las API principales se han refactorizado profundamente. Para más detalles, 
consulta los siguientes problemas:

- [Refactorización de la IPA de resolución de plantillas](https://github.com/thymeleaf/thymeleaf/issues/419)
- [Refactorización de la IPA de contexto](https://github.com/thymeleaf/thymeleaf/issues/420)
- [Refactorización de la IPA de resolución de mensajes](https://github.com/thymeleaf/thymeleaf/issues/421)


Reflexiones finales
--------------

Thymeleaf 3 representa un gran logro para el proyecto Thymeleaf Template Engine 
tras cuatro años de existencia y muchísimas horas de arduo trabajo. Incluye 
nuevas funciones fantásticas y numerosas mejoras internas.

Esperamos que se adapte mejor a las necesidades de tus proyectos. ¡No dudes en 
probarlo y enviarnos tus comentarios!
