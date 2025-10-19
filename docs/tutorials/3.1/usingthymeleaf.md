---
title: 'Tutorial: Usando Thymeleaf'
author: Thymeleaf
version: @documentVersion@
thymeleafVersion: @projectVersion@
---


1\. Presentando Thymeleaf
=========================



1.1 ¿Qué es Thymeleaf?
----------------------

Thymeleaf es un motor de plantillas del lado del servidor realizado en Java 
tanto para la web como para entornos aislados, capaz de procesar HTML, XML, 
JavaScript, CSS e incluso texto plano.

El objetivo principal de Thymeleaf es proporcionar una forma elegante y 
altamente mantenible de crear plantillas. Para conseguir esto, construye sobre 
el concepto de *Plantillas Naturales* para inyectar su lógica en ficheros de 
plantilla de una forma que no afecte a la plantilla al usarla como un prototipo 
de diseño. Esto mejora la comunicación del diseño y acorta la brecha entre los 
equipos de diseño y desarrollo.

Thymeleaf también ha sido diseñado desde el principio con los Estándares Web en 
mente -- especialmente **HTML5**  -- permitiéndole crear plantillas plenamente 
validadas si es lo que necesita.

1.2  ¿Qué clase de plantillas puede procesar Thymeleaf?
-------------------------------------------------

Tal como está, Thymeleaf le permite procesar ses clases de plantillas, cada una 
de las cuales se llama **Modo de Plantilla**:

 * HTML
 * XML
 * TEXT
 * JAVASCRIPT
 * CSS
 * RAW 

Existen dos modos de plantilla de *marcado* (`HTML` y `XML`), tres modos de 
plantilla *textuales* (`TEXT`, `JAVASCRIPT` y `CSS`) y un modo de plantilla 
*no-op*  (`RAW`).

El modo de plantilla **`HTML`** permitirá cualquier clase de entrada HTML, 
incluyendo HTML5, HTML 4 y XHTML. No se realizará ninguna validación ni 
comprobación de buen formato, y la estructura/código de la plantilla será 
respetada en la mayor medida posible en la salida.

El modo de plantilla **`XML`** permitirá la entrada XML. En este caso, se 
espera que el código esté bien formado -- sin etiquetas sin cerrar, sin 
atributos no entrecomillados, etc -- y el analizador lanzará excepciones si se 
encuentran violaciones del buen formado. Tenga en cuenta que no se realizará 
*validación* (contra un DTD o Esquema XML).

El modo de plantilla **`TEXT`** permitirá el uso de una sintaxis especial para 
plantilla que no sean de naturaleza de marcado. Ejemplos de tales plantillas 
podrían ser el texto de los correos electrónicos o documentación aplantillada. 
Tenga en cuenta que las plantillas HTML o XML pueden ser también procesadas 
como `TEXT`, en cuyo caso no serán analizadas como marcado, y cada etiqueta, 
DOCTYPE, comentario, etc. será tratado como mero texto.

El modo de plantilla **`JAVASCRIPT`** permitirá el procesado de ficheros 
JavaScript en una aplicación de Thymeleaf. Esto signifa ser capaz de usar el 
modelo de atos dentro de los ficheros JavaScript de la misma forma que puede ser 
hecho en los ficheros HTML, pero con integraciones específicas de JavaScript 
tales como el escapado especializado o *scripting natural*. El modo de plantilla
`JAVASCRIPT` se considera un modo *textual* y por lo tanto usa la misma sintaxis 
especial que el modo de plantilla `TEXT`.

El modo de plantilla **`CSS`** permitirá el procesado de ficheros CSS 
involucrados en una aplicación Thymeleaf. De forma similar al modo `JAVASCRIPT`, 
el modo de plantilla `CSS` es también un modo *textual* y usa la sintaxis de 
procesado especial del modo de plantilla `TEXT`.

El modo de plantilla **`RAW`** simplemente no procesará ninguna plantilla. Está 
destinado a usarse para insertar recursos intactos (archivos, respuestas de 
URL, etc.) en las plantillas que se procesan. Por ejemplo, recursos 
incontrolados, externos en formato HTML podrían ser incluídos en plantillas de la 
aplicación, sabiendo de forma segura que no se ejecutará ningún código 
Thymeleaf que estos recursos puedan incluir.

1.3  Dialectos: El dialecto estándar
------------------------------------

Thymeleaf es un motor de plantillas extremadamente extensible (en realidad podría 
ser llamado un _marco de trabajo de motor de plantillas_) que le permite definir 
y personalizar la forma en las que sus plantillas serán procesadas hasta un 
nivel fino de detalle.

Un objeto que aplica alguna lógica a un artefacto de marcado (una etiqueta, algo 
de texto, un comentarios, o un mero marcador de posición si las plantillas no están 
marcadas) se llama un _procesador_ (processor en inglés, N. del T.) y un 
conjunto de esos procesadores -- más quizás algunos artefactos extra -- es de 
lo que se compone normalmente un **dialecto** (dialect en inglés, N. del T.). 
Tal como está, la librería principal de Thymeleaf proporciona un dialecto 
llamado el **Dialecto Estandar*, el cual debería ser suficiente para la mayoría 
de los usuarios.

> Tenga en cuenta que los dialectos pueden en realidad no tener procesadores y 
> estar enteramente compuestos de otras clases de artifactos, pero los 
> procesadores son definitivamente el caso de uso más común.

_Este tutorial cubre el Dialecto Estándar_. Cada atributo y característica de 
sintaxis que aprenderá en las páginas siguientes se define por este dialecto, 
incluso si no se menciona explicitamente.

Por supuesto, los usuarios pueden crear sus propios dialectos (incluso 
extendiendo el Estándar) si quieren definir su propia lógica de procesamiento 
mientras se aprovechan de las características avanzadas de la librería. 
Thymeleaf puede ser configurado para usar varios dialectos a la vez.

> Los paquetes de integración oficiales thymeleaf-spring3 y thymeleaf-spring4 
> definen ambos un dialecto llamado el "Dialecto SpringStańdar", el cual en su 
> mayor parte es el mismo que el Dialecto Estándar, pero con pequeñas 
> adaptaciones para hacer un mejor uso de algunas características de Spring 
> Framework (por ejemplo, usando el Lenguaje de Expresión de Spring y SpringEL en 
> vez de OGNL). Así que si usted es un usuario de Spring MVC no estará perdiendo 
> su tiempo, y casi todas las cosas que aprenderá aquí será de uso en sus 
> aplicaciones Spring.

La mayoría de los procesadores del Dialecto Estándar son _procesadores de 
atributos_. Esto permite a los navegadores visualizar correctamente los ficheros 
de plantilla HTML incluso antes de ser procesados porque simplemente ignoran los 
atributos adicionales. Por ejemplo, mientras una JSP usando una librería de 
etiquetas podría incluir un fragmento de código no directamente visualizable por 
un navegador como:

```html
<form:inputText name="userName" value="${user.name}" />
```

...El Dialecto Estándar de Thymeleaf nos permitiría alcanzar la misma 
funcionalidad con::

```html
<input type="text" name="userName" value="James Carrot" th:value="${user.name}" />
```

