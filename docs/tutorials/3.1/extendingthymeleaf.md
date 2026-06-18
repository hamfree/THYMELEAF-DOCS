---
title: 'Tutorial: Ampliando Thymeleaf'
author: Thymeleaf
version: @documentVersion@
thymeleafVersion: @projectVersion@
---




1 Algunas razones para ampliar Thymeleaf
========================================

Thymeleaf es una biblioteca extremadamente extensible. Su clave reside en que la 
mayoría de sus funcionalidades orientadas al usuario no están integradas 
directamente en su núcleo, sino que se empaquetan y organizan en conjuntos de 
funcionalidades llamados _dialectos_.

La biblioteca ofrece dos dialectos predefinidos: el dialecto _Stándard_ y el 
dialecto _SpringStandard_, pero puedes crear fácilmente el tuyo propio. Veamos algunas de las razones para hacerlo:




**Escenario 1: agregar funcionalidades a los dialectos Standard **

Supongamos que tu aplicación utiliza el dialecto _SpringStandard_ y que necesita 
mostrar un cuadro de texto de alerta con fondo azul o rojo, según el rol del 
usuario (administrador o no administrador), de lunes a sábado, pero siempre en 
verde los domingos. Puedes calcular esto con expresiones condicionales en tu 
plantilla, pero demasiadas condiciones podrían dificultar la lectura del 
código...

Solución: crea un nuevo atributo llamado `alertclass` y un procesador de 
atributos para él (código Java que calculará la clase CSS correcta), e 
incorpóralo a tu propio dialecto `MyOwnDialect`. Agrega este dialecto a tu motor 
de plantillas con el prefijo `th` (igual que el de _SpringStandard_) y ahora 
podrás usar `th:alertclass="${user.role}"`.


**Escenario 2: componentes de la capa de vista**

Supongamos que su empresa utiliza Thymeleaf de forma extensiva y desea crear un 
repositorio de funcionalidades comunes (etiquetas y/o atributos) que pueda usar 
en varias aplicaciones sin tener que copiarlas y pegarlas de una a otra. Es 
decir, desea crear componentes de la capa de vista de forma similar a las 
_bibliotecas de etiquetas_ de JSP.

Solución: cree un dialecto de Thymeleaf para cada conjunto de funcionalidades 
relacionadas y agréguelos a sus aplicaciones según sea necesario. Tenga en 
cuenta que si las etiquetas o atributos de estos dialectos utilizan mensajes 
externalizados (internacionalizados), podrá empaquetarlos junto con sus 
dialectos (en forma de _mensajes de procesador_) en lugar de exigir que todas 
sus aplicaciones los incluyan en sus archivos `.properties` de mensajes, como 
se haría con JSP.


**Escenario 3: crear su propio sistema de plantillas**

Ahora imagina que estás creando un sitio web público que permite a los usuarios 
crear sus propias plantillas de diseño para mostrar su contenido. Por supuesto, 
no quieres que tus usuarios puedan hacer absolutamente todo en sus plantillas, 
ni siquiera todo lo que permite el dialecto estándar (por ejemplo, ejecutar 
expresiones OGNL). Por lo tanto, necesitas ofrecer a tus usuarios la posibilidad 
de añadir a sus plantillas solo un conjunto muy específico de funciones que 
estén bajo tu control (como mostrar una foto de perfil, el texto de una entrada 
de blog, etc.).

Solución: crea un dialecto de Thymeleaf con las etiquetas o atributos que quieras 
que tus usuarios puedan usar, como `<mysite:profilePhoto />` o 
`<mysite:blogentries fromDate="23/4/2011" />`. Luego, permite que tus usuarios 
creen sus propias plantillas usando estas funciones y deja que Thymeleaf las 
ejecute, asegurándote de que nadie haga lo que no tiene permitido.




2 Dialectos y procesadores
==========================

2.1. Dialectos
--------------

Si has leído el tutorial _Uso de Thymeleaf_ antes de llegar aquí —lo cual 
deberías haber hecho—, sabrás que lo que has estado aprendiendo hasta ahora no 
era exactamente _Thymeleaf_, sino su _dialecto estándar_ (o el _dialecto 
SpringStandard_, si también has leído el tutorial _Thymeleaf + Spring_).

¿Qué significa esto? Significa que todos esos atributos `th:x` que aprendiste a 
usar son solo un conjunto estándar de características predefinidas, pero puedes 
definir tu propio conjunto de atributos (o etiquetas) con los nombres que desees 
y usarlos en Thymeleaf para procesar tus plantillas. 
*Puedes definir tus propios dialectos.*

Los dialectos son objetos que implementan la interfaz 
`org.thymeleaf.dialect.IDialect`, que no podría ser más sencilla:

```java
public interface IDialect {

    public String getName();

}
```
El único requisito fundamental de un dialecto es tener un nombre que pueda 
utilizarse para su identificación. Pero esto por sí solo es de poca utilidad, 
por lo que los dialectos normalmente implementarán una o varias subinterfaces de 
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
más importante de Thymeleaf. Abordaremos los procesadores con más detalle en las 
siguientes secciones.

Este dialecto solo define tres elementos:

  * El *prefijo*, que es el prefijo o espacio de nombres que se debe aplicar 
  *por defecto* a los elementos y atributos que coinciden con los procesadores 
  del dialecto. Así, un dialecto con el prefijo `th`, como por ejemplo el 
  *Dialecto Estándar*, podrá definir procesadores que coincidan con atributos 
  como `th:text`, `th:if` o `th:whatever` (o `data-th-text`, `data-th-if` y 
  `data-th-whatever` si preferimos la sintaxis *HTML5 pura*). Sin embargo, tenga 
  en cuenta que el prefijo que devuelve un dialecto es **solo el predeterminado** 
  que se utilizará para ese dialecto, pero dicho prefijo se puede cambiar 
  durante la configuración del motor de plantillas. Tenga en cuenta también que 
  el prefijo puede ser `null` si queremos que nuestros procesadores se ejecuten 
  en etiquetas/atributos sin prefijo.

  * La *precedencia de dialecto* permite ordenar los procesadores según los 
  dialectos. Los procesadores definen su propio valor de *precedencia*, pero 
  estas precedencias se consideran *relativas a la precedencia de dialecto*, por 
  lo que cada procesador de un dialecto específico puede configurarse para 
  ejecutarse antes que todos los procesadores de un dialecto diferente 
  simplemente estableciendo los valores correctos para esta *precedencia de 
  dialecto*.

  * Los *procesadores* son, como su nombre indica, el conjunto de *procesadores* 
  proporcionados por el dialecto. Cabe destacar que al método 
  `getProcessors(...)` se le pasa el `dialectPrefix` como argumento si el 
  dialecto se ha configurado en el motor de plantillas con un prefijo diferente 
  al predeterminado. Lo más probable es que las instancias de `IProcessor` 
  necesiten esta información durante su inicialización.


