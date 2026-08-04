---
title: 'Spring MVC y Thymeleaf: cómo acceder a los datos desde las plantillas'
author: 'Rafa&#322; Borowiec &mdash; <a href="http://blog.codeleak.pl">http://blog.codeleak.pl</a>'
---
En una aplicación típica de Spring MVC, las clases `@Controller` se encargan de preparar un mapa de modelo con datos y seleccionar la vista que se va a renderizar. Este mapa de modelo permite la abstracción completa de la tecnología de vista y, en el caso de Thymeleaf, se transforma en un objeto de contexto de Thymeleaf (parte del _contexto de ejecución de plantillas de Thymeleaf_) que pone a disposición de las expresiones ejecutadas en las plantillas todas las variables definidas.


Atributos del modelo Spring
-----------------------

Spring MVC denomina atributos del modelo a los datos a los que se puede acceder durante la 
ejecución de las vistas. En Thymeleaf, el término equivalente es _variables de contexto_.

Existen varias maneras de añadir atributos del modelo a una vista en Spring MVC. A continuación, se muestran algunos casos comunes:

Añadir un atributo al modelo mediante su método `addAttribute`:

```java
    @RequestMapping(value = "message", method = RequestMethod.GET)
    public String messages(Model model) {
        model.addAttribute("messages", messageRepository.findAll());
        return "message/list";
    }
```

Devuelve `ModelAndView`con los atributos del modelo incluídos:

```java
    @RequestMapping(value = "message", method = RequestMethod.GET)
    public ModelAndView messages() {
        ModelAndView mav = new ModelAndView("message/list");
        mav.addObject("messages", messageRepository.findAll());
        return mav;
    }
```

Expone atributos comunes a través de métodos anotados con `@ModelAttribute`:

```java
    @ModelAttribute("messages")
    public List<Message> messages() {
        return messageRepository.findAll();
    }
```

Como habrás notado, en todos los casos anteriores se agrega el atributo `messages` al modelo y estará disponible en las vistas de Thymeleaf.

En Thymeleaf, se puede acceder a estos atributos del modelo (o _variables de contexto_, en la 
jerga de Thymeleaf) con la siguiente sintaxis: `${nombreAtributo}`, donde `nombreAtributo` en nuestro caso es `messages`. Esta es una expresión de [Spring EL][1]. En resumen, Spring EL (Spring Expression Language) es un lenguaje que permite consultar y manipular un grafo de objetos en tiempo de ejecución.

Puedes acceder a los atributos del modelo en las vistas con Thymeleaf de la siguiente manera:

```html
    <tr th:each="message : ${messages}">
        <td th:text="${message.id}">1</td>
        <td><a href="#" th:text="${message.title}">Title ...</a></td>
        <td th:text="${message.text}">Text ...</td>
    </tr>
```


Parámetros de solicitud
------------------

Los parámetros de la solicitud son accesibles fácilmente en las vistas de Thymeleaf. Los parámetros 
de la solicitud se pasan del cliente al servidor de la siguiente manera:

```html
    https://example.com/query?q=Thymeleaf+Is+Great!
```

Supongamos que tenemos un `@Controller` que envía una redirección con un parámetro de solicitud:

```java
    @Controller
    public class SomeController {
        @RequestMapping("/")
        public String redirect() {
            return "redirect:/query?q=Thymeleaf+Is+Great!";
        }
    }
```

Para acceder al parámetro `q` puede utilizar el prefijo `param.`:

```html
    <p th:text="${param.q}">Test</p>
```

En el ejemplo anterior, si el parámetro `q` no está presente, se mostrará una cadena vacía en el párrafo anterior; de lo contrario, se mostrará el valor de `q`.

Dado que los parámetros pueden ser multivalorados (por ejemplo, `https://example.com/query?q=Thymeleaf%20Is%20Great!&q=Really%3F`), puede acceder a ellos utilizando la sintaxis de corchetes:


```html
    <p th:text="${param.q[0] + ' ' + param.q[1]}" th:unless="${param.q == null}">Test</p>
```

Nota: Si accede a un parámetro multivalor con `${param.q}`, obtendrá un array serializado como valor.


Atributos de sesión
------------------

En el siguiente ejemplo agregamos `mySessionAttribute` a la sesión:

```java
    @RequestMapping({"/"})
    String index(HttpSession session) {
        session.setAttribute("mySessionAttribute", "someValue");
        return "index";
    }
```

De forma similar a los parámetros de la solicitud, se puede acceder a los atributos de la sesión utilizando el prefijo `session.`:

```html
    <p th:text="${session.mySessionAttribute}" th:unless="${session == null}">[...]</p>
```


Atributos de ServletContext
-------------------------

Los atributos de ServletContext se comparten entre solicitudes y sesiones. Para acceder a los atributos de ServletContext en Thymeleaf, puede usar el prefijo `application.`:

```html
        <table>
            <tr>
                <td>My context attribute</td>
                <!-- Recupera el atributo de ServletContext 'myContextAttribute' -->
                <td th:text="${application.myContextAttribute}">42</td>
            </tr>
            <tr th:each="attr : ${application}">
                <td th:text="${attr.key}">jakarta.servlet.context.tempdir</td>
                <td th:text="${attr.value}">/tmp</td>
            </tr>
        </table>
```


Beans de Spring
------------

Thymeleaf permite acceder a los beans registrados en el Spring Application Context con la sintaxis `@beanName`, por ejemplo:

```html
    <div th:text="${@urlService.getApplicationUrl()}">...</div> 
```

En el ejemplo anterior, `@urlService` se refiere a un Spring Bean registrado en su contexto, por ejemplo:

```java
    @Configuration
    public class MyConfiguration {
        @Bean(name = "urlService")
        public UrlService urlService() {
            return () -> "domain.com/myapp";
        }
    }

    public interface UrlService {
        String getApplicationUrl();
    }
```

Esto es bastante fácil y útil en algunos casos.


Referencias
----------

- [Thymeleaf + Spring][2]
- [Objetos básicos de expresión][3]


  [1]: http://docs.spring.io/spring-framework/docs/current/spring-framework-reference/html/expressions.html
  [2]: http://www.thymeleaf.org/doc/tutorials/3.1/thymeleafspring.html
  [3]: http://www.thymeleaf.org/doc/tutorials/3.1/usingthymeleaf.html#appendix-a-expression-basic-objects
