# leipalaskuri
by Teemu Nikula

Online-versio sovelluksesta: https://01a21cee-8ed2-1944-c461-848fa4efe28f.share.connect.posit.cloud/

Sovellus auttaa leipäreseptin ravintosisällön laskemiseen ja itsetehdyn leivän kilohinnan arvioimiseen. Syy sovelluksen luomiselle oli henkilökohtainen tarve laskea itseleivottujen leipien ravintosisältöjä ja kilohintoja vertailumielessä ja sovelluksen sisältö ja rajallisuus vastaa tarvetta. Sovelluksen tekoon on käytetty R:n Shiny-kirjastoa.

---

Sovellus sallii kahden erilaisen jauhon asettamisen reseptiin. Jauhotyypin 1 osuus määrittää jauhojen 1 osuuden massan mukaan valituista jauhoista. Jauhojen määrä (desilitroina) asettaa jauhotyypin 1 ja jauhotyypin 2 yhteenlasketun tilavuuden.

Sovellus sallii myös kuivahiivan, veden, siirapin, suolan, psylliumin ja ksantaanikumin määrän asettamisen. Yksi kuivahiivapussi on massaltaan 25 grammaa. Psylliumin ja ksantaanikumin ominaisuudet sovellus laskee arvioon sisäisesti.

Sovellus sallii myös eri siementyypin lisäämisen taikinaan ja siementen määrän säädön.

Haihtuvuusprosentti tarkoittaa osuutta joka taikinan massasta haihtuu paiston aikana, ja sitä voi arvioida välillä 0%-25%. 

Sovellus laskee leivän hintaan myös arvion sähkönhinnasta, joka perustuu omiin kokeiluihini. Tämä on noin 0.6 kWh leipää kohden. Tämä on asetettu vakioksi sovelluksen hintalaskuriin, joten pienillä taikinamäärillä tai suurilla arvio ei ole todennäköisesti järkevä.

---

data-kansio sisältää seuraavat .csv-tiedostot: jauhot.csv ja siemenet.csv

jauhot.csv

jauho: jauhon nimi;
tyyppi: jauhon viljan tyyppi;
tiheys: jauhojen tiheys (g/dl);
pakkauskoko: pakkauksen massa grammoina;
kilohinta: hinta/pakkauskoko;
energia: jauhojen energiamäärä kilokaloreina 100 g kohden;
rasva: jauhojen rasvamäärä grammoina per 100 g kohden;
rasvaTyyd: tyydyttyneiden rasvojen osuus grammoina edeltävästä luvusta;
hiilihyd: hiilihydraattisen osuus grammoina per 100 g kohden;
hiilihydSok: sokereiden osuus grammoina edeltävästä luvusta;
kuitu: kuidun määrä grammoina per 100 g;
proteeini: proteeinin määrä grammoina per 100 g;
suola: suolan määrä grammoina per 100 g;

siemenet.csv

siemen: siemenen nimi;
tyyppi: siemenen tyyppi;
tiheys: siementen tiheys (g/dl);
pakkauskoko: pakkauksen massa grammoina;
kilohinta: hinta/pakkauskoko;
energia: siementen energiamäärä kilokaloreina 100 g kohden;
rasva: siementen rasvamäärä grammoina per 100 g kohden;
rasvaTyyd: tyydyttyneiden rasvojen osuus grammoina edeltävästä luvusta;
hiilihyd: hiilihydraattisen osuus grammoina per 100 g kohden;
hiilihydSok: sokereiden osuus grammoina edeltävästä luvusta;
kuitu: kuidun määrä grammoina per 100 g;
proteeini: proteeinin määrä grammoina per 100 g;
suola: suolan määrä grammoina per 100 g;

---

helpers.R

Lukee yllä mainitut aineistot, luo listat eri jauhovaihtoehdoista.

Sisältää funktiot

jauhoetsin: palauttaa jauho.csv tiedoston nimen joka vastaa syötettä x

siemenetsin:  palauttaa siemenet.csv tiedoston nimen joka vastaa syötettä x

ravintolaskuri: jauho1 ja jauho 2 täsmentää käytetyt jauhovaihtoehdot. massa1 ja massa2 syötteet ilmoittavat valittujen jauhojen vastaavat massat.
Funktio palauttaa ravintosisällön (grammoina per 100 g) energialle, rasvalle, tyydyttyneille rasvoille, hiilihydraatille, sokerille, kuidulle, proteeinille ja suolalle.
Funktio palauttaa vektorin edellä mainituista määristä.

kuitulaskuri: jauho1 ja jauho 2 täsmentää käytetyt jauhovaihtoehdot. massa1 ja massa2 syötteet ilmoittavat valittujen jauhojen vastaavat massat.
Funktio palauttaa ravintosisällön (g/100g) kuidulle.
