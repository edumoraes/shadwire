# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# D3 draws the Chart component (the only third-party JS dependency). The chart
# imports it on connect, so only pages with a chart load it.
pin "d3", to: "https://cdn.jsdelivr.net/npm/d3@7.9.0/+esm", preload: false
