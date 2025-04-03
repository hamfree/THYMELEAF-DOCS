# Contributing to Thymeleaf

Thymeleaf is released under the Apache 2.0 license. If you would like to
contribute something, or want to hack on the code this document should help you
get started.


## Code of Conduct

This project adheres to the Contributor Covenant
[code of conduct][code-of-coduct].
By participating, you are expected to uphold this code. Please report
unacceptable behavior to [the project leads][thymeleaf-team].


## Using GitHub Issues

We use GitHub issues to track bugs and enhancements.
If you have a general usage question please ask on
[Stack Overflow][stackoverflow].
The Thymeleaf team and the broader community monitor the 
[`thymeleaf`][stackoverflow-thymeleaf] tag.

If you are reporting a bug, please help to speed up problem diagnosis by
providing as much information as possible.
Ideally, that would include a small sample project that reproduces the problem.


## Before submitting a Contribution

Before submitting a contribution that is not an obvious or trivial fix, 
get in contact with the [the project leads][thymeleaf-team] about your
ideas (an email should do). Let us discuss the possibilities with you so that
we make sure your contribution goes in the right direction and aligns with the
project's standards, intentions and roadmap.

Please understand that *not all contributions will be accepted and merged into
the project's repositories*. Talking about your planned contributions with the
project maintainers before creating pull requests can maximize the possibility
of your contributions being accepted.



## Signing the Contributor License Agreement

Before we accept a non-trivial patch or pull request we will need you to
sign a **Contributor License Agreement**.

There are two versions of the CLA:

   * **Individual CLA**: For individuals acting on their own behalf, i.e. not
     being backed by any company or government, and not making their
     contributions potentially under the effect of any contracts, agreements or
     laws that could cause their employeer (or any other entities) claim
     any rights on their contribution.
   * **Corporate CLA**: For corporate entities allowing some of their employees
     to contribute to Thymeleaf on the entity's behalf.

For more information on the CLA and the (very easy) process involving this
step, please have a look at the [Thymeleaf CLA repository][cla].



## Conventions and Housekeeping

### General Guidelines:

  - Obviously, **your code must both compile and work correctly**.
  - All your code should be easy to read and understand by a human. The same
    requirement applies to documentation.
  - Unless for specific artifacts such as documentation translations, all
    code, comments, documentation, names of classes and variables,
    log messages, etc. must be **in English**.
  - All contribured files must include the standard Thymeleaf copyright header.
  - Maximum recommended line length is 120 characters. This is not strictly
    enforced.
  - Indentation should be made with 4 spaces, not tabs. Line feeds should be
    UNIX-like (`\n`).
  - All source files should be pure ASCII, except `.properties` files which
    should be ISO-8859-1.
  - You shall add yourself as _author_ (e.g. Javadoc `@author`) to any files
    that you create or modify substantially (more than cosmetic changes).

### Specific Java Code Gudelines:

  - All your code should compile and run in the current minimum Java version
    of the project.
  - All your code should follow the Java Code Conventions regarding
    variable/method/class naming.
  - Number autoboxing and/or autounboxing is forbidden.
  - Every class should define a constructor, even if it is the no-argument
    constructor, and include a call to `super()`.
  - All method parameters should be declared as `final` so that they cannot be
    changed or reassigned in the method.
  - All non-nullable parameters in public methods should be first validated for
    non-nullity inside the code.
  - Existing Javadoc must be maintained along with performed changes. Addition
    of new Javadoc for public methods or code comments for any non-trivial
    algorithms is always welcome.
  - Writing unit tests for new, existing and modified code is always welcome
    too. For any new algorithms or functionality contributed, or substantial
    modifications made to existing ones, the team might consider these a
    requirement.




[cla]: https://github.com/thymeleaf/thymeleaf-org/blob/CLA_CURRENT/CLA/
[code-of-coduct]: https://github.com/thymeleaf/thymeleaf-org/blob/CoC_CURRENT/CoC/THYMELEAF_CODE_OF_CONDUCT.markdown
[thymeleaf-team]: https://www.thymeleaf.org/team.html
[stackoverflow]: https://stackoverflow.com
[stackoverflow-thymeleaf]: https://stackoverflow.com/tags/thymeleaf


# Contribuyendo a Thymeleaf

Thymeleaf se publica bajo la licencia Apache 2.0. Si desea contribuir o 
modificar el código, este documento le ayudará a empezar.

## Código de Conducta

Este proyecto se adhiere al [código de conducta][code-of-coduct] del Pacto del 
Colaborador.
Al participar, se espera que respete este código. Por favor, informe de 
cualquier comportamiento inaceptable a 
[los líderes del proyecto][thymeleaf-team].

## Uso de GitHub Issues

