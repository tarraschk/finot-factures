# Finot Factures

Outil de récupération automatique des factures de différents fournisseurs.

Pour le moment, cet outil ne sert qu'à récupérer automatiquement les factures OVH.

Ces factures sont ensuite envoyées par email.

### Installation

```
git clone git@github.com:tarraschk/finot-factures.git
```

Puis adapter le fichier `config.yml` avec les clés d'API OVH (pour récupérer les factures) et SendInBlue (envoi de mails).

### Exécution

Pour lancer le script une fois :

```
bundle install
bundle exec ruby script.rb
```

Pour le lancer dans une CRONTAB :

```
# Get the RVM Wrappers path:
rvm wrapper show
# Will display something like "Wrappers path: /usr/share/rvm/gems/ruby-3.0.0/wrappers"
# Take the same folder and append /ruby at the end
# /usr/share/rvm/gems/ruby-3.0.0/wrappers => /usr/share/rvm/gems/ruby-3.0.0/wrappers/ruby

# Then run the Crontab Editor
crontab -e

# And add:
0 20 * * * /<YOUR_WRAPPERS_PATH>/ruby <YOUR_PROJECT_PATH>/script.rb
# Example: 0 20 * * * /usr/share/rvm/gems/ruby-3.0.0/wrappers/ruby /home/ubuntu/workspace/finot-factures/script.rb
```

### Fournisseurs supportés

Pour le moment, seulement OVH.

### Licensing

This project is licensed under the [CC BY 4.0 license](https://creativecommons.org/licenses/by/4.0/).

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
