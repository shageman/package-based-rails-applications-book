# visualize_packwerk

## packs.png for every package in your app

This will generate a local dependency diagram for every pack in your app

```
find . -iname 'package.yml' | sed 's/\/package.yml//g' | sed 's/\.\///' | xargs -I % sh -c "bundle exec visualize_packs --only=% > %/packs.dot && dot %/packs.dot -Tpng -o %/packs.png"
```

## Get help

```
bundle exec visualize_packs --help
```