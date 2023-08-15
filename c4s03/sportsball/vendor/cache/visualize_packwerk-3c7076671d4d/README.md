# visualize_packwerk

## packs.png for every package in your app

This will generate a local dependency diagram for every pack in your app

```
find . -iname 'package.yml' | sed 's/\/package.yml//g' | sed 's/\.\///' | xargs -I % sh -c "bundle exec visualize_packs --only=% > %/packs.dot && dot %/packs.dot -Tpng -o %/packs.png"
```

If your app is large and has many packages and violations, the above graphs will likely be too big. Try this version to get only the edges to and from the focus package for each diagram:

```
find . -iname 'package.yml' | sed 's/\/package.yml//g' | sed 's/\.\///' | xargs -I % sh -c "bundle exec visualize_packs --only=% --only-edges-to-focus > %/packs.dot && dot %/packs.dot -Tpng -o %/packs.png"
```


## Get help

```
bundle exec visualize_packs --help
```

## What outputs look like

![Sample diagrams produced](https://github.com/shageman/visualize_packwerk/blob/main/diagram_examples.png?raw=true)

## Contributing

To contribute, install graphviz (and the `dot` command). You must also have Ruby 3.2.2 and bundler installed. Then

```
cd spec
./test.sh
```

Then, in `spec/sample_app` visually compare all `X.png` to `X_new.png` to make sure you are happy with the changes. If you, are, run `./update_cassettes.sh` in the same folder and commit the new test files with your changes.

If you have imagemagick installed, you can then also run `./create_comparison.sh` to create one big image of all the before (left) and after (right) versions of the sample diagrams.