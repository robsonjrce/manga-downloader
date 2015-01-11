require "test/unit"
require "mocha/setup"
require "webmock/test_unit"
require File.expand_path("../../lib/manga-downloader", __FILE__)

class MangaDownloaderTest < Test::Unit::TestCase

  def setup
    @manga_page   = "http://www.mangareader.net/shingeki-no-kyojin"
    @chapter_page = "http://www.mangareader.net/shingeki-no-kyojin/1"
    @image_page   = "http://www.mangareader.net/shingeki-no-kyojin/1"
    @options      = {:url => @manga_page}
    @generator    = MangaDownloader::Workflow.new(@options)
  end

  def test_default_url
    assert_equal @generator.manga_root_url, @manga_page
  end

  def test_must_find_title_and_chapters
    stub_request(:get, @manga_page).to_return(body: File.read("test/fixtures/shingeki-no-kyojin.html"))
    @generator.fetch_chapter_urls
    assert_equal "Shingeki no Kyojin Manga", @generator.manga_title
    expected_chapters = ["http://www.mangareader.net/shingeki-no-kyojin/1", "http://www.mangareader.net/shingeki-no-kyojin/2", "http://www.mangareader.net/shingeki-no-kyojin/3", "http://www.mangareader.net/shingeki-no-kyojin/4", "http://www.mangareader.net/shingeki-no-kyojin/5", "http://www.mangareader.net/shingeki-no-kyojin/6", "http://www.mangareader.net/shingeki-no-kyojin/7", "http://www.mangareader.net/shingeki-no-kyojin/8", "http://www.mangareader.net/shingeki-no-kyojin/9", "http://www.mangareader.net/shingeki-no-kyojin/10", "http://www.mangareader.net/shingeki-no-kyojin/11", "http://www.mangareader.net/shingeki-no-kyojin/12", "http://www.mangareader.net/shingeki-no-kyojin/13", "http://www.mangareader.net/shingeki-no-kyojin/14", "http://www.mangareader.net/shingeki-no-kyojin/15", "http://www.mangareader.net/shingeki-no-kyojin/16", "http://www.mangareader.net/shingeki-no-kyojin/17", "http://www.mangareader.net/shingeki-no-kyojin/18", "http://www.mangareader.net/shingeki-no-kyojin/19", "http://www.mangareader.net/shingeki-no-kyojin/20", "http://www.mangareader.net/shingeki-no-kyojin/21", "http://www.mangareader.net/shingeki-no-kyojin/22", "http://www.mangareader.net/shingeki-no-kyojin/23", "http://www.mangareader.net/shingeki-no-kyojin/27", "http://www.mangareader.net/shingeki-no-kyojin/28", "http://www.mangareader.net/shingeki-no-kyojin/29", "http://www.mangareader.net/shingeki-no-kyojin/30", "http://www.mangareader.net/shingeki-no-kyojin/31", "http://www.mangareader.net/shingeki-no-kyojin/32", "http://www.mangareader.net/shingeki-no-kyojin/33", "http://www.mangareader.net/shingeki-no-kyojin/34", "http://www.mangareader.net/shingeki-no-kyojin/35", "http://www.mangareader.net/shingeki-no-kyojin/36", "http://www.mangareader.net/shingeki-no-kyojin/37", "http://www.mangareader.net/shingeki-no-kyojin/38", "http://www.mangareader.net/shingeki-no-kyojin/39", "http://www.mangareader.net/shingeki-no-kyojin/40", "http://www.mangareader.net/shingeki-no-kyojin/41", "http://www.mangareader.net/shingeki-no-kyojin/42", "http://www.mangareader.net/shingeki-no-kyojin/43", "http://www.mangareader.net/shingeki-no-kyojin/44", "http://www.mangareader.net/shingeki-no-kyojin/45", "http://www.mangareader.net/shingeki-no-kyojin/46", "http://www.mangareader.net/shingeki-no-kyojin/47", "http://www.mangareader.net/shingeki-no-kyojin/48", "http://www.mangareader.net/shingeki-no-kyojin/49", "http://www.mangareader.net/shingeki-no-kyojin/50", "http://www.mangareader.net/shingeki-no-kyojin/51", "http://www.mangareader.net/shingeki-no-kyojin/52", "http://www.mangareader.net/shingeki-no-kyojin/53", "http://www.mangareader.net/shingeki-no-kyojin/54", "http://www.mangareader.net/shingeki-no-kyojin/55", "http://www.mangareader.net/shingeki-no-kyojin/56", "http://www.mangareader.net/shingeki-no-kyojin/57", "http://www.mangareader.net/shingeki-no-kyojin/58", "http://www.mangareader.net/shingeki-no-kyojin/59", "http://www.mangareader.net/shingeki-no-kyojin/60", "http://www.mangareader.net/shingeki-no-kyojin/61", "http://www.mangareader.net/shingeki-no-kyojin/62", "http://www.mangareader.net/shingeki-no-kyojin/63", "http://www.mangareader.net/shingeki-no-kyojin/64", "http://www.mangareader.net/shingeki-no-kyojin/65"]
    assert_equal expected_chapters, @generator.chapter_list
  end

  def test_must_find_pages
    stub_request(:get, @chapter_page).to_return(body: File.read("test/fixtures/shingeki-no-kyojin-1.html"))
    @generator.chapter_list = [@chapter_page]
    @generator.fetch_page_urls
    assert_equal 58, @generator.chapter_pages[@generator.chapter_list[0]].count
    expected_pages = ["http://www.mangareader.net/shingeki-no-kyojin/1", "http://www.mangareader.net/shingeki-no-kyojin/1/2", "http://www.mangareader.net/shingeki-no-kyojin/1/3", "http://www.mangareader.net/shingeki-no-kyojin/1/4", "http://www.mangareader.net/shingeki-no-kyojin/1/5", "http://www.mangareader.net/shingeki-no-kyojin/1/6", "http://www.mangareader.net/shingeki-no-kyojin/1/7", "http://www.mangareader.net/shingeki-no-kyojin/1/8", "http://www.mangareader.net/shingeki-no-kyojin/1/9", "http://www.mangareader.net/shingeki-no-kyojin/1/10", "http://www.mangareader.net/shingeki-no-kyojin/1/11", "http://www.mangareader.net/shingeki-no-kyojin/1/12", "http://www.mangareader.net/shingeki-no-kyojin/1/13", "http://www.mangareader.net/shingeki-no-kyojin/1/14", "http://www.mangareader.net/shingeki-no-kyojin/1/15", "http://www.mangareader.net/shingeki-no-kyojin/1/16", "http://www.mangareader.net/shingeki-no-kyojin/1/17", "http://www.mangareader.net/shingeki-no-kyojin/1/18", "http://www.mangareader.net/shingeki-no-kyojin/1/19", "http://www.mangareader.net/shingeki-no-kyojin/1/20", "http://www.mangareader.net/shingeki-no-kyojin/1/21", "http://www.mangareader.net/shingeki-no-kyojin/1/22", "http://www.mangareader.net/shingeki-no-kyojin/1/23", "http://www.mangareader.net/shingeki-no-kyojin/1/24", "http://www.mangareader.net/shingeki-no-kyojin/1/25", "http://www.mangareader.net/shingeki-no-kyojin/1/26", "http://www.mangareader.net/shingeki-no-kyojin/1/27", "http://www.mangareader.net/shingeki-no-kyojin/1/28", "http://www.mangareader.net/shingeki-no-kyojin/1/29", "http://www.mangareader.net/shingeki-no-kyojin/1/30", "http://www.mangareader.net/shingeki-no-kyojin/1/31", "http://www.mangareader.net/shingeki-no-kyojin/1/32", "http://www.mangareader.net/shingeki-no-kyojin/1/33", "http://www.mangareader.net/shingeki-no-kyojin/1/34", "http://www.mangareader.net/shingeki-no-kyojin/1/35", "http://www.mangareader.net/shingeki-no-kyojin/1/36", "http://www.mangareader.net/shingeki-no-kyojin/1/37", "http://www.mangareader.net/shingeki-no-kyojin/1/38", "http://www.mangareader.net/shingeki-no-kyojin/1/39", "http://www.mangareader.net/shingeki-no-kyojin/1/40", "http://www.mangareader.net/shingeki-no-kyojin/1/41", "http://www.mangareader.net/shingeki-no-kyojin/1/42", "http://www.mangareader.net/shingeki-no-kyojin/1/43", "http://www.mangareader.net/shingeki-no-kyojin/1/44", "http://www.mangareader.net/shingeki-no-kyojin/1/45", "http://www.mangareader.net/shingeki-no-kyojin/1/46", "http://www.mangareader.net/shingeki-no-kyojin/1/47", "http://www.mangareader.net/shingeki-no-kyojin/1/48", "http://www.mangareader.net/shingeki-no-kyojin/1/49", "http://www.mangareader.net/shingeki-no-kyojin/1/50", "http://www.mangareader.net/shingeki-no-kyojin/1/51", "http://www.mangareader.net/shingeki-no-kyojin/1/52", "http://www.mangareader.net/shingeki-no-kyojin/1/53", "http://www.mangareader.net/shingeki-no-kyojin/1/54", "http://www.mangareader.net/shingeki-no-kyojin/1/55", "http://www.mangareader.net/shingeki-no-kyojin/1/56", "http://www.mangareader.net/shingeki-no-kyojin/1/57", "http://www.mangareader.net/shingeki-no-kyojin/1/58"]
    assert_equal expected_pages, @generator.chapter_pages[@generator.chapter_list[0]]
  end

  def test_must_find_pages_image
    stub_request(:get, @image_page).to_return(body: File.read("test/fixtures/shingeki-no-kyojin-1-1.html"))
    @generator.chapter_list  = [@chapter_page]
    @generator.chapter_pages = {@chapter_page => ["http://www.mangareader.net/shingeki-no-kyojin/1"]}
    @generator.fetch_image_urls
    expected_image = MangaDownloader::ImageData.new( "Shingeki no Kyojin 1", "Page 1.jpg", "http://i11.mangareader.net/shingeki-no-kyojin/1/shingeki-no-kyojin-1813085.jpg" )
    assert_equal expected_image, @generator.chapter_images[@chapter_page][0]
    assert_equal 1, @generator.chapter_images[@chapter_page].count
  end

end