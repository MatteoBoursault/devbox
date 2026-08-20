# devbox
L'objectif de ce projet est de fournir un environnement de développement conteneurisé, reproductible et facilement déployable.
Les parties conteneurisation et déploiement sont gérées par **podman** et **distrobox** (Arch Linux) : le **Containerfile** construit l'image des outils, le dépôt (cloné dans le home) versionne les configurations.

Cet environnement de dev est pensé pour fonctionner uniquement dans le terminal et les raccourcis clavier sont adaptés à la disposition de clavier **Dvorak for programmer**.


## Installation

### Prérequis

Sur Arch Linux :
```bash
sudo pacman -S podman distrobox
```

### Construire l'image

L'image contient les outils ; les configurations arrivent via le dépôt cloné à la création.
```bash
podman build -t devbox .
```

### Mise en place

Supprimer l'ancienne devbox au besoin :
```bash
distrobox rm -f devbox
sudo rm -rf ~/.local/share/devbox-home
```

Créer une devbox (clone le dépôt dans le home) :
```bash
distrobox create --name devbox \
  --image devbox --yes \
  --home ~/.local/share/devbox-home \
  --volume ~/.ssh:$HOME/.local/share/devbox-home/.ssh:ro \
  --init-hooks "if [ ! -f \$HOME/.devbox-initialized ]; then \
    runuser -u \$(stat -c %u \$HOME) -- sh -c \"cd \$HOME && \
      git init && \
      git remote add origin git@github.com:MatteoBoursault/devbox.git && \
      git fetch && \
      git checkout main && \
      touch \$HOME/.devbox-initialized\"; \
  fi"
```

Entrer dans la devbox (lance herdr) :
```bash
distrobox enter --no-workdir devbox -- kitty herdr
```

Pour un shell simple (dépannage) :
```bash
distrobox enter --no-workdir devbox
```

## Commandes utiles

### Mettre à jour les outils
```bash
# Depuis l'intérieur de la devbox
just update
```

## Outils
La devbox contient les outils suivants, configurés pour fonctionner ensemble :
- kitty (terminal)
- fish (shell)
- starship (prompt)
- herdr (multiplexeur de terminal)
- yazi (gestionnaire de fichiers)
- nvim (IDE)
- omp (harnais LLM)
- bat, eza, zoxide, skim, rg, fd, bandwhich, btop, difftastic, procs, grex, trash-cli... (outils CLI)

## Langages

La devbox gère les langages suivants :
- TypeScript / JavaScript (bun)
- Rust
- Python
- C++
- C
- Lua
- Shell
- Json
- Toml
- Yaml
- Markdown

### Formatter / Linter / LSP

| Langage / format | Formatter | Linter | LSP |
|---|---|---|---|
| TypeScript / JavaScript | biome | biome | typescript-language-server |
| Rust | rustfmt | clippy | rust-analyzer |
| Python | ruff | ruff (+ mypy pour le typage) | — |
| C / C++ | clang-format | clang-tidy, cppcheck | clangd |
| Lua | stylua | luacheck | lua-language-server |
| Shell | shfmt | shellcheck | — |
| JSON | biome | biome | — |
| TOML | taplo | taplo | taplo |
| YAML | — | yamllint | — |
| Markdown | — | markdownlint-cli | — |

## Roadmap
Version actuelle : 0.0

### Version 1.0
Cette version devra contenir un Containerfile construisant une image opérationnelle, et une devbox instanciée depuis cette image par distrobox.
Celle-ci contiendra l'ensemble des outils présentés précédemment, configurés de manière minimale.
La devbox se voulant évolutive, les configurations des outils de cette version n'ont pas besoin d'être parfaites.

TODO :
- ajouter et configurer
    - nvim
        - trouver une distribution complète et l'adapter
    - omp

### Version 2.0
Cette version se concentrera sur l'observabilité.
L'objectif étant de mettre en place un maximum de hooks qui renseigneront les actions effectuées (touches de clavier, raccourcis nvim, déplacements dans yazi/herdr...) dans une base de données. Celle-ci serait par la suite analysée pour identifier des patterns récurrents qui seraient éliminés en créant par exemple de nouveaux raccourcis.

### Version 3.0
Cette version se concentrera sur la gestion des connaissances du développeur.
L'idée est de mettre en place des mécanismes d'apprentissage pour améliorer dans le temps les connaissances du développeur utilisant **devbox**.
On pourra utiliser les développements sur l'observabilité de la version 2.0 pour identifier les lacunes à combler.
