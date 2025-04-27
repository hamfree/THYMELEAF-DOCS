---
title: De HTML a HTML (vía HTML)
---


Conocer los fundamentos de la familia de estándares web HTML es fundamental al 
utilizar software como Thymeleaf. Al menos si se quiere comprender lo que se 
está haciendo.

El problema es que mucha gente conoce las tecnologías que utiliza para crear 
sitios web, pero desconoce su origen. Ha transcurrido un largo camino desde la 
creación de las primeras interfaces web, y desde entonces, cada nueva tecnología 
ha cambiado la forma en que desarrollamos para la web, desvalorizando gran parte 
de nuestro trabajo y, sobre todo, nuestros conocimientos.

Y ahora, con la llegada de HTML5, las cosas se han complicado aún más. 
*¿Qué es?* *¿Por qué es HTML en lugar de XHTML?* *¿No se consideraba perjudicial 
la sopa de etiquetas HTML?*

Así que demos un paso atrás y veamos cómo llegamos a donde estamos ahora y por 
qué.


En los años 90, existía el HTML...
----------------------------------

...y HTML era un estándar (o más correctamente, una *recomendación*) mantenido 
por el *Consorcio World Wide Web* (también conocido como W3C). A partir de un 
lenguaje llamado SGML, HTML definió un lenguaje de marcado basado en etiquetas 
para escribir documentos de hipertexto enriquecidos, altamente acoplado al 
protocolo utilizado para servirlos y sus recursos relacionados a través de la 
red: el *Protocolo de Transferencia de Hipertexto* (HTTP).

HTTP utilizaba *encabezados* de texto para definir qué se servía a los clientes 
y cómo. Uno de ellos era extremadamente importante: el encabezado 
`Content-Type`. Este encabezado explicaba a los navegadores el tipo de contenido 
que se les servía en un lenguaje llamado *MIME (Extensiones Multipropósito de 
Correo de Internet)*. El tipo MIME utilizado para servir documentos HTML era 
`text/html`:

```html
    Content-Type: text/html
```

HTML también definió una forma de comprobar si un documento era *válido*. Ser 
válido significaba básicamente que el documento se había escrito según las 
reglas HTML que dictaban qué atributos podía tener una etiqueta, dónde podía 
aparecer en el documento, etc.

Estas reglas de validez se especificaron mediante un lenguaje para definir la 
estructura de los documentos SGML llamado *Definición de Tipo de Documento* o 
DTD. Se creó una DTD estándar para cada versión de HTML, y los documentos HTML 
debían declarar la DTD (y, por lo tanto, la versión de HTML) a la que se 
ajustaban mediante una cláusula que debía aparecer en su primera línea: la 
*Declaración de Tipo de Documento* o cláusula `DOCTYPE`:

```html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
```


El modelo de objetos de documento y la sopa de etiquetas
--------------------------------------------------------

HTML se diseñó para mostrar documentos en navegadores, y a finales de los 90, 
estos navegadores eran desarrollados por empresas que competían ferozmente y que 
buscaban ofrecer el máximo número de funciones interesantes a sus usuarios. Dado 
que HTML solo definía reglas para el formato de documentos, muchas otras 
funciones quedaron a la imaginación de los desarrolladores de navegadores.

Una de las ideas más interesantes que surgieron en los navegadores fue la 
*interactividad del lado del cliente*. Esta interactividad se logró ejecutando 
*scripts*, en lenguajes como JavaScript, dentro del propio navegador, y dándoles 
la capacidad de manejar, modificar e incluso ejecutar eventos en partes del 
documento mostrado. Para ello, los navegadores tuvieron que modelar los 
documentos HTML como árboles de objetos en memoria, cada uno con su estado y 
eventos, y así nació el *Modelo de Objetos del Documento* (DOM).

El problema residía en que las reglas HTML para la correcta formación eran 
bastante laxas, mientras que los árboles DOM eran estructuras estrictamente 
jerárquicas. Esto implicaba que las diferentes interpretaciones de las 
posiciones y secuencias de las etiquetas HTML podían generar distintos árboles 
de objetos DOM en distintos navegadores. Si a esto le sumamos que estos 
distintos navegadores modelaban la API de los nodos DOM de distintas maneras 
(con distintos nombres, eventos, etc.), empezaremos a hacernos una idea de lo 
difícil que era crear interactividad entre navegadores en aquel entonces.

