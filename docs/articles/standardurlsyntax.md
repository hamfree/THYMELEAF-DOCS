---
title: Sintaxis estándar de URL
---


Los dialectos estándar de Thymeleaf —-llamados *Standard* y *SpringStandard*-— 
ofrecen una forma sencilla de crear URL en sus aplicaciones web para que incluyan 
los artefactos de *preparación de URL* necesarios. Esto se realiza mediante las 
llamadas *expresiones de enlace*, un tipo de *expresión estándar de Thymeleaf*: 
`@{...}`

URLs absolutas
-------------

Las URL absolutas permiten crear enlaces a otros servidores. Comienzan 
especificando un nombre de protocolo (`http://` o `https://`).

```html
<a th:href="@{http://www.thymeleaf/documentation.html}">
```

No se modifican en absoluto (a menos que tenga configurado un filtro de 
_reescritura de URL_ en su servidor que realice modificaciones en el 
método `HttpServletResponse.encodeUrl(...)`):

```html
<a href="http://www.thymeleaf/documentation.html">
```


URLs relativas al contexto
---------------------

El tipo de URL más utilizado son las *relativas al contexto*. Estas URL deben 
ser relativas a la raíz de la aplicación web una vez instalada en el servidor. 
Por ejemplo, si desplegamos un archivo `myapp.war` en un servidor Tomcat, 
nuestra aplicación probablemente será accesible como 
`http://localhost:8080/myapp`, y `myapp` será el *nombre del contexto*.


Las URL relativas al contexto comienzan con `/`:

```html
<a th:href="@{/order/list}">
```

Si nuestra aplicación está instalada en `http://localhost:8080/myapp`, esta URL 
mostrará:

```html
<a href="/myapp/order/list">
```


URL relativas al servidor
--------------------

Las URL *relativas al servidor* son muy similares a las URL 
*relativas al contexto*, excepto que no presuponen que deseas que tu URL enlace 
a un recurso dentro del contexto de tu aplicación y, por lo tanto, te permiten 
enlazar a un contexto diferente en el mismo servidor:

```html
<a th:href="@{~/billing-app/showDetails.htm}">
```

Se ignorará el contexto de la aplicación actual; por lo tanto, aunque nuestra 
aplicación esté desplegada en `http://localhost:8080/myapp`, esta URL mostrará:

```html
<a href="/billing-app/showDetails.htm">
```


URL relativas al protocolo
----------------------

Las URL *relativas al protocolo* son, de hecho, URL absolutas que mantienen el 
protocolo (HTTP, HTTPS) utilizado para mostrar la página actual. Se suelen usar 
para incluir recursos externos como estilos, scripts, etc.:

```html
<script th:src="@{//scriptserver.example.net/myscript.js}">...</script>
```

...que se mostrará sin modificaciones (excepto por la *reescritura de URL*), 
como por ejemplo:

```html
<script src="//scriptserver.example.net/myscript.js">...</script>
```


Agregar parámetros
-----------------

¿Cómo añadimos parámetros a las URL que creamos con expresiones `@{...}`? 
Es sencillo:

```html
<a th:href="@{/order/details(id=3)}">
```

Lo cual daría como resultado:

```html
<a href="/order/details?id=3">
```

Puedes añadir varios parámetros, separándolos con comas:

```html
<a th:href="@{/order/details(id=3,action='show_all')}">
```

Lo cual daría como resultado:

```html
<!-- Tenga en cuenta que los signos de ampersand (&) deben escaparse en HTML 
     en los atributos de las etiquetas... -->
<a href="/order/details?id=3&amp;action=show_all">
```

También puedes incluir parámetros en forma de _variables de ruta_ similares a los 
parámetros _generales_, pero especificando un marcador de posición dentro de la 
ruta de tu URL:

```html
<a th:href="@{/order/{id}/details(id=3,action='show_all')}">
```

Lo cual daría como resultado:

```html
<a href="/order/3/details?action=show_all">
```



Identificadores de fragmentos de URL
------------------------

