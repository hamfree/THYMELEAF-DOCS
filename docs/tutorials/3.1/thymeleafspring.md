---
title: 'Tutorial: Thymeleaf + Spring'
author: Thymeleaf
version: @documentVersion@
thymeleafVersion: @projectVersion@
---




Prólogo
=======

Este tutorial explica cómo Thymeleaf puede integrarse con Spring Framework, 
especialmente (pero no solo) Spring MVC.

Tenga en cuenta que Thymeleaf tiene integraciones para ambas versiones 5.x como 
de la versión 6.x de Spring Framework, proporcionadas por dos bibliotecas 
separadas llamadas `thymeleaf-spring5` y `thymeleaf-spring6`. Estas librerías 
son empaquetadas en ficheros '.jar' llamados `thymeleaf-spring5-{version}.jar` y 
`thymeleaf-spring6-{version}.jar'` y necesitan agregarse a su classpath para 
utilizar las integraciones de Thymeleaf con Spring en su aplicación.

Los ejemplos de código y la aplicación de ejemplo en este tutorial hacen uso de 
 **Spring 6.x** y sus integraciones de Thymeleaf correspondientes, pero 
los contenidos de este texto son válidos también para Spring 5.x. Si su aplicación 
usa Spring 5.x, todo lo que debe hacer es reemplazar el paquete 
`org.thymeleaf.spring6` con `org.thymeleaf.spring5` en los ejemplos de código.


1 Integrando Thymeleaf con Spring
=================================

Thymeleaf ofrece un conjunto de integraciones con Spring que le permiten usarlas 
como un sustituto completo de JSP en aplicaciones Spring MVC.

Estas integraciones le permitirán a usted:
 * Realizar los mapeados de los métodos en sus objetos `@Controller` de 
   Spring MVC hacia las vistas gestionadas por Thymeleaf, exactamente como lo 
   haría con JSPs.
 * Usar el **Lenguaje de Exprexión Spring** (Spring EL) en vez de OGNL en sus 
   plantillas.
 * Crear formularios en sus plantillas que están completamente integrados con sus
   beans de respaldo de formulario y resultados enlazados, incluido el uso de 
   editores de propiedades, servicios de conversión y manejo de errores de 
   validación.  
 * Visualizar mensajes de internacionalización de los archivos de mensajes 
   administrados por Spring  (a través de los objetos `MessageSource` usuales).
 * Resuelva sus plantillas utilizando los mecanismos de resolución propios de 
   Spring.  

Tenga en cuenta que para comprender completamente este tutorial, primero debe 
haber realizado el tutorial _"Uso de Thymeleaf"_, que explica el dialecto 
estándar en profundidad.


2 El Dialecto SpringStandard
============================
Para lograr una integración más fácil y mejor, Thymeleaf proporciona 
un dialecto que implementa específicamente todas las características necesarias 
para que funcione correctamente con Spring.

Este dialecto específico se basa en el Dialecto Estándar de Thymeleaf y se 
implementa en una clase llamada `org.thymeleaf.spring6.dialect.SpringStandardDialect`,
que en realidad extiende a `org.thymeleaf.standard.StandardDialect`.

Además de todas las características ya presentes en el dialecto estándar 
--y por lo tanto heredadas--, el dialecto SpringStandard introduce las siguientes 
características específicas:

 * Usar el Lenguaje de Expresión de Spring (Spring EL o SpEL) como un lenguaje 
   de expresión variable, en vez de OGNL. Consecuentemente, todas las expresiones
   `${...}` y `*{...}` serán evaluadas por el Motor de Expresiones de Spring.
   Tenga en cuenta que el soporte para el compilador de Spring EL está disponible.
 * Acceder a cualquier bean en su contexto de aplicación usando la sintaxis de 
   SpringEL: `${@myBean.doSomething()}`
 * Nuevos atributos para el procesador de formularios: `th:field`, `th:errors` y 
  `th:errorclass`, además de una nueva implementación de `th:object` que permite 
  su uso para la selección de comandos de formulario.
 * Un objeto y método de expresión, `#themes.code(...)`, que es equivalente a la 
   etiqueta JSP personalizada `spring:theme`.
  * Un objeto y método de expresión, `#mvc.uri(...)`, que es equivalente a la 
    función personalizada JSP `spring:mvcUrl(...)`.

Dese cuenta que la mayoría de las veces _no debería estar usando este dialecto 
directamente en un objeto normal `TemplateEngine`_ como parte de su configuración.
A menos de que tenga unas necesidades de integración con Spring muy específicas,
debería crear una instancia de una nueva clase de motor de plantillas que realice 
todas lasautomáticamente todos los pasos de configuración necesarios: 
`org.thymeleaf.spring6.SpringTemplateEngine`.

Un ejemplo de la configuración de un bean:

```java
@Bean
public SpringResourceTemplateResolver templateResolver(){
    // SpringResourceTemplateResolver se integra automáticamente con la propia 
    // infraestructura de resolución de recursos de Spring, que está altamente 
    // recomendado.
    SpringResourceTemplateResolver templateResolver = new SpringResourceTemplateResolver();
    templateResolver.setApplicationContext(this.applicationContext);
    templateResolver.setPrefix("/WEB-INF/templates/");
    templateResolver.setSuffix(".html");
    // HTML es el valor por defecto, agregado aquí solo por claridad.
    templateResolver.setTemplateMode(TemplateMode.HTML);
    // La cache de las plantillas está activada por defecto. Establézcala a falso
    // si quiere que las plantillas se actualicen automáticamente cuando se modifiquen.
    templateResolver.setCacheable(true);
    return templateResolver;
}

@Bean
public SpringTemplateEngine templateEngine(){
    // SpringTemplateEngine aplica automáticamente SpringStandardDialect y 
    // habilita los mecanismos de resolución de mensajes MessageSource de Spring.
    SpringTemplateEngine templateEngine = new SpringTemplateEngine();
    templateEngine.setTemplateResolver(templateResolver());
    // Habilitar el compilador SpringEL con Spring 4.2.4 o posterior puede 
    // acelerar la ejecución en la mayoría de los casos, pero podría ser 
    // incompatible con casos específicos en los que se reutilizan expresiones 
    // de una plantilla en diferentes tipos de datos. Por lo tanto, este 
    // flag indicador es "falso" por defecto para una compatibilidad con 
    // versiones anteriores más segura.
    templateEngine.setEnableSpringELCompiler(true);
    return templateEngine;
}
```

O, usando la configuración basada en XML de  Spring:

```xml
<!-- SpringResourceTemplateResolver se integra automáticamente con la propia   -->
<!-- infraestructura de resolución de recursos de Spring, que está altamente   -->
<!-- recomendado.                                                              -->
<bean id="templateResolver"
       class="org.thymeleaf.spring6.templateresolver.SpringResourceTemplateResolver">
  <property name="prefix" value="/WEB-INF/templates/" />
  <property name="suffix" value=".html" />
  <!-- HTML es el valor por defecto, agregado aquí solo por claridad.          -->
  <property name="templateMode" value="HTML" />
  <!-- La cache de las plantillas está activada por defecto. Establézcala a    -->
  <!-- falso si quiere que las plantillas se actualicen automáticamente        -->
  <!-- cuando se modifiquen.                                                   -->
  <property name="cacheable" value="true" />
</bean>
    
<!-- SpringTemplateEngine aplica automáticamente SpringStandardDialect y        -->
<!-- habilita los mecanismos de resolución de mensajes MessageSource de Spring. -->
<bean id="templateEngine"
      class="org.thymeleaf.spring6.SpringTemplateEngine">
  <property name="templateResolver" ref="templateResolver" />
  <!-- Habilitar el compilador SpringEL con Spring 4.2.4 o posterior puede     -->
  <!-- acelerar la ejecución en la mayoría de los casos, pero podría ser       -->
  <!-- incompatible con casos específicos en los que se reutilizan expresiones -->
  <!-- de una plantilla en diferentes tipos de datos. Por lo tanto, este       -->
  <!-- flag indicador es "falso" por defecto para una compatibilidad con       -->
  <!-- versiones anteriores más segura.                                        -->
  <property name="enableSpringELCompiler" value="true" />
</bean>
```



