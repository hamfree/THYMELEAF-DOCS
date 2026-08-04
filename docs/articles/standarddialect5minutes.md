---
title: Primeros pasos con los dialectos estándar en 5 minutos
---


Esta guía te llevará a través de algunos de los conceptos más importantes que
necesitas conocer para entender una plantilla de Thymeleaf escrita en los
dialectos *Standard* o *SpringStandard*. No es un sustituto de los
tutoriales -- que son mucho más completos -- pero te enseñará
lo suficiente para familiarizarte con la tecnología.


¿Dialectos estándar?
------------------

Thymeleaf es muy, muy extensible, y te permite definir tus propios
conjuntos de atributos de plantilla (o incluso etiquetas) con los nombres que desees,
evaluando las expresiones que quieras en la sintaxis que prefieras y aplicando
la lógica que necesites. Es más bien un *framework de motor de plantillas*.

Sin embargo, de manera predeterminada, viene con algo llamado *los dialectos
estándar* (llamados *Standard* y *SpringStandard*) que definen un conjunto de
características que deberían ser más que suficientes para la mayoría de los
escenarios. Puedes identificar cuándo se están utilizando estos dialectos estándar
en una plantilla porque contendrá atributos que comienzan con el prefijo `th`,
como `<span th:text="...">`.

Ten en cuenta que los dialectos *Standard* y *SpringStandard* son casi
idénticos, excepto que *SpringStandard* incluye características específicas para
la integración con aplicaciones Spring MVC (como, por ejemplo, el uso de
*Spring Expression Language* para la evaluación de expresiones en lugar de
*OGNL*).

También ten en cuenta que normalmente nos referimos a las características de los 
dialectos estándar cuando hablamos de Thymeleaf sin ser más específicos.


Sintaxis de expresiones estándar
--------------------------

La mayoría de los atributos de Thymeleaf permiten que sus valores se establezcan
como *expresiones* o que las contengan, a las que llamaremos *Expresiones Estándar*
debido a los dialectos en los que se utilizan. Estas pueden ser de cinco tipos:

  - `${...}` : Expresiones de variable.
  - `*{...}` : Expresiones de selección.
  - `#{...}` : Expresiones de mensajes (i18n).
  - `@{...}` : Expresiones de enlace (URL).
  - `~{...}` : Expresiones de fragmentos.

### Expresiones de variables


Las expresiones de variable son expresiones OGNL —o Spring EL si estás integrando
Thymeleaf con Spring— ejecutadas sobre las *variables de contexto* —también llamadas
*atributos de modelo* en la jerga de Spring—. Se ven así:

```html
${session.user.name}
```

Y los encontrarás como valores de atributo o como parte de ellos, dependiendo 
del atributo:

```html
<span th:text="${book.author.name}">
```

La expresión anterior es equivalente (tanto en OGNL como en SpringEL) a:
```java
((Book)context.getVariable("book")).getAuthor().getName()
```

Pero podemos encontrar expresiones variables en escenarios que no solo involucran
*salida*, sino un procesamiento más complejo como *condicionales*, *iteración*...

```html
<li th:each="book : ${books}">
```

Aquí, `${books}` selecciona la variable llamada `books` del contexto y la
evalúa como un *iterable* para ser utilizada en un bucle `th:each`.


### Expresiones de selección

Las expresiones de selección son exactamente como las expresiones de variable, 
excepto que se ejecutarán sobre un objeto seleccionado previamente en lugar de 
sobre todo el mapa de variables de contexto. Tienen este aspecto:

```html
*{customer.name}
```

El objeto sobre el que actúan se especifica mediante un atributo `th:object`:

```html
<div th:object="${book}">
  ...
  <span th:text="*{title}">...</span>
  ...
</div>
```

Así que eso sería equivalente a:
```java
{
  // th:object="${book}"
  final Book selection = (Book) context.getVariable("book");
  // th:text="*{title}"
  output(selection.getTitle());
}
```

