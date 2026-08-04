---
title: ¡Saluda! Cómo extender Thymeleaf en 5 minutos.
---

Ampliar Thymeleaf es sencillo: solo tenemos que crear un dialecto y añadirlo a 
nuestro motor de plantillas. Veamos cómo.

Todo el código que se muestra aquí proviene de una aplicación en funcionamiento. 
Puedes ver o descargar el código fuente desde 
[su repositorio de GitHub](https://github.com/thymeleaf/thymeleaf/tree/3.1-master/examples/spring6/thymeleaf-examples-spring6-sayhello).


Dialectos
---------

Los dialectos de Thymeleaf son conjuntos de características que podemos usar en 
tus plantillas.

Estas características incluyen:

- **Lógica de procesamiento**: se especifica mediante *procesadores* que se 
  aplican a los atributos de nuestras etiquetas (o a las etiquetas mismas).
- **Lógica de preprocesamiento y posprocesamiento**: se especifica mediante 
  *preprocesadores* y *posprocesadores* que se aplican a nuestra plantilla 
  antes (pre) o después (post) del procesamiento.
- **Objetos de expresión**: se pueden usar en las expresiones estándar de 
  Thymeleaf (como `#arrays`, `#dates`, etc.) para realizar las operaciones 
  especializadas que podamos necesitar.

Todas estas características son opcionales, y un dialecto puede especificar 
solo algunas. Por ejemplo, un dialecto podría no necesitar especificar ningún 
procesador, sino declarar un par de *objetos de expresión*.

Si ha visto fragmentos de código escritos en los *dialectos estándar*, habrá 
notado que los atributos procesables comienzan con `th:`. Ese "th:" se 
denomina **prefijo de dialecto**, e indica que todas las etiquetas y atributos 
procesados por ese dialecto comenzarán con dicho prefijo. Cada dialecto puede 
especificar su propio prefijo.

También es importante tener en cuenta que **un motor de plantillas puede 
configurarse con varios dialectos a la vez**, lo que permite procesar plantillas 
que incluyen características de todos los dialectos especificados (piense en los 
dialectos como una especie de *bibliotecas de etiquetas JSP* mejoradas). Además, 
algunos de estos dialectos pueden *compartir prefijo*, actuando efectivamente 
como un dialecto agregado.


El dialecto más simple de todos: ¡Di hola!
-------------------------------------

Vamos a crear un dialecto para una de nuestras aplicaciones. Será una aplicación 
Spring MVC, así que ya usaremos el dialecto SpringStandard (consulta el 
[tutorial Thymeleaf + Spring](/docs/documentation.html) para más detalles). Pero 
queremos añadir un nuevo atributo que nos permita saludar a quien queramos, así:

```html
<p hello:sayto="World">Hi ya!</p>
```

### El procesador

Primero, tendremos que crear el procesador de atributos que se encargará de 
mostrar nuestro mensaje de saludo.

Todos los procesadores implementan la interfaz `org.thymeleaf.processor.IProcessor`, 
y en concreto, un procesador de etiquetas implementa la interfaz 
`org.thymeleaf.processor.element.IElementTagProcessor`, ya que se trata de un 
procesador que se aplica a un *elemento* (en la jerga XML/HTML), y 
específicamente a la *etiqueta de apertura* de dicho elemento.

Además, este procesador se activará mediante un atributo específico de dicha 
*etiqueta de apertura* (`hello:sayto`), por lo que extenderemos una útil clase 
abstracta que nos proporcionará la mayor parte de la infraestructura de clases 
necesaria: `org.thymeleaf.processor.element.AbstractAttributeTagProcessor`.

```java
public class SayToAttributeTagProcessor extends AbstractAttributeTagProcessor {

    private static final String ATTR_NAME = "sayto";
    private static final int PRECEDENCE = 10000;


    public SayToAttributeTagProcessor(final String dialectPrefix) {
        super(
            TemplateMode.HTML, // Este procesador se aplicará únicamente al modo HTML.
            dialectPrefix,     // Prefijo que se aplicará al nombre para que coincida
            null,              // Sin nombre de etiqueta: coincide con cualquier nombre de etiqueta
            false,             // No se aplicará ningún prefijo al nombre de la etiqueta.
            ATTR_NAME,         // Nombre del atributo que se comparará
            true,              // Aplicar prefijo dialectal al nombre del atributo
            PRECEDENCE,        // Precedencia (dentro de la precedencia del dialecto)
            true);             // Elimine el atributo coincidente posteriormente.
    }


    protected void doProcess(
            final ITemplateContext context, final IProcessableElementTag tag,
            final AttributeName attributeName, final String attributeValue,
            final IElementTagStructureHandler structureHandler) {

        structureHandler.setBody(
                "Hello, " + HtmlEscape.escapeHtml5(attributeValue) + "!", false);

    }


}
```

### La clase de dialecto

Crear nuestro procesador fue muy sencillo, pero ahora necesitamos crear la 
*clase de dialecto*, que se encargará de indicarle a Thymeleaf que nuestro 
procesador está disponible.

La interfaz de dialecto más básica, `org.thymeleaf.dialect.IDialect`, solo le 
indica a Thymeleaf que una clase específica es un dialecto. Sin embargo, el 
motor necesita saber qué funcionalidades ofrece ese dialecto, y para 
declararlas, la clase de dialecto implementará una o varias subinterfaces de un 
conjunto de `IDialect`.

En concreto, nuestro dialecto ofrecerá procesadores y, por lo tanto, 
implementará la interfaz `org.thymeleaf.dialect.IProcessorDialect`. Para 
simplificarlo, en lugar de implementar directamente la interfaz, extenderemos 
una clase abstracta llamada `org.thymeleaf.dialect.AbstractProcessorDialect`.

```java
public class HelloDialect extends AbstractProcessorDialect {

    public HelloDialect() {
        super(
                "Hello Dialect",    // Nombre del dialecto
                "hello",            // Prefijo dialectal (hello:*)
                1000);              // precedencia del dialecto
    }

    /*
     * Inicializa los procesadores del dialecto.
     *
     * Nótese que el prefijo del dialecto se pasa aquí porque, aunque establecimos
     * "hello" como prefijo del dialecto en el constructor, esto solo
     * funciona por defecto, y en el momento de la configuración del motor, el usuario
     * podría haber elegido un prefijo diferente.
     */    
    public Set<IProcessor> getProcessors(final String dialectPrefix) {
        final Set<IProcessor> processors = new HashSet<IProcessor>();
        processors.add(new SayToAttributeTagProcessor(dialectPrefix));
        return processors;
    }


}
```


Usando el dialecto hello
------------------------

Using our new dialect is very easy. This being a Spring MVC application,
we just have to add it to our `templateEngine` bean during configuration,
along with the `templateResolver` bean it depends on:

```java
@Bean
public SpringResourceTemplateResolver templateResolver(){
    SpringResourceTemplateResolver templateResolver = new SpringResourceTemplateResolver();
    templateResolver.setApplicationContext(this.applicationContext);
    templateResolver.setPrefix("/WEB-INF/templates/");
    templateResolver.setSuffix(".html");
    templateResolver.setTemplateMode(TemplateMode.HTML);
    templateResolver.setCacheable(true);
    return templateResolver;
}

@Bean
public SpringTemplateEngine templateEngine(){
    SpringTemplateEngine templateEngine = new SpringTemplateEngine();
    templateEngine.setEnableSpringELCompiler(true);
    templateEngine.setTemplateResolver(templateResolver());
    templateEngine.addDialect(new HelloDialect());
    return templateEngine;
}
```
Tenga en cuenta que al usar `addDialect(...)` (en lugar de `setDialect(...)`) le 
estamos indicando al motor que queremos usar nuestro nuevo dialecto *además* del 
dialecto `StandardDialect` predeterminado. Por lo tanto, todos los atributos 
`th:*` estándar también estarán disponibles.

Y ahora nuestro nuevo atributo funcionaría a la perfección:

```html
<p>Hello World!</p>
```


¿Quieres saber más?
-------------------

Luego, echa un vistazo a 
[*"¡Saluda de nuevo! Prolonga Thymeleaf aún más en otros 5 minutos"*](sayhelloagainextendingthymeleafevenmore5minutes.html).