Es más: mientras todo esto sucedía, los navegadores se habían vuelto bastante 
indulgentes con los autores de HTML, permitiéndoles escribir documentos HTML mal 
formados (*sopa de etiquetas*) corrigiendo automáticamente sus errores. Esto 
llevó a los autores de HTML a crear documentos aún peor formados, y luego a los 
navegadores a permitir aún más errores de formato, lo que contribuyó a un ciclo 
bastante destructivo. Y adivina qué: cada navegador corregía todos estos errores 
de forma diferente. ¡Genial!

El W3C finalmente estandarizó la API DOM y un lenguaje para scripting en 
navegadores web: JavaScript (aunque por razones complejas insistieron en 
llamarlo ECMAScript). Sin embargo, el daño causado por el mundo de las sopas 
de etiquetas, sumado a la lenta adopción total de estos estándares por parte de 
los desarrolladores de navegadores —en muchos casos por temor a que perjudicaran 
la compatibilidad con versiones anteriores—, tuvo consecuencias que aún influyen 
en la forma en que creamos aplicaciones web hoy en día.


Introducir XML
--------------

Some time after HTML became a widely spread language, the W3C developed
a new specification called XML (*eXtensible Markup Language*), aimed at
the representation of general-purpose data (not only web) in the form of
hierarchical markup text.

XML was extensible in that it allowed the definition of purpose-specific
languages (tags and their attributes) to fit the needs of specific
scenarios. But HTML documents were not well formed from the XML
perspective, XML and HTML remained in fact incompatible languages. It
was not possible to express HTML as an XML *application*.

Being strictly hierarchical and removing the structural ambiguities of
HTML, XML documents were more directly translatable to standardized DOM
trees (a process known as *XML Parsing*). Also given the fact that XML
was a text-based language, and that text is a sort of
technology-agnostic format (as opposed to binary), XML became especially
suited for the cross-platform interchange of data across the internet.
In fact, it led to the birth of the now-ubiquitous *Web Services*
technologies.


HTML + XML = XHTML
------------------

At some point, driven by the obvious usefulness of XML and the fact that
it could make web documents more extensible and interoperable (like, for
example, producing more predictable DOMs across browsers), the W3C
decided to reformulate HTML as an XML dialect (or *application*) instead
of an SGML one, and so XHTML was born.

XHTML required web authors to write their documents as well-formed XML,
which introduced some formatting rules that didn't exist in HTML before:
tags should always be closed, attributes should always be escaped and
surrounded by quotes, etc.

The introduction of XHTML and the transformation of web documents into
well formed XML was generally perceived as a step forward, because it
would allow higher levels of standardization across browsers, less space
for authoring errors that had to be corrected in browser-specific ways,
and easier parsing and automated processing of web pages.

As a part of this, XHTML introduced a controversial concept coming
directly from XML and known as *Draconian Error Handling*, which meant
that any interpreter of XML -- including now a browser -- should fail
immediately should any kind of format error be found in the XML document
being processed. In practice, this meant that XHTML authors would have
to create perfectly well-formed documents or accept the fact that
browsers would never be able (in fact, allowed) to display them at all.

For validation, the XHTML 1.0 specification defined a set of DTDs that
could be used in `DOCTYPE` clauses: `XHTML 1.0 Strict`,
`XHTML 1.0 Transitional` and `XHTML 1.0 Frameset`. The first one was
meant for *pure* XHTML documents that didn't use any deprecated tags
coming from HTML, the second one for transitional documents that still
made use of deprecated tags and attributes, and the third one for
frameset pages.

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
```

But one of the most important aspects of XHTML was that it also
introduced a new MIME type, which was the one that every web server was
supposed to use for serving XHTML so that browsers knew that they had to
use their XHTML parser and engine instead of their HTML equivalents.
This was `application/xhtml+xml`:

```html
    Content-Type: application/xhtml+xml
