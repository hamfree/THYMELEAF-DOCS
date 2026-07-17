---
title: Llevamos Thymeleaf y plantillas naturales a la aplicación Spring PetClinic
author: 'Soraya S&aacute;nchez \<sschz AT users.sourceforge.net\>'
---

**Nota**: este artículo se refiere a una versión anterior de Thymeleaf 
(Thymeleaf 2.1).

La aplicación Spring PetClinic
--------------------------------
*Pet Clinic* es una de las aplicaciones de ejemplo creadas por SpringSource para 
Spring Framework. Está diseñada para mostrar y gestionar información relacionada 
con mascotas y veterinarios en una clínica veterinaria. La versión original de 
SpringSource se encuentra en [GitHub](https://github.com/SpringSource/spring-petclinic), 
 y la versión compatible con thymeleaf también se encuentra en 
[GitHub](https://github.com/thymeleaf/thymeleafexamples-petclinic).


![Página de inicio de PetClinic](images/petclinic/home.png)

*Pet Clinic* originalmente incluía una capa de vista creada con JSP, la cual 
reemplazaremos utilizando Thymeleaf:

-   Las modificaciones se enfocarán en la capa de vista: los ficheros JSP serán
    reemplazados y la aplicación será reconfigurada. Todo el código Java 
    permanecerá intacto. 
-   El marcado original se limpiará, pero toda la interfaz de la aplicación 
    deberá mostrarse exactamente igual que el original.
-   No se cambiarán los ficheros de hojas de estilo CSS. No se agregarán, 
    modificarán o actualizarán las librerías de JavaScript.
-   Los ficheros de plantilla Thymeleaf se mostrarán correctamente cuando se abran 
    estáticamente en un navegador (*Plantillas naturales*).

Todo el código de la aplicación PetClinic+Thymeleaf se puede obtener en 
la página [Thymeleaf Project's Documentation](/docs/documentation.html). Tenga 
en cuenta que los archivos JSP originales y las etiquetas JSP no se han eliminado 
del árbol de código fuente, sino que se han movido a la carpeta 
`doc/old_viewlayer` del árbol de código fuente, para que pueda seguir accediendo 
a ellos y compararlos con las nuevas plantillas.

La versión de aplicación PetClinic utilizada como base es la versión de su 
*rama principal en Github* del 17 de marzo de 2013.

### La capa de vista JSP original

La capa de vista original en JSP tiene un número de problemas que trataremos de 
arreglar cuando convirtamos la capa de vista a Thymeleaf:

-   Los JSPs incluyen etiquetas de JSTL, Librerías de Etiquetas de Spring y otras 
    librerías externas. Ninguna de estas son entendibles por los navegadores, por 
    lo que no hay forma para ellos de mostrar las páginas estáticas (No es 
    posible realizar prototipos estáticos).
-   Las etiquetas JSTL usan EL de JSP (Lenguaje de Expresiones), mientras que las 
    etiquetas de las bibliotecas de etiquetas de Spring para JSP utilizan el 
    lenguaje EL de Spring. Por lo tanto, se mezclan dos lenguajes de expresiones
    diferentes en la misma página.
-   Las plantillas originales de JSP no son documentos HTML bien formados. Por 
    ejemplo, la página *"ownersList"*:
    1. No contienen una etiqueta head, agregando en cambio una de otro JSP 
       usando una *include de JSP* (=\> no entendible por los navegadores).
    2. Los contenidos de la cabecera y el pie han sido reemplazados por etiquetas 
    include de JSP (=\> no entendible por los navegadores) así que las páginas 
    no pueden mostrarse estáticamente incluyendo su cabecera y pie. Y de 
    cualquier forma, incluso si esos contenidos fueran en la página, como las 
    páginas contienen etiquetas JSP y JSTL, no seríamos capaces de ver un 
    prototipo real.


Configuración
-------------

### Configuración básica del proyecto

Se necesitarán algunos pasos de configuración básicos:

-   Se modificará el archivo `pom.xml` para añadirle las dependencias de 
    Thymeleaf y eliminar las relacionadas con JSP.
-   El archivo `web.xml` se modificará para eliminar los servlets y filtros 
    relacionados con JSP.

### mvc-view-config.xml

Nuestro siguiente paso de configuración será agregar tres beans necesarios al 
archivo de configuración de beans de Spring, `mvc-view-config.xml`:

- El resolvedor de plantillas de Thymeleaf, encargado de leer los archivos de 
plantilla que se procesarán. Para esta aplicación, utilizaremos un 
`ServletContextTemplateResolver`.

- La instancia del motor de plantillas de Thymeleaf, de la clase 
`SpringTemplateEngine`.

- El resolvedor de vistas de Thymeleaf, una instancia de `ThymeleafViewResolver` 
que implementa la interfaz `org.springframework.web.servlet.ViewResolver` de 
Spring. Este bean sustituirá al bean original `InternalResourceViewResolver`, 
que habilitaba la compatibilidad con JSP en la aplicación original.

```xml
<bean id="templateResolver" class="org.thymeleaf.templateresolver.ServletContextTemplateResolver">
  <property name="prefix" value="/WEB-INF/thymeleaf/" />
  <property name="suffix" value=".html" />
  <property name="templateMode" value="HTML5" />
  <!-- La caché de plantillas está configurada como falsa (el valor predeterminado es verdadero). -->
  <property name="cacheable" value="false" />
</bean>

<bean id="templateEngine" class="org.thymeleaf.spring3.SpringTemplateEngine">
  <property name="templateResolver" ref="templateResolver" />
</bean>

<bean class="org.springframework.web.servlet.view.ContentNegotiatingViewResolver">
  <property name="contentNegotiationManager" ref="cnManager"/>
  <property name="viewResolvers">
    <list>
      <!-- Se utiliza aquí para las vistas 'xml' y 'atom' -->
      <bean class="org.springframework.web.servlet.view.BeanNameViewResolver">
        <property name="order" value="1"/>
      </bean>
        <!-- Se utiliza para vistas de Thymeleaf -->
      <bean class="org.thymeleaf.spring3.view.ThymeleafViewResolver">
        <property name="templateEngine" ref="templateEngine" />
        <property name="order" value="2"/>
      </bean>
    </list>
  </property>
</bean>
```

Tenga en cuenta que, a diferencia de la aplicación original, nuestras plantillas 
se ubicarán en la carpeta `/WEB-INF/thymeleaf` en lugar de la carpeta original 
`/WEB-INF/jsp`.


De JSP a Thymeleaf
---------------------

PetClinic incluye más de 10 plantillas JSP, y las reescribiremos todas usando 
Thymeleaf. Sin embargo, para simplificar, nos centraremos en 
`owners/ownerslist.jsp`, que convertiremos en `owners/ownersList.html`.

Recuerda que puedes ver todas las plantillas en el código fuente, que se puede 
descargar desde [la página de documentación](/docs/documentation.html), y 
también que puedes revisar los archivos JSP originales en la carpeta 
`doc/old_viewlayer`.

La página *owners/ownersList* tiene este aspecto:

![Página de propietarios](images/petclinic/owners.png)

Para convertir esta página a Thymeleaf, haremos lo siguiente:

- Cambiaremos el nombre de `ownersList.jsp` a `ownersList.html`.
- Eliminaremos todas las directivas `<%@ taglib %>`, ya que no necesitamos 
  ninguna biblioteca de etiquetas JSP.
- Reemplazaremos las etiquetas `jsp:include`, que añaden encabezado, pie de 
  página y encabezado a la página, por etiquetas que contengan los atributos de 
  Thymeleaf `th:substituteby` o `th:include`. Estos fragmentos de página se han 
  guardado en la carpeta `fragments` y también se han convertido a Thymeleaf.

```html
<!-- ownersList.jsp -->
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="datatables" uri="http://github.com/dandelion/datatables" %>

<html lang="en">

  <jsp:include page="../fragments/headTag.jsp"/>

  <body>
    <div class="container">
      <jsp:include page="../fragments/bodyHeader.jsp"/>

      <!-- ... -->

      <jsp:include page="../fragments/footer.jsp"/>

    </div>
  </body>

</html>
```

```html
<!-- ownersList.html -->
<!DOCTYPE html>

<html lang="en">

  <head th:substituteby="fragments/headTag :: headTag">

      <!-- ================================================================================================= -->
      <!-- Este <head> se utiliza únicamente para la creación de prototipos estáticos (plantillas naturales) -->
      <!-- y, por lo tanto, es totalmente opcional, ya que este fragmento de marcado se incluirá             -->
      <!-- desde "fragments.html" en tiempo de ejecución.                                                    -->
      <!-- ================================================================================================= -->

    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title>PetClinic :: a Spring Framework demonstration</title>

    <link href="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.0/css/bootstrap.min.css"
      th:href="@{/webjars/bootstrap/2.3.0/css/bootstrap.min.css}" rel="stylesheet" />
    <link href="../../../resources/css/petclinic.css"
      th:href="@{/resources/css/petclinic.css}" rel="stylesheet" />

    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"
      th:src="@{/webjars/jquery/1.9.0/jquery.js}"></script>
    <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"
      th:src="@{/webjars/jquery-ui/1.9.2/js/jquery-ui-1.9.2.custom.js}"></script>

    <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/themes/smoothness/jquery-ui.css"
      th:href="@{/webjars/jquery-ui/1.9.2/css/smoothness/jquery-ui-1.9.2.custom.css}"
      rel="stylesheet" />

  </head>

  <body>

    <div class="container">

      <div th:include="fragments/bodyHeader" th:remove="tag">

          <!-- ============================================================================================== -->
          <!-- Este div se utiliza únicamente para la creación de prototipos estáticos (plantillas naturales) -->
          <!-- y, por lo tanto, es completamente opcional, ya que este fragmento de marcado se incluirá       -->
          <!-- desde "fragments.html" en tiempo de ejecución.                                                 -->
          <!-- ============================================================================================== -->

        <img th:src="@{/resources/images/banner-graphic.png}"
          src="../../../resources/images/banner-graphic.png"/>

        <div class="navbar" style="width: 601px;">
          <div class="navbar-inner">
            <ul class="nav">
              <li style="width: 100px;">
                <a href="../welcome.html" th:href="@{/}">
                  <i class="icon-home"></i>Home
                </a>
              </li>
              <li style="width: 130px;">
                <a href="../owners/findOwners.html" th:href="@{/owners/find.html}">
                  <i class="icon-search"></i>Find owners
                </a>
              </li>
              <li style="width: 140px;">
                <a href="../vets/vetList.html" th:href="@{/vets.html}">
                  <i class="icon-th-list"></i>Veterinarians
                </a>
              </li>
              <li style="width: 90px;">
                <a href="../exception.html" th:href="@{/oups.html}"
                  title="trigger a RuntimeException to see how it is handled">
                  <i class="icon-warning-sign"></i>Error
                </a>
              </li>
              <li style="width: 80px;">
                <a href="#" title="not available yet. Work in progress!!">
                  <i class=" icon-question-sign"></i>Help
                </a>
              </li>
            </ul>
          </div>
        </div>

      </div>


      <!-- ... -->


      <table th:substituteby="fragments/footer :: footer" class="footer">

          <!-- ========================================================================================================== -->
          <!-- Esta sección de tabla se utiliza únicamente para la creación de prototipos estáticos (plantillas naturales -->
          <!--) y, por lo tanto, es completamente opcional, ya que este fragmento de marcado se                           -->
          <!-- incluirá desde "fragments.html" en tiempo de ejecución.                                                    -->
          <!-- ========================================================================================================== -->

        <tr>
          <td></td>
          <td align="right">
            <img src="../../../resources/images/springsource-logo.png"
              th:src="@{/resources/images/springsource-logo.png}"
              alt="Sponsored by SpringSource" />
          </td>
        </tr>

      </table>

    </div>

  </body>

</html>
```

Observa cómo nuestro archivo `ownersList.html` contiene más código en sus 
secciones de encabezado, cabecera y pie de página que el archivo JSP original. 
Hacerlo de esta manera es opcional, y su único objetivo es permitir que la 
plantilla `ownersList.html`, habilitada para Thymeleaf, se muestre estáticamente 
como un prototipo (algo prácticamente imposible con JSP).

*¿Merece la pena este código adicional?* Si necesitas o quieres usar prototipos 
de diseño, ¡sin duda! Verás claramente la diferencia que supone en la última 
sección de este artículo. Y de todos modos... ¡recuerda que este código de 
prototipado es opcional!

- Modifica el cuerpo de la página. El código original es el siguiente:


```html
<!-- ownersList.jsp -->
<datatables:table id="owners" data="${selections}" cdn="true" row="owner" theme="bootstrap2"
  cssClass="table table-striped" paginate="false" info="false" export="pdf">
  <datatables:column title="Name" cssStyle="width: 150px;" display="html">
    <spring:url value="owners/{ownerId}.html" var="ownerUrl">
      <spring:param name="ownerId" value="${owner.id}"/>
    </spring:url>
    <a href="${fn:escapeXml(ownerUrl)}"><c:out value="${owner.firstName} ${owner.lastName}"/></a>
  </datatables:column>
  <datatables:column title="Name" display="pdf">
    <c:out value="${owner.firstName} ${owner.lastName}"/>
  </datatables:column>
  <datatables:column title="Address" property="address" cssStyle="width: 200px;"/>
  <datatables:column title="City" property="city"/>
  <datatables:column title="Telephone" property="telephone"/>
  <datatables:column title="Pets" cssStyle="width: 100px;">
    <c:forEach var="pet" items="${owner.pets}">
      <c:out value="${pet.name}"/>
    </c:forEach>
  </datatables:column>
  <datatables:export type="pdf" cssClass="btn btn-small" />
</datatables:table>
```

Lo que reemplazaremos con:

```html
<!-- ownersList.html -->
<h2>Owners</h2>

<table class="table table-striped">
  <thead>
    <tr>
      <th style="width: 150px;">Name</th>
      <th style="width: 200px;">Address</th>
      <th>City</th>
      <th>Telephone</th>
      <th style="width: 100px;">Pets</th>
    </tr>
  </thead>
  <tbody>
    <tr th:each="owner : ${selections}">
      <td>
        <a href="ownerDetails.html"
          th:href="@{|/owners/${owner.id}|}"
          th:text="|${owner.firstName} ${owner.lastName}|">Mary Smith</a>
      </td>
      <td th:text="${owner.address}">45, Oxford Street</td>
      <td th:text="${owner.city}">Cambridge</td>
      <td th:text="${owner.telephone}">555-555-555</td>
      <td>
        <span th:each="pet : ${owner.pets}" th:text="${pet.name}" th:remove="tag">
          Rob
        </span>
      </td>
    </tr>
  </tbody>
</table>
```
-   En el código anterior se puede observar cómo utilizamos código HTML en lugar 
    de etiquetas JSP de una biblioteca externa. Esto no solo hace que nuestro 
    código sea mucho más claro y legible, sino también más estándar y 
    *comprensible para los navegadores*, lo que nos permitirá usar esta plantilla 
    como un *prototipo estático*. Veremos las ventajas de esto en la siguiente 
    sección.


¿Y qué pasa con lo de las *Plantillas Naturales*?
---------------------------------------------

Antes de comenzar esta migración, nos propusimos que nuestras nuevas plantillas 
de Thymeleaf se visualizaran correctamente al abrirlas de forma estática en un 
navegador (sin iniciar el servidor de la aplicación) gracias a las capacidades 
de *creación de plantillas naturales* de Thymeleaf.

Bien, veamos cómo se ve la plantilla original `owners/ownersList.jsp` cuando se 
visualiza de forma estática:

![Lista de propietarios (JSP), abierta estáticamente](images/petclinic/ownerslist_jsp_static.png)

...y ahora echemos un vistazo a nuestro nueva página impulsada por Thymeleaf
`owners/ownersList.html`:

![Lista de propietarios (thymeleaf), abierta estáticamente](images/petclinic/ownerslist_thymeleaf_static.png)

Aquí está. Los datos no son válidos, porque es un prototipo. ¡Pero se ve bien!
