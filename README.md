# sahib

`sahib` ist eine grafische Oberfläche für Schild-Datenbanken. Schild ist das offizielle Schulverwaltungssystem in NRW.

Im Gegensatz zu Schild ist `sahib` quelloffen und kann jederzeit angepasst werden. Es baut auf das [`schild`-Gem](https://github.com/hmt/schild) auf und kann prinzipiell auf alle in Schild zur Verfügung stehenden Daten zugreifen. Diese Daten können dann ausgelesen und mit Hilfe von Templates im Browser angeschaut werden. Als Unterbau für `sahib` dient [sinatra](https://github.com/sinatra/sinatra), ein Mikro-Framework für Webanwendungen.

`sahib` ersetzt Schild nicht, kann aber als Ergänzung für den schnellen Datenbankzugriff genutzt werden. Ebenso eignet es sich zur Erstellung und vor allem Darstellung von eigenen Dokumenten. Als Beispieldokument wir ein Zeugnis mitgeliefert, das über die ausgesuchten Schüler aufgerufen werden kann. Dazu eine beliebige Person über die Suche herausfiltern und auf das oben in der Tabelle angegebene Halbjahr anzeigen.

## Installation
`sahib` sollte als git-Repository heruntergeladen werden, damit es leicht zu aktualisieren bleibt. Dazu sollte [git](https://git-scm.com) installiert sein. Ebenso wird die Programmiersprache [Ruby](https://ruby-lang.org) erfordert, da `sahib` ein Ruby-Script ist. Sobald vorhanden, kann es losgehen

```sh
git clone git@github.com:hmt/sahib.git
```

Anschließend alle nötigen Gems installieren:

```sh
cd sahib
bundle install
```

Um `sahib` zu starten wird erwartet, dass eine Schild-Datenbank eingerichtet und zugänglich ist. Dazu müssen in die Datei `config/env.yml` alle nötigen Daten eingetragen werden.

```sh
development:
  S_ADAPTER: mysql2
  S_HOST: 192.168.178.55
  S_USER: schild
  S_PASSWORD: schild_passwort
  S_DB: schild_db
```

Sobald alles vorbereitet ist, kann der Server gestartet werden:

```sh
puma
```

Der Puma-Server startet auf Port 4567 und `sahib` kann im Browser unter [http://localhost:4567](http://localhost:4567) erreicht werden. Wenn alles geklappt hat, stehen nun alle eingetragenen Schüler zur Verfügung.

## Hinweis
Sahib ist nur ein weiteres Beispiel zur Nutzung des `schild`-Gems. Weitere Dokumente können entworfen und dem Repository hinzugefügt werden. `sahib` wird an einem Berufskolleg genutzt, möglicherweise haben andere Schulformen andere Bedürfnisse. In den meisten Fällen lassen sich `sahib` und `schild` recht schnell erweitern.

Da meines Wissens in Schild die Bildungsgänge und die Bezeichnungen der erlangten Abschlüüse nicht eingetragen sind, können diese in einer weiteren yaml-Datei hinterlegt und bei Bedarf ausgelesen werden. Dazu bitte `config/strings.yml` anschauen.

## Lizenz
[![Creative Commons Lizenzvertrag](https://i.creativecommons.org/l/by/4.0/88x31.png)]("http://creativecommons.org/licenses/by/4.0/")
[schild](https://github.com/hmt/schild) und [sahib](https://github.com/hmt/sahib) von [HMT](https://github.com/hmt) ist lizenziert unter einer [Creative Commons Namensnennung 4.0 International Lizenz](http://creativecommons.org/licenses/by/4.0/).
