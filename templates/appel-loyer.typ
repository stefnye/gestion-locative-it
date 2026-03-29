// Appel de loyer — Template Typst
// Usage: typst compile appel-loyer.typ --input nom="Dupont" --input prenom="Jean"
//        --input adresse="12 rue des Lilas, 77127 Lieusaint"
//        --input mois="2026-05" --input loyer="750.00" --input charges="50.00"

#let nom = sys.inputs.at("nom", default: "NOM")
#let prenom = sys.inputs.at("prenom", default: "Prénom")
#let adresse = sys.inputs.at("adresse", default: "Adresse du bien")
#let mois = sys.inputs.at("mois", default: "YYYY-MM")
#let loyer = float(sys.inputs.at("loyer", default: "0"))
#let charges = float(sys.inputs.at("charges", default: "0"))
#let bailleur_nom = sys.inputs.at("bailleur_nom", default: "SCI [Nom SCI]")
#let bailleur_adresse = sys.inputs.at("bailleur_adresse", default: "Adresse SCI")
#let date_echeance = sys.inputs.at("date_echeance", default: "le 1er du mois")
#let total = loyer + charges

#set page(margin: 2cm)
#set text(font: "Libertinus Serif", size: 11pt, lang: "fr")

#align(center)[
  #text(size: 18pt, weight: "bold")[Appel de loyer]
  #v(0.5em)
  #text(size: 12pt)[Période : #mois]
]

#v(2em)

#grid(
  columns: (1fr, 1fr),
  [
    *Bailleur*\
    #bailleur_nom\
    #bailleur_adresse
  ],
  align(right)[
    *Locataire*\
    #prenom #nom\
    #adresse
  ],
)

#v(2em)

#line(length: 100%)

#v(1em)

Madame, Monsieur,

Nous vous prions de bien vouloir trouver ci-dessous le détail du loyer dû pour la période de #mois :

#v(1em)

#table(
  columns: (1fr, auto),
  stroke: 0.5pt,
  [*Désignation*], [*Montant*],
  [Loyer hors charges], [#str(loyer) €],
  [Provisions pour charges], [#str(charges) €],
  table.hline(),
  [*Total à régler*], [*#str(total) €*],
)

#v(1em)

Le règlement est attendu #date_echeance par virement bancaire.

#v(1em)

Nous vous remercions de votre régularité et restons à votre disposition pour toute question.

#v(3em)

#align(right)[
  Fait à Lieusaint, le #datetime.today().display("[day]/[month]/[year]")\
  #v(2em)
  #bailleur_nom
]
