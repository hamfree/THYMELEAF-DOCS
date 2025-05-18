---
title: 'Tutorial: Usando Thymeleaf'
author: Thymeleaf
version: @documentVersion@
thymeleafVersion: @projectVersion@
---


1 Presentando Thymeleaf
=======================



1.1 ¿Qué es Thymeleaf?
----------------------

Thymeleaf es una biblioteca Java. Es un motor de plantillas XML/XHTML/HTML5 
capaz de aplicar un conjunto de transformaciones a los archivos de plantilla 
para mostrar los datos o el texto generados por sus aplicaciones.

Es más adecuado para servir XHTML/HTML5 en aplicaciones web, pero puede procesar 
cualquier archivo XML, ya sea en aplicaciones web o independientes.

El objetivo principal de Thymeleaf es proporcionar una forma elegante y bien 
estructurada de crear plantillas. Para lograrlo, se basa en etiquetas y 
atributos XML que definen la ejecución de la lógica predefinida en el DOM 
(Modelo de Objetos del Documento), en lugar de escribir explícitamente dicha 
lógica como código dentro de la plantilla.

Su arquitectura permite un procesamiento rápido de plantillas, basándose en el 
almacenamiento en caché inteligente de los archivos analizados para minimizar 
las operaciones de E/S durante la ejecución.

Y por último, pero no menos importante, Thymeleaf se diseñó desde el principio 
teniendo en cuenta los estándares XML y web, lo que permite crear plantillas con 
validación completa si es necesario.



1.2 ¿Qué clase de plantillas puede procesar Thymeleaf?
------------------------------------------------------

De fábrica, Thymeleaf le permite procesar seis tipos de plantillas, cada una de 
las cuales se denomina Modo de plantilla:

 * XML
 * XML válido
 * XHTML
 * XHTML válido
 * HTML5
 * HTML5 heredado

Todos estos modos se refieren a archivos XML bien formados, excepto el modo 
_HTML5 heredado_, que permite procesar archivos HTML5 con características como 
etiquetas independientes (no cerradas), atributos de etiqueta sin valor o sin 
comillas. Para procesar archivos en este modo específico, Thymeleaf primero 
realiza una transformación que convierte los archivos en archivos XML bien 
formados, que siguen siendo HTML5 perfectamente válidos (y, de hecho, son la 
forma recomendada de crear código HTML5). [Dado que XHTML5 es simplemente 
HTML5 en formato XML, servido con el tipo de contenido application/xhtml+xml, 
también podríamos decir que Thymeleaf es compatible con XHTML5].

Tenga en cuenta también que la validación solo está disponible para plantillas 
XML y XHTML.

Sin embargo, estos no son los únicos tipos de plantilla que Thymeleaf puede 
procesar, y el usuario siempre puede definir su propio modo especificando tanto 
la forma de analizar las plantillas en este modo como la de escribir los 
resultados. De esta forma, cualquier elemento que pueda modelarse como un árbol 
DOM (ya sea XML o no) podrá ser procesado eficazmente como plantilla por 
Thymeleaf.



1.3 Dialectos: El dialecto estándar
----------------------------------

Thymeleaf es un motor de plantillas extremadamente extensible (de hecho, debería 
llamarse mejor _framework de motor de plantillas_) que le permite definir 
completamente los nodos DOM que se procesarán en sus plantillas y también cómo 
se procesarán.

Un objeto que aplica alguna lógica a un nodo DOM se llama _procesador_, y un 
conjunto de estos procesadores ---más algunos artefactos extra--- se llama 
dialecto, de los cuales la biblioteca principal de Thymeleaf proporciona uno 
listo para usar llamado _Dialecto estándar_, que debería ser suficiente para las 
necesidades de un gran porcentaje de usuarios.

_El dialecto estándar es el que se describe en este tutorial_. Todos los 
atributos y características sintácticas que aprenderá en las siguientes páginas 
están definidos por este dialecto, incluso si no se menciona explícitamente.

Por supuesto, los usuarios pueden crear sus propios dialectos (incluso 
ampliando el Estándar) si desean definir su propia lógica de procesamiento y 
aprovechar las funciones avanzadas de la biblioteca. Un motor de plantillas 
permite configurar varios dialectos a la vez.

> Los paquetes de integración oficiales thymeleaf-spring3 y thymeleaf-spring4 
> definen un dialecto llamado "SpringStandard Dialect", prácticamente 
> equivalente al Dialecto Estándar, pero con pequeñas adaptaciones para 
> optimizar algunas características de Spring Framework (por ejemplo, usando el 
> lenguaje de expresiones Spring en lugar del OGNL estándar de Thymeleaf). Así 
> que, si usas Spring MVC, no estás perdiendo el tiempo, ya que casi todo lo que 
> aprendas aquí te será útil en tus aplicaciones Spring.

El Dialecto Estándar de Thymeleaf puede procesar plantillas en cualquier modo, 
pero es especialmente adecuado para los modos de plantilla orientados a la web 
(XHTML y HTML5). Además de HTML5, admite y valida específicamente las siguientes 
especificaciones XHTML: _XHTML 1.0 Transitional_, _XHTML 1.0 Strict_, 
_XHTML 1.0 Frameset_ y _XHTML 1.1_.

La mayoría de los procesadores del Dialecto Estándar son _procesadores de 
atributos_. Esto permite a los navegadores mostrar correctamente los archivos de 
plantilla XHTML/HTML5 incluso antes de procesarlos, ya que ignoran los atributos 
adicionales. Por ejemplo, una JSP que utiliza bibliotecas de etiquetas podría 
incluir un fragmento de código que un navegador no puede mostrar directamente, 
como:

```html
<form:inputText name="userName" value="${user.name}" />
```

...el Dialecto Estándar de Thymeleaf nos permitiría lograr la misma 
funcionalidad con:

```html
<input type="text" name="userName" value="James Carrot" th:value="${user.name}" />
```

Que no sólo se mostrará correctamente en los navegadores, sino que también nos 
permitirá (opcionalmente) especificar en él un atributo de valor 
("James Carrot", en este caso) que se mostrará cuando el prototipo se abra 
estáticamente en un navegador, y que será sustituido por el valor resultante de 
la evaluación de `${user.name}` durante el procesamiento de Thymeleaf de la 
plantilla.

Si es necesario, esto permitirá que el diseñador y el desarrollador trabajen en 
el mismo archivo de plantilla y reducirá el esfuerzo necesario para transformar 
un prototipo estático en un archivo de plantilla funcional. Esta capacidad se 
conoce comúnmente como _Plantillas Naturales_.



1.4 Arquitectura general
------------------------

El núcleo de Thymeleaf es un motor de procesado del DOM. Específicamente, usa su 
propia implementación de alto rendimiento del DOM --- no es la IPA estándar del 
DOM--- para la construcción de representaciones en árbol en memoria de sus 
plantillas, sobre las cuales opera más tarde recorriendo sus nodos y ejecutando 
procesardores en ellos que modifican el DOM de acuero a la _configuración_ 
actual y el conjunto de datos que se le pasa a la plantilla para su 
representación ---conocidos como el contexto.

El uso de una representación de plantilla DOM hace que se ajuste muy bien a las 
aplicaciones web porque los documentos web son representados muy a menudoc como 
árboles de objetos (en realida los árboles DOM son la forma en la que los 
navegadores representan las páginas web en memoria). Además, construir sobre la 
idea de que la mayoría de las aplicaciones web usan solo unas pocas docenas de 
plantillas, que estas no son archivos grandes y que no cambian normalmente 
mientras se ejecuta la aplicación, el uso de Thymelea de una caché en memoria de 
de árboles DOM de plantillas le permite ser rápido en entornos de producción, 
porque se necesita muy poca E/S (si existe alguna) para la mayoría de las 
operaciones de procesado de plantilla.

> Si quiere más detalles, más tarde en este tutorial hay un capítulo entero 
> dedicado al tamponado (caching) y a la forma en que Thymeleaf optimiza la 
> memoria y el uso de recursos para unas operaciones más rápidas.

Sin embargo, hay una restricción: esta arquitectura también requiere el uso 
de grandes cantidades de espacio de memoria para cada ejecución de plantilla que 
otras aproximaciones de análisis/procesado de plantillas, lo que significa que 
no debería usar la librería para crear documentos XML grandes de datos (en 
oposición a los documentos web). Como regla general (y siempre dependiendo del 
tamaño de memoria de su MVJ), si está generando archivos XML con tamaños 
alrededor de las decenas de megabytes en una única ejecución de plantilla, 
probablemente no debería estar usando Thymeleaf.

> La razón por la que consideramos esta restricción solo aplica a los archivos de 
> datos XML y no a la web con XHTML/HTML5 es que no debería nunca generar 
> documentos web tan grandes que los navegadores de sus usuarios se bloqueen y/o 
> exploten -- ¡recuerde que estos navegadores también tendrán que crar los árboles 
> DOM de sus páginas!


1.5 Antes de continuar, deberías leer...
------------------------------------------------

Thymeleaf es especialmente adecuado para trabajar con aplicaciones web. Estas 
aplicaciones se basan en una serie de estándares que todos deberían conocer muy 
bien, pero pocos lo hacen, incluso si llevan años trabajando con ellos.

Con la llegada de HTML5, el estado del arte de los estándares web es más confuso 
que nunca... ¿Volveremos de XHTML a HTML? ¿Abandonaremos la sintaxis XML? ¿Por 
qué ya nadie habla de XHTML 2.0?

