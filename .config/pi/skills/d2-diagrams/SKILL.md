---
name: d2-diagrams
description: >
  Écrire et vérifier des diagrammes avec d2 (DSL texte → PNG / SVG / ASCII). À utiliser
  dès qu'on demande un diagramme, un schéma, un flux, une architecture, un ERD, un
  diagramme de classes, une séquence ou une arborescence : écrire un fichier .d2 plutôt
  que du mermaid ou de l'ASCII dessiné à la main. Contient la syntaxe utile, les pièges
  et la recette de vérification.
---

# Diagrammes avec d2

Un `.d2` se corrige en relisant une ligne, pas en redessinant. Préférer un fichier `.d2`
à côté du code documenté plutôt qu'un mermaid enfoui dans un commentaire.

## Vérifier — obligatoire

1. `d2 validate f.d2` — erreurs de syntaxe et de sémantique sur stderr, exit 1. Corriger
   jusqu'à `Success!`.
2. `d2 f.d2 f.png` — rendu.
3. Se relire soi-même, selon ce que le modèle accepte en entrée :
   - **images acceptées en entrée** : `read` le PNG produit — il est envoyé au modèle, on
     voit le diagramme tel qu'il sera livré ;
   - **texte seulement** : `d2 --target '' --stdout-format ascii f.d2 -` et lire la sortie.
     Les lignes `success:` / `info:` partent sur stderr : stdout ne contient que le dessin.

Ne pas livrer un diagramme qui n'a pas passé l'étape 1.

## Commandes

```bash
d2 f.d2 f.png                # PNG ; sortie .svg par défaut si le chemin est omis
d2 --theme 5 f.d2 f.png      # thème (liste : d2 themes)
d2 --layout elk f.d2 f.png   # dagre (défaut) | elk | tala, tous embarqués
d2 fmt f.d2                  # formate en place
d2 validate f.d2             # seule preuve de correction
```

## Syntaxe

```d2
direction: right             # au niveau du board ou d'un conteneur ; haut par défaut

client -> api: HTTPS         # label du lien après le second ":"
api -> db: SQL
b -- c                       # sans flèche

api: {                       # conteneur
  shape: cylinder
  style: {fill: "#7FB4CA"; border-radius: 8; shadow: true}
}

*.style.font-size: 14        # glob : tous les nœuds ; ** pour tous les niveaux

classes: { svc: {style.fill: red} }
api.class: svc

sql: {                       # clés = colonnes
  shape: sql_table
  id: int {constraint: primary_key}
  name: varchar(255)
}
Klass: { shape: class; +name: string; +greet(): void }   # clés = membres

g: {grid-rows: 2; grid-columns: 2; a; b; c; d}   # grille
x.near: api                                      # proximité (dagre, tala)
x.tooltip: "..."
x.link: "https://…"
x.icon: https://icons.d2lang.com/2023/v0.6.0/icons/tech/kubernetes.svg

note: |md                    # bloc markdown ou code (|go, |bash, …)
  # Titre
  - *un*
|

layers: { infra: {web -> db} }                        # boards : une vue par entrée
scenarios: { panne: {api -> db: "timeout"} }
```

## Pièges (vérifiés)

- Clé ou label contenant `:` `->` `#` ou des espaces → guillemets : `"a -> b": "label"`.
  Un attribut réservé utilisé comme clé (`style`, `shape`, `label`, `class`, `direction`,
  `near`, `grid-rows`…) change de sens : le guillemeter pour en faire un vrai nœud.
- Dès qu'il y a `layers` / `scenarios` / `steps`, l'écriture sur stdout est refusée
  (« multiboard output cannot be written to stdout ») → ajouter `--target ''` pour rendre
  le board racine.
- `near` et `--layout elk` sont incompatibles (« only supports constant values for near »)
  → dagre ou tala pour ce mot-clé.
- Les blocs `|md` / `|go` sortent en cases vides en ASCII : la relecture ASCII ne vérifie
  pas un diagramme qui en contient.
- `d2 validate` ne juge pas le fond : un diagramme valide peut être illisible (trop de
  nœuds, `direction` inadapté). C'est l'étape 3 qui tranche.
