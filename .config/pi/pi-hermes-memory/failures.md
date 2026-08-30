[preference] Pas de commentaires inutiles dans le code ni les fichiers de config : pas de prose qui paraphrase le code, commenter seulement si l'information n'est pas évidente. <!-- created=2026-08-29, last=2026-08-29 -->
§
[tool-quirk] pi-hermes-memory (v0.9.7) : le store sqlite de recherche conserve des doublons des fichiers markdown ; une suppression via memory_remove ne nettoie pas la table sqlite. Pour vraiment tout vider, supprimer chaque entrée deux fois (fichier + sqlite) ; sinon memory_search remonte encore d'anciennes entrées. <!-- created=2026-08-29, last=2026-08-29 -->
§
[tool-quirk] pi-hermes-memory : l'écriture de mémoire contenant un chemin SSH est bloquée par un filtre de sécurité (threat pattern 'ssh_access'). Reformuler sans le chemin pour passer le filtre. <!-- created=2026-08-29, last=2026-08-29 -->
§
[correction] Les fichiers temporaires .*.recovery-* créés par l'extension pi-hermes-memory lors des écritures atomiques ne doivent jamais être commités. Ils ont été ignorés dans .gitignore via la règle .config/pi/pi-hermes-memory/.*.recovery-*. <!-- created=2026-08-29, last=2026-08-29 -->
§
[insight] just format vérifie que le justfile est lui-même formaté ; toute modification du justfile doit être syntaxiquement cohérente avec le format attendu sinon erreur "formatted justfile differs from original". <!-- created=2026-08-30, last=2026-08-30 -->
§
[tool-quirk] shfmt -f détecte les scripts sans extension avec shebang mais ignore .gitignore ; utiliser fd avec extensions explicites pour respecter .gitignore. <!-- created=2026-08-30, last=2026-08-30 -->
§
[tool-quirk] ruff.toml : indent-width n'est pas un champ valide dans la section [format] ; au top-level il est accepté (indent-width = 2). <!-- created=2026-08-30, last=2026-08-30 -->
§
[tool-quirk] clang-format : -style=file:cfg/.clang-format fonctionne pour pointer une config hors de l'arbre ; -style=file:cfg (répertoire) échoue. <!-- created=2026-08-30, last=2026-08-30 -->
§
[preference] Dans le projet devbox, le script scripts/format.lua est maintenu volontairement compact (≈2214 bytes, ~60 lignes) : Matteo a refusé une version >100 lignes, estimant qu'un simple lecteur de table + lanceur de formatter, plus le mode --staged, ne justifie pas ce volume. Toute évolution future du script doit rester minimale et éviter la duplication (regroupement extension→formatter partagé par les modes répertoire et --staged). — Failed: Matteo a rejeté le script format.lua initial (>100 lignes) qu'il jugeait excessivement complexe pour sa fonction ; il exige une version compacte et sans duplication. <!-- created=2026-08-30, last=2026-08-30 -->
§
[convention] Dans le projet devbox, la source de vérité des langages est .config/language/languages.lua (table Lua pure chargée nativement par nvim et par scripts/format.lua via luajit). Elle rassemble formatters (cmd, args, config, write, exts, chemins absolus) et languages (filetypes/treesitter/linter/formatter/lsp). Les configs des formatters sont déplacées dans .config/language/ (chemins absolus auto-résolus) et les flags --config sont passés via prepend_args sur les built-ins conform. Le hook git pre-commit (githooks/pre-commit) délègue à scripts/format.lua --staged, et core.hooksPath est posé dans just setup. <!-- created=2026-08-30, last=2026-08-30 -->
§
[insight] Dans le projet devbox, certaines configurations de formatters ont des formats incompatibles qui empêchent toute unification : biome.json est du JSON, .clang-format du YAML, .editorconfig de l'INI, et seuls ruff.toml/rustfmt.toml/.taplo.toml/.stylua.toml sont du TOML (avec des schémas incompatibles entre eux). Un fichier de config global unique pour tous les formatters est donc impossible. <!-- created=2026-08-30, last=2026-08-30 -->
§
[tool-quirk] shfmt -f<dir> détecte les scripts shell sans extension avec shebang, mais ignore totalement .gitignore ; ce n'est pas une alternative fiable à fd pour lister proprement les fichiers à formater dans un dépôt. <!-- created=2026-08-30, last=2026-08-30 -->
§
[tool-quirk] Lors d'un premier essai de taplo format sur un fichier TOML, la config auto-découverte était appliquée, mais impossible de valider la clé indent-width via ruff format car la clé valide est indent-style/indent-width au niveau [format] uniquement ; une clé indent-width au top-level échoue avec unknown field, et ruff check accepte indent-width top-level mais pas ruff format. <!-- created=2026-08-30, last=2026-08-30 -->
§
[insight] Dans init.lua (Neovim), éviter les variables intermédiaires inutiles comme formatters_by_ft quand on peut itérer directement sur langmod.languages ; garder les commentaires de consommation dans languages.lua lui-même, pas dans l'en-tête de section de init.lua. <!-- created=2026-08-30, last=2026-08-30 -->
§
[insight] biome rejette la présence d'une config racine imbriquée (biome.json dans un sous-dossier sans config à la racine) : il faut exclure le répertoire des configs des formatters lors de l'analyse récursive. <!-- created=2026-08-30, last=2026-08-30 -->
§
[correction] shfmt -f détecte les scripts sans extension avec shebang, mais ignore .gitignore ; fd -e respecte .gitignore mais ne voit pas les scripts sans extension. Le choix dépend du besoin (reproductibilité vs couverture), pas d'une supériorité intrinsèque. <!-- created=2026-08-30, last=2026-08-30 -->
§
[tool-quirk] ruff : la clé indent-width n'est pas reconnue au niveau format (erreur `unknown field`) mais fonctionne au niveau top-level ; il faut tester les clés exactes par outil avant d'écrire les configs. <!-- created=2026-08-30, last=2026-08-30 -->
§
[insight] Un script de formatage doit compter les fichiers modifiés (hash avant/après), pas les fichiers scannés, sinon il affiche toujours des fichiers 'à formater' alors que les formatters sont idempotents. <!-- created=2026-08-30, last=2026-08-30 -->
§
[failure] scripts/format.lua : fd sans -H ignore les répertoires cachés, donc ne voit pas .config (où vit tout le devbox home) et .editorconfig. Trouvé par l'utilisateur (« le script parse bien recursivement ? »). Fix : fd -H -E .git (le respect de .gitignore reste actif avec -H). <!-- created=2026-08-30, last=2026-08-30 -->
§
[correction] scripts/format.lua : compter les « fichiers trouvés/scannés » donne l'illusion que le script reformate à chaque appel, alors que les formatters sont idempotents. Fix : hash md5sum avant/après pour compter les fichiers réellement modifiés, pas les scannés. <!-- created=2026-08-30, last=2026-08-30 -->
§
[insight] Les sorties de formatters polluaient le retour du script de formatage ; les rediriger vers un log temporaire n'affiché qu'en cas d'échec clarifie le retour (succès = uniquement « → formatter : N fichier(s) »). <!-- created=2026-08-30, last=2026-08-30 -->