// Quittance de loyer — Template Typst
// Usage: typst compile quittance.typ --input nom="Dupont" --input prenom="Jean"
//        --input adresse="12 rue des Lilas, 77127 Lieusaint"
//        --input mois="2026-04" --input loyer="750.00" --input charges="50.00"
//        --input date_paiement="2026-04-05"

#let nom = sys.inputs.at("nom", default: "NOM")
#let prenom = sys.inputs.at("prenom", default: "Prénom")
#let adresse = sys.inputs.at("adresse", default: "Adresse du bien")
#let mois = sys.inputs.at("mois", default: "YYYY-MM")
#let loyer = float(sys.inputs.at("loyer", default: "0"))
#let charges = float(sys.inputs.at("charges", default: "0"))
#let date_paiement = sys.inputs.at("date_paiement", default: "JJ/MM/AAAA")
#let bailleur_nom = sys.inputs.at("bailleur_nom", default: "SCI [Nom SCI]")
#let bailleur_adresse = sys.inputs.at("bailleur_adresse", default: "Adresse SCI")
#let total = loyer + charges

#set page(margin: 2cm)
#set text(font: "Libertinus Serif", size: 11pt, lang: "fr")

#align(center)[
  #text(size: 18pt, weight: "bold")[Quittance de loyer]
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

Je soussigné(e), #bailleur_nom, bailleur du logement désigné ci-dessus, déclare avoir reçu de #prenom #nom la somme détaillée ci-dessous, en paiement du loyer et des charges pour la période indiquée.

#v(1em)

#table(
  columns: (1fr, auto),
  stroke: 0.5pt,
  [*Désignation*], [*Montant*],
  [Loyer hors charges], [#str(loyer) €],
  [Provisions pour charges], [#str(charges) €],
  table.hline(),
  [*Total*], [*#str(total) €*],
)

#v(1em)

*Date de paiement :* #date_paiement

#v(3em)

#align(right)[
  Fait à Lieusaint, le #datetime.today().display("[day]/[month]/[year]")\
  #v(2em)
  _Signature du bailleur_
]

#v(2em)

#text(size: 8pt, fill: gray)[
  Cette quittance annule tous les reçus qui auraient pu être établis précédemment en cas de paiement partiel du loyer. Elle est délivrée sous réserve de tous droits du bailleur. Conformément à la loi n°89-462 du 6 juillet 1989, la quittance est de droit lorsque le locataire en fait la demande.
]