3 Vistas y Solucionadores de Vistas
===================================



3.1 Vistas y solucionadores de vistas en Spring MVC
---------------------------------------------------

Hay dos interfaces en Spring MVC que componen el núcloe de su sistema de 
plantillas:

 * `org.springframework.web.servlet.View`
 * `org.springframework.web.servlet.ViewResolver`

Las vistas modelan las páginas en nuestras aplicaciones y nos permiten modificar
y predefinir su comportamiento definiéndolas como beans. Las vistas se encargan 
de renderizar la interfaz HTML real, generalmente mediante la ejecución de algún
motor de plantillas como Thymeleaf.

Los ViewResolvers son los objetos a cargo de obtener los objetos View para una 
operación específica y la regionalización. Típicamente, los controladores piden 
a los ViewResolvers redirigir a una vista con un nombre específico (una String 
devuelta por el método controlador), y luego todos los ViewResolvers, en la 
aplicación se ejecutan en una cadena ordenada hasta que uno de ellos es capaz 
de resolver esa vista, en cuyo caso se devuelve un objeto View y se le pasa el 
control para la renderización del HTML.

> Dese cuenta de que no todas las páginas en nuestras aplicaciones tienen que 
> estar definidas como Vistas, sino solo aquellas cuyo comportamiento deseamos
> que no sea estándar o estar configuradas de una manera específica (por ejemplo, 
> asociándolas con algunos beans especiales). Si se le pide a un ViewResolver una 
> vista que no tiene su bean correspondiente --lo que es el caso más habitual--, 
> se crea una nuevo objeto View ad hoc y se devuelve.

Una configuración típica para un ViewResolver JSP+JSTL en una aplicación Spring 
MVC del pasado se parecería a esto:

```xml
<bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
  <property name="viewClass" value="org.springframework.web.servlet.view.JstlView" />
  <property name="prefix" value="/WEB-INF/jsps/" />
  <property name="suffix" value=".jsp" />
  <property name="order" value="2" />
  <property name="viewNames" value="*jsp" />
</bean>
```

Un vistazo rápido a sus propiedades es suficiente para saber cómo está configurado:

 * `viewClass` establece la clase de las instancias View. Esto lo  necesita un 
   solucionador JSP, pero no será necesario cuando trabajemos con Thymeleaf.
 * `prefix` y `suffix` trabajan de forma similar a los atributos con los mismos
   nombres en los objetos del TemplateResolver de Thymeleaf.
 * `order` establece el orden en el cual el ViewResolver se consultará en la 
   cadena de solucionadores.
 * `viewNames` permite la definición (con comodines) de los nombres de vista que
   serán resueltos por este ViewResolver.



3.2 Vistas y solucionadores de vistas en Thymeleaf
-------------------------------------------------

Thymeleaf ofrece implementaciones para las dos interfaces mencionadas arriba:

 * `org.thymeleaf.spring6.view.ThymeleafView`
 * `org.thymeleaf.spring6.view.ThymeleafViewResolver`

Estas dos clases estarán a cargo de procesar las plantillas de Thymeleaf como 
resultado de la ejecución de los controladores.

La configuración de un Solucionador de Vistas de Thymeleaf es muy similar a la 
de JSP:


```java
@Bean
public ThymeleafViewResolver viewResolver(){
    ThymeleafViewResolver viewResolver = new ThymeleafViewResolver();
    viewResolver.setTemplateEngine(templateEngine());
    // NOTA 'order' y 'viewNames' son opcionales
    viewResolver.setOrder(1);
    viewResolver.setViewNames(new String[] {".html", ".xhtml"});
    return viewResolver;
}
```

...o en XML:

```xml
<bean class="org.thymeleaf.spring6.view.ThymeleafViewResolver">
  <property name="templateEngine" ref="templateEngine" />
  <!-- NOTA 'order' y 'viewNames' son opcionales -->
  <property name="order" value="1" />
  <property name="viewNames" value="*.html,*.xhtml" />
</bean>
```

El parámetro `templateEngine` es, por supuesto, el objeto `SpringTemplateEngine`
que definimos en el capítulo previo. Los otros dos (`order` y `viewNames`) son 
ambos opcionales, y tienen el mismo significado que en el ViewResolver de JSP 
que vimos antes.

Dese cuenta que no necesitamos los parámetros `prefix` o `suffix`, porque estos 
están ya especificados en el Solucionador de Plantillas (el cual a su vez se pasa 
al Motor de Plantillas).

¿Y si quisiéramos definir un bean "View" y añadirle variables estáticas? Fácil, 
simplemente definamos un bean *prototipo* para él:

```java
@Bean
@Scope("prototype")
public ThymeleafView mainView() {
    ThymeleafView view = new ThymeleafView("main"); // templateName = 'main'
    view.setStaticVariables(
        Collections.singletonMap("footer", "La Compañía de Frutas  ACME"));
    return view;
}
```

Al hacer esto, será capaz de ejecutar específicamente esta vista de bean 
seleccionándiola por su nombre de bean (`mainView`, en este caso).



4 Gestor Iniciador de Semillas de Romero de Spring
==================================================

