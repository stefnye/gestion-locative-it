// Lettre de révision annuelle IRL — Template Typst
// Usage: typst compile revision-irl.typ --input nom="Dupont" --input prenom="Jean"
//        --input ancien_loyer="750.00" --input nouveau_loyer="765.75"
//        --input ancien_irl="142.06" --input nouveau_irl="144.47"
//        --input trimestre_ref="T1 2026" --input date_effet="2026-07-01"

#let nom = sys.inputs.at("nom", default: "NOM")
#let prenom = sys.inputs.at("prenom", default: "Prénom")
#let adresse = sys.inputs.at("adresse", default: "Adresse du bien")
#let ancien_loyer = float(sys.inputs.at("ancien_loyer", default: "0"))
#let nouveau_loyer = float(sys.inputs.at("nouveau_loyer", default: "0"))
#let ancien_irl = sys.inputs.at("ancien_irl", default: "0")
#let nouveau_irl = sys.inputs.at("nouveau_irl", default: "0")
#let trimestre_ref = sys.inputs.at("trimestre_ref", default: "T? YYYY")
#let date_effet = sys.inputs.at("date_effet", default: "YYYY-MM-DD")
#let bailleur_nom = sys.inputs.at("bailleur_nom", default: "SCI [Nom SCI]")
#let bailleur_adresse = sys.inputs.at("bailleur_adresse", default: "Adresse SCI")

#set page(margin: 2cm)
#set text(font: "Libertinus Serif", size: 11pt, lang: "fr")

#grid(
  columns: (1fr, 1fr),
  [
    *#bailleur_nom*\
    #bailleur_adresse
  ],
  align(right)[
    *#prenom #nom*\
    #adresse
  ],
)

#v(1em)

#align(right)[
  Lieusaint, le #datetime.today().display("[day]/[month]/[year]")
]

#v(2em)

#text(weight: "bold")[Objet : Révision annuelle du loyer — Indice de Référence des Loyers (IRL)]

#v(1em)

Madame, Monsieur,

Conformément aux dispositions de l'article 17-1 de la loi n°89-462 du 6 juillet 1989 et aux clauses du bail, je vous informe de la révision annuelle de votre loyer.

#v(1em)

*Calcul de la révision :*

#table(
  columns: (1fr, auto),
  stroke: 0.5pt,
  [IRL de référence du bail (ancien)], [#ancien_irl],
  [Nouvel IRL (#trimestre_ref)], [#nouveau_irl],
  [Loyer actuel hors charges], [#str(ancien_loyer) €],
  table.hline(),
  [*Nouveau loyer hors charges*], [*#str(nouveau_loyer) €*],
)

#v(0.5em)

_Formule : ancien loyer × (nouvel IRL / ancien IRL) = #str(ancien_loyer) × (#nouveau_irl / #ancien_irl) = #str(nouveau_loyer) €_

#v(1em)

Cette révision prendra effet à compter du *#date_effet*.

Le montant des provisions pour charges reste inchangé.

#v(1em)

Nous vous remercions de prendre bonne note de cette révision et restons à votre disposition pour toute question.

#v(3em)

#align(right)[
  #bailleur_nom\
  #v(2em)
  _Signature_
]
