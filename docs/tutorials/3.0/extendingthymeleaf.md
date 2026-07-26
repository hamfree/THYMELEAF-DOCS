---
title: 'Tutorial: Extending Thymeleaf'
author: Thymeleaf
version: @documentVersion@
thymeleafVersion: @projectVersion@
---




1 Algunas razones para extender Thymeleaf
==================================

Thymeleaf es una biblioteca extremadamente extensible. Su clave reside en que la 
mayoría de sus funcionalidades orientadas al usuario no están integradas 
directamente en su núcleo, sino que se empaquetan y organizan en conjuntos de 
funcionalidades llamados _dialectos_.

La biblioteca ofrece dos dialectos predefinidos: _Standard_ y _SpringStandard_, 
pero puedes crear fácilmente los tuyos propios. Veamos algunas de las razones 
para hacerlo:



**Escenario 1: añadir características a los dialectos estándar**

Supongamos que tu aplicación utiliza el dialecto _SpringStandard_ y que necesita 
mostrar un cuadro de texto de alerta con fondo azul o rojo según el rol del 
usuario (administrador o no administrador) de lunes a sábado, pero siempre en 
verde los domingos. Puedes calcular esto con expresiones condicionales en tu 
plantilla, pero demasiadas condiciones podrían dificultar la lectura del código...

Solución: crea un nuevo atributo llamado `alertclass` y un procesador de atributos 
para él (código Java que calculará la clase CSS correcta), e incorpóralo a tu 
propio dialecto `MyOwnDialect`. ¡Agrega este dialecto a tu motor de plantillas 
con el prefijo `th` (igual que el de _SpringStandard_) y ahora podrás usar 
`th:alertclass="${user.role}"`!


**Escenario 2: Componentes de la capa de vista**

Supongamos que su empresa utiliza Thymeleaf de forma extensiva y desea crear un 
repositorio de funcionalidades comunes (etiquetas y/o atributos) que pueda usar 
en varias aplicaciones sin tener que copiarlas y pegarlas entre ellas. Es decir, 
desea crear componentes de la capa de vista de forma similar a las bibliotecas 
de etiquetas de JSP, _taglibs_.

Solución: cree un dialecto de Thymeleaf para cada conjunto de funcionalidades 
relacionadas y agréguelos a sus aplicaciones según sea necesario. Tenga en 
cuenta que si las etiquetas o atributos de estos dialectos utilizan mensajes 
externalizados (internacionalizados), podrá empaquetarlos junto con sus 
dialectos (en forma de _mensajes de procesador_) en lugar de exigir que todas 
sus aplicaciones los incluyan en sus archivos `.properties` de mensajes, como 
se haría con JSP.

**Escenario 3: Creación de tu propio sistema de plantillas**

Imagina que estás creando un sitio web público que permite a los usuarios crear 
sus propias plantillas de diseño para mostrar su contenido. Por supuesto, no 
quieres que tus usuarios puedan hacer absolutamente todo en sus plantillas, ni 
siquiera todo lo que permite el Dialecto Estándar (por ejemplo, ejecutar 
expresiones OGNL). Por lo tanto, necesitas ofrecer a tus usuarios la posibilidad 
de añadir a sus plantillas solo un conjunto muy específico de funciones que estén 
bajo tu control (como mostrar una foto de perfil, el texto de una entrada de 
blog, etc.).

Solución: crea un dialecto de Thymeleaf con las etiquetas o atributos que 
quieres que tus usuarios puedan usar, como `<mysite:profilePhoto />` o 
`<mysite:blogentries fromDate="23/4/2011" />`. Luego, permite que tus usuarios 
creen sus propias plantillas usando estas funciones y deja que Thymeleaf las 
ejecute, asegurándote de que nadie haga lo que no tiene permitido.

2 Dialectos y procesadores
=========================

2.1. Dialectos
-------------
Si has leído el tutorial _Uso de Thymeleaf_ antes de llegar aquí ---lo cual 
deberías haber hecho---, sabrás que lo que has estado aprendiendo hasta ahora no 
era exactamente _Thymeleaf_, sino su _dialecto estándar_ (o el dialecto _Spring 
Standard_, si también has leído el tutorial _Thymeleaf + Spring_).

¿Qué significa esto? Significa que todos esos atributos `th:x` que aprendiste a 
usar son solo un conjunto estándar de características predefinidas, pero puedes 
definir tu propio conjunto de atributos (o etiquetas) con los nombres que desees 
y usarlos en Thymeleaf para procesar tus plantillas. *Puedes definir tus propios 
dialectos.*

Los dialectos son objetos que implementan la interfaz 
`org.thymeleaf.dialect.IDialect`, que no podría ser más sencilla:

```java
public interface IDialect {

    public String getName();

}
```

El único requisito fundamental de un dialecto es tener un nombre que pueda 
utilizarse para su identificación. Pero esto por sí solo es de poca utilidad, por 
lo que los dialectos normalmente implementarán una o varias subinterfaces de 
`IDialect`, dependiendo de lo que proporcionen al motor Thymeleaf:

* `IProcessorDialect` para dialectos que proporcionan *procesadores*.
* `IPreProcessorDialect` para dialectos que proporcionan *preprocesadores*.
* `IPostProcessorDialect` para dialectos que proporcionan *postprocesadores*.
* `IExpressionObjectDialect` para dialectos que proporcionan *objetos de expresión*.
* `IExecutionAttributeDialect` para dialectos que proporcionan *atributos de ejecución*.


### Dialectos de procesador: `IProcessorDialect`

La interfaz `IProcessorDialect` tiene este aspecto:

```java
public interface IProcessorDialect extends IDialect {

    public String getPrefix();
    public int getDialectProcessorPrecedence();
    public Set<IProcessor> getProcessors(final String dialectPrefix);

}
```

Los **procesadores** son los objetos encargados de ejecutar la mayor parte de la 
lógica en las plantillas de Thymeleaf, y posiblemente el artefacto de extensión 
de Thymeleaf más importante. Hablaremos de los procesadores con más detalle en 
las próximas secciones.

Este dialecto solo define tres elementos:

* El *prefijo*, que es el prefijo o espacio de nombres que se debe aplicar 
*por defecto* a los elementos y atributos que coincidan con los procesadores del 
dialecto. Así, un dialecto con el prefijo `th`, como por ejemplo el 
*Dialecto Estándar*, podrá definir procesadores que coincidan con atributos 
como `th:text`, `th:if` o `th:whatever` (o `data-th-text`, `data-th-if` y 
`data-th-whatever` si preferimos la sintaxis *HTML5 pura*). Sin embargo, tenga 
en cuenta que el prefijo que devuelve un dialecto es **solo el predeterminado** 
que se utilizará para ese dialecto, pero dicho prefijo se puede cambiar durante 
la configuración del motor de plantillas. Tenga en cuenta también que el prefijo 
puede ser `null` si queremos que nuestros procesadores se ejecuten en 
etiquetas/atributos sin prefijo.
* La *precedencia de dialecto* permite ordenar los procesadores según los 
dialectos. Los procesadores definen su propio valor de *precedencia*, pero estas 
precedencias de procesador se consideran *relativas a la precedencia de dialecto*, 
por lo que cada procesador de un dialecto específico puede configurarse para 
ejecutarse antes que todos los procesadores de un dialecto diferente simplemente 
estableciendo los valores correctos para esta *precedencia de dialecto*.
* Los *procesadores* son, como su nombre indica, el conjunto de *procesadores* 
proporcionados por el dialecto. Cabe destacar que al método `getProcessors(...)` 
se le pasa el `dialectPrefix` como argumento en caso de que el dialecto se haya 
configurado en el motor de plantillas con un prefijo diferente al predeterminado. 
Lo más probable es que las instancias de `IProcessor` necesiten esta información 
durante su inicialización.

