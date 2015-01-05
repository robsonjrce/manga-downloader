# Manga Downloader

A command line tool to download and convert manga into customized volumes for reading at e-book reader heavily based on [manga-downloadr](https://github.com/akitaonrails/manga-downloadr).

The main motivation for this tool is to download and maintain the original files for the manga being downloaded and make possible to convert them into files that could be easily read on e-book readers.

## Support

It current supports the following file types:

* pdf
* cbz (you should have `zip package` installed)

And the following sites:

* www.mangareader.net
* www.mangahere.co

## Installation

Just install with:

```
gem 'manga-downloader', :github => 'robsonjrce/manga-downloader'
```

## Configuration

And then execute:

    $ manga-downloader <command>

* `--init URL`                   Create an empty manga-downloader repository
* `--fetch`                      Download objects and references from the repository
* `--check [FOLDER]`             Checks the integrity of the repository
* `--pdf [FOLDER]`               Compiles the destination folder into pdf
* `--cbz [FOLDER]`               Compiles the destination folder into cbz
* `--size PAGE_SIZE`             Defines the size of the page to be rendered width,height

## Usage

We should define a new directory and initialize our repository:

```
manga-downloader --init http://www.mangareader.net/shingeki-no-kyojin --size 1080,1440
```

Notice that our page size is defined to Kobo Aura HD. For Kindle Paperwhite, use:

```
manga-downloader --init http://www.mangareader.net/shingeki-no-kyojin --size 600,800
```

The configuration defined is stored at the current directory under the file `manga-downloader.yaml`

After setting up our environment, we should download all the volumes available:

```
manga-downloader --fetch
```

(during download state, you can be shown all retry attempts)

And convert it to be read on our e-reader:

On devices that support cbz files (as Kobo Aura HD), to convert all volumes:
```
manga-downloader --cbz
```

And a single volume:
```
manga-downloader --cbz [Volume Name]
```

For all the others devices, there's always the support of `PDF`:

```
manga-downloader --pdf
```

## Contributing

1. Fork it ( https://github.com/robsonjrce/manga-downloader/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