### Dialectos de preprocesador: `IPreProcessorDialect`

Los **preprocesadores** y **postprocesadores** se diferencian de los 
*procesadores* en que, en lugar de ejecutarse sobre un único evento o sobre un 
modelo de evento (un fragmento de una plantilla), se aplican a todo el proceso 
de ejecución de la plantilla como un paso adicional en la cadena de procesamiento 
del motor. Por lo tanto, siguen una API completamente diferente a la de los 
procesadores, mucho más orientada a eventos, definida por la interfaz de nivel 
inferior `ITemplateHandler`.

En el caso específico de los preprocesadores, estos se aplican **antes** de que 
el motor Thymeleaf comience a ejecutar los procesadores para una plantilla 
específica.

La interfaz `IPreProcessorDialect` tiene el siguiente aspecto:

```java
public interface IPreProcessorDialect extends IDialect {

    public int getDialectPreProcessorPrecedence();
    public Set<IPreProcessor> getPreProcessors();

}
```
Lo cual es muy similar al `IProcessorDialect` mencionado anteriormente —incluida 
su propia precedencia a nivel de dialecto para los preprocesadores—, pero 
carece de un *prefijo*, ya que los preprocesadores no lo necesitan en absoluto 
(no *coinciden* con eventos específicos, sino que los gestionan todos).

### Dialectos de postprocesamiento: `IPostProcessorDialect`

Como se indicó anteriormente, los **postprocesadores** son un paso adicional en 
la cadena de ejecución de la plantilla, pero en este caso se ejecutan 
**después** de que el motor Thymeleaf haya aplicado todos los procesadores 
necesarios. Esto significa que los postprocesadores se aplican justo antes de 
que se genere la salida de la plantilla (y, por lo tanto, pueden modificar lo 
que se está generando).

La interfaz `IPostProcessorDialect` tiene el siguiente aspecto:

```java
public interface IPostProcessorDialect extends IDialect {

    public int getDialectPostProcessorPrecedence();
    public Set<IPostProcessor> getPostProcessors();

}
```

...lo cual es completamente análogo a la interfaz `IPreProcessorDialect`, pero, 
por supuesto, para postprocesadores en este caso.


### Dialectos de objetos de expresión: `IExpressionObjectDialect`

Los dialectos que implementan esta interfaz proporcionan nuevos *objetos de 
expresión* u *objetos de utilidad de expresión* que se pueden usar en expresiones 
en cualquier parte de las plantillas, como `#strings`, `#numbers`, `#dates`, 
etc., proporcionadas por el dialecto estándar.

La interfaz `IExpressionObjectDialect` tiene el siguiente aspecto:

```java
public interface IExpressionObjectDialect extends IDialect {

    public IExpressionObjectFactory getExpressionObjectFactory();

}
```
Como podemos ver, esto no devuelve los objetos de expresión en sí, sino solo una 
*fábrica*. La razón es que algunos *objetos de expresión* podrían requerir datos 
del contexto de procesamiento para su construcción, por lo que no será posible 
construirlos hasta que estemos procesando la plantilla. Además, la mayoría de 
las expresiones no necesitan *objetos de expresión*, así que es mejor 
construirlos *bajo demanda*, solo cuando sean realmente necesarios para 
expresiones específicas (y construir únicamente los que sean necesarios).

Esta es la interfaz `IExpressionObjectFactory`:

```java
public interface IExpressionObjectFactory {

    public Map<String,ExpressionObjectDefinition> getObjectDefinitions();

    public Object buildObject(final IProcessingContext processingContext, final String expressionObjectName);

}
```

### Dialectos de atributos de ejecución: `IExecutionAttributeDialect`

Los dialectos que implementan esta interfaz pueden proporcionar 
*atributos de ejecución*, es decir, objetos disponibles para cada procesador que 
se ejecuta durante el procesamiento de plantillas.

Por ejemplo, el dialecto estándar implementa esta interfaz para proporcionar a 
cada procesador:

* El analizador de expresiones estándar Thymeleaf, que permite analizar y 
  ejecutar expresiones estándar en cualquier atributo.

* El evaluador de expresiones variables, que permite ejecutar expresiones 
  `${...}` en OGNL o SpringEL (dependiendo de si se utiliza el módulo de 
  integración de Spring).

* El servicio de conversión, que realiza operaciones de conversión en 
  expresiones `${...}}`.

Tenga en cuenta que estos objetos no están disponibles en el contexto, por lo 
que no se pueden usar desde expresiones de plantilla. Su disponibilidad se 
limita a implementaciones de puntos de extensión, como procesadores, 
preprocesadores, etc.

La interfaz `IExecutionAttributeDialect` es muy sencilla:


```java
public interface IExecutionAttributeDialect extends IDialect {

    public Map<String,Object> getExecutionAttributes();

}
```




2.2. Procesadores
-----------------

Los procesadores son objetos que implementan la interfaz 
`org.thymeleaf.processor.IProcessor`, y contienen la lógica real que se aplicará 
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

Pero existen varios tipos de procesador, uno para cada tipo de evento posible:

* Inicio/fin de plantilla
* Etiquetas de elementos
* Textos
* Comentarios
* Secciones CDATA
* Cláusulas DOCTYPE
* Declaraciones XML
* Instrucciones de procesamiento

Y también para los **modelos**: secuencias de eventos que representan un 
*elemento completo*, es decir, un elemento con todo su cuerpo, incluyendo 
cualquier elemento anidado o cualquier otro tipo de artefacto que pueda aparecer 
en su interior. Si el elemento modelado es un *elemento independiente*, el 
modelo solo contendrá su evento correspondiente; pero si el elemento modelado 
tiene un cuerpo, el modelo contendrá todos los eventos, desde su *etiqueta de 
apertura* hasta su *etiqueta de cierre*, ambas incluidas.

