---
title: Conceptos básicos de la integración de Thymeleaf y Spring Security
author: 'Jos&eacute; Miguel Samper \<jmiguelsamper AT users.sourceforge.net\>'
---

¿Has migrado a Thymeleaf, pero tus páginas de inicio de sesión y de error aún 
usan JSP? En este artículo veremos cómo configurar tu aplicación Spring para 
usar Thymeleaf en las páginas de inicio de sesión y de error.

Todo el código que se muestra aquí proviene de una aplicación en funcionamiento. 
Puede ver o descargar el código fuente desde [su repositorio de GitHub](https://github.com/thymeleaf/thymeleaf/tree/3.1-master/examples/springsecurity6/thymeleaf-examples-springsecurity6-websecurity).

**Nota:** Los paquetes de integración de Thymeleaf para Spring Security admiten 
aplicaciones Spring MVC y Spring WebFlux desde Spring Security 5, pero este 
artículo se centrará en una configuración Spring MVC.


Requisitos previos
-------------

Suponemos que está familiarizado con Thymeleaf y Spring Security, y que cuenta 
con una aplicación funcional que utiliza estas tecnologías. Si no conoce Spring 
Security, le recomendamos consultar la [Documentación de Spring Security](https://docs.spring.io/spring-security/reference/index.html).


Páginas de inicio de sesión
-----------

Con Spring Security puedes especificar cualquier URL para que funcione como 
página de inicio de sesión, por ejemplo:

```java
@Override
protected void configure(final HttpSecurity http) throws Exception {
    http
        .formLogin()
        .loginPage("/login.html")
        .failureUrl("/login-error.html")
      .and()
        .logout()
        .logoutSuccessUrl("/index.html");
}
```

Ahora tenemos que relacionar estas páginas dentro de un controlador Spring:

```java
@Controller
public class MainController {

  ...

  // Formulario de inicio de sesión
  @RequestMapping("/login.html")
  public String login() {
    return "login.html";
  }

  // Formulario de inicio de sesión con error
  @RequestMapping("/login-error.html")
  public String loginError(Model model) {
    model.addAttribute("loginError", true);
    return "login.html";
  }

}
```

Tenga en cuenta que estamos utilizando la misma plantilla **login.html** para 
ambas páginas, pero cuando se produce un error, establecemos un atributo 
booleano en el modelo.

Nuestra plantilla **login.html** es la siguiente:

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
  <head>
    <title>Página de inicio de sesión</title>
  </head>
  <body>
    <h1>Página de inicio de sesión</h1>
    <p th:if="${loginError}" class="error">Usuario o contraseña incorrectos</p>
    <form th:action="@{/login.html}" method="post">
      <label for="username">Nombre de usuario</label>:
      <input type="text" id="username" name="username" autofocus="autofocus" /> <br />
      <label for="password">Contraseña</label>:
      <input type="password" id="password" name="password" /> <br />
      <input type="submit" value="Acceder" />
    </form>
  </body>
</html>
```


Página de error
----------

También podemos configurar una página de error basada en Thymeleaf. En este caso, 
Spring Security no interviene en absoluto; simplemente debemos añadir un [ExceptionHandler](https://spring.io/blog/2013/11/01/exception-handling-in-spring-mvc) 
a nuestra configuración de Spring, como por ejemplo:


```java
@ControllerAdvice
public class ErrorController {

    private static Logger logger = LoggerFactory.getLogger(ErrorController.class);

    @ExceptionHandler(Throwable.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public String exception(final Throwable throwable, final Model model) {
        logger.error("Excepción durante la ejecución de la aplicación SpringSecurity", throwable);
        String errorMessage = (throwable != null ? throwable.getMessage() : "Error desconocido");
        model.addAttribute("errorMessage", errorMessage);
        model.addAttribute("httpStatus", HttpStatus.INTERNAL_SERVER_ERROR);
        return "error";
    }

}
```

La plantilla **error.html** podría ser similar a esta:

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
    <head>
        <title>Página de error</title>
        <meta charset="utf-8" />
        <link rel="stylesheet" href="css/main.css" th:href="@{/css/main.css}" />
    </head>
    <body>
        <h1 th:text="|${httpStatus} - ${httpStatus.reasonPhrase}|">500 - Internal Server Error</h1>
        <p th:utext="${errorMessage}">Error java.lang.NullPointerException</p>
        <a href="index.html" th:href="@{/index.html}">Volver a la página principal</a>
    </body>
</html>
```

Observe cómo pasamos el valor de enumeración `HttpStatus` de Spring como un 
atributo del modelo, de modo que la plantilla pueda mostrar información 
detallada sobre el estado del error (que en este caso siempre será `500`, pero 
esto nos permite reutilizar este `error.html` en otros escenarios de informes 
de errores donde se establece un `HttpStatus` diferente en el modelo).


Dialecto de Spring Security
-----------------------

En entornos Spring MVC, 
el [módulo de integración de Spring Security](https://github.com/thymeleaf/thymeleaf-extras-springsecurity) funciona como 
reemplazo de la 
[biblioteca de etiquetas de Spring Security](https://docs.spring.io/spring-security/reference/servlet/integrations/jsp-taglibs.html).

En este ejemplo, utilizamos este dialecto para imprimir las credenciales del 
usuario autenticado y mostrar contenido diferente a cada rol.

El atributo **sec:authorize** muestra su contenido cuando la expresión del 
atributo se evalúa como **verdadera**.

```html
<div sec:authorize="isAuthenticated()">
    Este contenido solo se muestra a usuarios autenticados.
</div>
<div sec:authorize="hasRole('ROLE_ADMIN')">
    Este contenido solo se muestra a los administradores.
</div>
<div sec:authorize="hasRole('ROLE_USER')">
    Este contenido solo se muestra a los usuarios.
</div>
```

El atributo **sec:authentication** se utiliza para imprimir el nombre de usuario 
y los roles del usuario que ha iniciado sesión.

```html
Usuario conectado: <span sec:authentication="name">Bob</span>
Roles: <span sec:authentication="authorities">[ROLE_USER, ROLE_ADMIN]</span>
```
