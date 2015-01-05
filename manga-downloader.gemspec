require File.expand_path("../lib/manga-downloader/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name    = 'manga-downloader'
  gem.version = MangaDownloader::VERSION
  gem.date    = Date.today.to_s
  gem.licenses = ['MIT']

  gem.summary = "downloads and compile to a Kindle optimized manga in PDF"
  gem.description = "downloads any manga from MangaReader.net"

  gem.authors  = ['Robson Jr']
  gem.email    = 'contato@robsonjr.com.br'
  gem.homepage = 'http://github.com/robsonjrce/manga-downloader'

  gem.add_dependency('nokogiri', '~> 1.6')
  gem.add_dependency('typhoeus', '~> 0.6')
  gem.add_dependency('rmagick', '~> 2.13')
  gem.add_dependency('prawn', '~> 1.3')
  gem.add_dependency('fastimage', '~> 1.6')

  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', '{bin,lib}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")

  gem.bindir = 'bin'
  gem.executables << 'manga-downloader'
end