```


Crashing down to (XHTML's) reality
----------------------------------

Just after its introduction, everything looked bright for XHTML. We
developers should just have to wait for browsers to fully implement it
and the world of web development would suddenly look much happier...

Trouble is, that never happened.

What happened was that one specific browser simply denied implementing
support for the `application/xhtml+xml` content type. Guess which one.
Yeah, exactly, that one. Internet Explorer.

Versions of IE older than 11 showed a download dialog when you tried to access a
document served with XHTML's own content type, and that of course meant
that you could not use that content type if you wanted to be able to display
your web site to IE users. By the time this was corrected,
it was simply too late.

Fortunately -- or maybe unfortunately -- The XHTML 1.0 specification
included an appendix that stated that XHTML 1.0 content could also be
served using the old `text/html` content type from the HTML times, in
order to ease the transition. And that's exactly what most of us have
been doing the past several years: creating XHTML 1.0 content, and then
serving it as `text/html`. Given that the XHTML 1.0 specification was
published in 2000, the *transition* has taken long.

But the fact is that when you serve content as HTML instead of XHTML
browsers will use their HTML engines for it, and not the XHTML-specific
ones. And although their HTML engines have been XHTML-enabled, they
still have to provide backwards compatibility for old HTML 4 code ---
which makes them very tricky pieces of software -- and importantly, they
lack some of the most XML-ish features of XHTML, starting with...
Draconian Error Handling.

And if you don't have Draconian Error Handling, you have a forgiving
engine that will let you serve documents that are not well formed,
automagically correcting your errors. And if you know the browser will
correct your errors (in a browser-specific way), you will probably never
correct your documents... and so the HTML horror story still goes on.

Knowing this, think that you've probably never really created a truly
XHTML web site. What you've done is (probably ill-formed) XHTML
documents served and displayed as plain old HTML. How about that?

But it went worse, because in 2002 `XHTML 1.1` removed the possibility
of using the HTML content type, therefore allowing only
`application/xhtml+xml`. The problem was that, instead of this forcing
Internet Explorer to support `application/xhtml+xml`, which didn't
happen, this restriction simply turned XHTML 1.1 into as much a
mythological creature as Nessie. Almost no one ever used it.

In 2009, the W3C allowed again the use of `text/html` with XHTML 1.1
but, again, it was too late.


Towards HTML5: A divorce story
------------------------------

At some point (specifically, 2004), some browser makers realised that
the existing XHTML specifications were evolving too slowly to cope with
the increasing demands of the web (video, audio, richer application
interfaces...), and that the W3C was increasingly pushing them towards
creating stricter interpretations of documents that could end up
rendering huge amounts of (ill-formed) existing code useless.

They wanted to enhance web applications with capabilities like video,
audio, local storage, or advanced form processing, and in fact they
could do it by just adding those features in a browser-specific way, but
they didn't want to go the non-interoperable way again. They needed the
standards to evolve and include these new features.

Nevertheless, there was a problem with evolving the existing standards
of the time (namely XHTML): there were still lots and lots of web sites
and applications still relying on legacy HTML out there, and if those
cool new features were standardized by going the XHTML ultra-strict way,
all those applications would never be able to use the new features
unless they were completely rewritten. And everybody wanted a more
interoperable and standard web, but not at the cost of throwing away
many years of work done by millions of web authors.

So these makers (along with other individuals) presented the W3C with
the idea of evolving HTML in a way that made all (or most) existing HTML
and XHTML code still valid as *new HTML* while providing powerful new
features for web applications and -- importantly -- clearly defining the
way in which error handling should be done.

This latter point meant that instead of failing on the first error,
browsers would know *by specification* how to perform the automagical
correction of errors created by web authors and therefore would react to
them in exactly the same way, effectively turning HTML code (be it
XML-formed or not) fully cross-browser. You would still be recommended
to create XML-formed code for new sites, but if you didn't fancy or you
still had some tons of old legacy HTML (and most certainly you had), you
would still be invited to join the party. See that old HTML site there?
Let's add some video to it! It all sounded quite sensible.

But the fact is, all of this didn't sound quite as well to W3C back in
2004, and they rejected the proposal and decided to go strictly the
XHTML way. HTML was dead for them, there was no reason to resurrect it,
and `XHTML 2.0` was the future.

This led to divorce. The proponents of this new concept for HTML, a
group that included individuals from Opera Software, the Mozilla
Foundation and Apple, left the W3C and founded the *Web Hypertext
Application Technology Working Group (WHATWG)* with the aim of defining
what we today know as HTML5.

Finally, in 2007, the W3C created a working group for *next-generation
HTML*, which later accepted to join efforts with WHATWG, effectively
adopting HTML5 as their working specification and future deliverable.
W3C and WHATWG were now united for creating HTML5, and in 2009 the W3C
just let XHTML 2.0 die by closing the group working on its
specification.

HTML5 was now the *only* future of web standards.


So what is HTML5?
-----------------

HTML5 is a set of standards -- still under development as of 2011 ---
evolving from current HTML 4 and XHTML specifications and aimed at:

-   Adding advanced new capabilities to HTML that effectively move web
    development slightly away from the document-oriented philosophy and
    towards a more application-oriented one. Such capabilities are
    called *HTML5 features* and are in some cases defined by standards
    on their own, apart from the HTML5 core one. HTML5 features include,
    among others: video, audio, drawing canvas, geolocation, local
    storage, offline support and advanced form-related capabilities.
-   Providing a pain-free path for migration from HTML and XHTML, which
    enables the adoption of HTML5 with little or no rewriting of code at
    all.
-   Providing a standard way of handling code errors, so that ill-formed
    HTML5 code will perform in the same predictable way in all browsers.

From a practical point of view, this means that (probably all of) your
current HTML and XHTML code will be considered valid HTML5 just by
changing your `DOCTYPE` to the HTML5 one:

```html
<!DOCTYPE html>
```

And by serving your content with content type `text/html`:

```html
    Content-Type: text/html