### Dialectos de preprocesador: `IPreProcessorDialect`

Los **preprocesadores** y **postprocesadores** se diferencian de los 
*procesadores* en que, en lugar de ejecutarse sobre un único evento o sobre un 
modelo de evento (un fragmento de una plantilla), se aplican a todo el proceso 
de ejecución de la plantilla como un paso adicional en la cadena de 
procesamiento del motor. Por lo tanto, siguen una API completamente diferente a 
la de los procesadores, mucho más orientada a eventos, definida por la interfaz 
de nivel inferior `ITemplateHandler`.

En el caso específico de los preprocesadores, se aplican **antes** de que el 
motor Thymeleaf comience a ejecutar los procesadores para una plantilla 
específica.

La interfaz `IPreProcessorDialect` tiene el siguiente aspecto:

```java
public interface IPreProcessorDialect extends IDialect {

    public int getDialectPreProcessorPrecedence();
    public Set<IPreProcessor> getPreProcessors();

}
```

Lo cual es muy similar al `IProcessorDialect` anterior, incluyendo su propia 
precedencia a nivel de dialecto para los preprocesadores, pero carece de un 
*prefijo*, ya que los preprocesadores no lo necesitan en absoluto (no 
*coinciden* con eventos específicos, sino que los manejan todos).


### Dialectos de postprocesador: `IPostProcessorDialect`

Como se indicó anteriormente, los **postprocesadores** son un paso adicional en 
la cadena de ejecución de la plantilla, pero en este caso se ejecutan 
**después** de que el motor Thymeleaf haya aplicado todos los procesadores 
necesarios. Esto significa que los postprocesadores se aplican justo antes de 
que se genere la salida de la plantilla (y, por lo tanto, pueden modificar lo 
que se genera).

La interfaz `IPostProcessorDialect` tiene el siguiente aspecto:

```java
public interface IPostProcessorDialect extends IDialect {

    public int getDialectPostProcessorPrecedence();
    public Set<IPostProcessor> getPostProcessors();

}
```

...lo cual es completamente análogo a la interfaz `IPreProcessorDialect`, pero 
por supuesto para postprocesadores en este caso.


### Dialectos de objetos de expresión: `IExpressionObjectDialect`

Los dialectos que implementan esta interfaz proporcionan nuevos *objetos de 
expresión* u *objetos de utilidad de expresión* que se pueden usar en expresiones 
en cualquier parte de las plantillas, como `#strings`, `#numbers`, `#dates`, etc., 
proporcionadas por el dialecto estándar.

La interfaz `IExpressionObjectDialect` tiene el siguiente aspecto:

```java
public interface IExpressionObjectDialect extends IDialect {

    public IExpressionObjectFactory getExpressionObjectFactory();

}
```

Como podemos ver, esto no devuelve los objetos de expresión en sí, sino solo una 
*fábrica*. Esto se debe a que algunos *objetos de expresión* pueden requerir 
datos del contexto de procesamiento para su construcción, por lo que no será 
posible construirlos hasta que estemos procesando la plantilla. Además, la 
mayoría de las expresiones no necesitan *objetos de expresión*, así que es mejor 
construirlos *bajo demanda*, solo cuando sean realmente necesarios para 
expresiones específicas (y construir únicamente los que se necesiten).

Esta es la interfaz `IExpressionObjectFactory`:

```java
public interface IExpressionObjectFactory {

    public Map<String,ExpressionObjectDefinition> getObjectDefinitions();

    public Object buildObject(final IProcessingContext processingContext, final String expressionObjectName);

}
```

### Dialectos de atributos de ejecución: `IExecutionAttributeDialect`

Los dialectos que implementan esta interfaz pueden proporcionar *atributos de 
ejecución*, es decir, objetos disponibles para todos los procesadores que se 
ejecutan durante el procesamiento de plantillas.

Por ejemplo, el dialecto estándar implementa esta interfaz para proporcionar a 
todos los procesadores:

* El *analizador de expresiones estándar Thymeleaf*, que permite analizar y 
ejecutar expresiones estándar en cualquier atributo.

* El *evaluador de expresiones variables*, que permite ejecutar expresiones 
`${...}` en OGNL o SpringEL (dependiendo de si se utiliza o no el módulo de 
integración de Spring).

* El *servicio de conversión*, que realiza operaciones de conversión en 
expresiones `${{...}}`.

Cabe destacar que estos objetos no están disponibles en el contexto, por lo que 
no se pueden usar desde expresiones de plantilla. Su disponibilidad se limita a 
implementaciones de puntos de extensión, como procesadores, preprocesadores, etc.

La interfaz `IExecutionAttributeDialect` es muy sencilla:

```java
public interface IExecutionAttributeDialect extends IDialect {

    public Map<String,Object> getExecutionAttributes();

}
```




2.2. Procesadores
---------------

Los procesadores son objetos que implementan la interfaz 
`org.thymeleaf.processor.IProcessor` y contienen la lógica real que se aplicará 
a las diferentes partes de una plantilla (que representaremos como **eventos**, 
dado que Thymeleaf es un motor basado en eventos). Esta interfaz tiene el 
siguiente aspecto:

```java
public interface IProcessor {

    public TemplateMode getTemplateMode();
    public int getPrecedence();

}
```

Al igual que con los dialectos, se trata de una interfaz muy sencilla que solo 
especifica el modo de plantilla en el que se puede aplicar el procesador y su 
precedencia.

Sin embargo, existen varios tipos de *procesador*, uno para cada tipo de evento 
posible:

* Inicio/fin de plantilla
* Etiquetas de elementos
* Textos
* Comentarios
* Secciones CDATA
* Cláusulas DOCTYPE
* Declaraciones XML
* Instrucciones de procesamiento

Y también para **modelos**: secuencias de eventos que representan un *elemento 
completo*, es decir, un elemento con todo su cuerpo, incluyendo cualquier 
elemento anidado o cualquier otro tipo de artefacto que pueda aparecer en su 
interior. Si el elemento modelado es un *elemento independiente*, el modelo solo 
contendrá su evento correspondiente; pero si el elemento modelado tiene un 
cuerpo, el modelo contendrá todos los eventos desde su *etiqueta de apertura* 
hasta su *etiqueta de cierre*, ambas incluidas.

Todos estos tipos de procesadores se crean implementando una interfaz específica 
o extendiendo una de las *implementaciones abstractas* disponibles. Todos estos 
artefactos que cumplen con la API del procesador Thymeleaf 3.0 se encuentran en 
el paquete `org.thymeleaf.processor`.




### Procesadores de elementos

Los procesadores de elementos son aquellos que se ejecutan en los eventos de 
*elemento abierto* (`IOpenElementTag`) o *elemento independiente* 
(`IStandaloneElementTag`), normalmente mediante la comparación del nombre del 
elemento (y/o uno de sus atributos) con una configuración coincidente 
especificada por el procesador. Así es como se ve la interfaz `IElementProcessor`:

```java
public interface IElementProcessor extends IProcessor {

    public MatchingElementName getMatchingElementName();
    public MatchingAttributeName getMatchingAttributeName();

}
```
Cabe destacar que las implementaciones de procesadores de elementos no deben 
implementar directamente esta interfaz. En cambio, los procesadores de elementos 
deben pertenecer a una de estas dos categorías:

* **Procesadores de etiquetas de elementos**, que implementan la interfaz 
`IElementTagProcessor`. Estos procesadores se ejecutan únicamente en eventos de 
etiquetas de apertura/independientes (no se pueden aplicar procesadores a 
etiquetas de cierre) y no tienen acceso directo al cuerpo del elemento.

