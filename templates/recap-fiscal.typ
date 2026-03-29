// Récapitulatif fiscal annuel — Template Typst
// Usage: typst compile recap-fiscal.typ --input annee="2025"
//        --input revenus_loyer="9000" --input revenus_charges="600"
//        --input interets_emprunt="3200" --input assurance_pno="180"
//        --input assurance_emprunteur="420" --input taxe_fonciere="950"
//        --input charges_copro="300" --input frais_gestion="0"
//        --input travaux="0" --input frais_comptabilite="0"

#let annee = sys.inputs.at("annee", default: "YYYY")
#let sci_nom = sys.inputs.at("sci_nom", default: "SCI [Nom SCI]")
#let sci_siren = sys.inputs.at("sci_siren", default: "XXX XXX XXX")

// Revenus
#let revenus_loyer = float(sys.inputs.at("revenus_loyer", default: "0"))
#let revenus_charges = float(sys.inputs.at("revenus_charges", default: "0"))
#let total_revenus = revenus_loyer + revenus_charges

// Charges déductibles
#let interets_emprunt = float(sys.inputs.at("interets_emprunt", default: "0"))
#let assurance_pno = float(sys.inputs.at("assurance_pno", default: "0"))
#let assurance_emprunteur = float(sys.inputs.at("assurance_emprunteur", default: "0"))
#let taxe_fonciere = float(sys.inputs.at("taxe_fonciere", default: "0"))
#let charges_copro = float(sys.inputs.at("charges_copro", default: "0"))
#let frais_gestion = float(sys.inputs.at("frais_gestion", default: "0"))
#let travaux = float(sys.inputs.at("travaux", default: "0"))
#let frais_comptabilite = float(sys.inputs.at("frais_comptabilite", default: "0"))
#let total_charges = interets_emprunt + assurance_pno + assurance_emprunteur + taxe_fonciere + charges_copro + frais_gestion + travaux + frais_comptabilite

#let resultat_foncier = total_revenus - total_charges

#set page(margin: 2cm)
#set text(font: "Libertinus Serif", size: 11pt, lang: "fr")

#align(center)[
  #text(size: 20pt, weight: "bold")[Récapitulatif Fiscal Annuel]
  #v(0.3em)
  #text(size: 14pt)[#sci_nom — Exercice #annee]
  #v(0.3em)
  #text(size: 10pt, fill: gray)[SIREN : #sci_siren — Revenus fonciers au réel (SCI à l'IR)]
]

#v(2em)

== Revenus fonciers bruts

#table(
  columns: (1fr, auto),
  stroke: 0.5pt,
  [Loyers hors charges encaissés], [#str(revenus_loyer) €],
  [Charges locatives récupérées], [#str(revenus_charges) €],
  table.hline(),
  [*Total revenus bruts*], [*#str(total_revenus) €*],
)

#v(1em)

== Charges déductibles

#table(
  columns: (1fr, auto),
  stroke: 0.5pt,
  [Intérêts d'emprunt], [#str(interets_emprunt) €],
  [Assurance PNO], [#str(assurance_pno) €],
  [Assurance emprunteur], [#str(assurance_emprunteur) €],
  [Taxe foncière], [#str(taxe_fonciere) €],
  [Charges de copropriété non récupérables], [#str(charges_copro) €],
  [Frais de gestion], [#str(frais_gestion) €],
  [Travaux déductibles], [#str(travaux) €],
  [Frais de comptabilité], [#str(frais_comptabilite) €],
  table.hline(),
  [*Total charges déductibles*], [*#str(total_charges) €*],
)

#v(1em)

== Résultat foncier net

#table(
  columns: (1fr, auto),
  stroke: 0.5pt,
  [Total revenus bruts], [#str(total_revenus) €],
  [Total charges déductibles], [- #str(total_charges) €],
  table.hline(),
  [*Résultat foncier net*], [*#str(resultat_foncier) €*],
)

#v(1em)

#text(size: 9pt, fill: gray)[
  _Ce document est un récapitulatif généré automatiquement à partir des données comptables Firefly III. Il est destiné à faciliter la préparation des déclarations 2072 (SCI) et 2042 (IRPP). Il ne constitue pas un document fiscal officiel._
]

#v(1em)

#align(right)[
  Généré le #datetime.today().display("[day]/[month]/[year]")
]