Todos estos tipos de procesadores se crean implementando una interfaz específica 
o extendiendo una de las *implementaciones abstractas* disponibles. Todos estos 
artefactos que cumplen con la API del procesador Thymeleaf se encuentran en el 
paquete `org.thymeleaf.processor`.



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
  `IElementTagProcessor`. Estos procesadores se ejecutan únicamente en eventos 
  de etiquetas de apertura/independientes (no se pueden aplicar procesadores a 
  etiquetas de cierre) y no tienen acceso directo al cuerpo del elemento.

* **Procesadores de modelos de elementos**, que implementan la interfaz 
  `IElementModelProcessor`. Estos procesadores se ejecutan en elementos 
  completos, incluyendo sus cuerpos, en forma de objetos `IModel`.

Analizaremos cada una de estas interfaces por separado:


### Procesadores de etiquetas de elementos: `IElementTagProcessor`

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
superinterfaz `IProcessor`). La firma `process(...)` es bastante compacta y 
sigue un patrón que se encuentra en todas las interfaces de procesadores de 
Thymeleaf:

* El método `process(...)` devuelve `void`. Cualquier acción se realizará a 
  través del `structureHandler`.

* El argumento `context` contiene el contexto con el que se ejecuta la plantilla: 
  variables, datos de la plantilla, etc.

* El argumento `tag` es el evento que activa el procesador. Contiene tanto el 
  nombre del elemento como sus atributos.

* El `structureHandler` es un objeto especial que permite al procesador dar 
  instrucciones al motor sobre las acciones que debe realizar como consecuencia 
  de su ejecución.


**Usar el  `structureHandler`**

El argumento `tag` que se pasa a `process(...)` es un objeto **inmutable**. Por 
lo tanto, no hay forma de, por ejemplo, modificar directamente los atributos de 
una etiqueta en el objeto `tag`. En su lugar, se debe usar `structureHandler`.

Por ejemplo, veamos cómo leeríamos el valor de un atributo específico de `tag`, 
lo decodificaríamos y lo guardaríamos en una variable, y luego eliminaríamos el 
atributo de la etiqueta:

```java
// Obtenemos el valor del atributo
String attributeValue = tag.getAttributeValue(attributeName);

// Desescapar el valor del atributo
attributeValue = 
    EscapedAttributeUtils.unescapeAttribute(context.getTemplateMode(), attributeValue);

// Indique al controlador de estructura que elimine el atributo de la etiqueta.
structureHandler.removeAttribute(attributeName);

... // Haz algo con ese valor de atributo.
```

*Tenga en cuenta que el código anterior solo pretende mostrar algunos conceptos 
de gestión de atributos; en la mayoría de los procesadores no necesitaremos 
realizar esta operación de "obtener valor + desescapar + eliminar" manualmente, 
ya que todo será manejado por una superclase extendida como 
`AbstractAttributeTagProcessor`*.

Arriba hemos visto solo una de las *operaciones* que ofrece el `structureHandler`. 
Existe un *controlador de estructura* para cada tipo de procesador en Thymeleaf, 
y el de los procesadores de *etiquetas de elementos* implementa la interfaz 
`IElementTagStructureHandler`, que tiene este aspecto:

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
plantillas como resultado de su ejecución. Los nombres de los métodos son 
bastante autoexplicativos (y cuentan con documentación Javadoc), pero en 
resumen:

* `setLocalVariable(...)`/`removeLocalVariable(...)` añaden una variable local 
a la ejecución de la plantilla. Esta variable local será accesible durante el 
resto de la ejecución del evento actual, así como durante todo su cuerpo (es 
decir, hasta su etiqueta de cierre correspondiente).

* `setAttribute(...)` añade un nuevo atributo a la etiqueta con un valor 
específico (y posiblemente también el tipo de comillas que lo rodean). Si el 
atributo ya existe, su valor se reemplazará.

* `replaceAttribute(...)` reemplaza un atributo existente por uno nuevo, 
ocupando su lugar en el atributo (incluyendo, por ejemplo, los espacios en 
blanco que lo rodean).

* `removeAttribute(...)` elimina un atributo de la etiqueta. 
* `setSelectionTarget(...)` modifica el objeto que se considerará el 
*objetivo de selección*, es decir, el objeto sobre el que se ejecutarán las 
*expresiones de selección* (`*{...}`). En el dialecto estándar, este 
*objetivo de selección* se suele modificar mediante el atributo `th:object`, 
pero los procesadores personalizados también pueden hacerlo. Tenga en cuenta que 
el *objetivo de selección* tiene el mismo ámbito que una variable local y, por 
lo tanto, solo será accesible dentro del cuerpo del elemento que se está 
procesando.

* `setInliner(...)` modifica el *inliner* que se utilizará para procesar todos 
los nodos de texto (eventos `IText`) que aparecen en el cuerpo del elemento que 
se está procesando. Este es el mecanismo que utiliza el atributo `th:inline` 
para habilitar el *inlining* en cualquiera de los modos especificados (`text`, 
`javascript`, etc.).

* `setTemplateData(...)` modifica los metadatos de la plantilla que se está 
procesando. Al insertar fragmentos, esto permite al motor conocer datos sobre el 
fragmento específico que se está procesando, así como la pila completa de 
fragmentos que se encuentran anidados.

* `setBody(...)` reemplaza todo el cuerpo del elemento que se está procesando con 
el texto o modelo proporcionado (secuencia de eventos = fragmento de marcado). 
Así es como funcionan, por ejemplo, `th:text`/`th:utext`. Cabe destacar que el 
texto o modelo de reemplazo especificado puede configurarse como *procesable* o 
no, dependiendo de si se desea ejecutar algún procesador que pueda estar 
asociado a él. En el caso de `th:utext="${var}"`, por ejemplo, el reemplazo se 
configura como *no procesable* para evitar la ejecución de cualquier marcado que 
`${var}` pueda devolver como parte de la plantilla.

* `insertBefore(...)`/`insertImmediatelyAfter(...)` permiten especificar un 
modelo (fragmento de marcado) que debe aparecer antes o *inmediatamente* 
después de la etiqueta que se está procesando. Tenga en cuenta que 
`insertImmediatelyAfter` significa *después de la etiqueta que se está 
procesando* (y, por lo tanto, como la primera parte del cuerpo del elemento) y 
no *después de todo el elemento que se abre aquí y se cierra en una etiqueta de 
cierre en algún lugar*.