### Expresiones de mensajes (i18n)

Las expresiones de mensajes (a menudo llamadas *externalización de textos*,
*internacionalización* o *i18n*) nos permiten recuperar mensajes
específicos de una configuración regional (*locale*) a partir de fuentes
externas (archivos `.properties`), referenciándolos mediante una clave y
(opcionalmente) aplicando un conjunto de parámetros.


En aplicaciones Spring, esto se integrará automáticamente con el mecanismo 
`MessageSource` de Spring.

```html
#{main.title}
```

```html
#{message.entrycreated(${entryId})}
```

Puedes encontrarlos en plantillas como esta:

```html
<table>
  ...
  <th th:text="#{header.address.city}">...</th>
  <th th:text="#{header.address.country}">...</th>
  ...
</table>
```

Tenga en cuenta que puede usar *expresiones de variables* dentro de 
*expresiones de mensajes* si desea que la clave del mensaje esté determinada por 
el valor de una variable de contexto, o si desea especificar variables como 
parámetros:

```html
#{${config.adminWelcomeKey}(${session.user.name})}
```

### Expresiones de enlace (URL)

Las expresiones de enlace están diseñadas para construir URL y agregarles 
contexto útil e información de sesión (un proceso que generalmente se denomina 
*reescritura de URL*).

Por lo tanto, para una aplicación web desplegada en el contexto `/myapp` de su 
servidor web, una expresión como esta:

```html
<a th:href="@{/order/list}">...</a>
```

Podría convertirse en algo como esto:

```html
<a href="/myapp/order/list">...</a>
```

O incluso esto, si necesitamos mantener las sesiones y las cookies no están 
habilitadas (o el servidor aún no lo sabe):

```html
<a href="/myapp/order/list;jsessionid=23fa31abd41ea093">...</a>
```


Las URL también pueden aceptar parámetros:

```html
<a th:href="@{/order/details(id=${orderId},type=${orderType})}">...</a>
```

El resultado es algo como esto:

```html
<!-- Tenga en cuenta que los signos de ampersand (&) deben codificarse en HTML 
     en los atributos de las etiquetas... -->
<a href="/myapp/order/details?id=23&amp;type=online">...</a>
```


Las expresiones de enlace pueden ser relativas, en cuyo caso no se antepondrá 
ningún contexto de aplicación a la URL:

```html
<a th:href="@{../documents/report}">...</a>
```

También relativo al servidor (de nuevo, no es necesario anteponer ningún 
contexto de aplicación):

```html
<a th:href="@{~/contents/main}">...</a>
```
Y relativo al protocolo (igual que las URL absolutas, pero el navegador 
utilizará el mismo protocolo HTTP o HTTPS que se usa en la página que se 
muestra):

```html
<a th:href="@{//static.mycompany.com/res/initial}">...</a>
```

Y, por supuesto, las expresiones de enlace pueden ser absolutas:

```html
<a th:href="@{http://www.mycompany.com/main}">...</a>
```

Pero un momento, en una URL absoluta (o relativa al protocolo)... ¿qué valor 
aporta la expresión de enlace de Thymeleaf? Fácil: la posibilidad de reescribir 
la URL definida por los *filtros de respuesta*. En una aplicación web basada en 
servlets, para cada URL que se genera (relativa al contexto, relativa, 
absoluta...), Thymeleaf siempre llamará al mecanismo 
`HttpServletResponse.encodeUrl(...)` antes de mostrar la URL. Esto significa que 
un filtro puede realizar una reescritura de URL personalizada para la aplicación 
envolviendo el objeto `HttpServletResponse` (un mecanismo de uso común).



### Expresiones de fragmentos

Las expresiones de fragmento son una forma sencilla de representar fragmentos de 
marcado y moverlos entre plantillas. Gracias a estas expresiones, los fragmentos 
se pueden replicar, pasar a otras plantillas como argumentos, etc.

