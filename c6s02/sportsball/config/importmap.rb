# typed: false
# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "foundation", to: "https://ga.jspm.io/npm:foundation@4.2.1-1/stylus/foundation.js"
pin "path", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.14/nodelibs/browser/path.js"
pin "stylus-type-utils", to: "https://ga.jspm.io/npm:stylus-type-utils@0.0.3/lib/type-utils.js"