* **Procesadores de modelos de elementos**, que implementan la interfaz 
`IElementModelProcessor`. Estos procesadores se ejecutan en elementos completos, 
incluyendo sus cuerpos, en forma de objetos `IModel`.

Analizaremos cada una de estas interfaces por separado:


### Procesadores de elementos etiqueta: `IElementTagProcessor`

Los procesadores de etiquetas de elementos, como se explicó, se ejecutan en la 
única etiqueta de *elemento abierto* o *elemento independiente* que coincide con 
su configuración correspondiente (que se ve en `IElementProcessor`). La interfaz 
que se debe implementar es `IElementTagProcessor`, que tiene este aspecto:

```java
public interface IElementTagProcessor extends IElementProcessor {

    public void process(
            final ITemplateContext context, 
            final IProcessableElementTag tag,
            final IElementTagStructureHandler structureHandler);

}
```
Como podemos ver, además de extender `IElementProcessor`, solo especifica un 
método `process(...)` que se ejecutará cuando la *configuración coincidente* 
coincida (y en el orden establecido por su *precedencia*, establecida en la 
superinterfaz `IProcessor`). La firma `process(...)` es bastante compacta y sigue 
un patrón que se encuentra en todas las interfaces de procesadores de Thymeleaf:

* El método `process(...)` devuelve `void`. Cualquier acción se realizará a 
través del `structureHandler`.
* El argumento `context` contiene el contexto con el que se ejecuta la 
plantilla: variables, datos de la plantilla, etc.
* El argumento `tag` es el evento que activa el procesador. Contiene tanto el 
nombre del elemento como sus atributos.
* El `structureHandler` es un objeto especial que permite al procesador dar 
instrucciones al motor sobre las acciones que debe realizar como consecuencia de 
su ejecución.

**Uso del `structureHandler`**

El argumento `tag` que se pasa a `process(...)` es un objeto **inmutable**. Por 
lo tanto, no hay forma de, por ejemplo, modificar directamente los atributos de 
una etiqueta en el propio objeto `tag`. En su lugar, se debe usar el 
`structureHandler`.

Por ejemplo, veamos cómo leeríamos el valor de un atributo específico de `tag`, 
lo decodificaríamos y lo guardaríamos en una variable, y luego eliminaríamos el 
atributo de la etiqueta:

```java
// Obtiene el valor del atributo
String attributeValue = tag.getAttributeValue(attributeName);

// Desescapa el valor del atributo
attributeValue = 
    EscapedAttributeUtils.unescapeAttribute(context.getTemplateMode(), attributeValue);

// Indique al structureHandler que elimine el atributo de la etiqueta.
structureHandler.removeAttribute(attributeName);

... // hacer algo con ese attributeValue
```
*Tenga en cuenta que el código anterior solo pretende mostrar algunos conceptos 
de gestión de atributos; en la mayoría de los procesadores no será necesario 
realizar manualmente esta operación de "obtener valor + descodificar + eliminar", 
ya que todo será gestionado por una superclase extendida como 
`AbstractAttributeTagProcessor`*.

Arriba hemos visto solo una de las *operaciones* que ofrece el 
`structureHandler`. Existe un *controlador de estructura* (structureHandler en 
inglés) para cada tipo de procesador en Thymeleaf, y el de los procesadores de 
*etiquetas de elementos* implementa la interfaz `IElementTagStructureHandler`, 
que tiene este aspecto:

```java
public interface IElementTagStructureHandler {

    public void reset();

    public void setLocalVariable(final String name, final Object value);
    public void removeLocalVariable(final String name);

    public void setAttribute(final String attributeName, final String attributeValue);
    public void setAttribute(final String attributeName, final String attributeValue, 
                             final AttributeValueQuotes attributeValueQuotes);

    public void replaceAttribute(final AttributeName oldAttributeName, 
                                 final String attributeName, final String attributeValue);
    public void replaceAttribute(final AttributeName oldAttributeName, 
                                 final String attributeName, final String attributeValue, 
                                 final AttributeValueQuotes attributeValueQuotes);

    public void removeAttribute(final String attributeName);
    public void removeAttribute(final String prefix, final String name);
    public void removeAttribute(final AttributeName attributeName);

    public void setSelectionTarget(final Object selectionTarget);

    public void setInliner(final IInliner inliner);

    public void setTemplateData(final TemplateData templateData);

    public void setBody(final String text, final boolean processable);
    public void setBody(final IModel model, final boolean processable);

    public void insertBefore(final IModel model); // cannot be processable
    public void insertImmediatelyAfter(final IModel model, final boolean processable);

    public void replaceWith(final String text, final boolean processable);
    public void replaceWith(final IModel model, final boolean processable);


    public void removeElement();
    public void removeTags();
    public void removeBody();
    public void removeAllButFirstChild();

    public void iterateElement(final String iterVariableName, 
                               final String iterStatusVariableName, 
                               final Object iteratedObject);

}
```

Ahí podemos ver todas las acciones que un procesador puede solicitar al motor de 
plantillas que realice como resultado de su ejecución. Los nombres de los 
métodos son bastante autoexplicativos (y cuentan con documentación Javadoc), 
pero en resumen:

  * `setLocalVariable(...)`/`removeLocalVariable(...)` añade una variable local a 
la ejecución de la plantilla. Esta variable local será accesible durante el 
resto de la ejecución del evento actual, así como durante todo su cuerpo (es 
decir, hasta su etiqueta de cierre correspondiente).
  * `setAttribute(...)` añade un nuevo atributo a la etiqueta con un valor 
específico (y posiblemente también el tipo de comillas que lo rodean). Si el 
atributo ya existe, su valor se reemplazará.
  * `replaceAttribute(...)` reemplaza un atributo existente por uno nuevo, 
ocupando su lugar en el atributo (incluyendo, por ejemplo, los espacios en 
blanco que lo rodean).
* `removeAttribute(...)` elimina un atributo de la etiqueta.
* `setSelectionTarget(...)` modifica el objeto que se considerará el objetivo de 
la selección, es decir, el objeto sobre el que se ejecutarán las expresiones de 
selección (`*{...}`). En el dialecto estándar, este *objetivo de selección* se 
suele modificar mediante el atributo `th:object`, pero los procesadores 
personalizados también pueden hacerlo. Tenga en cuenta que el *objetivo de 
selección* tiene el mismo ámbito que una variable local y, por lo tanto, solo 
será accesible dentro del cuerpo del elemento que se está procesando.
* `setInliner(...)` modifica el *inliner* que se utilizará para procesar todos 
los nodos de texto (eventos `IText`) que aparecen en el cuerpo del elemento que 
se está procesando. Este es el mecanismo que utiliza el atributo `th:inline` para 
habilitar la *inlining* en cualquiera de los modos especificados (`text`, 
`javascript`, etc.).
* `setTemplateData(...)` modifica los metadatos de la plantilla que se está 
procesando. Al insertar fragmentos, esto permite que el motor conozca los datos 
del fragmento específico que se está procesando, así como la pila completa de 
fragmentos anidados.
* `setBody(...)` reemplaza todo el cuerpo del elemento que se está procesando 
con el texto o modelo pasado (secuencia de eventos = fragmento de marcado). Así 
es como funcionan, por ejemplo, `th:text`/`th:utext`. Tenga en cuenta que el 
texto o modelo de reemplazo especificado puede configurarse como *procesable* o 
no, dependiendo de si queremos ejecutar algún procesador que pueda estar 
asociado a él. En el caso de `th:utext="${var}"`, por ejemplo, el reemplazo se 
configura como *no procesable* para evitar ejecutar cualquier marcado que pueda 
devolver `${var}` como parte de la plantilla.
* `insertBefore(...)`/`insertImmediatelyAfter(...)` permiten especificar un 
modelo (fragmento de marcado) que debe aparecer antes o *inmediatamente* después 
de la etiqueta que se está procesando. Tenga en cuenta que 
`insertImmediatelyAfter` significa *después de la etiqueta que se está 
procesando* (y, por lo tanto, como la primera parte del cuerpo del elemento) y 
no *después de todo el elemento que se abre aquí y se cierra en una etiqueta de 
cierre en algún lugar*.
* `replaceWith(...)` permite reemplazar el *elemento* actual (elemento completo) 
con el texto o modelo especificado como argumento.
* `removeElement()`/`removeTags()`/`removeBody()`/`removeAllButFirstChild()` 
permiten al procesador eliminar, respectivamente, todo el elemento incluyendo su 
cuerpo; solo las etiquetas ejecutadas (apertura + cierre) pero no el cuerpo; 
solo el cuerpo pero no las etiquetas contenedoras; y, por último, todos los 
elementos hijos de la etiqueta excepto el primer elemento hijo. Tenga en cuenta 
que todas estas opciones reflejan básicamente los diferentes valores que se 
pueden usar en el atributo `th:remove`.
* `iterateElement(...)` permite iterar sobre el elemento actual (incluido el 
cuerpo) tantas veces como elementos existan en el `iteratedObject` (que 
normalmente será una `Collection`, un `Map`, un `Iterator` o un array). Los otros 
dos argumentos se utilizarán para especificar los nombres de las variables que 
se usarán para los elementos iterados y la variable de estado.