El uso más común es para la inserción de fragmentos mediante `th:insert` o `th:replace`:

```html
<div th:insert="~{commons :: main}">...</div>
```

Pero se pueden usar en cualquier lugar, como cualquier otra variable:

```html
<div th:with="frag=~{footer :: #main/text()}">
  <p th:insert="${frag}">
</div>
```

Las expresiones de fragmento pueden tener argumentos:

```html
<div th:insert="~{commons :: #main(${title},${content})}">...</div>
```

These arguments are then available inside the referenced fragment as
context variables:

```html
<div th:fragment="main(title,content)">
  <h1 th:text="${title}">A title</h1>
  <p th:text="${content}">Some content</p>
</div>
```


### Literales y operaciones

Existe una buena variedad de tipos de literales y operaciones disponibles:

-   Literales:
    -   Literales de texto: `'one text'`, `'Another one!'`,...
    -   Literales numéricos: `0`, `34`, `3.0`, `12.3`,...
    -   Literales booleanos: `true`, `false`
    -   Literal Null: `null`
    -   Literales de tokens: `one`, `sometext`, `main`,...

-   Operaciones de texto:
    -   Concatenación de cadenas: `+`
    -   Substitución de literales: `|The name is ${name}|`

-   Operaciones aritméticas:
    -   Operadores binarios: `+`, `-`, `*`, `/`, `%`
    -   Signo menos (operador unario): `-`

-   Operaciones booleanas:
    -   Operadores binarios: `and`, `or`
    -   Negación booleana  (operador unario): `!`, `not`

-   Comparaciones e igualdad:
    -   Comparadores: `>`, `<`, `>=`, `<=` (`gt`, `lt`, `ge`, `le`)
    -   Operadores de igualdad: `==`, `!=` (`eq`, `ne`)

-   Operadores condicionales:
    -   Si-entonces: `(if) ? (then)`
    -   Si-entonces-si no: `(if) ? (then) : (else)`
    -   Defecto: `(value) ?: (defaultvalue)`

### Preprocesamiento de expresiones

Una última cosa que debes saber sobre las expresiones es que existe algo llamado 
*preprocesamiento de expresiones*, que se especifica entre `__` y tiene este 
aspecto:

```html
#{selection.__${sel.code}__}
```

Lo que vemos ahí es una expresión variable (`${sel.code}`) que se ejecutará 
primero y cuyo resultado —digamos, "`ALL`"— se utilizará como parte de la 
expresión real que se ejecutará después, en este caso una expresión de 
internacionalización (que buscaría el mensaje con la clave 
`selection.ALL`).


Algunos atributos básicos
---------------------

Veamos algunos de los atributos más básicos del
Dialecto Estándar. Empecemos con `th:text`, que simplemente reemplaza el cuerpo 
de una etiqueta (nótese de nuevo la capacidad de prototipado):

```html
<p th:text="#{msg.welcome}">Welcome everyone!</p>
```

Ahora bien, `th:each`, que repite el elemento en el que se encuentra tantas veces 
como especifique el array o la lista devuelta por su expresión, crea también una 
variable interna para el elemento de iteración con una sintaxis equivalente a la 
de una expresión *foreach* de Java::

```html
<li th:each="book : ${books}" th:text="${book.title}">En las Orillas del Sar</li>
```

Por último, Thymeleaf incluye muchos atributos `th` para atributos específicos de 
XHTML y HTML5 que simplemente evalúan sus expresiones y establecen el valor de 
estos atributos al resultado. Sus nombres imitan los de los atributos cuyos 
valores establecen:

```html
<form th:action="@{/createOrder}">
```

```html
<input type="button" th:value="#{form.submit}" />
```

```html
<a th:href="@{/admin/users}">
```


¿Quieres saber más?
------------------

¡Entonces el tutorial [*"Uso de Thymeleaf"*](/docs/documentation.html) es lo que 
estás buscando!
