require "test/unit"
require File.expand_path("../../../lib/site-support/site_support", __FILE__)

class SiteMangaReaderTest < Test::Unit::TestCase

  def setup
    @url = "http://www.mangareader.net/shingeki-no-kyojin"
    @factory = SiteSupport::SiteSupportFactory.factory(@url)
  end

  def test_must_not_change_url
    assert_equal @factory.url, @url
  end

  def test_should_not_change_url
    assert_not_respond_to @factory, :url=
  end

end