```

And here you might be thinking: why does that `DOCTYPE` specify no DTD
at all? Because there isn't one. HTML5 has no DTD because the rules that
define whether a document is valid HTML5 or not are defined as
human-readable text in the specification itself, but cannot be expressed
in the DTD language.

But this does not mean that an HTML5 parser and/or engine cannot
validate. It can. It simply has to be a piece of software especially
devoted to HTML5 parsing including specific code programmed for
executing the rules that are involved in validating HTML5 (as opposed to
reading those rules from a DTD file). Even if the specification is now
quite flexible, it still *is* a specification, and you have to conform
to it.

But if there is no DTD, then why have a DOCTYPE clause at all? Because a
DOCTYPE clause is needed in order to make browsers display documents in
*Standards Mode* (as opposed to *Quirks Mode*). The clause
`<!DOCTYPE html>` is the minimum valid DOCTYPE declaration possible, and
that is exactly all we need. It just acts as a switch.


Can I use HTML5 already?
------------------------

Mostly yes. While (as of 2016) there is no browser that fully
implements the whole HTML5 feature set, most of the common ones do
implement a large part of it. So as long as your users are not stuck
with very old versions of (now-defunct) Internet Explorer, you should
be fine in most scenarios.

Also, note that browser support actually evolves with time not only
because of the quick pace at which browsers release new versions, but
also because the specification itself is still work in progress.

For a list of HTML5 features and the corresponding browser support, check the
[Can I use...](http://caniuse.com/) website.  Notably, the HTML5 category list
for all of the features: [http://caniuse.com/#cats=HTML5](http://caniuse.com/#cats=HTML5)



And what about XHTML5? Does that exist?
---------------------------------------

In theory, yes. XHTML5 is just HTML5 served with:

```html
    Content-Type: application/xhtml+xml
```

But note that IE didn't support this until version 11 (Microsoft
Edge does support it). So again, think about your users' browser capabilities

Also, note that the difference between HTML5 and XHTML5 is the
content type and *only* the content type, because an XML-well-formed 
HTML5 document is in fact a perfectly valid HTML5 document. This is quite
different to the relation between HTML4 and XHTML 1.0/1.1, which were
incompatible languages.