* `replaceWith(...)` permite reemplazar el *elemento* actual (elemento completo) 
con el texto o modelo especificado como argumento.

* `removeElement()`/`removeTags()`/`removeBody()`/`removeAllButFirstChild()` 
permiten al procesador eliminar, respectivamente, todo el elemento incluido su 
cuerpo, solo las etiquetas ejecutadas (apertura + cierre) pero no el cuerpo, 
solo el cuerpo pero no las etiquetas contenedoras y, por último, todos los 
elementos hijos de la etiqueta excepto el primer elemento hijo. Tenga en cuenta 
que todas estas opciones básicamente reflejan los diferentes valores que se 
pueden usar en el atributo `th:remove`.

* `iterateElement(...)` permite iterar el elemento actual (incluido el cuerpo) 
tantas veces como elementos existan en el `iteratedObject` (que generalmente 
será una `Collection`, un `Map`, un `Iterator` o un array). Los otros dos 
argumentos se usarán para especificar los nombres de las variables utilizadas 
para los elementos iterados y la variable de estado.

**Implementaciones abstractas para `IElementTagProcessor`**

Thymeleaf ofrece dos implementaciones básicas de `IElementTagProcessor` que los 
procesadores pueden implementar para mayor comodidad:

* `org.thymeleaf.processor.element.AbstractElementTagProcessor`, diseñada para 
procesadores que identifican eventos de elementos por su nombre (es decir, sin 
tener en cuenta los atributos).

* `org.thymeleaf.processor.element.AbstractAttributeTagProcessor`, diseñada para 
procesadores que identifican eventos de elementos por uno de sus atributos (y 
opcionalmente también por el nombre del elemento).


### Procesadores de modelos de elementos: `IElementModelProcessor`

Los procesadores de modelos de elementos se ejecutan sobre los elementos 
completos con los que coinciden —incluidos sus cuerpos— en forma de un objeto 
`IModel` que contiene la secuencia completa de eventos que modela dicho elemento 
y su contenido. El `IElementModelProcessor` es muy similar al que se muestra 
arriba para los *procesadores de etiquetas*:

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

**Leer y modificar el modelo**

El objeto `IModel` que se pasa como parámetro al método `process()` es un 
modelo **mutable**, por lo que permite cualquier modificación (los *modelos* son 
mutables, los *eventos* como las *etiquetas* son inmutables). Por ejemplo, 
podríamos modificarlo para reemplazar cada nodo de texto de su cuerpo con un 
comentario con el mismo contenido:

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
de nodos específicos o datos relevantes mediante el patrón *Visitor*.


**Usar el `structureHandler`**

De forma similar a los *procesadores de etiquetas*, a los procesadores de 
modelos se les pasa un objeto *manejador de estructura* que les permite indicar 
al motor que realice cualquier acción que no pueda llevarse a cabo actuando 
directamente sobre el objeto `IModel model`. La interfaz que implementan estos 
manejadores de estructura, mucho más pequeña que la de los procesadores de 
etiquetas, es `IElementModelStructureHandler`:

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

Es fácil ver que este es un subconjunto del de los procesadores de etiquetas. 
Los pocos métodos que contiene funcionan de la misma manera:

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


### Procesadores de inicio/fin de plantilla: `ITemplateBoundariesProcessor`

Los procesadores de límites de plantilla son un tipo de procesador que se 
ejecuta con los eventos *inicio de plantilla* y *fin de plantilla* que se 
activan durante el procesamiento de la plantilla. Permiten realizar cualquier 
tipo de inicialización o liberación de recursos al inicio o al final de la 
ejecoperación de procesamiento de la plantilla. Cabe destacar que estos eventos 
no se**solo se activan para la plantilla de primer nivel**, y no para cada uno 
de los fragmentos que puedan analizarse o incluirse en la plantilla que se está 
procesando.

La interfaz `ITemplateBoundariesProcessor` tiene este aspecto:

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
eventos de *inicio de la plantilla* y otro para el *fin de la plantilla*. Su 
firma sigue el mismo patrón que los demás métodos `process(...)` que vimos 
anteriormente, recibiendo el contexto, el objeto de evento y el manejador de 
estructura. El manejador de estructura, en este caso, implementa una interfaz 
`ITemplateBoundariesStructureHandler` bastante sencilla.

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

Podemos observar cómo, además de los métodos habituales para gestionar variables 
locales, selección de destino e inserción en línea, también podemos utilizar el 
manejador de estructura para insertar texto o un modelo, que en este caso 
aparecerá al principio o al final del resultado (dependiendo del evento que se 
esté procesando).

### Otros procesadores

Thymeleaf 3.0 permite declarar procesadores para otros eventos, cada uno de los 
cuales implementa su interfaz correspondiente:

* Eventos de **Texto**: interfaz `ITextProcessor`
* Eventos de **Comentario**: interfaz `ICommentProcessor`
* Eventos de **Sección CDATA**: interfaz `ICDATASectionProcessor`
* Eventos de **Cláusula DOCTYPE**: interfaz `IDocTypeProcessor`
* Eventos de **Declaración XML**: interfaz `IXMLDeclarationProcessor`
* Eventos de **Procesamiento de Instrucción**: interfaz `IProcessingInstructionProcessor`

Todos ellos se parecen bastante a este (que es el de los eventos de texto):

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
===============================