**Implementaciones abstractas para `IElementTagProcessor`**

Thymeleaf ofrece dos implementaciones básicas de `IElementTagProcessor` que los 
procesadores pueden implementar para mayor comodidad:

* `org.thymeleaf.processor.element.AbstractElementTagProcessor`, diseñada para 
procesadores que comparan eventos de elementos por su nombre (es decir, sin 
tener en cuenta los atributos).

* `org.thymeleaf.processor.element.AbstractAttributeTagProcessor`, diseñada para 
procesadores que comparan eventos de elementos por uno de sus atributos (y 
opcionalmente también por el nombre del elemento).


### Procesadores de elementos de Modelo: `IElementModelProcessor`

Los procesadores de modelos de elementos se ejecutan sobre los elementos 
completos con los que coinciden —incluidos sus cuerpos— en forma de un objeto 
`IModel` que contiene la secuencia completa de eventos que modela dicho elemento 
y su contenido. El `IElementModelProcessor` es muy similar al que se vio 
anteriormente para los *procesadores de etiquetas*:

```java
public interface IElementModelProcessor extends IElementProcessor {

    public void process(
            final ITemplateContext context, 
            final IModel model,
            final IElementModelStructureHandler structureHandler);

}
```

Nótese cómo esta interfaz también extiende `IElementProcessor`, y cómo el 
método `process(...)` que contiene sigue la misma estructura que la de los 
procesadores de etiquetas, reemplazando `tag` por `model`, por supuesto:

* `process(...)` devuelve `void`. Las acciones se realizarán sobre `model` o 
`structureHandler`, no devolviendo ningún valor.
* `context` contiene el contexto de ejecución: variables, etc.
* `model` es la secuencia de eventos que modela el elemento completo sobre el 
que se ejecuta el procesador. Este modelo se puede modificar directamente desde 
el procesador.
* `structureHandler` permite indicar al motor que realice acciones más allá de 
la modificación del modelo (por ejemplo, establecer variables locales). 

**Lectura y modificación del modelo**

El objeto `IModel` que se pasa como parámetro al método `process()` es un modelo 
**mutable**, por lo que permite cualquier modificación (los *modelos* son mutables, 
los *eventos* como las *etiquetas* son inmutables). Por ejemplo, podríamos 
modificarlo para reemplazar cada nodo de texto de su cuerpo con un comentario 
del mismo contenido:

```java
final IModelFactory modelFactory =  context.getModelFactory();

int n = model.size();
while (n-- != 0) {
    final ITemplateEvent event = model.get(n);
    if (event instanceof IText) {
        final IComment comment =
                modelFactory.createComment(((IText)event).getText());
        model.insert(n, comment);
        model.remove(n + 1);
    }
}
```

Cabe destacar también que la interfaz `IModel` incluye un método 
`accept(IModelVisitor visitor)`, útil para recorrer un modelo completo en busca 
de nodos específicos o datos relevantes utilizando el patrón *Visitor*.

**Uso del `structureHandler`**

De forma similar a los *procesadores de etiquetas*, a los procesadores de 
modelos se les pasa un objeto *structureHandler* que les permite indicar al 
motor qué acciones no se pueden realizar actuando directamente sobre el objeto 
`IModel model`. La interfaz que implementan estos StructureHandlers, mucho más 
pequeña que la de los procesadores de etiquetas, es `IElementModelStructureHandler`:

```java
public interface IElementModelStructureHandler {

    public void reset();

    public void setLocalVariable(final String name, final Object value);
    public void removeLocalVariable(final String name);

    public void setSelectionTarget(final Object selectionTarget);

    public void setInliner(final IInliner inliner);

    public void setTemplateData(final TemplateData templateData);

}
```

Es fácil ver que este es un subconjunto del de los procesadores de etiquetas. Los 
pocos métodos que contiene funcionan de la misma manera:

* `setLocalVariable(...)`/`removeLocalVariable(...)` para agregar/eliminar 
variables locales que estarán disponibles durante la ejecución del modelo 
(después de la ejecución del procesador actual).
* `setSelectionTarget(...)` para modificar el *objetivo de selección* aplicado 
durante la ejecución del modelo.
* `setInliner(...)` para establecer un inliner.
* `setTemplateData(...)` para establecer metadatos sobre la plantilla que se 
está procesando.

**Implementaciones abstractas para `IElementModelProcessor`**

Thymeleaf ofrece dos implementaciones básicas de `IElementModelProcessor` que 
los procesadores pueden implementar para mayor comodidad:

* `org.thymeleaf.processor.element.AbstractElementModelProcessor`, diseñada para 
procesadores que comparan eventos de elementos por su nombre (es decir, sin 
tener en cuenta los atributos).

* `org.thymeleaf.processor.element.AbstractAttributeModelProcessor`, diseñada 
para procesadores que comparan eventos de elementos por uno de sus atributos (y 
opcionalmente también por el nombre del elemento).


### Procesadores de inicio y final de plantillas: `ITemplateBoundariesProcessor`

Los procesadores de límites de plantilla son un tipo de procesador que se 
ejecuta con los eventos *template start* y *template end* que se activan durante 
el procesamiento de la plantilla. Permiten realizar cualquier tipo de 
inicialización o liberación de recursos al inicio o al final de la operación de 
procesamiento de la plantilla. Cabe destacar que estos eventos **solo se activan 
para la plantilla de primer nivel**, y no para cada uno de los fragmentos que 
puedan analizarse o incluirse en la plantilla que se está procesando.

La interfaz `ITemplateBoundariesProcessor` tiene el siguiente aspecto:

```java
public interface ITemplateBoundariesProcessor extends IProcessor {

    public void processTemplateStart(
            final ITemplateContext context,
            final ITemplateStart templateStart,
            final ITemplateBoundariesStructureHandler structureHandler);

    public void processTemplateEnd(
            final ITemplateContext context,
            final ITemplateEnd templateEnd,
            final ITemplateBoundariesStructureHandler structureHandler);

}
```
En esta ocasión, la interfaz ofrece dos métodos `process*(...)`, uno para los 
eventos de *inicio de plantilla* y otro para los de *fin de plantilla*. Su firma 
sigue el mismo patrón que los demás métodos `process(...)` que vimos 
anteriormente, recibiendo el contexto, el objeto de evento y el manejador de 
estructura. Este manejador de estructura, en este caso, implementa una 
interfaz `ITemplateBoundariesStructureHandler` bastante sencilla:

