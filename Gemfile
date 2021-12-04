source "https://rubygems.org"

gem "minima", "~> 2.5"

# To use GitHub Pages, comment out 'gem "jekyll"'
# and uncomment 'gem "github-pages"'.
# To upgrade, run `bundle update github-pages`.
gem "github-pages", "~> 219", group: :jekyll_plugins
# gem "jekyll", "~> 4.2.0"

# Jekyll-related plugins
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
  gem 'jekyll-seo-tag'
  gem 'jekyll-sitemap'
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

