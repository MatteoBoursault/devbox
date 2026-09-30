---
name: d2-diagrams
description: >
  Écrire et vérifier des diagrammes avec d2. À utiliser dès qu'on demande un diagramme,
  un schéma, un flux, une architecture, un ERD, un diagramme de classes, une séquence ou
  une arborescence : écrire un fichier .d2 plutôt que du mermaid ou de l'ASCII dessiné à
  la main. Rendu SVG aux couleurs kanagawa ; contient la syntaxe utile, les pièges et la
  recette de vérification.
---

# Diagrammes avec d2

Un `.d2` se corrige en relisant une ligne, pas en redessinant. Préférer un fichier `.d2`
à côté du code documenté plutôt qu'un mermaid enfoui dans un commentaire. Le rendu se fait
aux couleurs kanagawa (thème préfixé, voir l'étape 2).

## Vérifier — obligatoire

1. `d2 validate f.d2` — corriger jusqu'à `Success!` (erreurs sur stderr, exit 1).
2. Rendre le SVG, couleurs kanagawa :

   ```bash
   cat ~/.config/d2/kanagawa-theme.d2 f.d2 | d2 - f.svg
   ```

   Sans ce préfixe, d2 rend avec son thème clair par défaut.
3. Relire le rendu avant de livrer, selon ce que le modèle accepte :
   - **images acceptées en entrée** : `rsvg-convert f.svg f.png && read f.png` — `read`
     n'envoie pas les SVG comme image, il faut rasteriser d'abord ;
   - **texte seulement** : `d2 --target '' --stdout-format ascii f.d2 -`. Les lignes
     `success:` / `info:` partent sur stderr ; stdout ne contient que le dessin. Une
     séquence ne se relit qu'avec `shape: sequence_diagram` (lifelines) : en
     `direction: right` brut, l'ASCII de ~6 acteurs est illisible.

Ne pas livrer un diagramme qui n'a pas passé l'étape 1.

## Commandes

```bash
d2 f.d2 f.svg                # rendu SVG (par défaut si le chemin finit en .svg)
d2 --layout elk f.d2 f.svg   # dagre (défaut) | elk | tala — tous embarqués
rsvg-convert f.svg f.png     # rasterise le SVG, pour relire le rendu avec `read`
d2 --stdout-format ascii f.d2 -   # aperçu texte, sans produire de fichier
d2 fmt f.d2                  # formate en place
d2 validate f.d2             # seule preuve de correction
```

Pour voir le rendu dans le terminal (utilisateur) : `d2p f.d2`, ou `d2p -w f.d2` pour
suivre les modifications.

## Syntaxe

```d2
direction: right             # au niveau du board ou d'un conteneur ; haut par défaut
shape: sequence_diagram      # diagramme de séquence : lifelines, lecture haut→bas propre

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
- Accolades `{ }` dans un label d'arête (`a -> b: {x, y}`) sont lues comme un map →
  guillemeter : `a -> b: "{x, y}"`. Idem sous `shape: sequence_diagram`.
- Diagramme de séquence : `shape: sequence_diagram` (lifelines), pas `direction: right`
  seul, sinon nœuds croisés et ASCII illisible.
