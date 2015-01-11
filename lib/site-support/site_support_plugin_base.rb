module SiteSupportPlugin
  class PluginBase
    def initialize url
      @url = url
      @url_sanitized = url.gsub(URI.parse(url).path, '')
    end

    def url
      @url
    end
  end
end