El código fuente de los ejemplos que se muestran en este y en los próximos 
capítulos de esta guía se encuentra en la aplicación de ejemplo _extraThyme_:

   * [Spring 5 extraThyme](https://github.com/thymeleaf/thymeleaf/tree/3.1-master/examples/spring5/thymeleaf-examples-spring5-extrathyme).
   * [Spring 6 extraThyme](https://github.com/thymeleaf/thymeleaf/tree/3.1-master/examples/spring6/thymeleaf-examples-spring6-extrathyme).


3.1. extraThyme: un sitio web para la liga de fútbol de Thymeland
----------------------------------------------------------

El fútbol es un deporte popular en Thymeland^[fútbol europeo, por supuesto ;-)].
Hay una liga de 10 equipos que se disputa cada temporada, y sus organizadores 
nos acaban de pedir que creemos una página web para ella llamada "extraThyme".

Este sitio web será muy sencillo: solo una tabla con:

* Los nombres de los equipos.
* El número de partidos ganados, empatados o perdidos, así como el total de 
puntos obtenidos.

* Una nota que explique si su posición en la tabla les permite clasificarse para 
competiciones de mayor nivel el próximo año o si, por el contrario, suponen su 
descenso a ligas regionales.

Sobre la tabla de clasificación, un banner mostrará titulares con los resultados 
de los partidos recientes. Además, habrá un banner bien visible que advertirá a 
los usuarios todos los domingos que son días de partido y, por lo tanto, 
deberían ir al estadio en lugar de navegar por internet.


![Tabla de la liga extraThyme](images/extendingthymeleaf/extrathyme-league-table.png)

Para nuestra aplicación, utilizaremos HTML5, Spring MVC y el dialecto 
SpringStandard. Ampliaremos Thymeleaf creando un dialecto `score` que incluye:

* Un atributo `score:remarkforposition` que muestra texto internacionalizado en 
la columna "Remarks" de la tabla. Este texto debe explicar si la posición del 
equipo en la tabla le permite clasificarse para la Liga de Campeones Mundiales, 
los Play-Offs Continentales o si desciende a la Liga Regional.
* Un atributo `score:classforposition` que establece una clase CSS para las filas 
de la tabla según los comentarios del equipo: fondo azul para la Liga de Campeones 
Mundiales, verde para los Play-Offs Continentales y rojo para el descenso.
* Una etiqueta `score:headlines` para mostrar el recuadro amarillo en la parte 
superior con los resultados de los partidos recientes. Esta etiqueta debe admitir 
un atributo `order` con los valores `random` (para mostrar un partido 
seleccionado al azar) y `latest` (por defecto, para mostrar solo el último 
partido). 
* Un atributo `score:match-day-today` que se puede agregar al encabezado de la 
tabla de la liga para agregar (condicionalmente, si es domingo) un banner que 
advierta al usuario que hoy es día de partido.

Por lo tanto, nuestro marcado se verá así, utilizando los atributos `th` y `score`:

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



3.2. Cambiar la clase CSS dependiendo de la posición del equipo
---------------------------------------------------------------

El primer procesador de atributos que desarrollaremos será 
`ClassForPositionAttributeTagProcessor`, que implementaremos como una subclase de 
una clase abstracta de conveniencia proporcionada por Thymeleaf llamada 
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
             TemplateMode.HTML, // Este procesador se aplicará solo al modo HTML
             dialectPrefix,     // Prefijo que se aplicará al nombre para la coincidencia
             null,              // Sin nombre de etiqueta: coincide con cualquier nombre de etiqueta
             false,             // No se aplicará ningún prefijo al nombre de la etiqueta
             ATTR_NAME,         // Nombre del atributo que se comparará
             true,              // Aplicar el prefijo del dialecto al nombre del atributo
             PRECEDENCE,        // Precedencia (dentro de la precedencia propia del dialecto)
             true);             // Eliminar el atributo coincidente posteriormente
    }


    @Override
    protected void doProcess(
            final ITemplateContext context, final IProcessableElementTag tag,
            final AttributeName attributeName, final String attributeValue,
            final IElementTagStructureHandler structureHandler) {

        final IEngineConfiguration configuration = context.getConfiguration();

        /*
         * Obtener el analizador de expresiones estándar de Thymeleaf
         */
        final IStandardExpressionParser parser =
                StandardExpressions.getExpressionParser(configuration);

        /*
         * Analiza el valor del atributo como una expresión estándar de Thymeleaf
         */
        final IStandardExpression expression = parser.parseExpression(context, attributeValue);

        /*
         * Ejecutar la expresión recién analizada
         */
        final Integer position = (Integer) expression.execute(context);
        
        /*
         * Obtén la observación correspondiente a esta posición en la tabla de clasificación.
         */
        final Remark remark = RemarkUtil.getRemarkForPosition(position);

        /*
         * Seleccione la clase CSS adecuada para el elemento.
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
         * Establezca el nuevo valor en el atributo 'class' (posiblemente agregándolo a un valor existente).
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
`Standard` como por el de `SpringStandard`). Esto significa que se pueden 
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

También es interesante la forma en que usamos el `structureHandler` para agregar 
un nuevo atributo a la etiqueta principal (recuerde que el objeto `tag` es 
inmutable):

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
nuestra responsabilidad**, pero en este caso conocemos todos los valores posibles 
de la variable `newValue` y no requieren escape, por lo que, en aras de la 
simplicidad, omitimos esa operación.


3.3. Mostrar un comentario internacionalizado
---------------------------------------------

El siguiente paso es crear un procesador de atributos capaz de mostrar el texto 
del comentario. Este será muy similar a `ClassForPositionAttrProcessor`, pero 
con un par de diferencias importantes:

* No asignaremos un valor a un atributo en la etiqueta principal, sino en el 
cuerpo del texto (contenido) de la etiqueta, de la misma manera que lo hace un 
atributo `th:text`.
* Necesitamos acceder al sistema de externalización (internacionalización) de 
mensajes desde nuestro código para poder mostrar el texto correspondiente a la 
configuración regional seleccionada.

Utilizaremos la misma clase base `AbstractAttributeTagProcessor`. Este será 
nuestro código:

```java
public class RemarkForPositionAttributeTagProcessor extends AbstractAttributeTagProcessor {

    private static final String ATTR_NAME = "remarkforposition";
    private static final int PRECEDENCE = 12000;


    public RemarkForPositionAttributeTagProcessor(final String dialectPrefix) {
        super(
            TemplateMode.HTML, // Este procesador se aplicará solo al modo HTML
            dialectPrefix,     // Prefijo que se aplicará al nombre para la coincidencia
            null,              // Sin nombre de etiqueta: coincide con cualquier nombre de etiqueta
            false,             // No se aplicará ningún prefijo al nombre de la etiqueta
            ATTR_NAME,         // Nombre del atributo que se comparará
            true,              // Aplicar el prefijo del dialecto al nombre del atributo
            PRECEDENCE,        // Precedencia (dentro de la precedencia del dialecto)
            true);             // Eliminar el atributo coincidente posteriormente

    }


    @Override
    protected void doProcess(
            final ITemplateContext context, final IProcessableElementTag tag,
            final AttributeName attributeName, final String attributeValue,
            final IElementTagStructureHandler structureHandler) {

        final IEngineConfiguration configuration = context.getConfiguration();

        /*
         * Obtenga el analizador de expresiones estándar de Thymeleaf.
         */
        final IStandardExpressionParser parser =
                StandardExpressions.getExpressionParser(configuration);

        /*
         * Analiza el valor del atributo como una expresión estándar de Thymeleaf.
         */
        final IStandardExpression expression =
                parser.parseExpression(context, attributeValue);

        /*
         * Ejecuta la expresión que acabas de analizar.
         */
        final Integer position = (Integer) expression.execute(context);

        /*
         * Obtenga la observación correspondiente a esta posición en la tabla de 
         * clasificación.
         */
        final Remark remark = RemarkUtil.getRemarkForPosition(position);
        
        /*
         * Si no se va a aplicar ningún comentario, simplemente asigne un cuerpo 
         * vacío a esta etiqueta.
         */
        if (remark == null) {
            structureHandler.setBody("", false); // false == 'non-processable'
            return;
        }

        /*
         * El mensaje debe estar internacionalizado, por lo que solicitamos al 
         * motor que resuelva el mensaje 'remarks.{REMARK}' (por ejemplo, 
         * 'remarks.RELEGATION'). No se necesitan parámetros para este mensaje.
         *
         * Además, especificaremos que se utilice la "representación ausente" 
         * para que, si esta entrada de mensaje no existe en nuestros paquetes 
         * de recursos, se muestre una etiqueta de mensaje ausente.
         */
        final String i18nMessage =
                context.getMessage(
                        RemarkForPositionAttributeTagProcessor.class, 
                        "remarks." + remark.toString(), 
                        new Object[0], 
                        true);

        /*
         * Establece el mensaje calculado como el cuerpo de la etiqueta, con 
         * caracteres de escape HTML y no procesable (de ahí el argumento 'false').
         */
        structureHandler.setBody(HtmlEscape.escapeHtml5(i18nMessage), false);
        
    }

}
```

### Acceso a los mensajes i18n

Tenga en cuenta que estamos accediendo al sistema de externalización de mensajes 
con:

```java
final String i18nMessage =
        context.getMessage(
                RemarkForPositionAttributeTagProcessor.class, 
                "remarks." + remark.toString(), 
                new Object[0], 
                true);
