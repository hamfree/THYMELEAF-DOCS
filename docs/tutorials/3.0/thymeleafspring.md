---
title: 'Tutorial: Thymeleaf + Spring'
author: Thymeleaf
version: @documentVersion@
thymeleafVersion: @projectVersion@
---




Prefacio
=======

Este tutorial explica cómo integrar Thymeleaf con Spring Framework, especialmente (aunque no exclusivamente) con Spring MVC.

Tenga en cuenta que Thymeleaf cuenta con integraciones para las versiones 3.x y 4.x de Spring Framework, proporcionadas por dos 
bibliotecas independientes llamadas `thymeleaf-spring3` y `thymeleaf-spring4`. Estas bibliotecas se encuentran en archivos `.jar` separados 
(`thymeleaf-spring3-{versión}.jar` y `thymeleaf-spring4-{versión}.jar`) y deben agregarse a su 
classpath para poder usar las integraciones de Thymeleaf con Spring en su aplicación.

Los ejemplos de código y la aplicación de ejemplo de este tutorial utilizan **Spring 4.x** y sus correspondientes
integraciones de Thymeleaf, pero el contenido de este texto también es válido para Spring 3.x. Si su aplicación utiliza
Spring 3.x, solo tiene que reemplazar el paquete `org.thymeleaf.spring4` por `org.thymeleaf.spring3` en los
ejemplos de código.


1 Integrando Thymeleaf con Spring
===================================

Thymeleaf ofrece un conjunto de integraciones con Spring que permiten usarlo como una alternativa completa a JSP en 
aplicaciones Spring MVC.

Estas integraciones le permitirán:

 * Hacer que los métodos mapeados en sus objetos `@Controller` de Spring MVC se reenvíen a las plantillas gestionadas 
   por Thymeleaf, exactamente como lo hace con los JSP.
 * Utilizar **Lenguaje de Expresión de Spring** (Spring EL) en lugar de OGNL en sus plantillas.
 * Crear formularios en sus plantillas que estén completamente integrados con sus beans de respaldo de formularios y 
   enlaces de resultados, incluyendo el uso de editores de propiedades, servicios de conversión y manejo de errores de 
   validación.
 * Mostrar los mensajes de internacionalización de los archivos de mensajes gestionados por Spring (a través de los 
   objetos `MessageSource` habituales).
 * Resolver sus plantillas utilizando los mecanismos de resolución de recursos propios de Spring.

Tenga en cuenta que, para comprender completamente este tutorial, primero debe haber consultado el tutorial 
_"Uso de Thymeleaf"_, que explica el dialecto estándar en profundidad.




2 El dialecto SpringStandard
============================

Para lograr una integración más sencilla y eficaz, Thymeleaf proporciona un 
dialecto que implementa específicamente todas las características necesarias 
para funcionar correctamente con Spring.

Este dialecto se basa en el dialecto estándar de Thymeleaf y se implementa en 
una clase llamada `org.thymeleaf.spring4.dialect.SpringStandardDialect`, que 
hereda de `org.thymeleaf.standard.StandardDialect`.

Además de todas las características ya presentes en el dialecto estándar --y, 
por lo tanto, heredadas--, el dialecto SpringStandard introduce las siguientes 
características específicas:

 * Se utiliza el lenguaje de expresiones de Spring (Spring EL o SpEL) como lenguaje 
   de expresiones variables, en lugar de OGNL. Por lo tanto, todas las 
   expresiones `${...}` y `*{...}` serán evaluadas por el motor de lenguaje de 
   expresiones de Spring. Tenga en cuenta también que se dispone de 
   compatibilidad con el compilador de Spring EL (Spring 4.2.4 o superior).
 * Se accede a cualquier bean en el contexto de su aplicación utilizando la 
   sintaxis de SpringEL: `${@myBean.doSomething()}`
 * Nuevos atributos para el procesamiento de formularios: `th:field`, `th:errors` 
   y `th:errorclass`, además de una nueva implementación de `th:object` que 
   permite utilizarlo para la selección de comandos de formulario.
 * Un objeto de expresión y un método, `#themes.code(...)`, que es equivalente 
   a la etiqueta personalizada JSP `spring:theme`.
 * Un objeto de expresión y un método, `#mvc.uri(...)`, que es equivalente a la 
   función personalizada JSP `spring:mvcUrl(...)` (solo en Spring 4.1+). 

Tenga en cuenta que, en la mayoría de los casos, no debería usar este dialecto 
directamente en un _objeto_ `TemplateEngine` normal como parte de su 
configuración. A menos que tenga necesidades de integración con Spring muy 
específicas, debería crear una instancia de una nueva clase de motor de 
plantillas que realice automáticamente todos los pasos de configuración 
necesarios: `org.thymeleaf.spring4.SpringTemplateEngine`.

Ejemplo de configuración de bean:

```java
@Bean
public SpringResourceTemplateResolver templateResolver(){
    // SpringResourceTemplateResolver se integra automáticamente con la infraestructura de resolución de recursos propia de Spring,
    // lo cual es altamente recomendable.
    SpringResourceTemplateResolver templateResolver = new SpringResourceTemplateResolver();
    templateResolver.setApplicationContext(this.applicationContext);
    templateResolver.setPrefix("/WEB-INF/templates/");
    templateResolver.setSuffix(".html");
    // HTML es el valor predeterminado, añadido aquí para mayor claridad.
    templateResolver.setTemplateMode(TemplateMode.HTML);
    // La caché de plantillas está activada por defecto. Desactívala si quieres 
    // que las plantillas se actualicen automáticamente al modificarse.
    templateResolver.setCacheable(true);
    return templateResolver;
}

@Bean
public SpringTemplateEngine templateEngine(){
    // SpringTemplateEngine aplica automáticamente SpringStandardDialect y 
    // habilita los mecanismos de resolución de mensajes MessageSource propios de Spring.
    SpringTemplateEngine templateEngine = new SpringTemplateEngine();
    templateEngine.setTemplateResolver(templateResolver());
    // Habilitar el compilador SpringEL con Spring 4.2.4 o posterior puede
    // acelerar la ejecución en la mayoría de los casos, pero podría ser incompatible
    // con casos específicos en los que se reutilizan expresiones en una plantilla
    // en diferentes tipos de datos, por lo que esta bandera es "falsa" por defecto
    // para una compatibilidad con versiones anteriores más segura.
    templateEngine.setEnableSpringELCompiler(true);
    return templateEngine;
}
```

