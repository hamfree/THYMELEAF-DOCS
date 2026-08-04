---
title: ¡Saluda de nuevo! Ampliando Thymeleaf aún más en otros 5 minutos.
---

Este artículo es una continuación de 
[*"¡Hola! Ampliando Thymeleaf en 5 minutos"*](sayhelloextendingthymeleaf5minutes.html) 
y debe leerse después de este. El código de este artículo proviene de la misma 
aplicación de ejemplo, que puede ver o descargar desde 
[su repositorio de GitHub](https://github.com/thymeleaf/thymeleaf/tree/3.1-master/examples/spring6/thymeleaf-examples-spring6-sayhello).


Algunas mejoras para nuestro dialecto de 'hola'
-----------------------------------------------

Hasta ahora nuestro `HelloDialect` nos permitió cambiar esto:

```html
<p hello:sayto="World">Hi ya!</p>
```

...en esto:

```html
<p>Hello World!</p>
```
Y funciona perfectamente... pero queremos añadir algunas funciones adicionales 
interesantes. Por ejemplo:

- Permitir expresiones de Spring EL como valores de atributos, como en la mayoría 
  de las etiquetas en el dialecto *Spring Thymeleaf*. Por ejemplo: 
  `hello:sayto="${user.name}"`
- Internacionalizar la salida: decir *Hello* en inglés, *Hola* en español, 
  *Ol&úa* en portugués, etc.

Y necesitaremos todo esto porque queremos poder crear un nuevo
atributo, llamado "`saytoplanet`", y saludar a todos los planetas del
sistema solar, con una plantilla como esta:

```html
<ul>
  <li th:each="planet : ${planets}" hello:saytoplanet="${planet}">Hello Planet!</li>
</ul>
```

...respaldado por un controlador Spring MVC que incluye todos esos planetas como un atributo del modelo llamado 
`planets`:

```java
@Controller
public class SayHelloController {

  public SayHelloController() {
    super();
  }

  @ModelAttribute("planets")
  public List<String> populatePlanets() {
    return Arrays.asList(new String[] {
        "Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"
    });
  }

  @RequestMapping({"/","/sayhello"})
  public String showSayHello() {
    return "sayhello";
  }

}
```


Añadiendo un nuevo procesador a nuestro dialecto
------------------------------------------------

Lo primero que queremos hacer es añadir un nuevo *procesador* a nuestro 
`HelloDialect` existente. Para ello, modificamos el método `getProcessors()` del 
dialecto para incluir nuestra nueva clase `SayToPlanetAttrProcessor`:

```java
public class HelloDialect extends AbstractProcessorDialect {

  ...

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
      processors.add(new SayToPlanetAttributeTagProcessor(dialectPrefix));
      return processors;
  }

  ...

}
```


Utilizar expresiones como valores de atributos
----------------------------------------------

Ahora queremos añadir a nuestro nuevo procesador la capacidad de analizar y 
ejecutar expresiones del mismo modo que podemos hacerlo en los dialectos 
*Standard* y *SpringStandard*, es decir, expresiones estándar de Thymeleaf:

-   `${...}` Expresiones de variables de Spring EL.
-   `#{...}` externalización de mensajes.
-   `@{...}` especificaciones del enlace.
-   `(cond)? (then) : (else)` expresiones condicionales/predeterminadas.
-   etc...

Para lograr esto, utilizaremos el *Analizador de expresiones estándar*, que 
analizará el valor del atributo y lo convertirá en un objeto de *expresión* 
ejecutable:

```java
public class SayToPlanetAttributeTagProcessor extends AbstractAttributeTagProcessor {

    private static final String ATTR_NAME = "saytoplanet";
    private static final int PRECEDENCE = 10000;

    private static final String SAYTO_PLANET_MESSAGE = "msg.helloplanet";

    
    public SayToPlanetAttributeTagProcessor(final String dialectPrefix) {
        super(
            TemplateMode.HTML, // Este procesador se aplicará únicamente al modo HTML
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
        /*
         * Para evaluar el valor del atributo como una expresión estándar de Thymeleaf,
         * primero obtenemos el analizador, luego lo usamos para analizar el valor del atributo en
         * un objeto de expresión y, finalmente, ejecutamos este objeto de expresión.
         */
        final IEngineConfiguration configuration = context.getConfiguration();

        final IStandardExpressionParser parser =
                StandardExpressions.getExpressionParser(configuration);

        final IStandardExpression expression = parser.parseExpression(context, attributeValue);

        final String planet = (String) expression.execute(context);

        /*
         * Establece el saludo como el cuerpo de la etiqueta, con caracteres de escape HTML y
         * no procesable (de ahí el argumento 'false').
         */
        structureHandler.setBody("Hello, planet " + planet, false);
        
    }

}
```

Nótese que, como hicimos en el artículo anterior, estamos extendiendo la clase 
abstracta de conveniencia `AbstractAttributeTagProcessor`.


Añadir internacionalización
---------------------------

Ahora queremos internacionalizar el mensaje que devuelve nuestro procesador de atributos.
Esto significa reemplazar este código de construcción de mensajes que solo está en inglés:

```java
"Hello, planet " + planet;
```

...con un mensaje construido a partir de una cadena externa que debemos obtener 
de alguna manera desde nuestro código. El objeto de contexto (`ITemplateContext`) 
ofrece lo que necesitamos:

```java
    public String getMessage(
            final Class<?> origin, 
            final String key, 
            final Object[] messageParameters, 
            final boolean useAbsentMessageRepresentation);
```

Sus argumentos tienen el siguiente significado:

- `origin`: la clase *origin* que se utilizará para la resolución de mensajes. 
   Al llamar desde un procesador, normalmente se trata de la propia clase del 
   procesador.
- `key`: la clave del mensaje que se va a recuperar.
- `messageParameters`: los parámetros que se aplicarán al mensaje solicitado.
- `useAbsentMessageRepresentation`: indica si se debe devolver una 
   *representación de mensaje ausente* en caso de que el mensaje no exista.

Así que usemos esto para lograr cierta internacionalización. Primero 
necesitaremos algunos archivos `.properties`, como:
`SayToPlanetAttributeTagProcessor_es.properties` para español:

```html
    msg.helloplanet=&iexcl;Hola, planeta {0}!
```    

`SayToPlanetAttributeTagProcessor_pt.properties` para el portugués:

```html
msg.helloplanet=Ol&aacute;, planeta {0}!
```

...etc.

Y ahora tendremos que modificar la clase del procesador 
`SayToPlanetAttributeTagProcessor` para que utilice estos mensajes:

```java
protected void doProcess(
        final ITemplateContext context, final IProcessableElementTag tag,
        final AttributeName attributeName, final String attributeValue,
        final IElementTagStructureHandler structureHandler) {

    /*
     * Para evaluar el valor del atributo como una expresión estándar de Thymeleaf,
     * primero obtenemos el analizador, luego lo usamos para analizar el valor del atributo en
     * un objeto de expresión y, finalmente, ejecutamos este objeto de expresión.
     */
    final IEngineConfiguration configuration = context.getConfiguration();

    final IStandardExpressionParser parser =
            StandardExpressions.getExpressionParser(configuration);

    final IStandardExpression expression = parser.parseExpression(context, attributeValue);

    final String planet = (String) expression.execute(context);

    /*
     * Este método 'getMessage(...)' intentará primero resolver el mensaje
     * a partir de las fuentes de mensajes de Spring configuradas (ya que se trata de una aplicación habilitada para Spring).
     *
     * Si no lo encuentra, intentará resolverlo a partir de un archivo .properties vinculado al classpath
     * con el mismo nombre que el 'origin' especificado, que
     * en este caso es la propia clase de este procesador. Esto permite que los recursos
     * se empaqueten, si es necesario, en los mismos archivos .jar que los procesadores
     * en los que se utilizan.
     */
    final String i18nMessage =
            context.getMessage(
                    SayToPlanetAttributeTagProcessor.class,
                    SAYTO_PLANET_MESSAGE,
                    new Object[] {planet},
                    true);

    /*
     * Establece el mensaje calculado como el cuerpo de la etiqueta, con caracteres de escape HTML y
     * no procesable (de ahí el argumento 'false').
     */
    structureHandler.setBody(HtmlEscape.escapeHtml5(i18nMessage), false);
    
}
```

¡Y eso es todo! Veamos los resultados de ejecutar nuestra plantilla con la 
configuración regional en español:

-   &iexcl;Hola, planeta Mercury!
-   &iexcl;Hola, planeta Venus!
-   &iexcl;Hola, planeta Earth!
-   &iexcl;Hola, planeta Mars!
-   &iexcl;Hola, planeta Jupiter!
-   &iexcl;Hola, planeta Saturn!
-   &iexcl;Hola, planeta Uranus!
-   &iexcl;Hola, planeta Neptune!


Ejercicio para el lector: internacionaliza los nombres de los planetas
----------------------------------------------------------------------

Ahora hemos aplicado la internacionalización a la salida de mensajes de nuestro 
procesador de atributos, pero los nombres de nuestros planetas siguen estando 
todos en inglés porque son variables *codificadas* en nuestro contexto (en el 
lenguaje de Spring, *atributos del modelo*).

¿Qué tal si internacionalizamos los nombres de los planetas? Las expresiones 
`#{...}` que podemos usar en este atributo ahora deberían facilitarlo bastante. 
Además, hay algunos ejemplos en artículos como 
[*"Introducción al dialecto estándar en 5 minutos"*](standarddialect5minutes.html) 
y los [tutoriales](/docs/documentation.html) que son bastante similares a este 
caso.