```java
public interface ITemplateBoundariesStructureHandler {

    public void reset();

    public void setLocalVariable(final String name, final Object value);
    public void removeLocalVariable(final String name);

    public void setSelectionTarget(final Object selectionTarget);

    public void setInliner(final IInliner inliner);

    public void insert(final String text, final boolean processable);
    public void insert(final IModel model, final boolean processable);

}
```

Podemos ver cómo, además de los métodos habituales para gestionar variables 
locales, selección de destino e inliner, también podemos utilizar el manejador 
de estructura para insertar texto o un modelo, que en este caso aparecerá al 
principio o al final del resultado (dependiendo del evento que se esté 
procesando).


### Otros procesadores

Thymeleaf 3.0 permite declarar procesadores para otros eventos, cada uno de los 
cuales implementa su interfaz correspondiente:

* Eventos de **Texto**: interfaz `ITextProcessor`
* Eventos de **Comentario**: interfaz `ICommentProcessor`
* Eventos de **Sección CDATA**: interfaz `ICDATASectionProcessor`
* Eventos de **Cláusula DOCTYPE**: interfaz `IDocTypeProcessor`
* Eventos de **Declaración XML**: interfaz `IXMLDeclarationProcessor`
* Eventos de **Procesamiento de Instrucciones**: interfaz `IProcessingInstructionProcessor`

Todas tienen una apariencia similar a esta (que corresponde a los eventos de texto):

```java
public interface ITextProcessor extends IProcessor {

    public void process(
            final ITemplateContext context, 
            final IText text,
            final ITextStructureHandler structureHandler);

}
```

El mismo patrón que todos los demás métodos `process(...)`: contexto, evento, 
manejador de estructura. Y estos manejadores de estructura son muy simples, como 
este (de nuevo, el de los eventos de texto):

```java
public interface ITextStructureHandler {

    public void reset();

    public void setText(final CharSequence text);

    public void replaceWith(final IModel model, final boolean processable);

    public void removeText();

}
```




3 Crear nuestro propio dialecto
==========================

El código fuente de los ejemplos que se muestran en este y en futuros capítulos 
de esta guía se puede encontrar en el [repositorio de GitHub de extraThyme](https://github.com/thymeleaf/thymeleafexamples-extrathyme).


3.1. extraThyme: un sitio web para la liga de fútbol de Thymeland
----------------------------------------------------------

El fútbol es un deporte popular en Thymeland^[fútbol europeo, por supuesto ;-)].
Allí se disputa una liga de 10 equipos cada temporada, y sus organizadores nos 
han pedido que creemos una página web llamada "extraThyme".

Esta página web será muy sencilla: solo una tabla con:

* Los nombres de los equipos.
* El número de partidos ganados, empatados o perdidos, así como el total de 
puntos obtenidos.
* Una nota que explique si su posición en la tabla les permite clasificarse para 
competiciones de mayor nivel el año que viene o si, por el contrario, suponen su 
descenso a ligas regionales.

Sobre la tabla de clasificación, un banner mostrará titulares con los resultados 
de los últimos partidos. Además, habrá un banner bien visible que advertirá a 
los usuarios todos los domingos que son días de partido y, por lo tanto, 
deberían ir al estadio en lugar de navegar por internet.


![tabla de la liga extraThyme](images/extendingthymeleaf/extrathyme-league-table.png)

Para nuestra aplicación, utilizaremos HTML5, Spring MVC y el dialecto 
SpringStandard. Ampliaremos Thymeleaf creando un dialecto `score` que incluye:

* Un atributo `score:remarkforposition` que muestra texto internacionalizado en 
la columna Remarks de la tabla. Este texto debe explicar si la posición del 
equipo en la tabla le permite clasificarse para la Liga de Campeones Mundiales, 
los Play-Offs Continentales o si desciende a la Liga Regional.

* Un atributo `score:classforposition` que establece una clase CSS para las 
filas de la tabla según los comentarios del equipo: fondo azul para la Liga de 
Campeones Mundiales, verde para los Play-Offs Continentales y rojo para el 
descenso.
* Una etiqueta `score:headlines` para mostrar el recuadro amarillo en la parte 
superior con los resultados de los partidos recientes. Esta etiqueta debe admitir 
un atributo order con los valores `random` (para mostrar un partido seleccionado 
al azar) y `latest` (por defecto, para mostrar solo el último partido). 
* Un atributo `score:match-day-today` que se puede añadir al encabezado de la 
tabla de clasificación para (condicionalmente, si es domingo) mostrar un banner 
que advierta al usuario que hoy hay partido.

Nuestro código HTML se verá así, utilizando los atributos `th` y `score`:


```html
<!DOCTYPE html>

<!--/* Tenga en cuenta que los xmlns:* aquí son completamente opcionales y solo sirven para */-->
<!--/* evitar que los IDE muestren errores sobre etiquetas/atributos que quizás desconozcan */-->
<html xmlns:th="http://www.thymeleaf.org" xmlns:score="http://thymeleafexamples">

  <head>
    <title>extraThyme: Thymeland's football website</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" type="text/css" media="all"
          href="../../css/extrathyme.css" th:href="@{/css/extrathyme.css}"/>
  </head>

  <body>

    <div>
      <img src="../../images/extrathymelogo.png" 
           alt="extraThyme logo" title="extraThyme logo"
           th:src="@{/images/extrathymelogo.png}" th:alt-title="#{title.application}"/>
    </div>

    <score:headlines order="random" />

    <div class="leaguetable">

      <h2 score:match-day-today th:text="#{title.leaguetable(${execInfo.now.time})}">
        League table for 07 July 2011
      </h2>
      
      <table>
        <thead>
          <tr>
            <th th:text="#{team.name}">Team</th>
            <th th:text="#{team.won}" class="matches">Won</th>
            <th th:text="#{team.drawn}" class="matches">Drawn</th>
            <th th:text="#{team.lost}" class="matches">Lost</th>
            <th th:text="#{team.points}" class="points">Points</th>
            <th th:text="#{team.remarks}">Remarks</th>
          </tr>
        </thead>
        <tbody>
          <tr th:each="t : ${teams}" score:classforposition="${tStat.count}">
            <td th:text="|${t.name} (${t.code})|">The Winners (TWN)</td>
            <td th:text="${t.won}" class="matches">1</td>
            <td th:text="${t.drawn}" class="matches">0</td>
            <td th:text="${t.lost}" class="matches">0</td>
            <td th:text="${t.points}" class="points">3</td>
            <td score:remarkforposition="${tStat.count}">Great winner!</td>
          </tr>
          <!--/*-->
          <tr>
            <td>The First Losers (TFL)</td>
            <td class="matches">0</td>
            <td class="matches">1</td>
            <td class="matches">0</td>
            <td class="points">1</td>
            <td>Little loser!</td>
          </tr>
          <tr>
            <td>The Last Losers (TLL)</td>
            <td class="matches">0</td>
            <td class="matches">0</td>
            <td class="matches">1</td>
            <td class="points">0</td>
            <td>Big loooooser</td>
          </tr>
          <!--*/-->
        </tbody>
      </table>

    </div>

  </body>

</html>
```      