O bien, utilizando la configuración basada en XML de Spring:

```xml
<!-- SpringResourceTemplateResolver se integra automáticamente con la          -->
<!-- infraestructura de resolución de recursos propia de Spring lo cual es     --> 
<!-- altamente recomendable.                                                   -->
<bean id="templateResolver"
       class="org.thymeleaf.spring4.templateresolver.SpringResourceTemplateResolver">
  <property name="prefix" value="/WEB-INF/templates/" />
  <property name="suffix" value=".html" />
  <!-- HTML es el valor predeterminado, añadido aquí para mayor claridad.      -->
  <property name="templateMode" value="HTML" />
  <!-- La caché de plantillas está activada por defecto. Desactívala si        -->
  <!-- quieres que las plantillas se actualicen automáticamente al             -->
  <!-- modificarse.                                                            -->
  <property name="cacheable" value="true" />
</bean>
       
<!-- SpringTemplateEngine aplica automáticamente SpringStandardDialect y       -->
<!-- habilita los mecanismos de resolución de mensajes MessageSource propios   -->
<!-- de Spring.                                                                -->
<bean id="templateEngine"
      class="org.thymeleaf.spring4.SpringTemplateEngine">
  <property name="templateResolver" ref="templateResolver" />
  <!-- Habilitar el compilador SpringEL con Spring 4.2.4 o posterior puede     -->
  <!-- acelerar la ejecución en la mayoría de los casos, pero podría ser       -->
  <!-- incompatible con casos específicos en los que se reutilizan expresiones -->
  <!-- de una plantilla en diferentes tipos de datos por lo que esta bandera   -->
  <!-- está desactivada por defecto para una mayor seguridad de compatibilidad -->
  <!-- con versiones anteriorescompatibilidad con versiones anteriores.        -->
  <property name="enableSpringELCompiler" value="true" />
</bean>
```



3 Vistas y solucionadores de vistas
==========================



3.1 Vistas y solucionadores de vistas en Spring MVC
------------------------------------------

En Spring MVC existen dos interfaces que conforman el núcleo de su sistema de 
plantillas:

 * `org.springframework.web.servlet.View`
 * `org.springframework.web.servlet.ViewResolver`

Las vistas modelan las páginas de nuestras aplicaciones y nos permiten modificar 
y predefinir su comportamiento al definirlas como beans. Las vistas se encargan 
de renderizar la interfaz HTML, generalmente mediante la ejecución de un motor 
de plantillas como Thymeleaf.

Los ViewResolvers son los objetos encargados de obtener objetos View para una 
operación y configuración regional específicas. Normalmente, los controladores 
solicitan a los ViewResolvers que redirijan a una vista con un nombre específico 
(una cadena de texto devuelta por el método del controlador). A continuación, 
todos los ViewResolvers de la aplicación se ejecutan en cadena de forma ordenada 
hasta que uno de ellos logra resolver dicha vista. En ese caso, se devuelve un 
objeto View y se le transfiere el control para la renderización del HTML.

> Tenga en cuenta que no todas las páginas de nuestras aplicaciones tienen que 
> estar definidas como Vistas, sino  solo aquellas cuyo comportamiento deseamos 
> no ser estándar o configurados en una de una forma específica (por ejemplo, 
> conectándole algunos beans especiales). Si a un ViewResolver se le solicita 
> una vista que no tiene un bean correspondiente  --que es el caso común--, se 
> crea un nuevo objeto View ad hoc y se devuelve.

Una configuración típica para un ViewResolver JSP+JSTL en una aplicación Spring 
MVC del pasado tenía este aspecto:

```xml
<bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
  <property name="viewClass" value="org.springframework.web.servlet.view.JstlView" />
  <property name="prefix" value="/WEB-INF/jsps/" />
  <property name="suffix" value=".jsp" />
  <property name="order" value="2" />
  <property name="viewNames" value="*jsp" />
</bean>
```

Un vistazo rápido a sus propiedades es suficiente para saber cómo fue configurado:

 * `viewClass` establece la clase de las instancias de View. Esto es necesario 
   para un resolvedor JSP, pero no será necesario en absoluto cuando trabajemos 
   con Thymeleaf.
 * Los parámetros `prefix` y `suffix` funcionan de forma similar a los atributos 
   con los mismos nombres en los objetos TemplateResolver de Thymeleaf.
 * `order` establece el orden en el que se consultará el ViewResolver en la cadena.
 * `viewNames` permite definir (con comodines) los nombres de las vistas que 
   serán resueltas por este ViewResolver.



3.2 Vistas y solucionadores de vistas en Thymeleaf
-----------------------------------------

Thymeleaf ofrece implementaciones para las dos interfaces mencionadas 
anteriormente:

 * `org.thymeleaf.spring4.view.ThymeleafView`
 * `org.thymeleaf.spring4.view.ThymeleafViewResolver`

Estas dos clases se encargarán de procesar las plantillas de Thymeleaf como 
resultado de la ejecución de los controladores.

La configuración del Solucionador de Vistas de Thymeleaf es muy similar a la de 
JSP:

```java
@Bean
public ThymeleafViewResolver viewResolver(){
    ThymeleafViewResolver viewResolver = new ThymeleafViewResolver();
    viewResolver.setTemplateEngine(templateEngine());
    // NOTA: 'order' y 'viewNames' son opcionales.
    viewResolver.setOrder(1);
    viewResolver.setViewNames(new String[] {".html", ".xhtml"});
    return viewResolver;
}
```

...o en XML:

```xml
<bean class="org.thymeleaf.spring4.view.ThymeleafViewResolver">
  <property name="templateEngine" ref="templateEngine" />
  <!-- NOTA: 'order' y 'viewNames' son opcionales. -->
  <property name="order" value="1" />
  <property name="viewNames" value="*.html,*.xhtml" />
</bean>
```