```

Esto invocará el mecanismo de resolución de mensajes configurado en el motor, 
pasando no solo la clave específica que nos interesa y sus parámetros (ninguno 
en este caso), sino también dos datos adicionales:

* El *origen* que se asignará al mensaje: `RemarkForPositionAttributeTagProcessor.class`
* Si se debe usar una *representación de mensaje ausente* (`true`)

La resolución de mensajes es un **punto de extensión** en Thymeleaf (interfaz 
`IMessageResolver`), por lo que el tratamiento de estos parámetros depende de la 
implementación específica que se utilice.

La implementación predeterminada en aplicaciones que no utilizan Spring 
(`StandardMessageResolver`) hará lo siguiente:

* Primero, busca archivos `.properties` con el mismo nombre que el archivo de 
plantilla más la configuración regional. Por ejemplo, si la plantilla es 
`/views/main.html` y la configuración regional es `gl_ES`, buscará 
`/views/main_gl_ES.properties`, luego `/views/main_gl.properties` y, finalmente, 
`/views/main.properties`.

* Si no se encuentra, utiliza la clase *origin* (que podría haberse especificado 
como `null`) y busca archivos `.properties` en el classpath con el nombre de la 
clase especificada allí (la clase propia del procesador): 
`classpath:org/thymeleaf/examples/spring6/extrathyme/dialects/score/RemarkForPositionAttributeTagProcessor_gl_ES.properties`,
etc. Esto permite la *componentización* de procesadores y dialectos con su 
conjunto completo de paquetes de recursos i18n en simples archivos `.jar`. Si no 
se encuentra ninguno de estos, compruebe el indicador de *representación de 
mensaje ausente*. Si es `false`, simplemente devuelva `null`. Si es `true`, 
genere un texto que permita al desarrollador o usuario identificar rápidamente 
la falta de un recurso i18n: `??remarks.rel_gl_ES??`.

_(Tenga en cuenta que, en aplicaciones con Spring, este mecanismo de resolución 
de mensajes se reemplazará por defecto con el de Spring, basado en los beans 
`MessageSource` declarados en el contexto de la aplicación Spring)._


### Contenido escapado del HTML

Además, en este procesador realizamos el escape HTML necesario del contenido que 
estamos configurando mediante la clase `HtmlEscape` de la biblioteca 
[Unbescape](http://unbescape.org), que se utiliza para este propósito en todo 
Thymeleaf:

```java
structureHandler.setBody(HtmlEscape.escapeHtml5(i18nMessage), false);
```


3.4. Un procesador de elementos para nuestros titulares
-------------------------------------------------------

El tercer procesador que escribiremos es un procesador de elementos (etiquetas). 
Cabe destacar que lo denominamos *procesador de etiquetas de elementos*, a 
diferencia de los dos procesadores anteriores, que eran *procesadores de 
etiquetas de atributos*. Esto se debe a que, en este caso, queremos que nuestro 
procesador coincida (es decir, que se seleccione para su ejecución) en función 
del **nombre de la etiqueta**, y no del nombre de uno de sus atributos.

Este tipo de procesador de etiquetas tiene una ventaja y una desventaja con 
respecto a los procesadores de etiquetas de atributos:

* Ventaja: los elementos pueden contener múltiples atributos, por lo que los 
procesadores de elementos pueden recibir un conjunto de parámetros de 
configuración más completo y complejo.
* Desventaja: los navegadores no reconocen los elementos/etiquetas personalizados, 
por lo que si desarrolla una aplicación web con etiquetas personalizadas, es 
posible que tenga que sacrificar una de las características más interesantes de 
Thymeleaf: la capacidad de mostrar plantillas estáticamente como prototipos 
(_plantillas naturales_).

Este procesador extenderá `AbstractElementTagProcessor`, la clase base que se 
utilizará para los procesadores de etiquetas que no coincidan con un atributo 
específico:

```java
public class HeadlinesElementTagProcessor extends AbstractElementTagProcessor {

    private static final String TAG_NAME = "headlines";
    private static final int PRECEDENCE = 1000;


    private final Random rand = new Random(System.currentTimeMillis());


    public HeadlinesElementTagProcessor(final String dialectPrefix) {
        super(
            TemplateMode.HTML, // Este procesador se aplicará solo al modo HTML
            dialectPrefix,     // Prefijo que se aplicará al nombre para la coincidencia
            TAG_NAME,          // Nombre de la etiqueta: coincidir específicamente con esta etiqueta
            true,              // Aplicar el prefijo del dialecto al nombre de la etiqueta
            null,              // Sin nombre de atributo: coincidirá por nombre de etiqueta
            false,             // No se aplicará ningún prefijo al nombre del atributo
            PRECEDENCE);       // Precedencia (dentro de la precedencia propia del dialecto)    
    }