_(Tenga en cuenta que hemos añadido una segunda y una tercera fila a nuestra 
tabla, rodeadas de comentarios a nivel de analizador sintáctico `<!--/* ... */-->` 
para que nuestra plantilla se muestre correctamente como prototipo al abrirla 
directamente en un navegador.)_



3.2. Cambiar la clase CSS según la posición del equipo.
--------------------------------------------

El primer procesador de atributos que desarrollaremos será 
`ClassForPositionAttributeTagProcessor`, que implementaremos como una subclase 
de una clase abstracta de conveniencia proporcionada por Thymeleaf llamada 
`AbstractAttributeTagProcessor`.

Esta clase abstracta es la base para todos los procesadores de etiquetas (es 
decir, los procesadores que actúan sobre eventos de *etiquetas* y no sobre 
*modelos*) que coinciden (es decir, se seleccionan para su ejecución) en función 
de la existencia de un atributo específico en dicha etiqueta. En este caso, 
`score:classforposition`.

La idea es que utilizaremos este procesador para establecer un nuevo valor para 
el atributo `class` de la etiqueta a la que pertenece `score:classforposition`.

Veamos nuestro código:

```java
public class ClassForPositionAttributeTagProcessor extends AbstractAttributeTagProcessor {

    private static final String ATTR_NAME = "classforposition";
    private static final int PRECEDENCE = 10000;


    public ClassForPositionAttributeTagProcessor(final String dialectPrefix) {
        super(
            TemplateMode.HTML, // Este procesador se aplicará únicamente al modo HTML.
            dialectPrefix,     // Prefijo que se aplicará al nombre para que coincida
            null,              // Sin nombre de etiqueta: coincide con cualquier nombre de etiqueta
            false,             // No se aplicará ningún prefijo al nombre de la etiqueta.
            ATTR_NAME,         // Nombre del atributo que se comparará
            true,              // Aplicar prefijo de dialecto al nombre del atributo
            PRECEDENCE,        // Precedencia (dentro de la propia precedencia del dialecto)
            true);             // Elimine el atributo coincidente posteriormente
    }


    @Override
    protected void doProcess(
            final ITemplateContext context, final IProcessableElementTag tag,
            final AttributeName attributeName, final String attributeValue,
            final IElementTagStructureHandler structureHandler) {

        final IEngineConfiguration configuration = context.getConfiguration();

        /*
         * Obtiene el analizador de expresiones estándar de Thymeleaf.
         */
        final IStandardExpressionParser parser =
                StandardExpressions.getExpressionParser(configuration);

        /*
         * Analiza el valor del atributo como una expresión estándar de Thymeleaf.
         */
        final IStandardExpression expression = parser.parseExpression(context, attributeValue);

        /*
         * Ejecuta la expresión que se acaba de analizar.
         */
        final Integer position = (Integer) expression.execute(context);

        /*
         * Obtiene la observación correspondiente a esta posición en la tabla de clasificación.
         */
        final Remark remark = RemarkUtil.getRemarkForPosition(position);

        /*
         * Selecciona la clase CSS adecuada para el elemento.
         */
        final String newValue;
        if (remark == Remark.WORLD_CHAMPIONS_LEAGUE) {
            newValue = "wcl";
        } else if (remark == Remark.CONTINENTAL_PLAYOFFS) {
            newValue = "cpo";
        } else if (remark == Remark.RELEGATION) {
            newValue = "rel";
        } else {
            newValue = null;
        }

        /*
         * Establece el nuevo valor en el atributo 'class' (posiblemente agregándolo a un valor existente).
         */
        if (newValue != null) {
            String currentClass = tag.getAttribute("class").getValue();
            if (currentClass != null) {
                structureHandler.setAttribute("class", currentClass + " " + newValue);
            } else {
                structureHandler.setAttribute("class", newValue);
            }
        }

    }

}
```

El flujo lógico básico es fácil de ver y comprender: se obtiene el valor del 
atributo, se utiliza para calcular lo necesario y, finalmente, se usa el 
`structureHandler` para indicar al motor las modificaciones necesarias como 
resultado.

Es importante destacar que creamos este atributo con la capacidad de ejecutar 
expresiones escritas en la sintaxis estándar (utilizada tanto por el dialecto 
_Standard_ como por el de _SpringStandard_). Esto significa que se pueden 
establecer valores como `${var}`, `#{messageKey}`, condicionales, etc. Vea cómo 
lo usamos en nuestra plantilla:

```html
<tr th:each="t : ${teams}" score:classforposition="${tStat.count}">
```

Para evaluar estas expresiones (también llamadas _Expresiones estándar de 
Thymeleaf_) primero necesitamos obtener el analizador de expresiones estándar, 
luego analizar el valor del atributo y, finalmente, ejecutar la expresión 
analizada:

```java
final IStandardExpressionParser parser =
        StandardExpressions.getExpressionParser(configuration);

final IStandardExpression expression = parser.parseExpression(context, attributeValue);

final Integer position = (Integer) expression.execute(context);
```

También es interesante la forma en que usamos el `structureHandler` para 
agregar un nuevo atributo a la etiqueta principal (recuerde que el objeto `tag` 
es inmutable):

```java
if (newValue != null) {
    String currentClass = tag.getAttribute("class").getValue();
    if (currentClass != null) {
        structureHandler.setAttribute("class", currentClass + " " + newValue);
    } else {
        structureHandler.setAttribute("class", newValue);
    }
}
```

Por último, tenga en cuenta que **el escape de textos y atributos HTML es 
nuestra responsabilidad**, pero en este caso conocemos todos los valores 
posibles de la variable `newValue` y no requieren escape, por lo que, en aras 
de la simplicidad, omitimos esa operación.


3.3. Mostrar un comentario internacionalizado
-------------------------------------------

The next thing to do is creating an attribute processor able to display the remark text. This 
will be very similar to the `ClassForPositionAttrProcessor`, but with a couple of important differences:

 * We will not be setting a value for an attribute in the host tag, but rather the text body (content) of 
   the tag, in the same way a `th:text` attribute does.
 * We need to access the message externalization (internationalization) system from our code so that we 
   can display the text corresponding to the selected locale.

We will be using the same `AbstractAttributeTagProcessor` base class. And this will be our code:

```java
public class RemarkForPositionAttributeTagProcessor extends AbstractAttributeTagProcessor {

    private static final String ATTR_NAME = "remarkforposition";
    private static final int PRECEDENCE = 12000;


    public RemarkForPositionAttributeTagProcessor(final String dialectPrefix) {
        super(
            TemplateMode.HTML, // This processor will apply only to HTML mode
            dialectPrefix,     // Prefix to be applied to name for matching
            null,              // No tag name: match any tag name
            false,             // No prefix to be applied to tag name
            ATTR_NAME,         // Name of the attribute that will be matched
            true,              // Apply dialect prefix to attribute name
            PRECEDENCE,        // Precedence (inside dialect's precedence)
            true);             // Remove the matched attribute afterwards
    }


    @Override
    protected void doProcess(
            final ITemplateContext context, final IProcessableElementTag tag,
            final AttributeName attributeName, final String attributeValue,
            final IElementTagStructureHandler structureHandler) {

        final IEngineConfiguration configuration = context.getConfiguration();

        /*
         * Obtain the Thymeleaf Standard Expression parser
         */
        final IStandardExpressionParser parser =
                StandardExpressions.getExpressionParser(configuration);

        /*
         * Parse the attribute value as a Thymeleaf Standard Expression
         */
        final IStandardExpression expression =
                parser.parseExpression(context, attributeValue);

        /*
         * Execute the expression just parsed
         */
        final Integer position = (Integer) expression.execute(context);

        /*
         * Obtain the remark corresponding to this position in the league table
         */
        final Remark remark = RemarkUtil.getRemarkForPosition(position);
        
        /*
         * If no remark is to be applied, just set an empty body to this tag
         */
        if (remark == null) {
            structureHandler.setBody("", false); // false == 'non-processable'
            return;
        }
        
        /*
         * Message should be internationalized, so we ask the engine to resolve
         * the message 'remarks.{REMARK}' (e.g. 'remarks.RELEGATION'). No
         * parameters are needed for this message.
         *
         * Also, we will specify to "use absent representation" so that, if this
         * message entry didn't exist in our resource bundles, an absent-message
         * label will be shown.
         */
        final String i18nMessage =
                context.getMessage(
                        RemarkForPositionAttributeTagProcessor.class, 
                        "remarks." + remark.toString(), 
                        new Object[0], 
                        true);

        /*
         * Set the computed message as the body of the tag, HTML-escaped and
         * non-processable (hence the 'false' argument)
         */
        structureHandler.setBody(HtmlEscape.escapeHtml5(i18nMessage), false);
        
    }

}
```

