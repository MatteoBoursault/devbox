Matteo, français, ingénieur en informatique, futur architecte logiciel. Objectif : devenir très bon en informatique. <!-- created=2026-08-29, last=2026-08-29 -->
§
Fix temporaire dans le projet devbox : le documenter par un commentaire « TODO_devbox : blabla, voici pourquoi ce bricolage a été mis en place... ». <!-- created=2026-08-29, last=2026-08-29 -->
§
Contrôle fin et compréhension : Matteo veut suivre précisément ce que fait l'agent et le comprendre. Sauf mention contraire, demander quand un choix se présente : il a en général une idée précise de ce qu'il souhaite. <!-- created=2026-08-29, last=2026-08-29 -->
§
Gestion git : c'est Matteo qui gère git, pas l'agent. Ne pas commit ni push de soi-même. <!-- created=2026-08-29, last=2026-08-29 -->
§
Matteo veut des recettes just et une organisation des configs cohérentes ; il questionne systématiquement les choix de l'agent quand une approche diffère des autres outils (ex. shfmt vs fd) et exige des justifications vérifiées, pas des approximations. <!-- created=2026-08-30, last=2026-08-30 -->
§
Matteo exige des scripts et configs minimalistes, sans complexité superflue ni verbosité inutile. <!-- created=2026-08-30, last=2026-08-30 -->
§
Matteo repère et signale les couplages inutiles (ex. dépendance à git pour un script hors dépôt, duplication de données, variables redondantes). <!-- created=2026-08-30, last=2026-08-30 -->
§
Matteo veut que les explications sur la consommation d'un fichier partagé vivent dans ce fichier lui-même, pas chez ses consommateurs. <!-- created=2026-08-30, last=2026-08-30 -->
§
Matteo préfère co-localiser les données de configuration (ex. réglages LSP) avec les entités qu'elles décrivent, plutôt que les séparer dans des fichiers consommateurs. <!-- created=2026-08-30, last=2026-08-30 -->
§
Matteo exige des scripts minimalistes : il conteste systématiquement la taille des scripts (ex. format.lua réduit de 110 à 90 lignes, le cœur étant ~20 lignes) et considère la verbosité des commentaires comme de la complexité superflue. <!-- created=2026-08-30, last=2026-08-30 -->
§
Matteo préfère que les scripts fonctionnent hors du dépôt git et sans dépendance à git quand ce n'est pas nécessaire (localisation par emplacement du script, pas par rev-parse). <!-- created=2026-08-30, last=2026-08-30 -->
§
Coding preferences: 2-space indent, 120-char line width. Values minimal code — no unnecessary variables/abstractions, single source of truth, no duplication, co-locate config with its consumer. Wants facts verified before acting (don't assume); asks to be questioned until 100% sure of the plan. <!-- created=2026-08-30, last=2026-08-30 -->
§
Matteo a demandé que la fonction fish `sch` ouvre un onglet herdr quand on édite un fichier, comme le fait actuellement yazi via open-in-herdr.sh. (Cette préférence spécifique doit être implémentée — il n'a pas encore précisé comment gérer le cas où herdr n'est pas disponible.) <!-- created=2026-08-30, last=2026-08-30 -->
§
Matteo a demandé que la fonction fish `sch` ouvre un onglet herdr quand on édite un fichier, comme le fait actuellement yazi via open-in-herdr.sh. Cette préférence est désormais implémentée : il n'a pas précisé comment gérer le cas où herdr n'est pas disponible. <!-- created=2026-08-30, last=2026-08-30 -->
§
Matteo préfère que biome.json reste dans .config/language/ (co-localisé avec les autres configs de formatage) plutôt qu'à la racine du dépôt, même si cela demande des ajustements dans nvim-lint. Il valorise la co-localisation des configs. <!-- created=2026-08-30, last=2026-08-30 -->
§
Matteo wants linter configs (luacheck globals, markdownlint rules) defined inside languages.lua, co-located with the language/formatter configs, rather than in separate root-level config files - to avoid redundancy and keep a single source of truth. <!-- created=2026-08-30, last=2026-08-30 -->
