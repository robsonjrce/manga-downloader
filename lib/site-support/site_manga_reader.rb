module SiteSupportPlugin
  class MangaReader < SiteSupportPlugin::PluginBase
    def manga_title
      "#mangaproperties h1"
    end

    def chapter_list
      "#listing a"
    end

    def chapter_list_parse url
      @url_sanitized + url
    end

    def page_list
      '#selectpage #pageMenu option'
    end

    def page_list_parse url
      @url_sanitized + url
    end

    def image
      '#img'
    end

    def image_alt text
      text.match("^(.*?)\s\-\s(.*?)$")
    end
  end
end