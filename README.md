# sahib

`sahib` ist ein Report-Werkzeug für Schild und kann den in Schild
integrierten Report-Designer vollständig ersetzen. Die Arbeitsweise von
`sahib` unterscheidet sich jedoch grundlegend und spricht möglicherweise
nur einen Teil der Schild-Benutzer an. Schild ist das offiziell vom Land
NRW unterstützte Schulverwaltungssystem für alle Schulformen.

## Eigenschaften
Im Gegensatz zu Schild ist `sahib` quelloffen und kann jederzeit
angepasst werden. Eine frei zugängliche Kopie des Programms ist unter
[https://github.com/hmt/sahib](https://github.com/hmt/sahib) einsehbar
und enthält die aktuellen Installationshinweise und geprüfte Versionen.
Auch wenn nicht immer tagesaktuelle Änderungen sichtbar sind, wird
`sahib` regelmäßig erweitert und seit 2014 aktiv an einem BK eingesetzt.

## Vorteile
`sahib` ist ein Report-Werkzeug, das auf die Schild-Datenbank direkt
zugreift und dadurch die Daten beliebig verarbeiten kann. Im Gegensatz
zum Report-Designer von Schild, verwendet `sahib` HTML-Reports zum
Erstellen von Dokumenten. Diese Dokumente können dadurch im Browser
angeschaut oder als PDF zum Drucken und Archivieren verwendet werden.

Daraus ergeben sich mehrere praktische Vorteile, die im folgenden näher
erläutert werden sollen.

HTML-Reports lassen sich relativ einfach erstellen. Es sind im Prinzip
ganz normale Web-Seiten, die jedoch Platzhalter für Name, Klasse, etc.
verwenden. Da als Unterbau für `sahib` die Programmiersprache Ruby
verwendet wird, können neben einfachen Platzhaltern auch komplexe
Funktionen in die Reports eingebaut werden, die jede beliebige Schleife,
Abfrage und sonstiges verwirklicht. Alle Informationen, die zusammen ein
Dokument ergeben, können mit einem einzigen Textdokument erstellt werden
und benötigen keine Subreports. Um Funktionen wiederholt verwenden zu
können, werden sog. _Partials_ verwendet.

Ebenfalls können für diese HTML-Reports praktisch alle Grafikformate
verwendet werden, die im Browser dargestellt werden können. Dies ist
insbesondere für die Verwendung von Logos praktisch, da hier die frei
skalierbaren SVG-Grafiken zum Einsatz kommen können, die in beliebiger
Größe immer perfekt aussehen und scharfe Konturen bilden. Ein Format,
das der Report-Designer in Schild nicht zulässt.

HTML ist ein gängiger Standard und kann mittels CSS perfekt gesteuert
werden. Selbst ohne umfangreiche Anpassungen werden einfache Dokumente
gut aussehen und es gibt keine verzerrten oder gestauchten Absätze mehr.
Auch die Lücken zwischen Fließtext und Platzhaltern gehören der
Vergangenheit an. Alle Elemente auf der Seite können individuell
platziert werden und ermöglichen ein gleichmäßiges Erscheinungsbild.

Es können alle verfügbaren Fonts verwendet werden und der Browser
kümmert sich von selbst um die richtige Einstellung der Textabstände. Es
ist kein manuelles Verschieben mehr notwendig. Auch muss nicht mühsam
mit der Maus ein Element platziert werden, alle Anweisungen werden mit
Hilfe von CSS konkretisiert und sollte es mal schwerfallen, ein Element
richtig zu platzieren, dann können die umfangreichen Enwicklerwerkzeuge
im Browser verwendet werden, um Fehler im erstellten Dokument zu finden.
Und das ohne zwischen Report und Vorschau zu wechseln.

HTML und CSS sind im Internet hervorragend dokumentiert und sind
international standardisiert. Viele Bibliotheken erleichtern es
zusätzlich, besondere Effekte zu erzeugen oder auf erprobte Lösungen
zurückzugreifen.

Ein weiterer Vorteil von textbasierten Reports ist die Möglichkeit des
Austauschs. Reports können problemlos verschickt und ausprobiert werden,
Fehler werden sofort im Browser angezeigt. Ebenso können Textdateien mit
Hilfe von Werkzeugen wie git versioniert werden, d.h. mehrere Versionen
des gleichen Reports können übereinander gesichert werden, ohne dass
vorherige Versionen dabei verloren gehen.

Da einige Elemente der verschiedenen an der Schule zu erzeugenden
Dokumente recht hohe Ähnlichkeiten aufweisen, besteht die Möglichkeit
sogenannte Partials zu verwenden. Partials sind kleine Schnipsel, die
von mehreren Reports gleichzeitig verwendet werden können ohne den
gleichen Abschnitt jedes Mal neu zu schreiben. So bietet es sich z.B.
an, die Notentabelle in verschiedenen Zeugnissen zu nutzen und dabei nur
einmal zu schreiben. Ebenso können Textschnipsel von mehreren Reports
geteilt werden, die häufig in Dokumenten erscheinen, z.B. die Hinweise
auf Notenstufen, Rechtsmittel etc.

Unter den gegebenen Voraussetzungen wird hoffentlich deutlich, dass
`sahib` anders ist und möglicherweise Einstiegshürden aufstellt. Mit
zunehmendem Dokumentenaufkommen verringert sich jedoch der Aufwand und
neue Reports lassen sich immer schneller erstellen. Sobald ein Pool von
Reports besteht, auf den zurückgegriffen werden kann, ist das Ändern
oder Erstellen neuer Reports eine Aufgabe von wenigen Minuten. Kopieren
eines ähnlichen Reports, ändern der wesentlichen Inhalte und optische
Anpassungen. Damit ist der neue Report sofort einsatzbereit.
Grundsätzlich kann der Report während der Erstellungsphase bereits im
Browser betrachtet und korrigiert werden.

## Templates
Dokumente werden, wie oben erwähnt, mit Hilfe von HTML-Reports erstellt,
die ein Gerüst erstellen und anschließend mit Daten aus der
Schild-Datenbank auffüllen. Diese Reports sind technisch gesehen keine
reinen HTML-Dateien, da sie den Steuercode für die Platzhalter,
Schleifen und Abfragen enthalten. Sie sind ihnen aber sehr ähnlich und
kompatibel. D.h. ein korrektes HTML-Dokument wird immer auch korrekt
dargestellt.

Die nachfolgende Designentscheidung für `sahib` mag dem Autor praktisch
erscheinen, anderen evtl. nicht und lässt sich bei interessierter
Nachfrage grundsätzlich relativ schnell erweitern und sollte daher kein
Hinderungsgrund zum Einsatz von `sahib` darstellen.

Die Reports verwenden kein reines HTML sondern eine Template-Sprache
namens [slim](http://slim-lang.com/). Slim unterscheidet sich wesentlich
von _normalem_ HTML, da grundsätzlich nur öffnende Tags verwendet werden
und Verschachtelungen mit Hilfe von Leerzeichen erzeugt werden. Der
Vorteil ist ein wesentlich leichter zu lesender Reports und keine
eckigen Klammern. Ebenfalls ist slim für den Einsatz von Steuercodes
optimiert. Allerdings ist es auch in slim möglich, reguläres HTML zu
verweden, das aber nicht besonders sinnvoll ist.

## Systemvoraussetzungen
`sahib` kann auf zwei Arten ausgeführt werden. Zum einen kann man
`sahib` als einfaches Script ausführen oder aber die Containerlösung
verwenden, die üblicherweise zu empfehlen ist und im folgenden
beschrieben wird.

`sahib` wurde ausführlich unter verschiedenen Linux-Distributionen
getestet und läuft ohne Einschränkungen auch auf älteren Systemen
relativ schnell. Geschwindigkeit orientiert sich hierbei an der
Erzeugung von Dokumenten im Vergleich zum Report-Designer unter Schild.
Mehrere hundert Seiten Dokumente lassen sich selbst auf einfacher
Hardware in wenigen Sekunden als PDF erzeugen und anzeigen. Das Ergebnis
ist jedefalls deutlich schneller als Schild auf vergelichbarer Hardware.

Damit die Containerlösung mit Docker verwendet werden kann, muss ein
64-Bit Linux vorhanden sein, theoretisch sollte auch Windows oder MacOS
als Host-System möglich sein, wurde aber bisher auf Grund mangelnder
Hardware nicht getestet.

Ebenfalls muss der verwendete Rechner Zugriff auf die von Schild
verwendete MySQL-Datenbank haben, damit die Daten abgefragt werden
können. Ein einfacher Lesezugriff ist ausreichend, `sahib` selbst führt
keine Schreibzugriffe auf die Datenbank aus.

Ebenfalls sollte der Rechner, wenn `sahib` von mehreren Rechnern aus
genutzt werden soll, am Netzwerk angeschlossen sein, damit alle
Schild-Benutzer Zugriff auf die Dokumente haben. Ansonsten kann `sahib`
nur vom jeweiligen Rechner aus verwendet werden. Grundsätzlich ist
`sahib` für den Serverbetrieb vorgesehen.

## Technische Grundlagen
`sahib` ist ein [Ruby](https://ruby-lang.org)-Script, das einen
HTTP-Server startet und lediglich die Suche von bestimmten
Schülergruppen unterstützt. Es können entweder einzelne Schüler  oder
Klassen gesucht und angezeigt werden. Das ist die absolute
Grundausstattung und alle weiteren Eigenschaften werden über
Erweiterungen bzw. Reports eingebunden.

`sahib` baut auf das [`schild`-Gem](https://github.com/hmt/schild) auf
und kann prinzipiell auf alle in Schild zur Verfügung stehenden Daten
zugreifen. Als Unterbau dient
[sinatra](https://github.com/sinatra/sinatra), ein Mikro-Framework für
Webanwendungen. Momentan beschränken sich die verfügbaren Daten auf
Tabellen, die für das BK relevant sind. Weitere Tabellen können jedoch
problemlos hinzugefügt werden, wenn dies gewünscht wird. Bisher wurde
aus Mangel an Einsatzgebieten darauf verzichtet.

## Installation
Es wird zwischen zwei möglichen Installationsarten unterschieden, zum
einen mit Hilfe von Docker-Containern, zum anderen über eine eigene
Laufzeitumgebung. Beide Methoden werden näher beschrieben.

Werden Docker-Conainer verwendet, reduziert sich die vorausgehende
Arbeit erheblich, ist also zu empfehlen.

Insgesamt ist es jedoch praktisch eine gemeinsame Grundlage zu schaffen,
damit unter Umständen beide Methoden gleichwertig benutzt werden können,
was durchaus vorteilhaft ist. Mehr dazu in den beiden Abschnitten.

`sahib` verwendet Konfigurationsdateien, um zwischen verschiedenen
Umgebungen unterschiedliche Einstellungen zuzulassen. Dies kann nützlich
sein, um z.B. mehrere Schild-Datenbanken zu verwalten oder eigene
Testumgebungen zu entwerfen. Wichtig ist jedoch zu wissen, dass `sahib`
mit nur jeweils einer Datenbank pro Instanz läuft und für den
Datenbankwechsel mit neuen Konfigurationsdateien gestartet werden muss.

Im `sahib`-Repository mit dem Quellcode befinden sich bereits
Standardeinstellungen, die als Grundlage verwendet werden sollten.

Dazu bietet es sich an, das `sahib`-Repository zu klonen, um alle
Standardeinstellungen und Verzeichnisse fertig eingerichtet zur
Verfügung stehen zu haben:

```bash
git clone https://github.com/hmt/sahib.git
```

Dazu sollte man auf dem System [git](https://git-scm.com/) installiert
haben. Das ist insbesondere im Hinblick auf weitere Updates sinnvoll.
Zum Testen reicht allerdings auch eine Downloadversion, die
[hier](https://github.com/hmt/sahib/archive/master.zip) verfügbar ist.

Im `sahib`-Verzeichnis befinden sich nun alle benötigten Dateien, die
nun für die entsprechende Installationsmethode angepasst werden müssen.

**WICHTIG**
Für Testzwecke ist `sahib` vollständig eingerichtet und kann direkt über
Docker gestartet werden. Die Konfigurationsdatei sollte dann nicht
geändert werden.

Sobald der eigene Datenbankserver mit den _echten_ Schild-Daten
verwendet werden soll, muss eine `*.env`-Datei angelegt werden, hier
soll sie `beispiel.env` heißen und befindet sich im
`config`-Verzeichnis.

```bash
# config/beispiel.env

# Der Adapter wird bestimmt durch die von Schild
# verwendete Datenbank. Meist MySQL, deshalb
# 'mysql2' beibehalten
S_ADAPTER=mysql2

# Der Host-Eintrag ist die Adresse der Datenbank
# im Netzwerk. Kann eine IP sein oder 'localhost',
# wenn die DB sich auf dem gleichen Rechner
# befindet. Bei Docker muss die Host-IP verwendet
# werden, 'localhost' verweist sonst auf die IP
# des sahib-Containers. Standardeinstellung ist 'db'
# und verweist auf den Datenbank-Container mit der
# Testdatenbank, die automatisch zum Einsatz kommt,
# wenn man docker-compose verwendet.
S_HOST=db

# Name der Schild-Datenbank
S_DB=schild-test

# Name des Datenbank-Benutzers. Nicht autmatisch
# identisch mit den Schild-Benutzern
S_USER=schild

# Das Passwort zur Schild-Datenbank
S_PASSWORD=schild

# sahib-Einstellungen
# Diese Einstellung gewährt allen Benutzer von
# Sahib Zugriff auf die Erweiterungseinstellungen
# bzw. anderer Einstellungen, die evtl hinzukommen.
# Muss zum ersten Einrichten 'true' sein.
S_REPO_ADMIN=true

# Dies ist die Datenbank der weiteren
# Einstellungen, die sahib anlegt. Z.B. Ort des
# Erweiterungs-Verzeichnisses oder Adresse der
# Erweiterungen. Wird anschließend als *.db Datei
# gesichert
DATENBANK=beispiel
```

Damit ist die erste Grundlage gelegt, eine der beiden folgenden Methoden
sollte nun ausgewählt werden.

### Docker (empfohlen)
Docker ist laut
[Wikipedia](https://de.wikipedia.org/wiki/Docker_(Software)):

> eine Open-Source-Software, die dazu verwendet werden kann, Anwendungen
> mithilfe von Betriebssystemvirtualisierung in Containern zu isolieren.
> Dies vereinfacht einerseits die Bereitstellung von Anwendungen, weil
> sich Container, die alle nötigen Pakete enthalten, leicht als Dateien
> transportieren und installieren lassen. Andererseits gewährleisten
> Container die Trennung der auf einem Rechner genutzten Ressourcen,
> sodass ein Container keinen Zugriff auf Ressourcen anderer Container
> hat.

Sobald Docker auf dem System läuft, ist es relativ einfach, `sahib` zu
installieren und es besteht eine hohe Sicherheit, dass `sahib` wie
vorgesehen funktioniert und die erzeugten PDF mit der erwarteten
Qualität ausgestattet sind.

Docker wird auf den unterschiedlichen Distributionen unterschiedlich
installiert. Die gängigen Distributionen wie Ubuntu, Fedora, Arch etc
werden jedoch standardmäßig unterstützt und bieten aktuelle Versionen.
Bitte informieren Sie sich
[hier](https://www.docker.com/products/overview#/install_the_platform),
wie Sie Docker auf Ihrem System installieren können. Beachten Sie, dass
`sahib` bisher nur auf Linux getestet wurde. Möglicherweise läuft
`sahib` auch auf Windows oder Mac. Probieren Sie es selber aus und
schreiben Sie ein [Feedback](https://github.com/hmt/sahib/issues).

`sahib` verwendet drei Container, wenn PDF erzeugt werden sollen. Ein
Container für `sahib` selbst, das unter Ruby läuft, ein Container für
den PDF-Renderer, der unter Node läuft und nur für das Erzeugen der PDF
zuständig ist sowie ein Datenbank-Container mit einer MariaDB-Instanz,
die auch die Testdatenbank beinhaltet. Da alle Container voneinander
abhängig sind, bietet es sich an, docker-compose zu verwenden, ein
Werkzeug, das Container "orchestriert", also in der richtigen
Reihenfolge mit den passenden Parametern startet.

Zur Installation schauen Sie bitte auf folgender
[Seite](https://docs.docker.com/compose/) und folgen den Anweisungen
(meist nur ein Einzeiler unter Linux).

Sobald docker und docker-compose installiert sind, muss sichergestellt
werden, dass die oben angegebene Konfigurationsdatei angelegt wurde,
damit `sahib` eine Verbindung zur Schild-Datenbank aufbauen kann.
Anschließend kann sie mit Hilfe der `docker-compose.yml`-Datei verwendet
werden, die sich bereits im `sahib`-Verzeichnis befindet:

```yaml
# docker-compose.yml
version: '2.1'
services:
  sahib:
    image: hmtx/sahib:latest
    command: bundle exec puma
    volumes:
      - ./plugins:/app/plugins
      - ./config:/app/config
    ports:
      - "80:9393"
    depends_on:
      - pdf
      - db
    env_file:
      - config/${DATENBANK:-beispiel}.env
  pdf:
    image: hmtx/electron_pdf:latest
  db:
    image: hmtx/mariadb:latest
```

In der mitgelieferten `docker-compose.yml` wird das lokale
`plugins`-Verzeichnis verwendet, um Erweiterungen dauerhaft lokal zu
speichern. Daten, die innerhalb von Docker-Containern gespeichert
werden, werden beim nächsten Container-Start gelöscht und müssen deshalb
als externe Daten in den Container mit eingebunden werden. Gleiches gilt
auch für die Einstellungen, die über das `config`-Verzeichnis zur
Verfügung gestellt werden werden.

Für die Verwendung der Testdatenbank sollten alle Einträge beibehalten
werden. Falls eine eigene `*.env`-Datei mit Zugangsdaten zu einer
anderen Datenbank angelegt wurden, muss eine weitere `yml`-Datei
angelegt werden, damit auf die richtigen Umgebunsvariablen zugegriffen
wird:


```bash
# docker-compose.andere.yml
version: '2.1'
services:
  sahib:
    env_file:
      - config/andere.env
```


Anschließend kann `sahib` gestartet werden:

`sudo docker-compose up`

oder wenn eine weitere `docker-compose`-Datei angelegt wurde:

`sudo docker-compose -f docker-compose.yml -f docker-compose.andere.yml
up`

Über diesen Befehl wird Docker angewiesen, die oben angegeben Container
aus dem Docker-Hub zu ziehen und zu starten. In der Kommandozeile werden
die drei Containerstati mit verschiedenen Farben angezeigt; nach wenigen
Sekunden ist `sahib` per Browser unter
[http://localhost](http://localhost) erreichbar. Von anderen Rechnern im
Netzwerk muss die Adresse des ausführenden Rechners benutzt werden.

### Eigene Laufzeitumgebung

`sahib` sollte als git-Repository heruntergeladen werden, damit es
leicht zu aktualisieren bleibt. Dazu sollte [git](https://git-scm.com)
installiert sein. Ebenso wird die Programmiersprache
[Ruby](https://ruby-lang.org) erfordert, da `sahib` ein Ruby-Script ist.
Sobald vorhanden, kann es losgehen. Zum installieren von Ruby kann man
einen Versionsmanager verwenden, der Ruby bequem im eigenen
Benutzerverzeichnis installiert oder man verwendet das vom System
vorgegebene Ruby. Praktischer ist meistens ein Werkzeug wie
[ruby-install](https://github.com/postmodern/ruby-install) mit
[chruby](https://github.com/postmodern/chruby) oder
[rvm](https://rvm.io/). Damit alle benötigten Bibliotheken installiert
werden können, wird `bundler` installiert:

`gem install bundler`

Anschließend alle nötigen Gems installieren:

`bundle install`

Falls Fehlermeldungen auftauchen, liegt es meist an fehlenden
Abhängigkeiten, um native Bibliotheken zu kompilieren. Dazu gibt es
meist für die jeweilige Linux-Distribution ein besonderes Paket. Für die
Datenbankanbindung werden MySQL/Mariadb- und Postgresql-Clients
benötigt, deren Pakete sicht jedoch im Namen bei jeder Distribution
unterscheiden.

Sobald alles vorbereitet ist, kann der Server gestartet werden:

`eval $(cat config/beispiel.env) bundle exec puma`

Dieser etwas außergewöhnliche Befehl erfüllt mehrere Aufgaben
gleichzeitig. Erst lädt die Shell zum Ausführen der folgenden Befehle
die `beispiel.env`-Datei, evaluiert die darin angegeben Variablen als
Systemvariablen und stellt sie somit `sahib` zur Verfügung, d.h. `sahib`
kann auf die Datenbankangaben mit Hilfe der Systemvariablen zugreifen.
Anschließend wird über bundler und den installierten Bibliotheken der
Puma-Server ausgeführt, der `sahib` startet und als lokale Web-Anwendung
zur Verfügung stellt.

Der Puma-Server startet auf Port 9393 und `sahib` kann im Browser unter
[http://localhost:9393](http://localhost:9393) erreicht werden. Wenn
alles geklappt hat, stehen nun alle eingetragenen Schüler zur Verfügung.

Beendet werden kann `sahib` mit der Tastenkombination Strg-c.

## `sahib` benutzen
Nach dem erfolgreichen Start von `sahib` kann im Browser alles weitere
erledigt werden. Die Oberfläche ist absichtlich minimal gehalten und
bietet nur die nötigsten Buttons und Eingabefelder.

### Schüler finden und Dokumente erzeugen
Die _Startseite_ bietet praktisch nur ein Engabefeld zur Suche von
Schülern, bzw. Klassen. Beides wird bei Beginn der Eingabe direkt als
Treffer zurückgemeldet, verschiedene Symbole markieren aktive Schüler,
ausgeschulte oder Abgänger. Klassen werden mit der jeweiligen Jahreszahl
versehen. Sobald man einen Treffer auswählt, wird der Treffer in der
Einzel- oder Gruppenansicht dargestellt. Einzelne Schüler können auch in
ihrer Klasse dargestellt werden, ebenso kann in einer Gruppensansicht
ein einzelner Schüler zur Einzelansicht angezeigt werden.

Sind Reports eingerichtet, kann mit Hilfe der Dokumenten-Taste ein neues
Dokument erstellt werden, aus dem heraus dann zusätzlich ein PDF erzeugt
werden kann. Da die Erstellung von PDF etwas rechenintensiver ist, wird
immer erst eine _einfache_ HTML-Darstellung angezeigt, die grundsätzlich
mit der PDF-Darstellung übereinstimmen sollte. Da jeder Rechner aber
andere Font-Einstellunge hat, kann es u.U. sein, dass die beiden
Darstellungen voneinander abweichen. Wichtig ist jedoch, dass bei der
Verwendung der Docker-Container die PDF-Ezeugung grundsätzlich auf allen
Systemen identisch funktioniert und gleiche Ergebnisse bei gleichen
Daten geliefert werden, unabhängig vom eingesetzten System.

Damit die Dokumente erzeugt werden können, müssen Reports zur Verfügung
gestellt werden.

## Reports in Sahib einbinden
`sahib` liefert keine eigenen Reports mit, da es im Prinzip nicht
möglich ist, Reports zu erstellen, die für alle Schulen gültig sind.
Änderungen müssen praktisch immer vorgenommen werden, auch wenn es nur
die eingebundenen Logos sind.

Das Einbinden von Reports gestaltet sich jedoch relativ leicht, wenn man
bereit ist, sich mit dem Erweiterungssystem von `sahib`
auseinanderzusetzen.

Im oberen Menu der Browser-Ansicht befindet sich das  Einstellungssymbol
mit dem Zahnrad, hinter dem sich der Punkt _Erweiterungen_ befindet.

Auf der Erweiterungsseite bietet sich die Möglichkeit
Erweiterungen/Reports mit Hilfe von lokalen Verzeichnissen bzw. als
git-Repositories einzubinden.

Lokale Verzeichnisse sind für `sahib` über das Dateisystem erreichbar,
könnte dementsprechend auch ein entfernt eingebundenes Laufwerk im
Netzwerk sein, bietet sich jedoch eher für ein auf dem selben Rechner
befindliches Verzeichnis an, an dem eigene Dokumente erstellt, bzw.
bearbeitet werden, da sie automatisch aktuell sind und sofort in `sahib`
zur Ansicht zur Verfügung stehen.

git-Repositories sind meistens entfernt abgelegte Dokumente, die z.B.
per Internet erreichbar sind und besonders dann praktisch sind, wenn auf
dem einen Rechner Reports entwickelt und geprüft werden, anschließend
mit dem git-Repository abgeglichen werden und dann den `sahib`-Nutzern
zur Verfügung gestellt werden. Ebenso können git-Repositories über
öffentliche Quellen mit anderen Nutzern ausgetauscht werden. Viele
Reports unterscheiden sich in den schulischen Bedürfnissen nur minimal
und können mit wenigen Handgriffen an die eigenen Vorstellungen
angepasst werden.

Mit der Eingabe einer lokalen- bzw. einer git-Adresse wird noch ein Name
erwartet, unter dem die Dokumente angezeigt werden. Dazu bietet sich
z.B. das Jahr an, wenn man jährlich andere Reports verwendet oder
Reports für bestimmte Situationen.

Sobald die Reports gefunden und eingebunden wurden, stehen sie den
Nutzern zur Verfügung. 

Wird ein Report-Verzeichnis/Repository für einige Zeit nicht benötigt
und die Reportauswahl wirkt unübersichtlich, dann kann durch ein Klick
auf das Auge die Darstellung ausgeblendet werden.

Ein Demo-Repository für Reports ist hier verfügbar:

`https://github.com/hmt/demo-reports.git`

Unter Erweiterungen `git-Erweiterung` wählen, Repository-URL eintragen
und als Namen z.B. `Demo` auswählen. `sahib` prüft die Verfügbarkeit und
bindet unter `Speichern` die Erweiterung endgültig ein. Der Server wird
daraufhin neu gestartet und in der Schüler- bzw. Klassenauswahl können
nun die neuen Dokumente erzeugt werden.

## Reports erstellen
Anders als der von Schild mitgelieferte Report-Designer hat `sahib`
keinen eigenen Editor zum bearbeiten der Reports. Da es sich bei den
Reports um Textdateien handelt, die praktisch von Hand erstellt werden
können, ist dies in den meisten Fällen auch kein Problem.

`sahib` kann theoretisch jedes beliebige HTML-Dokument sein, aber in
erster Linie steht sicherlich die Erzeugung von schulrelevanten
Dokumenten im Vordergrund. Zeugnisse, Bescheinigungen und Listen für den
Alltag. Gemein ist allen, dass sie als PDF archivierbar sind und sich
problemlos drucken lassen.

Wesentliches Merkmal ist also, dass die erzeugten Dokumente in den
meisten Fällen auf A4 bzw. A3 ausgegeben werden. Dazu bietet CSS die
`@media`-Anweisung, die von `sahib`-Reports praktisch universell genutzt
wird. Hiermit werden den Reports die passenden Maße für erzeugende
Dokumente mitgeteilt und anschließend ausgegeben.

Alles, was auf die somit erzeugten Flächen passt, wird seitenweise
ausgegeben, bzw. verlässt den Seitenrand. Ein automatisches Umbrechen
findet nicht statt, es sei denn, es wird so per CSS angewiesen. Das hat
den Vorteil, dass Benutzer die volle Kontrolle über die Seitengestaltung
behalten und nicht mit frühen Seitenumbrüchen konfrontiert werden.

Die meisten in der Entwicklungsphase zum Einsatz kommenden Reports
verwenden neben den generellen Anweisungen zur Seitenerstellung noch die
CSS-Bibliothek [Bootstrap](https://getbootstrap.com/), die es
ermöglicht, sog. Grids u verwenden, also ein mehrspaltiges Layout, um
Seiten oder Dokumente über bis zu 12 Spalten zu gestalten. Was
ursprünglich nur für Internetseiten gedacht war, lässt sich hervorragend
auch für `sahib`-Reports nutzen. Ein System, das auch im Print-Bereich
genutzt wird. Damit lassen sich Elemente auf einem Dokument gleichmäßig
positionieren, ohne dass man sich viel Gedanken über absolute Positionen
machen muss. Das CSS positioniert alle Elemente automatisch an der
optimalen Stelle.

Es ist bei der Neugestaltung von Reports sinnvoll auf bereits
existierende Vorlagen zurückzugreifen und lediglich anzupassen. Die
meisten Einstellungen in den CSS-Dateien sind dabei erprobte Hilfen für
die Erstellung von Reports.

Im [Demo-Repository](https://github.com/hmt/demo-reports) sind einige
Reports verzeichnet, die einen ersten Eindruck verschaffen. Nähere
Informationen zum Erstellen von eigenen Reports werden an dieser Stelle
ergänzt.

## Reports mit Slim erstellen
Wie oben erwähnt, ist Slim eine Template-Sprache, die HTML erzeugt und
Steuercodes für Ruby enthalten kann. Dabei ist es, wie der Name schon
sagt, »slim«. HTML mit all den öffnenden und schließenden Tags und
eckigen Klammern wird auf das wesentliche reduziert und lässt sich
dadurch schneller schreiben und teilweise besser lesen.

Dazu ein konkretes Beispiel, das sich auch als
[Gist](https://gist.github.com/) unter:
[https://gist.github.com/hmt/5a6236a044f5ac36dd4643c2d98bfbb1](https://gist.github.com/hmt/5a6236a044f5ac36dd4643c2d98bfbb1)
finden lässt. Mit einem GitHub-Nutzer kann man diesen Gist »forken«,
also eine eigene Kopie erstellen und nach eigenen Wünschen verändern und
in `sahib` einbinden.
<script
src="https://gist.github.com/hmt/5a6236a044f5ac36dd4643c2d98bfbb1.js"></script>
## Lizenz
sahib von HMT ist lizenziert unter der MIT-Lizenz.
