# ParsePackwerk
This gem is meant to give a way to parse the various YML files that come with [`packwerk`](https://github.com/Shopify/packwerk).

# Usage
```ruby
# Get all packages
# Note that currently, this does not respect configuration in `packwerk.yml`
packages = ParsePackwerk.all

# Get a single package with a given ame
package = ParsePackwerk.find('packs/my_pack')

# Get a structured `package_todo.yml` object a single package
package_todo = ParsePackwerk::PackageTodo.for(package)

# Count violations of a particular type for a package
package_todo.violations.count(&:privacy?)
package_todo.violations.count(&:dependency?)

# Get the number of files a particular constant is violated in
package_todo.violations.select { |v| v.class_name == 'SomeConstant' }.sum { |v| v.files.count }
```

# Why does this gem exist?
We generally recommend folks depend on `packwerk` rather than `parse_packwerk`. This gem is mostly a private implementation for other parts of the Big Rails modularization toolchain.

This gem exists for this toolchain for these reasons:

- `packwerk` is lacking public APIs for the behavior we want. It's close with `PackageSet`, but we need to also be able to parse violations.
- Certain critical, production runtime code-paths need to use this, and we want a simple, low-dependency, infrequently changing dependency for our production environment. One example of production usage is that `package.yml` files can store team ownership information, which is used when an error happens in production to route it to the right team.
- `packwerk` has heavy duty dependencies like rails and lots of others, and it adds a degree of maintenance cost and complexity that isn’t necessary when all we want to do is read YML files

Long-term, it might make sense for these reasons to extract out some of the parsing from `packwerk` into a separate gem similar to this so that we can leverage the ecosystem of tools associated with the idea of a “pack” in ways that are simple and safe for both development and production environments.