El código fuente para los ejemplos mostrados en este y futuros capítulos de esta 
guía se encuentran en la aplicación de ejemplo 
_Spring Thyme Seed Starter Manager (STSM)_: 


   * [Spring 5 STSM](https://github.com/thymeleaf/thymeleaf/tree/3.1-master/examples/spring5/thymeleaf-examples-spring5-stsm).
   * [Spring 6 STSM](https://github.com/thymeleaf/thymeleaf/tree/3.1-master/examples/spring6/thymeleaf-examples-spring6-stsm).


4.1 El Concepto
---------------

En Thymeleaf somos grandes aficionados al tomillo, y cada primavera preparamos 
nuestros kits de germinación de semillas con buena tierra y nuestras semillas 
favoritas, colocándolas bajo el sol español y esperando pacientemente a que 
nuestras nuevas plantas crezcan.

Pero este año nos cansamos de pegar etiquetas a los compartimentos de germinación 
de semillas para saber qué semilla había en cada compartimento, así que 
decidimos crear una aplicación con Spring MVC y Thymeleaf para catalogar 
nuestros semilleros: _The Spring Thyme SeedStarter Manager_.

![STSM página inicial](images/thymeleafspring/stsm-view.png)

De similar forma a la aplicación Good Thymes Virtual Grocery que desarrollamos 
en el tutorial _Usando Thymeleaf_, STSM nos permitirá ejemplificar los aspectos
más importantes de la integración de Thymeleaf como motor de plantillas para 
Spring MVC.



4.2 Capa de Negocio
------------------

Necesitaremos una capa de negocio muy simple para nuestra aplicación. En primer 
lugar, echemos un vistazo a nuestras entidades de modelo:

![Modelo de STSM](images/thymeleafspring/stsm-model.png)

Un par de clases de servicio muy simples proporcionarán los métodos de negocio 
requeridos. Como: 

```java
@Service
public class SeedStarterService {

    @Autowired
    private SeedStarterRepository seedstarterRepository; 

    public List<SeedStarter> findAll() {
        return this.seedstarterRepository.findAll();
    }

    public void add(final SeedStarter seedStarter) {
        this.seedstarterRepository.add(seedStarter);
    }

}
```

Y:

```java
@Service
public class VarietyService {

    @Autowired
    private VarietyRepository varietyRepository; 

    public List<Variety> findAll() {
        return this.varietyRepository.findAll();
    }

    public Variety findById(final Integer id) {
        return this.varietyRepository.findById(id);
    }

}
```



4.3 Configuración de Spring MVC
----------------------------

Lo siguiente que necesitamos es establecer la configuración de Spring MVC para 
la aplicación, lo que incluirá no solo los artefactos estándar de Spring MVC 
como la gestión de recursos o el análisis de anotaciones, sino también la 
creación de las instancias del Motor de Plantillas (Template Engine) y del 
Solucionador de Vistas (View Resolver).

```java
@Configuration
@EnableWebMvc
@ComponentScan
public class SpringWebConfig
        extends WebMvcConfigurerAdapter implements ApplicationContextAware {

    private ApplicationContext applicationContext;


    public SpringWebConfig() {
        super();
    }


    public void setApplicationContext(final ApplicationContext applicationContext)
            throws BeansException {
        this.applicationContext = applicationContext;
    }



    /* ******************************************************************* */
    /*  ARTEFACTOS DE CONFIGURACIÓN GENERALES                              */
    /*  Recursos estáticiso, mensajes i18n, formateadores (Servicio de     */
    /*  de conversión)                                                     */
    /* ******************************************************************* */

    @Override
    public void addResourceHandlers(final ResourceHandlerRegistry registry) {
        super.addResourceHandlers(registry);
        registry.addResourceHandler("/images/**").addResourceLocations("/images/");
        registry.addResourceHandler("/css/**").addResourceLocations("/css/");
        registry.addResourceHandler("/js/**").addResourceLocations("/js/");
    }

    @Bean
    public ResourceBundleMessageSource messageSource() {
        ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
        messageSource.setBasename("Messages");
        return messageSource;
    }

    @Override
    public void addFormatters(final FormatterRegistry registry) {
        super.addFormatters(registry);
        registry.addFormatter(varietyFormatter());
        registry.addFormatter(dateFormatter());
    }

    @Bean
    public VarietyFormatter varietyFormatter() {
        return new VarietyFormatter();
    }

    @Bean
    public DateFormatter dateFormatter() {
        return new DateFormatter();
    }



    /* **************************************************************** */
    /* ARTEFACTOS ESPECÍFICOS DE THYMELEAF                              */
    /*  TemplateResolver <- TemplateEngine <- ViewResolver              */
    /* **************************************************************** */

    @Bean
    public SpringResourceTemplateResolver templateResolver(){
        // SpringResourceTemplateResolver se integra automáticamente con la 
        // infraestructura de resolución de recursos propia de Spring, lo cual 
        // es altamente recomendable.
        SpringResourceTemplateResolver templateResolver = new SpringResourceTemplateResolver();
        templateResolver.setApplicationContext(this.applicationContext);
        templateResolver.setPrefix("/WEB-INF/templates/");
        templateResolver.setSuffix(".html");
        // HTML es el valor por defecto, agregado aquí solo por claridad.
        templateResolver.setTemplateMode(TemplateMode.HTML);
        // La cache de las plantillas está activada por defecto. Establézcala a 
        // falso si quiere que las plantillas se actualicen automáticamente cuando 
        // se modifiquen.
        templateResolver.setCacheable(true);
        return templateResolver;
    }

    @Bean
    public SpringTemplateEngine templateEngine(){
        // SpringTemplateEngine aplica automáticamente SpringStandardDialect y 
        // habilita los mecanismos de resolución de mensajes MessageSource de Spring.
        SpringTemplateEngine templateEngine = new SpringTemplateEngine();
        templateEngine.setTemplateResolver(templateResolver());
        // Habilitar el compilador SpringEL con Spring 4.2.4 o posterior 
        // puede acelerar la ejecución en la mayoría de los casos, pero podría ser 
        // incompatible con casos específicos en los que se reutilizan expresiones 
        // de una plantilla en diferentes tipos de datos. Por lo tanto, este 
        // flag indicador es "falso" por defecto para una compatibilidad con 
        // versiones anteriores más segura.
        templateEngine.setEnableSpringELCompiler(true);
        return templateEngine;
    }

    @Bean
    public ThymeleafViewResolver viewResolver(){
        ThymeleafViewResolver viewResolver = new ThymeleafViewResolver();
        viewResolver.setTemplateEngine(templateEngine());
        return viewResolver;
    }

}
```



4.4 El Controlador
------------------

Por supuesto, también necesitaremos un controlador para nuestra aplicación. Como 
STSM solo contendrá una página web con una lista de germinadores de semillas y 
un formulario para agregar nuevos, escribiremos solo una clase controladora 
para todas las interacciones del servidor:

```java
@Controller
public class SeedStarterMngController {

    @Autowired
    private VarietyService varietyService;
    
    @Autowired
    private SeedStarterService seedStarterService;

    ...

}
```

Ahora veamos que podemos agregar a esta clase controladora.


### Atributos del Modelo

Lo primero que agregaremos son algunos atributos del modelo que necesitaremos 
en la página:

```java
@ModelAttribute("allTypes")
public List<Type> populateTypes() {
    return Arrays.asList(Type.ALL);
}
    
@ModelAttribute("allFeatures")
public List<Feature> populateFeatures() {
    return Arrays.asList(Feature.ALL);
}
    
@ModelAttribute("allVarieties")
public List<Variety> populateVarieties() {
    return this.varietyService.findAll();
}
    
@ModelAttribute("allSeedStarters")
public List<SeedStarter> populateSeedStarters() {
    return this.seedStarterService.findAll();
}
```


### Métodos mapeados

Y ahora la parte más importante de un controlador, los métodos mapeados: uno 
para mostrar la página del formulario, y otro para procesar la agregación de 
nuevos objetos `SeedStarter`.

```java
@RequestMapping({"/","/seedstartermng"})
public String showSeedstarters(final SeedStarter seedStarter) {
    seedStarter.setDatePlanted(Calendar.getInstance().getTime());
    return "seedstartermng";
}

@RequestMapping(value="/seedstartermng", params={"save"})
public String saveSeedstarter(
        final SeedStarter seedStarter, final BindingResult bindingResult, final ModelMap model) {
    if (bindingResult.hasErrors()) {
        return "seedstartermng";
    }
    this.seedStarterService.add(seedStarter);
    model.clear();
    return "redirect:/seedstartermng";
}
```



4.5 Configuración de un Servicio de Conversión
----------------------------------------------

Para facilitar el formato de los objetos `Date` y `Variety` en nuestra capa de 
vista, configuramos nuestra aplicación para que se creara e inicializara un 
objeto `ConversionService` de Spring (mediante el `WebMvcConfigurerAdapter` que 
extendemos) con un par de objetos de formato que necesitaremos. Véase de nuevo:

```java
@Override
public void addFormatters(final FormatterRegistry registry) {
    super.addFormatters(registry);
    registry.addFormatter(varietyFormatter());
    registry.addFormatter(dateFormatter());
}

@Bean
public VarietyFormatter varietyFormatter() {
    return new VarietyFormatter();
}

@Bean
public DateFormatter dateFormatter() {
    return new DateFormatter();
}
```

Los *formateadores* de Spring son implementaciones de la interfaz 
`org.springframework.format.Formatter`. Para obtener más información de cómo 
trabaja la infraestructura de conversión de Spring, vea los documentos en  
[spring.io](http://docs.spring.io/spring/docs/4.3.x/spring-framework-reference/html/validation.html#core-convert).

Echemos un vistaz a `DateFormatter`, que da formato a fechas de acuerdo a la 
cadena de formato presente en la clave de mensaje `date.format` de nuestro 
`Messages.properties`:

```java
public class DateFormatter implements Formatter<Date> {

    @Autowired
    private MessageSource messageSource;


    public DateFormatter() {
        super();
    }

    public Date parse(final String text, final Locale locale) throws ParseException {
        final SimpleDateFormat dateFormat = createDateFormat(locale);
        return dateFormat.parse(text);
    }

    public String print(final Date object, final Locale locale) {
        final SimpleDateFormat dateFormat = createDateFormat(locale);
        return dateFormat.format(object);
    }

    private SimpleDateFormat createDateFormat(final Locale locale) {
        final String format = this.messageSource.getMessage("date.format", null, locale);
        final SimpleDateFormat dateFormat = new SimpleDateFormat(format);
        dateFormat.setLenient(false);
        return dateFormat;
    }

}
```

La clase `VarietyFormatter` automáticamente convierte entre nuestras entidades
`Variety` y la forma en que queremos usarlas en nuestros formularios 
(básicamente, por sus valores del campo `id`):

```java
public class VarietyFormatter implements Formatter<Variety> {

    @Autowired
    private VarietyService varietyService;


    public VarietyFormatter() {
        super();
    }

    public Variety parse(final String text, final Locale locale) throws ParseException {
        final Integer varietyId = Integer.valueOf(text);
        return this.varietyService.findById(varietyId);
    }


    public String print(final Variety object, final Locale locale) {
        return (object != null ? object.getId().toString() : "");
    }

}
```
Más adelante aprenderemos más de cómo estos formateadores afectan la forma en 
que nuestros datos se muestran. 




5 Listado de Datos de Inicio de Semillas
=======================================

La primera cosa que nuestra página `/WEB-INF/templates/seedstartermng.html` 
mostrará es un listado con los semilleros de iniciación actualmente almacenados. 
Para estos necesitaremos algunos mensajes externalizados y también alguna 
evaluación de expresiones sobre los atributos del modelo.
Como esto:

```html
<div class="seedstarterlist" th:unless="${#lists.isEmpty(allSeedStarters)}">
    
  <h2 th:text="#{title.list}">Lista de semilleros</h2>
  
  <table>
    <thead>
      <tr>
        <th th:text="#{seedstarter.datePlanted}">Fecha de siembra</th>
        <th th:text="#{seedstarter.covered}">Cubierta</th>
        <th th:text="#{seedstarter.type}">Tipo</th>
        <th th:text="#{seedstarter.features}">Características</th>
        <th th:text="#{seedstarter.rows}">Filas</th>
      </tr>
    </thead>
    <tbody>
      <tr th:each="sb : ${allSeedStarters}">
        <td th:text="${{sb.datePlanted}}">13/01/2011</td>
        <td th:text="#{|bool.${sb.covered}|}">sí</td>
        <td th:text="#{|seedstarter.type.${sb.type}|}">Estructura alámbrica</td>
        <td th:text="${#strings.arrayJoin(
                           #messages.arrayMsg(
                               #strings.arrayPrepend(sb.features,'seedstarter.feature.')),
                           ', ')}">Calefacción Eléctrica, Césped</td>
        <td>
          <table>
            <tbody>
              <tr th:each="row,rowStat : ${sb.rows}">
                <td th:text="${rowStat.count}">1</td>
                <td th:text="${row.variety.name}">Thymus Thymi</td>
                <td th:text="${row.seedsPerCell}">12</td>
              </tr>
            </tbody>
          </table>
        </td>
      </tr>
    </tbody>
  </table>
</div>
```

Hay mucho que ver aquí. Analicemos cada fragmento por separado.

En primer lugar, esta sección solo se mostrará si hay algún iniciador de 
semillas. Logramos esto con un atributo th:unless y la función 
`#lists.isEmpty(...)`.

```html
<div class="seedstarterlist" th:unless="${#lists.isEmpty(allSeedStarters)}">
```

Tenga en cuenta que todos los objetos de utilidad como `#lists` están disponibles 
en las expresiones de Spring EL, al igual que en las expresiones OGNL del 
dialecto estándar.

Lo siguiente que veremos son muchos textos internacionalizados (externalizados), 
como:

```html
<h2 th:text="#{title.list}">Lista de semilleros</h2>

<table>
  <thead>
    <tr>
      <th th:text="#{seedstarter.datePlanted}">Fecha de siembra</th>
      <th th:text="#{seedstarter.covered}">Cubierta</th>
      <th th:text="#{seedstarter.type}">Tipo</th>
      <th th:text="#{seedstarter.features}">Características</th>
      <th th:text="#{seedstarter.rows}">Filas</th>
      ...
```

Al tratarse de una aplicación Spring MVC, ya hemos definido un bean 
de tipo `MessageSource` en nuestra configuración de Spring (los objetos 
`MessageSource` son la forma estándar de gestionar los textos externos en Spring 
MVC):

```java
@Bean
public ResourceBundleMessageSource messageSource() {
    ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
    messageSource.setBasename("Messages");
    return messageSource;
}
```

...y esa propiedad `basename` indica que tendremos archivos como 
`Messages_es.properties` o `Messages_en.properties` en nuestro classpath. Veamos 
la versión en español:

```properties
title.list=Lista de semilleros

date.format=dd/MM/yyyy
bool.true=sí
bool.false=no

seedstarter.datePlanted=Fecha de plantación
seedstarter.covered=Cubierto
seedstarter.type=Tipo
seedstarter.features=Características
seedstarter.rows=Filas

seedstarter.type.WOOD=Madera
seedstarter.type.PLASTIC=Plástico

seedstarter.feature.SEEDSTARTER_SPECIFIC_SUBSTRATE=Sustrato específico para semilleros
seedstarter.feature.FERTILIZER=Fertilizante
seedstarter.feature.PH_CORRECTOR=Corrector de PH
```

En la primera columna de la tabla mostraremos la fecha en que se preparó el 
cultivo inicial. Sin embargo, **la mostraremos formateada** según lo definido en
nuestro `DateFormatter`. Para ello, utilizaremos la sintaxis de doble llave 
(`${{...}}`), que aplicará automáticamente el Servicio de Conversión de Spring, 
incluyendo el `DateFormatter` que registramos en la configuración.

```html
<td th:text="${{sb.datePlanted}}">13/01/2011</td>
```
A continuación se muestra si el recipiente de inicio de semillas está cubierto 
o no, transformando el valor de la propiedad booleana "bean coverd" en un "sí" 
o "no" internacionalizado con una expresión de sustitución literal:

```html
<td th:text="#{|bool.${sb.covered}|}">sí</td>
```
Ahora tenemos que mostrar el tipo de contenedor de semillas. El tipo es una 
enumeración de Java con dos valores (`WOOD` y `PLASTIC`), y por eso definimos 
dos propiedades en nuestro archivo `Messages` llamadas `seedstarter.type.WOOD` 
y `seedstarter.type.PLASTIC`.

Pero para obtener los nombres internacionalizados de los tipos, necesitaremos 
agregar el prefijo `seedstarter.type.` al valor de la enumeración mediante una 
expresión, cuyo resultado utilizaremos luego como clave del mensaje:


```html
<td th:text="#{|seedstarter.type.${sb.type}|}">Estructura alámbrica</td>
```
La parte más difícil de este listado es la columna _features_. En ella queremos 
mostrar todas las características de nuestro contenedor —--que vienen en forma de 
un array de enumeraciones `Feature`--—, separadas por comas. Por ejemplo: 
_"Calefacción Eléctrica, Césped"_.

Tenga en cuenta que esto es particularmente difícil porque estos valores de 
enumeración también deben externalizarse, como hicimos con los tipos. El flujo 
es entonces:

1. Anteponga el prefijo correspondiente a todos los elementos del array 
`features`.
2. Obtenga los mensajes externalizados correspondientes a todas las claves del 
paso 1.
3. Una todos los mensajes obtenidos en el paso 2, utilizando una coma como 
delimitador.

Para lograr esto, creamos el siguiente código:

```html
<td th:text="${#strings.arrayJoin(
                   #messages.arrayMsg(
                       #strings.arrayPrepend(sb.features,'seedstarter.feature.')),
                   ', ')}">Calefacción Eléctrica, Césped</td>
```
La última columna de nuestra lista será bastante simple, de hecho. Incluso si 
tiene una tabla anidada para mostrar el contenido de cada fila en el contenedor:

```html
<td>
  <table>
    <tbody>
      <tr th:each="row,rowStat : ${sb.rows}">
        <td th:text="${rowStat.count}">1</td>
        <td th:text="${row.variety.name}">Thymus Thymi</td>
        <td th:text="${row.seedsPerCell}">12</td>
      </tr>
    </tbody>
  </table>
</td>
```




6 Crear un Formulario
=====================



6.1 Manejo del objeto de comando (Command Object)
-------------------------------------------------

El _objeto de comando_ es el nombre que Spring MVC da a los beans de respaldo de 
los formularios; es decir, a los objetos que modelan los campos de un formulario 
y proporcionan métodos getter y setter que el framework utilizará para establecer 
y obtener los valores introducidos por el usuario en el navegador.

Thymeleaf requiere que especifique el objeto de comando mediante el atributo 
`th:object` en su etiqueta `<form>`:

```html
<form action="#" th:action="@{/seedstartermng}" th:object="${seedStarter}" method="post">
    ...
</form>
```

Esto es coherente con otros usos de `th:object`, pero de hecho, este escenario 
específico añade algunas limitaciones para integrarse correctamente con la 
infraestructura de Spring MVC:

 * Los valores para los atributos `th:object` en las etiquetas de formulario 
   deben ser expresiones variables (`${...}`) que especifiquen únicamente el
   nombre de un atributo del modelo, sin navegación de propiedades. Esto 
   significa que una expresión como `${seedStarter}` es válida, pero 
   `${seedStarter.data}` no lo sería.

 * Una vez dentro de la etiqueta `<form>`, no se puede especificar ningún otro 
   atributo `th:object`. Esto es coherente con el hecho de que los formularios 
   HTML no se pueden anidar.



6.2 Entradas
----------

Veamos ahora cómo agregar un campo de entrada a nuestro formulario:

```html
<input type="text" th:field="*{datePlanted}" />
```
Como puede ver, aquí introducimos un nuevo atributo: `th:field`. Esta es una 
muy característica muy importante para la integración con Spring MVC, ya que se 
encarga de todo el trabajo pesado de vincular su entrada con una propiedad en el 
bean de respaldo del formulario. Puede considerarse equivalente al atributo 
`path` en una etiqueta `<form:input>` de la biblioteca de etiquetas JSP de Spring 
MVC.

El atributo `th:field` se comporta de manera diferente según si está asociado a 
una etiqueta `<input>`, `<select>` o `<textarea>` (y también según el tipo 
específico de etiqueta `<input>`). En este caso (`input[type=text]`), la línea 
de código anterior es similar a:

```html
<input type="text" id="datePlanted" name="datePlanted" th:value="*{datePlanted}" />
```
...pero en realidad es algo más que eso, porque `th:field` también aplicará el 
Servicio de Conversión de Spring registrado, incluido el `DateFormatter` que 
vimos anteriormente (incluso si la expresión del campo no está entre corchetes 
dobles). Gracias a esto, la fecha se mostrará con el formato correcto.

Los valores para los atributos `th:field` deben ser expresiones de selección 
(`*{...}`), lo cual tiene sentido dado que se evaluarán en el bean que respalda 
el formulario y no en las variables de contexto (o atributos del modelo en la 
jerga de Spring MVC).

A diferencia de las que se encuentran en `th:object`, estas expresiones pueden 
incluir la navegación de propiedades (de hecho, cualquier expresión permitida 
para el atributo path de una etiqueta JSP `<form:input>` estará permitida aquí).

Tenga en cuenta que `th:field` también reconoce los nuevos tipos de elementos 
HTML`<input>` introducidos por HTML5, como `<input type="datetime" ... />`, 
`<input type="color" ... />`, etc., lo que añade compatibilidad total con HTML5 
a Spring MVC.



6.3 Campos de Casilla de Verificación
-------------------------------------

`th:field` también nos permite definir campos de entrada de casilla de 
verificación. Veamos un ejemplo de nuestra página HTML:

```html
<div>
  <label th:for="${#ids.next('covered')}" th:text="#{seedstarter.covered}">Cubierta</label>
  <input type="checkbox" th:field="*{covered}" />
</div>
```
Cabe destacar que, además de la casilla de verificación en sí, hay otros 
elementos interesantes, como una etiqueta externa y el uso de la función 
`#ids.next('covered')` para obtener el valor que se aplicará al atributo `id` 
del campo de entrada de la casilla de verificación.

¿Por qué necesitamos esta generación dinámica de un atributo id para este campo? 
Porque las casillas de verificación pueden tener múltiples valores y, por lo 
tanto, sus valores id siempre tendrán un sufijo de número de secuencia (mediante 
el uso interno de la función `#ids.seq(...)`) para garantizar que cada una de 
las entradas de casilla de verificación para la misma propiedad tenga un valor 
id diferente.

Podemos verlo más fácilmente si observamos un campo de casilla de verificación 
con múltiples valores:

```html
<ul>
  <li th:each="feat : ${allFeatures}">
    <input type="checkbox" th:field="*{features}" th:value="${feat}" />
    <label th:for="${#ids.prev('features')}" 
           th:text="#{${'seedstarter.feature.' + feat}}">Calefacción Eléctrica</label>
  </li>
</ul>
```

Tenga en cuenta que esta vez hemos añadido un atributo `th:value`, porque el 
campo features no es un valor booleano como lo era covered, sino que es una 
matriz de valores.

Veamos la salida HTML generada por este código:

```html
<ul>
  <li>
    <input id="features1" name="features" type="checkbox" value="SEEDSTARTER_SPECIFIC_SUBSTRATE" />
    <input name="_features" type="hidden" value="on" />
    <label for="features1">Sustrato específico para el cultivo de semillas</label>
  </li>
  <li>
    <input id="features2" name="features" type="checkbox" value="FERTILIZER" />
    <input name="_features" type="hidden" value="on" />
    <label for="features2">Fertilizante utilizado</label>
  </li>
  <li>
    <input id="features3" name="features" type="checkbox" value="PH_CORRECTOR" />
    <input name="_features" type="hidden" value="on" />
    <label for="features3">Corrector de pH utilizado</label>
  </li>
</ul>
```
Aquí podemos ver cómo se agrega un sufijo de secuencia al atributo id de cada 
entrada, y cómo la función `#ids.prev(...)` nos permite recuperar el último valor 
de secuencia generado para un id de entrada específico.

> No te preocupes por esos campos ocultos con `name="_features"`: se añaden 
> automáticamente para evitar problemas con los navegadores que no envían los 
> valores de las casillas de verificación sin marcar al servidor al enviar el 
> formulario.

> Don't worry about those hidden inputs with `name="_features"`: they are
> automatically added in order to avoid problems with browsers not sending
> unchecked checkbox values to the server upon form submission.

Tenga en cuenta también que si nuestra propiedad features contenía algunos 
valores seleccionados en nuestro bean de respaldo del formulario, `th:field` se 
habría encargado de eso y habría agregado un atributo `checked="checked"` a las 
etiquetas de entrada correspondientes.



6.4 Campos de Botón de Opción
-----------------------------

Los campos de botones de opción se especifican de forma similar a las casillas 
de verificación no booleanas (multivalor), excepto que, por supuesto, no son 
multivalor:

```html
<ul>
  <li th:each="ty : ${allTypes}">
    <input type="radio" th:field="*{type}" th:value="${ty}" />
    <label th:for="${#ids.prev('type')}" th:text="#{${'seedstarter.type.' + ty}}">Estructura alámbrica</label>
  </li>
</ul>
```



6.5 Selectores desplegables/de lista
------------------------------------

Los campos de selección constan de dos partes: la etiqueta `<select>` y sus etiquetas anidadas `<option>`.

Al crear este tipo de campo, solo la etiqueta `<select>` debe incluir el 
atributo `th:field`, pero los atributos `th:value` de las etiquetas anidadas 
`<option>` serán muy importantes, ya que permitirán saber cuál es la opción 
seleccionada (de forma similar a las casillas de verificación y los botones de 
opción no booleanos).

Vamos a reconstruir el campo de tipo como un menú desplegable:

```html
<select th:field="*{type}">
  <option th:each="type : ${allTypes}" 
          th:value="${type}" 
          th:text="#{${'seedstarter.type.' + type}}">Estructura alámbrica</option>
</select>
```

En este punto, entender este fragmento de código es bastante sencillo. Basta con 
observar cómo la precedencia de atributos nos permite establecer el atributo 
`th:each` en la propia etiqueta `<option>`.



6.6 Campos Dinámicos
--------------------

Gracias a las avanzadas capacidades de enlace de campos de formulario en Spring 
MVC, podemos usar expresiones EL complejas de Spring para enlazar campos de 
formulario dinámicos a nuestro bean de respaldo de formulario. Esto nos permitirá 
crear nuevos objetos Row en nuestro bean `SeedStarter` y agregar los campos de 
esas filas a nuestro formulario a petición del usuario. 

Para ello, necesitaremos un par de nuevos métodos mapeados en nuestro 
controlador, que agregarán o eliminarán una fila de nuestro `SeedStarter` 
dependiendo de la existencia de parámetros de solicitud específicos:

```java
@RequestMapping(value="/seedstartermng", params={"addRow"})
public String addRow(final SeedStarter seedStarter, final BindingResult bindingResult) {
    seedStarter.getRows().add(new Row());
    return "seedstartermng";
}

@RequestMapping(value="/seedstartermng", params={"removeRow"})
public String removeRow(
        final SeedStarter seedStarter, final BindingResult bindingResult, 
        final HttpServletRequest req) {
    final Integer rowId = Integer.valueOf(req.getParameter("removeRow"));
    seedStarter.getRows().remove(rowId.intValue());
    return "seedstartermng";
}
```

Y ahora podemos añadir una tabla dinámica a nuestro formulario:

```html
<table>
  <thead>
    <tr>
      <th th:text="#{seedstarter.rows.head.rownum}">Fila</th>
      <th th:text="#{seedstarter.rows.head.variety}">Variedad</th>
      <th th:text="#{seedstarter.rows.head.seedsPerCell}">Semillas por célula</th>
      <th>
        <button type="submit" name="addRow" th:text="#{seedstarter.row.add}">Agregar fila</button>
      </th>
    </tr>
  </thead>
  <tbody>
    <tr th:each="row,rowStat : *{rows}">
      <td th:text="${rowStat.count}">1</td>
      <td>
        <select th:field="*{rows[__${rowStat.index}__].variety}">
          <option th:each="var : ${allVarieties}" 
                  th:value="${var.id}" 
                  th:text="${var.name}">Thymus Thymi</option>
        </select>
      </td>
      <td>
        <input type="text" th:field="*{rows[__${rowStat.index}__].seedsPerCell}" />
      </td>
      <td>
        <button type="submit" name="removeRow" 
                th:value="${rowStat.index}" th:text="#{seedstarter.row.remove}">Eliminar fila</button>
      </td>
    </tr>
  </tbody>
</table>
```
Hay bastantes cosas que ver aquí, pero no mucho que no debamos entender a estas 
alturas... excepto por una cosa `extraña`:


```html
<select th:field="*{rows[__${rowStat.index}__].variety}">

    ...

</select>
```
Si recuerdas del tutorial _"Usando Thymeleaf"_, la sintaxis `__${...}__` es una 
expresión de preprocesamiento, que es una expresión interna que se evalúa antes 
de evaluar la expresión completa. Pero, ¿por qué esa forma de especificar el 
índice de fila? ¿No bastaría con:

```html
<select th:field="*{rows[rowStat.index].variety}">

    ...

</select>
```
Bueno, en realidad no. El problema es que Spring EL no evalúa las variables 
dentro de los corchetes de índice de array, por lo que al ejecutar la expresión 
anterior obtendríamos un error que nos indica que `rows[rowStat.index]` (en 
lugar de `rows[0]`, `rows[1]`, etc.) no es una posición válida en la colección 
de filas. Por eso es necesario el preprocesamiento.

Veamos un fragmento del HTML resultante después de pulsar _"Añadir fila"_ un par 
de veces:

```html
<tbody>
  <tr>
    <td>1</td>
    <td>
      <select id="rows0.variety" name="rows[0].variety">
        <option selected="selected" value="1">Thymus vulgaris</option>
        <option value="2">Thymus x citriodorus</option>
        <option value="3">Thymus herba-barona</option>
        <option value="4">Thymus pseudolaginosus</option>
        <option value="5">Thymus serpyllum</option>
      </select>
    </td>
    <td>
      <input id="rows0.seedsPerCell" name="rows[0].seedsPerCell" type="text" value="" />
    </td>
    <td>
      <button name="removeRow" type="submit" value="0">Eliminar fila</button>
    </td>
  </tr>
  <tr>
    <td>2</td>
    <td>
      <select id="rows1.variety" name="rows[1].variety">
        <option selected="selected" value="1">Thymus vulgaris</option>
        <option value="2">Thymus x citriodorus</option>
        <option value="3">Thymus herba-barona</option>
        <option value="4">Thymus pseudolaginosus</option>
        <option value="5">Thymus serpyllum</option>
      </select>
    </td>
    <td>
      <input id="rows1.seedsPerCell" name="rows[1].seedsPerCell" type="text" value="" />
    </td>
    <td>
      <button name="removeRow" type="submit" value="1">Eliminar fila</button>
    </td>
  </tr>
</tbody>
```




7 Validación y Mensajes de Error
================================

La mayoría de nuestros formularios deberán mostrar mensajes de validación para 
informar al usuario de los errores que haya cometido.

Thymeleaf ofrece algunas herramientas para ello: un par de funciones en el 
objeto `#fields`, y los atributos `th:errors` y `th:errorclass`.


7.1 Errores de campo
--------------------

Veamos cómo podríamos asignar una clase CSS específica a un campo si este 
presenta un error:

```html
<input type="text" th:field="*{datePlanted}" 
                   th:class="${#fields.hasErrors('datePlanted')}? fieldError" />
```

Como puede ver, la función `#fields.hasErrors(...)` recibe la expresión del campo 
como parámetro (`datePlanted`) y devuelve un valor booleano que indica si 
existen errores de validación para ese campo.

También podríamos obtener todos los errores para ese campo e iterarlos:

```html
<ul>
  <li th:each="err : ${#fields.errors('datePlanted')}" th:text="${err}" />
</ul>
```

En lugar de iterar, también podríamos haber usado `th:errors`, un atributo 
especializado que crea una lista con todos los errores para el selector 
especificado, separados por `<br />`:

```html
<input type="text" th:field="*{datePlanted}" />
<p th:if="${#fields.hasErrors('datePlanted')}" th:errors="*{datePlanted}">Fecha incorrecta</p>
```



### Simplificando el estilo CSS basado en errores: `th:errorclass`

El ejemplo anterior, *asignar una clase CSS a un campo de formulario si este 
contiene errores*, es tan común que Thymeleaf ofrece un atributo específico para 
ello: `th:errorclass`.

Aplicado a la etiqueta de un campo de formulario (input, select, textarea, etc.), 
leerá el nombre del campo a examinar de cualquier atributo `name` o `th:field` 
existente en la misma etiqueta y, a continuación, añadirá la clase CSS 
especificada a la etiqueta si dicho campo contiene errores.

```html
<input type="text" th:field="*{datePlanted}" class="small" th:errorclass="fieldError" />
```

Si `datePlanted` tiene errores, se mostrará de la siguiente manera:

```html
<input type="text" id="datePlanted" name="datePlanted" value="2013-01-01" class="small fieldError" />
```


7.2 Todos los errores
---------------------

¿Y si queremos mostrar todos los errores del formulario? Solo necesitamos 
consultar los métodos `#fields.hasErrors(...)` y `#fields.errors(...)` con las 
constantes `'*'` o `'all'` (que son equivalentes):

```html
<ul th:if="${#fields.hasErrors('*')}">
  <li th:each="err : ${#fields.errors('*')}" th:text="${err}">La entrada es incorrecta</li>
</ul>
```

Como en los ejemplos anteriores, podríamos obtener todos los errores e iterarlos...

```html
<ul>
  <li th:each="err : ${#fields.errors('*')}" th:text="${err}" />
</ul>
```
...así como construir una lista separada por `<br />`:

```html
<p th:if="${#fields.hasErrors('all')}" th:errors="*{all}">Fecha incorrecta</p>
```

Por último, tenga en cuenta que `#fields.hasErrors('*')` es equivalente a 
`#fields.hasAnyErrors()` y `#fields.errors('*')` es equivalente a 
`#fields.allErrors()`. Utilice la sintaxis que prefiera:

```html
<div th:if="${#fields.hasAnyErrors()}">
  <p th:each="err : ${#fields.allErrors()}" th:text="${err}">...</p>
</div>
```


7.3 Errores Globales
--------------------

Existe un tercer tipo de error en un formulario de Spring: los errores 
*globales*. Se trata de errores que no están asociados a ningún campo específico 
del formulario, pero que aun así existen.

Thymeleaf ofrece la constante `global` para acceder a estos errores:

```html
<ul th:if="${#fields.hasErrors('global')}">
  <li th:each="err : ${#fields.errors('global')}" th:text="${err}">La entrada es incorrecta</li>
</ul>
```

```html
<p th:if="${#fields.hasErrors('global')}" th:errors="*{global}">Fecha incorrecta</p>
```

...así como los métodos de conveniencia equivalentes `#fields.hasGlobalErrors()` 
y `#fields.globalErrors()`: 

```html
<div th:if="${#fields.hasGlobalErrors()}">
  <p th:each="err : ${#fields.globalErrors()}" th:text="${err}">...</p>
</div>
```


7.4 Mostrar Errores Fuera de los Formularios
--------------------------------------------

Los errores de validación de formularios también se pueden mostrar fuera de los 
formularios utilizando variables (`${...}`) en lugar de expresiones de selección 
(`*{...}`) y anteponiendo el nombre del bean que respalda el formulario: 

```html
<div th:errors="${myForm}">...</div>
<div th:errors="${myForm.date}">...</div>
<div th:errors="${myForm.*}">...</div>

<div th:if="${#fields.hasErrors('${myForm}')}">...</div>
<div th:if="${#fields.hasErrors('${myForm.date}')}">...</div>
<div th:if="${#fields.hasErrors('${myForm.*}')}">...</div>

<form th:object="${myForm}">
    ...
</form>
```


7.5 Objetos de Error Enriquecidos
----------------------

Thymeleaf ofrece la posibilidad de obtener información de error de formulario en 
forma de beans (en lugar de simples *cadenas*), con los atributos `fieldName` 
(cadena), `message` (cadena) y `global` (booleano).

Estos errores se pueden obtener mediante el método de utilidad 
`#fields.detailedErrors()`:

```html
<ul>
    <li th:each="e : ${#fields.detailedErrors()}" th:class="${e.global}? globalerr : fielderr">
        <span th:text="${e.global}? '*' : ${e.fieldName}">El nombre del campo</span> |
        <span th:text="${e.message}">El mesanej de error</span>
    </li>
</ul>
```


8 ¡Todavía es un prototipo!
===========================

Nuestra aplicación ya está lista. Pero echemos un segundo vistazo a la página 
`.html` que creamos...

Una de las consecuencias más agradables de trabajar con Thymeleaf es que, después 
de haberde toda la funcionalidad que hemos añadido a nuestro HTML, aún podemos 
usarlo como prototipo (lo llamamos una _Plantilla Natural_). Abramos 
`seedstarterng.html` directamente en nuestro navegador sin ejecutar nuestra 
aplicación:

![Plantillas naturales en STSM](images/thymeleafspring/stsm-natural-templating.png)

¡Ahí está! No es una aplicación funcional, no son datos reales... pero es un 
prototipo perfectamente válido compuesto por código HTML perfectamente 
visualizable.




9 El Servicio de Conversión
===========================

9.1 Configuración
-----------------

Como se explicó anteriormente, Thymeleaf puede utilizar un servicio de conversión 
registrado en el contexto de la aplicación. Nuestra clase de configuración de la 
aplicación, al extender la clase auxiliar `WebMvcConfigurerAdapter` de Spring, 
registrará automáticamente dicho servicio de conversión, que podemos configurar 
añadiendo los formateadores que necesitemos. Veamos de nuevo cómo se ve:

```java
@Override
public void addFormatters(final FormatterRegistry registry) {
    super.addFormatters(registry);
    registry.addFormatter(varietyFormatter());
    registry.addFormatter(dateFormatter());
}

@Bean
public VarietyFormatter varietyFormatter() {
    return new VarietyFormatter();
}

@Bean
public DateFormatter dateFormatter() {
    return new DateFormatter();
}
```
   
9.1 Sintaxis de doble llave
---------------------------

El servicio de conversión se puede aplicar fácilmente para convertir/formatear 
cualquier objeto a cadena de texto. Esto se realiza mediante la sintaxis de 
expresiones con doble llave:

  * Para expresiones variables: `${{...}}`
  * Para expresiones de selección: `*{{...}}`

Por ejemplo, dado un convertidor de entero a cadena que agrega comas como 
separador de miles, esto:

```html
<p th:text="${val}">...</p>
<p th:text="${{val}}">...</p>
```

...debería dar como resultado:

```html
<p>1234567890</p>
<p>1,234,567,890</p>
```



9.2 Uso en formularios
----------------------


Ya vimos anteriormente que a cada atributo `th:field` siempre se le aplicará el 
servicio de conversión, por lo que:

```html
<input type="text" th:field="*{datePlanted}" />
```

...es en realidad equivalente a:

```html
<input type="text" th:field="*{{datePlanted}}" />
```

Tenga en cuenta que, según los requisitos de Spring, este es el único escenario 
en el que se aplica el Servicio de Conversión en expresiones que utilizan 
sintaxis de una sola llave.



9.3 Objeto de utilidad `#conversions` 
-------------------------------------- 

El objeto de utilidad de expresión `#conversions` permite la ejecución manual 
del Servicio de conversión donde sea necesario:

```html
<p th:text="${'Val: ' + #conversions.convert(val,'String')}">...</p>
```

Sintaxis para este objeto de utilidad:

  * `#conversions.convert(Object,Class)`: convierte el objeto a la clase especificada.
  * `#conversions.convert(Object,String)`: Igual que lo anterior, pero especificando la clase de destino como una cadena (tenga en cuenta que se puede omitir el paquete `java.lang.`).




10 Representación de Fragmentos de Plantilla
============================================

Thymeleaf ofrece la posibilidad de renderizar solo una parte de una plantilla 
como resultado de su ejecución: un *fragmento*.

Esta puede ser una herramienta útil para la modularización. Por ejemplo, se 
puede usar en controladores que se ejecutan en llamadas AJAX, las cuales podrían 
devolver fragmentos de marcado de una página ya cargada en el navegador (para 
actualizar un selector, habilitar/deshabilitar botones, etc.).

La renderización fragmentaria se puede lograr utilizando las 
*especificaciones de fragmento* de Thymeleaf: objetos que implementan la 
interfaz `org.thymeleaf.fragment.IFragmentSpec`.

La implementación más común es 
`org.thymeleaf.standard.fragment.StandardDOMSelectorFragmentSpec`, que permite 
especificar un fragmento usando un selector DOM, similar a los que se usan en 
`th:include` o `th:replace`.

10.1 Especificación de fragmentos en beans de vista
----------------------------------------

Los *beans de vista* son beans de la clase 
`org.thymeleaf.spring6.view.ThymeleafView` declarados en el contexto de la 
aplicación (declaraciones `@Bean` si se utiliza la configuración Java). Permiten 
especificar fragmentos como este:

```java
@Bean(name="content-part")
@Scope("prototype")
public ThymeleafView someViewBean() {
    ThymeleafView view = new ThymeleafView("index"); // templateName = 'index'
    view.setMarkupSelector("content");
    return view;
}
``` 

Dada la definición de bean anterior, si nuestro controlador devuelve 
`content-part` (el nombre del bean anterior)...

```java    
@RequestMapping("/showContentPart")
public String showContentPart() {
    ...
    return "content-part";
}
```

Thymeleaf devolverá únicamente el fragmento `content` de la plantilla `index`, 
cuya ubicación probablemente será algo como `/WEB-INF/templates/index.html`, una 
vez aplicados el prefijo y el sufijo. Por lo tanto, el resultado será 
completamente equivalente a especificar `index :: content`:

```html
<!DOCTYPE html>
<html>
  ...
  <body>
    ...
    <div th:fragment="content">
       ¡Solo se renderizará este div!
    </div>
    ...
  </body>
</html>
```

Cabe destacar también que, gracias a la potencia de los selectores de marcado de 
Thymeleaf, podríamos seleccionar un fragmento en una plantilla sin necesidad de 
utilizar ningún atributo `th:fragment`. Por ejemplo, usemos el atributo `id`:

```java
@Bean(name="content-part")
@Scope("prototype")
public ThymeleafView someViewBean() {
    ThymeleafView view = new ThymeleafView("index"); // templateName = 'index'
    view.setMarkupSelector("#content");
    return view;
}
``` 

...which will perfectly select:

```html
<!DOCTYPE html>
<html>
  ...
  <body>
    ...
    <div id="content">
       ¡Solo se renderizará este div!
    </div>
    ...
  </body>
</html>
```




10.2 Especificación de fragmentos en los valores de retorno del controlador
---------------------------------------------------------------------------

En lugar de declarar *beans de vista*, los fragmentos se pueden especificar 
desde los propios controladores utilizando la sintaxis de 
*expresiones de fragmento*. Al igual que en los atributos `th:insert` o 
`th:replace`:

```java    
@RequestMapping("/showContentPart")
public String showContentPart() {
    ...
    return "index :: content";
}
```

Por supuesto, nuevamente disponemos de todo el potencial de los selectores DOM, 
por lo que podríamos seleccionar nuestro fragmento basándonos en atributos HTML 
estándar, como `id="content"`:

```java    
@RequestMapping("/showContentPart")
public String showContentPart() {
    ...
    return "index :: #content";
}
```

Y también podemos usar parámetros, como:

```java    
@RequestMapping("/showContentPart")
public String showContentPart() {
    ...
    return "index :: #content ('myvalue')";
}
```



11 Funciones de integración avanzadas
=====================================


11.1 Integración con `RequestDataValueProcessor`
-------------------------------------------------

Thymeleaf seamlessly integrates with Spring's `RequestDataValueProcessor` interface. This interface allows the interception of link URLs, form URLs and form field values before they are written to the markup result, as well as transparently adding hidden form fields that enable security features like e.g. protection agains CSRF (Cross-Site Request Forgery).

An implementation of `RequestDataValueProcessor` can be easily configured at the Application Context. It needs to implement
the `org.springframework.web.servlet.support.RequestDataValueProcessor` interface and have 
`requestDataValueProcessor` as a bean name:

```java
@Bean
public RequestDataValueProcessor requestDataValueProcessor() {
  return new MyRequestDataValueProcessor();
}
```

...and Thymeleaf will use it this way:

  * `th:href` and `th:src` call `RequestDataValueProcessor.processUrl(...)` before rendering the URL.

  * `th:action` calls `RequestDataValueProcessor.processAction(...)` before rendering the form's `action` attribute, and additionally it detects when this attribute is being applied on a `<form>` tag ---which should be the only place, anyway---, and in such case calls `RequestDataValueProcessor.getExtraHiddenFields(...)` and adds the returned hidden fields just before the closing `</form>` tag.

  * `th:value` calls `RequestDataValueProcessor.processFormFieldValue(...)` for rendering the value it refers to, unless there is a `th:field` present in the same tag (in which case `th:field` will take care).

  * `th:field` calls `RequestDataValueProcessor.processFormFieldValue(...)` for rendering the value of the field it applies to (or the tag body if it is a `<textarea>`).


> Note there are very few scenarios in which you would need to explicitly implement `RequestDataValueProcessor`
> in your application. In most cases, this will be used automatically by security libraries you transparently use, 
> like e.g. Spring Security's CSRF support.



11.1 Creación de URI para controladores
---------------------------------------

Since version 4.1, Spring allows the possibility to build links to annotated controllers directly from views, without the 
need to know the URIs these controllers are mapped to.

In Thymeleaf, this can be achieved by means of the `#mvc.url(...)` expression object method, which allows the 
specification of controller methods by the capital letters of the controller class they are in, followed by 
the name of the method itself. This is equivalent to JSP's `spring:mvcUrl(...)` custom function. 

For example, for:
```java
public class ExampleController {

    @RequestMapping("/data")
    public String getData(Model model) { ... return "template" }

    @RequestMapping("/data")
    public String getDataParam(@RequestParam String type) { ... return "template" }

}
```
The following code will create a link to it:
```html
<a th:href="${(#mvc.url('EC#getData')).build()}">Get Data Param</a>
<a th:href="${(#mvc.url('EC#getDataParam').arg(0,'internal')).build()}">Get Data Param</a>
``` 

You can read more about this mechanism 
at http://docs.spring.io/spring-framework/docs/4.1.2.RELEASE/spring-framework-reference/html/mvc.html#mvc-links-to-controllers-from-views


12 Integración con Spring WebFlow
=================================


12.1 Configuración básica
-------------------------

The Thymeleaf + Spring integration packages include integration with Spring
WebFlow.

_Note: Spring WebFlow 3.0+ is required when Thymeleaf is used with Spring 6, and
Spring WebFlow 2.5 is needed with Spring 5._

WebFlow includes some AJAX capabilities for rendering fragments of the displayed
page when specific events (_transitions_) are triggered, and in order to enable
Thymeleaf to attend these AJAX requests, we will have to use a different `ViewResolver`
implementation, configured like this:

```java
@Bean
public FlowDefinitionRegistry flowRegistry() {
    // NOTE: Additional configuration might be needed in your app
    return getFlowDefinitionRegistryBuilder()
            .addFlowLocation("...")
            .setFlowBuilderServices(flowBuilderServices())
            .build();
}

@Bean
public FlowExecutor flowExecutor() {
    // NOTE: Additional configuration might be needed in your app
    return getFlowExecutorBuilder(flowRegistry()).build();
}

@Bean
public FlowBuilderServices flowBuilderServices() {
    // NOTE: Additional configuration might be needed in your app
    return getFlowBuilderServicesBuilder()
            .setViewFactoryCreator(viewFactoryCreator())
            .build();
}

@Bean
public ViewFactoryCreator viewFactoryCreator() {
    MvcViewFactoryCreator factoryCreator = new MvcViewFactoryCreator();
    factoryCreator.setViewResolvers(
            Collections.singletonList(thymeleafViewResolver()));
    factoryCreator.setUseSpringBeanBinding(true);
    return factoryCreator;
}

@Bean
public ViewResolver thymeleafViewResolver() {
    AjaxThymeleafViewResolver viewResolver = new AjaxThymeleafViewResolver();
    // We need to set a special ThymeleafView implementation: FlowAjaxThymeleafView
    viewResolver.setViewClass(FlowAjaxThymeleafView.class);
    viewResolver.setTemplateEngine(templateEngine());
    return viewResolver;
}

```

Note the above is not a complete configuration: you will still need to configure your handlers, etc. Refer to the
Spring WebFlow documentation for that.

From here on, you can specify Thymeleaf templates in your view-state's:

```xml
<view-state id="detail" view="bookingDetail">
    ...
</view-state>
```

In the above example, `bookingDetail` is a Thymeleaf template specified in the
usual way, understandable by any of the _Template Resolvers_ configured at the `TemplateEngine`.



12.2 Fragmentos AJAX en Spring WebFlow
-------------------------------------

> Note that what is explained here is just the way to create AJAX fragments to be used
> with Spring WebFlow. If you are not using WebFlow, creating a Spring MVC controller that
> responds to an AJAX request and returns a chunk of HTML is as straightforward as creating
> any other template-returning controller, with the only exception that you would probably
> be returning a fragment like `"main :: admin"` from your controller method.

WebFlow allows the specification of fragments to be rendered via AJAX with `<render>`
tags, like this:

```xml
<view-state id="detail" view="bookingDetail">
    <transition on="updateData">
        <render fragments="hoteldata"/>
    </transition>
</view-state>
```

These fragments (`hoteldata`, in this case) can be a comma-separated list of
fragments specified at the markup with `th:fragment`:

```xml
<div id="data" th:fragment="hoteldata">
    This is a content to be changed
</div>
```

_Always remember that the specified fragments must have an `id` attribute, so
that the Spring JavaScript libraries running on the browser are capable of
substituting the markup._

`<render>` tags can also be specified using DOM selectors:

```html
<view-state id="detail" view="bookingDetail">
    <transition on="updateData">
        <render fragments="[//div[@id='data']]"/>
    </transition>
</view-state>
```

...and this will mean no `th:fragment` is needed:

```html
<div id="data">
    This is a content to be changed
</div>
```

As for the code that triggers the `updateData` transition, it looks like:

```html
<script type="text/javascript" th:src="@{/resources/dojo/dojo.js}"></script>
<script type="text/javascript" th:src="@{/resources/spring/Spring.js}"></script>
<script type="text/javascript" th:src="@{/resources/spring/Spring-Dojo.js}"></script>

  ...

<form id="triggerform" method="post" action="">
    <input type="submit" id="doUpdate" name="_eventId_updateData" value="Update now!" />
</form>

<script type="text/javascript">
    Spring.addDecoration(
        new Spring.AjaxEventDecoration({formId:'triggerform',elementId:'doUpdate',event:'onclick'}));
</script>
```