No solo será esto más correctamente mostrado por los navegadores, sino que también 
nos permite (opcionalmente) especificar un valor de atributo en éste ("James 
Carrot", en este caso) que será mostrado cuando el prototipo esté abierto 
estáticamente en un navegador, y que será sustituido por el valor resultante de 
la evaluación de `${user.name}` durante el procesado de la plantilla.

Esto ayuda a que tu diseñador y desarrollador trabajen en el mismo fichero de 
plantilla y reduce el esfuerzo requerido para transformar un prototipo estático 
en un fichero de plantilla funcional. La habilidad para hacer esto es una 
funcionalidad llamada _Plantillado Natural_.

2\. La tienda de comestibles virtual Good Thymes
================================================

El código fuente para los ejemplos mostrados en este, y futuros capítulos de 
esta guía, se puede encontrar en en ejemplo _Good Thymes Virtual Grocery (GTVG)_
el cual tiene dos versiones (equivalentes):

   * basado en `javax.*`: [gtvg-javax](https://github.com/thymeleaf/thymeleaf/tree/3.1-master/examples/core/thymeleaf-examples-gtvg-javax).
   * basado en `jakarta.*`: [gtvg-jakarta](https://github.com/thymeleaf/thymeleaf/tree/3.1-master/examples/core/thymeleaf-examples-gtvg-jakarta).



2.1 Un sitio web para una tienda de comestibles
-----------------------------------------------

Para explicar mejor los conceptos involucrados en el procesadamiento de 
plantillas con Thymeleaf, este tutorial usará una aplicación de demostración que 
puede descargar desde el sitio web del proyecto.

Esta aplicación es el sitio web de una tienda de comestibles  virtual 
imaginaria, y nos ofrecerá muchos escenarios para mostrar las muchas 
características de Thymeleaf.

Para empezar, necesitamos un conjunto simple de entidades del modelo para 
nuestra aplicación:  `Products` (Productos) que son vendidos a los `Customers`
(Clientes) creando `Orders` (Pedidos). También gestionaremos  `Comments` 
(Comentarios) sobre estos `Products`:

![Ejemplo del modelo de la aplicación](images/usingthymeleaf/gtvg-model.png)

Nuestra aplicación también tendrá una capa muy simple de servicio, compuesta por 
objetos `Service` (Servicio) que contienen métodos como:


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

En la capa web nuestra aplicación tendrá un filtro que delegará la ejecución a 
los comandos habilitados por Thymeleaf dependiendo de la URL solicitada:

```java

/*
 * El objeto application necesita ser declarado primero (implementa IWebApplication)
 * En este caso, se usará la versión basada en Jakarta.
 */
public void init(final FilterConfig filterConfig) throws ServletException {
    this.application =
            JakartaServletWebApplication.buildApplication(
                filterConfig.getServletContext());
    // Veremos más tarde cómo el objeto TemplateEngine se construye y configura
    this.templateEngine = buildTemplateEngine(this.application);
}

/*
 * Cada petición será procesada creando un objeto de intercambio (modelando la 
 * petición, su respuesta y todos los datos necesitados para este proceso) y 
 * después se llama al controlador correspondiente.
 */
private boolean process(HttpServletRequest request, HttpServletResponse response)
        throws ServletException {
    
    try {

        final IWebExchange webExchange = 
            this.application.buildExchange(request, response);
        final IWebRequest webRequest = webExchange.getRequest();

        // Esto evita que se activen ejecuciones del motor para las URLs de recursos
        if (request.getRequestURI().startsWith("/css") ||
                request.getRequestURI().startsWith("/images") ||
                request.getRequestURI().startsWith("/favicon")) {
            return false;
        }
        
        /*
         * Consulta la asignación de controlador/URL y obtiene el controlador 
         * que procesará la solicitud. Si no hay ningún controlador disponible, 
         * devuelve falso y deja que otros filtros/servlets procesen la solicitud. 
         */
        final IGTVGController controller = 
            ControllerMappings.resolveControllerForRequest(webRequest);
        if (controller == null) {
            return false;
        }

        /*
         *  Escribe las cabeceras de la respuesta
         */
        response.setContentType("text/html;charset=UTF-8");
        response.setHeader("Pragma", "no-cache");
        response.setHeader("Cache-Control", "no-cache");
        response.setDateHeader("Expires", 0);

        /*
         * Obtiene el flujo escritor (writer) de la respuesta (response)
         */
        final Writer writer = response.getWriter();

        /*
         * Ejecuta el controlador y procesa la plantilla de la vista, 
         * escribiendo los resultados al flujo escritor de la respuesta 
         * (response writer) 
         */
        controller.process(webExchange, this.templateEngine, writer);
        
        return true;
        
    } catch (Exception e) {
        try {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } catch (final IOException ignored) {
            // Simplemente ignora esto
        }
        throw new ServletException(e);
    }
    
}
```

Este es nuestro interfaz `IGTVGController`:

```java
public interface IGTVGController {

    public void process(
            final IWebExchange webExchange, 
            final ITemplateEngine templateEngine,
            final Writer writer)
            throws Exception;
    
}
```

Todo lo que tenemos que hacer ahora es crear implementaciones de la interfaz 
`IGTVGController`, recuperando los datos de los servicios y procesando las 
plantillas usando el objeto `ITemplateEngine`.

Al final se verá así:


![Ejemplo de página de inicio de la aplicación](images/usingthymeleaf/gtvg-view.png)

Pero primero veamos cómo se inicializa el motor de plantillas.



2.2 Creación y configuración del Motor de Plantillas
----------------------------------------------------

El método _init(...)_ en nuestro filtro contenía esta línea: 

```java
this.templateEngine = buildTemplateEngine(this.application);
```
Veamos ahora cómo nuestro objeto `org.thymeleaf.TemplateEngine` se inicializa: 

```java
private static ITemplateEngine buildTemplateEngine(final IWebApplication application) {

    // Las plantillas se resolverán como recursos de aplicación (ServletContext)
    final WebApplicationTemplateResolver templateResolver = 
            new WebApplicationTemplateResolver(application);

    // HTML es el modo por defecto, pero lo estableceremos igualmente para entender mejor el código
    templateResolver.setTemplateMode(TemplateMode.HTML);
    // Esto convertíra "home" en "/WEB-INF/templates/home.html"
    templateResolver.setPrefix("/WEB-INF/templates/");
    templateResolver.setSuffix(".html");
    // Establece la caché TTL de la plantilla a 1 hora. Si no establece, las entradas existirían en la caché hasta que la LRU las expulse 
    templateResolver.setCacheTTLMs(Long.valueOf(3600000L));

    // La caché se establece a verdadero por defecto. Establézcala a falso si quiere que las plantillas
    // se actualizen automáticamente cuando se modifiquen.
    templateResolver.setCacheable(true);

    final TemplateEngine templateEngine = new TemplateEngine();
    templateEngine.setTemplateResolver(templateResolver);

    return templateEngine;

}
```
Hay muchas formas de configurar un objeto `TemplateEngine`, pero por ahora estas
pocas líneas de código nos enseñarán lo bastante sobre los pasos necesitados.


### El Solucionador de Plantillas (Template Resolver)

Empecemos con el Solucionador de Plantillas (Template Resolver):

```java
final WebApplicationTemplateResolver templateResolver = 
        new WebApplicationTemplateResolver(application);
```

Los Solucionadores de Plantillas son objetos que implementan una interfaz de la 
IPA (Interfaz Público de Aplicaciones, API en inglés) de Thymeleaf llamada
`org.thymeleaf.templateresolver.ITemplateResolver`: 

```java
public interface ITemplateResolver {

    ...
  
    /*
     * Las plantillas se resuelven por su nombre (o contenido) y también (opcionalmente) por su 
     * plantilla propietaria en el caso de que estemos intentando resolver un fragmento para otra plantilla.
     * Devolverá nulo si la plantilla no puede ser manejada por este solucionador de plantillas.
     */
    public TemplateResolution resolveTemplate(
            final IEngineConfiguration configuration,
            final String ownerTemplate, final String template,
            final Map<String, Object> templateResolutionAttributes);
}
```

Estos objetos están a cargo de determinar cómo serán accedidas nuestras plantillas 
y, en esta aplicación GTVG, el uso de `org.thymeleaf.templateresolver.WebApplicationTemplateResolver`
significa que vamos a recuperar nuestros ficheros de plantillas como recursos del 
objeto _IWebApplication_: una abstracción de Thymeleaf que, en las aplicaciones basadas en Servlets,  
básicamente envuelve el objeto de la IPA de Servlets `[javax|jakarta].servlet.ServletContext`, 
y eso resuelve los recursos desde la raíz de la aplicación web.

Pero eso no es todo lo que podemos decir sobre el solucionador de plantillas, porque podemos establecer
algunos parámetros de configuración en él. Primero, el modo de plantilla:

```java
templateResolver.setTemplateMode(TemplateMode.HTML);
```
HTML es el modo de plantilla por defecto para `WebApplicationTemplateResolver`, pero es 
una buena práctica establecerla siempre de forma que nuestro código documente claramente lo qué 
está sucediendo.

```java
templateResolver.setPrefix("/WEB-INF/templates/");
templateResolver.setSuffix(".html");
```
Los _prefix_ y _suffix_ modifican los nombres de la plantilla que estamos pasando al 
motor para obtener los nombres reales del recurso que se utilizarán.

Usando esta configuración, el nombre de plantilla _"product/list"_ correspondería a:

```java
servletContext.getResourceAsStream("/WEB-INF/templates/product/list.html")
```

Opcionalmente, la cantidad de tiempo que una plantilla analizada puede existir en la caché se 
configura en el Solucionador de Plantillas mediante la propiedad _cacheTTLMs_: 


```java
templateResolver.setCacheTTLMs(3600000L);
```

Una plantilla puede aún ser expulsada de la caché antes de que se alcance el TTL 
si se alcanza el tamaño máximo de la caché y esta es la entrada más antigua 
almacenada actualmente en caché. 

> El comportamiento y tamaños de la Caché puede ser definido por el usuario implementando 
> la interfaz `ICacheManager` o modificando el objeto `StandardCacheManager` para gestionar 
> la caché por defecto.

Hay mucho más que aprender sobre los solucionadores de plantillas, pero por ahora
echemos un vistazo a la creación de nuestro objeto de Motor de Plantilla (Templete Engine).


### El Motor de Plantillas (Template Engine)

Los objetos de Motor de Plantilla son implementaciones de la interfaz 
`org.thymeleaf.ITemplateEngine`. Una de estas implementaciones es ofrecida por 
el nucleo de Thymeleaf: `org.thymeleaf.TemplateEngine`, y nosotros craemos una 
instancia de esta aquí:

```java
templateEngine = new TemplateEngine();
templateEngine.setTemplateResolver(templateResolver);
```

Bastante sencillo, ¿verdad? Todo lo que necesitamos es crear una instancia y 
configurarla como Solucionador de Plantillas.

Un solucionador de plantillas es el único parámetro *requerido* que necesita un
`TemplateEngine`, aunque existen muchos otros que cubriremos más tarde 
(resolvedores de mensajes, tamaños de caché, etc). Por ahora, esto es todo lo que 
necesitamos.

Nuestro Motor de Plantillas está ahora listo y podemos empezar a crear nuestras 
páginas usando Thymeleaf.




3\. Uso de textos
=================

3.1 Una bienvenida en varios idiomas
------------------------------------

Nuestra primera tarea será crear una página de inicio para nuestro sitio de la 
tienda de comestibles.

La primera versión de esta página ser extremadamente simple: simplemente un título 
y un mensaje de bienvenida. Este es nuestro fichero `/WEB-INF/templates/home.html`:

```html
<!DOCTYPE html>

<html xmlns:th="http://www.thymeleaf.org">

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

Lo primero que notará es que este archivo es HTML5 y puede ser mostrado 
correctamente por cualquier navegador porque no incluye ninguna etiqueta que no 
sea HTML (los navegadores ignoran todos los atributos que no entienden, como 
`th:text`).

Pero también podrá notar que esta plantilla no es realmente un documento HTML5 
_válido_, porque esos atributos no estándar que estamos usando en la forma `th:*`
no están permitidos por la especificación HTML5. En realidad, estamos incluso 
agregando un atributo `xmlns:th` a nuestra etiqueta `<html>`, algo absolutamente 
no HTML5:

```html
<html xmlns:th="http://www.thymeleaf.org">
```
...que no tiene ninguna influencia en el procesamiento de la plantilla, pero 
funciona como un *encantamiento* que evita que nuestro IDE se queje de la falta 
de un espacio de nombres de una definición de espacio de nombres para todos esos 
atributos `th:*`.

¿Y qué pasa si queremos que esta plantilla sea **válida para HTML5**? Fácil: 
cambie a la sintaxis de atributos de datos de Thymeleaf, utilizando el prefijo 
`data-` para los nombres de atributos y separadores de guion (`-`) en lugar de 
punto y coma (`:`):

```html
<!DOCTYPE html>

<html>

  <head>
    <title>Tienda de comestibles virtual Good Thymes</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" type="text/css" media="all" 
          href="../../css/gtvg.css" data-th-href="@{/css/gtvg.css}" />
  </head>

  <body>
  
    <p data-th-text="#{home.welcome}">¡Bienvenido a nuestra tienda de comestibles!</p>
  
  </body>

</html>
```

Los atributos personalizados `data-` están permitidos por la especificación HTML5, 
de forma que, con el código de arriba, nuestra plantilla sería un *documento HTML5 
válido*.

> Ambas notaciones son completamente equivalentes e intercambiables, pero por el
> bien de la simplicidad y la brevedad de los ejemplos de código, este tutorial 
> usará la *notacion del espacion de nombres* (`th:*`). Además, la notación
> `th:*` es más general y permitida en cada modo de plantilla Thymeleaf (`XML`, 
> `TEXT`...) mientras que la notación `data-` se permite solo en el modo `HTML`.


### Usando th:text y externalizando texto

Externalizar texto es extraer fragmentos del código de la plantilla fuera de los 
ficheros de plantillas de forma que puedan mantenerse en ficheros separados
(normalmente ficheros `.properties`) y que puedan ser facilmente reemplazados con
los textos equivalentes escritos en otros lenguajes (un proceso llamado 
internacionalización o simplemente _i18n_). Los fragmentos externalizados de 
texto se llaman normalmente *"messages"*.

Los mensajes (messages) siempre tienen una clave que los identifica, y Thymeleaf 
le permite especificar que un texto corresponderá a un mensaje específico con la 
sintaxis `#{...}`:

```html
<p th:text="#{home.welcome}">¡Bienvenido a nuestra tienda de comestibles!</p>
```

Lo que podemos ver aquí es de hecho dos características diferentes del Dialecto 
Estandar de Thymeleaf:

 * El atributo `th:text`, que evalúa su expresión de valor y establece el
   resultado como el cuerpo de la etiqueta anfitriona, reemplazando efectivamente
   el texto "¡Bienvenido a nuestra tienda de comestibles!" que vemos en el código.
 * La expresión `#{home.welcome}`, especficada en la _Sintaxis de la Expresión 
   Estándar_, que indica que el texto que debe utilizar  el atributo `th:text`
   debe ser reemplazado por el mensaje con la clave `home.welcome` correspondiente  
   a la configuración regional con la que estamos procesando la plantilla.

Ahora bien, ¿dónde está este texto externalizado?

La ubicación del texto externalizado en Thymelea es completamente configurable, y 
dependerá de la implementación específica de `org.thymeleaf.messageresolver.IMessageResolver`
que será usada, pero podríamos crear nuestras propias implementaciones si 
quisiéramos, por ejemplo, obtener los mensajes de una base de datos.

Sin embargo, no hemos especificdo un solucionador de mensajes para nuestro motor 
de plantillas durante la inicialización, y eso significa que nuestra aplicación 
está usando el _Solucionador Estándar de Mensajes_, implementado por 
`org.thymeleaf.messageresolver.StandardMessageResolver`.

El solucionador estándar de mensajes espera encontrar los mensaje para 
`/WEB-INF/templates/home.html` en ficheros de propiedades en la misma carpeta y 
con el mismo nombre que la plantilla, como:

 * `/WEB-INF/templates/home_en.properties` para textos en inglés.
 * `/WEB-INF/templates/home_es.properties` para textos en lenguaje español.
 * `/WEB-INF/templates/home_pt_BR.properties` para textos en lenguaje portugues (Brasil).
 * `/WEB-INF/templates/home.properties` para los textos por defecto (si la 
   configuración regional no coincide).

Echemos un vistazo a nuestro fichero `home_es.properties`:

```
home.welcome=¡Bienvenido a nuestra tienda de comestibles!
```

Esto es todo lo que necesitamos para que Thymelea procese nuestra plantilla. 
Ahora, creemos ahora nuestro controlador de inicio.



### Contextos (Contexts)

Para procesar nuestra plantilla, crearemos una clase `HomeController` que 
implemente la interfaz `IGTVGController` que vimos antes:

```java
public class HomeController implements IGTVGController {

    public void process(
            final IWebExchange webExchange, 
            final ITemplateEngine templateEngine,
            final Writer writer)
            throws Exception {
        
        WebContext ctx = new WebContext(webExchange, webExchange.getLocale());
        
        templateEngine.process("home", ctx, writer);
        
    }

}
```

Lo primero que vemos es la creación de un *contexto*. Un contexto de Thymeleaf 
es un objeto que implementa la interfaz `org.thymeleaf.context.IContext`. Los 
contextos deben contener todos los datos necesarios para la ejecución del motor 
de plantillas en un mapa de variables, así como la configuración regional que 
debe utilizarse para los mensajes externalizados.

```java
public interface IContext {

    public Locale getLocale();
    public boolean containsVariable(final String name);
    public Set<String> getVariableNames();
    public Object getVariable(final String name);
    
}
```

Existe una extensión especializada de esta interfaz,  `org.thymeleaf.context.IWebContext`,
diseñada para ser utilizada en aplicaciones web.

```java
public interface IWebContext extends IContext {
    
    public IWebExchange getExchange();
    
}
```

El núcleo de la librería de Thymelea ofrede una implementación de cada una de 
estas interfaces:

 * `org.thymeleaf.context.Context` implementa `IContext`
 * `org.thymeleaf.context.WebContext` implementa `IWebContext`

Y como puede ver en el código del controlado, `WebContext` es el que usamos. De 
hecho tenemos que hacerlo, porque el uso de un `WebApplicationTemplateResolver` 
requiere que usemos un contexto que implemente `IWebContext`.

```java
WebContext ctx = new WebContext(webExchange, webExchange.getLocale());
```

El constructor `WebContext` requiere información contenida en el objeto de 
abstracción `IWebExchange` que fue creado en el filtro representando este 
intercambio basado en web (p.e. petición + respuesta). La configuración regional 
por defecto del sistema se utilizará si no se especifica ninguna (aunque usted 
no debe permitir nunca que esto ocurra en aplicaciones reales).

Existen algunas expresiones especializadas que seremos capaces de utilizar para 
obtener los parámetros de la petición y los atributos de la  petición, sesión y 
aplicación del `WebContext` en nuestras plantillas. Por ejemplo:

 * `${x}` devolverá una variable `x` almacenada en el contexto de Thymeleaf o como un *atributo de intercambio* (Un *"atributo de la petición"* e"* en la jerga de los Servlet).
 * `${param.x}` devolverá un *parámetro de petición* llamado `x` (el cual podría ser multivalor).
 * `${session.x}` devolverá un *atributo de sesión* llamado `x`.
 * `${application.x}` devolverá un *atributo de aplicación* llamado `x` (un *"atributo del contexto del servlet"* en la jerga de los Servlets).


### Ejecución del motor de plantillas

Con nuestro objeto de contexto listo, ahora podemos decirle al motor de plantillas
que procese la plantilla (por su nombre) usando el contexto, y pasándole un 
escritor de respuesta (response writer) de forma que la respuesta pueda escribir
en él: 


```java
templateEngine.process("home", ctx, writer);
```

Veamos los resultados de esto usando la configuración regional española:

```html
<!DOCTYPE html>

<html>

  <head>
    <title>Tienda de comestibles virtual Good Thymes</title>
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


La versión  más simple de nuestra página de Inicio parece estar lista ahora, pero 
hay algo en el código quelo que no hemos pensado... ¿Qué pasaría si tenemos un 
mensaje como este?

```java
home.welcome=¡Bienvenido a nuestra <b>fantástica</b> tienda de comestibles!
```

Si ejecutamos esta plantilla como antes, obtendremos:

```html
<p>¡Bienvenido a nuestra  &lt;b&gt;fantástica&lt;/b&gt; tienda de comestibles!</p>
```

Lo que no es exactamente lo que esperábamos, porque nuestra etiqueta `<b>` ha 
sido escapada y por lo tanto será visualizada en el navegador.

Este es el comportamiento por defecto del atributo `th:text`. Si queremos que 
Thymeleaf respete nuestras etiquetas HTML y no las escape, tendremos que usar un 
atributo diferente: `th:utext` (para "texto sin escape"):

```html
<p th:utext="#{home.welcome}">¡Bienvenido a nuestra tienda de comestibles!</p>
```

Esto sacará nuestro mensaje tal como lo queríamos:


```html
<p>¡Bienvenido a nuestra <b>fantástica</b> tienda de comestibles!</p>
```


### Uso y visualización de variables

Ahora agreguemos algo de más contenido a nuestra página de inicio. Por ejemplo, 
podremos querer visualizar la fecha debajo de nuestor mensaje de bievenida, así:

```
¡Bienvenido a nuestra fantástica tienda de comestibles!

Hoy es: 12 julio 2010
```

En primer lugar, tendremos que modificar nuestro controlador para que agreguemos 
esa fecha como variable de contexto:

```java
public void process(
        final IWebExchange webExchange, 
        final ITemplateEngine templateEngine,
        final Writer writer)
        throws Exception {
        
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMMM yyyy");
    Calendar cal = Calendar.getInstance();

    WebContext ctx = new WebContext(webExchange, webExchange.getLocale());
    ctx.setVariable("today", dateFormat.format(cal.getTime()));
    
    templateEngine.process("home", ctx, writer);

}
```

Hemos agregado una variable `String` llamada `today` a nuestro contexto, y ahora 
podemos visualizarla en nuestra plantilla:
```html
<body>

  <p th:utext="#{home.welcome}">¡Bienvenido a nuestra tienda de comestibles!</p>

  <p>Hoy es: <span th:text="${today}">13 febrero 2011</span></p>
  
</body>
```

Como puede ver, estamos aún usando el atributo `th:text` para el trabajo (y eso 
es correcto, poque queremos reemplazar el cuerpor de la etiqueta), pero la 
sintaxis es un poquito diferente esta vez y en vez de una expresión de valor 
`#{...}`, estamos usando una `${...}`. Esta es una **expresión de variable**, 
y contiene una expresión en un lenguaje llamado _OGNL (Object-Graph Navigation 
Language)_ (Lenguaje de Navegación de Objetos-Gráficos) que será ejecutado en el 
mapa de variables del contexto del que hablamos antes.

La expresión `${today}` simplemente significa "obtén la variable llamada today", 
pero estas expresiones podrían ser más complejas (como `${user.name}`) para 
"obtener la variable llamada usuario, y llamar su método "getName()"

Existen muchas posibilidades en los valores de los atributos: mensajes, 
expresiones de variables... y mucho más. El siguiente capítulo nos mostrará 
cuáles son todas estas posibilidades.




4\. Sintaxis de expresiones estándar
====================================

Nos tomaremos un pequeño descanso en el desarrollo de nuestra tienda virtual de 
comestibles para aprender sobre una de las partes más importantes del Dialecto 
Estándar de Thymeleaf: La sintaxis de las Expresiones Estándar de Thymeleaf:

```html
<p th:utext="#{home.welcome}">¡Bienvenido a nuestra tienda de comestibles!</p>

<p>Hoy es: <span th:text="${today}">13 febrero 2011</span></p>
```

Pero existen más tipos de expresiones, y más detalles interesantes que aprender 
sobre las que ya conocemos. Primero, veamos un breve resumen de las 
características de las expresiones estándar:


 * Expresiones simples:
    * Expresiones de Variable: `${...}`
    * Expresiones de Variable de Selección: `*{...}`
    * Expresiones de Mensaje: `#{...}`
    * Expresiones de Enlace URL: `@{...}`
    * Expresiones de Fragmento: `~{...}`
 * Literales
    * Literales de texto: `'one text'`, `'Another one!'`,...
    * Literales de número: `0`, `34`, `3.0`, `12.3`,...
    * Literales booleanos: `true`, `false`
    * Literal nulo (null): `null`
    * Literal de ficha (token): `one`, `sometext`, `main`,...
 * Operaciones de texto: 
    * Concatenación de cadenas: `+`
    * Substituciones en literales: `|The name is ${name}|`
 * Operaciones aritméticas:
    * Operadores binarios: `+`, `-`, `*`, `/`, `%`
    * Signo menos (operador unario): `-`
 * Operadores lógicos:
    * Operadores binarios: `and`, `or`
    * Negación lógica (operador unario): `!`, `not`
 * Comparaciones e igualdad:
    * Comparadores: `>`, `<`, `>=`, `<=` (`gt`, `lt`, `ge`, `le`)
    * Operadores de igualdad: `==`, `!=` (`eq`, `ne`)
 * Operadores condicionales:
    * If-then: `(if) ? (then)`
    * If-then-else: `(if) ? (then) : (else)`
    * Valor por defecto: `(value) ?: (defaultvalue)`
 * Fichas (Tokens) especiales :
    * Operación nula: `_`

Todas estas características pueden combinarse y anidarse:

```html
'Usuario es del tipo: ' + ( ' + (${user.isAdmin()} ? 'Administrador' : (${user.type} ?: 'Desconocido'))
```



4.1 Mensajes
------------

Como ya sabemos, las expresiones de mensaje `#{...}` nos permiten vincular esto:

```html
<p th:utext="#{home.welcome}">¡Bienvenido a nuestra tienda de comestibles!</p>
```

...a esto:

```
home.welcome=¡Bienvenido a nuestra tienda de comestibles!
```

Pero hay un aspecto que aún no hemos considerado: ¿qué ocurre si el texto del 
mensaje no es completamente estático? ¿Qué ocurriría, por ejemplo, si nuestra 
aplicación sabía quién es el usuario que visita el sitio en cualquier momento y 
queremos saludarle por su nombre?


```html
<p>¡Bienvenido a nuestra tienda de comestibles, John Apricot!</p>
```

Esto significa que necesitaríamos agregar un parámetro a nuestro mensaje. Así:

```
home.welcome=¡Bienvenido a nuestra tienda de comestibles, {0}!
```

Los parámetros se especifican de acuerdo a la sintaxis estándar de 
[`java.text.MessageFormat`](https://docs.oracle.com/javase/10/docs/api/java/text/MessageFormat.html)
, lo cual significa que puede dar formato a números y fechas como se especifica 
en los documentos de las IPA para las clases en el paquete `java.text.*`.

Para especificar un valor para nuestro parámetro, y dado un atributo de sesión 
llamado `user`, podríamos tener:

```html
<p th:utext="#{home.welcome(${session.user.name})}">
  ¡Bienvenido a nuestra tienda de comestibles, Sebastian Pepper!
</p>
```

> Dese cuenta que el uso de `th:utext` aquí significa que el mensaje con formato 
> no será escapado. Este ejemplo asume que `user.name` ya está escapado.

Se pueden especificar varios parámetros, separados por comas.

La misma clave del mensaje puede provenir de una variable: 


```html
<p th:utext="#{${welcomeMsgKey}(${session.user.name})}">
    ¡Bienvenido a nuestra tienda de comestibles, Sebastian Pepper!
</p>
```



4.2 Variables
-------------

Ya mencionamos que las expresiones `${...}` son en realidad expresiones OGNL
(Lenguaje de Navegación Objeto-Gráfico) ejecutadas sobre el mapa de variables 
contenidas en el contexto.

> Para información detallada sobre la sintaxis OGNL y sus características, 
> consulte la guía [Guía del Lenguaje OGNL](http://commons.apache.org/ognl/)
> 
> En aplicaciones que habilitan Spring MVC OGNL será reemplazado con **SpringEL**,
> pero su sintaxis es muy similiar a la de OGNL (En realidad, exactamente lo 
> mismo para la mayoría de los casos comunes).

De la sintaxis de OGNL, sabemos que la expresión en:

```html
<p>Hoy es: <span th:text="${today}">13 febrero 2011</span>.</p>
```

...es en realidad equivalente a esto:

```java
ctx.getVariable("today");
```

Pero OGNL nos permite crear expresiones mucho más potentes, y así es como 
funciona esto:

```html
<p th:utext="#{home.welcome(${session.user.name})}">
    ¡Bienvenido a nuestra tienda de comestibles, Sebastian Pepper!
</p>
```

...obtiene el nombre de usuario ejecutando:

```java
((User) ctx.getVariable("session").get("user")).getName();
```

Pero la navegación por métodos getter es solo una de las características de 
OGNL. Veamos más:

```java
/*
 * Acceso a propiedades usando el punto  (.). Es equivalente a llamar a los getters de la propiedad.
 */
${person.father.name}

/*
 * El acceso a propiedades puede también realizarse usando corchetes ([]) y 
 * escribir el nombre de la propiedad como una variable o entre comillas simples.
 */
${person['father']['name']}

/*
 * Si el objeto es un map, tanto el punto como la sintaxis de corchete serán 
 * equivalentes a ejecutar una llamada a su método get(...).
 */
${countriesByCode.ES}
${personsByName['Stephen Zucchini'].age}

/*
 * El acceso indexado a matrices o colecciones se realizar también con corchetes, 
 * escribiendo el índice sin comillas.
 */
${personsArray[0].name}

/*
 * Se puede llamar a los métodos, incluso con argumentos.
 */
${person.createCompleteName()}
${person.createCompleteNameWithSeparator('-')}
```


### Objetos básicos de Expresiones OGNL

Cuando se evaluan las expresiones OGNL en las variables del contexto, algunos 
objetos se ponen a disposición de las expresiones para mayor flexibilidad. Estos 
 objetos se referenciarán (según el estándar OGNL) comenzando con el símbolo `#`:

 * `#ctx`: el objeto de contexto.
 * `#vars:` las variables del contexto.
 * `#locale`: la configuración regional del contexto.

Así que podemos hacer esto:

```html
País de configuración regional establecido: <span th:text="${#locale.country}">ES</span>.
```

Puede leer la referencia completa de estos objetos en el [Apéndice A](#appendix-a-expression-basic-objects). 


### Objetos de utilidad de expresión

Además de estos objetos básicos, Thymeleaf nos ofrecerá un conjunto de objetos de 
utilidad que nos ayudarán a realizar tareas comunes en nuestras expresiones.

 * `#execInfo`: información sobre la plantilla que está siendo procesada.
 * `#messages`: métodos par obtener mensajes externalizados dentro de expresiones 
    de variables, en la misma forma que serían obtenidas usando la sintaxis 
    #{...}. 
 * `#uris`: métodos para escapar partes de las URLs/URIs
 * `#conversions`: métodos para la ejecución del *servicio de conversión* 
    configurado (si lo hay).
 * `#dates`: métodos para objetos `java.util.Date`: formateado, extracción de 
    componentes, etc.
 * `#calendars`: análogo a `#dates`, pero para objetos `java.util.Calendar`.
 * `#temporals`: para tratar con fechas y horas utilizando la API `java.time` 
    en JDK8+.
 * `#numbers`: métodos para formatear objetos numéricos.
 * `#strings`: métodos para objetos `String`: contiene, comienza con, 
    anteponer/agregar, etc.
 * `#objects`: métodos para objetos en general.
 * `#bools`: métodos para la evaluación booleana.
 * `#arrays`: métodos para matrices.
 * `#lists`: métodos para listas.
 * `#sets`: métodos para conjuntos.
 * `#maps`: métodos para mapas.
 * `#aggregates`: métodos para crear agregados en matrices o colecciones.
 * `#ids`: métodos para tratar con atributos de identificación que podrían 
    repetirse (por ejemplo, como resultado de una iteración).

Puede comprobar qué funciones se ofrecen para cada uno de estos objetos de 
utilidad en el [Apéndice B](#appendix-b-expression-utility-objects).


### Reformateando las fechas en nuestra página de inicio

Ahora que sabemos de estos objetos de utilidad, podríamos usarlos para cambiar 
la forma en que mostramos la fecha en nuestra página de inicio. En vez de hacer 
esto en nuestro `HomeController`:

```java
SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMMM yyyy");
Calendar cal = Calendar.getInstance();

WebContext ctx = new WebContext(webExchange, webExchange.getLocale());
ctx.setVariable("today", dateFormat.format(cal.getTime()));

templateEngine.process("home", ctx, writer);
```

...podemos hacer precisamente esto:

```java
WebContext ctx = new WebContext(webExchange, webExchange.getLocale());
ctx.setVariable("today", Calendar.getInstance());

templateEngine.process("home", ctx, writer);
```

...y luego realizar el formato de fecha en la propia capa de vista:

```html
<p>
  Hoy es: <span th:text="${#calendars.format(today,'dd MMMM yyyy')}">13 Mayo 2011</span>
</p>
```



4.3 Expresiones en selecciones (sintaxis de asterisco)
------------------------------------------------------

No solo las expresiones de variables pueden ser escritas como `${...}`, si no 
también como `*{...}`.


Sin embargo, existe una diferencia importante: la sintaxis del asterisco evalúa 
las expresiones en _objetos seleccionados_ en lugar de en todo el contexto. 
Es decir, mientras no haya ningún objeto seleccionado, las sintaxis del dólar y 
del asterisco hacen exactamente lo mismo.

¿Y qué es un objeto seleccionado? El resultado de una expresión que usa el 
atributo `th:object`. Usemos uno en nuestra página de perfil de usuario 
(`userprofile.html`):

```html
  <div th:object="${session.user}">
    <p>Nombre: <span th:text="*{firstName}">Sebastian</span>.</p>
    <p>Apellidos: <span th:text="*{lastName}">Pepper</span>.</p>
    <p>Nacionalidad: <span th:text="*{nationality}">Saturno</span>.</p>
  </div>
```

Lo cual es exactamente equivalente a:

```html
<div>
  <p>Nombre: <span th:text="${session.user.firstName}">Sebastian</span>.</p>
  <p>Apellidos: <span th:text="${session.user.lastName}">Pepper</span>.</p>
  <p>Nacionalidad: <span th:text="${session.user.nationality}">Saturno</span>.</p>
</div>
```

Por supuesto, la sintaxis del dólar y del asterisco se puede mezclar:

```html
<div th:object="${session.user}">
  <p>Nombre: <span th:text="*{firstName}">Sebastian</span>.</p>
  <p>Apellidos: <span th:text="${session.user.lastName}">Pepper</span>.</p>
  <p>Nacionalidad: <span th:text="*{nationality}">Saturno</span>.</p>
</div>
```

Cuando hay una selección de objetos en su lugar, el objeto seleccionado también 
estará disponible para las expresiones en dólares como la variable de expresión 
`#object`:

```html
<div th:object="${session.user}">
  <p>Nombre: <span th:text="${#object.firstName}">Sebastian</span>.</p>
  <p>Apellidos: <span th:text="${session.user.lastName}">Pepper</span>.</p>
  <p>Nacionalidad: <span th:text="*{nationality}">Saturno</span>.</p>
</div>
```

Como se dijo, si no se ha realizado ninguna selección de objetos, las sintaxis 
de dólar y asterisco son equivalentes.

```html
<div>
  <p>Nombre: <span th:text="*{session.user.name}">Sebastian</span>.</p>
  <p>Apellidos: <span th:text="*{session.user.surname}">Pepper</span>.</p>
  <p>Nacionalidad: <span th:text="*{session.user.nationality}">Saturno</span>.</p>
</div>
```


4.4 Enlaces a URLs
------------------

Debido a su importancia, las URLs son ciudadanas de primera clase en las 
plantillas de aplicaciones web, y el _Dialecto Estándar de Thymeleaf_ tiene una 
sintaxis especial para ellas, la sintaxis `@`: `@{...}`

Hay diferentes tipos de URLs:
There are different types of URLs:

 * URLs absolutas: `http://www.thymeleaf.org`
 *  URLs relativas, las cuales pueden ser:
    * relativas a la página: `user/login.html`
    * relativas al contexto: `/itemdetails?id=3` (el nombre del contexto en el 
      servidor será agregado automáticamente)
    * relativas al servidor: `~/billing/processInvoice` (permite llamar URLS en 
      otros contextos (= aplicación) en el mismo servidor.
    * URLs relativas al protocolo: `//code.jquery.com/jquery-2.0.3.min.js`

El procesado real de estasa expresiones y sus conversiones a las URLs que serán
mostradas se hace por implementaciones de la interfaz `org.thymeleaf.linkbuilder.ILinkBuilder`
que está registrada dentro del objeto `ITemplateEngine` que está siendo usado.

De forma predeterminada, se registra una única implementación de esta interfaz 
de la clase `org.thymeleaf.linkbuilder.StandardLinkBuilder`, lo cual es 
suficiente tanto para entornos web como offline basados en la API de Servlet. 
Otros escenarios (como la integración con frameworks web que no utilizan la API 
de Servlet) podrían requerir implementaciones específicas de la interfaz del 
constructor de enlaces.

Usemos esta nueva sintaxis. Conozca el atributo `th:href`:

```html
<!-- Producirá 'http://localhost:8080/gtvg/order/details?orderId=3' (mas reescritura) -->
<a href="details.html" 
   th:href="@{http://localhost:8080/gtvg/order/details(orderId=${o.id})}">view</a>

<!-- Producirá '/gtvg/order/details?orderId=3' (mas reescritura) -->
<a href="details.html" th:href="@{/order/details(orderId=${o.id})}">view</a>

<!-- Producirá '/gtvg/order/3/details' (mas reescritura) -->
<a href="details.html" th:href="@{/order/{orderId}/details(orderId=${o.id})}">view</a>
```

Algunas cosas a tener en cuenta aquí:

 * `th:href` es un atributo modificador: una vez procesado, calculará la URL del 
   enlace que se utilizará y establecerá ese valor en el atributo `href` de la 
   etiqueta `<a>`.
 * Se permite usar expresiones para los parámetros de URL (como se puede ver en 
   `orderId=${o.id}`). Las operaciones de codificación de parámetros de URL 
   requeridas también se realizarán automáticamente.
 * Si se necesitan varios parámetros, se separarán con comas: 
   `@{/order/process(execId=${execId},execType='FAST')}`
 * También se permiten plantillas de variables en las rutas de URL: 
   `@{/order/{orderId}/details(orderId=${orderId})}`
 * Las URL relativas que empiezan por `/` (p. ej., `/order/details`) tendrán 
   automáticamente como prefijo el nombre del contexto de la aplicación.
 * Si las cookies no están habilitadas o aún no se conoce, se podría añadir el 
   sufijo `";jsessionid=..."` a las URL relativas para preservar la sesión. Esto 
   se llama _Reescritura de URL_ y Thymeleaf te permite conectar tus propios 
   filtros de reescritura mediante el mecanismo `response.encodeURL(...)` de la 
   API de Servlet para cada URL.
 * El atributo `th:href` nos permite (opcionalmente) tener un atributo `href` 
   estático funcional en nuestra plantilla, de modo que los enlaces de nuestra 
   plantilla sigan siendo navegables por un navegador al abrirlos directamente 
   para fines de creación de prototipos.

Como fue el caso con la sintaxis de mensajes (`#{...}`) las bases de las URL 
pueden ser el resultado de evaluar otra expresión:

```html
<a th:href="@{${url}(orderId=${o.id})}">vista</a>
<a th:href="@{'/details/'+${user.login}(orderId=${o.id})}">vista</a>
```


### Un menú para nuestra página de inicio

Ahora que sabemos como crear URLs de enlace, ¿Qué tal si añadimos un pequeño 
menú en nuestra página de inicio para algunas de las otras páginas del sitio?

```html
<p>Por favor, seleccione una opción</p>
<ol>
  <li><a href="product/list.html" th:href="@{/product/list}">Lista de Productos</a></li>
  <li><a href="order/list.html" th:href="@{/order/list}">Lista de Pedidos</a></li>
  <li><a href="subscribe.html" th:href="@{/subscribe}">Suscríbete a nuestro boletín informativo</a></li>
  <li><a href="userprofile.html" th:href="@{/userprofile}">Ver perfil de usuario</a></li>
</ol>
```


### URLs relativas a la raíz del servidor

Se puede usar una sintaxis adicional para crear URLs relativas a la raíz del 
servidor (en vez de relativas a la raíz del contexto) para enlazar a diferentes 
contextos en el mismo servidor. Estas URLs se especificarán como 
`@{~/path/to/something}`



4.5 Fragmentos
-------------

Las expresiones de fragmento son una forma fácil de representar fragmentos de 
marcoad y moverlos entre las plantillas. Esto nos permite replicarlas, pasarlas 
a otras plantilas como argumentos, etc.

El uso más común es para la inserción de fragmentos usando `th:insert` o 
`th:replace` (más sobre esto en una sección posterior):
(more on these in a later section):

```html
<div th:insert="~{commons :: main}">...</div>
```
Pero pueden ser utilizadas en cualquier parte, al igual que cualquier otra 
variable:

```html
<div th:with="frag=~{footer :: #main/text()}">
  <p th:insert="${frag}"></p>
</div>
```

Más tarde en este tutorial hay una sección entera dedicada al Diseño de 
Plantillas, incluyendo una explicación más profunda de las expresiones de 
fragmento.



4.6 Literales
------------

### Literales de texto

Los literales de texto son simplemente cadenas de caracteres delimitados entre 
comillas simples. Pueden incluir cualquier carácter, pero deberá escapar 
cualquier comilla simple dentro de ellas usando `\'`.

```html
<p>
  Ahora está mirando un  <span th:text="'aplicación web funcional'">fichero de plantilla</span>.
</p>
```

### Literales numéricos

Los literales numéricos son simplemente eso: números.

```html
<p>El año es  <span th:text="2013">1492</span>.</p>
<p>En dos años, será <span th:text="2013 + 2">1494</span>.</p>
```


### Literales booleanos

Los literales booleano son `true` y `false`. Por ejemplo:

```html
<div th:if="${user.isAdmin()} == false"> ...
```

En este ejemplo, el `== false` está escrito fuera de las llaves, y así es 
Thymeleaf quien se cuida de ello. Si estuviera escrito dentro de las llaves, 
sería responsabilidad de los motores OGNL/SpringEL:

```html
<div th:if="${user.isAdmin() == false}"> ...
```


### El literal null (nulo)

El literal `null` puede ser también usado:

```html
<div th:if="${variable.something} == null"> ...
```


### Literales de identificadores (tokens)

Los literales numéricos, booleanos y nulo son en realidad un caso particular de 
_fichas literales_.

Estas fichas (tokens) permiten un poco de simplificación en las Expresiones 
Estándar. Trabajan exactamente de la misma forma que los literales de texto 
(`'...'`), pero estos solo permiten letras  (`A-Z` y `a-z`), números (`0-9`), 
corchetes (`[` y `]`), puntos (`.`), guiones (`-`) y subrayados (`_`). Así que 
nada de espacios en blanco, ni comas, etc.

¿Lo bueno? Los tokens no necesitan comillas. Así que podemos hacer esto:

```html
<div th:class="content">...</div>
```

en lugar de:

```html
<div th:class="'content'">...</div>
```



4.7 Agregar textos
-------------------

Los textos, sin importar si son literales o el resultado de evaluar expresiones 
variables o de mensajes, se pueden agregar fácilmente usando el operador `+`:

```html
<span th:text="'El nombre del usuario es ' + ${user.name}">
```



4.8 Sustituciones de literales
-------------------------

Las sustituciones literales permiten formatear fácilmente cadenas que contienen 
valores de variables sin la necesidad de agregar literales con '...' + '...'`.

Estas sustituciones deben estar rodeadas de barras verticales (`|`), como:

```html
<span th:text="|¡Bienvenido a nuestra aplicación, ${user.name}!|">
```

Lo cual es equivalente a:

```html
<span th:text="'¡Bienvenido a nuestra aplicación, ' + ${user.name} + '!'">
```

Las sustituciones literales se pueden combinar con otros tipos de expresiones:

```html
<span th:text="${onevar} + ' ' + |${twovar}, ${threevar}|">
```
> Solo las expresiones de mensaje/variables (`${...}`, `*{...}`, `#{...}`) se 
> permiten dentro de las substituciones de literales `|...|`. No se permiten 
> otros literales (`'...'`), tokens booleanos/numéricos, expresiones 
> condicionales, etc. 



4.9 Operaciones aritméticas
-------------------------

También se encuentran disponibles algunas operaciones aritméticas: 
`+`, `-`, `*`, `/` y `%`.

```html
<div th:with="isEven=(${prodStat.count} % 2 == 0)">
```
Dese cuenta que estos operadores pueden también ser utilizados dentro de 
expresiones OGNL por sí mismos (y en ese caso serán ejecutados por OGNL en vez 
del motor de Expresiones Estándar de Thymeleaf):

```html
<div th:with="isEven=${prodStat.count % 2 == 0}">
```

Dese cuenta que existen aliases textuales para algunos de estos operadores: 
`div` (`/`), `mod` (`%`).



4.10 Comparadores e igualdad 
-----------------------------

Los valores en las expresiones pueden compararse con los símbolos 
`>`, `<`, `>=` y `<=`, y los operadores `==` y `!=` se pueden utilizar para 
comprobar la igualdad (o la ausencia de ella). Dese cuenta de que XML establece 
que los símbolos `<` y `>` no deberían utilizarse como valores de atributos, y 
por ello deben sustituirse por `&lt;` y `&gt;`.

```html
<div th:if="${prodStat.count} &gt; 1">
<span th:text="'El modo de ejecución es ' + ( (${execMode} == 'dev')? 'Desarrollo' : 'Producción')">
```

Una alternativa más simple podría ser usar los alias textuales que existen para 
algunos de estos operandos: `gt` (`>`), `lt` (`<`), `ge` (`>=`), `le` (`<=`), 
`not` (`!`). También `eq` (`==`), `neq`/`ne` (`!=`).



4.11 Expresiones condicionales
----------------------------

Las _expresiones condicionales_ están destinadas a evaluar solo una de dos 
expresiones dependiendo del resultado de evaluar una condición (que es en sí 
otra expresión).

Echemos una mirada a un fragmento de ejemplo (introduciendo otro _modificador de 
atributos_, `th:class`):

```html
<tr th:class="${row.even}? 'even' : 'odd'">
  ...
</tr>
```

Todas las partes de una expresión condicional (`condition`, `then` y `else`) son 
por sí mismas expresiones, lo que significa que pueden ser variables (`${...}`, 
`*{...}`), mensajes (`#{...}`), URLs (`@{...}`) o literales (`'...'`).

Las expresiones condicionales pueden tambien anidarse usando paréntesis:

```html
<tr th:class="${row.even}? (${row.first}? 'first' : 'even') : 'odd'">
  ...
</tr>
```

Las expresiones Else (si no, N. del T.) pueden omitirse, en cuyo caso se devuelve 
un valor nulo si la condición es falsa:

```html
<tr th:class="${row.even}? 'alt'">
  ...
</tr>
```



4.12  Expresiones predeterminadas (operador Elvis)
-----------------------------------------

Una _expresión por defecto_ es una clase especial de valor condicional sin una 
parte _then_. Es el equivalente al _Operador elvis_ presente en algunos lenguajes 
como Groovy, permitiéndole especificar dos expresiones: la primera se usa si no 
evalúa a nulo, pero si lo hace entonce se usa la segunda.

Veamos esto en acción en nuestra página de perfil de usuario:

```html
<div th:object="${session.user}">
  ...
  <p>Edad: <span th:text="*{age}?: '(sin edad especificada)'">27</span>.</p>
</div>
```
Como puede ver, el operador es `?:`, y lo usamos aquí para especificar un valor 
por defecto para un nombre (un valor literal, en este caso) solo si el resultado 
de evaluar `*{age}` es nulo. Esto es por lo tanto equivalente a:

```html
<p>Edad: <span th:text="*{age != null}? *{age} : '(sin edad especificada)'">27</span>.</p>
```

Como con los valores condicionales, pueden contener expresiones anidadas entre 
paréntesis:

```html
<p>
  Nombre: 
  <span th:text="*{firstName}?: (*{admin}? 'Administrador' : #{default.username})">Sebastian</span>
</p>
```



4.13 El token de no operación
-----------------------------

La ficha No-Operación se representa por un símbolo de subrayado (`_`).

La idea detrás de esta ficha es especificar que el resultado deseado para una 
expresión es *no hacer nada*, por ejemplo, haga exactamente como si el atributo 
procesable (por ejemplo, `th:text`) no existiera en absoluto.

Entre otras posibilidades, esto permite a los desarrolladores a usar texto 
prototipado como valores por defecto. Por ejemplo, en vez de:

```html
<span th:text="${user.name} ?: 'usuario no autenticado'">...</span>
```
... podmeos usar directamente *'usuario no autenticado'* como un texto 
prototipado, lo que resulta en un código que es más conciso y versátil desde un 
punto de vista de diseño:

```html
<span th:text="${user.name} ?: _">usuario no autenticado</span>
```



4.14 Conversión y Formato de datos 
---------------------------------
Thymeleaf define una sintaxis de *dobles llaves* para las expresiones de 
variables (`${...}`) y selección (`*{...}`) que nos permite aplicar 
*conversiones de datos* mediante un *servicio de conversión* configurado.

Básicamente funciona así:

```html
<td th:text="${{user.lastAccessDate}}">...</td>
```
¿Ha notado la doble llave?: `${{...}}`. Esto indica a Thymeleaf que pase el 
resultado de la expresión `user.lastAccessDate` al *servicio de conversión* y le 
solicita que realice una **operación de formato** (una conversión a `String`) 
antes de escribir el resultado.

Suponiendo que `user.lastAccessDate` es del tipo `java.util.Calendar`, si se ha 
registrado un *servicio de conversión* (implementación de 
`IStandardConversionService`) y contiene una conversión válida para 
`Calendar -> String`, se aplicará.

La implementación predeterminada de `IStandardConversionService` (la clase 
`StandardConversionService`) simplemente ejecuta `.toString()` en cualquier 
objeto convertido a `String`. Para obtener más información sobre cómo registrar 
una implementación personalizada de *servicio de conversión*, consulte la 
sección [Más sobre la configuración](#more-on-configuration).

> Los paquetes de integración oficiales thymeleaf-spring3 y thymeleaf-spring4 
> integran de forma transparente el mecanismo del servicio de conversión de 
> Thymeleaf con la infraestructura propia del *Servicio de Conversión* de 
> Spring, de modo que los servicios de conversión y los formateadores declarados 
> en la configuración de Spring estarán disponibles automáticamente para las 
> expresiones `${{...}}` y `*{{...}}`.



4.15 Preprocesamiento
------------------

Además de todas estas funciones para el procesamiento de expresiones, Thymeleaf 
cuenta con la función de preprocesar expresiones.

El preprocesamiento consiste en ejecutar las expresiones antes de la normal, lo 
que permite modificar la expresión que finalmente se ejecutará.

Las expresiones preprocesadas son exactamente iguales a las normales, pero 
aparecen rodeadas por un doble guión bajo (como `__${expression}__`).

Imaginemos que tenemos una entrada `Messages_fr.properties` de i18n que contiene 
una expresión OGNL que llama a un método estático específico del lenguaje, como:

```java
article.text=@myapp.translator.Translator@translateToFrench({0})
```

...y un equivalente de `Messages_es.properties`:

```java
article.text=@myapp.translator.Translator@translateToSpanish({0})
```

Podemos crear un fragmento de marcado que evalúe una u otra expresión según la 
configuración regional. Para ello, primero seleccionaremos la expresión 
(mediante preprocesamiento) y luego dejaremos que Thymeleaf la ejecute:...

```html
<p th:text="${__#{article.text('textVar')}__}">Algún texto aquí...</p>
```

y un equivalente de `Messages_es.properties`:

```java
article.text=@myapp.translator.Translator@translateToSpanish({0})
```
Tenga en cuenta que el paso de preprocesamiento para una configuración regional 
en francés creará el siguiente equivalente:

```html
<p th:text="${@myapp.translator.Translator@translateToFrench(textVar)}">Algo de texto aquí...</p>
```

La cadena de preprocesamiento `__` se puede escapar en los atributos 
usando `\_\_`.


5\. Establecer valores de atributos
==========================

Este capítulo explicará la forma en que podemos establecer (o modificar) valores 
de atributos en nuestro marcado.


5.1 Establecer el valor de cualquier atributo
--------------------------------------

Digamos que nuestro sitio web publica un boletín informativo y queremos que 
nuestros usuarios puedan suscribirse a él, por lo que creamos una plantilla 
`/WEB-INF/templates/subscribe.html` con un formulario:

```html
<form action="subscribe.html">
  <fieldset>
    <input type="text" name="email" />
    <input type="submit" value="¡Subscribase!" />
  </fieldset>
</form>
```
Al igual que con Thymeleaf, esta plantilla se parece más a un prototipo estático 
que a una plantilla para una aplicación web. En primer lugar, el atributo 
`action` de nuestro formulario enlaza estáticamente al archivo de plantilla, lo 
que evita la reescritura de URLs. En segundo lugar, el atributo `value` del 
botón de envío muestra un texto en inglés, pero nos gustaría que estuviera 
internacionalizado.

Ingrese entonces el atributo `th:attr` y su capacidad para cambiar el valor de 
los atributos de las etiquetas en las que está configurado:

```html
<form action="subscribe.html" th:attr="action=@{/subscribe}">
  <fieldset>
    <input type="text" name="email" />
    <input type="submit" value="¡Subscribase!" th:attr="value=#{subscribe.submit}"/>
  </fieldset>
</form>
```
El concepto es bastante sencillo: `th:attr` simplemente toma una expresión que 
asigna un valor a un atributo. Tras crear los archivos de controlador y mensajes 
correspondientes, el resultado del procesamiento de este archivo será:

```html
<form action="/gtvg/subscribe">
  <fieldset>
    <input type="text" name="email" />
    <input type="submit" value="¡Suscríbase!"/>
  </fieldset>
</form>
```
Además de los nuevos valores de atributos, también puedes ver que el nombre del 
contexto de la aplicación se ha prefijado automáticamente a la base de URL en 
`/gtvg/subscribe`, como se explicó en el capítulo anterior.

¿Y si quisiéramos configurar más de un atributo a la vez? Las reglas XML no 
permiten configurar un atributo dos veces en una etiqueta, por lo que `th:attr` 
tomará una lista de asignaciones separadas por comas, como:

```html
<img src="../../images/gtvglogo.png" 
     th:attr="src=@{/images/gtvglogo.png},title=#{logo},alt=#{logo}" />
```

Dados los archivos de mensajes necesarios, esto generará:

```html
<img src="/gtgv/images/gtvglogo.png" title="Logo de Good Thymes" alt="Logo de Good Thymes" />
```



5.2 Establecer valores para atributos específicos
-------------------------------------------------

By now, you might be thinking that something like:

```html
<input type="submit" value="Subscribe!" th:attr="value=#{subscribe.submit}"/>
```

...is quite an ugly piece of markup. Specifying an assignment inside an
attribute's value can be very practical, but it is not the most elegant way of
creating templates if you have to do it all the time.

Thymeleaf agrees with you, and that's why `th:attr` is scarcely used in
templates. Normally, you will be using other `th:*` attributes whose task is
setting specific tag attributes (and not just any attribute like `th:attr`).

For example, to set the `value` attribute, use `th:value`:

```html
<input type="submit" value="Subscribe!" th:value="#{subscribe.submit}"/>
```

This looks much better! Let's try and do the same to the `action` attribute in
the `form` tag:

```html
<form action="subscribe.html" th:action="@{/subscribe}">
```

And do you remember those `th:href` we put in our `home.html` before? They are
exactly this same kind of attributes:

```html
<li><a href="product/list.html" th:href="@{/product/list}">Lista de Productos</a></li>
```

There are quite a lot of attributes like these, each of them targeting a
specific HTML5 attribute:

---------------------- ---------------------- ----------------------
`th:abbr`              `th:accept`            `th:accept-charset`    
`th:accesskey`         `th:action`            `th:align`             
`th:alt`               `th:archive`           `th:audio`             
`th:autocomplete`      `th:axis`              `th:background`        
`th:bgcolor`           `th:border`            `th:cellpadding`       
`th:cellspacing`       `th:challenge`         `th:charset`           
`th:cite`              `th:class`             `th:classid`           
`th:codebase`          `th:codetype`          `th:cols`              
`th:colspan`           `th:compact`           `th:content`           
`th:contenteditable`   `th:contextmenu`       `th:data`              
`th:datetime`          `th:dir`               `th:draggable`         
`th:dropzone`          `th:enctype`           `th:for`               
`th:form`              `th:formaction`        `th:formenctype`       
`th:formmethod`        `th:formtarget`        `th:fragment`          
`th:frame`             `th:frameborder`       `th:headers`           
`th:height`            `th:high`              `th:href`              
`th:hreflang`          `th:hspace`            `th:http-equiv`        
`th:icon`              `th:id`                `th:inline`            
`th:keytype`           `th:kind`              `th:label`             
`th:lang`              `th:list`              `th:longdesc`          
`th:low`               `th:manifest`          `th:marginheight`      
`th:marginwidth`       `th:max`               `th:maxlength`         
`th:media`             `th:method`            `th:min`               
`th:name`              `th:onabort`           `th:onafterprint`      
`th:onbeforeprint`     `th:onbeforeunload`    `th:onblur`            
`th:oncanplay`         `th:oncanplaythrough`  `th:onchange`          
`th:onclick`           `th:oncontextmenu`     `th:ondblclick`        
`th:ondrag`            `th:ondragend`         `th:ondragenter`       
`th:ondragleave`       `th:ondragover`        `th:ondragstart`       
`th:ondrop`            `th:ondurationchange`  `th:onemptied`         
`th:onended`           `th:onerror`           `th:onfocus`           
`th:onformchange`      `th:onforminput`       `th:onhashchange`      
`th:oninput`           `th:oninvalid`         `th:onkeydown`         
`th:onkeypress`        `th:onkeyup`           `th:onload`            
`th:onloadeddata`      `th:onloadedmetadata`  `th:onloadstart`       
`th:onmessage`         `th:onmousedown`       `th:onmousemove`       
`th:onmouseout`        `th:onmouseover`       `th:onmouseup`         
`th:onmousewheel`      `th:onoffline`         `th:ononline`          
`th:onpause`           `th:onplay`            `th:onplaying`         
`th:onpopstate`        `th:onprogress`        `th:onratechange`      
`th:onreadystatechange``th:onredo`            `th:onreset`           
`th:onresize`          `th:onscroll`          `th:onseeked`          
`th:onseeking`         `th:onselect`          `th:onshow`            
`th:onstalled`         `th:onstorage`         `th:onsubmit`          
`th:onsuspend`         `th:ontimeupdate`      `th:onundo`            
`th:onunload`          `th:onvolumechange`    `th:onwaiting`         
`th:optimum`           `th:pattern`           `th:placeholder`       
`th:poster`            `th:preload`           `th:radiogroup`        
`th:rel`               `th:rev`               `th:rows`              
`th:rowspan`           `th:rules`             `th:sandbox`           
`th:scheme`            `th:scope`             `th:scrolling`         
`th:size`              `th:sizes`             `th:span`              
`th:spellcheck`        `th:src`               `th:srclang`           
`th:standby`           `th:start`             `th:step`              
`th:style`             `th:summary`           `th:tabindex`          
`th:target`            `th:title`             `th:type`              
`th:usemap`            `th:value`             `th:valuetype`         
`th:vspace`            `th:width`             `th:wrap`              
`th:xmlbase`           `th:xmllang`           `th:xmlspace`          
---------------------- ---------------------- ----------------------


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

...with this:

```html
<img src="../../images/gtvglogo.png" 
     th:src="@{/images/gtvglogo.png}" th:alt-title="#{logo}" />
```



5.4 Anexar y anteponer
----------------------

Thymeleaf also offers the `th:attrappend` and `th:attrprepend` attributes, which
append (suffix) or prepend (prefix) the result of their evaluation to the
existing attribute values.

For example, you might want to store the name of a CSS class to be added (not
set, just added) to one of your buttons in a context variable, because the
specific CSS class to be used would depend on something that the user did before:

```html
<input type="button" value="Do it!" class="btn" th:attrappend="class=${' ' + cssStyle}" />
```

If you process this template with the `cssStyle` variable set to `"warning"`,
you will get:

```html
<input type="button" value="Do it!" class="btn warning" />
```

There are also two specific _appending attributes_ in the Standard Dialect: the
`th:classappend` and `th:styleappend` attributes, which are used for adding a
CSS class or a fragment of _style_ to an element without overwriting the
existing ones:

```html
<tr th:each="prod : ${prods}" class="row" th:classappend="${prodStat.odd}? 'odd'">
```

(Don't worry about that `th:each` attribute. It is an _iterating attribute_ and
we will talk about it later.)



5.5 Atributos booleanos de valor fijo
-------------------------------------

HTML has the concept of _boolean attributes_, attributes that have no value and
the presence of one means that value is "true".  In XHTML, these attributes
take just 1 value, which is itself.

For example, `checked`:

```html
<input type="checkbox" name="option2" checked /> <!-- HTML -->
<input type="checkbox" name="option1" checked="checked" /> <!-- XHTML -->
```

The Standard Dialect includes attributes that allow you to set these attributes
by evaluating a condition, so that if evaluated to true, the attribute will be
set to its fixed value, and if evaluated to false, the attribute will not be set:

```html
<input type="checkbox" name="active" th:checked="${user.active}" />
```

The following fixed-value boolean attributes exist in the Standard Dialect:



------------------- ------------------ ------------------
`th:async`          `th:autofocus`     `th:autoplay`      
`th:checked`        `th:controls`      `th:declare`       
`th:default`        `th:defer`         `th:disabled`      
`th:formnovalidate` `th:hidden`        `th:ismap`         
`th:loop`           `th:multiple`      `th:novalidate`    
`th:nowrap`         `th:open`          `th:pubdate`       
`th:readonly`       `th:required`      `th:reversed`      
`th:scoped`         `th:seamless`      `th:selected`      
------------------- ------------------ ------------------




5.6 Compatibilidad con nombres de elementos y atributos compatibles con HTML5
-----------------------------------------------------------------------------

Thymeleaf offers a *default attribute processor* that allows us to set the value
of *any* attribute, even if no specific `th:*` processor has been defined for it
at the Standard Dialect.

So something like:

```html
<span th:whatever="${user.name}">...</span>
```

Will result in:

```html
<span whatever="John Apricot">...</span>
```



5.7 Compatibilidad con nombres de elementos y atributos compatibles con HTML5
----------------------------------------------------------

It is also possible to use a completely different syntax to apply processors to
your templates in a more HTML5-friendly manner.

```html	
<table>
    <tr data-th-each="user : ${users}">
        <td data-th-text="${user.login}">...</td>
        <td data-th-text="${user.name}">...</td>
    </tr>
</table>
```

The `data-{prefix}-{name}` syntax is the standard way to write custom attributes
in HTML5, without requiring developers to use any namespaced names like `th:*`.
Thymeleaf makes this syntax automatically available to all your dialects (not
only the Standard ones).

There is also a syntax to specify custom tags: `{prefix}-{name}`, which follows
the _W3C Custom Elements specification_ (a part of the larger _W3C Web
Components spec_). This can be used, for example, for the `th:block` element (or
also `th-block`), which will be explained in a later section. 

**Important:** this syntax is an addition to the namespaced `th:*` one, it does
not replace it. There is no intention at all to deprecate the namespaced syntax
in the future. 




6 Iteración
===========

So far we have created a home page, a user profile page and also a page for
letting users subscribe to our newsletter... but what about our products?  For
that, we will need a way to iterate over items in a collection to build out our
product page.



6.1 Conceptos básicos de iteración
----------------------------------

To display products in our `/WEB-INF/templates/product/list.html` page we will
use a table. Each of our products will be displayed in a row (a `<tr>` element),
and so for our template we will need to create a _template row_ -- one
that will exemplify how we want each product to be displayed -- and then instruct
Thymeleaf to repeat it, once for each product.

The Standard Dialect offers us an attribute for exactly that: `th:each`.


### Usando th:each

For our product list page, we will need a controller method that retrieves the
list of products from the service layer and adds it to the template context:

```java
public void process(
        final IWebExchange webExchange, 
        final ITemplateEngine templateEngine, 
        final Writer writer)
        throws Exception {
    
    final ProductService productService = new ProductService();
    final List<Product> allProducts = productService.findAll();
    
    final WebContext ctx = new WebContext(webExchange, webExchange.getLocale());
    ctx.setVariable("prods", allProducts);
    
    templateEngine.process("product/list", ctx, writer);
    
}
```

And then we will use `th:each` in our template to iterate over the list of
products:

```html
<!DOCTYPE html>

<html xmlns:th="http://www.thymeleaf.org">

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
the result of evaluating `${prods}`, repeat this fragment of template, using the
current element in a variable called prod". Let's give a name each of the things
we see:

 * We will call `${prods}` the _iterated expression_ or _iterated variable_.
 * We will call `prod` the _iteration variable_ or simply _iter variable_.

Note that the `prod` iter variable is scoped to the `<tr>` element, which means
it is available to inner tags like `<td>`.


### Valores iterables

The `java.util.List` class isn't the only value that can be used for iteration in
Thymeleaf. There is a quite complete set of objects that are considered _iterable_
by a `th:each` attribute:

 * Any object implementing `java.util.Iterable`
 * Any object implementing `java.util.Enumeration`.
 * Any object implementing `java.util.Iterator`, whose values will be used as
   they are returned by the iterator, without the need to cache all values in memory.
 * Any object implementing `java.util.Map`. When iterating maps, iter variables
   will be of class `java.util.Map.Entry`.
 * Any object implementing `java.util.stream.Stream`.
 * Any array.
 * Any other object will be treated as if it were a single-valued list
   containing the object itself.



6.2 Mantener el estado de la iteración
--------------------------------------

When using `th:each`, Thymeleaf offers a mechanism useful for keeping track of
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

Let's see how we could use it with the previous example:

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

The status variable (`iterStat` in this example) is defined in the `th:each`
attribute by writing its name after the iter variable itself, separated by a
comma. Just like the iter variable, the status variable is also scoped to the
fragment of code defined by the tag holding the `th:each` attribute.

Let's have a look at the result of processing our template:

```html
<!DOCTYPE html>

<html>

  <head>
    <title>Good Thymes Virtual Grocery</title>
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
    <link rel="stylesheet" type="text/css" media="all" href="/gtvg/css/gtvg.css" />
  </head>

  <body>

    <h1>Product list</h1>
  
    <table>
      <tr>
        <th>NAME</th>
        <th>PRICE</th>
        <th>IN STOCK</th>
      </tr>
      <tr class="odd">
        <td>Fresh Sweet Basil</td>
        <td>4.99</td>
        <td>yes</td>
      </tr>
      <tr>
        <td>Italian Tomato</td>
        <td>1.25</td>
        <td>no</td>
      </tr>
      <tr class="odd">
        <td>Yellow Bell Pepper</td>
        <td>2.50</td>
        <td>yes</td>
      </tr>
      <tr>
        <td>Old Cheddar</td>
        <td>18.75</td>
        <td>yes</td>
      </tr>
    </table>
  
    <p>
      <a href="/gtvg/" shape="rect">Return to home</a>
    </p>

  </body>
  
</html>
```

Note that our iteration status variable has worked perfectly, establishing the
`odd` CSS class only to odd rows.

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



6.3 Optimización mediante recuperación diferida de datos
--------------------------------------------------------

Sometimes we might want to optimize the retrieval of collections of data (e.g.
from a database) so that these collections are only retrieved if they are really
going to be used. 

> Actually, this is something that can be applied to *any* piece of data, but given the size
> that in-memory collections might have, retrieving collections that are meant to be iterated
> is the most common case for this scenario.

In order to support this, Thymeleaf offers a mechanism to *lazily load context
variables*. Context variables that implement the `ILazyContextVariable`
interface -- most probably by extending its `LazyContextVariable` default
implementation -- will be resolved in the moment of being executed. For example:

```java
context.setVariable(
     "users",
     new LazyContextVariable<List<User>>() {
         @Override
         protected List<User> loadValue() {
             return databaseRepository.findAllUsers();
         }
     });
```

This variable can be used without knowledge of its *laziness*, in code such as:

```html
<ul>
  <li th:each="u : ${users}" th:text="${u.name}">user name</li>
</ul>
```

But at the same time, will never be initialized (its `loadValue()` method will
never be called) if `condition` evaluates to `false` in code such as:

```html
<ul th:if="${condition}">
  <li th:each="u : ${users}" th:text="${u.name}">user name</li>
</ul>
```




7\. Evaluación condicional
==========================



7.1 Condicionales simples: "if" y "unless"
------------------------------------------

Sometimes you will need a fragment of your template to only appear in the result
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

This will create a link to the comments page (with URL `/product/comments`) with
a `prodId` parameter set to the `id` of the product, but only if the product has
any comments.

Let's have a look at the resulting markup:

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

Also, `th:if` has an inverse attribute, `th:unless`, which we could have used in
the previous example instead of using a `not` inside the OGNL expression:

```html
<a href="comments.html"
   th:href="@{/comments(prodId=${prod.id})}" 
   th:unless="${#lists.isEmpty(prod.comments)}">view</a>
```



7.2 Sentencias Switch
---------------------

There is also a way to display content conditionally using the equivalent of a
_switch_ structure in Java: the `th:switch` / `th:case` attribute set.

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




8\. Diseño de plantillas
========================



8.1 Incluyendo fragmentos de plantilla
--------------------------------------

### Definición y referencia de fragmentos

In our templates, we will often want to include parts from other templates,
parts like footers, headers, menus...

In order to do this, Thymeleaf needs us to define these parts, "fragments", for
inclusion, which can be done using the `th:fragment` attribute. 

Say we want to add a standard copyright footer to all our grocery pages, so we
create a `/WEB-INF/templates/footer.html` file containing this code:

```html
<!DOCTYPE html>

<html xmlns:th="http://www.thymeleaf.org">

  <body>
  
    <div th:fragment="copy">
      &copy; 2011 The Good Thymes Virtual Grocery
    </div>
  
  </body>
  
</html>
```

The code above defines a fragment called `copy` that we can easily include in
our home page using one of the `th:insert` or `th:replace` attributes:

```html
<body>

  ...

  <div th:insert="~{footer :: copy}"></div>
  
</body>
```

Note that `th:insert` expects a *fragment expression* (`~{...}`), which is *an
expression that results in a fragment*.


### Sintaxis de especificación de fragmentos

The syntax of *fragment expressions* is quite straightforward. There are three
different formats:

 * `"~{templatename::selector}"` Includes the fragment resulting from applying
   the specified Markup Selector on the template named `templatename`.  Note
   that `selector` can be a mere fragment name, so you could specify something
   as simple as `~{templatename::fragmentname}` like in the `~{footer :: copy}`
   above.

   > Markup Selector syntax is defined by the underlying AttoParser parsing
   > library, and is similar to XPath expressions or CSS selectors. See
   > [Appendix C](#appendix-c-markup-selector-syntax) for more info.

 * `"~{templatename}"` Includes the complete template named `templatename`.

   > Note that the template name you use in `th:insert`/`th:replace` tags
   > will have to be resolvable by the Template Resolver currently being used by
   > the Template Engine.

 * `~{::selector}"` or `"~{this::selector}"` Inserts a fragment from the same
   template, matching `selector`. If not found on the template where the expression
   appears, the stack of template calls (insertions) is traversed towards the
   originally processed template (the *root*), until `selector` matches at 
   some level.

Both `templatename` and `selector` in the above examples can be fully-featured
expressions (even conditionals!) like:

```html
<div th:insert="~{ footer :: (${user.isAdmin}? #{footer.admin} : #{footer.normaluser}) }"></div>
```

Fragments can include any `th:*` attributes. These attributes will be evaluated
once the fragment is included into the target template (the one with the `th:insert`/`th:replace`
attribute), and they will be able to reference any context variables defined in
this target template.

> A big advantage of this approach to fragments is that you can write your
> fragments in pages that are perfectly displayable by a browser, with a
> complete and even *valid* markup structure, while still retaining the ability
> to make Thymeleaf include them into other templates.


### Referenciar fragmentos sin `th:fragment`

Thanks to the power of Markup Selectors, we can include fragments that do not use any 
`th:fragment` attributes. It can even be markup code coming from a different application 
with no knowledge of Thymeleaf at all:

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

  <div th:insert="~{footer :: #copy-section}"></div>
  
</body>
```



### Difference between `th:insert` and `th:replace`

And what is the difference between `th:insert` and `th:replace`?

 * `th:insert` will simply insert the specified fragment as the body
   of its host tag.

 * `th:replace` actually *replaces* its host tag with the specified fragment.

So an HTML fragment like this:

```html
<footer th:fragment="copy">
  &copy; 2011 The Good Thymes Virtual Grocery
</footer>
```

...included twice in host `<div>` tags, like this:

```html
<body>

  ...

  <div th:insert="~{footer :: copy}"></div>

  <div th:replace="~{footer :: copy}"></div>
  
</body>
```

...will result in:

```html
<body>

  ...

  <div>
    <footer>
      &copy; 2011 The Good Thymes Virtual Grocery
    </footer>
  </div>

  <footer>
    &copy; 2011 The Good Thymes Virtual Grocery
  </footer>
  
</body>
```



8.2 Firmas de fragmentos parametrizables
----------------------------------------

In order to create a more _function-like_ mechanism for template fragments,
fragments defined with `th:fragment` can specify a set of parameters:
	
```html
<div th:fragment="frag (onevar,twovar)">
    <p th:text="${onevar} + ' - ' + ${twovar}">...</p>
</div>
```

This requires the use of one of these two syntaxes to call the fragment from
`th:insert` or `th:replace`:

```html
<div th:replace="~{ ::frag (${value1},${value2}) }">...</div>
<div th:replace="~{ ::frag (onevar=${value1},twovar=${value2}) }">...</div>
```

Note that order is not important in the last option:

```html
<div th:replace="~{ ::frag (twovar=${value2},onevar=${value1}) }">...</div>
```


### Variables locales de fragmentos sin firma de fragmento

Even if fragments are defined without arguments like this:

```html	
<div th:fragment="frag">
    ...
</div>
```

We could use the second syntax specified above to call them (and only the second one):

```html	
<div th:replace="~{::frag (onevar=${value1},twovar=${value2})}">
```

This would be equivalent to a combination of `th:replace` and `th:with`:

```html	
<div th:replace="~{::frag}" th:with="onevar=${value1},twovar=${value2}">
```

**Note** that this specification of local variables for a fragment -- no matter
whether it has an argument signature or not -- does not cause the context to be
emptied prior to its execution. Fragments will still be able to access every
context variable being used at the calling template like they currently are. 


### th:assert para afirmaciones dentro de la plantilla

The `th:assert` attribute can specify a comma-separated list of expressions
which should be evaluated and produce true for every evaluation, raising an
exception if not.

```html
<div th:assert="${onevar},(${twovar} != 43)">...</div>
```

This comes in handy for validating parameters at a fragment signature:

```html
<header th:fragment="contentheader(title)" th:assert="${!#strings.isEmpty(title)}">...</header>
```



8.3 Eliminación de fragmentos de plantilla
------------------------------------------

Thanks to *fragment expressions*, we can specify parameters for fragments that
are not texts, numbers, bean objects... but instead fragments of markup.

This allows us to create our fragments in a way such that they can be *enriched*
with markup coming from the calling templates, resulting in a very flexible
**template layout mechanism**.

Note the use of the `title` and `links` variables in the fragment below:

```html
<head th:fragment="common_header(title,links)">

  <title th:replace="${title}">The awesome application</title>

  <!-- Common styles and scripts -->
  <link rel="stylesheet" type="text/css" media="all" th:href="@{/css/awesomeapp.css}">
  <link rel="shortcut icon" th:href="@{/images/favicon.ico}">
  <script type="text/javascript" th:src="@{/sh/scripts/codebase.js}"></script>

  <!--/* Per-page placeholder for additional links */-->
  <th:block th:replace="${links}" />

</head>
```

We can now call this fragment like:

```html
...
<head th:replace="~{ base :: common_header(~{::title},~{::link}) }">

  <title>Awesome - Main</title>

  <link rel="stylesheet" th:href="@{/css/bootstrap.min.css}">
  <link rel="stylesheet" th:href="@{/themes/smoothness/jquery-ui.css}">

</head>
...
```

...and the result will use the actual `<title>` and `<link>` tags from our
calling template as the values of the `title` and `links` variables, resulting
in our fragment being customized during insertion:

```html
...
<head>

  <title>Awesome - Main</title>

  <!-- Common styles and scripts -->
  <link rel="stylesheet" type="text/css" media="all" href="/awe/css/awesomeapp.css">
  <link rel="shortcut icon" href="/awe/images/favicon.ico">
  <script type="text/javascript" src="/awe/sh/scripts/codebase.js"></script>

  <link rel="stylesheet" href="/awe/css/bootstrap.min.css">
  <link rel="stylesheet" href="/awe/themes/smoothness/jquery-ui.css">

</head>
...
```


### Usando el fragmento vacío

A special fragment expression, the *empty fragment* (`~{}`), can be used for
specifying *no markup*. Using the previous example:

```html
<head th:replace="~{ base :: common_header(~{::title},~{}) }">

  <title>Awesome - Main</title>

</head>
...
```

Note how the second parameter of the fragment (`links`) is set to the *empty
fragment* and therefore nothing is written for the `<th:block th:replace="${links}" />`
block:

```html
...
<head>

  <title>Awesome - Main</title>

  <!-- Common styles and scripts -->
  <link rel="stylesheet" type="text/css" media="all" href="/awe/css/awesomeapp.css">
  <link rel="shortcut icon" href="/awe/images/favicon.ico">
  <script type="text/javascript" src="/awe/sh/scripts/codebase.js"></script>

</head>
...
```


### Uso del token de no operación

The no-op can be also used as a parameter to a fragment if we just want to let
our fragment use  its current markup as a default value. Again, using the
`common_header` example:

```html
...
<head th:replace="~{base :: common_header(_,~{::link})}">

  <title>Awesome - Main</title>

  <link rel="stylesheet" th:href="@{/css/bootstrap.min.css}">
  <link rel="stylesheet" th:href="@{/themes/smoothness/jquery-ui.css}">

</head>
...
```

See how the `title` argument (first argument of the `common_header` fragment) is
set to *no-op* (`_`), which results in this part of the fragment not being
executed at all (`title` = *no-operation*):

```html
  <title th:replace="${title}">The awesome application</title>
```

So the result is:

```html
...
<head>

  <title>The awesome application</title>

  <!-- Common styles and scripts -->
  <link rel="stylesheet" type="text/css" media="all" href="/awe/css/awesomeapp.css">
  <link rel="shortcut icon" href="/awe/images/favicon.ico">
  <script type="text/javascript" src="/awe/sh/scripts/codebase.js"></script>

  <link rel="stylesheet" href="/awe/css/bootstrap.min.css">
  <link rel="stylesheet" href="/awe/themes/smoothness/jquery-ui.css">

</head>
...
```


### Inserción condicional avanzada de fragmentos

The availability of both the *empty fragment* and *no-operation token* allows us
to perform conditional insertion of fragments in a very easy and elegant way.

For example, we could do this in order to insert our `common :: adminhead`
fragment *only* if the user is an administrator, and insert nothing (empty
fragment) if not:

```html
...
<div th:insert="${user.isAdmin()} ? ~{common :: adminhead} : ~{}">...</div>
...
```

Also, we can use the *no-operation token* in order to insert a fragment only if
the specified condition is met, but leave the markup without modifications if
the condition is not met:

```html
...
<div th:insert="${user.isAdmin()} ? ~{common :: adminhead} : _">
    Welcome [[${user.name}]], click <a th:href="@{/support}">here</a> for help-desk support.
</div>
...
```

Additionally, if we have configured our template resolvers to *check for
existence* of the template resources –- by means of their `checkExistence` flag
-– we can use the existence of the fragment itself as the condition in a *default*
operation:

```html
...
<!-- The body of the <div> will be used if the "common :: salutation" fragment  -->
<!-- does not exist (or is empty).                                              -->
<div th:insert="~{common :: salutation} ?: _">
    Welcome [[${user.name}]], click <a th:href="@{/support}">here</a> for help-desk support.
</div>
...
```



8.4 Eliminación de fragmentos de plantilla
-------------------------------

Back to the example application, let's revisit the last version of our product list template:

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

Why? Because, although perfectly displayable by browsers, that table only has a
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

And what does that `all` value in the attribute, mean? `th:remove` can behave in
five different ways, depending on its value:

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

The `th:remove` attribute can take any _Thymeleaf Standard Expression_, as long
as it returns one of the allowed String values (`all`, `tag`, `body`, `all-but-first`
or `none`).

This means removals could be conditional, like:

```html
<a href="/something" th:remove="${condition}? tag : none">Link text not to be removed</a>
```

Also note that `th:remove` considers `null` a synonym to `none`, so the
following works the same as the example above:

```html
<a href="/something" th:remove="${condition}? tag">Link text not to be removed</a>
```

In this case, if `${condition}` is false, `null` will be returned, and thus no
removal will be performed. 


8.5 Herencia de diseño
----------------------

To be able to have a single file as layout, fragments can be used. An example 
of a simple layout having `title` and `content` using `th:fragment` and 
`th:replace`:

```html
<!DOCTYPE html>
<html th:fragment="layout (title, content)" xmlns:th="http://www.thymeleaf.org">
<head>
    <title th:replace="${title}">Layout Title</title>
</head>
<body>
    <h1>Layout H1</h1>
    <div th:replace="${content}">
        <p>Layout content</p>
    </div>
    <footer>
        Layout footer
    </footer>
</body>
</html>
```

This example declares a fragment called **layout** having _title_ and _content_ as
parameters. Both will be replaced on page inheriting it by provided fragment 
expressions in the example below.

```html
<!DOCTYPE html>
<html th:replace="~{layoutFile :: layout(~{::title}, ~{::section})}">
<head>
    <title>Page Title</title>
</head>
<body>
<section>
    <p>Page content</p>
    <div>Included on page</div>
</section>
</body>
</html>
```

In this file, the `html` tag will be replaced by _layout_, but in the layout 
`title` and `content` will have been replaced by `title` and `section` blocks
respectively.

If desired, the layout can be composed by several fragments as _header_ 
and _footer_.



9 Variables locales
=================

Thymeleaf calls _local variables_ the variables that are defined for a specific
fragment of a template, and are only available for evaluation inside that
fragment.

An example we have already seen is the `prod` iter variable in our product list
page:

```html
<tr th:each="prod : ${prods}">
    ...
</tr>
```

That `prod` variable will be available only within the bounds of the `<tr>` tag.
Specifically:

 * It will be available for any other `th:*` attributes executing in that tag
   with less _precedence_ than `th:each` (which means they will execute after `th:each`).
 * It will be available for any child element of the `<tr>` tag, such as any `<td>`
   elements.

Thymeleaf offers you a way to declare local variables without iteration, using
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
available for evaluation along with any other variables declared in the context,
but only within the bounds of the containing `<div>` tag.

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




10\. Precedencia de atributos
=============================

What happens when you write more than one `th:*` attribute in the same tag? For
example:

```html
<ul>
  <li th:each="item : ${items}" th:text="${item.description}">Item description here...</li>
</ul>
```

We would expect that `th:each` attribute to execute before the `th:text` so that
we get the results we want, but given the fact that the HTML/XML standards do
not give any kind of meaning to the order in which the attributes in a tag are 
written, a _precedence_ mechanism had to be established in the attributes
themselves in order to be sure that this will work as expected.

So, all Thymeleaf attributes define a numeric precedence, which establishes the
order in which they are executed in the tag. This order is:


-----------------------------------------------------------------
Order   Feature                            Attributes
------- ---------------------------------- ----------------------
      1 Fragment inclusion                 `th:insert`\
                                           `th:replace`

      2 Fragment iteration                 `th:each`

      3 Conditional evaluation             `th:if`\
                                           `th:unless`\
                                           `th:switch`\
                                           `th:case`

      4 Local variable definition          `th:object`\
                                           `th:with`

      5 General attribute modification     `th:attr`\
                                           `th:attrprepend`\
                                           `th:attrappend`

      6 Specific attribute modification    `th:value`\
                                           `th:href`\
                                           `th:src`\
                                           `...`

      7 Text (tag body modification)       `th:text`\
                                           `th:utext`

      8 Fragment specification             `th:fragment`

      9 Fragment removal                   `th:remove`
-----------------------------------------------------------------

This precedence mechanism means that the above iteration fragment will give
exactly the same results if the attribute position is inverted (although it
would be slightly less readable):

```html
<ul>
  <li th:text="${item.description}" th:each="item : ${items}">Item description here...</li>
</ul>
```




11\. Comentarios y bloques
==========================

11.1. Comentarios HTML/XML estándar
-----------------------------------

Standard HTML/XML comments `<!-- ... -->` can be used anywhere in Thymeleaf
templates. Anything inside these comments won't be processed by Thymeleaf, and
will be copied verbatim to the result:

```html
<!-- User info follows -->
<div th:text="${...}">
  ...
</div>
```



11.2. Bloques de comentarios a nivel de analizador de Thymeleaf
---------------------------------------------------------------

Parser-level comment blocks are code that will be simply removed from the
template when Thymeleaf parses it. They look like this:

```html
<!--/* This code will be removed at Thymeleaf parsing time! */-->
``` 

Thymeleaf will remove everything between `<!--/*` and `*/-->`, so these comment
blocks can also be used for displaying code when a template is statically open,
knowing that it will be removed when Thymeleaf processes it:

```html
<!--/*--> 
  <div>
     you can see me only before Thymeleaf processes me!
  </div>
<!--*/-->
```

This might come very handy for prototyping tables with a lot of `<tr>`'s, for
example:

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



11.3. Bloques de comentarios exclusivos del prototipo de Thymeleaf
------------------------------------------------------------------

Thymeleaf allows the definition of special comment blocks marked to be comments
when the template is open statically (i.e. as a prototype), but considered
normal markup by Thymeleaf when executing the template.

```html
<span>hello!</span>
<!--/*/
  <div th:text="${...}">
    ...
  </div>
/*/-->
<span>goodbye!</span>
```

Thymeleaf's parsing system will simply remove the `<!--/*/` and `/*/-->` markers,
but not its contents, which will be left therefore uncommented. So when
executing the template, Thymeleaf will actually see this:

```html
<span>hello!</span>
 
  <div th:text="${...}">
    ...
  </div>
 
<span>goodbye!</span>
```

As with parser-level comment blocks, this feature is dialect-independent.



11.4. Etiqueta sintética `th:block`
-----------------------------------

Thymeleaf's only element processor (not an attribute) included in the Standard
Dialects is `th:block`.

`th:block` is a mere attribute container that allows template developers to
specify whichever attributes they want. Thymeleaf will execute these attributes
and then simply make the block, but not its contents, disappear.

So it could be useful, for example, when creating iterated tables that require
more than one `<tr>` for each element:

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

Note how this solution allows templates to be valid HTML (no need to add
forbidden `<div>` blocks inside `<table>`), and still works OK when open
statically in browsers as prototypes! 




12\. Inserción en línea
=======================



12.1 Inserción de texto en línea
--------------------------------

Although the Standard Dialect allows us to do almost everything using tag
attributes, there are situations in which we could prefer writing expressions
directly into our HTML texts. For example, we could prefer writing this:

```html
<p>Hello, [[${session.user.name}]]!</p>
```

...instead of this:

```html
<p>Hello, <span th:text="${session.user.name}">Sebastian</span>!</p>
```

Expressions between `[[...]]` or `[(...)]` are considered **inlined expressions**
in Thymeleaf, and inside them we can use any kind of expression that would also
be valid in a `th:text` or `th:utext` attribute.

Note that, while `[[...]]` corresponds to `th:text` (i.e. result will be *HTML-escaped*), 
`[(...)]` corresponds to `th:utext` and will not perform any HTML-escaping. So
with a variable such as `msg = 'This is <b>great!</b>'`, given this fragment:

```html
<p>The message is "[(${msg})]"</p>
```

The result will have those `<b>` tags unescaped, so:

```html
<p>The message is "This is <b>great!</b>"</p>
```

Whereas if escaped like:

```html
<p>The message is "[[${msg}]]"</p>
```

The result will be HTML-escaped:

```html
<p>The message is "This is &lt;b&gt;great!&lt;/b&gt;"</p>
```

Note that **text inlining is active by default** in the body of every tag in our
markup –- not the tags themselves -–, so there is nothing we need to do to
enable it.


### Plantillas en línea vs. plantillas naturales

If you come from other template engines in which this way of outputting text is
the norm, you might be asking: _Why aren't we doing this from the beginning?
It's less code than all those_ `th:text` _attributes!_ 

Well, be careful there, because although you might find inlining quite 
interesting, you should always remember that inlined expressions will be 
displayed verbatim in your HTML files when you open them statically, so you 
probably won't be able to use them as design prototypes anymore!

The difference between how a browser would statically display our fragment of
code without using inlining...

```
Hello, Sebastian!
```

...and using it...

```
Hello, [[${session.user.name}]]!
```

...is quite clear in terms of design usefulness.


### Deshabilitar la inserción en línea

This mechanism can be disabled though, because there might actually be occasions
in which we do want to output the `[[...]]` or  `[(...)]` sequences without its
contents being processed as an expression. For that, we will use `th:inline="none"`:

```html
<p th:inline="none">A double array looks like this: [[1, 2, 3], [4, 5]]!</p>
```

This will result in:

```html
<p>A double array looks like this: [[1, 2, 3], [4, 5]]!</p>
```



12.2 Inserción de texto en línea
------------------

*Text inlining* is very similar to the *expression inlining* capability we have
just seen, but it actually adds more power. It has to be enabled explicitly with
`th:inline="text"`.

Text inlining not only allows us to use the same *inlined expressions* we just
saw, but in fact processes *tag bodies* as if they were templates processed in
the `TEXT` template mode, which allows us to perform text-based template logic
(not only output expressions).

We will see more about this in the next chapter about the *textual template modes*.



12.3 Inserción de JavaScript en línea
------------------------

JavaScript inlining allows for a better integration of JavaScript `<script>`
blocks in templates being processed in the `HTML` template mode.

As with *text inlining*, this is actually equivalent to processing the scripts
contents as if they were templates in the `JAVASCRIPT` template mode, and
therefore all the power of the *textual template modes* (see next chapter) will
be at hand. However, in this section we will focus on how we can use it for 
adding the output of our Thymeleaf expressions into our JavaScript blocks.

This mode has to be explicitly enabled using `th:inline="javascript"`:

```html
<script th:inline="javascript">
    ...
    var username = [[${session.user.name}]];
    ...
</script>
```

This will result in:

```html
<script th:inline="javascript">
    ...
    var username = "Sebastian \"Fruity\" Applejuice";
    ...
</script>
```

Two important things to note in the code above: 

*First*, that JavaScript inlining will not only output the required text, but 
also enclose it with quotes and JavaScript-escape its contents, so that the
expression results are output as a **well-formed JavaScript literal**.

*Second*, that this is happening because we are outputting the `${session.user.name}`
expression as **escaped**, i.e. using a double-bracket expression: `[[${session.user.name}]]`.
If instead we used *unescaped* like:

```html
<script th:inline="javascript">
    ...
    var username = [(${session.user.name})];
    ...
</script>
```

The result would look like:

```html
<script th:inline="javascript">
    ...
    var username = Sebastian "Fruity" Applejuice;
    ...
</script>
```

...which is malformed JavaScript code. But outputting something unescaped might
be what we need if we are building parts of our script by means of appending
inlined expressions, so it's good to have this tool at hand.


### Plantillas naturales de JavaScript

The mentioned *intelligence* of the JavaScript inlining mechanism goes much
further than just applying JavaScript-specific escaping and outputting
expression results as valid literals.

For example, we can wrap our (escaped) inlined expressions in JavaScript
comments like:

```html
<script th:inline="javascript">
    ...
    var username = /*[[${session.user.name}]]*/ "Gertrud Kiwifruit";
    ...
</script>
```

And Thymeleaf will ignore everything we have written *after the comment and
before the semicolon* (in this case ` 'Gertrud Kiwifruit'`), so the result of
executing this will look exactly like when we were not using the wrapping
comments:

```html
<script th:inline="javascript">
    ...
    var username = "Sebastian \"Fruity\" Applejuice";
    ...
</script>
```

But have another careful look at the original template code:


```html
<script th:inline="javascript">
    ...
    var username = /*[[${session.user.name}]]*/ "Gertrud Kiwifruit";
    ...
</script>
```

Note how this is **valid JavaScript** code. And it will perfectly execute when
you open your template file in a static manner (without executing it at a
server).

So what we have here is a way to do **JavaScript natural templates**!


### Evaluación en línea avanzada y serialización de JavaScript

An important thing to note regarding JavaScript inlining is that this
expression evaluation is intelligent and not limited to Strings. Thymeleaf will
correctly write in JavaScript syntax the following kinds of objects:

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
    ...
    var user = /*[[${session.user}]]*/ null;
    ...
</script>
```

That `${session.user}` expression will evaluate to a `User` object, and
Thymeleaf will correctly convert it to Javascript syntax:

```html
<script th:inline="javascript">
    ...
    var user = {"age":null,"firstName":"John","lastName":"Apricot",
                "name":"John Apricot","nationality":"Antarctica"};
    ...
</script>
```

The way this JavaScript serialization is done is by means of an implementation
of the `org.thymeleaf.standard.serializer.IStandardJavaScriptSerializer`
interface, which can be configured at the instance of the `StandardDialect`
being used at the template engine.

The default implementation of this JS serialization mechanism will look for the
[Jackson library](https://github.com/FasterXML/jackson) in the classpath and, if
present, will use it. If not, it will apply a built-in serialization mechanism
that covers the needs of most scenarios and produces similar results (but is
less flexible).



12.4 Inserción de CSS
-----------------

Thymeleaf also allows the use of inlining in CSS `<style>` tags, such as:

```html
<style th:inline="css">
  ...
</style>
```

For example, say we have two variables set to two different `String` values:

```
classname = 'main elems'
align = 'center'
```

We could use them just like:

```html
<style th:inline="css">
    .[[${classname}]] {
      text-align: [[${align}]];
    }
</style>
```

And the result would be:

```html
<style th:inline="css">
    .main\ elems {
      text-align: center;
    }
</style>
```

Note how CSS inlining also bears some *intelligence*, just like JavaScript's.
Specifically, expressions output via *escaped* expressions like `[[${classname}]]`
will be escaped as **CSS identifiers**. That is why our `classname = 'main elems'`
has turned into `main\ elems` in the fragment of code above.


### Funciones avanzadas: plantillas naturales CSS, etc.

In an equivalent way to what was explained before for JavaScript, CSS inlining
also allows for our `<style>` tags to work both statically and dynamically, i.e.
 as **CSS natural templates** by means of wrapping inlined expressions in
 comments. See:

```html
<style th:inline="css">
    .main\ elems {
      text-align: /*[[${align}]]*/ left;
    }
</style>
```




13 Modos de plantilla textual
=========================



13.1 Sintaxis textual
-------------------

Three of the Thymeleaf *template modes* are considered **textual**: `TEXT`, `JAVASCRIPT`
and `CSS`. This differentiates them from the markup template modes: `HTML` and `XML`.

The key difference between *textual* template modes and the markup ones is that
in a textual template there are no tags into which to insert logic in the form
of attributes, so we have to rely on other mechanisms.

The first and most basic of these mechanisms is **inlining**, which we have
already detailed in the previous chapter. Inlining syntax is the most simple way
to output results of expressions in textual template mode, so this is a
perfectly valid template for a text email.

```
  Dear [(${name})],

  Please find attached the results of the report you requested
  with name "[(${report.name})]".

  Sincerely,
    The Reporter.
```

Even without tags, the example above is a complete and valid Thymeleaf template
that can be executed in the `TEXT` template mode.

But in order to include more complex logic than mere *output expressions*, we
need a new non-tag-based syntax:

```
[# th:each="item : ${items}"]
  - [(${item})]
[/]
```

Which is actually the *condensed* version of the more verbose:

```
[#th:block th:each="item : ${items}"]
  - [#th:block th:utext="${item}" /]
[/th:block]
```

Note how this new syntax is based on elements (i.e. processable tags) that are
declared as `[#element ...]` instead of `<element ...>`. Elements are open like
`[#element ...]` and closed like `[/element]`, and standalone tags can be
declared by minimizing the open element with a `/` in a way almost equivalent to
XML tags: `[#element ... /]`.

The Standard Dialect only contains a processor for one of these elements: the
already-known `th:block`, though we could extend this in our dialects and create
new elements in the usual way. Also, the `th:block` element (`[#th:block ...] ... [/th:block]`)
is allowed to be abbreviated as the empty string (`[# ...] ... [/]`), so the
above block is actually equivalent to:

```
[# th:each="item : ${items}"]
  - [# th:utext="${item}" /]
[/]
```

And given `[# th:utext="${item}" /]` is equivalent to an *inlined unescaped
expression*, we could just use it in order to have less code. Thus we end up
with the first fragment of code we saw above:

```
[# th:each="item : ${items}"]
  - [(${item})]
[/]
```

Note that the *textual syntax requires full element balance (no unclosed tags)
and quoted attributes* -- it's more XML-style than HTML-style.

Let's have a look at a more complete example of a `TEXT` template, a *plain text*
email template:

```
Dear [(${customer.name})],

This is the list of our products:

[# th:each="prod : ${products}"]
   - [(${prod.name})]. Price: [(${prod.price})] EUR/kg
[/]

Thanks,
  The Thymeleaf Shop
```

After executing, the result of this could be something like:

```
Dear Mary Ann Blueberry,

This is the list of our products:

   - Apricots. Price: 1.12 EUR/kg
   - Bananas. Price: 1.78 EUR/kg
   - Apples. Price: 0.85 EUR/kg
   - Watermelon. Price: 1.91 EUR/kg

Thanks,
  The Thymeleaf Shop
```

And another example in `JAVASCRIPT` template mode, a `greeter.js` file, we
process as a textual template and which result we call from our HTML pages. Note
this is *not* a `<script>` block in an HTML template, but a `.js` file being
processed as a template on its own:

```javascript
var greeter = function() {

    var username = [[${session.user.name}]];

    [# th:each="salut : ${salutations}"]    
      alert([[${salut}]] + " " + username);
    [/]

};
```

After executing, the result of this could be something like:

```javascript
var greeter = function() {

    var username = "Bertrand \"Crunchy\" Pear";

      alert("Hello" + " " + username);
      alert("Ol\u00E1" + " " + username);
      alert("Hola" + " " + username);

};
```


### Atributos de elementos escapados

In order to avoid interactions with parts of the template that might be
processed in other modes (e.g. `text`-mode inlining inside an `HTML` template),
Thymeleaf 3.0 allows the attributes in elements in its *textual syntax* to be
escaped. So:

 * Attributes in `TEXT` template mode will be *HTML-unescaped*.
 * Attributes in `JAVASCRIPT` template mode will be *JavaScript-unescaped*.
 * Attributes in `CSS` template mode will be *CSS-unescaped*.

So this would be perfectly OK in a `TEXT`-mode template (note the `&gt;`):
```
  [# th:if="${120&lt;user.age}"]
     Congratulations!
  [/]
```

Of course that `&lt;` would make no sense in a *real text* template, but it is a
good idea if we are processing an HTML template with a `th:inline="text"` block
containing the code above and we want to make sure our browser doesn't take that
`<user.age` for the name of an open tag when statically opening the file as a
prototype.



13.2 Extensibilidad
------------------

One of the advantages of this syntax is that it is just as extensible as the 
*markup* one. Developers can still define their own dialects with custom
elements and attributes, apply a prefix to them (optionally), and then use them
in textual template modes:

```
  [#myorg:dosomething myorg:importantattr="211"]some text[/myorg:dosomething]
```



13.3 Bloques de comentarios de solo prototipos textuales: agregar código
-------------------------------------------------------

The `JAVASCRIPT` and `CSS` template modes (not available for `TEXT`) allow 
including code between a special comment syntax `/*[+...+]*/` so that Thymeleaf
will automatically uncomment such code when processing the template:

```javascript
var x = 23;

/*[+

var msg  = "This is a working application";

+]*/

var f = function() {
    ...
```

Will be executed as:

```javascript
var x = 23;

var msg  = "This is a working application";

var f = function() {
...
```

You can include expressions inside these comments, and they will be evaluated:

```javascript
var x = 23;

/*[+

var msg  = "Hello, " + [[${session.user.name}]];

+]*/

var f = function() {
...
```



13.4 Bloques de comentarios de nivel de analizador textual: eliminación de código
-------------------------------------------------------

In a way similar to that of prototype-only comment blocks, all the three textual
template modes (`TEXT`, `JAVASCRIPT` and `CSS`) make it possible to instruct
Thymeleaf to remove code between special `/*[- */` and `/* -]*/` marks, like
this:

```javascript
var x = 23;

/*[- */

var msg  = "This is shown only when executed statically!";

/* -]*/

var f = function() {
...
```

Or this, in `TEXT` mode:

```
...
/*[- Note the user is obtained from the session, which must exist -]*/
Welcome [(${session.user.name})]!
...
```



13.5 Plantillas naturales de JavaScript y CSS
-----------------------------------------

As seen in the previous chapter, JavaScript and CSS inlining offer the
possibility to include inlined expressions inside JavaScript/CSS comments, like:

```javascript
...
var username = /*[[${session.user.name}]]*/ "Sebastian Lychee";
...
```

...which is valid JavaScript, and once executed could look like:

```html
...
var username = "John Apricot";
...
```

This same *trick* of enclosing inlined expressions inside comments can in fact be
used for the entire textual mode syntax:

```
  /*[# th:if="${user.admin}"]*/
     alert('Welcome admin');
  /*[/]*/
```

That alert in the code above will be shown when the template is open statically
-- because it is 100% valid JavaScript --, and also when the template is run if
the user is an admin. It is equivalent to:

```
  [# th:if="${user.admin}"]
     alert('Welcome admin');
  [/]
```

...which is actually the code to which the initial version is converted during
template parsing. 

Note however that wrapping elements in comments does not clean the lines they
live in (to the right until a `;` is found) as inlined output expressions do.
That behaviour is reserved for inlined output expressions only.

So Thymeleaf 3.0 allows the development of **complex JavaScript scripts and CSS
style sheets in the form of natural templates**, valid both as a *prototype* and
as a *working template*.




14  Algunas páginas más para nuestra tienda de comestibles
==================================

Now we know a lot about using Thymeleaf, we can add some new pages to our
website for order management.

Note that we will focus on HTML code, but you can have a look at the bundled
source code if you want to see the corresponding controllers.



14.1 Lista de pedidos
---------------

Let's start by creating an order list page, `/WEB-INF/templates/order/list.html`:

```html
<!DOCTYPE html>

<html xmlns:th="http://www.thymeleaf.org">

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



14.2 Detalles del pedido
------------------

Now for the order details page, in which we will make a heavy use of asterisk
syntax:

```html
<!DOCTYPE html>

<html xmlns:th="http://www.thymeleaf.org">

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
      <p><b>Nombre:</b> <span th:text="*{name}">Frederic Tomato</span></p>
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
    <p><b>Nombre:</b> <span th:text="*{name}">Frederic Tomato</span></p>
    ...
  </div>

  ...
</body>
```

...which makes that `*{name}` equivalent to:


```html
<p><b>Nombre:</b> <span th:text="${order.customer.name}">Frederic Tomato</span></p>
```




15\. Más sobre la configuración
===============================



15.1 Resolvedores de plantillas
-------------------------------

For our Good Thymes Virtual Grocery, we chose an `ITemplateResolver`
implementation called `WebApplicationTemplateResolver` that allowed us to obtain
templates as resources from the application resources (the _Servlet Context_
in a Servlet-based webapp).

Besides giving us the ability to create our own template resolver by
implementing `ITemplateResolver,` Thymeleaf includes four implementations out of
the box:

 * `org.thymeleaf.templateresolver.ClassLoaderTemplateResolver`, which resolves
   templates as classloader resources, like:

    ```java
    return Thread.currentThread().getContextClassLoader().getResourceAsStream(template);
    ```

 * `org.thymeleaf.templateresolver.FileTemplateResolver`, which resolves
   templates as files from the file system, like:

    ```java
    return new FileInputStream(new File(template));
    ```

 * `org.thymeleaf.templateresolver.UrlTemplateResolver`, which resolves
   templates as URLs (even non-local ones), like:

    ```java
    return (new URL(template)).openStream();
    ```

 * `org.thymeleaf.templateresolver.StringTemplateResolver`, which resolves
   templates directly as the `String` being specified as `template` (or
   *template name*, which in this case is obviously much more than a mere name):

    ```java
    return new StringReader(templateName);
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
    templateResolver.setCharacterEncoding("UTF-8");
    ```

 * Template mode to be used:

    ```java
    // Default is HTML
    templateResolver.setTemplateMode("XML");
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
   will be to exceed the cache max size (oldest entry will be removed).

    ```java
    // Default is no TTL (only cache size exceeded would remove entries)
    templateResolver.setCacheTTLMs(60000L);
    ```

> The Thymeleaf + Spring integration packages offer a `SpringResourceTemplateResolver`
> implementation which uses all the Spring infrastructure for accessing and
> reading resources in applications, and which is the recommended implementation
> in Spring-enabled applications.


### Encadenamiento de solucionadores de plantillas


Also, a Template Engine can specify several template resolvers, in which case an
order can be established between them for template resolution so that, if the
first one is not able to resolve the template, the second one is asked, and so
on:

```java
ClassLoaderTemplateResolver classLoaderTemplateResolver = new ClassLoaderTemplateResolver();
classLoaderTemplateResolver.setOrder(Integer.valueOf(1));

WebApplicationTemplateResolver webApplicationTemplateResolver = 
        new WebApplicationTemplateResolver(application);
webApplicationTemplateResolver.setOrder(Integer.valueOf(2));

templateEngine.addTemplateResolver(classLoaderTemplateResolver);
templateEngine.addTemplateResolver(webApplicationTemplateResolver);
```

When several template resolvers are applied, it is recommended to specify
patterns for each template resolver so that Thymeleaf can quickly discard those
template resolvers that are not meant to resolve the template, enhancing
performance. Doing this is not a requirement, but a recommendation:

```java
ClassLoaderTemplateResolver classLoaderTemplateResolver = new ClassLoaderTemplateResolver();
classLoaderTemplateResolver.setOrder(Integer.valueOf(1));
// This classloader will not be even asked for any templates not matching these patterns 
classLoaderTemplateResolver.getResolvablePatternSpec().addPattern("/layout/*.html");
classLoaderTemplateResolver.getResolvablePatternSpec().addPattern("/menu/*.html");

WebApplicationTemplateResolver webApplicationTemplateResolver = 
        new WebApplicationTemplateResolver(application);
webApplicationTemplateResolver.setOrder(Integer.valueOf(2));
```

If these *resolvable patterns* are not specified, we will be relying on the
specific capabilities of each of the `ITemplateResolver` implementations we are
using. Note that not all implementations might be able to determine the
existence of a template before resolving, and thus could always consider a
template as *resolvable* and break the resolution chain (not allowing other
resolvers to check for the same template), but then be unable to read the real
resource.

All the `ITemplateResolver` implementations that are included with core
Thymeleaf include a mechanism that will allow us to make the resolvers *really
check* if a resource exists before considering it *resolvable*. It is the
`checkExistence` flag, which works like:

```java
ClassLoaderTemplateResolver classLoaderTemplateResolver = new ClassLoaderTemplateResolver();
classLoaderTemplateResolver.setOrder(Integer.valueOf(1));
classLoaderTempalteResolver.setCheckExistence(true);
```

This `checkExistence` flag forces the resolver perform a *real check* for
resource existence during the resolution phase (and let the following resolver
in the chain be called if existence check returns false). While this might sound
good in every case, in most cases this will mean a double access to the resource
itself (once for checking existence, another time for reading it), and could be
a performance issue in some scenarios, e.g. remote URL-based template resources
-- a potential performance issue that might anyway get largely mitigated by the
use of the template cache (in which case templates will only be *resolved* the
first time they are accessed).



15.2 Resolvedores de mensajes
-----------------------------

We did not explicitly specify a Message Resolver implementation for our Grocery
application, and as it was explained before, this meant that the implementation
being used was an `org.thymeleaf.messageresolver.StandardMessageResolver` object.

`StandardMessageResolver` is the standard implementation of the `IMessageResolver` 
interface, but we could create our own if we wanted, adapted to the specific
needs of our application.

> The Thymeleaf + Spring integration packages offer by default an `IMessageResolver`
> implementation which uses the standard Spring way of retrieving externalized
> messages, by using `MessageSource` beans declared at the Spring Application
> Context.


### Resolvedor de mensajes estándar

So how does `StandardMessageResolver` look for the messages requested at a
specific template?

If the template name is `home` and it is located in `/WEB-INF/templates/home.html`,
and the requested locale is `gl_ES` then this resolver will look for messages in
the following files, in this order:

 * `/WEB-INF/templates/home_gl_ES.properties`
 * `/WEB-INF/templates/home_gl.properties`
 * `/WEB-INF/templates/home.properties`

Refer to the JavaDoc documentation of the `StandardMessageResolver` class for
more detail on how the complete message resolution mechanism works.


### Configuración de solucionadores de mensajes

What if we wanted to add a message resolver (or more) to the Template Engine?
Easy:

```java
// For setting only one
templateEngine.setMessageResolver(messageResolver);

// For setting more than one
templateEngine.addMessageResolver(messageResolver);
```

And why would we want to have more than one message resolver? For the same
reason as template resolvers: message resolvers are ordered and if the first one
cannot resolve a specific message, the second one will be asked, then the third,
etc.




15.3 Servicios de conversión
------------------------

The *conversion service* that enables us to perform data conversion and
formatting operations by means of the *double-brace* syntax (`${{...}}`) is
actually a feature of the Standard Dialect, not of the Thymeleaf Template Engine
itself.

As such, the way to configure it is by setting our custom implementation of the
`IStandardConversionService` interface directly into the instance of `StandardDialect`
that is being configured into the template engine. Like:

```java
IStandardConversionService customConversionService = ...

StandardDialect dialect = new StandardDialect();
dialect.setConversionService(customConversionService);

templateEngine.setDialect(dialect);
```

> Note that the thymeleaf-spring3 and thymeleaf-spring4 packages contain the
> `SpringStandardDialect`, and this dialect already comes pre-configured with an
> implementation of `IStandardConversionService` that integrates Spring's own
> *Conversion Service* infrastructure into Thymeleaf.



15.4 Registro de trazas
------------

Thymeleaf pays quite a lot of attention to logging, and always tries to offer
the maximum amount of useful information through its logging interface.

The logging library used is `slf4j,` which in fact acts as a bridge to whichever
logging implementation we might want to use in our application (for example, `log4j`).

Thymeleaf classes will log `TRACE`, `DEBUG` and `INFO`-level information,
depending on the level of detail we desire, and besides general logging it will
use three special loggers associated with the TemplateEngine class which we can
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
    * `org.thymeleaf.TemplateEngine.cache.EXPRESSION_CACHE`

An example configuration for Thymeleaf's logging infrastructure, using `log4j`,
could be:

```
log4j.logger.org.thymeleaf=DEBUG
log4j.logger.org.thymeleaf.TemplateEngine.CONFIG=TRACE
log4j.logger.org.thymeleaf.TemplateEngine.TIMER=TRACE
log4j.logger.org.thymeleaf.TemplateEngine.cache.TEMPLATE_CACHE=TRACE
```




16\. Caché de plantillas
========================

Thymeleaf works thanks to a set of parsers -- for markup and text -- that parse
templates into sequences of events (open tag, text, close tag, comment, etc.)
and a series of processors -- one for each type of behaviour that needs to be
applied -- that modify the template parsed event sequence in order to create the
results we expect by combining the original template with our data.

It also includes -- by default -- a cache that stores parsed templates; the
sequence of events resulting from reading and parsing template files before
processing them. This is especially useful when working in a web application,
and builds on the following concepts:

 * Input/Output is almost always the slowest part of any application. In-memory
   processing is extremely quick by comparison.
 * Cloning an existing in-memory event sequence is always much quicker than
   reading a template file, parsing it and creating a new event sequence for it.
 * Web applications usually have only a few dozen templates.
 * Template files are small-to-medium size, and they are not modified while the
   application is running.

This all leads to the idea that caching the most used templates in a web
application is feasible without wasting large amounts of memory, and also that
it will save a lot of time that would be spent on input/output operations on a
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
// Default is 200
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




17 Lógica de plantilla desacoplada
===========================

17.1 Lógica desacoplada: El concepto
---------------------------------

So far we have worked for our Grocery Store with templates done the *usual way*,
with logic being inserted into our templates in the form of attributes.

But Thymeleaf also allows us to completely *decouple* the template markup from
its logic, allowing the creation of **completely logic-less markup templates**
in the `HTML` and `XML` template modes.

The main idea is that template logic will be defined in a separate *logic file*
(more exactly a *logic resource*, as it doesn't need to be a *file*). By default,
that logic resource will  be an additional file living in the same place (e.g.
folder) as the template file, with the same name but with `.th.xml` extension:

```
/templates
+->/home.html
+->/home.th.xml
```

So the `home.html` file can be completely logic-less. It might look like this:

```html
<!DOCTYPE html>
<html>
  <body>
    <table id="usersTable">
      <tr>
        <td class="username">Jeremy Grapefruit</td>
        <td class="usertype">Normal User</td>
      </tr>
      <tr>
        <td class="username">Alice Watermelon</td>
        <td class="usertype">Administrator</td>
      </tr>
    </table>
  </body>
</html>
```

Absolutely no Thymeleaf code there. This is a template file that a designer with
no Thymeleaf or templating knowledge could have created, edited and/or
understood. Or a fragment of HTML provided by some external system with no
Thymeleaf hooks at all.

Let's now turn that `home.html` template into a Thymeleaf template by creating 
our additional `home.th.xml` file like this:

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

Here we can see a lot of `<attr>` tags inside a `thlogic` block. Those `<attr>`
tags perform *attribute injection* on nodes of the original template selected by
means of their `sel` attributes, which contain Thymeleaf *markup selectors*
(actually *AttoParser markup selectors*). 

Also note that `<attr>` tags can be nested so that their selectors are *appended*.
That `sel="/tr[0]"` above, for example, will be processed as `sel="#usersTable/tr[0]"`.
And the selector for the user name `<td>` will be processed as `sel="#usersTable/tr[0]//td.username"`.

So once merged, both files seen above will be the same as:

```html
<!DOCTYPE html>
<html>
  <body>
    <table id="usersTable" th:remove="all-but-first">
      <tr th:each="user : ${users}">
        <td class="username" th:text="${user.name}">Jeremy Grapefruit</td>
        <td class="usertype" th:text="#{|user.type.${user.type}|}">Normal User</td>
      </tr>
      <tr>
        <td class="username">Alice Watermelon</td>
        <td class="usertype">Administrator</td>
      </tr>
    </table>
  </body>
</html>
```

This looks more familiar, and is indeed less *verbose* than creating two
separate files. But the advantage of *decoupled templates* is that we can
give for our templates total independence from Thymeleaf, and therefore better
maintainability from the design standpoint.

Of course some *contracts* between designers or developers will still be needed
-- e.g. the fact that the users `<table>` will need an `id="usersTable"` --, but
in many scenarios a pure-HTML template will be a much better communication
artifact between design and development teams.



17.2 Configuración de plantillas desacopladas
------------------------------------

### Habilitación de plantillas desacopladas

Decoupled logic will not be expected for every template by default. Instead, the
configured template resolvers (implementations of `ITemplateResolver`) will need
to specifically mark the templates they resolve as *using decoupled logic*.

Except for `StringTemplateResolver` (which does not allow decoupled logic), all
other out-of-the-box implementations of `ITemplateResolver` will provide a flag
called `useDecoupledLogic` that will mark all templates resolved by that
resolver as potentially having all or part of its logic living in a separate
resource:

```java
final WebApplicationTemplateResolver templateResolver = 
        new WebApplicationTemplateResolver(application);
...
templateResolver.setUseDecoupledLogic(true);
```


### Mezcla de lógica acoplada y desacoplada

Decoupled template logic, when enabled, is not a requirement. When enabled, it
means that the engine will *look for* a resource containing decoupled logic,
parsing and merging it with the original template if it exists. No error will be
thrown if the decoupled logic resource does not exist.

Also, in the same template we can mix both *coupled* and *decoupled* logic, for
example by adding some Thymeleaf attributes at the original template file but
leaving others for the separate decoupled logic file. The most common case for
this is using the new (in v3.0) `th:ref` attribute.



17.3 El atributo th:ref
---------------------------

`th:ref` is only a marker attribute. It does nothing from the processing
standpoint and simply disappears when the template is processed, but its
usefulness lies in the fact that it acts as a *markup reference*, i.e. it can be
resolved by name from a *markup selector* just like a *tag name* or a *fragment*
(`th:fragment`).

So if we have a selector like:

```xml
  <attr sel="whatever" .../>
```

This will match:

 * Any `<whatever>` tags.
 * Any tags with a `th:fragment="whatever"` attribute.
 * Any tags with a `th:ref="whatever"` attribute.

What is the advantage of `th:ref` against, for example, using a pure-HTML `id`
attribute? Merely the fact that we might not want to add so many `id` and `class`
attributes to our tags to act as *logic anchors*, which might end up *polluting*
our output. 

And in the same sense, what is the disadvantage of `th:ref`? Well, obviously
that we'd be adding a bit of Thymeleaf logic (*"logic"*) to our templates.

Note this applicability of the `th:ref` attribute **does not only apply to
decoupled logic template files**: it works the same in other types of scenarios,
like in fragment expressions (`~{...}`).



17.4 Impacto en el rendimiento de las plantillas desacopladas
----------------------------------------------

The impact is extremely small. When a resolved template is marked to use
decoupled logic and it is not cached, the template logic resource will be
resolved first, parsed and processed into a sequence of instructions in-memory:
basically a list of attributes to be injected to each markup selector.

But this is the only *additional step* required because, after this, the real
template will be parsed, and while it is parsed these attributes will be
injected *on-the-fly* by the parser itself, thanks to the advanced capabilities
for node selection in AttoParser. So parsed nodes will come out of the parser as
if they had their injected attributes written in the original template file.

The biggest advantage of this? When a template is configured to be cached, it
will be cached already containing the injected attributes. So the overhead of
using *decoupled templates* for cacheable templates, once they are cached, 
will be absolutely *zero*.



17.5 Resolución de lógica desacoplada
----------------------------------

The way Thymeleaf resolves the decoupled logic resources corresponding to each
template is configurable by the user. It is determined by an extension point,
the `org.thymeleaf.templateparser.markup.decoupled.IDecoupledTemplateLogicResolver`, 
for which a *default implementation* is provided: `StandardDecoupledTemplateLogicResolver`.

What does this standard implementation do?

 * First, it applies a `prefix` and a `suffix` to the *base name* of the
   template resource (obtained by means of its `ITemplateResource#getBaseName()`
   method). Both prefix and suffix can be configured and, by default, the prefix
   will be empty and the suffix will be `.th.xml`.
 * Second, it asks the template resource to resolve a *relative resource* with
   the computed name by means of its `ITemplateResource#relative(String relativeLocation)`
   method.

The specific implementation of `IDecoupledTemplateLogicResolver` to be used can
be configured at the `TemplateEngine` easily:

```java
final StandardDecoupledTemplateLogicResolver decoupledresolver = 
        new StandardDecoupledTemplateLogicResolver();
decoupledResolver.setPrefix("../viewlogic/");
...
templateEngine.setDecoupledTemplateLogicResolver(decoupledResolver);
```




18 Apéndice A: Objetos básicos de expresión
=======================================

Some objects and variable maps are always available to be invoked. Let's see
them:


### Base objects

 * **\#ctx** : the context object. An implementation of `org.thymeleaf.context.IContext` 
   or `org.thymeleaf.context.IWebContext` depending on our environment
   (standalone or web).

   Note `#vars` and `#root` are synomyns for the same object, but using `#ctx`
   is recommended.

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.context.IContext
 * ======================================================================
 */

${#ctx.locale}
${#ctx.variableNames}

/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.context.IWebContext
 * ======================================================================
 */

${#ctx.request}
${#ctx.response}
${#ctx.session}
${#ctx.servletContext}
```

 * **\#locale** : direct access to the `java.util.Locale` associated with
   current request.

```java
${#locale}
```


### Espacios de nombres de contexto web para atributos de solicitud/sesión, etc.

When using Thymeleaf in a web environment, we can use a series of shortcuts for
accessing request parameters, session attributes and application attributes:

> Note these are not *context objects*, but maps added to the context as
> variables, so we access them without `#`. In some way, they act as *namespaces*.

 * **param** : for retrieving request parameters. `${param.foo}` is a `String[]`
   with the values of the `foo` request parameter, so `${param.foo[0]}` will
   normally be used for getting the first value.

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

Note there is **no need to specify a namespace for accessing request attributes**
(as opposed to *request parameters*) because all request attributes are
automatically added to the context as variables in the context root:

```java
${myRequestAttribute}
```




19 Apéndice B: Objetos de utilidad de expresión
=========================================


### Información de ejecución

 * **\#execInfo** : expression object providing useful information about the
   template being processed inside Thymeleaf Standard Expressions.

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.ExecutionInfo
 * ======================================================================
 */

/*
 * Return the name and mode of the 'leaf' template. This means the template
 * from where the events being processed were parsed. So if this piece of
 * code is not in the root template "A" but on a fragment being inserted
 * into "A" from another template called "B", this will return "B" as a
 * name, and B's mode as template mode.
 */
${#execInfo.templateName}
${#execInfo.templateMode}

/*
 * Return the name and mode of the 'root' template. This means the template
 * that the template engine was originally asked to process. So if this
 * piece of code is not in the root template "A" but on a fragment being
 * inserted into "A" from another template called "B", this will still 
 * return "A" and A's template mode.
 */
${#execInfo.processedTemplateName}
${#execInfo.processedTemplateMode}

/*
 * Return the stacks (actually, List<String> or List<TemplateMode>) of
 * templates being processed. The first element will be the 
 * 'processedTemplate' (the root one), the last one will be the 'leaf'
 * template, and in the middle all the fragments inserted in nested
 * manner to reach the leaf from the root will appear.
 */
${#execInfo.templateNames}
${#execInfo.templateModes}

/*
 * Return the stack of templates being processed similarly (and in the
 * same order) to 'templateNames' and 'templateModes', but returning
 * a List<TemplateData> with the full template metadata.
 */
${#execInfo.templateStack}
```


### Mensajes

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


### URIs/URLs

 * **\#uris** : utility object for performing URI/URL operations (esp.
   escaping/unescaping) inside Thymeleaf Standard Expressions.

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Uris
 * ======================================================================
 */

/*
 * Escape/Unescape as a URI/URL path
 */
${#uris.escapePath(uri)}
${#uris.escapePath(uri, encoding)}
${#uris.unescapePath(uri)}
${#uris.unescapePath(uri, encoding)}

/*
 * Escape/Unescape as a URI/URL path segment (between '/' symbols)
 */
${#uris.escapePathSegment(uri)}
${#uris.escapePathSegment(uri, encoding)}
${#uris.unescapePathSegment(uri)}
${#uris.unescapePathSegment(uri, encoding)}

/*
 * Escape/Unescape as a Fragment Identifier (#frag)
 */
${#uris.escapeFragmentId(uri)}
${#uris.escapeFragmentId(uri, encoding)}
${#uris.unescapeFragmentId(uri)}
${#uris.unescapeFragmentId(uri, encoding)}

/*
 * Escape/Unescape as a Query Parameter (?var=value)
 */
${#uris.escapeQueryParam(uri)}
${#uris.escapeQueryParam(uri, encoding)}
${#uris.unescapeQueryParam(uri)}
${#uris.unescapeQueryParam(uri, encoding)}
```


### Conversiones

 * **\#conversions** : utility object that allows the execution of the
   *Conversion Service* at any point of a template:

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Conversions
 * ======================================================================
 */

/*
 * Execute the desired conversion of the 'object' value into the
 * specified class.
 */
${#conversions.convert(object, 'java.util.TimeZone')}
${#conversions.convert(object, targetClass)}
```


### Fechas

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


### Calendarios

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


### Temporales (java.time)

 * **\#temporals** : deal with date/time objects from the JDK8+ `java.time` API:

```java
/*
 * ======================================================================
 * See javadoc API for class org.thymeleaf.expression.Temporals
 * ======================================================================
 */

/*
 *
 * Format date with the standard locale format
 * Also works with arrays, lists or sets
 */
${#temporals.format(temporal)}
${#temporals.arrayFormat(temporalsArray)}
${#temporals.listFormat(temporalsList)}
${#temporals.setFormat(temporalsSet)}

/*
 * Format date with the standard format for the provided locale
 * Also works with arrays, lists or sets
 */
${#temporals.format(temporal, locale)}
${#temporals.arrayFormat(temporalsArray, locale)}
${#temporals.listFormat(temporalsList, locale)}
${#temporals.setFormat(temporalsSet, locale)}

/*
 * Format date with the specified pattern
 * SHORT, MEDIUM, LONG and FULL can also be specified to used the default java.time.format.FormatStyle patterns
 * Also works with arrays, lists or sets
 */
${#temporals.format(temporal, 'dd/MMM/yyyy HH:mm')}
${#temporals.format(temporal, 'dd/MMM/yyyy HH:mm', 'Europe/Paris')}
${#temporals.arrayFormat(temporalsArray, 'dd/MMM/yyyy HH:mm')}
${#temporals.listFormat(temporalsList, 'dd/MMM/yyyy HH:mm')}
${#temporals.setFormat(temporalsSet, 'dd/MMM/yyyy HH:mm')}

/*
 * Format date with the specified pattern and locale
 * Also works with arrays, lists or sets
 */
${#temporals.format(temporal, 'dd/MMM/yyyy HH:mm', locale)}
${#temporals.arrayFormat(temporalsArray, 'dd/MMM/yyyy HH:mm', locale)}
${#temporals.listFormat(temporalsList, 'dd/MMM/yyyy HH:mm', locale)}
${#temporals.setFormat(temporalsSet, 'dd/MMM/yyyy HH:mm', locale)}

/*
 * Format date with ISO-8601 format
 * Also works with arrays, lists or sets
 */
${#temporals.formatISO(temporal)}
${#temporals.arrayFormatISO(temporalsArray)}
${#temporals.listFormatISO(temporalsList)}
${#temporals.setFormatISO(temporalsSet)}

/*
 * Obtain date properties
 * Also works with arrays, lists or sets
 */
${#temporals.day(temporal)}                    // also arrayDay(...), listDay(...), etc.
${#temporals.month(temporal)}                  // also arrayMonth(...), listMonth(...), etc.
${#temporals.monthName(temporal)}              // also arrayMonthName(...), listMonthName(...), etc.
${#temporals.monthNameShort(temporal)}         // also arrayMonthNameShort(...), listMonthNameShort(...), etc.
${#temporals.year(temporal)}                   // also arrayYear(...), listYear(...), etc.
${#temporals.dayOfWeek(temporal)}              // also arrayDayOfWeek(...), listDayOfWeek(...), etc.
${#temporals.dayOfWeekName(temporal)}          // also arrayDayOfWeekName(...), listDayOfWeekName(...), etc.
${#temporals.dayOfWeekNameShort(temporal)}     // also arrayDayOfWeekNameShort(...), listDayOfWeekNameShort(...), etc.
${#temporals.hour(temporal)}                   // also arrayHour(...), listHour(...), etc.
${#temporals.minute(temporal)}                 // also arrayMinute(...), listMinute(...), etc.
${#temporals.second(temporal)}                 // also arraySecond(...), listSecond(...), etc.
${#temporals.nanosecond(temporal)}             // also arrayNanosecond(...), listNanosecond(...), etc.

/*
 * Create temporal (java.time.Temporal) objects from its components
 */
${#temporals.create(year,month,day)}                                // return a instance of java.time.LocalDate
${#temporals.create(year,month,day,hour,minute)}                    // return a instance of java.time.LocalDateTime
${#temporals.create(year,month,day,hour,minute,second)}             // return a instance of java.time.LocalDateTime
${#temporals.create(year,month,day,hour,minute,second,nanosecond)}  // return a instance of java.time.LocalDateTime

/*
 * Create a temporal (java.time.Temporal) object for the current date and time
 */
${#temporals.createNow()}                      // return a instance of java.time.LocalDateTime
${#temporals.createNowForTimeZone(zoneId)}     // return a instance of java.time.ZonedDateTime
${#temporals.createToday()}                    // return a instance of java.time.LocalDate
${#temporals.createTodayForTimeZone(zoneId)}   // return a instance of java.time.LocalDate

/*
 * Create a temporal (java.time.Temporal) object for the provided date
 */
${#temporals.createDate(isoDate)}              // return a instance of java.time.LocalDate
${#temporals.createDateTime(isoDate)}          // return a instance of java.time.LocalDateTime
${#temporals.createDate(isoDate, pattern)}     // return a instance of java.time.LocalDate
${#temporals.createDateTime(isoDate, pattern)} // return a instance of java.time.LocalDateTime
```


### Numeros

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
 * =====================
 * Formatting currencies
 * =====================
 */

${#numbers.formatCurrency(num)}
${#numbers.arrayFormatCurrency(numArray)}
${#numbers.listFormatCurrency(numList)}
${#numbers.setFormatCurrency(numSet)}


/* 
 * ======================
 * Formatting percentages
 * ======================
 */

${#numbers.formatPercent(num)}
${#numbers.arrayFormatPercent(numArray)}
${#numbers.listFormatPercent(numList)}
${#numbers.setFormatPercent(numSet)}

/* 
 * Set minimum integer digits and (exact) decimal digits.
 */
${#numbers.formatPercent(num, 3, 2)}
${#numbers.arrayFormatPercent(numArray, 3, 2)}
${#numbers.listFormatPercent(numList, 3, 2)}
${#numbers.setFormatPercent(numSet, 3, 2)}


/*
 * ===============
 * Utility methods
 * ===============
 */

/*
 * Create a sequence (array) of integer numbers going
 * from x to y
 */
${#numbers.sequence(from,to)}
${#numbers.sequence(from,to,step)}
```


### Cadenas (String, en inglés)

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


### Objetos

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


### Booleanos

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


### Matrices

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


### Listas

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


### Conjuntos

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


### Mapas

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


### Agregados

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




20 Apéndice C: Sintaxis del selector de marcado
=====================================

Thymeleaf's Markup Selectors are directly borrowed from Thymeleaf's parsing 
library: [AttoParser](http://attoparser.org).

The syntax for this selectors has large similarities with that of selectors in
XPath, CSS and jQuery, which makes them easy to use for most users. You can have
a look at the complete syntax reference at the
[AttoParser documentation](http://www.attoparser.org/apidocs/attoparser/2.0.4.RELEASE/org/attoparser/select/package-summary.html).

For example, the following selector will select every `<div>` with the class `content`,
in every position inside the markup (note this is not as concise as it could be,
read on to know why):

```html
<div th:insert="~{mytemplate :: //div[@class='content']}">...</div>
```

The basic syntax includes:

 * `/x` means direct children of the current node with name x.

 * `//x` means children of the current node with name x, at any depth.

 * `x[@z="v"]` means elements with name x and an attribute called z with value
   "v".

 * `x[@z1="v1" and @z2="v2"]` means elements with name x and attributes z1 and
   z2 with values "v1" and "v2", respectively.

 * `x[i]` means element with name x positioned in number i among its siblings.

 * `x[@z="v"][i]` means elements with name x, attribute z with value "v" and
   positioned in number i among its siblings that also match this condition.

But more concise syntax can also be used:

 * `x` is exactly equivalent to `//x` (search an element with name or reference
   `x` at any depth level, a *reference* being a `th:ref` or a `th:fragment` attribute).

 * Selectors are also allowed without element name/reference, as long as they
   include a specification of arguments. So `[@class='oneclass']` is a valid
   selector that looks for any elements (tags) with a class attribute with value
   `"oneclass"`.

Advanced attribute selection features:

 * Besides `=` (equal), other comparison operators are also valid: `!=` (not
   equal), `^=` (starts with) and `$=` (ends with). For example: `x[@class^='section']`
   means elements with name `x` and a value for attribute `class` that starts
   with `section`.

 * Attributes can be specified both starting with `@` (XPath-style) and without
   (jQuery-style). So `x[z='v']` is equivalent to `x[@z='v']`.
 
 * Multiple-attribute modifiers can be joined both with `and` (XPath-style) and
   also by chaining multiple modifiers (jQuery-style). So `x[@z1='v1' and @z2='v2']`
   is actually equivalent to `x[@z1='v1'][@z2='v2']` (and also to `x[z1='v1'][z2='v2']`).

Direct _jQuery-like_ selectors:

 * `x.oneclass` is equivalent to `x[class='oneclass']`.

 * `.oneclass` is equivalent to `[class='oneclass']`.

 * `x#oneid` is equivalent to `x[id='oneid']`.

 * `#oneid` is equivalent to `[id='oneid']`.

 * `x%oneref` means `<x>` tags that have a `th:ref="oneref"` or `th:fragment="oneref"`
   attribute.

 * `%oneref` means any tags that have a `th:ref="oneref"` or `th:fragment="oneref"`
   attribute. Note this is actually equivalent to simply `oneref` because
   references can be used instead of element names.

 * Direct selectors and attribute selectors can be mixed: `a.external[@href^='https']`.

So the above Markup Selector expression:

```html
<div th:insert="~{mytemplate :: //div[@class='content']}">...</div>
```

Could be written as:

```html
<div th:insert="~{mytemplate :: div.content}">...</div>
```

Examining a different example, this:

```html
<div th:replace="~{mytemplate :: myfrag}">...</div>
```

Will look for a `th:fragment="myfrag"` fragment signature (or `th:ref`
references). But would also look for tags with name `myfrag` if they existed
(which they don't, in HTML). Note the difference with:

```html
<div th:replace="~{mytemplate :: .myfrag}">...</div>
```

...which will actually look for any elements with `class="myfrag"`, without
caring about `th:fragment` signatures (or `th:ref` references). 


### Coincidencia de clases multivalor

Markup Selectors understand the class attribute to be **multivalued**, and
therefore allow the application of selectors on this attribute even if the
element has several class values.

For example, `div.two` will match `<div class="one two three" />`
