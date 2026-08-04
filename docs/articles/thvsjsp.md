---
title: 'Capa de vista de Spring MVC: Thymeleaf vs. JSP'
---


En este artículo compararemos la misma página (un formulario de suscripción) 
creada dos veces para la misma aplicación Spring MVC: una vez con Thymeleaf y 
otra con JSP, JSTL y las librerías de etiquetas de Spring.

Todo el código que se muestra aquí proviene de una aplicación en funcionamiento. 
Puedes ver o descargar el código fuente desde 
[su repositorio de GitHub](https://github.com/thymeleaf/thymeleaf/tree/3.1-master/examples/spring6/thymeleaf-examples-spring6-thvsjsp).

Requisitos comunes
-------------------

Nuestros clientes necesitan un formulario para suscribir nuevos miembros a una 
lista de mensajes, con dos campos:

- Correo electrónico
- Tipo de suscripción (recibir todos los correos, resumen diario)

Esta página también deberá ser HTML5 y completamente internacionalizable, 
extrayendo todos los textos y mensajes de los archivos de recursos ya 
configurados en nuestros objetos `MessageSource` en nuestra infraestructura 
Spring.

Nuestra aplicación tendrá dos `@Controller`, que contendrán exactamente el mismo 
código pero redirigirán a diferentes vistas:

- `SubscribeJsp` para la página JSP (la vista `subscribejsp`).

- `SubscribeTh` para la página Thymeleaf (la vista `subscribeth`).

Nuestro modelo incluirá las siguientes clases:

- `Subscription`, un bean de respaldo para el formulario con dos campos: 
  `String email` y `SubscriptionType subscriptionType`.
- `SubscriptionType` es una enumeración que modela el campo `subscriptionType` 
   del formulario, con los valores `ALL_EMAILS` y `DAILY_DIGEST`.

*(En este artículo nos centraremos únicamente en el código de la plantilla 
JSP/Thymeleaf. Si desea conocer los detalles de implementación del código del 
controlador o la configuración de Spring, consulte el código fuente en el 
paquete descargable).*


Hacerlo con JSP
-----------------


Esta es nuestra página:

![La página JSP](images/thvsjsp/jsp1.png)

Y este es nuestro código JSP, usando las librerías de etiquetas de Spring JSP (`tags` and 
`form`) y JSTL (`core`): 

```html
<%@ taglib prefix="sf" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html>

  <head>
    <title>Spring MVC view layer: Thymeleaf vs. JSP</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" type="text/css" media="all" href="<s:url value='/css/thvsjsp.css' />"/>
  </head>

  <body>

    <h2>This is a JSP</h2>

    <s:url var="formUrl" value="/subscribejsp" />
    <sf:form modelAttribute="subscription" action="${formUrl}">

      <fieldset>

        <div>
          <label for="email"><s:message code="subscription.email" />: </label>
          <sf:input path="email" />
        </div>
        <div>
          <label><s:message code="subscription.type" />: </label>
          <ul>
            <c:forEach var="type" items="${allTypes}" varStatus="typeStatus">
              <li>
                <sf:radiobutton path="subscriptionType" value="${type}" />
                <label for="subscriptionType${typeStatus.count}">
                  <s:message code="subscriptionType.${type}" />
                </label>
              </li>
            </c:forEach>
          </ul>
        </div>

        <div class="submit">
          <button type="submit" name="save"><s:message code="subscription.submit" /></button>
        </div>

      </fieldset>

    </sf:form>

  </body>

</html>
```


Haciéndolo con Thymeleaf
-----------------------

Ahora, vamos a hacer lo mismo con Thymeleaf. Esta es nuestra página:


![La página Thymeleaf](images/thvsjsp/th1.png)

Y este es nuestro código Thymeleaf:

```html
<!DOCTYPE html>

<html xmlns:th="http://www.thymeleaf.org">

  <head>
    <title>Spring MVC view layer: Thymeleaf vs. JSP</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" type="text/css" media="all"
      href="../../css/thvsjsp.css" th:href="@{/css/thvsjsp.css}"/>
  </head>

  <body>

    <h2>This is a Thymeleaf template</h2>

    <form action="#" th:object="${subscription}" th:action="@{/subscribeth}">

      <fieldset>

        <div>
          <label for="email" th:text="#{subscription.email}">Email: </label>
          <input type="text" th:field="*{email}" />
        </div>
        <div>
          <label th:text="#{subscription.type}">Type: </label>
          <ul>
            <li th:each="type : ${allTypes}">
              <input type="radio" th:field="*{subscriptionType}" th:value="${type}" />
              <label th:for="${#ids.prev('subscriptionType')}"
                th:text="#{|subscriptionType.${type}|}">First type</label>
            </li>
            <li th:remove="all"><input type="radio" /> <label>Second Type</label></li>
          </ul>
        </div>

        <div class="submit">
          <button type="submit" name="save" th:text="#{subscription.submit}">Subscribe me!</button>
        </div>

      </fieldset>

    </form>

  </body>

</html>
```

Aspectos a tener en cuenta  aquí:

- Esto se parece mucho más a HTML que la versión JSP -- sin etiquetas extrañas, 
  solo algunos atributos significativos.

- Las expresiones variables (`${...}`) son de Spring EL y se ejecutan en los 
  atributos del modelo; las expresiones con asterisco (`*{...}`) se ejecutan en 
  el bean de respaldo del formulario; las expresiones con hash (`#{...}`) se usan 
  para la internacionalización; y las expresiones de enlace (`@{...}`) reescriben 
  las URL. (*Si quieres saber más, consulta la guía 
  ["Introducción al dialecto estándar en 5 minutos"](standarddialect5minutes.html)*).

- Se permite incluir código de prototipo: por ejemplo, podemos establecer el 
  texto `Email:` en la etiqueta del primer campo, sabiendo que Thymeleaf lo 
  sustituirá por el texto internacionalizado con la clave `subscription.email` 
  al ejecutar la página.

- Incluso hemos podido añadir un `<li>` para un segundo botón de opción, 
  simplemente por placer de prototipar. Se eliminará cuando Thymeleaf ejecute 
  nuestra página.


¡Cambiemos el estilo de la página!
----------------------------
Imaginemos que, una vez escritas nuestras páginas, decidimos de repente que ya 
no queremos verde para la zona alrededor del botón de envío, sino un azul 
pálido. De todas formas, no estamos seguros del tono exacto de azul que mejor se 
adapte, así que tendremos que probar varias combinaciones antes de decidirnos 
por una en concreto.

Veamos los pasos que tendríamos que seguir con cada tecnología:

### Cambiar el estilo de la página usando JSP

**Paso 1**: *Desplegar la aplicación en nuestro servidor de desarrollo e 
iniciarlo*. Nuestra página JSP no se renderizará sin iniciar el servidor,
así que esto será un requisito.

**Paso 2**: *Navegar por las páginas hasta encontrar la que queremos modificar*. 
Normalmente, la página que queremos modificar será una de las decenas de páginas 
de nuestra aplicación, y es muy probable que para acceder a ella tengamos que 
hacer clic en enlaces, enviar formularios o consultar bases de datos.

**Paso 3**: *Abrir Firebug, Dragonfly o tu herramienta de desarrollo web favorita 
en el navegador*. Esto nos permitirá modificar los estilos actuando directamente 
sobre el DOM del navegador y, por lo tanto, ver los resultados de inmediato.

**Paso 4**: *Realizar los cambios de color*. Probablemente probaremos un par de 
tonos de azul diferentes antes de decidirnos por el que nos guste.


![Página JSP optimizada](images/thvsjsp/jsp2.png)

**Paso 5**: *Copiar y pegar los cambios en nuestros archivos CSS*.

¡Hecho!

### Cambiar el estilo de la página usando Thymeleaf

**Paso 1**: *Haz doble clic en el archivo de plantilla `.html` y deja que tu 
navegador lo abra*. Al ser una plantilla de Thymeleaf, se mostrará correctamente, 
solo con los datos de la plantilla/prototipo (observa las opciones del tipo de 
suscripción):

![Página Thymeleaf - válida como prototipo](images/thvsjsp/th2.png)

**Paso 2**: *Abre el archivo `.css` con tu editor de texto favorito*.
El archivo de plantilla enlaza estáticamente con el CSS en su etiqueta 
`<link rel="stylesheet" ...>` (con un `href` que Thymeleaf sustituye al ejecutar 
la plantilla por el generado por `th:href`). Por lo tanto, cualquier cambio que 
hagamos en ese CSS se aplicará a la página estática que muestra nuestro 
navegador.

**Paso 3**: *Realiza los cambios de color*. Como sucedió con JSP, probablemente 
tendremos que probar varias combinaciones de colores, que se actualizarán en 
nuestro navegador simplemente pulsando F5.

¡Listo!

### ¡Esa fue una gran diferencia!
La diferencia en el número de pasos no es realmente importante aquí (también 
podríamos haber usado Firebug con la plantilla Thymeleaf). Lo que sí es 
importante es la complejidad, el esfuerzo y el tiempo que requiere cada uno de 
los pasos necesarios para JSP. Tener que desplegar e iniciar toda la aplicación 
hizo que JSP perdiera terreno.

Además, piense en cómo evolucionaría esta diferencia si:

- Nuestro servidor de desarrollo no fuera local, sino remoto.
- Los cambios no solo implicaran CSS, sino también añadir o eliminar código HTML.
- Aún no hubiéramos implementado la lógica necesaria en nuestra aplicación para 
  *acceder a esa página* una vez desplegada.

Este último punto es crucial: ¿qué pasaría si nuestra aplicación aún estuviera 
en desarrollo, la lógica Java necesaria para mostrar esta u otras páginas 
anteriores no funcionara correctamente y tuviéramos que mostrar el nuevo color a 
nuestro cliente? (¡o incluso dejar que lo eligiera sobre la marcha!)...

### ¿Y qué hay de intentar usar JSP como prototipo estático?

Vale, ahora podrías preguntar: *¿Pero por qué iniciamos la aplicación para 
modificar el JSP en lugar de simplemente abrirlo como hiciste con Thymeleaf? ¿No 
podemos hacer eso?*

La respuesta corta es NO.

Pero intentémoslo de todos modos: por supuesto, tendremos que renombrar nuestro 
archivo para que termine en `.html` en lugar de `.jsp`, pero veamos qué sucede 
cuando abrimos el navegador:

![Página JSP abierta directamente en un navegador.](images/thvsjsp/jsp3.png)

¿QUÉ? ¿Dónde está nuestra página? Bueno, sigue ahí, pero para que funcionara como 
JSP tuvimos que añadir muchas etiquetas y funciones JSP que la hicieron funcionar 
perfectamente al ser ejecutada por nuestro servidor web... pero al mismo tiempo, 
dejaron de ser HTML. Y por lo tanto, dejaron de ser visibles en un navegador.

Recordemos de nuevo cómo se veía la plantilla de Thymeleaf cuando hacíamos doble 
clic en ella:

![Página de Thymeleaf abierta directamente en un navegador.](images/thvsjsp/th2.png)

Definitivamente no están en la misma liga, ¿verdad?


¿Tienes HTML5?
----------

Pero bueno -- dijimos al principio que nuestra página iba a ser HTML5, así 
que... ¿por qué no aprovechamos algunas de las nuevas y geniales funciones de 
formularios de HTML5?

Por ejemplo, ahora existe `<input type="email" ...>`, que hace que nuestro 
navegador compruebe que el texto introducido por el usuario tenga el formato de 
una dirección de correo electrónico. Además, hay una nueva propiedad para todos 
los campos de entrada llamada `placeholder`, que muestra un texto en el campo 
que desaparece automáticamente cuando el campo recibe el foco (normalmente 
cuando el usuario hace clic en él).

Suena bien, ¿verdad? E incluso si algún navegador no lo admitiera, seguiríamos 
usando estas funciones sin problemas, ya que todos los navegadores tratarán un 
campo de entrada de un tipo que no reconocen (`email`) como un campo de texto, e 
ignorarán silenciosamente el atributo `placeholder` del mismo modo que ignoran 
los atributos `th:*` de Thymeleaf.

### Cómo usar HTML5 con JSP

#### Antes de Spring 3.1

Las bibliotecas de etiquetas JSP de Spring MVC no ofrecían soporte completo para 
HTML5 hasta Spring 3.1, por lo que antes de esta versión no había otra forma de 
escribir una etiqueta de entrada de *tipo correo electrónico* que no fuera 
hacerlo en HTML simple, como por ejemplo:

```html
<input type="email" id="email" name="email" placeholder="your@email" value="" />
```
¡Pero esto no era correcto! En Spring MVC, nunca deberíamos escribir un campo de 
entrada JSP de esa manera, ya que no estaríamos *vinculando* correctamente nuestra 
entrada a la propiedad `email` del bean que respalda el formulario. Para ello, 
necesitaríamos usar la etiqueta `<s:eval/>`, que aplicará todas las 
transformaciones necesarias (como los *editores de propiedades*) y hará que 
nuestra etiqueta HTML simple funcione como si existiera la etiqueta 
`<sf:email/>`:

```html
<input type="email" id="email" name="email" placeholder="your@email"
       value="<s:eval expression='subscription.email' />" />
```

#### Desde Spring 3.1

En Spring 3.1 todavía no existe la etiqueta `<sf:email ...>`, pero la etiqueta 
existente `<sf:input ...>` nos permite especificar un atributo `type` con el 
valor `email`, lo cual funcionará perfectamente:

```html
<sf:input path="email" type="email" />
```

Y esto realizará correctamente nuestros *vinculaciones de formulario* :-).

### Usando HTML5 con Thymeleaf

Thymeleaf ofrece compatibilidad total con HTML5 (incluso con Spring 3.0), por lo 
que solo tendremos que cambiar el `type` de nuestro campo de entrada y añadir un 
`placeholder`. Funcionará sin problemas, vinculando correctamente nuestra 
propiedad e integrándose con los *editores de propiedades* de Spring MVC. Y, lo 
que es más importante, se mostrará como un campo de entrada normal cuando se 
muestre como prototipo ---algo que la etiqueta `sf:input` no permite---:


```html
<input type="email" th:field="*{email}" placeholder="your@email" />
```

¡Hecho!

![Resultado final con Thymeleaf](images/thvsjsp/th3.png)
