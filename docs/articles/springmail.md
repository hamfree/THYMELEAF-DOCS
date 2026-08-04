---
title: Envío de correos electrónicos en Spring con Thymeleaf
author: 'Jos&eacute; Miguel Samper \<jmiguelsamper AT users.sourceforge.net\>'
---

En este artículo mostraremos cómo usar las plantillas de Thymeleaf para redactar 
correos electrónicos de diversos tipos, e integraremos esto con las utilidades 
de correo electrónico de Spring para configurar un sistema de correo electrónico 
sencillo pero potente.

Cabe destacar que, si bien este artículo —y la aplicación de ejemplo 
correspondiente— utiliza el framework Spring, Thymeleaf también puede usarse 
para procesar plantillas de correo electrónico en una aplicación sin Spring. 
Asimismo, tenga en cuenta que la aplicación de ejemplo es una aplicación web, 
pero no es necesario que una aplicación esté habilitada para la web para enviar 
correos electrónicos con Thymeleaf.


Requisitos previos
-------------

Este artículo presupone que usted está familiarizado con Thymeleaf y Spring.
No profundizaremos en los detalles de Spring Mail; para obtener más información, 
consulte el 
[capítulo sobre correo electrónico en la documentación de Spring](https://docs.spring.io/spring-framework/reference/integration/email.html).


Ejemplo de aplicación
-------------------

Todo el código de este artículo proviene de una aplicación de ejemplo funcional. 
Puede ver o descargar el código fuente desde [su repositorio de GitHub](https://github.com/thymeleaf/thymeleaf/tree/3.1-master/examples/spring6/thymeleaf-examples-spring6-springmail). Se 
recomienda encarecidamente descargar esta aplicación, ejecutarla y explorar su 
código fuente *(tenga en cuenta que deberá configurar su nombre de usuario y 
contraseña SMTP, así como su servidor SMTP si no utiliza Gmail, en 
`src/main/resources/configuration.properties`)*.


Envío de correo electrónico con Spring
-------------------------

Primero, debes configurar un objeto **Remitente de correo** en tu configuración 
de Spring, como se muestra en el siguiente código (tus necesidades de 
configuración específicas pueden variar):

```java
@Configuration
@PropertySource("classpath:mail/emailconfig.properties")
public class SpringMailConfig implements ApplicationContextAware, EnvironmentAware {

    private static final String JAVA_MAIL_FILE = "classpath:mail/javamail.properties";

    private ApplicationContext applicationContext;
    private Environment environment;

    ...

    @Bean
    public JavaMailSender mailSender() throws IOException {

        final JavaMailSenderImpl mailSender = new JavaMailSenderImpl();

        // Configuración básica del remitente de correo, basada en emailconfig.properties
        mailSender.setHost(this.environment.getProperty(HOST));
        mailSender.setPort(Integer.parseInt(this.environment.getProperty(PORT)));
        mailSender.setProtocol(this.environment.getProperty(PROTOCOL));
        mailSender.setUsername(this.environment.getProperty(USERNAME));
        mailSender.setPassword(this.environment.getProperty(PASSWORD));

        // Configuración del remitente de correo específica de JavaMail, basada en javamail.properties.
        final Properties javaMailProperties = new Properties();
        javaMailProperties.load(this.applicationContext.getResource(JAVA_MAIL_FILE).getInputStream());
        mailSender.setJavaMailProperties(javaMailProperties);

        return mailSender;

    }

    ...

}
```

Tenga en cuenta que el código anterior obtiene la configuración de los archivos 
de propiedades `mail/emailconfig.properties` y `mail/javamail.properties` en su 
classpath.

Spring proporciona una clase llamada `MimeMessageHelper` para facilitar la 
creación de mensajes de correo electrónico. Veamos cómo usarla junto con 
nuestro `mailSender`.

```java
final MimeMessage mimeMessage = this.mailSender.createMimeMessage();
final MimeMessageHelper message = new MimeMessageHelper(mimeMessage, "UTF-8");
message.setFrom("sender@example.com");
message.setTo("recipient@example.com");
message.setSubject("This is the message subject");
message.setText("This is the message body");
this.mailSender.send(mimeMessage);
```


Plantillas de correo electrónico de Thymeleaf
-------------------------

Utilizar Thymeleaf para procesar nuestras plantillas de correo electrónico nos 
permitiría usar algunas funciones interesantes:

-   **Expresiones** en Spring EL.
-   Control de flujo: **iteraciones**, **condicionales**, ...
-   **Funciones de utilidad**: formato de fecha/número, manejo de listas, matrices...
-   Fácil **i18n**, integrado con la infraestructura de internacionalización 
    Spring de nuestra aplicación.
-   **Plantillas naturales**: nuestras plantillas de correo electrónico pueden 
    ser prototipos estáticos, escritos por diseñadores de interfaz de usuario.
-   etc...

Además, dado que Thymeleaf no requiere dependencias de la API de servlets, 
**no sería necesario crear ni enviar correos electrónicos desde una aplicación 
web**. Las técnicas aquí explicadas podrían utilizarse con pocos o ningún cambio 
en una aplicación independiente sin interfaz web.

### Nuestros objetivos

Nuestra aplicación de ejemplo enviará cinco tipos de correos electrónicos:

1. Correo de texto (sin HTML).
2. HTML simple (con saludo internacionalizado).
3. Texto HTML con un archivo adjunto.
4. Texto HTML con una imagen insertada.
5. Texto HTML editado por el usuario.

### Configuración de Spring

Para procesar nuestras plantillas, configuraremos un `TemplateEngine` 
especialmente configurado para el procesamiento de correo electrónico, en 
nuestra configuración de Spring Email:

```java
@Configuration
@PropertySource("classpath:mail/emailconfig.properties")
public class SpringMailConfig implements ApplicationContextAware, EnvironmentAware {

    ...

    @Bean
    public ResourceBundleMessageSource emailMessageSource() {
        final ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
        messageSource.setBasename("mail/MailMessages");
        return messageSource;
    }

    ...

    @Bean
    public TemplateEngine emailTemplateEngine() {
        final SpringTemplateEngine templateEngine = new SpringTemplateEngine();
        // Solucionador para correos electrónicos de texto
        templateEngine.addTemplateResolver(textTemplateResolver());
        // Solucionador para correos electrónicos HTML (excepto el editable)
        templateEngine.addTemplateResolver(htmlTemplateResolver());
        // Solucionador para correos electrónicos HTML editables (que se tratarán como una cadena de texto).
        templateEngine.addTemplateResolver(stringTemplateResolver());
        // Fuente del mensaje, internacionalización específica para correos electrónicos
        templateEngine.setTemplateEngineMessageSource(emailMessageSource());
        return templateEngine;
    }

    private ITemplateResolver textTemplateResolver() {
        final ClassLoaderTemplateResolver templateResolver = new ClassLoaderTemplateResolver();
        templateResolver.setOrder(Integer.valueOf(1));
        templateResolver.setResolvablePatterns(Collections.singleton("text/*"));
        templateResolver.setPrefix("/mail/");
        templateResolver.setSuffix(".txt");
        templateResolver.setTemplateMode(TemplateMode.TEXT);
        templateResolver.setCharacterEncoding(EMAIL_TEMPLATE_ENCODING);
        templateResolver.setCacheable(false);
        return templateResolver;
    }

    private ITemplateResolver htmlTemplateResolver() {
        final ClassLoaderTemplateResolver templateResolver = new ClassLoaderTemplateResolver();
        templateResolver.setOrder(Integer.valueOf(2));
        templateResolver.setResolvablePatterns(Collections.singleton("html/*"));
        templateResolver.setPrefix("/mail/");
        templateResolver.setSuffix(".html");
        templateResolver.setTemplateMode(TemplateMode.HTML);
        templateResolver.setCharacterEncoding(EMAIL_TEMPLATE_ENCODING);
        templateResolver.setCacheable(false);
        return templateResolver;
    }

    private ITemplateResolver stringTemplateResolver() {
        final StringTemplateResolver templateResolver = new StringTemplateResolver();
        templateResolver.setOrder(Integer.valueOf(3));
        // No hay patrón resoluble, simplemente procesará como plantilla de cadena todo lo que no haya coincidido previamente.
        templateResolver.setTemplateMode(TemplateMode.HTML);
        templateResolver.setCacheable(false);
        return templateResolver;
    }

    ...

}
```

Tenga en cuenta que hemos configurado tres *resolutores de plantillas* para 
nuestro motor específico de correo electrónico: uno para las plantillas de 
TEXTO, otro para las plantillas HTML y un tercero para las plantillas HTML 
editables, que daremos al usuario la oportunidad de modificar y que llegarán al 
motor de plantillas como una simple `String` una vez modificadas.

Los tres solucionadores de plantillas están ordenados de manera que se ejecuten 
en secuencia, intentando hacer coincidir sus *patrones resolubles* con el nombre 
de la plantilla y resolviendo la plantilla especificada solo si su nombre 
coincide.

Cabe destacar también que este `TemplateEngine` es específico para el 
procesamiento de correo electrónico y completamente independiente del utilizado 
para la interfaz web. Este `TemplateEngine` para la interfaz web, que se 
integrará con Spring MVC mediante un `ThymeleafViewResolver`, se define en 
realidad en un archivo `@Configuration` diferente que implementa 
`WebMvcConfigurer` (y que no mostraremos aquí para centrarnos en el 
procesamiento de correo electrónico).

### Ejecutando el motor de plantillas

En algún punto de nuestro código, necesitaremos ejecutar nuestro motor de 
plantillas para generar el texto de nuestros mensajes. Hemos optado por hacerlo 
en una clase `EmailService`, para que quede claro que consideramos que esta es 
una responsabilidad de nuestra *capa de negocio* (y no de la *capa web*).

Como es habitual en Thymeleaf, antes de ejecutar la plantilla necesitaremos 
rellenar un *contexto* que contenga todas las variables que queremos usar 
durante su ejecución. Dado que el procesamiento de nuestro correo electrónico no 
depende de la web, una instancia de `Context` será suficiente:

```java
final Context ctx = new Context(locale);
ctx.setVariable("name", recipientName);
ctx.setVariable("subscriptionDate", new Date());
ctx.setVariable("hobbies", Arrays.asList("Cinema", "Sports", "Music"));
ctx.setVariable("imageResourceName", imageResourceName); // para que podamos hacer referencia a él desde HTML

final String htmlContent = this.templateEngine.process("html/email-inlineimage.html", ctx);
```

Nuestro archivo `email-inlineimage.html` es la plantilla que utilizaremos para 
enviar correos electrónicos con una imagen insertada, y tiene el siguiente 
aspecto:

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
  <head>
    <title th:remove="all">Template for HTML email with inline image</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  </head>
  <body>
    <p th:text="#{greeting(${name})}">
      Hello, Peter Static!
    </p>
    <p th:if="${name.length() > 10}">
      Wow! You've got a long name (more than 10 chars)!
    </p>
    <p>
      You have been successfully subscribed to the <b>Fake newsletter</b> on
      <span th:text="${#dates.format(subscriptionDate)}">28-12-2012</span>
    </p>
    <p>Your hobbies are:</p>
    <ul th:remove="all-but-first">
      <li th:each="hobby : ${hobbies}" th:text="${hobby}">Reading</li>
      <li>Writing</li>
      <li>Bowling</li>
    </ul>
    <p>
      You can find <b>your inlined image</b> just below this text.
    </p>
    <p>
      <img src="sample.png" th:src="|cid:${imageResourceName}|" />
    </p>
    <p>
      Regards, <br />
      <em>The Thymeleaf Team</em>
    </p>
  </body>
</html>
```

Analicemos algunos puntos:

-   La plantilla anterior es totalmente WYSIWYG; puedes ver cómo queda 
    simplemente abriéndola con tu navegador. Es mucho mejor que enviar un correo 
    electrónico para ver el resultado, ¿verdad?

![Imagen insertada en el correo electrónico](images/springmail/inline.png)

-   Podemos usar todas las características de Thymeleaf. Aquí, por ejemplo, 
    hemos usado i18n con una expresión parametrizada `#{...}`, `th:each` para 
    iterar sobre una lista, `#dates` para formatear una fecha...
-   El elemento `img` tiene un valor `src` codificado de forma fija (útil para 
    la creación de prototipos), que se sustituirá en tiempo de ejecución por 
    algo como `cid:image.jpg` que coincida con el nombre del archivo de imagen 
    adjunto.


### Correo electrónico de texto (no HTML)

¿Y qué pasa con el correo electrónico de texto? Bueno, ya hemos configurado un 
resolvedor de plantillas para plantillas de correo electrónico de texto, así que 
todo lo que tendríamos que hacer es crear una plantilla usando la sintaxis 
textual de Thymeleaf, como por ejemplo:

```
[( #{greeting(${name})} )]

[# th:if="${name.length() gt 10}"]Wow! You've got a long name (more than 10 chars)![/]

You have been successfully subscribed to the Fake newsletter on [( ${#dates.format(subscriptionDate)} )].

Your hobbies are:
[# th:each="hobby : ${hobbies}"]
 - [( ${hobby} )]
[/]

Regards,
    The Thymeleaf Team
```



Reuniéndolo todo
-----------------------

### La clase de servicio

Finalmente, veamos cómo se vería el método que ejecuta esta plantilla de correo 
electrónico en nuestra clase de servicio `EmailService`:

```java
public void sendMailWithInline(
  final String recipientName, final String recipientEmail, final String imageResourceName,
  final byte[] imageBytes, final String imageContentType, final Locale locale)
  throws MessagingException {

    // Preparar el contexto de evaluación
    final Context ctx = new Context(locale);
    ctx.setVariable("name", recipientName);
    ctx.setVariable("subscriptionDate", new Date());
    ctx.setVariable("hobbies", Arrays.asList("Cinema", "Sports", "Music"));
    ctx.setVariable("imageResourceName", imageResourceName); // para que podamos hacer referencia a él desde HTML

    // Preparar mensaje usando una función auxiliar de Spring.
    final MimeMessage mimeMessage = this.mailSender.createMimeMessage();
    final MimeMessageHelper message =
        new MimeMessageHelper(mimeMessage, true, "UTF-8"); // true = multipart
    message.setSubject("Example HTML email with inline image");
    message.setFrom("thymeleaf@example.com");
    message.setTo(recipientEmail);

    // Crea el cuerpo HTML usando Thymeleaf.
    final String htmlContent = this.templateEngine.process("email-inlineimage.html", ctx);
    message.setText(htmlContent, true); // true = isHtml

    // Agregue la imagen en línea, referenciada desde el código HTML como "cid:${imageResourceName}".
    final InputStreamSource imageSource = new ByteArrayResource(imageBytes);
    message.addInline(imageResourceName, imageSource, imageContentType);

    // Enviar correo
    this.mailSender.send(mimeMessage);

}
```

Tenga en cuenta que hemos utilizado un objeto
`org.springframework.core.io.ByteArrayResource` para adjuntar la
imagen subida por el usuario, que previamente convertimos en un
`byte[]`.

También puedes usar `FileSystemResource` para adjuntar un archivo directamente 
desde el sistema de archivos ---evitando así cargarlo en la memoria--- o 
`UrlResource` para adjuntar un archivo remoto.

### El controlador

Ahora veamos el método del controlador que llama a nuestro servicio:

```java
/*
* Enviar correo HTML con imagen en línea
*/
@RequestMapping(value = "/sendMailWithInlineImage", method = RequestMethod.POST)
public String sendMailWithInline(
  @RequestParam("recipientName") final String recipientName,
  @RequestParam("recipientEmail") final String recipientEmail,
  @RequestParam("image") final MultipartFile image,
  final Locale locale)
  throws MessagingException, IOException {

    this.emailService.sendMailWithInline(
        recipientName, recipientEmail, image.getName(),
        image.getBytes(), image.getContentType(), locale);
    return "redirect:sent.html";

}
```

Es sumamente sencillo. Observa cómo utilizamos un objeto `MultipartFile` de 
Spring MVC para modelar el archivo subido y pasar su contenido al servicio.


Más ejemplos
-------------

Para mayor brevedad, solo hemos detallado uno de los cinco tipos de correo 
electrónico que nuestra aplicación puede enviar. Sin embargo, puede consultar el 
código fuente necesario para crear los cinco tipos de correo electrónico en la 
aplicación de ejemplo `springmail`, que puede descargar desde la [página de 
documentación](/docs/documentation.html).