    @Override
    protected void doProcess(
            final ITemplateContext context, final IProcessableElementTag tag,
            final IElementTagStructureHandler structureHandler) {

        /*
         * Obtenga el contexto de la aplicación Spring.
         */
        final ApplicationContext appCtx = SpringContextUtils.getApplicationContext(context);

        /*
         * Obtiene el bean HeadlineRepository del contexto de la aplicación y le solicita
         * la lista actual de titulares.
         */
        final HeadlineRepository headlineRepository = appCtx.getBean(HeadlineRepository.class);
        final List<Headline> headlines = headlineRepository.findAllHeadlines();

        /*
         * Lee el atributo 'order' de la etiqueta. Este atributo opcional en nuestra etiqueta
         * nos permitirá determinar si queremos mostrar un titular aleatorio o
         * solo el más reciente ('latest' es el valor predeterminado).
         */
        final String order = tag.getAttributeValue("order");

        String headlineText = null;
        if (order != null && order.trim().toLowerCase().equals("random")) {
            // El orden es aleatorio 

            final int r = this.rand.nextInt(headlines.size());
            headlineText = headlines.get(r).getText();
            
        } else {
            // El orden es "último", solo se mostrará el titular más reciente.
            
            Collections.sort(headlines);
            headlineText = headlines.get(headlines.size() - 1).getText();
            
        }

        /*
         * Crea la estructura DOM que sustituirá nuestra etiqueta personalizada.
         * El título se mostrará dentro de una etiqueta '<div>', por lo que esta debe
         * crearse primero y luego se debe agregar un nodo de texto.
         */
        final IModelFactory modelFactory = context.getModelFactory();

        final IModel model = modelFactory.createModel();

        model.add(modelFactory.createOpenElementTag("div", "class", "headlines"));
        model.add(modelFactory.createText(HtmlEscape.escapeHtml5(headlineText)));
        model.add(modelFactory.createCloseElementTag("div"));

        /*
         * Indique al motor que reemplace este elemento completo con el modelo 
         * especificado.
         */
        structureHandler.replaceWith(model, false);
        
    }

}
```

La primera parte interesante del código anterior muestra cómo acceder al 
`Contexto de aplicación` de Spring para obtener uno de nuestros beans (el 
`Repositorio de encabezados`):

```java
final ApplicationContext appCtx = SpringContextUtils.getApplicationContext(context);
```

Además, este procesador es diferente a los anteriores en que necesitaremos 
*crear marcado* como resultado de su ejecución: vamos a reemplazar la etiqueta 
original `<score:headlines .../>` con un fragmento `<div>...</div>`, por lo que 
necesitaremos hacer uso de la **fábrica de modelos**.


### El modelo factoría

La fábrica de modelos es un objeto especial disponible para los procesadores (y 
otras estructuras como preprocesadores, postprocesadores, etc.) que puede crear 
nuevas instancias de *eventos* como *modelos* (fragmentos de plantillas), y 
también nuevas instancias de *modelos* propiamente dichos.

Por lo tanto, es la herramienta para crear nuevo marcado, como podemos ver en el 
código anterior:

```java
final IModelFactory modelFactory = context.getModelFactory();

final IModel model = modelFactory.createModel();

model.add(modelFactory.createOpenElementTag("div", "class", "headlines"));
model.add(modelFactory.createText(HtmlEscape.escapeHtml5(headlineText)));
model.add(modelFactory.createCloseElementTag("div"));
```

Observe cómo los eventos de marcado deben crearse *uno a la vez*, y cómo las 
etiquetas de apertura y cierre para el mismo elemento `div` deben crearse por 
separado y en el orden correcto. Esto se debe a que los modelos son 
*secuencias de eventos* y no nodos en un Modelo de Objetos del Documento (DOM).

La fábrica de modelos ofrece un conjunto bastante completo de métodos para crear 
eventos de todo tipo de eventos: etiquetas, textos, DOCTYPEs, etc., y también 
métodos útiles para modificar los atributos de una etiqueta (creando una nueva 
instancia de `tag`, dado que son inmutables), como por ejemplo:

```java
final IOpenElemenTag newTag = modelFactory.setAttribute(tag, "class", "newvalue");
```

Además, la fábrica de modelos puede crear instancias de `IModel` desde cero (como 
en el ejemplo anterior de `modelFactory.createModel()`), a partir de un único 
evento existente, y también a partir de un fragmento de marcado que queremos 
convertir en su secuencia de eventos correspondiente mediante su análisis 
sintáctico:


```java
final IModel model = 
        modelFactory.parse(
                context.getTemplateData(), 
                "<div class='headlines'>Algunos titulares</div>");
```




3.5. Un modelo de procesador para nuestro pancarta "Día de partido hoy".
----------------------------------------------------------------------

El último procesador que incluiremos en nuestro dialecto es de naturaleza 
diferente a los que hemos visto hasta ahora: es un **procesador de modelos**, 
no un *procesador de etiquetas*.

Como ya se mencionó en una sección anterior, los procesadores de modelos no se 
ejecutan en un evento de etiqueta específico, sino en la secuencia completa de 
eventos (es decir, el *modelo*) que contiene el elemento completo que están 
comparando.

Así pues, si tenemos un procesador de modelos que compara etiquetas `<p>` con el 
atributo `score:matcher` y un fragmento de plantilla como este:

```html
<p score:matcher="whatever">
    Este es un cuerpo
</p>
```

Ese *procesador de modelos* recibirá como argumento de su método `doProcess()` 
un `IModel` que contiene 3 eventos: `<p score:matcher="whatever">` (etiqueta de 
apertura), `\n This is some body\n` (texto) y `</p>` (etiqueta de cierre).


Volviendo a nuestros requisitos: queríamos un procesador de modelos que 
coincidiera con un `score:match-day-today`, que pudiéramos aplicar al encabezado 
de la tabla de la liga y hacer que mostrara, debajo de este encabezado, un banner 
advirtiendo al usuario que los domingos son días de partido:

```html
<h2 score:match-day-today th:text="#{title.leaguetable(${execInfo.now.time})}">
    Clasificación de la liga al 7 de julio de 2011
