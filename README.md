# sahib
`sahib` ist eine grafische Oberfläche für Schild-Datenbanken. Schild ist das offizielle Schulverwaltungssystem in NRW.

Jetzt gleich testen unnter [sahib.hmt.im](http://sahib.hmt.im). Die Daten sind Testdaten der Fa. Ribeka.

Im Gegensatz zu Schild ist `sahib` quelloffen und kann jederzeit angepasst werden. Es baut auf die [`schild`-Bibliothek](https://github.com/hmt/schild) auf und kann prinzipiell auf alle in Schild zur Verfügung stehenden Daten zugreifen. Diese Daten können ausgelesen und mit Hilfe von `sahib` formatiert im Browser dargestellt und in PDF umgewandelt werden.

`sahib` ersetzt Schild nicht, bietet aber die Möglichkeit, alternativ Dokumente zu erstellen. Im Gegensatz zum Formulardesigner, der in Schild eingebaut ist, kann `sahib` auf viele Bibliotheken aus der professionellen Webentwicklung zurückgreifen, die bereits lange erprobt und dokumentiert sind. Die Erzeugung hochwertiger PDF-Dokumente in `sahib` wird ausschließlich über HTML und CSS gesteuert.

## Funktionsweise von sahib
`sahib` baut auf moderne Webtechnologien, die unabhängig ständig weiter entwickelt und gepflegt werden. `sahib` ist im Prinzip nur eine Schnittstelle zwischen Schild und Dokument, die für die Abfrage der Daten aus der Schild-Datenbank zuständig ist und dafür sorgt, dass die Dokumente alle notwendigen Daten bekommen.

Sofern Schild eine MySQL-Datenbank (oder andere externe Datenbank) verwendet, auf die `sahib` zugreifen kann, steht einem Einsatz nichts im Weg.

`sahib` läuft als Webanwendung im Browser und greift direkt auf die Schild-Datenbank zu. Es erwartet eine Anmeldung mit dem Schild-Benutzernamen.

Die Benutzerschnittstelle ist ein Suchfenster, in dem man nach Schülern oder Klassen suchen kann.

Wird aus dem Dropdown-Menu eine Klasse oder ein Schüler ausgewählt, erscheint die Klassen- oder Schüleransicht mit allgemeinen Informationen.

Zwei Knöpfe ermöglichen die Auswahl eines bestimmten Abschnitts (oder Halbjahr) und eines Dokuments. Wie in Schild muss zunächst das Jahr und der Abschnitt gewählt werden, damit passend dazu ein Dokument erzeugt werden kann.

Je nach Schulform oder Bildungsgang kann nun ein Dokument ausgewählt und angezeigt werden. Entsprechend der Datenlage folgen Warnmeldungen oder die vollständige Anzeige des Dokuments. Ebenso besteht die Möglichkeit der PDF-Erzeugung. Alle Dokumente können als Klassensatz oder für einzelne Schüler erzeugt werden.

`sahib` liefert eine Reihe von Standard-Formularen mit, die angepasst oder neu geschrieben werden können. Sie sind im repository unter `dokumente` einzusehen.

Dokumente verwenden unter `sahib` die Templatesprache [slim](http://slim-lang.com/), die einen vereinfachten HTML-Syntax verwendet:

```html
<b>fetter Text</b>
normaler Text
<table>
  <tr>
    <td>
      eine Tabelle
    </td>
    <td>
      mit ein bisschen Text
    </td>
  </tr>
</table>
```

kann in slim auch so geschrieben werden:
```slim
b fetter Text
|normaler Text
table
  tr
    td eine Tabelle
    td mit ein bisschen Text
```

Es entfallen die vielen Klammern und es wird lesbarer. Ein weiterer Vorteil ist dynamischer Inhalt, der natürlich beim Einsatz von dynamischen Dokumenten unablässig ist.

So ist z.B. der Kopf eines Zeugnisses so formuliert:
```slim
    b #{s.anrede} #{s.vorname} #{s.name}
    br /
    |geboren am #{(s.geburtsdatum).strftime("%d.%m.%Y")} in #{s.geburtsort}
    br /
    'war vom #{s.beginn_bildungsgang.strftime("%d.%m.%Y")} bis zur Aushändigung des Zeugnisses
```
Dabei ersetzt slim automatisch den eingebundenen Ruby-Code, der sich zwischen den `#{}` aufhält. Geübten Programmierern fällt auf, dass hier interpolierten Strings zum Einsatz kommen.

Da die meisten Dokumente auf zwei Objekten aufbauen, dem Schüler- und dem Abschnittsobjekt, gestaltet sich die dynamische Abfrage recht komfortabel. Über `s.ein_datenbankfeld` lassen sich alle Informationen aus der Datenbank abrufen, inklusive einiger Hilfsmethoden, wie z.b. die Anrede, Geschlecht oder auch die Fachklasse etc. Es empfiehlt sich die Dokumente genauer anzuschauen und damit zu experimentieren.

Alle Dokumente, die im Dokumentenordner angelegt werden, sollten in der Datei `config/doc_einstellungen.yml` angemeldet werden, damit sie sich problemlos in `sahib` einfügen und entsprechend der eigenen Vorgaben nur für bestimmte Gruppen verwendet werden können. Ebenso können Einschränkungen zum verwendeten Zeitraum angegeben werden, Logos dynamisch eingebunden werden etc.

Da die Dokumente in HTML und CSS angelegt werden, kann auf eine Vielzahl von CSS-Bibliotheken zurückgegriffen werden, die hochwertige Typografie liefern und moderne Grid-Verfahren anbieten. Exaktes Positionieren von Elementen ist kein Wunsch mehr, es ist möglich.

In den eingebundenen Dokumenten wird die [Bootstrap-Bibliothek](http://getbootstrap.com/) verwendet, die ständig weiterentwickelt wird und hochwertiges Design liefert, das nicht nur für das Web geeignet ist. Grids lassen mehrspaltiges Positionieren von Text und Elementen problemlos zu und ermöglichen ein schnelles Arbeiten.

Da `sahib` auf Webtechnologien aufbaut und moderne Browser eine Vielzahl von Formaten unterstützen, kann in den Dokumenten ohne Probleme auf Vektorgrafiken zurückgegriffen werden. Frei skalierbare Logos sind kein Problem mehr und Pixel beim Druck von Zeugnissen gehören der Vergangenheit an.

Zur Erzeugung der PDF wird ebenfalls ein Browser auf dem Server verwendet. Die Bibliothek [slimer.js](https://slimerjs.org/) startet auf dem Server eine Firefox-Instanz und druckt im Hintergrund ein PDF, das am Browser wieder ausgegeben wird. Damit kann man sichergehen, dass am Bildschirm und auf dem Drucker identische Ergebnisse geliefert werden.

Da im Browser alle Daten schon in endgültiger Fassung angezeigt werden und alle Dokumente aus HTML und CSS bestehen, kann auch direkt im Browser mit Hilfe der Entwicklerwekzeuge nach Fehlern gesucht und Feineinstellungen vorgenommen werden. Es muss nicht geraten werden, welche Einstellung verändert werden muss, im Browser kann direkt verändert und angepasst werden bei gleichzeitiger Ansicht des Ergebnisses. Das macht auch die Erstellung komplizierter Dokumente sehr komfortabel.

## Installations
Zwei Installationsmöglichkeiten stehen zur Auswahl, einmal über Docker und einmal von Hand. Die Installation mit Docker ist leider noch nicht dokumentiert und es steht auch noch kein Image bereit. Wer sich auskennt, `slimerjs` muss beim letzten `COPY` relativ zu `sahib` mit eingebunden werden, sonst fehlt es.

Um `sahib` von Hand zu installieren, sollte es als git-Repository heruntergeladen werden, damit es leicht zu aktualisieren bleibt. Dazu sollte [git](https://git-scm.com) installiert sein. Ebenso wird die Programmiersprache [Ruby](https://ruby-lang.org) erfordert, da `sahib` ein Ruby-Script ist. Sobald vorhanden, kann es losgehen

```sh
git clone git@github.com:hmt/sahib.git
```

Anschließend alle nötigen Gems installieren:

```sh
cd sahib
bundle install
```

Um `sahib` zu starten wird erwartet, dass eine Schild-Datenbank eingerichtet und zugänglich ist. Dazu müssen in die Datei `config/env_init.yml` alle nötigen Daten eingetragen werden.

```sh
development:
  S_ADAPTER: mysql2
  S_HOST: 192.168.178.55
  S_USER: schild
  S_PASSWORD: schild_passwort
  S_DB: schild_db
  SLIMERJSLAUNCHER: /usr/bin/firefox
  SLIMER_SSL_PROFILE: /home/sahib/.innophi/slimerjs/ulakm.AllowSSL
```

Sobald alles vorbereitet ist, kann der Server gestartet werden:

```sh
puma
```

Der Puma-Server startet auf Port 9292 und `sahib` kann im Browser unter [http://localhost:9292](http://localhost:9292) erreicht werden. Wenn alles geklappt hat, stehen nun alle eingetragenen Schüler zur Verfügung.

Für die Erzeugung der PDF wird ein PDF-Renderer vorausgesetzt. Sahib
verwendet `slimer.js`, das auf Firefox zurückgreift. Es müssen also
beide Programme installiert und erreichbar sein. Auf einem Server bietet
es sich also an, z.B. xvfb-run zu installieren (Linux), damit man
headless arbeiten kann, d.h. keine grafische Oberfläche zum Starten von
Firefox braucht.

## Hinweis
Sahib ist nur ein weiteres Beispiel zur Nutzung des `schild`-Gems. Weitere Dokumente können entworfen und dem Repository hinzugefügt werden. `sahib` wird an einem Berufskolleg genutzt, möglicherweise haben andere Schulformen andere Bedürfnisse. In den meisten Fällen lassen sich `sahib` und `schild` recht schnell erweitern.

Da meines Wissens in Schild die Bildungsgänge und die Bezeichnungen der erlangten Abschlüüse nicht eingetragen sind, können diese in einer weiteren yaml-Datei hinterlegt und bei Bedarf ausgelesen werden. Dazu bitte `config/strings.yml` anschauen.

Als Unterbau für `sahib` dient [sinatra](https://github.com/sinatra/sinatra), ein Mikro-Framework für Webanwendungen.

## Lizenz
[sahib](https://github.com/hmt/sahib) von [HMT](https://github.com/hmt) ist lizenziert unter der MIT-Lizenz.

The MIT License (MIT)

Copyright (c) 2015-2016 HMT

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
