set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :fonts_dir, 'stylesheets/fonts'

# layouts
page "example_1.html", layout: "example_layout"
page "example_2.html", layout: "example_layout"
page "example_3.html", layout: "example_layout"

# Development-specific configuration
configure :development do
  set :debug_assets, true   # deliver js in individual files
end

# Build-specific configuration
configure :build do
  activate :relative_assets
  set :relative_links, true
end