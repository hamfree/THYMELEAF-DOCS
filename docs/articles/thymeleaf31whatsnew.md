---
title: "Thymeleaf 3.1: Novedades y cómo migrar"
---

La última versión es Thymeleaf `3.1.5.RELEASE`.

## Qué hay de nuevo

### Compatibilidad con la API 5.0 de Servlet y el espacio de nombres de clases `jakarta.*`.

Thymeleaf 3.1 añade compatibilidad con el nuevo espacio de nombres de clases `jakarta.*` en la API de Servlets desde la versión 5.0, sin eliminar la compatibilidad con las clases `javax.*` de versiones anteriores.

### Compatibilidad con Spring 6.0

Thymeleaf 3.1 incorpora una nueva biblioteca principal, `thymeleaf-spring6`, para la integración con Spring Framework 6.0.

Se ha eliminado la compatibilidad con versiones de Spring anteriores a la 5.0.

### Compatibilidad con Spring Security 6.0

Thymeleaf 3.1 incorpora una nueva biblioteca principal, `thymeleaf-extras-springsecurity6`, para la integración con Spring Security 6.0.

Se ha eliminado la compatibilidad con versiones de Spring Security anteriores a la 5.0.

### Soporte principal para el paquete `java.time`

El módulo de extras `thymeleaf-extras-java8time` se ha integrado en el núcleo de Thymeleaf: el objeto de utilidad de expresiones `#temporals` ahora está siempre disponible.

### Compatibilidad con Java

Actualmente, JDK 8 es la versión mínima generalmente requerida.

JDK 17 es la versión mínima requerida para las bibliotecas principales `thymeleaf-spring6` y `thymeleaf-extras-springsecurity6`.

### Eliminación de objetos de utilidad de expresión basados en la API web

Las expresiones `#request`, `#response`, `#session` y `#servletContext` ya no están disponibles en Thymeleaf 3.1.

### Restricciones más estrictas sobre el uso de clases en expresiones

Thymeleaf 3.1 establece una restricción general en el uso de clases de paquetes principales: `java.*`, `javax.*`, `jakarta.*`, `jdk.*`, `org.ietf.jgss.*`, `org.omg.*`, `org.w3c.dom.*`, `org.xml.sax.*`, `com.sun.*` y `sun.*`.

Ahora está prohibido llamar a métodos o constructores para las clases de estos paquetes, así como realizar referencias estáticas.

Como excepción a esta restricción, algunas clases de estos paquetes siempre están _permitidas_:

* Clases básicas de `java.lang.*` y `java.math.*`: `java.lang.Boolean`, `java.lang.Byte`, `java.lang.Character`, `java.lang.Double`, `java.lang.Enum`, `java.lang.Float`, `java.lang.Integer`, `java.lang.Long`, `java.lang.Math`, `java.lang.Number`, `java.lang.Short`, `java.lang.String`, `java.math.BigDecimal`, `java.math.BigInteger`, `java.math.RoundingMode`.
* Clases e interfaces de colección: `java.util.Collection`, `java.util.Enumeration`, `java.util.Iterable`, `java.util.Iterator`, `java.util.List`, `java.util.ArrayList`, `java.util.LinkedList`, `java.util.Set`, `java.util.HashSet`, `java.util.LinkedHashSet`, `java.util.Map`, `java.util.Map.Entry`, `java.util.HashMap`, `java.util.LinkedHashMap`. Nota: Los métodos de interfaz (p. ej., `Map#get(key)`) suelen estar permitidos para cualquier implementación, pero las implementaciones específicas que se enumeran aquí también pueden construirse y referenciarse estáticamente.
* Otras clases de uso común en `java.util.*`: `java.util.Properties`, `java.util.Optional`, `java.util.stream.Stream`, `java.util.Locale`, `java.util.Date`, `java.util.Calendar`.

### Desuso de algunos artefactos y eliminación de los que ya habían sido descontinuados

Algunas funcionalidades se han declarado obsoletas en Thymeleaf 3.1.

* Se ha declarado obsoleto `th:include` en favor de `th:insert`. Tenga en cuenta que `th:insert` tiene una semántica ligeramente diferente a la de `th:include`.
* Se ha declarado obsoleta la sintaxis sin envolver para la inserción de fragmentos: ahora siempre se debe usar `~{template :: fragment}` en lugar de simplemente `template :: fragment`.

Además, se han eliminado las funcionalidades que se habían declarado obsoletas en la versión 3.0:

* Se ha eliminado `th:substituteby`, que se había declarado obsoleta en favor de `th:replace`.
* Se ha eliminado el uso obsoleto de `execInfo` como variable de contexto (`${execInfo}`), disponible desde la versión 3.0 como objeto de utilidad de expresión (`${#execInfo}`).

### Otras mejoras menores

