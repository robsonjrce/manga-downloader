require "test/unit"
require File.expand_path("../../../lib/site-support/site_support", __FILE__)

class SiteSupportTest < Test::Unit::TestCase

  def test_site_support_manga_here
    assert_instance_of SiteSupportPlugin::MangaHere, SiteSupport::SiteSupportFactory.factory("http://www.mangahere.co/manga/onegai_teacher/")
    assert_instance_of SiteSupportPlugin::MangaHere, SiteSupport::SiteSupportFactory.factory("http://www.mangahere.co/manga/one_piece/")
    assert_instance_of SiteSupportPlugin::MangaHere, SiteSupport::SiteSupportFactory.factory("http://www.mangahere.co/manga/bloodline/")
  end

  def test_site_support_manga_reader
    assert_instance_of SiteSupportPlugin::MangaReader, SiteSupport::SiteSupportFactory.factory("http://www.mangareader.net/shingeki-no-kyojin")
    assert_instance_of SiteSupportPlugin::MangaReader, SiteSupport::SiteSupportFactory.factory("http://www.mangareader.net/103/one-piece.html")
    assert_instance_of SiteSupportPlugin::MangaReader, SiteSupport::SiteSupportFactory.factory("http://www.mangareader.net/96/berserk.html")
  end

end