### Acceso a los mensajes i18n

Note that we are accessing the message externalization system with:

```java
final String i18nMessage =
        context.getMessage(
                RemarkForPositionAttributeTagProcessor.class, 
                "remarks." + remark.toString(), 
                new Object[0], 
                true);
```

This will call the message resolution mechanism configured at the engine, passing
not only the specific key we are interested on and its parameters (none, in this case), but
also two other pieces of information:

  * The *origin* to be assigned to the message: `RemarkForPositionAttributeTagProcessor.class`
  * Whether an *absent message representation* should be used (`true`)

Message resolution is an **extension point** in Thymeleaf (`IMessageResolver` interface), and
therefore how these parameters are treated depends on the specific implementation being used.
The default implementation in non-Spring-enabled applications (`StandardMessageResolver`) 
will do the following:

  * First look for `.properties` files with the same name as the template file + the locale. So
    if the template is `/views/main.html` and locale is `gl_ES`, it will look for
    `/views/main_gl_ES.properties`, then `/views/main_gl.properties` and last
    `/views/main.properties`.
  * If not found, then use the *origin* class (which could have been specified `null`) and look
    for `.properties` files in classpath with the name of the class specified there (the
    processor's own class): `classpath:thymeleafexamples/extrathyme/dialects/score/RemarkForPositionAttributeTagProcessor_gl_ES.properties`,
    etc. This allows the *componentization* or processors and dialects with their whole set of
    i18n resource bundles in plain old `.jar` files.
  * If none of these are found, have a look at the *absent message representation* flag. If `false`,
    simply return `null`. If `true`, create some kind of text that will allow the developer or user
    to quickly identify the fact that an i18n resource is missing: `??remarks.rel_gl_ES??`.

_(Note that, in Spring-enabled applications, this message resolution mechanism will be replaced by default
with Spring's own, based on the `MessageSource` beans declared at the Spring Application Context.)_


### Escapar contenido HTML

Also, in this processor we are performing the required HTML-escaping of the content we are setting
by using the `HtmlEscape` class from the [Unbescape](http://unbescape.org) library, used for this
purpose throughout Thymeleaf:

```java
structureHandler.setBody(HtmlEscape.escapeHtml5(i18nMessage), false);
```


3.4. Un procesador de elementos para nuestros titulares
-------------------------------------------

The third processor we will write is an element (tag) processor. Note we call this an *element tag processor*
in contrast with the two previous processors, which were *attribute tag processors*. The reason is, in this case
we want our processor to match (i.e. to be selected for execution) based on the **name of the tag**, not
on the name of one of its attributes.

This kind of tag processor has one advantage and also one disadvantage with
respect to attribute tag processors:

 * Advantage: elements can contain multiple attributes, and so your element processors can receive a richer and 
   more complex set of configuration parameters.
 * Disadvantage: custom elements/tags are unknown to browsers, and so if you are developing a web application 
   using custom tags you might have to sacrifice one of the most interesting features of Thymeleaf: the ability 
   to statically display templates as prototypes (_natural templating_).

This processor will extend `AbstractElementTagProcessor`, the base class to be used for tag processors that
do not match on a specific attribute:

```java
public class HeadlinesElementTagProcessor extends AbstractElementTagProcessor {

    private static final String TAG_NAME = "headlines";
    private static final int PRECEDENCE = 1000;


    private final Random rand = new Random(System.currentTimeMillis());


    public HeadlinesElementTagProcessor(final String dialectPrefix) {
        super(
            TemplateMode.HTML, // This processor will apply only to HTML mode
            dialectPrefix,     // Prefix to be applied to name for matching
            TAG_NAME,          // Tag name: match specifically this tag
            true,              // Apply dialect prefix to tag name
            null,              // No attribute name: will match by tag name
            false,             // No prefix to be applied to attribute name
            PRECEDENCE);       // Precedence (inside dialect's own precedence)
    }


    @Override
    protected void doProcess(
            final ITemplateContext context, final IProcessableElementTag tag,
            final IElementTagStructureHandler structureHandler) {

        /*
         * Obtain the Spring application context.
         */
        final ApplicationContext appCtx = SpringContextUtils.getApplicationContext(context);

        /*
         * Obtain the HeadlineRepository bean from the application context, and ask
         * it for the current list of headlines.
         */
        final HeadlineRepository headlineRepository = appCtx.getBean(HeadlineRepository.class);
        final List<Headline> headlines = headlineRepository.findAllHeadlines();

        /*
         * Read the 'order' attribute from the tag. This optional attribute in our tag 
         * will allow us to determine whether we want to show a random headline or
         * only the latest one ('latest' is default).
         */
        final String order = tag.getAttributeValue("order");

        String headlineText = null;
        if (order != null && order.trim().toLowerCase().equals("random")) {
            // Order is random 

            final int r = this.rand.nextInt(headlines.size());
            headlineText = headlines.get(r).getText();
            
        } else {
            // Order is "latest", only the latest headline will be shown
            
            Collections.sort(headlines);
            headlineText = headlines.get(headlines.size() - 1).getText();
            
        }

        /*
         * Create the DOM structure that will be substituting our custom tag.
         * The headline will be shown inside a '<div>' tag, and so this must
         * be created first and then a Text node must be added to it.
         */
        final IModelFactory modelFactory = context.getModelFactory();

        final IModel model = modelFactory.createModel();

        model.add(modelFactory.createOpenElementTag("div", "class", "headlines"));
        model.add(modelFactory.createText(HtmlEscape.escapeHtml5(headlineText)));
        model.add(modelFactory.createCloseElementTag("div"));

        /*
         * Instruct the engine to replace this entire element with the specified model.
         */
        structureHandler.replaceWith(model, false);
        
    }

}
```

The first interesting part of the code above is showing how to access Spring's `ApplicationContext`
in order to obtain one of our beans from it (the `HeadlineRepository`):

```java
final ApplicationContext appCtx = SpringContextUtils.getApplicationContext(context);
```

Also, this processor is different to the previous ones in that we will need to *create markup* as 
a result of its execution: we are going to replace the original `<score:headlines .../>` tag with
a `<div>...</div>` fragment, so we will need to make use of the **model factory**.


### El objeto Factoría de Modelos

The model factory is a special object available to processors (and other
structures such as pre-processors, post-processors, etc.) that can create new
instances of *events* as *models* (fragments of templates), and also new
instances of *models* themselves.

It is therefore the tool for creating new markup, like we can see in the code
above:

```java
final IModelFactory modelFactory = context.getModelFactory();

final IModel model = modelFactory.createModel();

model.add(modelFactory.createOpenElementTag("div", "class", "headlines"));
model.add(modelFactory.createText(HtmlEscape.escapeHtml5(headlineText)));
model.add(modelFactory.createCloseElementTag("div"));
```

Note how markup events needs to be created *one event at a time*, and how the open and close tags for the same `div`
element have to be created separately and in the correct order. This is because models are *sequences of
events* and not nodes in a Document Object Model (DOM).

The model factory offers a quite complete set of methods for creating all types of events: tags, texts, DOCTYPEs... and
also useful methods for modifying the attributes in a tag (by creating a new `tag` instance, given they are immutable),
such as:

```java
final IOpenElemenTag newTag = modelFactory.setAttribute(tag, "class", "newvalue");
```

Also, the model factory is able to create `IModel` instances from scratch (like the `modelFactory.createModel()` above),
from a single existing event, and also from a piece of markup that we want to convert into its corresponding sequence
of events by *parsing* it:

```java
final IModel model = 
        modelFactory.parse(
                context.getTemplateData(), 
                "<div class='headlines'>Some headlines</div>");
```




3.5. Un modelo de procesador para nuestro banner "Día de partido hoy".
-------------------------------------------------------

The last processor we will include in our dialect is of a different nature than the ones we've seen so
far: it is a **model processor**, not a *tag processor*.

As already mentioned in a previous section, model processors do not execute on a
specific tag event, but on the complete sequence of events (i.e. the *model*)
that contains the entire element they are matching.

So if we have a model processor that matches `<p>` tags with attribute `score:matcher`, and a fragment of
template such as:

```html
<p score:matcher="whatever">
    This is some body
</p>
```

That *model processor* will receive as an argument of its `doProcess()` method
an `IModel` containing 3 events: `<p score:matcher="whatever">` (open tag), 
`\n    This is some body\n` (text) and `</p>` (close tag).


So back to our requirements: we wanted a model processor matching a
`scrore:match-day-today`, that we can apply to the league table header and 
make it display, below this header, a banner warning the user that sundays are match days:

```html
<h2 score:match-day-today th:text="#{title.leaguetable(${execInfo.now.time})}">
    League table for 07 July 2011
</h2>
```

Note that we don't need a value for this `score:match-day-today` attribute, so
we can just ignore it. Our code will like like this:


```java
public class MatchDayTodayModelProcessor extends AbstractAttributeModelProcessor {

    private static final String ATTR_NAME = "match-day-today";
    private static final int PRECEDENCE = 100;


    public MatchDayTodayModelProcessor(final String dialectPrefix) {
        super(
            TemplateMode.HTML, // This processor will apply only to HTML mode
            dialectPrefix,     // Prefix to be applied to name for matching
            null,              // No tag name: match any tag name
            false,             // No prefix to be applied to tag name
            ATTR_NAME,         // Name of the attribute that will be matched
            true,              // Apply dialect prefix to attribute name
            PRECEDENCE,        // Precedence (inside dialect's own precedence)
            true);             // Remove the matched attribute afterwards
    }


    protected void doProcess(
            final ITemplateContext context, final IModel model,
            final AttributeName attributeName, final String attributeValue,
            final IElementModelStructureHandler structureHandler) {


        if (!checkPositionInMarkup(context)) {
            throw new TemplateProcessingException(
                    "The " + ATTR_NAME + " attribute can only be used inside a " +
                    "markup element with class \"leaguetable\"");
        }

        final Calendar now = Calendar.getInstance(context.getLocale());
        final int dayOfWeek = now.get(Calendar.DAY_OF_WEEK);

        // Sundays are Match Days!!
        if (dayOfWeek == Calendar.SUNDAY) {

            // The Model Factory will allow us to create new events
            final IModelFactory modelFactory = context.getModelFactory();

            // We will be adding the "Today is Match Day" banner just after
            // the element we are processing for:
            //
            // <h4 class="matchday">Today is MATCH DAY!</h4>
            //
            model.add(modelFactory.createOpenElementTag("h4", "class", "matchday")); //
            model.add(modelFactory.createText("Today is MATCH DAY!"));
            model.add(modelFactory.createCloseElementTag("h4"));

        }

    }


    private static boolean checkPositionInMarkup(final ITemplateContext context) {

        /*
         * We want to make sure this processor is being applied inside a container tag which has
         * class="leaguetable". So we need to check the second-to-last entry in the element stack
         * (the last entry is the tag being processed itself).
         */

        final List<IProcessableElementTag> elementStack = context.getElementStack();
        if (elementStack.size() < 2) {
            return false;
        }

        final IProcessableElementTag container = elementStack.get(elementStack.size() - 2);
        if (!(container instanceof IOpenElementTag)) {
            return false;
        }

        final String classValue = container.getAttributeValue("class");
        return classValue != null && classValue.equals("leaguetable");

    }


}
```

The first thing to note is that we are performing a check on the position the attribute
is being used at: we will only allow it inside a container with `class="leaguetable"`. So
our `checkPositionInMarkup(...)` method makes use of the *element stack* in order to
know the list of tags that had to be processed in order to process the current one.


Also, regarding the way the new banner element is created (an `<h4>`) notice how what
we are doing is modifying the `model` attribute passed as an argument to `doProcess(...)`.
No new model object is being created:

```java
final IModelFactory modelFactory = context.getModelFactory();

model.add(modelFactory.createOpenElementTag("h4", "class", "matchday")); //
model.add(modelFactory.createText("Today is MATCH DAY!"));
model.add(modelFactory.createCloseElementTag("h4"));
```



3.6. Declarándolo todo: el dialecto
----------------------------------

The last step we need to take in order to complete our dialect is, of course,
the dialect class itself.

As seen in a previous section, dialects might implement different interfaces
depending on what they provide to the template engine. In this case, our dialect
is only providing processors so it will be implementing `IProcessorDialect`.

In fact, we will extend an abstract convenience implementation that will ease
the implementation of the interface: `AbstractProcessorDialect`:

```java
public class ScoreDialect extends AbstractProcessorDialect {

    private static final String DIALECT_NAME = "Score Dialect";


    public ScoreDialect() {
        // We will set this dialect the same "dialect processor" precedence as
        // the Standard Dialect, so that processor executions can interleave.
        super(DIALECT_NAME, "score", StandardDialect.PROCESSOR_PRECEDENCE);
    }

    /*
     * Two attribute processors are declared: 'classforposition' and
     * 'remarkforposition'. Also one element processor: the 'headlines'
     * tag.
     */
    public Set<IProcessor> getProcessors(final String dialectPrefix) {
        final Set<IProcessor> processors = new HashSet<IProcessor>();
        processors.add(new ClassForPositionAttributeTagProcessor(dialectPrefix));
        processors.add(new RemarkForPositionAttributeTagProcessor(dialectPrefix));
        processors.add(new HeadlinesElementTagProcessor(dialectPrefix));
        processors.add(new MatchDayTodayModelProcessor(dialectPrefix));
        // This will remove the xmlns:score attributes we might add for IDE validation
        processors.add(new StandardXmlNsTagProcessor(TemplateMode.HTML, dialectPrefix));
        return processors;
    }


}
```

Once our dialect is created, we will need to add it to our Template Engine object
in order to use it. This being a Spring-enabled application, we will modify
the declared template engine bean:

```java
@Bean
public SpringTemplateEngine templateEngine(){
    SpringTemplateEngine templateEngine = new SpringTemplateEngine();
    templateEngine.setTemplateResolver(templateResolver());
    templateEngine.addDialect(new ScoreDialect());
    return templateEngine;
}
```

Note that the `addDialect(...)` call there will add the Score Dialect to the one
already configured by default in a `SpringTemplateEngine`: the SpringStandard dialect.

And that's it! Our dialect is ready to run now, and our league table will
display in exactly the way we wanted.