Los identificadores de fragmento pueden incluirse en las URL, tanto con 
parámetros como sin ellos. Siempre se incluirán en la base de la URL, de modo 
que:

```html
<a th:href="@{/home#all_info(action='show')}">
```

...el resultado sería:

```html
<a href="/home?action=show#all_info">
```


Reescritura de URL
-------------

Thymeleaf permite configurar filtros de reescritura de URL en la aplicación, y 
lo hace llamando al método `response.encodeURL(...)` en la clase 
`HttpServletResponse` de la API de Servlet para cada URL generada a partir de 
una plantilla de Thymeleaf (Thymeleaf 3.1 admite los espacios de nombres 
`javax.servlet` y `jakarta.servlet`).

Esta es la forma estándar de admitir operaciones de reescritura de URL en 
aplicaciones web Java y permite que las URL:

-   Detecta automáticamente si el usuario tiene las cookies habilitadas o no, y 
    añade el fragmento `;jsessionid=...` a la URL si no las tiene habilitadas, o 
    si es la primera solicitud y aún se desconoce la configuración de cookies.
-   Aplica automáticamente la configuración del proxy a las URL cuando sea 
    necesario.
-   Utiliza (si está configurado) diferentes configuraciones de CDN (Red de 
    Distribución de Contenido) para enlazar con contenido distribuido en varios 
    servidores.

Una tecnología muy común (y recomendada) para la reescritura de URL es 
[URLRewriteFilter](http://tuckey.org/urlrewrite/).


¿Solo para th:href?
-------------------

No creas que las expresiones URL `@{...}` solo se usan en los atributos 
`th:href`. De hecho, se pueden usar en cualquier lugar, al igual que las 
expresiones de variables (`${...}`) o las de externalización/internacionalización 
de mensajes (`#{...}`).

Por ejemplo, podrías usarlos en formularios...

```html
<form th:action="@{/order/processOrder}">
```

...o como parte de otra expresión. Aquí como parámetro de una cadena 
externalizada/internacionalizada:

```html
<p th:text="#{orders.explanation('3', @{/order/details(id=3,action='show_all')})}">
```


Uso de expresiones en las URL
-------------------------

¿Qué pasaría si necesitáramos escribir una expresión URL como esta?

```html
<a th:href="@{/order/details(id=3,action='show_all')}">
```

...pero ni `3` ni `show_all` podrían ser literales, porque solo conocemos su 
valor en tiempo de ejecución.

¡Sin problema! Cada valor de parámetro URL es, de hecho, una expresión, por lo 
que puedes sustituir fácilmente tus literales por cualquier otra expresión, 
incluyendo i18n, condicionales, etc.

```html
<a th:href="@{/order/details(id=${order.id},action=(${user.admin} ? 'show_all' : 'show_public'))}">
```

Además: una expresión URL como:

```html
<a th:href="@{/order/details(id=${order.id})}">
```

...es de hecho un atajo para:

```html
<a th:href="@{'/order/details'(id=${order.id})}">
```

Lo que significa que la propia URL base puede especificarse como una expresión, 
por ejemplo, una expresión variable:

```html
<a th:href="@{${detailsURL}(id=${order.id})}">
```

...o un texto externalizado/internacionalizado:

```html
<a th:href="@{#{orders.details.localized_url}(id=${order.id})}">
```

...incluso se pueden utilizar expresiones complejas, incluyendo condicionales, 
por ejemplo:

```html
<a th:href="@{(${user.admin}? '/admin/home' : ${user.homeUrl})(id=${order.id})}">
```

¿Lo quieres más limpio? Usa `th:with`:

```html
<a th:with="baseUrl=(${user.admin}? '/admin/home' : ${user.homeUrl})"
  th:href="@{${baseUrl}(id=${order.id})}">
```

...o...

```html
<div th:with="baseUrl=(${user.admin}? '/admin/home' : ${user.homeUrl})">
  ...
  <a th:href="@{${baseUrl}(id=${order.id})}">...</a>
  ...
</div>
```
