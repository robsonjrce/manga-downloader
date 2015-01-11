require "test/unit"
require File.expand_path("../../../lib/site-support/site_support", __FILE__)

class SiteMangaHereTest < Test::Unit::TestCase

  def setup
    @url = "http://www.mangahere.co/manga/onegai_teacher/"
    @factory = SiteSupport::SiteSupportFactory.factory(@url)
  end

  def test_should_maintain_url
    assert_equal @factory.url, @url
  end

  def test_should_not_change_url
    assert_not_respond_to @factory, :url=
  end

end