El parámetro `templateEngine` es, por supuesto, el objeto `SpringTemplateEngine` 
que definimos en el capítulo anterior. Los otros dos (`order` y `viewNames`) son 
opcionales y tienen el mismo significado que en el JSP ViewResolver que vimos 
anteriormente.

Tenga en cuenta que no necesitamos los parámetros `prefix` ni `suffix`, ya que 
estos se especifican en el Template Resolver (que a su vez se pasa al Template 
Engine).

¿Y si quisiéramos definir un bean `View` y añadirle algunas variables estáticas? 
Es sencillo: basta con definir un bean *prototype* para ello.

```java
@Bean
@Scope("prototype")
public ThymeleafView mainView() {
    ThymeleafView view = new ThymeleafView("main"); // templateName = 'main'
    view.setStaticVariables(
        Collections.singletonMap("footer", "The ACME Fruit Company"));
    return view;
}
```

Al hacer esto, podrá ejecutar específicamente este bean de vista seleccionándolo 
por su nombre (en este caso, `mainView`).



4 Gestor de semillas de tomillo de Spring
===================================

El código fuente de los ejemplos que se muestran en este y en futuros capítulos 
de esta guía se puede encontrar en el repositorio de GitHub [Spring Thyme Seed Starter Manager](https://github.com/thymeleaf/thymeleafexamples-stsm).


4.1 El concepto
---------------

En Thymeleaf somos grandes aficionados al tomillo, y cada primavera preparamos 
nuestros kits de germinación con buena tierra y nuestras semillas favoritas, los 
colocamos bajo el sol español y esperamos pacientemente a que crezcan nuestras 
nuevas plantas.

Pero este año nos cansamos de pegar etiquetas en los recipientes de germinación 
para saber qué semilla había en cada compartimento, así que decidimos crear una 
aplicación con Spring MVC y Thymeleaf para catalogar nuestros kits: _El Gestor 
de Germinación de Semillas de Tomillo de Spring_.

![Portada de STSM](images/thymeleafspring/stsm-view.png)

De forma similar a la aplicación Good Thymes Virtual Grocery que desarrollamos 
en el tutorial _Using Thymeleaf_, el STSM nos permitirá ejemplificar los aspectos 
más importantes de la integración de Thymeleaf como motor de plantillas para 
Spring MVC.



4.2 Capa de Negocio
------------------

Necesitaremos una capa de negocio muy simple para nuestra aplicación. En primer 
lugar, veamos las entidades de nuestro modelo:

![Modelo STSM](images/thymeleafspring/stsm-model.png)

Un par de clases de servicio muy sencillas proporcionarán los métodos de negocio 
necesarios. Por ejemplo:

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

A continuación, debemos configurar Spring MVC para la aplicación, lo que 
incluirá no solo los elementos estándar de Spring MVC, como el manejo de 
recursos o el escaneo de anotaciones, sino también la creación de instancias del 
motor de plantillas y del solucionador de vistas.

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
    /*  ARTEFACTOS DE CONFIGURACIÓN GENERAL                                */
    /*  Recursos estáticos, Mensajes i18n, Formateadores                   */ 
    /* (Servicio de Conversión)                                            */
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
    /*  ARTEFACTOS ESPECÍFICOS DE THYMELEAF                             */
    /*  TemplateResolver <- TemplateEngine <- ViewResolver              */
    /* **************************************************************** */

    @Bean
    public SpringResourceTemplateResolver templateResolver(){
        // SpringResourceTemplateResolver se integra automáticamente con la 
        // infraestructura de resolución de recursos propia de Spring,
        // lo cual es altamente recomendable.
        SpringResourceTemplateResolver templateResolver = new SpringResourceTemplateResolver();
        templateResolver.setApplicationContext(this.applicationContext);
        templateResolver.setPrefix("/WEB-INF/templates/");
        templateResolver.setSuffix(".html");
        // HTML es el valor predeterminado, añadido aquí para mayor claridad.
        templateResolver.setTemplateMode(TemplateMode.HTML);
        // La caché de plantillas está activada por defecto. Desactívala si deseas 
        // que las plantillas se actualicen automáticamente al modificarse.
        templateResolver.setCacheable(true);
        return templateResolver;
    }

    @Bean
    public SpringTemplateEngine templateEngine(){
        // SpringTemplateEngine aplica automáticamente SpringStandardDialect y 
        // habilita los mecanismos de resolución de mensajes MessageSource 
        // propios de Spring.
        SpringTemplateEngine templateEngine = new SpringTemplateEngine();
        templateEngine.setTemplateResolver(templateResolver());
        // Habilitar el compilador SpringEL con Spring 4.2.4 o versiones 
        // posteriores puede acelerar la ejecución en la mayoría de los casos, 
        // pero podría ser incompatible con casos específicos en los que las 
        // expresiones de una plantilla se reutilizan en diferentes tipos de 
        // datos, por lo que esta bandera está desactivada por defecto para una 
        // mayor seguridad y compatibilidad con versiones anteriores.
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



4.4 El controlador
------------------

Por supuesto, también necesitaremos un controlador para nuestra aplicación. Como 
el STSM solo contendrá una página web con una lista de kits de semillas y un 
formulario para agregar nuevas, escribiremos una sola clase de controlador para 
todas las interacciones con el servidor:

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

Ahora veamos qué podemos agregar a esta clase de controlador.


### Atributos del modelo

Primero agregaremos algunos atributos del modelo que necesitaremos en la página:

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
para mostrar la página del formulario y otro para procesar la adición de nuevos 
objetos `SeedStarter`.

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



4.5 Configurar un servicio de conversión
------------------------------------

Para facilitar el formato de los objetos `Date` y `Variety` en nuestra capa de 
vista, configuramos nuestra aplicación de manera que se creará e inicializará un 
objeto `ConversionService` de Spring (mediante el `WebMvcConfigurerAdapter` que 
extendemos) con un par de objetos *formateadores* que necesitaremos. Véalo de nuevo:

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
`org.springframework.format.Formatter`. Para obtener más información sobre cómo 
funciona la infraestructura de conversión de Spring, consulte la documentación 
en [spring.io](http://docs.spring.io/spring/docs/4.3.x/spring-framework-reference/html/validation.html#core-convert).

Veamos el `DateFormatter`, que formatea las fechas según una cadena de formato 
presente en la clave `date.format` de nuestro archivo `Messages.properties`:

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

El `VarietyFormatter` convierte automáticamente entre nuestras entidades `Variety` 
y la forma en que queremos usarlas en nuestros formularios (básicamente, por los 
valores de su campo `id`):

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

Más adelante aprenderemos más sobre cómo estos formateadores afectan la forma en 
que se muestran nuestros datos.




5 Listado de datos del semillero
===========================

Lo primero que mostrará nuestra página `/WEB-INF/templates/seedstartermng.html` 
es una lista con los starters de semillas almacenados actualmente. Para ello, 
necesitaremos algunos mensajes externos y también la evaluación de expresiones 
en los atributos del modelo. Algo así:

```html
<div class="seedstarterlist" th:unless="${#lists.isEmpty(allSeedStarters)}">
    
  <h2 th:text="#{title.list}">List of Seed Starters</h2>
  
  <table>
    <thead>
      <tr>
        <th th:text="#{seedstarter.datePlanted}">Date Planted</th>
        <th th:text="#{seedstarter.covered}">Covered</th>
        <th th:text="#{seedstarter.type}">Type</th>
        <th th:text="#{seedstarter.features}">Features</th>
        <th th:text="#{seedstarter.rows}">Rows</th>
      </tr>
    </thead>
    <tbody>
      <tr th:each="sb : ${allSeedStarters}">
        <td th:text="${{sb.datePlanted}}">13/01/2011</td>
        <td th:text="#{|bool.${sb.covered}|}">yes</td>
        <td th:text="#{|seedstarter.type.${sb.type}|}">Wireframe</td>
        <td th:text="${#strings.arrayJoin(
                           #messages.arrayMsg(
                               #strings.arrayPrepend(sb.features,'seedstarter.feature.')),
                           ', ')}">Electric Heating, Turf</td>
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

En primer lugar, esta sección solo se mostrará si hay semillas iniciales. Esto 
se logra con el atributo `th:unless` y la función `#lists.isEmpty(...)`.

```html
<div class="seedstarterlist" th:unless="${#lists.isEmpty(allSeedStarters)}">
```

Tenga en cuenta que todos los objetos de utilidad como `#lists` están disponibles 
en las expresiones de Spring EL, al igual que en las expresiones OGNL del 
dialecto estándar.

Lo siguiente que veremos son muchos textos internacionalizados (externalizados), como:

```html
<h2 th:text="#{title.list}">List of Seed Starters</h2>

<table>
  <thead>
    <tr>
      <th th:text="#{seedstarter.datePlanted}">Date Planted</th>
      <th th:text="#{seedstarter.covered}">Covered</th>
      <th th:text="#{seedstarter.type}">Type</th>
      <th th:text="#{seedstarter.features}">Features</th>
      <th th:text="#{seedstarter.rows}">Rows</th>
      ...
```

Al tratarse de una aplicación Spring MVC, ya hemos definido un bean 
`MessageSource` en nuestra configuración de Spring (los objetos `MessageSource` 
son la forma estándar de gestionar textos externos en Spring MVC):

```java
@Bean
public ResourceBundleMessageSource messageSource() {
    ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
    messageSource.setBasename("Messages");
    return messageSource;
}
```

...y esa propiedad `basename` indica que tendremos archivos como 
`Messages_es.properties` o `Messages_en.properties` en nuestro classpath. Echemos 
un vistazo a la versión en español:

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

A continuación se muestra si el recipiente de inicio de semillas está cubierto o 
no, transformando el valor de la propiedad booleana bean coverd en un _"sí"_ o 
_"no"_ internacionalizado con una expresión de sustitución literal:

```html
<td th:text="#{|bool.${sb.covered}|}">yes</td>
```

Ahora debemos mostrar el tipo de contenedor de semillas. El tipo es una 
enumeración Java con dos valores (`WOOD` y `PLASTIC`), y por eso definimos dos 
propiedades en nuestro archivo `Messages` llamadas `seedstarter.type.WOOD` y 
`seedstarter.type.PLASTIC`.

Pero para obtener los nombres internacionalizados de los tipos, necesitaremos 
agregar el prefijo `seedstarter.type.` al valor de la enumeración mediante una 
expresión, cuyo resultado utilizaremos como clave del mensaje:

```html
<td th:text="#{|seedstarter.type.${sb.type}|}">Wireframe</td>
```
La parte más difícil de este listado es la columna _features_. En ella queremos 
mostrar todas las características de nuestro contenedor ---que vienen en forma 
de un array de enumeraciones `Feature`---, separadas por comas. Por ejemplo: 
_"Calefacción eléctrica, Césped"_.

Tenga en cuenta que esto es particularmente difícil porque estos valores de 
enumeración también deben externalizarse, como hicimos con los tipos. El flujo 
es el siguiente:

1. Anteponer el prefijo correspondiente a todos los elementos de la matriz `features`.
2. Obtener los mensajes externalizados correspondientes a todas las claves del paso 1.
3. Unir todos los mensajes obtenidos en el paso 2, utilizando una coma como delimitador.

Para lograr esto, creamos el siguiente código:

```html
<td th:text="${#strings.arrayJoin(
                   #messages.arrayMsg(
                       #strings.arrayPrepend(sb.features,'seedstarter.feature.')),
                   ', ')}">Electric Heating, Turf</td>
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




6 Crear un formulario
=================



6.1 Manejo del objeto de comando
-------------------------------
El _objeto command_ es el nombre que Spring MVC le da a los beans de respaldo 
de formularios; es decir, a los objetos que modelan los campos de un formulario 
y proporcionan métodos getter y setter que el framework utilizará para establecer 
y obtener los valores ingresados por el usuario en el navegador.

Thymeleaf requiere que especifique el objeto command mediante el atributo 
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

Como puedes ver, aquí introducimos un nuevo atributo: `th:field`. Esta es una 
característica muy importante para la integración con Spring MVC, ya que se 
encarga de todo el trabajo pesado de vincular tu entrada con una propiedad en el 
bean que respalda el formulario. Puedes considerarlo como el equivalente del 
atributo `path` en una etiqueta <form:input> de la biblioteca de etiquetas JSP 
de Spring MVC.

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

Los valores para los atributos `th:field` deben ser expresiones de 
selección (`*{...}`), lo cual tiene sentido dado que se evaluarán en el bean que 
respalda el formulario y no en las variables de contexto (o atributos del modelo 
en la jerga de Spring MVC).

A diferencia de las que se encuentran en `th:object`, estas expresiones pueden 
incluir la navegación de propiedades (de hecho, cualquier expresión permitida 
para el atributo path de una etiqueta JSP `<form:input>` estará permitida aquí).

Tenga en cuenta que `th:field` también entiende los nuevos tipos de elementos 
`<input>` introducidos por HTML5, como `<input type="datetime" ... />`, 
`<input type="color" ... />`, etc., lo que efectivamente agrega soporte completo 
para HTML5 a Spring MVC.



6.3 Campos de casilla de verificación
-------------------

`th:field` también nos permite definir campos de entrada de casilla de 
verificación. Veamos un ejemplo de nuestra página HTML:

```html
<div>
  <label th:for="${#ids.next('covered')}" th:text="#{seedstarter.covered}">Covered</label>
  <input type="checkbox" th:field="*{covered}" />
</div>
```

Cabe destacar que, además de la casilla de verificación en sí, hay otros 
elementos interesantes, como una etiqueta externa y el uso de la función 
`#ids.next('covered')` para obtener el valor que se aplicará al atributo `id` de 
la casilla de verificación.

¿Por qué necesitamos esta generación dinámica de un atributo `id` para este 
campo? Porque las casillas de verificación pueden tener múltiples valores, por 
lo que sus valores `id` siempre irán seguidos de un número de secuencia 
(mediante la función `#ids.seq(...)` internamente) para garantizar que cada 
casilla de verificación para la misma propiedad tenga un valor `id` diferente.

Esto se aprecia mejor al observar un campo de casilla de verificación con 
múltiples valores:

```html
<ul>
  <li th:each="feat : ${allFeatures}">
    <input type="checkbox" th:field="*{features}" th:value="${feat}" />
    <label th:for="${#ids.prev('features')}" 
           th:text="#{${'seedstarter.feature.' + feat}}">Heating</label>
  </li>
</ul>
```

Ten en cuenta que esta vez hemos añadido el atributo `th:value`, ya que el 
campo `features` no es booleano como en `covered`, sino un array de valores.

Veamos el código HTML generado:

```html
<ul>
  <li>
    <input id="features1" name="features" type="checkbox" value="SEEDSTARTER_SPECIFIC_SUBSTRATE" />
    <input name="_features" type="hidden" value="on" />
    <label for="features1">Seed starter-specific substrate</label>
  </li>
  <li>
    <input id="features2" name="features" type="checkbox" value="FERTILIZER" />
    <input name="_features" type="hidden" value="on" />
    <label for="features2">Fertilizer used</label>
  </li>
  <li>
    <input id="features3" name="features" type="checkbox" value="PH_CORRECTOR" />
    <input name="_features" type="hidden" value="on" />
    <label for="features3">PH Corrector used</label>
  </li>
</ul>
```

Aquí podemos ver cómo se agrega un sufijo de secuencia al atributo id de cada 
entrada, y cómo la función `#ids.prev(...)` nos permite recuperar el último 
valor de secuencia generado para un id de entrada específico.

> No te preocupes por esos campos ocultos con `name="_features"`: se añaden 
> automáticamente para evitar problemas con los navegadores que no envían los 
> valores de las casillas de verificación sin marcar al servidor al enviar el 
> formulario.

Tenga en cuenta también que si nuestra propiedad features contenía algunos 
valores seleccionados en nuestro bean de respaldo del formulario, `th:field` se 
habría encargado de eso y habría agregado un atributo `checked="checked"` a las 
etiquetas de entrada correspondientes.



6.4 Campos de botones de opción
-----------------------

Los campos de botones de opción se especifican de forma similar a las casillas 
de verificación no booleanas (multivalor) ---excepto que, por supuesto, no son 
multivalor:

```html
<ul>
  <li th:each="ty : ${allTypes}">
    <input type="radio" th:field="*{type}" th:value="${ty}" />
    <label th:for="${#ids.prev('type')}" th:text="#{${'seedstarter.type.' + ty}}">Wireframe</label>
  </li>
</ul>
```



6.5 Selectores desplegables/de lista
---------------------------

Los campos de selección constan de dos partes: la etiqueta `<select>` y sus 
etiquetas anidadas `<option>`. Al crear este tipo de campo, solo la etiqueta 
`<select>` debe incluir el atributo `th:field`, pero los atributos `th:value` 
de las etiquetas anidadas `<option>` serán muy importantes, ya que permitirán 
saber cuál es la opción seleccionada (de forma similar a las casillas de 
verificación y los botones de opción no booleanos).

Vamos a reconstruir el campo de tipo como un menú desplegable:

```html
<select th:field="*{type}">
  <option th:each="type : ${allTypes}" 
          th:value="${type}" 
          th:text="#{${'seedstarter.type.' + type}}">Wireframe</option>
</select>
```

En este punto, entender este fragmento de código es bastante sencillo. Basta con 
observar cómo la precedencia de atributos nos permite establecer el atributo 
`th:each` en la propia etiqueta `<option>`.



6.6 Campos dinámicos
------------------

Gracias a las avanzadas capacidades de enlace de campos de formulario en Spring 
MVC, podemos usar expresiones EL complejas de Spring para enlazar campos de 
formulario dinámicos a nuestro bean de respaldo de formulario. Esto nos permitirá 
crear nuevos objetos Row en nuestro bean `SeedStarter` y agregar los campos de 
esas filas a nuestro formulario a petición del usuario.

Para ello, necesitaremos un par de métodos mapeados nuevos en nuestro 
controlador, que agregarán o eliminarán una fila de nuestro `SeedStarter` según 
la existencia de parámetros de solicitud específicos:

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
      <th th:text="#{seedstarter.rows.head.rownum}">Row</th>
      <th th:text="#{seedstarter.rows.head.variety}">Variety</th>
      <th th:text="#{seedstarter.rows.head.seedsPerCell}">Seeds per cell</th>
      <th>
        <button type="submit" name="addRow" th:text="#{seedstarter.row.add}">Add row</button>
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
                th:value="${rowStat.index}" th:text="#{seedstarter.row.remove}">Remove row</button>
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
índice de fila? ¿No bastaría con?: 

```html
<select th:field="*{rows[rowStat.index].variety}">

    ...

</select>
```

...Bueno, en realidad no. El problema es que Spring EL no evalúa las variables 
dentro de los corchetes de índice de array, por lo que al ejecutar la expresión 
anterior obtendríamos un error que nos indica que `rows[rowStat.index]` (en 
lugar de `rows[0]`, `rows[1]`, etc.) no es una posición válida en la colección 
de filas. Por eso, es necesario el preprocesamiento.

Veamos un fragmento del HTML resultante tras pulsar _"Añadir fila"_
un par de veces:

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
      <button name="removeRow" type="submit" value="0">Remove row</button>
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
      <button name="removeRow" type="submit" value="1">Remove row</button>
    </td>
  </tr>
</tbody>
```




7 Validación y mensajes de error
===============================

La mayoría de nuestros formularios deberán mostrar mensajes de validación para 
informar al usuario de los errores que él o ella haya cometido.

Thymeleaf ofrece algunas herramientas para ello: un par de funciones en el 
objeto `#fields`, y los atributos `th:errors` y `th:errorclass`.


7.1 Errores de campo
----------------
Veamos cómo podríamos asignar una clase CSS específica a un campo si este 
presenta un error:

```html
<input type="text" th:field="*{datePlanted}" 
                   th:class="${#fields.hasErrors('datePlanted')}? fieldError" />
```

Como puede verse, la función `#fields.hasErrors(...)` recibe la expresión del 
campo como parámetro (`datePlanted`) y devuelve un valor booleano que indica si 
existen errores de validación para ese campo.

También podríamos obtener todos los errores de ese campo e iterar sobre ellos:

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
<p th:if="${#fields.hasErrors('datePlanted')}" th:errors="*{datePlanted}">Incorrect date</p>
```



### Simplificando el estilo CSS basado en errores: `th:errorclass`

El ejemplo anterior, *asignar una clase CSS a un campo de formulario si ese 
campo contiene errores*, es tan común que Thymeleaf ofrece un atributo 
específico para ello: `th:errorclass`.

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
--------------

¿Y si queremos mostrar todos los errores del formulario? Solo necesitamos 
consultar los métodos `#fields.hasErrors(...)` y `#fields.errors(...)` con las 
constantes `'*'` o `'all'` (que son equivalentes):

```html
<ul th:if="${#fields.hasErrors('*')}">
  <li th:each="err : ${#fields.errors('*')}" th:text="${err}">Input is incorrect</li>
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
<p th:if="${#fields.hasErrors('all')}" th:errors="*{all}">Incorrect date</p>
```

Por último, tenga en cuenta que `#fields.hasErrors('*')` es equivalente a 
`#fields.hasAnyErrors()` y `#fields.errors('*')` es equivalente a 
`#fields.allErrors()`. Utilice la sintaxis que prefiera:

```html
<div th:if="${#fields.hasAnyErrors()}">
  <p th:each="err : ${#fields.allErrors()}" th:text="${err}">...</p>
</div>
```


7.3 Errores globales
-----------------

Existe un tercer tipo de error en un formulario de Spring: los errores 
*globales*. Estos errores no están asociados a ningún campo específico 
del formulario, pero aun así existen.

Thymeleaf ofrece la constante `global` para acceder a estos errores:

```html
<ul th:if="${#fields.hasErrors('global')}">
  <li th:each="err : ${#fields.errors('global')}" th:text="${err}">Input is incorrect</li>
</ul>
```

```html
<p th:if="${#fields.hasErrors('global')}" th:errors="*{global}">Incorrect date</p>
```

...así como los métodos de conveniencia equivalentes `#fields.hasGlobalErrors()` 
y `#fields.globalErrors()`: 

```html
<div th:if="${#fields.hasGlobalErrors()}">
  <p th:each="err : ${#fields.globalErrors()}" th:text="${err}">...</p>
</div>
```


7.4 Mostrar errores fuera de los formularios
-----------------------------------

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


7.5 Objetos de error enriquecidos
----------------------

Thymeleaf ofrece la posibilidad de obtener información de errores de formulario 
en forma de beans (en lugar de simples cadenas de texto), con los atributos 
`fieldName` (cadena), `message` (cadena) y `global` (booleano).

Estos errores se pueden obtener mediante el método de utilidad 
`#fields.detailedErrors()`:

```html
<ul>
    <li th:each="e : ${#fields.detailedErrors()}" th:class="${e.global}? globalerr : fielderr">
        <span th:text="${e.global}? '*' : ${e.fieldName}">The field name</span> |
        <span th:text="${e.message}">The error message</span>
    </li>
</ul>
```


8 ¡Todavía es un prototipo!
=========================

Nuestra aplicación ya está lista. Pero echemos un segundo vistazo a la página 
`.html` que creamos...

Una de las ventajas de trabajar con Thymeleaf es que, después de añadir toda la 
funcionalidad a nuestro HTML, podemos seguir usándolo como prototipo (lo 
llamamos una _plantilla natural_). Abramos `seedstarterng.html` directamente en 
nuestro navegador sin ejecutar la aplicación:

![Plantillas naturales STSM](images/thymeleafspring/stsm-natural-templating.png)

¡Ahí está! No es una aplicación funcional, no son datos reales... pero es un 
prototipo perfectamente válido compuesto por código HTML perfectamente 
visualizable.




9 El servicio de conversión
========================

9.1 Configuración
-----------------

Como se explicó anteriormente, Thymeleaf puede utilizar un servicio de conversión 
registrado en el contexto de la aplicación. Nuestra clase de configuración de la 
aplicación, al extender la clase auxiliar `WebMvcConfigurerAdapter` de Spring, 
registrará automáticamente dicho servicio de conversión, que podemos configurar 
añadiendo los *formateadores* que necesitemos. Veamos de nuevo cómo se ve:

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
-----------------------

El servicio de conversión se puede aplicar fácilmente para convertir/formatear 
cualquier objeto a cadena de texto. Esto se realiza mediante la sintaxis de 
expresiones con doble llave:

* Para expresiones de variables: `${{...}}`
* Para expresiones de selección: `*{{...}}`

Por ejemplo, dado un convertidor de entero a cadena que agrega comas como 
separador de miles, se obtiene lo siguiente:

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
----------------


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
--------------------------------- 

El objeto de utilidad de expresión `#conversions` permite la ejecución manual 
del Servicio de conversión donde sea necesario:

```html
<p th:text="${'Val: ' + #conversions.convert(val,'String')}">...</p>
```

Sintaxis para este objeto de utilidad:

* `#conversions.convert(Object,Class)`: convierte el objeto a la clase especificada.
* `#conversions.convert(Object,String)`: igual que la anterior, pero especificando 
  la clase de destino como una cadena (tenga en cuenta que se puede omitir el 
  paquete `java.lang.`).




10 Fragmentos de plantilla de renderizado
===============================

Thymeleaf ofrece la posibilidad de renderizar solo una parte de una plantilla 
como resultado de su ejecución: un *fragmento*.

Esta puede ser una herramienta útil para la modularización. Por ejemplo, se puede 
usar en controladores que se ejecutan en llamadas AJAX, las cuales podrían 
devolver fragmentos de marcado de una página ya cargada en el navegador (para 
actualizar un selector, habilitar/deshabilitar botones, etc.).

La renderización fragmentaria se puede lograr utilizando las *especificaciones 
de fragmento* de Thymeleaf: objetos que implementan la interfaz 
`org.thymeleaf.fragment.IFragmentSpec`.

La implementación más común es 
`org.thymeleaf.standard.fragment.StandardDOMSelectorFragmentSpec`, que permite 
especificar un fragmento usando un selector DOM, similar a los que se usan en 
`th:include` o `th:replace`.

10.1 Especificar fragmentos en beans de vista
----------------------------------------

Los *beans de vista* son beans de la clase `org.thymeleaf.spring4.view.ThymeleafView` 
declarados en el contexto de la aplicación (declaraciones `@Bean` si se utiliza 
la configuración Java). Permiten especificar fragmentos como este:

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

...Thymeleaf devolverá únicamente el fragmento `content` de la plantilla 
`index`, cuya ubicación probablemente será algo como 
`/WEB-INF/templates/index.html`, una vez aplicados el prefijo y el sufijo. Por 
lo tanto, el resultado será completamente equivalente a especificar 
`index :: content`:

```html
<!DOCTYPE html>
<html>
  ...
  <body>
    ...
    <div th:fragment="content">
      Only this div will be rendered!
    </div>
    ...
  </body>
</html>
```

Cabe destacar también que, gracias a la potencia de los selectores de marcado de 
Thymeleaf, podríamos seleccionar un fragmento en una plantilla sin necesidad de 
utilizar ningún atributo `th:fragment`. Usemos el atributo `id`, por ejemplo:

```java
@Bean(name="content-part")
@Scope("prototype")
public ThymeleafView someViewBean() {
    ThymeleafView view = new ThymeleafView("index"); // templateName = 'index'
    view.setMarkupSelector("#content");
    return view;
}
``` 

...que seleccionará perfectamente:

```html
<!DOCTYPE html>
<html>
  ...
  <body>
    ...
    <div id="content">
      Only this div will be rendered!
    </div>
    ...
  </body>
</html>
```




10.2 Especificar fragmentos en los valores de retorno del controlador
---------------------------------------------------

En lugar de declarar *beans de vista*, los fragmentos se pueden especificar 
desde los propios controladores utilizando la sintaxis de *expresiones de 
fragmento*. Al igual que en los atributos `th:insert` o `th:replace`:

```java    
@RequestMapping("/showContentPart")
public String showContentPart() {
    ...
    return "index :: content";
}
```

Por supuesto, nuevamente está disponible todo el poder de los selectores DOM, 
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
================================


11.1 Integración con `RequestDataValueProcessor`
-------------------------------------------------

Thymeleaf se integra a la perfección con la interfaz `RequestDataValueProcessor` 
de Spring. Esta interfaz permite interceptar las URL de enlaces, las URL de 
formularios y los valores de los campos de formulario antes de que se escriban 
en el resultado del marcado, además de añadir de forma transparente campos de 
formulario ocultos que habilitan funciones de seguridad como la protección 
contra CSRF (falsificación de solicitudes entre sitios).

Una implementación de `RequestDataValueProcessor` se puede configurar fácilmente 
en el contexto de la aplicación. Debe implementar la interfaz 
`org.springframework.web.servlet.support.RequestDataValueProcessor` y tener 
`requestDataValueProcessor` como nombre de bean:

```java
@Bean
public RequestDataValueProcessor requestDataValueProcessor() {
  return new MyRequestDataValueProcessor();
}
```

...y Thymeleaf lo utilizará de esta manera:

* `th:href` y `th:src` llaman a `RequestDataValueProcessor.processUrl(...)` 
  antes de renderizar la URL.
* `th:action` llama a `RequestDataValueProcessor.processAction(...)` antes de 
   renderizar el atributo `action` del formulario y, además, detecta cuándo se 
   aplica este atributo a una etiqueta `<form>` (que, en teoría, debería ser el 
   único lugar), y en ese caso llama a 
   `RequestDataValueProcessor.getExtraHiddenFields(...)` y añade los campos 
   ocultos devueltos justo antes de la etiqueta de cierre `</form>`.
* `th:value` llama a `RequestDataValueProcessor.processFormFieldValue(...)` para 
   renderizar el valor al que se refiere, a menos que haya un `th:field` 
   presente en la misma etiqueta (en cuyo caso `th:field` se encargará de ello).
* `th:field` llama a `RequestDataValueProcessor.processFormFieldValue(...)` para 
   renderizar el valor del campo al que se aplica (o el cuerpo de la etiqueta si 
   es un `<textarea>`).


> Cabe destacar que existen muy pocos escenarios en los que sea necesario 
> implementar explícitamente `RequestDataValueProcessor` en su aplicación. En la 
> mayoría de los casos, las bibliotecas de seguridad que utilice de forma 
> transparente, como por ejemplo la compatibilidad con CSRF de Spring Security, 
> lo usarán automáticamente.



11.1 Creación de URI para controladores
---------------------------------

Desde la versión 4.1, Spring permite crear enlaces a controladores anotados 
directamente desde las vistas, sin necesidad de conocer las URI a las que están 
mapeados dichos controladores.

En Thymeleaf, esto se logra mediante el método de objeto de expresión 
`#mvc.url(...)`, que permite especificar los métodos del controlador mediante 
las letras mayúsculas de la clase del controlador a la que pertenecen, seguidas 
del nombre del método. Esto es equivalente a la función personalizada 
`spring:mvcUrl(...)` de JSP.

Por ejemplo, para:

```java
public class ExampleController {

    @RequestMapping("/data")
    public String getData(Model model) { ... return "template" }

    @RequestMapping("/data")
    public String getDataParam(@RequestParam String type) { ... return "template" }

}
```
El siguiente código creará un enlace al mismo:
```html
<a th:href="${(#mvc.url('EC#getData')).build()}">Get Data Param</a>
<a th:href="${(#mvc.url('EC#getDataParam').arg(0,'internal')).build()}">Get Data Param</a>
``` 

Puedes leer más sobre este mecanismo en 
http://docs.spring.io/spring-framework/docs/4.1.2.RELEASE/spring-framework-reference/html/mvc.html#mvc-links-to-controllers-from-views


12 Integración con Spring WebFlow
============================


12.1 Configuración básica
-----------------------

Los paquetes de integración de Thymeleaf + Spring incluyen la integración con 
Spring WebFlow.

_Nota: Se requiere Spring WebFlow 2.5 o superior al usar Thymeleaf con Spring 5, 
mientras que solo se permiten versiones anteriores a WebFlow 2.5 al usar 
Thymeleaf con versiones anteriores de Spring._

WebFlow incluye funcionalidades AJAX para renderizar fragmentos de la página 
mostrada cuando se activan eventos específicos (_transiciones_). Para que 
Thymeleaf pueda gestionar estas solicitudes AJAX, será necesario usar una 
implementación diferente de `ViewResolver`, configurada de la siguiente manera 
(para Spring WebFlow 2.5 o superior):

```java
@Bean
public FlowDefinitionRegistry flowRegistry() {
    // NOTA: Es posible que se requiera configuración adicional en su aplicación.
    return getFlowDefinitionRegistryBuilder()
            .addFlowLocation("...")
            .setFlowBuilderServices(flowBuilderServices())
            .build();
}

@Bean
public FlowExecutor flowExecutor() {
    // NOTA: Es posible que se requiera configuración adicional en su aplicación.
    return getFlowExecutorBuilder(flowRegistry()).build();
}

@Bean
public FlowBuilderServices flowBuilderServices() {
    // NOTA: Es posible que se requiera configuración adicional en su aplicación.
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
    // Necesitamos configurar una implementación especial de ThymeleafView: FlowAjaxThymeleafView
    viewResolver.setViewClass(FlowAjaxThymeleafView.class);
    viewResolver.setTemplateEngine(templateEngine());
    return viewResolver;
}

```

Tenga en cuenta que la configuración anterior no está completa: aún deberá 
configurar sus manejadores, etc. Consulte la documentación de Spring WebFlow 
para obtener más información.

A partir de aquí, puede especificar las plantillas de Thymeleaf en sus estados 
de vista:

```xml
<view-state id="detail" view="bookingDetail">
    ...
</view-state>
```

En el ejemplo anterior, `bookingDetail` es una plantilla Thymeleaf especificada 
de la forma habitual, comprensible para cualquiera de los _solucionadores de 
plantillas_ configurados en el `TemplateEngine`.



12.2 Fragmentos AJAX en Spring WebFlow
-------------------------------------

> Tenga en cuenta que lo que se explica aquí es simplemente la forma de crear 
> fragmentos AJAX para usar con Spring WebFlow. Si no usa WebFlow, crear un 
> controlador Spring MVC que responda a una solicitud AJAX y devuelva un 
> fragmento HTML es tan sencillo como crear cualquier otro controlador que 
> devuelva una plantilla, con la única excepción de que probablemente devolverá 
> un fragmento como `"main :: admin"` desde el método de su controlador.

WebFlow permite especificar fragmentos que se renderizarán mediante AJAX con 
etiquetas `<render>`, como esta:

```xml
<view-state id="detail" view="bookingDetail">
    <transition on="updateData">
        <render fragments="hoteldata"/>
    </transition>
</view-state>
```

Estos fragmentos (`hoteldata`, en este caso) pueden ser una lista de fragmentos 
separados por comas, especificados en el marcado con `th:fragment`:

```xml
<div id="data" th:fragment="hoteldata">
    This is a content to be changed
</div>
```

_Recuerde siempre que los fragmentos especificados deben tener un atributo `id`, 
para que las bibliotecas JavaScript de Spring que se ejecutan en el navegador 
puedan sustituir el marcado._

Las etiquetas `<render>` también se pueden especificar mediante selectores DOM:

```html
<view-state id="detail" view="bookingDetail">
    <transition on="updateData">
        <render fragments="[//div[@id='data']]"/>
    </transition>
</view-state>
```

...y esto significa que no se necesita ningún `th:fragment`:

```html
<div id="data">
    This is a content to be changed
</div>
```

En cuanto al código que activa la transición `updateData`, tiene el siguiente 
aspecto:

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