</h2>
```

Tenga en cuenta que no necesitamos un valor para este atributo 
`score:match-day-today`, por lo que podemos simplemente ignorarlo. Nuestro código 
se verá así:


```java
public class MatchDayTodayModelProcessor extends AbstractAttributeModelProcessor {

    private static final String ATTR_NAME = "match-day-today";
    private static final int PRECEDENCE = 100;


    public MatchDayTodayModelProcessor(final String dialectPrefix) {
        super(
            TemplateMode.HTML, // Este procesador se aplicará solo al modo HTML
            dialectPrefix,     // Prefijo que se aplicará al nombre para la coincidencia
            null,              // Sin nombre de etiqueta: coincide con cualquier nombre de etiqueta
            false,             // No se aplicará ningún prefijo al nombre de la etiqueta
            ATTR_NAME,         // Nombre del atributo que se comparará
            true,              // Aplicar el prefijo del dialecto al nombre del atributo
            PRECEDENCE,        // Precedencia (dentro de la precedencia propia del dialecto)
            true);             // Eliminar el atributo coincidente posteriormente
    }


    protected void doProcess(
            final ITemplateContext context, final IModel model,
            final AttributeName attributeName, final String attributeValue,
            final IElementModelStructureHandler structureHandler) {


        if (!checkPositionInMarkup(context)) {
            throw new TemplateProcessingException(
                    "El atributo " + ATTR_NAME + " solo se puede usar dentro de un " +
                            "elemento de marcado con la clase \"leaguetable\"");
        }

        final Calendar now = Calendar.getInstance(context.getLocale());
        final int dayOfWeek = now.get(Calendar.DAY_OF_WEEK);

        // ¡Los domingos son días de partido!
        if (dayOfWeek == Calendar.SUNDAY) {

            // La Fábrica de Modelos nos permitirá crear nuevos eventos.
            final IModelFactory modelFactory = context.getModelFactory();

            // Agregaremos el banner "Hoy es día de partido" justo después
            // del elemento que estamos procesando:
            //
            // <h4 class="matchday">¡Hoy es DÍA DE PARTIDO!</h4>
            //
            model.add(modelFactory.createOpenElementTag("h4", "class", "matchday")); //
            model.add(modelFactory.createText("¡Hoy es DÍA DE PARTIDO!"));
            model.add(modelFactory.createCloseElementTag("h4"));

        }

    }


    private static boolean checkPositionInMarkup(final ITemplateContext context) {

        /*
         * Queremos asegurarnos de que este procesador se aplique dentro de una 
         * etiqueta contenedora con la clase "leaguetable". Por lo tanto, debemos 
         * verificar la penúltima entrada en la pila de elementos (La última 
         * entrada es la etiqueta que se está procesando).
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

Lo primero que cabe destacar es que estamos comprobando la posición en la que se 
utiliza el atributo: solo lo permitiremos dentro de un contenedor con 
`class="leaguetable"`. Por lo tanto, nuestro método `checkPositionInMarkup(...)` 
utiliza la *pila de elementos* para conocer la lista de etiquetas que se deben 
procesar para procesar la actual.

Además, con respecto a cómo se crea el nuevo elemento banner (un `<h4>`), observe 
cómo modificamos el atributo `model` que se pasa como argumento a 
`doProcess(...)`. No se crea ningún objeto de modelo nuevo.

```java
final IModelFactory modelFactory = context.getModelFactory();

model.add(modelFactory.createOpenElementTag("h4", "class", "matchday")); //
model.add(modelFactory.createText("¡Hoy es DÍA DE PARTIDO!"));
model.add(modelFactory.createCloseElementTag("h4"));
```



3.6. Declarándolo todo: el dialecto
----------------------------------

El último paso para completar nuestro dialecto es, por supuesto, la propia clase 
del dialecto.

Como vimos en una sección anterior, los dialectos pueden implementar diferentes 
interfaces según lo que proporcionen al motor de plantillas. En este caso, 
nuestro dialecto solo proporciona procesadores, por lo que implementará 
`IProcessorDialect`.

De hecho, extenderemos una implementación abstracta de conveniencia que 
facilitará la implementación de la interfaz: `AbstractProcessorDialect`.


```java
public class ScoreDialect extends AbstractProcessorDialect {

    private static final String DIALECT_NAME = "Score Dialect";


    public ScoreDialect() {
        // Asignaremos a este dialecto la misma precedencia de "procesador de dialecto" que
        // al dialecto estándar, para que las ejecuciones del procesador puedan intercalarse.
        super(DIALECT_NAME, "score", StandardDialect.PROCESSOR_PRECEDENCE);
    }

    /*
     * Se declaran dos procesadores de atributos: 'classforposition' y
     * 'remarkforposition'. También un procesador de elementos: la etiqueta 'headlines'.
     */
    public Set<IProcessor> getProcessors(final String dialectPrefix) {
        final Set<IProcessor> processors = new HashSet<IProcessor>();
        processors.add(new ClassForPositionAttributeTagProcessor(dialectPrefix));
        processors.add(new RemarkForPositionAttributeTagProcessor(dialectPrefix));
        processors.add(new HeadlinesElementTagProcessor(dialectPrefix));
        processors.add(new MatchDayTodayModelProcessor(dialectPrefix));
        // Esto eliminará los atributos xmlns:score que podríamos agregar para la validación del IDE.
        processors.add(new StandardXmlNsTagProcessor(TemplateMode.HTML, dialectPrefix));
        return processors;
    }


}
```

Una vez creado nuestro dialecto, necesitaremos agregarlo a nuestro objeto Template 
Engine para poder usarlo. Dado que se trata de una aplicación habilitada para 
Spring, modificaremos el bean del motor de plantillas declarado:

```java
@Bean
public SpringTemplateEngine templateEngine(){
    SpringTemplateEngine templateEngine = new SpringTemplateEngine();
    templateEngine.setTemplateResolver(templateResolver());
    templateEngine.addDialect(new ScoreDialect());
    return templateEngine;
}
```

Ten en cuenta que la llamada `addDialect(...)` añadirá el dialecto Score al que 
ya está configurado por defecto en `SpringTemplateEngine`: el dialecto 
SpringStandard.

¡Y listo! Nuestro dialecto ya está listo para ejecutarse y nuestra tabla de 
clasificación se mostrará exactamente como queríamos.