* Actualización general de las versiones de las dependencias.
* Permite que el objeto de utilidad de expresiones `#temporals` formatee los mensajes temporales en configuraciones regionales distintas a la predeterminada.
* Admite la iteración (por ejemplo, `th:each`) directamente en flujos de Java (`java.util.stream.Stream`).
* Permite que las instancias de `SpringTemplateEngine` se configuren con un resolvedor de mensajes personalizado (incluso que no sea de Spring).

### (Para desarrolladores) Revisión completa de la estructura del repositorio de código fuente del proyecto.

Thymeleaf 3.1 incluye una revisión completa de los repositorios de código fuente (anteriormente múltiples) y mejoras significativas en la gestión de las aplicaciones de ejemplo desde la perspectiva del desarrollo:

* Integración de la mayoría de los repositorios de código de Thymeleaf anteriores en el repositorio de GitHub `thymeleaf` (https://github.com/thymeleaf/thymeleaf), que ahora contiene:
  * El nuevo BOM de Thymeleaf (`thymeleaf-parent`), que integra y unifica todas las dependencias y la configuración de compilación de Thymeleaf.
  * Todas las bibliotecas principales de Thymeleaf, incluidas las integraciones con Spring y Spring Security.
  * Todas las bibliotecas de prueba de Thymeleaf y sus integraciones.
  * Todos los repositorios de prueba de Thymeleaf.
  * Todas las aplicaciones de ejemplo oficiales de Thymeleaf, incluidas las aplicaciones de ejemplo basadas en el núcleo, Spring, Spring Security y Spring Boot.
* Creación de una configuración Maven multiproyecto de gran tamaño para compilar el árbol completo de módulos de Thymeleaf.
* Configuración de las aplicaciones de ejemplo para permitir la ejecución de aplicaciones web no basadas en Spring Boot desde la línea de comandos de Maven. 
* Creación de paquetes de distribución más completos en formato `.zip`, que ahora incluyen no solo bibliotecas, sino también aplicaciones de ejemplo tanto en formato binario como en código fuente (compilable).
* Migración de toda la infraestructura de pruebas a JUnit 5.

## Migrando a Thymeleaf 3.1

### Versión de JDK

Thymeleaf 3.1 cambia su nivel mínimo de compatibilidad a JDK 8, pero `thymeleaf-spring6` y `thymeleaf-extras-springsecurity6` requieren JDK 17 porque esta es la versión de JDK que requiere Spring 6.0.


### Estructuras relacionadas con la web

_(NOTA: En las aplicaciones web basadas en Spring, lo que se explica aquí permanecerá oculto para los desarrolladores y, por lo tanto, no afectará a sus aplicaciones. Los usuarios de Spring pueden omitir esta sección sin problema.)_

Thymeleaf 3.1 introduce tres interfaces que abstraen los detalles específicos de la API web que se esté utilizando (por ejemplo, `javax.*` o `jakarta.*`):

* `org.thymeleaf.web.IWebApplication`: Representa la aplicación web y los atributos asociados a ella.
* `org.thymeleaf.web.IWebExchange`: Representa el manejo de una solicitud web. Contiene la solicitud, la sesión (si existe) y cualquier atributo asociado por la aplicación a este intercambio específico.
* `org.thymeleaf.web.IWebRequest`: Representa una solicitud web: ruta URL, parámetros, encabezados y cookies.
* `org.thymeleaf.web.IWebSession`: Representa una sesión web, si existe, y contiene cualquier atributo asociado.

Aunque `IWebApplication` se correspondiera más o menos con el `ServletContext` de la API de Servlet, no existiría una correspondencia exacta entre esta y otras estructuras de la API de Servlet. Por ejemplo, parte de los datos que ofrece `HttpServletRequest` de la API de Servlet (como la URL y los parámetros) estarían contenidos en un objeto `IWebRequest`, mientras que otras partes (como los atributos de la solicitud) estarían contenidas en `IWebExchange`.

Thymeleaf proporciona implementaciones para todas estas interfaces tanto para entornos `javax.*` como para entornos `jakarta.*`.

Normalmente, una aplicación web instanciará una implementación específica de `IWebApplication` al inicializarse, como por ejemplo:

```java
final JakartaServletWebApplication application =
    JakartaServletWebApplication.buildApplication(servletContext);
```

Y luego, para cada solicitud entrante, esta implementación específica de la aplicación ofrecerá una forma de crear objetos `IWebExchange` que modelan el manejo de dicha solicitud, normalmente algún tipo de método `buildExchange(...)`:

```java
final HttpServletRequest request = ...;
final HttpServletResponse response = ...;
...
final IWebExchange webExchange = this.application.buildExchange(request, response);
final IWebRequest webRequest = webExchange.getRequest();
...
final String path = webRequest.getPathWithinApplication();
```

Estas interfaces ofrecen métodos para leer recursos, almacenar y leer datos, transformar URL, etc. Toda la información más común que necesitan las aplicaciones web. Además, las implementaciones específicas de estas interfaces suelen ofrecer una forma de obtener los objetos nativos de la API web que utilizan (por ejemplo, obtener el objeto `HttpServletRequest` subyacente del objeto `IWebExchange`).

Cabe destacar que su aplicación podrá seguir utilizando las clases específicas de su API web (por ejemplo, las clases `jakarta.*`). El uso de estas abstracciones solo será necesario al interactuar directamente con las API de Thymeleaf.


### Spring 6.0 y Spring Security 6.0 (y Spring Boot 3.0)

Las nuevas integraciones de Thymeleaf con Spring 6.0 y Spring Security 6.0 se configuran de forma equivalente a como se hacían (y se siguen haciendo) para Spring 5.x.

No deberían ser necesarios cambios, salvo reemplazar las dependencias anteriores `thymeleaf-spring5` o `thymeleaf-extras-springsecurity5` por las nuevas `thymeleaf-spring6` o `thymeleaf-extras-springsecurity6`.

En el caso de las aplicaciones basadas en Spring Boot, no se requieren cambios. El nuevo Spring Boot 3.0 ya configurará y utilizará Thymeleaf 3.1 al añadir el iniciador Thymeleaf Spring Boot.


### Restricciones de expresión

Para mejorar la seguridad de tus plantillas, Thymeleaf 3.1 ha implementado una serie de restricciones en las expresiones de variables (`${...}` y `*{...}`) que podrían afectar tu código existente.

Como se explica en la sección _Novedades_, los objetos de utilidad de expresiones `#request`, 
`#response`, `#session` y `#servletContext` ya no están disponibles en las expresiones de las plantillas.

La alternativa recomendada es agregar a tu modelo, a nivel del controlador, la información específica que tus plantillas necesitan de estos objetos. Esto se puede hacer mediante `model#addAttribute(...)` en el código del controlador, o mediante las anotaciones `@ModelAttribute` o incluso `@ControllerAdvice`.

```java
@ModelAttribute("contextPath")
public String contextPath(final HttpServletRequest request) {
    return request.getContextPath();
}
```

Además, como se detalla en la sección _Novedades_, se ha establecido una estricta restricción de 
uso para las clases que pertenecen al núcleo de JDK y Jakarta EE, con algunas excepciones. Los objetos de las clases prohibidas no se podrán usar en expresiones de variables desde Thymeleaf 3.1.

Si alguna de tus plantillas necesita ejecutar expresiones en objetos de las clases prohibidas, puedes crear una clase contenedora (en el paquete de tu aplicación) que delegue sus métodos al objeto original, y que sí se podrá usar en expresiones de variables.


### Desuso de th:include

Si tus plantillas utilizan el atributo `th:include`, ten en cuenta que esto seguirá estando permitido en Thymeleaf 3.1, pero se eliminará en una versión futura de la biblioteca. Se recomienda encarecidamente reemplazar el uso de `th:include` por `th:insert`, aunque cabe señalar que no funcionan exactamente igual.

Mientras que `th:include` solo insertaba el contenido de un fragmento, esto resulta en:

```html
<div id="main" th:include="~{::frag}">...</div>
...
<p th:fragment="frag" class="content">
    algo
</p>
```

...resulta en esto:

```html
<div id="main">
  algo
</div>
```

Al usar `th:insert`, se insertará todo el fragmento, _incluida la etiqueta en la que está definido_, lo que da como resultado:

```html
<div id="main" th:insert="~{::frag}">...</div>
...
<p th:fragment="frag" class="content">
  algo
</p>
```

...resulta en esto:

```html
<div id="main">
  <p class="content">
    algo
  </p>
</div>
```

Si necesita específicamente lograr el mismo resultado que con `th:include`, deberá combinar `th:insert` y `th:remove` de una manera similar a:

```html
<div id="main" th:insert="~{::frag}">...</div>
...
<p th:fragment="frag" th:remove="tag" class="content">
  algo
</p>
```

...lo que dará como resultado:

```html
<div id="main">
  algo
</div>
```

Recuerda también que los fragmentos también se pueden definir utilizando la etiqueta `<th:block>`, que siempre desaparecerá después de la evaluación, lo que proporciona una mayor flexibilidad:

```html
<div id="main" th:insert="~{::frag}">...</div>
...
<th:block th:fragment="frag">
    algo
</th:block>
```

El resultado sería:

```html
<div id="main">
    algo
</div>
```


### Desuso de expresiones de fragmentos sin envolver

En Thymeleaf, las expresiones de fragmento se expresan como `~{...}` y se pueden usar en muchos tipos de atributos y expresiones, aunque normalmente aparecen como valores para los atributos `th:insert` y `th:replace`.

Antes de Thymeleaf 3.1, atributos como `th:insert` o `th:replace` (o el obsoleto `th:include`) 
permitían especificar expresiones de fragmento sin el _contenedor_ `~{...}`:

```html
<div id="top" th:insert="common :: header">...</div>
```

Pero desde Thymeleaf 3.1, esta sintaxis, aunque seguirá funcionando, se considerará _obsoleta_ y 
se eliminará en una versión futura. Lo anterior ahora debe expresarse como:

```html
<div id="top" th:insert="~{common :: header}">...</div>
```