Antes de continuar con este tutorial, le recomendamos leer el artículo "De HTML 
a HTML (vía HTML)" en el sitio web de Thymeleaf, disponible en:
[http://www.thymeleaf.org/doc/articles/fromhtmltohtmlviahtml.html](http://www.thymeleaf.org/doc/articles/fromhtmltohtmlviahtml.html)



2 La tienda de comestibles virtual Good Thymes
==============================================

El código fuente de los ejemplos que se muestran en este y futuros capítulos de 
esta guía se puede encontrar en el 
[repositorio de GitHub de Good Thymes Virtual Grocery](https://github.com/thymeleaf/thymeleafexamples-gtvg).


2.1 Un sitio web para una tienda de comestibles
-----------------------------------------------

Para explicar mejor los conceptos involucrados en el procesamiento de plantillas 
con Thymeleaf, este tutorial utilizará una aplicación de demostración que puede 
descargar del sitio web del proyecto.

Esta aplicación representa el sitio web de una tienda de comestibles virtual 
imaginaria, y nos proporcionará los escenarios adecuados para ejemplificar 
diversas características de Thymeleaf.

Necesitaremos un conjunto bastante simple de entidades modelo para nuestra 
aplicación: «Productos», que se venden a «Clientes» mediante la creación de 
«Pedidos». También gestionaremos los «Comentarios» sobre estos «Productos».

![Modelo de aplicación de ejemplo](images/usingthymeleaf/gtvg-model.png)

Nuestra pequeña aplicación también tendrá una capa de servicio muy simple, 
compuesta por objetos `Servicio` que contienen métodos como:


```java
public class ProductService {

    ...

    public List<Product> findAll() {
        return ProductRepository.getInstance().findAll();
    }

    public Product findById(Integer id) {
        return ProductRepository.getInstance().findById(id);
    }
    
}
```

Finalmente, en la capa web nuestra aplicación tendrá un filtro que delegará la 
ejecución a comandos habilitados para Thymeleaf dependiendo de la URL de la 
solicitud:

```java
private boolean process(HttpServletRequest request, HttpServletResponse response)
        throws ServletException {
        
    try {
            
        /*
         * Consultar la asignación de controlador/URL y obtener el controlador
         * que procesará la solicitud. Si no hay ningún controlador disponible,
         * devolver falso y permitir que otros filtros/servlets procesen la 
         * solicitud.
         */
        IGTVGController controller = GTVGApplication.resolveControllerForRequest(request);
        if (controller == null) {
            return false;
        }
        /*
         * Obtener la instancia de TemplateEngine.
         */
        TemplateEngine templateEngine = GTVGApplication.getTemplateEngine();
            
        /*
         * Escribe los encabezados de respuesta
         */
        response.setContentType("text/html;charset=UTF-8");
        response.setHeader("Pragma", "no-cache");
        response.setHeader("Cache-Control", "no-cache");
        response.setDateHeader("Expires", 0);

        /*
         * Ejecutar el controlador y la plantilla de vista de proceso,
         * escribir los resultados en el generador de respuestas.
         */
        controller.process(
                request, response, this.servletContext, templateEngine);

        return true;
            
    } catch (Exception e) {
        throw new ServletException(e);
    }
        
}    
```

Este es nuestro interfaz `IGTVGController`:

```java
public interface IGTVGController {

    public void process(
            HttpServletRequest request, HttpServletResponse response,
            ServletContext servletContext, TemplateEngine templateEngine);    
    
}
```

Todo lo que tenemos que hacer ahora es crear implementaciones de la interfaz 
`IGTVGController`, recuperar datos de los servicios y procesar plantillas 
utilizando el objeto `TemplateEngine`.

Al final se verá así:

![Ejemplo de página de inicio de la aplicación](images/usingthymeleaf/gtvg-view.png)

Pero primero veamos cómo se inicializa ese motor de plantillas.



2.2 Creación y configuración del Motor de Plantillas
----------------------------------------------------

El método _process(...)_ en nuestro filtro contenía esta sentencia:

```java
TemplateEngine templateEngine = GTVGApplication.getTemplateEngine();
```

Lo que significa que la clase _GTVGApplication_ está a cargo de crear y 
configurar uno de los objetos más importantes en una aplicación habilitada para 
Thymeleaf: la instancia `TemplateEngine`.

Nuestro objeto `org.thymeleaf.TemplateEngine` se inicializa de la siguiente 
manera:

```java
public class GTVGApplication {
  
    
    ...
    private static TemplateEngine templateEngine;
    ...
    
    
    static {
        ...
        initializeTemplateEngine();
        ...
    }
    
    
    private static void initializeTemplateEngine() {
        
        ServletContextTemplateResolver templateResolver = 
            new ServletContextTemplateResolver();
        // XHTML es el modo predeterminado, pero lo configuramos de todos modos 
        // para una mejor comprensión del código.
        templateResolver.setTemplateMode("XHTML");
        // Esto convertirá "home" a "/WEB-INF/templates/home.html"
        templateResolver.setPrefix("/WEB-INF/templates/");
        templateResolver.setSuffix(".html");
        // Tiempo de vida de la caché de plantillas: 1 h. Si no se configura, 
        // las entradas se almacenarán en caché hasta que LRU las expulse.
        templateResolver.setCacheTTLMs(3600000L);
        
        templateEngine = new TemplateEngine();
        templateEngine.setTemplateResolver(templateResolver);
        
    }
    
    ...

}
```

Por supuesto, hay muchas formas de configurar un objeto `TemplateEngine`, pero 
por ahora estas pocas líneas de código nos enseñarán lo suficiente sobre los 
pasos necesarios.


### El Solucionador de Plantillas (Template Resolver)

Comencemos con el solucionador de plantillas (Template Resolver):

```java
ServletContextTemplateResolver templateResolver = new ServletContextTemplateResolver();
```

Los solucionadores de plantillas son objetos que implementan una interfaz de la 
API de Thymeleaf llamada `org.thymeleaf.templateresolver.ITemplateResolver`:

```java
public interface ITemplateResolver {

    ...
  
    /*
    * Las plantillas se resuelven por el nombre de la cadena (templateProcessingParameters.getTemplateName())
    * Devolverá un valor nulo si este solucionador de plantillas no puede procesar la plantilla.
    */
    public TemplateResolution resolveTemplate(
            TemplateProcessingParameters templateProcessingParameters);

}
```

Estos objetos se encargan de determinar cómo se accederá a nuestras plantillas 
y, en esta aplicación GTVG, la implementación 
`org.thymeleaf.templateresolver.ServletContextTemplateResolver` que estamos 
usando especifica que vamos a recuperar nuestros archivos de plantilla como 
recursos del _Servlet Context_: un objeto `javax.servlet.ServletContext` de toda 
la aplicación que existe en todas las aplicaciones web Java y que resuelve 
recursos considerando la raíz de la aplicación web como la raíz de las rutas de 
recursos.

Pero eso no es todo lo que podemos decir sobre el solucionador de plantillas, ya 
que podemos configurarlo. Primero, el modo de plantilla, uno de los estándar:

```java
templateResolver.setTemplateMode("XHTML");
```

XHTML es el modo de plantilla predeterminado para 
`ServletContextTemplateResolver`, pero es una buena práctica establecerlo de 
todos modos para que nuestro código documente claramente lo que está sucediendo.

```java
templateResolver.setPrefix("/WEB-INF/templates/");
templateResolver.setSuffix(".html");
```

Estos _prefix_ y _suffix_ hacen exactamente lo que parecen: modifican los 
nombres de las plantillas que pasaremos al motor para obtener los nombres de los 
recursos reales que se utilizarán.

Usando esta configuración, el nombre de la plantilla _"product/list"_ 
correspondería a:

```java
servletContext.getResourceAsStream("/WEB-INF/templates/product/list.html")
```
De manera opcional, la cantidad de tiempo que una plantilla analizada que se 
encuentra en caché se considerará válida se puede configurar en el solucionador 
de plantillas mediante la propiedad _cacheTTLMs_:

```java
templateResolver.setCacheTTLMs(3600000L);
```

Por supuesto, una plantilla puede ser expulsada de la memoria caché antes de que 
se alcance ese TTL si se alcanza el tamaño máximo de memoria caché y es la 
entrada más antigua almacenada en caché actualmente.

> El usuario puede definir el comportamiento y el tamaño del caché implementando 
> la interfaz `ICacheManager` o simplemente modificando el objeto 
> `StandardCacheManager` configurado para administrar los cachés de forma 
> predeterminada.

Aprenderemos más sobre los solucionadores de plantillas más adelante. Ahora 
veamos la creación de nuestro objeto Motor de Plantillas.


### El Motor de Plantillas (Template Engine)

Los objetos de Template Engine son de la clase _org.thymeleaf.TemplateEngine_, y 
estas son las líneas que crearon nuestro motor en el ejemplo actual:

```java
templateEngine = new TemplateEngine();
templateEngine.setTemplateResolver(templateResolver);
```

Bastante sencillo, ¿verdad? Solo necesitamos crear una instancia y configurarla 
como solucionador de plantillas.

Un solucionador de plantillas es el único parámetro obligatorio que necesita un 
`TemplateEngine`, aunque, por supuesto, hay muchos otros que se abordarán más 
adelante (solucionadores de mensajes, tamaño de caché, etc.). Por ahora, esto es 
todo lo que necesitamos.

Nuestro motor de plantillas ya está listo y podemos comenzar a crear nuestras 
páginas usando Thymeleaf.




3 Uso de textos
===============



3.1 Una bienvenida en varios idiomas
------------------------------------

Nuestra primera tarea será crear una página de inicio para nuestro sitio de 
comestibles.

La primera versión que escribiremos de esta página será extremadamente sencilla: 
solo un título y un mensaje de bienvenida. Este es nuestro archivo 
`/WEB-INF/templates/home.html`:

```html
<!DOCTYPE html SYSTEM "http://www.thymeleaf.org/dtd/xhtml1-strict-thymeleaf-4.dtd">

<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:th="http://www.thymeleaf.org">

  <head>
    <title>Tienda de comestibles virtual Good Thymes</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" type="text/css" media="all" 
          href="../../css/gtvg.css" th:href="@{/css/gtvg.css}" />
  </head>

  <body>
  
    <p th:text="#{home.welcome}">¡Bienvenido a nuestra tienda de comestibles!</p>
  
  </body>

</html>
```

Lo primero que notará es que este archivo es XHTML y cualquier navegador puede 
mostrarlo correctamente, ya que no incluye etiquetas que no sean XHTML (y los 
navegadores ignoran todos los atributos que no comprenden, como `th:text`). 
Además, los navegadores lo mostrarán en modo estándar (no en modo peculiar), ya 
que tiene una declaración `DOCTYPE` bien formada.


Además, esto también es XHTML _válido_ ^[Tenga en cuenta que, aunque esta 
plantilla es XHTML válido, anteriormente seleccionamos el modo de plantilla 
"XHTML" y no "VALIDXHTML". Por ahora, podemos desactivar la validación, pero no 
queremos que nuestro IDE genere demasiados problemas.], ya que hemos 
especificado una DTD de Thymeleaf que define atributos como `th:text` para que 
sus plantillas se consideren válidas. Además, una vez procesada la plantilla (y 
eliminados todos los atributos `th:*`), Thymeleaf sustituirá automáticamente 
esa declaración de DTD en la cláusula `DOCTYPE` por una declaración estándar 
`XHTML 1.0 Strict` (dejaremos estas funciones de traducción de DTD para un 
capítulo posterior).

También se declara un espacio de nombres thymeleaf para los atributos `th:*`:

```html
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:th="http://www.thymeleaf.org">
```

Tenga en cuenta que, si no nos hubiéramos preocupado en absoluto por la validez 
o la correcta formación de nuestra plantilla, podríamos haber especificado 
simplemente un `XHTML 1.0 Strict DOCTYPE` estándar, sin declaraciones de 
espacios de nombres xmlns:


```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html>

  <head>
    <title>Tienda de comestibles virtual Good Thymes</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" type="text/css" media="all" 
          href="../../css/gtvg.css" th:href="@{/css/gtvg.css}" />
  </head>

  <body>
  
    <p th:text="#{home.welcome}">¡Bienvenido a nuestra tienda de comestibles!</p>
  
  </body>

</html>
```

...y esto aún sería perfectamente procesable por Thymeleaf en el modo XHTML 
(aunque probablemente nuestro IDE nos haría la vida imposible mostrando 
advertencias por todas partes).

Pero ya basta de validación. Ahora, la parte realmente interesante de la 
plantilla: veamos qué hace el atributo `th:text`.


### Usando th:text y externalizando texto

Externalizar texto consiste en extraer fragmentos de código de plantilla de los archivos de plantilla 
para guardarlos en archivos separados específicos (normalmente archivos `.properties`) 
y poder sustituirlos fácilmente por textos equivalentes escritos en otros idiomas (un proceso 
denominado internacionalización o simplemente _i18n_). Los fragmentos de texto externalizados suelen 
denominarse "mensajes".

Los mensajes tiene siempre una clave que los identifica, y Thymeleaf le permite 
especificar que un texto debe corresponder a un mensaje expecífico con la sintaxis `#{...}`: 


```html
<p th:text="#{home.welcome}">¡Bienvenido a nuestra tienda de comestibles!</p>
```

Lo que podemos ver aquí son, de hecho, dos características diferentes del Dialecto Estándar de Thymeleaf:

 * El atributo `th:text`, el cual evalúa su expresión de valor y establece el resultado de esta evaluación como el 
   cuerpo de la etiqueta en la que se encuentra, substituyendo así el texto "¡Bienvenido a nuestra tienda de 
   comestibles!" que vemos en el código. 
 * La expresión `#{home.welcome}`, especificada en la _Sintaxis de Expresión Estándar_, que especifica que el
   texto que utilizará el atributo `th:text` debe ser el mensaje con la clave `home.welcome` correspondiente 
   a la configuración regiional con la que estemos procesando la plantilla.

Ahora bien, ¿dónde está este texto externalizado?

La ubicación del texto externalizado en Thymeleaf es completamente configurable, y dependerá de la implementación 
específica de `org.thymeleaf.messageresolver.IMessageResolver` utilizada. Normalmente, una implementación basada 
en archivos `.properties` será la utilizada, aunque podríamos crear nuestras propias implementaciones si quisiéramos, 
por ejemplo, obtener mensajes de una base de datos.

Sin embargo, no hemos especificado un solucionador de mensajes en nuestro Motor de Plantillas durante la 
inicialización, y eso significa que nuestra aplicación está usando el _Solucionador Estándar de Mensajes_, implementado 
por la clase `org.thymeleaf.messageresolver.StandardMessageResolver`.

Este solucionador estándar de mensajes espera encontrar los mensajes para `/WEB-INF/templates/home.html` en archivos
.properties en la misma carpeta y con el mismo nombre que la plantilla como:


 * `/WEB-INF/templates/home_en.properties` para textos en inglés.
 * `/WEB-INF/templates/home_es.properties` para textos en español.
 * `/WEB-INF/templates/home_pt_BR.properties` para textos en portugués (Brasil).
 * `/WEB-INF/templates/home.properties` para textos predeterminados (si no se coincide con la configuración regional).

Echemos un vistazo a nuestro archivo `home_es.properties`:

```
home.welcome=¡Bienvenido a nuestra tienda de comestibles!
```

Esto es todo lo que necesitamos para hacer que Thymeleaf procese nuestra plantilla. Ahora, creemos nuestro controlador 
de inicio.


### Contextos (Contexts)

Para procesar nuestra plantilla, crearemos una clase `HomeController` que implemente la interfaz `IGTVGController` que 
vimos antes:

```java
public class HomeController implements IGTVGController {

    public void process(
            HttpServletRequest request, HttpServletResponse response,
            ServletContext servletContext, TemplateEngine templateEngine) {
        
        WebContext ctx = 
            new WebContext(request, response, servletContext, request.getLocale());
        templateEngine.process("home", ctx, response.getWriter());
        
    }

}
```

Lo primero que vemos aquí es la creación de un contexto. Un contexto de Thymeleaf es un objeto que implementa la 
interfaz `org.thymeleaf.context.IContext`. Los contextos deben contener todos los datos necesarios para la ejecución 
del motor de plantillas en un mapa de variables, así como la configuración regional que debe utilizarse para los 
mensajes externalizados.

```java
public interface IContext {

    public VariablesMap<String,Object> getVariables();
    public Locale getLocale();
    ...
    
}
```

Hay una extensión especializada de esta interfaz, `org.thymeleaf.context.IWebContext`:

```java
public interface IWebContext extends IContext {
    
    public HttpSerlvetRequest getHttpServletRequest();
    public HttpSession getHttpSession();
    public ServletContext getServletContext();
    
    public VariablesMap<String,String[]> getRequestParameters();
    public VariablesMap<String,Object> getRequestAttributes();
    public VariablesMap<String,Object> getSessionAttributes();
    public VariablesMap<String,Object> getApplicationAttributes();
    
}
```

La biblioteca principal de Thymeleaf ofrece una implementación de cada una de estas interfaces:

 * `org.thymeleaf.context.Context` implementa `IContext`
 * `org.thymeleaf.context.WebContext` implementa `IWebContext`

Como pueden ver en el código del controlador, usaremos `WebContext`. De hecho, es obligatorio, ya que el uso de 
`ServletContextTemplateResolver` requiere un contexto que implemente `IWebContext`.

```java
WebContext ctx = new WebContext(request, servletContext, request.getLocale());
```

Solo se requieren dos de esos tres argumentos del constructor, porque se utilizará la configuración regional 
predeterminada del sistema si no se especifica ninguna (aunque nunca debe permitir que esto suceda en aplicaciones 
reales).

Según la definición de la interfaz, podemos ver que `WebContext` ofrecerá métodos especializados para obtener los 
parámetros de la solicitud y los atributos de la solicitud, la sesión y la aplicación. Pero, de hecho, `WebContext` 
hará algo más que eso:

 * Agrega todos los atributos de la petición al mapa de variables del contexto.
 * Agrega una variable de contexto llamada `param` que contiene todos los parámetros de la petición.
 * Agrega una variable de contexto llamada `session` que contiene todos los atributos de la sesión.
 * Agrega una variable de contexto llamada `application` que contiene todos los atributos del ServletContext.

Justo antes de la ejecución, se establece una variable especial en todos los objetos de contexto 
(implementaciones de `IContext`), incluyendo `Context` y `WebContext`, llamada información de ejecución (`execInfo`). 
Esta variable contiene dos datos que se pueden usar desde las plantillas:

 * El nombre de la plantilla (`${execInfo.templateName}`), el nombre especificado para la ejecución del motor y 
   correspondiente a la plantilla que se está ejecutando.
 * La fecha y hora actuales (`${execInfo.now}`), un objeto `Calendar` correspondiente al momento en que el motor 
   de plantillas inició su ejecución para esta plantilla.


### Ejecución del motor de plantillas

Con nuestro objeto de contexto listo, solo necesitamos ejecutar el motor de plantillas, especificar el nombre de la 
plantilla y el contexto, y pasar el generador de respuestas para que la respuesta se pueda escribir en él:

```java
templateEngine.process("home", ctx, response.getWriter());
```

Veamos los resultados de esto usando la configuración regional española:

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

  <head>
    <title>Good Thymes Virtual Grocery</title>
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
    <link rel="stylesheet" type="text/css" media="all" href="/gtvg/css/gtvg.css" />
  </head>

  <body>
  
    <p>¡Bienvenido a nuestra tienda de comestibles!</p>

  </body>

</html>
```




3.2 Más sobre textos y variables
-------------------------------


### Texto no escapado

La versión más sencilla de nuestra página de inicio parece estar lista ya, pero hay algo en lo que no hemos pensado... 
¿qué pasaría si tuviéramos un mensaje como este?

```java
home.welcome=¡Bienvenido a nuestra <b>fántastica</b> tienda de comestibles!
```

Si ejecutamos esta plantilla como antes, obtendremos:

```html
<p>¡Bienvenido a nuestra &lt;b&gt;fantástica&lt;/b&gt; grocery store!</p>
```

Esto no es exactamente lo que esperábamos, porque nuestra etiqueta `<b>` ha sido escapada y, por lo tanto, se mostrará 
en el navegador.

Este es el comportamiento predeterminado del atributo th:text. Si queremos que Thymeleaf respete nuestras 
etiquetas XHTML y no las escape, tendremos que usar un atributo diferente: `th:utext` (para "texto sin escape").

```html
<p th:utext="#{home.welcome}">¡Bienvenido a nuestra tienda de comestibles!</p>
Esto mostrará nuestro mensaje tal como lo queríamos:
<p>¡Bienvenidos a nuestra <b>fantástica</b> tienda de comestibles!</p>
```


### Uso y visualización de variables

Ahora, añadamos más contenido a nuestra página de inicio. Por ejemplo, podríamos mostrar la fecha debajo del mensaje 
de bienvenida, así:

```
¡Bienvenidos a nuestra fantástica tienda de comestibles!

Hoy es: 12 julio 2010
```

En primer lugar, tendremos que modificar nuestro controlador para que agreguemos esa fecha como variable de contexto:

```java
public void process(
        HttpServletRequest request, HttpServletResponse response,
        ServletContext servletContext, TemplateEngine templateEngine) {
        
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMMM yyyy");
    Calendar cal = Calendar.getInstance();
        
    WebContext ctx = 
        new WebContext(request, response, servletContext, request.getLocale());
    ctx.setVariable("today", dateFormat.format(cal.getTime()));
        
    templateEngine.process("home", ctx, response.getWriter());
      
}
```

Hemos agregado una variable today de tipo `String` a nuestro contexto, y ahora podemos visualizarla en nuestra 
plantilla:

```html
<body>

  <p th:utext="#{home.welcome}">¡Bienvenidos a nuestra fantástica tienda de comestibles!</p>

  <p>Hoy es: <span th:text="${today}">13 febrero 2011</span></p>
  
</body>
```

Como pueden ver, seguimos usando el atributo `th:text` para el trabajo (correcto, ya que queremos sustituir el cuerpo 
de la etiqueta), pero la sintaxis es ligeramente diferente esta vez: en lugar de un valor de expresión `#{...}`, 
usamos uno `${...}`. Este valor de expresión variable contiene una expresión en un lenguaje llamado 
_OGNL (Lenguaje de Navegación de Objetos-Gráficos)_ que se ejecutará en el mapa de variables de contexto.

La expresión `${today}` simplemente significa "obtén la variable llamada today", pero estas expresiones pueden ser 
más complejas (como `${user.name}` para "obtén una variable llamda user, y llama a su método `getName()`).

Existen muchas posibilidades en los valores de los atributos: mensajes, expresiones de variables... y mucho más. El 
próximo capítulo nos mostrará cuáles son todas estas posibilidades.




4 Sintaxis de expresiones estándar
==================================

Haremos una breve pausa en el desarrollo de nuestra tienda virtual de comestibles para aprender sobre una de las partes 
más importantes del dialecto estándar de Thymeleaf: la sintaxis de las expresiones estándar de Thymeleaf.

Ya hemos visto dos tipos de valores de atributo válidos expresados en esta sintaxis: mensaje y expresiones de variable:


```html
<p th:utext="#{home.welcome}">Welcome to our grocery store!</p>

<p>Today is: <span th:text="${today}">13 february 2011</span></p>
```

Pero hay más tipos de valores que aún desconocemos, y más detalles interesantes sobre los que ya conocemos. Primero, 
veamos un breve resumen de las características de las expresiones estándar:

 * Expresiones simples:
    * Expresiones de variables: `${...}`
    * Expresiones de variables de selección: `*{...}`
    * Expresiones de mensajes: `#{...}`
    * Expresiones de enlaces URL: `@{...}`
 * Literales
    * Literales de Texto: `'one text'`, `'Another one!'`,...
    * Literales numéricos: `0`, `34`, `3.0`, `12.3`,...
    * Literales booleanos: `true`, `false`
    * Literal null: `null`
    * Tokens literales: `one`, `sometext`, `main`,...
 * Operaciones de texto: 
    * Concatenación de cadenas: `+`
    * Sustituciones literales: `|The name is ${name}|`
 * Operaciones aritméticas:
    * Operadores binarios: `+`, `-`, `*`, `/`, `%`
    * Signo menos (operador unario): `-`
 * Operaciones booleanas:
    * Operadores binarios: `and`, `or`
    * Negación booleana (operador unario): `!`, `not`
 * Comparaciones e igualdad:
    * Comparadores: `>`, `<`, `>=`, `<=` (`gt`, `lt`, `ge`, `le`)
    * Operadores de igualdad: `==`, `!=` (`eq`, `ne`)
 * Operadores condicionales:
    * If-then: `(if) ? (then)`
    * If-then-else: `(if) ? (then) : (else)`
    * Default: `(value) ?: (defaultvalue)`

Todas estas características se pueden combinar y anidar:

```html
'User is of type ' + (${user.isAdmin()} ? 'Administrator' : (${user.type} ?: 'Unknown'))
```



4.1 Mensajes
------------

Como ya sabemos, las expresiones de mensaje `#{...}` nos permiten vincular esto:

```html
<p th:utext="#{home.welcome}">Welcome to our grocery store!</p>
```

...a esto:

```html
home.welcome=¡Bienvenido a nuestra tienda de comestibles!
```
Pero hay un aspecto que aún no hemos considerado: ¿qué ocurre si el texto del mensaje no es completamente estático? 
¿Qué sucedería si, por ejemplo, nuestra aplicación supiera quién es el usuario que visita el sitio en cualquier momento 
y quisiéramos saludarlo por su nombre?

```html
<p>¡Bienvenido a nuestra tienda de comestibles, John Apricot!</p>
```

Esto significa que necesitaríamos agregar un parámetro a nuestro mensaje. Algo como esto:

```html
home.welcome=¡Bienvenido a nuestra tienda de comestibles, {0}!
```

Los parámetros se especifican de acuerdo con la sintaxis estándar `java.text.MessageFormat`, lo que significa que puede 
agregar formato a números y fechas como se especifica en la documentación de API para esa clase.

Para especificar un valor para nuestro parámetro, y dado un atributo de sesión HTTP llamado `usuario`, tendríamos:

```html
<p th:utext="#{home.welcome(${session.user.name})}">
  Welcome to our grocery store, Sebastian Pepper!
</p>
```

Si es necesario, se pueden especificar varios parámetros, separados por comas. De hecho, la clave del mensaje podría 
provenir de una variable:

```html
<p th:utext="#{${welcomeMsgKey}(${session.user.name})}">
  Welcome to our grocery store, Sebastian Pepper!
</p>
```



4.2 Variables
-------------
Ya mencionamos que las expresiones `${...}` son en realidad expresiones OGNL (Object-Graph Navigation Language) 
ejecutadas en el mapa de variables contenidas en el contexto.

> Para información detallada sobre la sintaxis y capacidades de OGNL, debería leer la Guía del Lenguaje OGNL en:
> [http://commons.apache.org/ognl/](http://commons.apache.org/ognl/)

De la sintaxis de OGNL, sabemos que esto:

```html
<p>Today is: <span th:text="${today}">13 february 2011</span>.</p>
```

...es de hecho equivalente a esto:

```java
ctx.getVariables().get("today");
```

Pero OGNL nos permite crear expresiones mucho más potentes, y así es como funciona esto:

```html
<p th:utext="#{home.welcome(${session.user.name})}">
  Welcome to our grocery store, Sebastian Pepper!
</p>
```

...de hecho obtiene el nombre de usuario ejecutando:

```java
((User) ctx.getVariables().get("session").get("user")).getName();
```

Pero la navegación por métodos getter es solo una de las características de OGNL. Veamos más:

```java
/*
 * Acceso a las propiedades usando el punto (.). Es el equivalente a llamar a los métodos get de la propiedad
 */
${person.father.name}

/*
 * Se puede acceder a las propieades también utilizando los corchetes ([]) y escribiendo el nombre de la propiedad como 
 * una variable o entre comillas simples.
 */
${person['father']['name']}

/*
 * Si el objeto es un mapa, tanto el punto como la sintaxis de corchetes serán equivalemntes a ejecutar una llamada 
 * a un método get(...).
 */
${countriesByCode.ES}
${personsByName['Stephen Zucchini'].age}

/*
 * El acceso indexado a matrices o colecciones también se realiza con corchetes, escribiendo el índice sin comillas.
 */
${personsArray[0].name}

/*
 * Se pueden llamar a los métodos, incluso con argumentos.
 */
${person.createCompleteName()}
${person.createCompleteNameWithSeparator('-')}
```


### Objetos básicos de expresión

Al evaluar las expresiones OGNL en las variables de contexto, algunos objetos se
ponen a disposición de las expresiones para mayor flexibilidad. Estos objetos se 
referenciarán (según el estandar OGNL) comenzando con el símbolo `#`:

 * `#ctx`: el objeto context (el contexto, en español).
 * `#vars:` las variables contenidas en context.
 * `#locale`: la configuración regional de context.
 * `#httpServletRequest`: (solo en Contextos de Web) el objeto 
    `HttpServletRequest`.
 * `#httpSession`: (solo en Contextos de Web) el objeto `HttpSession`.

Así que podemos hacer esto:

```html
Established locale country: <span th:text="${#locale.country}">US</span>.
```

Puede leer la referencia completa de estos objetos en el 
[Apéndice A](#apendice-a-expresión-objetos-basicos).



### Objetos de utilidad de expresión

Además de estos objetos básicos, Thymeleaf nos ofrecerá un conjunto de objetos 
de utilidad que nos ayudarán a realizar tareas comunes en nuestras expresiones.

 * `#dates`: métodos de utilidad para los objetos `java.util.Date`: formateo, 
    extracción de componentes, etc.
 * `#calendars`: análogo a `#dates`, pero para los objetos `java.util.Calendar`.
 * `#numbers`: métodos de utilidad para dar formato a los objetos numéricos.
 * `#strings`: métodos de utilidad para los objetos `String`: contains, 
    startsWith, prepending/appending, etc.
 * `#objects`: métodos de utilidad para todos los objetos en general.
 * `#bools`: métodos de utilidad para la evaluación booleana.
 * `#arrays`: métodos de utilidad para matrices (arrays en inglés).
 * `#lists`: métodos de utilidad para las listas (list en inglés).
 * `#sets`: métodos de utilidad para los conjuntos (sets en inglés).
 * `#maps`: métodos de utilidad para los mapas (maps en inglés).
 * `#aggregates`: Métodos de utilidad para crear agregados en matrices o 
    colecciones.
 * `#messages`: métodos de utilidad para obtener mensajes externalizados dentro 
    de expresiones variables, de la misma manera que se obtendrían utilizando la 
    sintaxis #{...}.
 * `#ids`: Métodos de utilidad para gestionar atributos de identificación que 
    puedan repetirse (por ejemplo, como resultado de una iteración).

Puede comprobar qué funciones se ofrecen para cada uno de estos objetos de 
utilidad en el [Apéndice B](#apendice-b-expresion-objetos-de-utilidad).


### Reformateando las fechas en nuestra página de inicio

Ahora que conocemos estos objetos de utilidad, podemos usarlos para cambiar la 
forma en que mostramos la fecha en nuestra página de inicio. En lugar de hacerlo 
en nuestro `HomeController`:

```java
SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMMM yyyy");
Calendar cal = Calendar.getInstance();

WebContext ctx = new WebContext(request, servletContext, request.getLocale());
ctx.setVariable("today", dateFormat.format(cal.getTime()));

templateEngine.process("home", ctx, response.getWriter());
```

...Podemos hacer precisamente esto:

```java
WebContext ctx = new WebContext(request, servletContext, request.getLocale());
ctx.setVariable("today", Calendar.getInstance());

templateEngine.process("home", ctx, response.getWriter());
```

...y luego realizar el formato de fecha en la propia capa de vista:

```html
<p>
  Hoy es: <span th:text="${#calendars.format(today,'dd MMMM yyyy')}">13 Mayo 2011</span>
</p>
```



4.3 Expresiones en selecciones (sintaxis de asterisco)
------------------------------------------------------

Las expresiones variables no sólo se pueden escribir en expresiones `${...}`, 
sino también en expresiones `*{...}`.

Sin embargo, existe una diferencia importante: la sintaxis de asterisco evalúa 
las expresiones en los objetos seleccionados, en lugar de en todo el mapa de 
variables de contexto. Es decir, mientras no haya ningún objeto seleccionado, 
las sintaxis de dólar y de asterisco hacen exactamente lo mismo.

¿Y qué es esa selección de objetos? Un atributo `th:object`. Usémoslo en nuestra 
página de perfil de usuario (`userprofile.html`):

```html
  <div th:object="${session.user}">
    <p>Nombre: <span th:text="*{firstName}">Sebastian</span>.</p>
    <p>Apellido: <span th:text="*{lastName}">Pepper</span>.</p>
    <p>Nacionalidad: <span th:text="*{nationality}">Saturno</span>.</p>
  </div>
```

Lo cual es exactamente equivalente a:

```html
<div>
  <p>Nombre: <span th:text="${session.user.firstName}">Sebastian</span>.</p>
  <p>Apellido: <span th:text="${session.user.lastName}">Pepper</span>.</p>
  <p>Nacionalidad: <span th:text="${session.user.nationality}">Saturno</span>.</p>
</div>
```

Por supuesto, la sintaxis dólar y asterisco se pueden mezclar:

```html
<div th:object="${session.user}">
  <p>Nombre: <span th:text="*{firstName}">Sebastian</span>.</p>
  <p>Apellido: <span th:text="${session.user.lastName}">Pepper</span>.</p>
  <p>Nacionalidad: <span th:text="*{nationality}">Saturno</span>.</p>
</div>
```

Cuando hay una selección de objetos en su lugar, el objeto seleccionado también 
estará disponible para las expresiones dólares como la variable de expresión 
`#object`:

```html
<div th:object="${session.user}">
  <p>Nombre: <span th:text="${#object.firstName}">Sebastian</span>.</p>
  <p>Apellido: <span th:text="${session.user.lastName}">Pepper</span>.</p>
  <p>Nacionalidad: <span th:text="*{nationality}">Saturno</span>.</p>
</div>
```

Como se dijo, si no se ha realizado ninguna selección de objetos, las sintaxis 
de dólar y asterisco son exactamente equivalentes.

```html
<div>
  <p>Nombre: <span th:text="*{session.user.name}">Sebastian</span>.</p>
  <p>Apellido: <span th:text="*{session.user.surname}">Pepper</span>.</p>
  <p>Nacionalidad: <span th:text="*{session.user.nationality}">Saturno</span>.</p>
</div>
```



4.4 Enlaces a URLs
------------------

Debido a su importancia, las URL son ciudadanos de primera clase en las 
plantillas de aplicaciones web, y el dialecto estándar de Thymeleaf tiene una 
sintaxis especial para ellas, la sintaxis `@`: `@{...}`

Existen diferentes tipos de URL:

 * URLs absolutas, como `http://www.thymeleaf.org`
 * URLs relativas, las cuales pueden ser:
    * relativas a una página, como `user/login.html`
    * relativas al contexto, como `/itemdetails?id=3` (el nombre del contexto en 
      el servidor se agregará automáticamente)
    * relativas al servidor, como `~/billing/processInvoice` (permiten la 
      llamada de URLs en otros contextos (= application) en el mismo servidor).
    * URL relativas al protocolo, como `//code.jquery.com/jquery-2.0.3.min.js`

Thymeleaf puede manejar URL absolutas en cualquier situación, pero para las 
relativas requerirá que utilice un objeto de contexto que implemente la interfaz 
`IWebContext`, que contiene información proveniente de la solicitud HTTP y 
necesaria para crear enlaces relativos.

Usemos esta nueva sintaxis. Conozcamos el atributo `th:href`:

```html
<!-- Producirá 'http://localhost:8080/gtvg/order/details?orderId=3' (mas reescritura) -->
<a href="details.html" 
   th:href="@{http://localhost:8080/gtvg/order/details(orderId=${o.id})}">vista</a>

<!-- Producirá '/gtvg/order/details?orderId=3' (mas reescritura) -->
<a href="details.html" th:href="@{/order/details(orderId=${o.id})}">vista</a>

<!-- Producirá '/gtvg/order/3/details' (mas reescritura) -->
<a href="details.html" th:href="@{/order/{orderId}/details(orderId=${o.id})}">vista</a>
```

Aspectos a tener en cuenta:

* `th:href` es un atributo modificador de atributo: una vez procesado, calculará 
  la URL del enlace que se utilizará y asignará el atributo href de la etiqueta 
  `<a>` a esta URL.
* Se permiten expresiones para los parámetros de URL (como se puede ver en 
  `orderId=${o.id}`). Las operaciones de codificación de URL necesarias también 
  se realizarán automáticamente.
* Si se necesitan varios parámetros, estos se separarán con comas, como 
  `@{/order/process(execId=${execId},execType='FAST')}`.
* También se permiten plantillas de variables en las rutas de URL, como 
  `@{/order/{orderId}/details(orderId=${orderId})}`.
* Las URL relativas que empiezan por `/` (como `/order/details`) se prefijarán 
  automáticamente con el nombre del contexto de la aplicación. * Si las cookies 
  no están habilitadas o aún no se conoce, se podría añadir un sufijo 
  `";jsessionid=..."` a las URL relativas para preservar la sesión. Esto se 
  denomina _Reescritura de URL_, y Thymeleaf permite incorporar filtros de 
  reescritura propios mediante el mecanismo `response.encodeURL(...)` de la API 
  de Servlets para cada URL.
* La etiqueta `th:href` nos permitió (opcionalmente) tener un atributo `href` 
  estático funcional en nuestra plantilla, de modo que los enlaces de la 
  plantilla permanecieran navegables en un navegador al abrirse directamente 
  para fines de prototipado.

Como fue el caso con la sintaxis del mensaje (`#{...}`), las bases de URL 
también pueden ser el resultado de evaluar otra expresión:

```html
<a th:href="@{${url}(orderId=${o.id})}">vista</a>
<a th:href="@{'/details/'+${user.login}(orderId=${o.id})}">vista</a>
```


### Un menú para nuestra página de inicio

Ahora que sabemos cómo crear URL de enlaces, ¿qué tal si agregamos un pequeño 
menú en nuestra página de inicio para algunas de las otras páginas del sitio?

```html
<p>Por favor, seleccione una opción</p>
<ol>
  <li><a href="product/list.html" th:href="@{/product/list}">Lista de Productos</a></li>
  <li><a href="order/list.html" th:href="@{/order/list}">Lista de Pedidos</a></li>
  <li><a href="subscribe.html" th:href="@{/subscribe}">Suscríbete a Nuestro Boletín Informativo</a></li>
  <li><a href="userprofile.html" th:href="@{/userprofile}">Ver Perfil de Usuario</a></li>
</ol>
```


### URLs relativas a la raíz del servidor

Se puede usar una sintaxis adicional para crear URL relativas a la raíz del 
servidor (en lugar de las relativas a la raíz del contexto) para enlazar a 
diferentes contextos en el mismo servidor. Estas URL se especificarán como 
`@{~/path/to/something}`



4.5 Literales
-------------

### Literales de texto

Los literales de texto son cadenas de caracteres entre comillas simples. Pueden 
incluir cualquier carácter, pero las comillas simples que los contienen deben 
escaparse con `\`.

```html
<p>
  Ahora estás viendo un <span th:text="'aplicación web funcional'">archivo de plantilla</span>.
</p>
```

### Literales numéricos

Los literales numéricos se ven exactamente como lo que son: números.

```html
<p>El año es <span th:text="2013">1492</span>.</p>
<p>En dos años, será <span th:text="2013 + 2">1494</span>.</p>
```


### Literales booleanos

Los literales booleano son `true` y `false`. Por ejemplo:

```html
<div th:if="${usuario.esAdmin()} == false"> ...
```

Tenga en cuenta que, en el ejemplo anterior, el `== false` se escribe fuera de 
las llaves, por lo que es Thymeleaf quien se encarga de ello. Si se escribiera 
dentro de las llaves, sería responsabilidad de los motores OGNL/SpringEL:

```html
<div th:if="${usuario.esAdmin() == false}"> ...
```


### El literal null (nulo)

El literal `null` también se puede utilizar:

```html
<div th:if="${variable.algo} == null"> ...
```


### Literales de identificadores (tokens)

Los literales numéricos, booleanos y nulos son de hecho un caso particular de 
_literales de identificadores_.

Estos identificadores permiten simplificar ligeramente las expresiones estándar. 
Funcionan igual que los literales de texto (`'...'`), pero solo admiten letras 
(`A-Z` y `a-z`), números (`0-9`), corchetes (`[` y `]`), puntos (`.`), guiones 
(`-`) y guiones bajos (`_`). Por lo tanto, no se permiten espacios, comas, etc.

¿Lo bueno? Los tokens no necesitan comillas. Así que podemos hacer esto:

```html
<div th:class="content">...</div>
```

en lugar de:

```html
<div th:class="'content'">...</div>
```



4.6 Agregar textos
-----------------

Los textos, sin importar si son literales o el resultado de evaluar expresiones 
variables o de mensajes, se pueden agregar fácilmente usando el operador `+`:

```html
th:text="'El nombre del usuario es ' + ${usuario.nombre}"
```




4.7 Sustituciones de literales
------------------------------

Las sustituciones literales permiten formatear fácilmente cadenas que contienen 
valores de variables sin la necesidad de agregar literales con '...' + '...'`.

Estas sustituciones deben estar rodeadas de barras verticales (`|`), como:

```html
<span th:text="|Bienvenido a nuestra aplicación, ${usuario.nombre}!|">
```

Lo cual en realidad es equivalente a:

```html
<span th:text="'Bienvenido a nuestra aplicación, ' + ${usuario.nombre} + '!'">
```

Las sustituciones literales se pueden combinar con otros tipos de expresiones:

```html
<span th:text="${varuno} + ' ' + |${vardos}, ${vartres}|">
```

**Nota:** Solo se permiten expresiones variables (`${...}`) dentro de las 
sustituciones literales `|...|`. No se permiten otros literales (`'...'`), 
identificadores, booleanos/numéricos, expresiones condicionales, etc.




4.8 Operaciones aritméticas
---------------------------

También están disponibles algunas operaciones aritméticas: `+`, `-`, `*`, `/` 
y `%`.

```html
th:with="esPar=(${prodStat.cuenta} % 2 == 0)"
```

Tenga en cuenta que estos operadores también se pueden aplicar dentro de las 
expresiones de variables OGNL (y en ese caso serán ejecutados por OGNL en lugar 
del motor de expresiones estándar de Thymeleaf):

```html
th:with="esPar=${prodStat.cuenta % 2 == 0}"
```

Tenga en cuenta que existen alias textuales para algunos de estos operadores: 
`div` (`/`), `mod` (`%`).


4.9 Comparadores e igualdad
---------------------------

Los valores de las expresiones se pueden comparar con los símbolos `>`, `<`, 
`>=` y `<=`, como es habitual, y también se pueden usar los operadores `==` y 
`!=` para comprobar la igualdad (o la falta de ella). Tenga en cuenta que XML 
establece que los símbolos `<` y `>` no deben usarse en valores de atributos, 
por lo que deben sustituirse por `&lt;` y `&gt;`.

```html
th:if="${prodStat.count} &gt; 1"
th:text="'El modo de ejecución es ' + ( (${execMode} == 'dev')? 'Desarrollo' : 'Producción')"
```

Tenga en cuenta que existen alias textuales para algunos de estos operadores: 
`gt` (`>`), `lt` (`<`), `ge` (`>=`), `le` (`<=`), `not` (`!`). También 
`eq` (`==`), `neq`/`ne` (`!=`).



4.10 Expresiones condicionales
------------------------------

Las _expresiones condicionales_ están destinadas a evaluar solo una de dos 
expresiones dependiendo del resultado de evaluar una condición (que es en sí 
otra expresión).

Echemos un vistazo a un fragmento de ejemplo (que introduce otro modificador de 
atributo, esta vez `the:class`):

```html
<tr th:class="${fila.par}? 'par' : 'impar'">
  ...
</tr>
```

Las tres partes de una expresión condicional (`condition`, `then` y `else`) son 
en sí mismas expresiones, lo que significa que pueden ser variables (`${...}`, 
`*{...}`), mensajes (`#{...}`), URL (`@{...}`) o literales (`'...'`).

Las expresiones condicionales también se pueden anidar mediante paréntesis:

```html
<tr th:class="${fila.par}? (${fila.primera}? 'primera' : 'par') : 'impar'">
  ...
</tr>
```

Las expresiones else también se pueden omitir, en cuyo caso se devuelve un valor 
nulo si la condición es falsa:

```html
<tr th:class="${fila.par}? 'alt'">
  ...
</tr>
```



4.11 Expresiones predeterminadas (operador Elvis)
-------------------------------------------------

Una _expresión predeterminada_ es un tipo especial de valor condicional sin la 
parte _then_. Equivale al _operador Elvis_, presente en lenguajes como Groovy, y 
permite especificar dos expresiones; la segunda solo se evalúa si la primera 
devuelve un valor nulo.

Veámoslo en acción en nuestra página de perfil de usuario:

```html
<div th:object="${sesion.usuario}">
  ...
  <p>Edad: <span th:text="*{age}?: '(sin edad especificada)'">27</span>.</p>
</div>
```

Como puede ver, el operador es `?:`, y lo usamos aquí para especificar un valor 
predeterminado para un nombre (un valor literal, en este caso) solo si el 
resultado de evaluar `*{age}` es nulo. Por lo tanto, esto equivale a:

```html
<p>Edad: <span th:text="*{age != null}? *{age} : '(sin edad especificada)'">27</span>.</p>
```

Al igual que los valores condicionales, pueden contener expresiones anidadas 
entre paréntesis:

```html
<p>
  Nombre: 
  <span th:text="*{firstName}?: (*{admin}? 'Admin' : #{default.username})">Sebastian</span>
</p>
```



4.12 Preprocesamiento
---------------------

Además de todas estas funcionalidades para el procesamiento de expresiones, 
Thymeleaf nos ofrece la posibilidad de _preprocesar_ expresiones.

¿Y qué es el preprocesamiento? Es una ejecución de las expresiones antes de la 
normal, que permite modificar la expresión que finalmente se ejecutará.

Las expresiones preprocesadas son exactamente como las normales, pero aparecen 
rodeadas por un símbolo de doble guión bajo (como `__${expresion}__`).

Imaginemos que tenemos una entrada i18n `Messages_fr.properties` que contiene 
una expresión OGNL que llama a un método estático específico del lenguaje, como:

```java
article.text=@myapp.translator.Translator@translateToFrench({0})
```

...y un `Messages_es.properties equivalente`:

```java
article.text=@myapp.translator.Translator@translateToSpanish({0})
```

Podemos crear un fragmento de marcado que evalúe una u otra expresión según la 
configuración regional. Para ello, primero seleccionaremos la expresión 
(mediante preprocesamiento) y luego dejaremos que Thymeleaf la ejecute:

```html
<p th:text="${__#{article.text('textVar')}__}">Algún texto aquí...</p>
```

Tenga en cuenta que el paso de preprocesamiento para una configuración regional 
francesa será la creación del siguiente equivalente:

```html
<p th:text="${@myapp.translator.Translator@translateToFrench(textVar)}">Algún texto aquí...</p>
```

La cadena de preprocesamiento `__` se puede escapar en atributos usando `\_\_`.




5 Establecer valores de atributos
=================================

Este capítulo explicará la forma en que podemos establecer (o modificar) valores 
de atributos en nuestras etiquetas de marcado, posiblemente la siguiente 
característica más básica que necesitaremos después de establecer el contenido 
del cuerpo de la etiqueta.



5.1 Establecer el valor de cualquier atributo
---------------------------------------------

Digamos que nuestro sitio web publica un boletín informativo y queremos que 
nuestros usuarios puedan suscribirse a él, por lo que creamos una plantilla 
`/WEB-INF/templates/subscribe.html` con un formulario:

```html
<form action="subscribe.html">
  <fieldset>
    <input type="text" name="email" />
    <input type="submit" value="¡Suscribeme!" />
  </fieldset>
</form>
```

Parece bastante correcto, pero lo cierto es que este archivo se parece más a una 
página XHTML estática que a una plantilla para una aplicación web. En primer 
lugar, el atributo "action" de nuestro formulario enlaza estáticamente al 
archivo de plantilla, lo que impide la reescritura de URLs. En segundo lugar, el 
atributo "value" del botón de envío hace que muestre un texto en inglés, pero 
nos gustaría que estuviera internacionalizado.

Ingrese entonces el atributo `th:attr` y su capacidad para cambiar el valor de 
los atributos de las etiquetas en las que está configurado:

```html
<form action="subscribe.html" th:attr="action=@{/subscribe}">
  <fieldset>
    <input type="text" name="email" />
    <input type="submit" value="¡Suscribeme!" th:attr="value=#{subscribe.submit}"/>
  </fieldset>
</form>
```

El concepto es bastante sencillo: `th:attr` simplemente toma una expresión que 
asigna un valor a un atributo. Tras crear los archivos de controlador y mensajes 
correspondientes, el resultado del procesamiento de este archivo será el 
esperado:

```html
<form action="/gtvg/subscribe">
  <fieldset>
    <input type="text" name="email" />
    <input type="submit" value="¡Suscríbeme!"/>
  </fieldset>
</form>
```

Además de los nuevos valores de atributos, también puedes ver que el nombre del 
contexto de la aplicación se ha prefijado automáticamente a la base de la URL en 
`/gtvg/subscribe`, como se explicó en el capítulo anterior.

¿Pero qué sucede si queremos configurar más de un atributo a la vez? Las reglas 
XML no permiten configurar un atributo dos veces en una etiqueta, por lo que 
`th:attr` tomará una lista de asignaciones separadas por comas, como:

```html
<img src="../../images/gtvglogo.png" 
     th:attr="src=@{/images/gtvglogo.png},title=#{logo},alt=#{logo}" />
```

Dados los archivos de mensajes requeridos, esto generará:

```html
<img src="/gtgv/images/gtvglogo.png" title="Logo de Good Thymes" alt="Logo de Good Thymes" />
```



5.2 Establecer valores para atributos específicos
-------------------------------------------------

By now, you might be thinking that something like:

```html
<input type="submit" value="Subscribe me!" th:attr="value=#{subscribe.submit}"/>
```

...is quite an ugly piece of markup. Specifying an assignment inside an
attribute's value can be very practical, but it is not the most elegant way of
creating templates if you have to do it all the time.

Thymeleaf agrees with you. And that's why in fact `th:attr` is scarcely used in
templates. Normally, you will be using other `th:*` attributes whose task is
setting specific tag attributes (and not just any attribute like `th:attr`).

And which attribute does the Standard Dialect offer us for setting the `value`
attribute of our button? Well, in a rather obvious manner, it's `th:value`. Let's
have a look:

```html
<input type="submit" value="Subscribe me!" th:value="#{subscribe.submit}"/>
```

This looks much better!. Let's try and do the same to the `action` attribute in
the `form` tag:

```html
<form action="subscribe.html" th:action="@{/subscribe}">
```

And do you remember those `th:href` we put in our `home.html` before? They are
exactly this same kind of attributes:

```html
<li><a href="product/list.html" th:href="@{/product/list}">Product List</a></li>
```

There are quite a lot of attributes like these, each of them targeting a
specific XHTML or HTML5 attribute:

|                      |                  |                     |
|:---------------------|:-----------------|:--------------------|
| `th:abbr`            | `th:accept`      | `th:accept-charset` |
| `th:accesskey`       | `th:action`      | `th:align`          |
| `th:alt`             | `th:archive`     | `th:audio`          |
| `th:autocomplete`    | `th:axis`        | `th:background`     |
| `th:bgcolor`         | `th:border`      | `th:cellpadding`    |
| `th:cellspacing`     | `th:challenge`   | `th:charset`        |
| `th:cite`            | `th:class`       | `th:classid`        |
| `th:codebase`        | `th:codetype`    | `th:cols`           |
| `th:colspan`         | `th:compact`     | `th:content`        |
| `th:contenteditable` | `th:contextmenu` | `th:data`           |
| `th:datetime`        | `th:dir`         | `th:draggable`      |
| `th:dropzone`        | `th:enctype`     | `th:for`            |
| `th:form`            | `th:formaction`  | `th:formenctype`    |
| `th:formmethod`      | `th:formtarget`  | `th:frame`          |
| `th:frameborder`     | `th:headers`     | `th:height`         |
| `th:high`            | `th:href`        | `th:hreflang`       |
| `th:hspace`          | `th:http-equiv`  | `th:icon`           |
| `th:id`              | `th:keytype`     | `th:kind`           |
| `th:label`           | `th:lang`        | `th:list`           |
| `th:longdesc`        | `th:low`         | `th:manifest`       |
| `th:marginheight`    | `th:marginwidth` | `th:max`            |
| `th:maxlength`       | `th:media`       | `th:method`         |
| `th:min`             | `th:name`        | `th:optimum`        |
| `th:pattern`         | `th:placeholder` | `th:poster`         |
| `th:preload`         | `th:radiogroup`  | `th:rel`            |
| `th:rev`             | `th:rows`        | `th:rowspan`        |
| `th:rules`           | `th:sandbox`     | `th:scheme`         |
| `th:scope`           | `th:scrolling`   | `th:size`           |
| `th:sizes`           | `th:span`        | `th:spellcheck`     |
| `th:src`             | `th:srclang`     | `th:standby`        |
| `th:start`           | `th:step`        | `th:style`          |
| `th:summary`         | `th:tabindex`    | `th:target`         |
| `th:title`           | `th:type`        | `th:usemap`         |
| `th:value`           | `th:valuetype`   | `th:vspace`         |
| `th:width`           | `th:wrap`        | `th:xmlbase`        |
| `th:xmllang`         | `th:xmlspace`    |                     |


5.3 Establecer más de un valor a la vez
---------------------------------------

There are two rather special attributes called `th:alt-title` and `th:lang-xmllang`
which can be used for setting two attributes to the same value at the same time.
Specifically:

 * `th:alt-title` will set `alt` and `title`. 
 * `th:lang-xmllang` will set `lang` and `xml:lang`.

For our GTVG home page, this will allow us to substitute this:

```html
<img src="../../images/gtvglogo.png" 
     th:attr="src=@{/images/gtvglogo.png},title=#{logo},alt=#{logo}" />
```

...or this, which is equivalent:

```html
<img src="../../images/gtvglogo.png" 
     th:src="@{/images/gtvglogo.png}" th:title="#{logo}" th:alt="#{logo}" />
```

...by this:

```html
<img src="../../images/gtvglogo.png" 
     th:src="@{/images/gtvglogo.png}" th:alt-title="#{logo}" />
```



5.4 Anexar y anteponer
----------------------

Working in an equivalent way to `th:attr`, Thymeleaf offers the `th:attrappend`
and `th:attrprepend` attributes, which append (suffix) or prepend (prefix) the
result of their evaluation to the existing attribute values.

For example, you might want to store the name of a CSS class to be added (not
set, just added) to one of your buttons in a context variable, because the
specific CSS class to be used would depend on something that the user did before.
Easy:

```html
<input type="button" value="Do it!" class="btn" th:attrappend="class=${' ' + cssStyle}" />
```

If you process this template with the `cssStyle` variable set to `"warning"`,
you will get:

```html
<input type="button" value="Do it!" class="btn warning" />
```

There are also two specific _appending attributes_ in the Standard Dialect: the `th:classappend`
and `th:styleappend` attributes, which are used for adding a CSS class or a fragment of _style_ to an element without
overwriting the existing ones:

```html
<tr th:each="prod : ${prods}" class="row" th:classappend="${prodStat.odd}? 'odd'">
```

(Don't worry about that `th:each` attribute. It is an _iterating attribute_ and
we will talk about it later.)



5.5 Atributos booleanos de valor fijo
-------------------------------------

Some XHTML/HTML5 attributes are special in that, either they are present in
their elements with a specific and fixed value, or they are not present at all.

For example, `checked`:

```html
<input type="checkbox" name="option1" checked="checked" />
<input type="checkbox" name="option2" />
```

No other value than `"checked"` is allowed according to the XHTML standards for
the `checked` attribute (HTML5 rules are a little more relaxed on that). And the
same happens with `disabled`, `multiple`, `readonly` and `selected`.

The Standard Dialect includes attributes that allow you to set these attributes
by evaluating a condition, so that if evaluated to true, the attribute will be
set to its fixed value, and if evaluated to false, the attribute will not be set:

```html
<input type="checkbox" name="active" th:checked="${user.active}" />
```

The following fixed-value boolean attributes exist in the Standard Dialect:

|     Fixed-value     |    boolean     |   Attributes    |
|:-------------------:|:--------------:|:---------------:|
|     `th:async`      | `th:autofocus` |  `th:autoplay`  |
|    `th:checked`     | `th:controls`  |  `th:declare`   |
|    `th:default`     |   `th:defer`   |  `th:disabled`  |
| `th:formnovalidate` |  `th:hidden`   |   `th:ismap`    |
|      `th:loop`      | `th:multiple`  | `th:novalidate` |
|     `th:nowrap`     |   `th:open`    |  `th:pubdate`   |
|    `th:readonly`    | `th:required`  |  `th:reversed`  |
|     `th:scoped`     | `th:seamless`  |  `th:selected`  |


5.6 Compatibilidad con nombres de elementos y atributos compatibles con HTML5
-----------------------------------------------------------------------------

It is also possible to use a completely different syntax to apply processors to your templates, more HTML5-friendly.

```html	
<table>
    <tr data-th-each="user : ${users}">
        <td data-th-text="${user.login}">...</td>
        <td data-th-text="${user.name}">...</td>
    </tr>
</table>
```

The `data-{prefix}-{name}` syntax is the standard way to write custom attributes in HTML5, without requiring developers to use any namespaced names like `th:*`. Thymeleaf makes this syntax automatically available to all your dialects (not only the Standard ones).

There is also a syntax to specify custom tags: `{prefix}-{name}`, which follows the _W3C Custom Elements specification_ (a part of the larger _W3C Web Components spec_). This can be used, for example, for the `th:block` element (or also `th-block`), which will be explained in a later section. 

**Important:** this syntax is an addition to the namespaced `th:*` one, it does not replace it. There is no intention at all to deprecate the namespaced syntax in the future. 




6 Iteration
===========

So far we have created a home page, a user profile page and also a page for
letting users subscribe to our newsletter... but what about our products?
Shouldn't we build a product list to let visitors know what we sell? Well,
obviously yes. And there we go now.



6.1 Iteration basics
--------------------

For listing our products in our `/WEB-INF/templates/product/list.html` page we
will need a table. Each of our products will be displayed in a row (a `<tr>`
element), and so for our template we will need to create a _template row_ ---one
that will exemplify how we want each product to be displayed--- and then instruct
Thymeleaf to _iterate it_ once for each product.

The Standard Dialect offers us an attribute for exactly that, `th:each`.


### Using th:each

For our product list page, we will need a controller that retrieves the list of
products from the service layer and adds it to the template context:

```java
public void process(
        HttpServletRequest request, HttpServletResponse response,
        ServletContext servletContext, TemplateEngine templateEngine) {

    ProductService productService = new ProductService();
    List<Product> allProducts = productService.findAll(); 

    WebContext ctx = new WebContext(request, servletContext, request.getLocale());
    ctx.setVariable("prods", allProducts);

    templateEngine.process("product/list", ctx, response.getWriter());
}
```

And then we will use `th:each` in our template to iterate the list of products:

```html
<!DOCTYPE html SYSTEM "http://www.thymeleaf.org/dtd/xhtml1-strict-thymeleaf-4.dtd">

<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:th="http://www.thymeleaf.org">

  <head>
    <title>Good Thymes Virtual Grocery</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" type="text/css" media="all" 
          href="../../../css/gtvg.css" th:href="@{/css/gtvg.css}" />
  </head>

  <body>

    <h1>Product list</h1>
  
    <table>
      <tr>
        <th>NAME</th>
        <th>PRICE</th>
        <th>IN STOCK</th>
      </tr>
      <tr th:each="prod : ${prods}">
        <td th:text="${prod.name}">Onions</td>
        <td th:text="${prod.price}">2.41</td>
        <td th:text="${prod.inStock}? #{true} : #{false}">yes</td>
      </tr>
    </table>
  
    <p>
      <a href="../home.html" th:href="@{/}">Return to home</a>
    </p>

  </body>

</html>
```

That `prod : ${prods}` attribute value you see above means "for each element in
the result of evaluating `${prods}`, repeat this fragment of template setting
that element into a variable called prod". Let's give a name each of the things
we see:

 * We will call `${prods}` the _iterated expression_ or _iterated variable_.
 * We will call `prod` the _iteration variable_ or simply _iter variable_.

Note that the `prod` iter variable will only be available inside the `<tr>`
element (including inner tags like `<td>`).


### Iterable values

Not only `java.util.List` objects can be used for iteration in Thymeleaf. In
fact, there is a quite complete set of objects that are considered _iterable_
by a `th:each` attribute:

 * Any object implementing `java.util.Iterable`
 * Any object implementing `java.util.Map`. When iterating maps, iter variables
   will be of class `java.util.Map.Entry`.
 * Any array
 * Any other object will be treated as if it were a single-valued list
   containing the object itself.



6.2 Keeping iteration status
----------------------------

When using `th:each,` Thymeleaf offers a mechanism useful for keeping track of
the status of your iteration: the _status variable_.

Status variables are defined within a `th:each` attribute and contain the
following data:

 * The current _iteration index_, starting with 0. This is the `index` property.
 * The current _iteration index_, starting with 1. This is the `count` property.
 * The total amount of elements in the iterated variable. This is the `size`
   property.
 * The _iter variable_ for each iteration. This is the `current` property.
 * Whether the current iteration is even or odd. These are the `even/odd` boolean
   properties.
 * Whether the current iteration is the first one. This is the `first` boolean
   property.
 * Whether the current iteration is the last one. This is the `last` boolean
   property.

Let's see how we could use it within the previous example:

```html
<table>
  <tr>
    <th>NAME</th>
    <th>PRICE</th>
    <th>IN STOCK</th>
  </tr>
  <tr th:each="prod,iterStat : ${prods}" th:class="${iterStat.odd}? 'odd'">
    <td th:text="${prod.name}">Onions</td>
    <td th:text="${prod.price}">2.41</td>
    <td th:text="${prod.inStock}? #{true} : #{false}">yes</td>
  </tr>
</table>
```

As you can see, the status variable (`iterStat` in this example) is defined in
the `th:each` attribute by writing its name after the iter variable itself,
separated by a comma. As happens to the iter variable, the status variable will
only be available inside the fragment of code defined by the tag holding the `th:each`
attribute.

Let's have a look at the result of processing our template:

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

  <head>
    <title>Good Thymes Virtual Grocery</title>
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
    <link rel="stylesheet" type="text/css" media="all" href="/gtvg/css/gtvg.css" />
  </head>

  <body>

    <h1>Product list</h1>
  
    <table>
      <tr>
        <th colspan="1" rowspan="1">NAME</th>
        <th colspan="1" rowspan="1">PRICE</th>
        <th colspan="1" rowspan="1">IN STOCK</th>
      </tr>
      <tr>
        <td colspan="1" rowspan="1">Fresh Sweet Basil</td>
        <td colspan="1" rowspan="1">4.99</td>
        <td colspan="1" rowspan="1">yes</td>
      </tr>
      <tr class="odd">
        <td colspan="1" rowspan="1">Italian Tomato</td>
        <td colspan="1" rowspan="1">1.25</td>
        <td colspan="1" rowspan="1">no</td>
      </tr>
      <tr>
        <td colspan="1" rowspan="1">Yellow Bell Pepper</td>
        <td colspan="1" rowspan="1">2.50</td>
        <td colspan="1" rowspan="1">yes</td>
      </tr>
      <tr class="odd">
        <td colspan="1" rowspan="1">Old Cheddar</td>
        <td colspan="1" rowspan="1">18.75</td>
        <td colspan="1" rowspan="1">yes</td>
      </tr>
    </table>
  
    <p>
      <a href="/gtvg/" shape="rect">Return to home</a>
    </p>

  </body>
  
</html>
```

Note that our iteration status variable has worked perfectly, establishing the
`odd` CSS class only to odd rows (row counting starts with 0).

> All those colspan and rowspan attributes in the `<td>` tags, as well as the
> shape one in `<a>` are automatically added by Thymeleaf in accordance with the
> DTD for the selected _XHTML 1.0 Strict_ standard, that establishes those
> values as default for those attributes (remember that our template didn't set a value for them). Don't worry about them at all, because they will not affect the display of your page. As an example, if we were using HTML5 (which has no DTD), those attributes would never be added.

If you don't explicitly set a status variable, Thymeleaf will always create one
for you by suffixing `Stat` to the name of the iteration variable:

```html
<table>
  <tr>
    <th>NAME</th>
    <th>PRICE</th>
    <th>IN STOCK</th>
  </tr>
  <tr th:each="prod : ${prods}" th:class="${prodStat.odd}? 'odd'">
    <td th:text="${prod.name}">Onions</td>
    <td th:text="${prod.price}">2.41</td>
    <td th:text="${prod.inStock}? #{true} : #{false}">yes</td>
  </tr>
</table>
```




7 Conditional Evaluation
========================



7.1 Simple conditionals: "if" and "unless"
------------------------------------------

Sometimes you will need a fragment of your template only to appear in the result
if a certain condition is met. 

For example, imagine we want to show in our product table a column with the
number of comments that exist for each product and, if there are any comments, a
link to the comment detail page for that product.

In order to do this, we would use the `th:if` attribute:

```html
<table>
  <tr>
    <th>NAME</th>
    <th>PRICE</th>
    <th>IN STOCK</th>
    <th>COMMENTS</th>
  </tr>
  <tr th:each="prod : ${prods}" th:class="${prodStat.odd}? 'odd'">
    <td th:text="${prod.name}">Onions</td>
    <td th:text="${prod.price}">2.41</td>
    <td th:text="${prod.inStock}? #{true} : #{false}">yes</td>
    <td>
      <span th:text="${#lists.size(prod.comments)}">2</span> comment/s
      <a href="comments.html" 
         th:href="@{/product/comments(prodId=${prod.id})}" 
         th:if="${not #lists.isEmpty(prod.comments)}">view</a>
    </td>
  </tr>
</table>
```

Quite a lot of things to see here, so let's focus on the important line:

```html
<a href="comments.html"
   th:href="@{/product/comments(prodId=${prod.id})}" 
   th:if="${not #lists.isEmpty(prod.comments)}">view</a>
```

There is little to explain from this code, in fact: We will be creating a link
to the comments page (with URL `/product/comments`) with a `prodId` parameter
set to the `id` of the product, but only if the product has any comments.

Let's have a look at the resulting markup (getting rid of the defaulted `rowspan`
and `colspan` attributes for a cleaner view):

```html
<table>
  <tr>
    <th>NAME</th>
    <th>PRICE</th>
    <th>IN STOCK</th>
    <th>COMMENTS</th>
  </tr>
  <tr>
    <td>Fresh Sweet Basil</td>
    <td>4.99</td>
    <td>yes</td>
    <td>
      <span>0</span> comment/s
    </td>
  </tr>
  <tr class="odd">
    <td>Italian Tomato</td>
    <td>1.25</td>
    <td>no</td>
    <td>
      <span>2</span> comment/s
      <a href="/gtvg/product/comments?prodId=2">view</a>
    </td>
  </tr>
  <tr>
    <td>Yellow Bell Pepper</td>
    <td>2.50</td>
    <td>yes</td>
    <td>
      <span>0</span> comment/s
    </td>
  </tr>
  <tr class="odd">
    <td>Old Cheddar</td>
    <td>18.75</td>
    <td>yes</td>
    <td>
      <span>1</span> comment/s
      <a href="/gtvg/product/comments?prodId=4">view</a>
    </td>
  </tr>
</table>
```

Perfect! That's exactly what we wanted.

Note that the `th:if` attribute will not only evaluate _boolean_ conditions.
Its capabilities go a little beyond that, and it will evaluate the specified
expression as `true` following these rules:

 * If value is not null:
    * If value is a boolean and is `true`.
    * If value is a number and is non-zero
    * If value is a character and is non-zero
    * If value is a String and is not "false", "off" or "no"
    * If value is not a boolean, a number, a character or a String.
 * (If value is null, th:if will evaluate to false).

Also, `th:if` has a negative counterpart, `th:unless`, which we could have used
in the previous example instead of using a `not` inside the OGNL expression:

```html
<a href="comments.html"
   th:href="@{/comments(prodId=${prod.id})}" 
   th:unless="${#lists.isEmpty(prod.comments)}">view</a>
```



7.2 Switch statements
---------------------

There is also a way to display content conditionally using the equivalent of a
_switch_ structure in Java: the `th:switch` / `th:case` attribute set.

They work exactly as you would expect:

```html
<div th:switch="${user.role}">
  <p th:case="'admin'">User is an administrator</p>
  <p th:case="#{roles.manager}">User is a manager</p>
</div>
```

Note that as soon as one `th:case` attribute is evaluated as `true`, every other
`th:case` attribute in the same switch context is evaluated as `false`.

The default option is specified as `th:case="*"`:

```html
<div th:switch="${user.role}">
  <p th:case="'admin'">User is an administrator</p>
  <p th:case="#{roles.manager}">User is a manager</p>
  <p th:case="*">User is some other thing</p>
</div>
```




8 Template Layout
=================



8.1 Including template fragments
--------------------------------

### Defining and referencing fragments

We will often want to include in our templates fragments from other templates.
Common uses for this are footers, headers, menus...

In order to do this, Thymeleaf needs us to define the fragments available for
inclusion, which we can do by using the `th:fragment` attribute. 

Now let's say we want to add a standard copyright footer to all our grocery
pages, and for that we define a `/WEB-INF/templates/footer.html` file containing
this code:

```html
<!DOCTYPE html SYSTEM "http://www.thymeleaf.org/dtd/xhtml1-strict-thymeleaf-4.dtd">

<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:th="http://www.thymeleaf.org">

  <body>
  
    <div th:fragment="copy">
      &copy; 2011 The Good Thymes Virtual Grocery
    </div>
  
  </body>
  
</html>
```

The code above defines a fragment called `copy` that we can easily include in
our home page using one of the `th:include` or `th:replace` attributes:

```html
<body>

  ...

  <div th:include="footer :: copy"></div>
  
</body>
```

The syntax for both these inclusion attributes is quite straightforward. There
are three different formats:

 * `"templatename::domselector"` or the equivalent `templatename::[domselector]` Includes the fragment resulting from executing the specified DOM Selector on the template named `templatename`.
    * Note that `domselector` can be a mere fragment name, so you could specify something as simple as `templatename::fragmentname` like in the `footer :: copy` above.

   > DOM Selector syntax is similar to XPath expressions and CSS selectors, see the [Appendix C](#appendix-c-dom-selector-syntax) for more info on this syntax.

 * `"templatename"` Includes the complete template named `templatename`.

   > Note that the template name you use in `th:include`/`th:replace` tags
   > will have to be resolvable by the Template Resolver currently being used by
   > the Template Engine.

 * `::domselector"` or `"this::domselector"` Includes a fragment from the same template.

Both `templatename` and `domselector` in the above examples
can be fully-featured expressions (even conditionals!) like:

```html
<div th:include="footer :: (${user.isAdmin}? #{footer.admin} : #{footer.normaluser})"></div>
```

Fragments can include any `th:* attributes`. These attributes will be evaluated
once the fragment is included into the target template (the one with the `th:include`/`th:replace`
attribute), and they will be able to reference any context variables defined in
this target template.

> A big advantage of this approach to fragments is that you can write your
> fragments' code in pages that are perfectly displayable by a browser, with a
> complete and even validating XHTML structure, while still retaining the
> ability to make Thymeleaf include them into other templates.


### Referencing fragments without `th:fragment`

Besides, thanks to the power of DOM Selectors, we can include fragments that do not use any `th:fragment` attributes. It can even be markup code coming from a different application with no knowledge of Thymeleaf at all:

```html
...
<div id="copy-section">
  &copy; 2011 The Good Thymes Virtual Grocery
</div>
...
```

We can use the fragment above simply referencing it by its `id` attribute, in a similar way to a CSS selector:

```html
<body>

  ...

  <div th:include="footer :: #copy-section"></div>
  
</body>
```



### Difference between `th:include` and `th:replace` 

And what is the difference between `th:include` and `th:replace`? Whereas `th:include`
will include the contents of the fragment into its host tag, `th:replace`
will actually substitute the host tag by the fragment's. So that an HTML5
fragment like this:

```html
<footer th:fragment="copy">
  &copy; 2011 The Good Thymes Virtual Grocery
</footer>
```

...included twice in host `<div>` tags, like this:

```html
<body>

  ...

  <div th:include="footer :: copy"></div>
  <div th:replace="footer :: copy"></div>
  
</body>
```

...will result in:

```html
<body>

  ...

  <div>
    &copy; 2011 The Good Thymes Virtual Grocery
  </div>
  <footer>
    &copy; 2011 The Good Thymes Virtual Grocery
  </footer>
  
</body>
```

The `th:substituteby` attribute can also be used as an alias for `th:replace`, but the latter is recommended. Note that `th:substituteby` might be deprecated in future versions.



8.2 Parameterizable fragment signatures
---------------------------------------

In order to create a more _function-like_ mechanism for the use of template fragments,
fragments defined with `th:fragment` can specify a set of parameters:
	
```html
<div th:fragment="frag (onevar,twovar)">
    <p th:text="${onevar} + ' - ' + ${twovar}">...</p>
</div>
```

This requires the use of one of these two syntaxes to call the fragment from `th:include`, 
`th:replace`:

```html
<div th:include="::frag (${value1},${value2})">...</div>
<div th:include="::frag (onevar=${value1},twovar=${value2})">...</div>
```

Note that order is not important in the last option:

```html
<div th:include="::frag (twovar=${value2},onevar=${value1})">...</div>
```

###Fragment local variables without fragment signature

Even if fragments are defined without signature, like this:

```html	
<div th:fragment="frag">
    ...
</div>
```

We could use the second syntax specified above to call them (and only the second one):

```html	
<div th:include="::frag (onevar=${value1},twovar=${value2})">
```

This would be, in fact, equivalent to a combination of `th:include` and `th:with`:

```html	
<div th:include="::frag" th:with="onevar=${value1},twovar=${value2}">
```

**Note** that this specification of local variables for a fragment ---no matter whether it 
has a signature or not--- does not cause the context to emptied previously to its 
execution. Fragments will still be able to access every context variable being used at the 
calling template like they currently are. 



###th:assert for in-template assertions

The `th:assert` attribute can specify a comma-separated list of expressions which should be
evaluated and produce true for every evaluation, raising an exception if not.

```html
<div th:assert="${onevar},(${twovar} != 43)">...</div>
```

This comes in handy for validating parameters at a fragment signature:

```html
<header th:fragment="contentheader(title)" th:assert="${!#strings.isEmpty(title)}">...</header>
```




8.3 Removing template fragments
-------------------------------

Let's revisit the last version of our product list template:

```html
<table>
  <tr>
    <th>NAME</th>
    <th>PRICE</th>
    <th>IN STOCK</th>
    <th>COMMENTS</th>
  </tr>
  <tr th:each="prod : ${prods}" th:class="${prodStat.odd}? 'odd'">
    <td th:text="${prod.name}">Onions</td>
    <td th:text="${prod.price}">2.41</td>
    <td th:text="${prod.inStock}? #{true} : #{false}">yes</td>
    <td>
      <span th:text="${#lists.size(prod.comments)}">2</span> comment/s
      <a href="comments.html" 
         th:href="@{/product/comments(prodId=${prod.id})}" 
         th:unless="${#lists.isEmpty(prod.comments)}">view</a>
    </td>
  </tr>
</table>
```

This code is just fine as a template, but as a static page (when directly open
by a browser without Thymeleaf processing it) it would not make a nice prototype. 

Why? Because although perfectly displayable by browsers, that table only has a
row, and this row has mock data. As a prototype, it simply wouldn't look
realistic enough... we should have more than one product, _we need more rows_.

So let's add some:

```html
<table>
  <tr>
    <th>NAME</th>
    <th>PRICE</th>
    <th>IN STOCK</th>
    <th>COMMENTS</th>
  </tr>
  <tr th:each="prod : ${prods}" th:class="${prodStat.odd}? 'odd'">
    <td th:text="${prod.name}">Onions</td>
    <td th:text="${prod.price}">2.41</td>
    <td th:text="${prod.inStock}? #{true} : #{false}">yes</td>
    <td>
      <span th:text="${#lists.size(prod.comments)}">2</span> comment/s
      <a href="comments.html" 
         th:href="@{/product/comments(prodId=${prod.id})}" 
         th:unless="${#lists.isEmpty(prod.comments)}">view</a>
    </td>
  </tr>
  <tr class="odd">
    <td>Blue Lettuce</td>
    <td>9.55</td>
    <td>no</td>
    <td>
      <span>0</span> comment/s
    </td>
  </tr>
  <tr>
    <td>Mild Cinnamon</td>
    <td>1.99</td>
    <td>yes</td>
    <td>
      <span>3</span> comment/s
      <a href="comments.html">view</a>
    </td>
  </tr>
</table>
```

Ok, now we have three, definitely better for a prototype. But... what will
happen when we process it with Thymeleaf?:

```html
<table>
  <tr>
    <th>NAME</th>
    <th>PRICE</th>
    <th>IN STOCK</th>
    <th>COMMENTS</th>
  </tr>
  <tr>
    <td>Fresh Sweet Basil</td>
    <td>4.99</td>
    <td>yes</td>
    <td>
      <span>0</span> comment/s
    </td>
  </tr>
  <tr class="odd">
    <td>Italian Tomato</td>
    <td>1.25</td>
    <td>no</td>
    <td>
      <span>2</span> comment/s
      <a href="/gtvg/product/comments?prodId=2">view</a>
    </td>
  </tr>
  <tr>
    <td>Yellow Bell Pepper</td>
    <td>2.50</td>
    <td>yes</td>
    <td>
      <span>0</span> comment/s
    </td>
  </tr>
  <tr class="odd">
    <td>Old Cheddar</td>
    <td>18.75</td>
    <td>yes</td>
    <td>
      <span>1</span> comment/s
      <a href="/gtvg/product/comments?prodId=4">view</a>
    </td>
  </tr>
  <tr class="odd">
    <td>Blue Lettuce</td>
    <td>9.55</td>
    <td>no</td>
    <td>
      <span>0</span> comment/s
    </td>
  </tr>
  <tr>
    <td>Mild Cinnamon</td>
    <td>1.99</td>
    <td>yes</td>
    <td>
      <span>3</span> comment/s
      <a href="comments.html">view</a>
    </td>
  </tr>
</table>
```

The last two rows are mock rows! Well, of course they are: iteration was only
applied to the first row, so there is no reason why Thymeleaf should have
removed the other two.

We need a way to remove those two rows during template processing. Let's use the
`th:remove` attribute on the second and third `<tr>` tags:

```html
<table>
  <tr>
    <th>NAME</th>
    <th>PRICE</th>
    <th>IN STOCK</th>
    <th>COMMENTS</th>
  </tr>
  <tr th:each="prod : ${prods}" th:class="${prodStat.odd}? 'odd'">
    <td th:text="${prod.name}">Onions</td>
    <td th:text="${prod.price}">2.41</td>
    <td th:text="${prod.inStock}? #{true} : #{false}">yes</td>
    <td>
      <span th:text="${#lists.size(prod.comments)}">2</span> comment/s
      <a href="comments.html" 
         th:href="@{/product/comments(prodId=${prod.id})}" 
         th:unless="${#lists.isEmpty(prod.comments)}">view</a>
    </td>
  </tr>
  <tr class="odd" th:remove="all">
    <td>Blue Lettuce</td>
    <td>9.55</td>
    <td>no</td>
    <td>
      <span>0</span> comment/s
    </td>
  </tr>
  <tr th:remove="all">
    <td>Mild Cinnamon</td>
    <td>1.99</td>
    <td>yes</td>
    <td>
      <span>3</span> comment/s
      <a href="comments.html">view</a>
    </td>
  </tr>
</table>
```

Once processed, everything will look again as it should:

```html
<table>
  <tr>
    <th>NAME</th>
    <th>PRICE</th>
    <th>IN STOCK</th>
    <th>COMMENTS</th>
  </tr>
  <tr>
    <td>Fresh Sweet Basil</td>
    <td>4.99</td>
    <td>yes</td>
    <td>
      <span>0</span> comment/s
    </td>
  </tr>
  <tr class="odd">
    <td>Italian Tomato</td>
    <td>1.25</td>
    <td>no</td>
    <td>
      <span>2</span> comment/s
      <a href="/gtvg/product/comments?prodId=2">view</a>
    </td>
  </tr>
  <tr>
    <td>Yellow Bell Pepper</td>
    <td>2.50</td>
    <td>yes</td>
    <td>
      <span>0</span> comment/s
    </td>
  </tr>
  <tr class="odd">
    <td>Old Cheddar</td>
    <td>18.75</td>
    <td>yes</td>
    <td>
      <span>1</span> comment/s
      <a href="/gtvg/product/comments?prodId=4">view</a>
    </td>
  </tr>
</table>
```

And what about that `all` value in the attribute, what does it mean? Well, in fact
`th:remove` can behave in five different ways, depending on its value:

 * `all`: Remove both the containing tag and all its children.
 * `body`: Do not remove the containing tag, but remove all its children.
 * `tag`: Remove the containing tag, but do not remove its children.
 * `all-but-first`: Remove all children of the containing tag except the first one.
 * `none` : Do nothing. This value is useful for dynamic evaluation.

What can that `all-but-first` value be useful for? It will let us save some `th:remove="all"`
when prototyping:

```html
<table>
  <thead>
    <tr>
      <th>NAME</th>
      <th>PRICE</th>
      <th>IN STOCK</th>
      <th>COMMENTS</th>
    </tr>
  </thead>
  <tbody th:remove="all-but-first">
    <tr th:each="prod : ${prods}" th:class="${prodStat.odd}? 'odd'">
      <td th:text="${prod.name}">Onions</td>
      <td th:text="${prod.price}">2.41</td>
      <td th:text="${prod.inStock}? #{true} : #{false}">yes</td>
      <td>
        <span th:text="${#lists.size(prod.comments)}">2</span> comment/s
        <a href="comments.html" 
           th:href="@{/product/comments(prodId=${prod.id})}" 
           th:unless="${#lists.isEmpty(prod.comments)}">view</a>
      </td>
    </tr>
    <tr class="odd">
      <td>Blue Lettuce</td>
      <td>9.55</td>
      <td>no</td>
      <td>
        <span>0</span> comment/s
      </td>
    </tr>
    <tr>
      <td>Mild Cinnamon</td>
      <td>1.99</td>
      <td>yes</td>
      <td>
        <span>3</span> comment/s
        <a href="comments.html">view</a>
      </td>
    </tr>
  </tbody>
</table>
```

The `th:remove` attribute can take any _Thymeleaf Standard Expression_, as long as it returns one 
of the allowed String values (`all`, `tag`, `body`, `all-but-first` or `none`).

This means removals could be conditional, like:

```html
<a href="/something" th:remove="${condition}? tag : none">Link text not to be removed</a>
```

Also note that `th:remove` considers `null` a synonym to `none`, so that the following works
exactly as the example above:

```html
<a href="/something" th:remove="${condition}? tag">Link text not to be removed</a>
```

In this case, if `${condition}` is false, `null` will be returned, and thus no removal will be performed. 




9 Local Variables
=================

Thymeleaf calls _local variables_ those variables that are defined for a
specific fragment of a template, and are only available for evaluation inside
that fragment.

An example we have already seen is the `prod` iter variable in our product list
page:

```html
<tr th:each="prod : ${prods}">
    ...
</tr>
```

That `prod` variable will be available only within the bonds of the `<tr>` tag.
Specifically:

 * It will be available for any other `th:*` attributes executing in that tag
   with less _precedence_ than `th:each` (which means they will execute after `th:each`).
 * It will be available for any child element of the `<tr>` tag, such as `<td>`
   elements.

Thymeleaf offers you a way to declare local variables without iteration. It is
the `th:with` attribute, and its syntax is like that of attribute value
assignments:

```html
<div th:with="firstPer=${persons[0]}">
  <p>
    The name of the first person is <span th:text="${firstPer.name}">Julius Caesar</span>.
  </p>
</div>
```

When `th:with` is processed, that `firstPer` variable is created as a local
variable and added to the variables map coming from the context, so that it is
as available for evaluation as any other variables declared in the context from
the beginning, but only within the bounds of the containing `<div>` tag.

You can define several variables at the same time using the usual multiple
assignment syntax:

```html
<div th:with="firstPer=${persons[0]},secondPer=${persons[1]}">
  <p>
    The name of the first person is <span th:text="${firstPer.name}">Julius Caesar</span>.
  </p>
  <p>
    But the name of the second person is 
    <span th:text="${secondPer.name}">Marcus Antonius</span>.
  </p>
</div>
```

The `th:with` attribute allows reusing variables defined in the same attribute:

```html
<div th:with="company=${user.company + ' Co.'},account=${accounts[company]}">...</div>
```

Let's use this in our Grocery's home page! Remember the code we wrote for
outputting a formatted date?

```html
<p>
  Today is: 
  <span th:text="${#calendars.format(today,'dd MMMM yyyy')}">13 february 2011</span>
</p>
```

Well, what if we wanted that `"dd MMMM yyyy"` to actually depend on the locale?
For example, we might want to add the following message to our `home_en.properties`:

```
date.format=MMMM dd'','' yyyy
```

...and an equivalent one to our `home_es.properties`:


```
date.format=dd ''de'' MMMM'','' yyyy
```

Now, let's use `th:with` to get the localized date format into a variable, and
then use it in our `th:text` expression:

```html
<p th:with="df=#{date.format}">
  Today is: <span th:text="${#calendars.format(today,df)}">13 February 2011</span>
</p>
```

That was clean and easy. In fact, given the fact that `th:with` has a higher
`precedence` than `th:text`, we could have solved this all in the `span` tag:

```html
<p>
  Today is: 
  <span th:with="df=#{date.format}" 
        th:text="${#calendars.format(today,df)}">13 February 2011</span>
</p>
```

You might be thinking: Precedence? We haven't talked about that yet! Well, don't
worry because that is exactly what the next chapter is about.




10 Attribute Precedence
=======================

What happens when you write more than one `th:*` attribute in the same tag? For
example:

```html
<ul>
  <li th:each="item : ${items}" th:text="${item.description}">Item description here...</li>
</ul>
```

Of course, we would expect that `th:each` attribute to execute before the `th:text`
so that we get the results we want, but given the fact that the DOM (Document
Object Model) standard does not give any kind of meaning to the order in which
the attributes of a tag are written, a _precedence_ mechanism has to be
established in the attributes themselves in order to be sure that this will work
as expected.

So, all Thymeleaf attributes define a numeric precedence, which establishes the
order in which they are executed in the tag. This order is:

|  Order | Feature                            | Attributes             |
|-------:|:-----------------------------------|:-----------------------|
|      1 | Fragment inclusion                 | `th:include`\          |
|        |                                    | `th:replace`           |
|      2 | Fragment iteration                 | `th:each`              |
|      3 | Conditional evaluation             | `th:if`\               |
|        |                                    | `th:unless`\           |
|        |                                    | `th:switch`\           |
|        |                                    | `th:case`              |
|      4 | Local variable definition          | `th:object`\           |
|        |                                    | `th:with`              |
|      5 | General attribute modification     | `th:attr`\             |
|        |                                    | `th:attrprepend`\      |
|        |                                    | `th:attrappend`        |
|      6 | Specific attribute modification    | `th:value`\            |
|        |                                    | `th:href`\             |
|        |                                    | `th:src`\              |
|        |                                    | `...`                  |
|      7 | Text (tag body modification)       | `th:text`\             |
|        |                                    | `th:utext`             |
|      8 | Fragment specification             | `th:fragment`          |
|      9 | Fragment removal                   | `th:remove`            |


This precedence mechanism means that the above iteration fragment will give
exactly the same results if the attribute position is inverted (although it would be
slightly less readable):

```html
<ul>
  <li th:text="${item.description}" th:each="item : ${items}">Item description here...</li>
</ul>
```



11. Comments and Blocks
=======================

11.1. Standard HTML/XML comments
--------------------------------

Standard HTML/XML comments `<!-- ... -->` can be used anywhere in thymeleaf templates. Anything inside these comments won't be processed by neither Thymeleaf nor the browser, and will be just copied verbatim to the result:

```html
<!-- User info follows -->
<div th:text="${...}">
  ...
</div>
```


11.2. Thymeleaf parser-level comment blocks
-------------------------------------------

Parser-level comment blocks are code that will be simply removed from the template when thymeleaf parses it. They look like this:

```html
<!--/* This code will be removed at thymeleaf parsing time! */-->
``` 

Thymeleaf will remove absolutely everything between `<!--/*` and `*/-->`, so these comment blocks can also be used for displaying code when a template is statically open, knowing that it will be removed when thymeleaf processes it:

```html
<!--/*--> 
  <div>
     you can see me only before thymeleaf processes me!
  </div>
<!--*/-->
```

This might come very handy for prototyping tables with a lot of `<tr>`'s, for example:

```html
<table>
   <tr th:each="x : ${xs}">
     ...
   </tr>
   <!--/*-->
   <tr>
     ...
   </tr>
   <tr>
     ...
   </tr>
   <!--*/-->
</table>
```


11.3. Thymeleaf prototype-only comment blocks
---------------------------------------------

Thymeleaf allows the definition of special comment blocks marked to be comments when the template is open statically (i.e. as a prototype), but considered normal markup by Thymeleaf when executing the template.

```html
<span>hello!</span>
<!--/*/
  <div th:text="${...}">
    ...
  </div>
/*/-->
<span>goodbye!</span>
```

Thymeleaf's parsing system will simply remove the `<!--/*/` and `/*/-->` markers, but not its contents, which will be left therefore uncommented. So when executing the template, Thymeleaf will actually see this:

```html
<span>hello!</span>
 
  <div th:text="${...}">
    ...
  </div>
 
<span>goodbye!</span>
```

As happens with parser-level comment blocks, note that this feature is dialect-independent.


11.4. Synthetic `th:block` tag
------------------------------

Thymeleaf's only element processor (not an attribute) included in the Standard Dialects is `th:block`.

`th:block` is a mere attribute container that allows template developers to specify whichever attributes they want. Thymeleaf will execute these attributes and then simply make the block dissapear without a trace.

So it could be useful, for example, when creating iterated tables that require more than one `<tr>` for each element:

```html
<table>
  <th:block th:each="user : ${users}">
    <tr>
        <td th:text="${user.login}">...</td>
        <td th:text="${user.name}">...</td>
    </tr>
    <tr>
        <td colspan="2" th:text="${user.address}">...</td>
    </tr>
  </th:block>
</table>
```

And especially useful when used in combination with prototype-only comment blocks:

```html
<table>
    <!--/*/ <th:block th:each="user : ${users}"> /*/-->
    <tr>
        <td th:text="${user.login}">...</td>
        <td th:text="${user.name}">...</td>
    </tr>
    <tr>
        <td colspan="2" th:text="${user.address}">...</td>
    </tr>
    <!--/*/ </th:block> /*/-->
</table>
```

Note how this solution allows templates to be valid HTML (no need to add forbidden `<div>` blocks inside `<table>`), and still works OK when open statically in browsers as prototypes! 




12 Inlining
===========



12.1 Text inlining
------------------

Although the Standard Dialect allows us to do almost everything we might need by
using tag attributes, there are situations in which we could prefer writing
expressions directly into our HTML texts. For example, we could prefer writing
this:

```html
<p>Hello, [[${session.user.name}]]!</p>
```

...instead of this:

```html
<p>Hello, <span th:text="${session.user.name}">Sebastian</span>!</p>
```

Expressions between `[[...]]` are considered expression inlining in Thymeleaf,
and in them you can use any kind of expression that would also be valid in a
`th:text` attribute.

In order for inlining to work, we must activate it by using the `th:inline`
attribute, which has three possible values or modes (`text`, `javascript` and `none`).
Let's try `text`:

```html
<p th:inline="text">Hello, [[${session.user.name}]]!</p>
```

The tag holding the `th:inline` does not have to be the one containing the
inlined expression/s, any parent tag would do:

```html
<body th:inline="text">

   ...

   <p>Hello, [[${session.user.name}]]!</p>

   ...

</body>
```

So you might now be asking: _Why aren't we doing this from the beginning? It's
less code than all those_ `th:text` _attributes!_ Well, be careful there,
because although you might find inlining quite interesting, you should always
remember that inlined expressions will be displayed verbatim in your HTML files
when you open them statically, so you probably won't be able to use them as
prototypes anymore!

The difference between how a browser would statically display our fragment of
code without using inlining...

```html
Hello, Sebastian!
```

...and using it...

```html
Hello, [[${session.user.name}]]!
```

...is quite clear.



12.2 Script inlining (JavaScript and Dart)
------------------------------------------

Thymeleaf offers a series of "scripting" modes for its inlining capabilities, so
that you can integrate your data inside scripts created in some script languages.

Current scripting modes are `javascript` (`th:inline="javascript"`) and `dart` (`th:inline="dart"`).

The first thing we can do with script inlining is writing the value of
expressions into our scripts, like:

```html
<script th:inline="javascript">
/*<![CDATA[*/
    ...

    var username = /*[[${session.user.name}]]*/ 'Sebastian';

    ...
/*]]>*/
</script>
```

The `/*[[...]]*/` syntax, instructs Thymeleaf to evaluate the contained
expression. But there are more implications here:

 * Being a javascript comment (`/*...*/`), our expression will be ignored when
   displaying the page statically in a browser.
 * The code after the inline expression (`'Sebastian'`) will be executed when
   displaying the page statically.
 * Thymeleaf will execute the expression and insert the result, but it will also
   remove all the code in the line after the inline expression itself (the part
   that is executed when displayed statically).

So, the result of executing this will be:

```html
<script th:inline="javascript">
/*<![CDATA[*/
    ...

    var username = 'John Apricot';

    ...
/*]]>*/
</script>
```

You can also do it without comments with the same effects, but that will make
your script to fail when loaded statically:

```html
<script th:inline="javascript">
/*<![CDATA[*/
    ...

    var username = [[${session.user.name}]];

    ...
/*]]>*/
</script>
```

Note that this evaluation is intelligent and not limited to Strings. Thymeleaf
will correctly write in Javascript/Dart syntax the following kinds of objects:

 * Strings
 * Numbers
 * Booleans
 * Arrays
 * Collections
 * Maps
 * Beans (objects with _getter_ and _setter_ methods)

For example, if we had the following code:

```html
<script th:inline="javascript">
/*<![CDATA[*/
    ...

    var user = /*[[${session.user}]]*/ null;

    ...
/*]]>*/
</script>
```

That `${session.user}` expression will evaluate to a `User` object, and
Thymeleaf will correctly convert it to Javascript syntax:

```html
<script th:inline="javascript">
/*<![CDATA[*/
    ...

    var user = {'age':null,'firstName':'John','lastName':'Apricot',
                'name':'John Apricot','nationality':'Antarctica'};

    ...
/*]]>*/
</script>
```


### Adding code

An additional feature when using javascript inlining is the ability to include
code between a special comment syntax `/*[+...+]*/` so that Thymeleaf will
automatically uncomment that code when processing the template:

```javascript
var x = 23;

/*[+

var msg  = 'This is a working application';

+]*/

var f = function() {
    ...
```

Will be executed as:

```javascript
var x = 23;

var msg  = 'This is a working application';

var f = function() {
...
```

You can include expressions inside these comments, and they will be evaluated:

```javascript
var x = 23;

/*[+

var msg  = 'Hello, ' + [[${session.user.name}]];

+]*/

var f = function() {
...
```


### Removing code

It is also possible to make Thymeleaf remove code between special `/*[- */` and `/* -]*/`
comments, like this:

```javascript
var x = 23;

/*[- */

var msg  = 'This is a non-working template';

/* -]*/

var f = function() {
...
```




13 Validation and Doctypes
==========================



13.1 Validating templates
-------------------------

As mentioned before, Thymeleaf offers us out-of-the-box two standard template
modes that validate our templates before processing them: `VALIDXML` and `VALIDXHTML.`
These modes require our templates to be not only _well-formed XML_ (which they
should always be), but in fact valid according to the specified `DTD`.

The problem is that if we use the `VALIDXHTML` mode with templates including a `DOCTYPE`
clause such as this:

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
```

...we are going to obtain validation errors because the `th:*` tags do not exist
according to that `DTD.` That's perfectly normal, as the W3C obviously has no
reason to include Thymeleaf's features in their standards but, how do we solve
it? By changing the `DTD.` 

Thymeleaf includes a set of `DTD` files that mirror the original ones from the
XHTML standards, but adding all the available `th:*` attributes from the
Standard Dialect. That's why we have been using this in our templates:

```html
<!DOCTYPE html SYSTEM "http://www.thymeleaf.org/dtd/xhtml1-strict-thymeleaf-4.dtd">
```

That `SYSTEM` identifier instructs the Thymeleaf parser to resolve the special
Thymeleaf-enabled `XHTML 1.0 Strict DTD` file and use it for validating our
template. And don't worry about that `http` thing, because that is only an
identifier, and the `DTD` file will be locally read from Thymeleaf's jar files.

> Note that because this DOCTYPE declaration is a perfectly valid one, if we
> open a browser to statically display our template as a prototype it will be
> rendered in _Standards Mode_.

Here you have the complete set of Thymeleaf-enabled `DTD` declarations for all
the supported flavours of XHTML:

```html
<!DOCTYPE html SYSTEM "http://www.thymeleaf.org/dtd/xhtml1-strict-thymeleaf-4.dtd">
<!DOCTYPE html SYSTEM "http://www.thymeleaf.org/dtd/xhtml1-transitional-thymeleaf-4.dtd">
<!DOCTYPE html SYSTEM "http://www.thymeleaf.org/dtd/xhtml1-frameset-thymeleaf-4.dtd">
<!DOCTYPE html SYSTEM "http://www.thymeleaf.org/dtd/xhtml11-thymeleaf-4.dtd">
```

Also note that, in order for your IDE to be happy, and even if you are not
working in a validating mode, you will need to declare the `th` namespace in
your `html` tag:

```html
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:th="http://www.thymeleaf.org">
```



13.2 Doctype translation
------------------------

It is fine for our templates to have a `DOCTYPE` like:

```html
<!DOCTYPE html SYSTEM "http://www.thymeleaf.org/dtd/xhtml1-strict-thymeleaf-4.dtd">
```

But it would not be fine for our web applications to send XHTML documents with
this `DOCTYPE` to client browsers, because:

 * They are not `PUBLIC` (they are `SYSTEM DOCTYPE`s), and therefore our web
   would not be validatable with the W3C Validators.
 * They are not needed, because once processed, all `th:*` tags will have
   dissapeared.

That's why Thymeleaf includes a mechanism for _DOCTYPE translation_, which will
automatically translate your thymeleaf-specific XHTML `DOCTYPE`s into standard `DOCTYPE`s.

For example, if your template is _XHTML 1.0 Strict_ and looks like this:

```html
<!DOCTYPE html SYSTEM "http://www.thymeleaf.org/dtd/xhtml1-strict-thymeleaf-4.dtd">

<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:th="http://www.thymeleaf.org">
    ... 
</html>
```

After making Thymeleaf process the template, your resulting XHTML will look like
this:

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
    ... 
</html>
```

You don't have to do anything for these transformations to take place: Thymeleaf
will take care of them automatically.




14 Some more Pages for our Grocery
==================================

Now we know a lot about using Thymeleaf, we can add some new pages to our
website for order management.

Note that we will focus on XHTML code, but you can have a look at the bundled
source code if you want to see the corresponding controllers.



14.1 Order List
---------------

Let's start by creating an order list page, `/WEB-INF/templates/order/list.html`:

```html
<!DOCTYPE html SYSTEM "http://www.thymeleaf.org/dtd/xhtml1-strict-thymeleaf-4.dtd">

<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:th="http://www.thymeleaf.org">

  <head>

    <title>Good Thymes Virtual Grocery</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" type="text/css" media="all" 
          href="../../../css/gtvg.css" th:href="@{/css/gtvg.css}" />
  </head>

  <body>

    <h1>Order list</h1>
  
    <table>
      <tr>
        <th>DATE</th>
        <th>CUSTOMER</th>
        <th>TOTAL</th>
        <th></th>
      </tr>
      <tr th:each="o : ${orders}" th:class="${oStat.odd}? 'odd'">
        <td th:text="${#calendars.format(o.date,'dd/MMM/yyyy')}">13 jan 2011</td>
        <td th:text="${o.customer.name}">Frederic Tomato</td>
        <td th:text="${#aggregates.sum(o.orderLines.{purchasePrice * amount})}">23.32</td>
        <td>
          <a href="details.html" th:href="@{/order/details(orderId=${o.id})}">view</a>
        </td>
      </tr>
    </table>
  
    <p>
      <a href="../home.html" th:href="@{/}">Return to home</a>
    </p>
    
  </body>
  
</html>
```

There's nothing here that should surprise us, except for this little bit of OGNL
magic:

```html
<td th:text="${#aggregates.sum(o.orderLines.{purchasePrice * amount})}">23.32</td>
```

What that does is, for each order line (`OrderLine` object) in the order,
multiply its `purchasePrice` and `amount` properties (by calling the
corresponding `getPurchasePrice()` and `getAmount()` methods) and return the
result into a list of numbers, later aggregated by the `#aggregates.sum(...)`
function in order to obtain the order total price.

You've got to love the power of OGNL.



14.2 Order Details
------------------

Now for the order details page, in which we will make a heavy use of asterisk
syntax:

```html
<!DOCTYPE html SYSTEM "http://www.thymeleaf.org/dtd/xhtml1-strict-thymeleaf-4.dtd">

<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:th="http://www.thymeleaf.org">

  <head>
    <title>Good Thymes Virtual Grocery</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" type="text/css" media="all" 
          href="../../../css/gtvg.css" th:href="@{/css/gtvg.css}" />
  </head>

  <body th:object="${order}">

    <h1>Order details</h1>

    <div>
      <p><b>Code:</b> <span th:text="*{id}">99</span></p>
      <p>
        <b>Date:</b>
        <span th:text="*{#calendars.format(date,'dd MMM yyyy')}">13 jan 2011</span>
      </p>
    </div>

    <h2>Customer</h2>

    <div th:object="*{customer}">
      <p><b>Name:</b> <span th:text="*{name}">Frederic Tomato</span></p>
      <p>
        <b>Since:</b>
        <span th:text="*{#calendars.format(customerSince,'dd MMM yyyy')}">1 jan 2011</span>
      </p>
    </div>
  
    <h2>Products</h2>
  
    <table>
      <tr>
        <th>PRODUCT</th>
        <th>AMOUNT</th>
        <th>PURCHASE PRICE</th>
      </tr>
      <tr th:each="ol,row : *{orderLines}" th:class="${row.odd}? 'odd'">
        <td th:text="${ol.product.name}">Strawberries</td>
        <td th:text="${ol.amount}" class="number">3</td>
        <td th:text="${ol.purchasePrice}" class="number">23.32</td>
      </tr>
    </table>

    <div>
      <b>TOTAL:</b>
      <span th:text="*{#aggregates.sum(orderLines.{purchasePrice * amount})}">35.23</span>
    </div>
  
    <p>
      <a href="list.html" th:href="@{/order/list}">Return to order list</a>
    </p>

  </body>
  
</html>
```

Not much really new here, except for this nested object selection:

```html
<body th:object="${order}">

  ...

  <div th:object="*{customer}">
    <p><b>Name:</b> <span th:text="*{name}">Frederic Tomato</span></p>
    ...
  </div>

  ...
</body>
```

...which makes that `*{name}` in fact equivalent to:


```html
<p><b>Name:</b> <span th:text="${order.customer.name}">Frederic Tomato</span></p>
```




15 More on Configuration
========================



15.1 Template Resolvers
-----------------------

For our Good Thymes Virtual Grocery, we chose an `ITemplateResolver`
implementation called `ServletContextTemplateResolver` that allowed us to obtain
templates as resources from the Servlet Context.

Besides giving you the ability to create your own template resolver by
implementing `ITemplateResolver,` Thymeleaf includes three other implementations
out of the box:

 * `org.thymeleaf.templateresolver.ClassLoaderTemplateResolver`, which resolves
   templates as classloader resources, like:

    ```java
    return Thread.currentThread().getContextClassLoader().getResourceAsStream(templateName);
    ```

 * `org.thymeleaf.templateresolver.FileTemplateResolver`, which resolves
   templates as files from the file system, like:

    ```java
    return new FileInputStream(new File(templateName));
    ```

 * `org.thymeleaf.templateresolver.UrlTemplateResolver`, which resolves
   templates as URLs (even non-local ones), like:

    ```java
    return (new URL(templateName)).openStream();
    ```

All of the pre-bundled implementations of `ITemplateResolver` allow the same set
of configuration parameters, which include:

 * Prefix and suffix (as already seen):

    ```java
    templateResolver.setPrefix("/WEB-INF/templates/");
    templateResolver.setSuffix(".html");
    ```

 * Template aliases that allow the use of template names that do not directly
   correspond to file names. If both suffix/prefix and alias exist, alias will
   be applied before prefix/suffix:

    ```java
    templateResolver.addTemplateAlias("adminHome","profiles/admin/home");
    templateResolver.setTemplateAliases(aliasesMap);
    ```

 * Encoding to be applied when reading templates:

    ```java
    templateResolver.setEncoding("UTF-8");
    ```

 * Default template mode, and patterns for defining other modes for specific
   templates:

    ```java
    // Default is TemplateMode.XHTML
    templateResolver.setTemplateMode("HTML5");
    templateResolver.getXhtmlTemplateModePatternSpec().addPattern("*.xhtml");
    ```

 * Default mode for template cache, and patterns for defining whether specific
   templates are cacheable or not:

    ```java
    // Default is true
    templateResolver.setCacheable(false);
    templateResolver.getCacheablePatternSpec().addPattern("/users/*");
    ```

 * TTL in milliseconds for parsed template cache entries originated in this
   template resolver. If not set, the only way to remove an entry from the cache
   will be LRU (cache max size exceeded and the entry is the oldest).

    ```java
    // Default is no TTL (only LRU would remove entries)
    templateResolver.setCacheTTLMs(60000L);
    ```

Also, a Template Engine can be specified several template resolvers, in which case an
order can be established between them for template resolution so that, if the
first one is not able to resolve the template, the second one is asked, and so
on:

```java
ClassLoaderTemplateResolver classLoaderTemplateResolver = new ClassLoaderTemplateResolver();
classLoaderTemplateResolver.setOrder(Integer.valueOf(1));

ServletContextTemplateResolver servletContextTemplateResolver = new ServletContextTemplateResolver();
servletContextTemplateResolver.setOrder(Integer.valueOf(2));

templateEngine.addTemplateResolver(classLoaderTemplateResolver);
templateEngine.addTemplateResolver(servletContextTemplateResolver);
```

When several template resolvers are applied, it is recommended to specify
patterns for each template resolver so that Thymeleaf can quickly discard those
template resolvers that are not meant to resolve the template, enhancing
performance. Doing this is not a requirement, but an optimization:

```java
ClassLoaderTemplateResolver classLoaderTemplateResolver = new ClassLoaderTemplateResolver();
classLoaderTemplateResolver.setOrder(Integer.valueOf(1));
// This classloader will not be even asked for any templates not matching these patterns 
classLoaderTemplateResolver.getResolvablePatternSpec().addPattern("/layout/*.html");
classLoaderTemplateResolver.getResolvablePatternSpec().addPattern("/menu/*.html");

ServletContextTemplateResolver servletContextTemplateResolver = new ServletContextTemplateResolver();
servletContextTemplateResolver.setOrder(Integer.valueOf(2));
```



15.2 Message Resolvers
----------------------

We did not explicitly specify a Message Resolver implementation for our Grocery
application, and as it was explained before, this meant that the implementation
being used was an `org.thymeleaf.messageresolver.StandardMessageResolver` object.

This `StandardMessageResolver,` which looks for messages files with the same
name as the template in the way already explained, is in fact the only message
resolver implementation offered by Thymeleaf core out of the box, although of
course you can create your own by just implementing the `org.thymeleaf.messageresolver.IMessageResolver`
interface.

> The Thymeleaf + Spring integration packages offer an `IMessageResolver`
> implementation which uses the standard Spring way of retrieving externalized
> messages, by using `MessageSource` objects.

What if you wanted to add a message resolver (or more) to the Template Engine?
Easy:

```java
// For setting only one
templateEngine.setMessageResolver(messageResolver);

// For setting more than one
templateEngine.addMessageResolver(messageResolver);
```

And why would you want to have more than one message resolver? for the same
reason as template resolvers: message resolvers are ordered and if the first one
cannot resolve a specific message, the second one will be asked, then the third,
etc.



15.3 Logging
------------

Thymeleaf pays quite a lot of attention to logging, and always tries to offer
the maximum amount of useful information through its logging interface.

The logging library used is `slf4j,` which in fact acts as a bridge to whichever
logging implementation you might want to use in your application (for example, `log4j`).

Thymeleaf classes will log `TRACE`, `DEBUG` and `INFO`-level information,
depending on the level of detail you desire, and besides general logging it will
use three special loggers associated with the TemplateEngine class which you can
configure separately for different purposes:

 * `org.thymeleaf.TemplateEngine.CONFIG` will output detailed configuration of
   the library during initialization.
 * `org.thymeleaf.TemplateEngine.TIMER` will output information about the amount
   of time taken to process each template (useful for benchmarking!)
 * `org.thymeleaf.TemplateEngine.cache` is the prefix for a set of loggers that
   output specific information about the caches. Although the names of the cache
   loggers are configurable by the user and thus could change, by default they
   are:
    * `org.thymeleaf.TemplateEngine.cache.TEMPLATE_CACHE`
    * `org.thymeleaf.TemplateEngine.cache.FRAGMENT_CACHE`
    * `org.thymeleaf.TemplateEngine.cache.MESSAGE_CACHE`
    * `org.thymeleaf.TemplateEngine.cache.EXPRESSION_CACHE`

An example configuration for Thymeleaf's logging infrastructure, using `log4j`,
could be:

```
log4j.logger.org.thymeleaf=DEBUG
log4j.logger.org.thymeleaf.TemplateEngine.CONFIG=TRACE
log4j.logger.org.thymeleaf.TemplateEngine.TIMER=TRACE
log4j.logger.org.thymeleaf.TemplateEngine.cache.TEMPLATE_CACHE=TRACE
```




16 Template Cache
=================

Thymeleaf works thanks to a DOM processing engine and a series of processors
---one for each type of node that needs to apply logic--- that modify the document's
DOM tree in order to create the results you expect by combining this tree with
your data.

It also includes ---by default--- a cache that stores parsed templates, this is, the
DOM trees resulting from reading and parsing template files before processing
them. This is especially useful when working in a web application, and builds on
the following concepts:

 * Input/Output is almost always the slowest part of any application. In-memory
   process is extremely quick compared to it.
 * Cloning an existing in-memory DOM-tree is always much quicker than reading a
   template file, parsing it and creating a new DOM object tree for it.
 * Web applications usually only have a few dozen templates.
 * Template files are small-to-medium size, and they are not modified while the
   application is running.

This all leads to the idea that caching the most used templates in a web
application is feasible without wasting big amounts of memory, and also that it
will save a lot of time that would be spent on input/output operations on a
small set of files that, in fact, never change.

And how can we take control of this cache? First, we've learned before that we
can enable or disable it at the Template Resolver, even acting only on specific
templates:

```java
// Default is true
templateResolver.setCacheable(false);
templateResolver.getCacheablePatternSpec().addPattern("/users/*");
```

Also, we could modify its configuration by establishing our own _Cache Manager_
object, which could be an instance of the default `StandardCacheManager`
implementation:

```java
// Default is 50
StandardCacheManager cacheManager = new StandardCacheManager();
cacheManager.setTemplateCacheMaxSize(100);
...
templateEngine.setCacheManager(cacheManager);
```

Refer to the javadoc API of `org.thymeleaf.cache.StandardCacheManager` for more
info on configuring the caches.

Entries can be manually removed from the template cache:

```java
// Clear the cache completely
templateEngine.clearTemplateCache();

// Clear a specific template from the cache
templateEngine.clearTemplateCacheFor("/users/userList");
```




## 17 Apéndice A: Objetos básicos de expresión {#apendice-a-expresión-objetos-basicos} 
=========================================

Some objects and variable maps are always available to be invoked at variable expressions (executed by OGNL or SpringEL). Let's see them:

### Base objects

 * **\#ctx** : the context object. It will be an implementation of `org.thymeleaf.context.IContext`, 
   `org.thymeleaf.context.IWebContext` depending on our environment (standalone or web). If we are
   using the _Spring integration module_, it will be an instance of 
   `org.thymeleaf.spring[3|4].context.SpringWebContext`.

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.context.IContext
 * ======================================================================
 */

${#ctx.locale}
${#ctx.variables}

/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.context.IWebContext
 * ======================================================================
 */

${#ctx.applicationAttributes}
${#ctx.httpServletRequest}
${#ctx.httpServletResponse}
${#ctx.httpSession}
${#ctx.requestAttributes}
${#ctx.requestParameters}
${#ctx.servletContext}
${#ctx.sessionAttributes}
```

 * **\#locale** : direct access to the `java.util.Locale` associated with current request.

```java
${#locale}
```

 * **\#vars** : an instance of `org.thymeleaf.context.VariablesMap` with all the variables in the Context
    (usually the variables contained in `#ctx.variables` plus local ones).

    Unqualified expressions are evaluated against this object. In fact, `${something}` is completely equivalent
    to (but more beautiful than) `${#vars.something}`.

    `#root` is a synomyn for the same object.

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.context.VariablesMap
 * ======================================================================
 */

${#vars.get('foo')}
${#vars.containsKey('foo')}
${#vars.size()}
...
```

### Web context namespaces for request/session attributes, etc.

When using Thymeleaf in a web environment, we can use a series of shortcuts for accessing request parameters, session attributes and application attributes:

   > Note these are not *context objects*, but maps added to the context as variables, so we access them without `#`. In some way, therefore, they act as *namespaces*.

 * **param** : for retrieving request parameters. `${param.foo}` is a
   `String[]` with the values of the `foo` request parameter, so `${param.foo[0]}` will normally be used for getting the first value.

```java
/*
 * ============================================================================
 * See javadoc API for class org.thymeleaf.context.WebRequestParamsVariablesMap
 * ============================================================================
 */

${param.foo}              // Retrieves a String[] with the values of request parameter 'foo'
${param.size()}
${param.isEmpty()}
${param.containsKey('foo')}
...
```

 * **session** : for retrieving session attributes.

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.context.WebSessionVariablesMap
 * ======================================================================
 */

${session.foo}                 // Retrieves the session atttribute 'foo'
${session.size()}
${session.isEmpty()}
${session.containsKey('foo')}
...
```

 * **application** : for retrieving application/servlet context attributes.

```java
/*
 * =============================================================================
 * See javadoc API for class org.thymeleaf.context.WebServletContextVariablesMap
 * =============================================================================
 */

${application.foo}              // Retrieves the ServletContext atttribute 'foo'
${application.size()}
${application.isEmpty()}
${application.containsKey('foo')}
...
```

Note there is **no need to specify a namespace for accessing request attributes** (as opposed to *request parameters*) because all request attributes are automatically added to the context as variables in the context root:

```java
${myRequestAttribute}
```

### Web context objects

Inside a web environment there is also direct access to the following objects (note these are objects, not maps/namespaces):

 * **\#httpServletRequest** : direct access to the `javax.servlet.http.HttpServletRequest` object associated with the current request.

```java
${#httpServletRequest.getAttribute('foo')}
${#httpServletRequest.getParameter('foo')}
${#httpServletRequest.getContextPath()}
${#httpServletRequest.getRequestName()}
...
```
 * **\#httpSession** : direct access to the `javax.servlet.http.HttpSession` object associated with the current request.

```java
${#httpSession.getAttribute('foo')}
${#httpSession.id}
${#httpSession.lastAccessedTime}
...
```

### Spring context objects

If you are using Thymeleaf from Spring, you can also access these objects:

 * **\#themes** : provides the same features as the Spring `spring:theme` JSP tag.

```java
${#themes.code('foo')}
```

### Spring beans

Thymeleaf also allows accessing beans registered at your Spring Application Context in the standard way defined  by Spring EL, which is using the syntax `@beanName`, for example:

```html
<div th:text="${@authService.getUserName()}">...</div>
```




## 18 Apéndice B: Objetos de utilidad de expresión  {#apendice-b-expresion-objetos-de-utilidad}
=========================================

### Dates

 * **\#dates** : utility methods for `java.util.Date` objects:

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Dates
 * ======================================================================
 */

/*
 * Format date with the standard locale format
 * Also works with arrays, lists or sets
 */
${#dates.format(date)}
${#dates.arrayFormat(datesArray)}
${#dates.listFormat(datesList)}
${#dates.setFormat(datesSet)}

/*
 * Format date with the ISO8601 format
 * Also works with arrays, lists or sets
 */
${#dates.formatISO(date)}
${#dates.arrayFormatISO(datesArray)}
${#dates.listFormatISO(datesList)}
${#dates.setFormatISO(datesSet)}

/*
 * Format date with the specified pattern
 * Also works with arrays, lists or sets
 */
${#dates.format(date, 'dd/MMM/yyyy HH:mm')}
${#dates.arrayFormat(datesArray, 'dd/MMM/yyyy HH:mm')}
${#dates.listFormat(datesList, 'dd/MMM/yyyy HH:mm')}
${#dates.setFormat(datesSet, 'dd/MMM/yyyy HH:mm')}

/*
 * Obtain date properties
 * Also works with arrays, lists or sets
 */
${#dates.day(date)}                    // also arrayDay(...), listDay(...), etc.
${#dates.month(date)}                  // also arrayMonth(...), listMonth(...), etc.
${#dates.monthName(date)}              // also arrayMonthName(...), listMonthName(...), etc.
${#dates.monthNameShort(date)}         // also arrayMonthNameShort(...), listMonthNameShort(...), etc.
${#dates.year(date)}                   // also arrayYear(...), listYear(...), etc.
${#dates.dayOfWeek(date)}              // also arrayDayOfWeek(...), listDayOfWeek(...), etc.
${#dates.dayOfWeekName(date)}          // also arrayDayOfWeekName(...), listDayOfWeekName(...), etc.
${#dates.dayOfWeekNameShort(date)}     // also arrayDayOfWeekNameShort(...), listDayOfWeekNameShort(...), etc.
${#dates.hour(date)}                   // also arrayHour(...), listHour(...), etc.
${#dates.minute(date)}                 // also arrayMinute(...), listMinute(...), etc.
${#dates.second(date)}                 // also arraySecond(...), listSecond(...), etc.
${#dates.millisecond(date)}            // also arrayMillisecond(...), listMillisecond(...), etc.

/*
 * Create date (java.util.Date) objects from its components
 */
${#dates.create(year,month,day)}
${#dates.create(year,month,day,hour,minute)}
${#dates.create(year,month,day,hour,minute,second)}
${#dates.create(year,month,day,hour,minute,second,millisecond)}

/*
 * Create a date (java.util.Date) object for the current date and time
 */
${#dates.createNow()}

${#dates.createNowForTimeZone()}

/*
 * Create a date (java.util.Date) object for the current date (time set to 00:00)
 */
${#dates.createToday()}

${#dates.createTodayForTimeZone()}
```


### Calendars

 * **\#calendars** : analogous to `#dates`, but for `java.util.Calendar` objects:

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Calendars
 * ======================================================================
 */

/*
 * Format calendar with the standard locale format
 * Also works with arrays, lists or sets
 */
${#calendars.format(cal)}
${#calendars.arrayFormat(calArray)}
${#calendars.listFormat(calList)}
${#calendars.setFormat(calSet)}

/*
 * Format calendar with the ISO8601 format
 * Also works with arrays, lists or sets
 */
${#calendars.formatISO(cal)}
${#calendars.arrayFormatISO(calArray)}
${#calendars.listFormatISO(calList)}
${#calendars.setFormatISO(calSet)}

/*
 * Format calendar with the specified pattern
 * Also works with arrays, lists or sets
 */
${#calendars.format(cal, 'dd/MMM/yyyy HH:mm')}
${#calendars.arrayFormat(calArray, 'dd/MMM/yyyy HH:mm')}
${#calendars.listFormat(calList, 'dd/MMM/yyyy HH:mm')}
${#calendars.setFormat(calSet, 'dd/MMM/yyyy HH:mm')}

/*
 * Obtain calendar properties
 * Also works with arrays, lists or sets
 */
${#calendars.day(date)}                // also arrayDay(...), listDay(...), etc.
${#calendars.month(date)}              // also arrayMonth(...), listMonth(...), etc.
${#calendars.monthName(date)}          // also arrayMonthName(...), listMonthName(...), etc.
${#calendars.monthNameShort(date)}     // also arrayMonthNameShort(...), listMonthNameShort(...), etc.
${#calendars.year(date)}               // also arrayYear(...), listYear(...), etc.
${#calendars.dayOfWeek(date)}          // also arrayDayOfWeek(...), listDayOfWeek(...), etc.
${#calendars.dayOfWeekName(date)}      // also arrayDayOfWeekName(...), listDayOfWeekName(...), etc.
${#calendars.dayOfWeekNameShort(date)} // also arrayDayOfWeekNameShort(...), listDayOfWeekNameShort(...), etc.
${#calendars.hour(date)}               // also arrayHour(...), listHour(...), etc.
${#calendars.minute(date)}             // also arrayMinute(...), listMinute(...), etc.
${#calendars.second(date)}             // also arraySecond(...), listSecond(...), etc.
${#calendars.millisecond(date)}        // also arrayMillisecond(...), listMillisecond(...), etc.

/*
 * Create calendar (java.util.Calendar) objects from its components
 */
${#calendars.create(year,month,day)}
${#calendars.create(year,month,day,hour,minute)}
${#calendars.create(year,month,day,hour,minute,second)}
${#calendars.create(year,month,day,hour,minute,second,millisecond)}

${#calendars.createForTimeZone(year,month,day,timeZone)}
${#calendars.createForTimeZone(year,month,day,hour,minute,timeZone)}
${#calendars.createForTimeZone(year,month,day,hour,minute,second,timeZone)}
${#calendars.createForTimeZone(year,month,day,hour,minute,second,millisecond,timeZone)}

/*
 * Create a calendar (java.util.Calendar) object for the current date and time
 */
${#calendars.createNow()}

${#calendars.createNowForTimeZone()}

/*
 * Create a calendar (java.util.Calendar) object for the current date (time set to 00:00)
 */
${#calendars.createToday()}

${#calendars.createTodayForTimeZone()}
```


### Numbers

 * **\#numbers** : utility methods for number objects:

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Numbers
 * ======================================================================
 */

/*
 * ==========================
 * Formatting integer numbers
 * ==========================
 */

/* 
 * Set minimum integer digits.
 * Also works with arrays, lists or sets
 */
${#numbers.formatInteger(num,3)}
${#numbers.arrayFormatInteger(numArray,3)}
${#numbers.listFormatInteger(numList,3)}
${#numbers.setFormatInteger(numSet,3)}


/* 
 * Set minimum integer digits and thousands separator: 
 * 'POINT', 'COMMA', 'WHITESPACE', 'NONE' or 'DEFAULT' (by locale).
 * Also works with arrays, lists or sets
 */
${#numbers.formatInteger(num,3,'POINT')}
${#numbers.arrayFormatInteger(numArray,3,'POINT')}
${#numbers.listFormatInteger(numList,3,'POINT')}
${#numbers.setFormatInteger(numSet,3,'POINT')}


/*
 * ==========================
 * Formatting decimal numbers
 * ==========================
 */

/*
 * Set minimum integer digits and (exact) decimal digits.
 * Also works with arrays, lists or sets
 */
${#numbers.formatDecimal(num,3,2)}
${#numbers.arrayFormatDecimal(numArray,3,2)}
${#numbers.listFormatDecimal(numList,3,2)}
${#numbers.setFormatDecimal(numSet,3,2)}

/*
 * Set minimum integer digits and (exact) decimal digits, and also decimal separator.
 * Also works with arrays, lists or sets
 */
${#numbers.formatDecimal(num,3,2,'COMMA')}
${#numbers.arrayFormatDecimal(numArray,3,2,'COMMA')}
${#numbers.listFormatDecimal(numList,3,2,'COMMA')}
${#numbers.setFormatDecimal(numSet,3,2,'COMMA')}

/*
 * Set minimum integer digits and (exact) decimal digits, and also thousands and 
 * decimal separator.
 * Also works with arrays, lists or sets
 */
${#numbers.formatDecimal(num,3,'POINT',2,'COMMA')}
${#numbers.arrayFormatDecimal(numArray,3,'POINT',2,'COMMA')}
${#numbers.listFormatDecimal(numList,3,'POINT',2,'COMMA')}
${#numbers.setFormatDecimal(numSet,3,'POINT',2,'COMMA')}



/*
 * ==========================
 * Utility methods
 * ==========================
 */

/*
 * Create a sequence (array) of integer numbers going
 * from x to y
 */
${#numbers.sequence(from,to)}
${#numbers.sequence(from,to,step)}
```


### Strings

 * **\#strings** : utility methods for `String` objects:

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Strings
 * ======================================================================
 */

/*
 * Null-safe toString()
 */
${#strings.toString(obj)}                           // also array*, list* and set*

/*
 * Check whether a String is empty (or null). Performs a trim() operation before check
 * Also works with arrays, lists or sets
 */
${#strings.isEmpty(name)}
${#strings.arrayIsEmpty(nameArr)}
${#strings.listIsEmpty(nameList)}
${#strings.setIsEmpty(nameSet)}

/*
 * Perform an 'isEmpty()' check on a string and return it if false, defaulting to
 * another specified string if true.
 * Also works with arrays, lists or sets
 */
${#strings.defaultString(text,default)}
${#strings.arrayDefaultString(textArr,default)}
${#strings.listDefaultString(textList,default)}
${#strings.setDefaultString(textSet,default)}

/*
 * Check whether a fragment is contained in a String
 * Also works with arrays, lists or sets
 */
${#strings.contains(name,'ez')}                     // also array*, list* and set*
${#strings.containsIgnoreCase(name,'ez')}           // also array*, list* and set*

/*
 * Check whether a String starts or ends with a fragment
 * Also works with arrays, lists or sets
 */
${#strings.startsWith(name,'Don')}                  // also array*, list* and set*
${#strings.endsWith(name,endingFragment)}           // also array*, list* and set*

/*
 * Substring-related operations
 * Also works with arrays, lists or sets
 */
${#strings.indexOf(name,frag)}                      // also array*, list* and set*
${#strings.substring(name,3,5)}                     // also array*, list* and set*
${#strings.substringAfter(name,prefix)}             // also array*, list* and set*
${#strings.substringBefore(name,suffix)}            // also array*, list* and set*
${#strings.replace(name,'las','ler')}               // also array*, list* and set*

/*
 * Append and prepend
 * Also works with arrays, lists or sets
 */
${#strings.prepend(str,prefix)}                     // also array*, list* and set*
${#strings.append(str,suffix)}                      // also array*, list* and set*

/*
 * Change case
 * Also works with arrays, lists or sets
 */
${#strings.toUpperCase(name)}                       // also array*, list* and set*
${#strings.toLowerCase(name)}                       // also array*, list* and set*

/*
 * Split and join
 */
${#strings.arrayJoin(namesArray,',')}
${#strings.listJoin(namesList,',')}
${#strings.setJoin(namesSet,',')}
${#strings.arraySplit(namesStr,',')}                // returns String[]
${#strings.listSplit(namesStr,',')}                 // returns List<String>
${#strings.setSplit(namesStr,',')}                  // returns Set<String>

/*
 * Trim
 * Also works with arrays, lists or sets
 */
${#strings.trim(str)}                               // also array*, list* and set*

/*
 * Compute length
 * Also works with arrays, lists or sets
 */
${#strings.length(str)}                             // also array*, list* and set*

/*
 * Abbreviate text making it have a maximum size of n. If text is bigger, it
 * will be clipped and finished in "..."
 * Also works with arrays, lists or sets
 */
${#strings.abbreviate(str,10)}                      // also array*, list* and set*

/*
 * Convert the first character to upper-case (and vice-versa)
 */
${#strings.capitalize(str)}                         // also array*, list* and set*
${#strings.unCapitalize(str)}                       // also array*, list* and set*

/*
 * Convert the first character of every word to upper-case
 */
${#strings.capitalizeWords(str)}                    // also array*, list* and set*
${#strings.capitalizeWords(str,delimiters)}         // also array*, list* and set*

/*
 * Escape the string
 */
${#strings.escapeXml(str)}                          // also array*, list* and set*
${#strings.escapeJava(str)}                         // also array*, list* and set*
${#strings.escapeJavaScript(str)}                   // also array*, list* and set*
${#strings.unescapeJava(str)}                       // also array*, list* and set*
${#strings.unescapeJavaScript(str)}                 // also array*, list* and set*

/*
 * Null-safe comparison and concatenation
 */
${#strings.equals(first, second)}
${#strings.equalsIgnoreCase(first, second)}
${#strings.concat(values...)}
${#strings.concatReplaceNulls(nullValue, values...)}

/*
 * Random
 */
${#strings.randomAlphanumeric(count)}
```


### Objects

 * **\#objects** : utility methods for objects in general

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Objects
 * ======================================================================
 */

/*
 * Return obj if it is not null, and default otherwise
 * Also works with arrays, lists or sets
 */
${#objects.nullSafe(obj,default)}
${#objects.arrayNullSafe(objArray,default)}
${#objects.listNullSafe(objList,default)}
${#objects.setNullSafe(objSet,default)}
```


### Booleans

 * **\#bools** : utility methods for boolean evaluation

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Bools
 * ======================================================================
 */

/*
 * Evaluate a condition in the same way that it would be evaluated in a th:if tag
 * (see conditional evaluation chapter afterwards).
 * Also works with arrays, lists or sets
 */
${#bools.isTrue(obj)}
${#bools.arrayIsTrue(objArray)}
${#bools.listIsTrue(objList)}
${#bools.setIsTrue(objSet)}

/*
 * Evaluate with negation
 * Also works with arrays, lists or sets
 */
${#bools.isFalse(cond)}
${#bools.arrayIsFalse(condArray)}
${#bools.listIsFalse(condList)}
${#bools.setIsFalse(condSet)}

/*
 * Evaluate and apply AND operator
 * Receive an array, a list or a set as parameter
 */
${#bools.arrayAnd(condArray)}
${#bools.listAnd(condList)}
${#bools.setAnd(condSet)}

/*
 * Evaluate and apply OR operator
 * Receive an array, a list or a set as parameter
 */
${#bools.arrayOr(condArray)}
${#bools.listOr(condList)}
${#bools.setOr(condSet)}
```


### Arrays

 * **\#arrays** : utility methods for arrays

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Arrays
 * ======================================================================
 */

/*
 * Converts to array, trying to infer array component class.
 * Note that if resulting array is empty, or if the elements
 * of the target object are not all of the same class,
 * this method will return Object[].
 */
${#arrays.toArray(object)}

/*
 * Convert to arrays of the specified component class.
 */
${#arrays.toStringArray(object)}
${#arrays.toIntegerArray(object)}
${#arrays.toLongArray(object)}
${#arrays.toDoubleArray(object)}
${#arrays.toFloatArray(object)}
${#arrays.toBooleanArray(object)}

/*
 * Compute length
 */
${#arrays.length(array)}

/*
 * Check whether array is empty
 */
${#arrays.isEmpty(array)}

/*
 * Check if element or elements are contained in array
 */
${#arrays.contains(array, element)}
${#arrays.containsAll(array, elements)}
```


### Lists

 * **\#lists** : utility methods for lists

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Lists
 * ======================================================================
 */

/*
 * Converts to list
 */
${#lists.toList(object)}

/*
 * Compute size
 */
${#lists.size(list)}

/*
 * Check whether list is empty
 */
${#lists.isEmpty(list)}

/*
 * Check if element or elements are contained in list
 */
${#lists.contains(list, element)}
${#lists.containsAll(list, elements)}

/*
 * Sort a copy of the given list. The members of the list must implement
 * comparable or you must define a comparator.
 */
${#lists.sort(list)}
${#lists.sort(list, comparator)}
```


### Sets

 * **\#sets** : utility methods for sets

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Sets
 * ======================================================================
 */

/*
 * Converts to set
 */
${#sets.toSet(object)}

/*
 * Compute size
 */
${#sets.size(set)}

/*
 * Check whether set is empty
 */
${#sets.isEmpty(set)}

/*
 * Check if element or elements are contained in set
 */
${#sets.contains(set, element)}
${#sets.containsAll(set, elements)}
```


### Maps

 * **\#maps** : utility methods for maps

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Maps
 * ======================================================================
 */

/*
 * Compute size
 */
${#maps.size(map)}

/*
 * Check whether map is empty
 */
${#maps.isEmpty(map)}

/*
 * Check if key/s or value/s are contained in maps
 */
${#maps.containsKey(map, key)}
${#maps.containsAllKeys(map, keys)}
${#maps.containsValue(map, value)}
${#maps.containsAllValues(map, value)}
```


### Aggregates

 * **\#aggregates** : utility methods for creating aggregates on arrays or
   collections

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Aggregates
 * ======================================================================
 */

/*
 * Compute sum. Returns null if array or collection is empty
 */
${#aggregates.sum(array)}
${#aggregates.sum(collection)}

/*
 * Compute average. Returns null if array or collection is empty
 */
${#aggregates.avg(array)}
${#aggregates.avg(collection)}
```


### Messages

 * **\#messages** : utility methods for obtaining externalized messages inside
   variables expressions, in the same way as they would be obtained using `#{...}`
   syntax.

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Messages
 * ======================================================================
 */

/*
 * Obtain externalized messages. Can receive a single key, a key plus arguments,
 * or an array/list/set of keys (in which case it will return an array/list/set of 
 * externalized messages).
 * If a message is not found, a default message (like '??msgKey??') is returned.
 */
${#messages.msg('msgKey')}
${#messages.msg('msgKey', param1)}
${#messages.msg('msgKey', param1, param2)}
${#messages.msg('msgKey', param1, param2, param3)}
${#messages.msgWithParams('msgKey', new Object[] {param1, param2, param3, param4})}
${#messages.arrayMsg(messageKeyArray)}
${#messages.listMsg(messageKeyList)}
${#messages.setMsg(messageKeySet)}

/*
 * Obtain externalized messages or null. Null is returned instead of a default
 * message if a message for the specified key is not found.
 */
${#messages.msgOrNull('msgKey')}
${#messages.msgOrNull('msgKey', param1)}
${#messages.msgOrNull('msgKey', param1, param2)}
${#messages.msgOrNull('msgKey', param1, param2, param3)}
${#messages.msgOrNullWithParams('msgKey', new Object[] {param1, param2, param3, param4})}
${#messages.arrayMsgOrNull(messageKeyArray)}
${#messages.listMsgOrNull(messageKeyList)}
${#messages.setMsgOrNull(messageKeySet)}
```


### IDs

 * **\#ids** : utility methods for dealing with `id` attributes that might be
   repeated (for example, as a result of an iteration).

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Ids
 * ======================================================================
 */

/*
 * Normally used in th:id attributes, for appending a counter to the id attribute value
 * so that it remains unique even when involved in an iteration process.
 */
${#ids.seq('someId')}

/*
 * Normally used in th:for attributes in <label> tags, so that these labels can refer to Ids
 * generated by means if the #ids.seq(...) function.
 *
 * Depending on whether the <label> goes before or after the element with the #ids.seq(...)
 * function, the "next" (label goes before "seq") or the "prev" function (label goes after 
 * "seq") function should be called.
 */
${#ids.next('someId')}
${#ids.prev('someId')}
```



19 Appendix C: DOM Selector syntax
==================================

DOM Selectors borrow syntax features from XPATH, CSS and jQuery, in order to provide a powerful and easy to use way to specify template fragments.

For example, the following selector will select every `<div>` with the class `content`, in every position inside the markup:

```html
<div th:include="mytemplate :: [//div[@class='content']]">...</div>
```

The basic syntax inspired from XPath includes:

 * `/x` means direct children of the current node with name x.

 * `//x` means children of the current node with name x, at any depth.

 * `x[@z="v"]` means elements with name x and an attribute called z with value "v".

 * `x[@z1="v1" and @z2="v2"]` means elements with name x and attributes z1 and z2 with values "v1" and "v2", respectively.

 * `x[i]` means element with name x positioned in number i among its siblings.

 * `x[@z="v"][i]` means elements with name x, attribute z with value "v" and positioned in number i among its siblings that also match this condition.

But more concise syntax can also be used:

 * `x` is exactly equivalent to `//x` (search an element with name or reference `x` at any depth level).

 * Selectors are also allowed without element name/reference, as long as they include a specification of arguments. So `[@class='oneclass']` is a valid selector that looks for any elements (tags) with a class attribute with value "oneclass".

Advanced attribute selection features:

 * Besides `=` (equal), other comparison operators are also valid: `!=` (not equal), `^=` (starts with) and `$=` (ends with). For example: `x[@class^='section']` means elements with name `x` and a value for attribute `class` that starts with `section`.

 * Attributes can be specified both starting with `@` (XPath-style) and without (jQuery-style). So `x[z='v']` is equivalent to `x[@z='v']`.
 
 * Multiple-attribute modifiers can be joined both with `and` (XPath-style) and also by chaining multiple modifiers (jQuery-style). So `x[@z1='v1' and @z2='v2']` is actually equivalent to `x[@z1='v1'][@z2='v2']` (and also to `x[z1='v1'][z2='v2']`).

Direct _jQuery-like_ selectors:

 * `x.oneclass` is equivalent to `x[class='oneclass']`.

 * `.oneclass` is equivalent to `[class='oneclass']`.

 * `x#oneid` is equivalent to `x[id='oneid']`.

 * `#oneid` is equivalent to `[id='oneid']`.

 * `x%oneref` means nodes -not just elements- with name x that match reference _oneref_ according to a specified `DOMSelector.INodeReferenceChecker` implementation.

 * `%oneref` means nodes -not just elements- with any name that match reference _oneref_ according to a specified `DOMSelector.INodeReferenceChecker` implementation. Note this is actually equivalent to simply `oneref` because references can be used instead of element names.

 * Direct selectors and attribute selectors can be mixed: `a.external[@href^='https']`.

The above DOM Selector expression:

```html
<div th:include="mytemplate :: [//div[@class='content']]">...</div>
```
could be written as:

```html
<div th:include="mytemplate :: [div.content]">...</div>
```

###Multivalued class matching

DOM Selectors understand the class attribute to be **multivalued**, and therefore allow the application of selectors on this attribute even if the element has several class values.

For example, `div[class='two']` will match `<div class="one two three" />`

###Optional brackets

The syntax of the fragment inclusion attributes converts every fragment selection into a DOM selection, so brackets `[...]` are not needed (though allowed).

So the following, with no brackets, is equivalent to the bracketed selector seen above:

```html
<div th:include="mytemplate :: div.content">...</div>
```

So, summarizing, this:

```html
<div th:replace="mytemplate :: myfrag">...</div>
```

Will look for a `th:fragment="myfrag"` fragment signature. But would also look for tags with name `myfrag` if they existed (which they don't, in HTML). Note the difference with:

```html
<div th:replace="mytemplate :: .myfrag">...</div>
```

which will actually look for any elements with `class="myfrag"`, without caring about `th:fragment` signatures.