Usamos GitHub Issues para rastrear errores y mejoras.
Si tiene alguna pregunta sobre el uso general, pregunte en
[Stack Overflow][stackoverflow].
El equipo de Thymeleaf y la comunidad en general monitorean la etiqueta
[`thymeleaf`][stackoverflow-thymeleaf].

Si informa un error, por favor, ayude a acelerar el diagnóstico del problema 
proporcionando la mayor cantidad de información posible. Idealmente, esto 
incluiría un pequeño proyecto de muestra que reproduzca el problema.

## Antes de enviar una contribución

Antes de enviar una contribución que no sea una solución obvia o trivial, 
contacta con [los líderes del proyecto][thymeleaf-team] y comparte tus ideas (un 
correo electrónico bastará). Permítenos analizar las posibilidades contigo para 
asegurarnos de que tu contribución vaya en la dirección correcta y se ajuste a 
los estándares, las intenciones y la hoja de ruta del proyecto.

Ten en cuenta que *no todas las contribuciones serán aceptadas ni se integrarán 
en los repositorios del proyecto*. Hablar sobre tus contribuciones previstas con 
los mantenedores del proyecto antes de crear solicitudes de incorporación de 
cambios puede maximizar las posibilidades de que sean aceptadas.

## Firma del Acuerdo de Licencia de Colaborador

Antes de aceptar un parche o una solicitud de incorporación de cambios 
significativos, necesitarás firmar un **Acuerdo de Licencia de Colaborador**.

Existen dos versiones del CLA:

* **CLA Individual**: Para personas que actúan en nombre propio, es decir, que 
  no cuentan con el respaldo de ninguna empresa ni gobierno, y que no realizan 
  sus contribuciones bajo la influencia de contratos, acuerdos o leyes que 
  puedan dar lugar a que sus empleados (o cualquier otra entidad) reclamen 
  derechos sobre sus contribuciones.

* **CLA Corporativo**: Para entidades corporativas que permiten que algunos de 
  sus empleados contribuyan a Thymeleaf en nombre de la entidad.

Para obtener más información sobre el CLA y el sencillo proceso que implica este 
paso, consulte el [repositorio de CLA de Thymeleaf][cla].

## Convenciones y Mantenimiento

### Directrices Generales:

- Obviamente, **su código debe compilarse y funcionar correctamente**.
- Todo su código debe ser fácil de leer y comprender para una persona. El mismo 
  requisito se aplica a la documentación. - Salvo para artefactos específicos 
  como traducciones de documentación, todo el código, los comentarios, la 
  documentación, los nombres de clases y variables, los mensajes de registro, 
  etc., deben estar **en inglés**.
- Todos los archivos contribuidos deben incluir el encabezado de copyright 
  estándar de Thymeleaf.
- La longitud máxima de línea recomendada es de 120 caracteres. Esto no se 
  aplica estrictamente.
- La sangría debe ser de 4 espacios, no de tabulaciones. Los saltos de línea 
  deben ser similares a los de UNIX (`\n`).
- Todos los archivos fuente deben ser ASCII puro, excepto los archivos 
  `.properties`, que deben cumplir la norma ISO-8859-1.
- Debe agregarse como _autor_ (por ejemplo, Javadoc `@author`) a cualquier 
  archivo que cree o modifique sustancialmente (más allá de cambios 
  superficiales).

### Directrices específicas para el código Java:

- Todo su código debe compilarse y ejecutarse en la versión mínima actual de 
  Java del proyecto.
- Todo su código debe seguir las convenciones de código Java en cuanto a la 
  nomenclatura de variables, métodos y clases. - Se prohíbe el autoboxing y/o 
  autounboxing de números.
- Cada clase debe definir un constructor, incluso si es el constructor sin 
  argumentos, e incluir una llamada a `super()`.
- Todos los parámetros del método deben declararse como `final` para que no se 
  puedan modificar ni reasignar en el método.
- Todos los parámetros no nulos en los métodos públicos deben validarse primero 
  para verificar su no nulidad dentro del código.
- La documentación Java existente debe mantenerse junto con los cambios 
  realizados. La adición de nueva documentación Java para métodos públicos o 
  comentarios de código para cualquier algoritmo no trivial siempre es 
  bienvenida.
- La escritura de pruebas unitarias para código nuevo, existente y modificado 
  también es bienvenida. Para cualquier nuevo algoritmo o funcionalidad 
  aportada, o modificaciones sustanciales realizadas a los existentes, el equipo 
  podría considerarlos un requisito.

[cla]: https://github.com/thymeleaf/thymeleaf-org/blob/CLA_CURRENT/CLA/
[código de producto]: https://github.com/thymeleaf/thymeleaf-org/blob/CoC_CURRENT/CoC/THYMELEAF_CODE_OF_CONDUCT.markdown
[equipo de thymeleaf]: https://www.thymeleaf.org/team.html
[stackoverflow]: https://stackoverflow.com
[stackoverflow-thymeleaf]: https://stackoverflow.com/tags/thymeleaf