require 'rubygems'
require 'bundler/setup'

require 'nokogiri'
require 'typhoeus'
require 'fileutils'
require 'rmagick'
require 'prawn'
require 'fastimage'
require 'open-uri'
require 'yaml'
require 'site-suport'

module MangaDownloader
  ImageData = Struct.new(:folder, :filename, :url)

  class Workflow
    attr_accessor :manga_root_url, :manga_root, :manga_root_folder, :manga_name, :hydra_concurrency
    attr_accessor :chapter_list, :chapter_pages, :chapter_images, :download_links, :chapter_pages_count
    attr_accessor :manga_title, :pages_per_volume, :page_size
    attr_accessor :processing_state
    attr_accessor :fetch_page_urls_errors, :fetch_image_urls_errors, :fetch_images_errors
    attr_accessor :site

    def initialize(options = {})
      self.manga_root_url    = options[:url]
      self.manga_root        = options[:manga_root] || "./"
      self.manga_root_folder = File.join(manga_root)
      self.manga_name        = File.basename(Dir.pwd)

      self.hydra_concurrency = options[:hydra_concurrency]

      self.chapter_pages    = {}
      self.chapter_images   = {}

      self.pages_per_volume = options[:pages_per_volume]
      self.page_size        = options[:page_size]

      self.processing_state        = []
      self.fetch_page_urls_errors  = []
      self.fetch_image_urls_errors = []
      self.fetch_images_errors     = []

      # factory for manga site
      self.site = SiteSuport::SiteSuportFactory.factory options[:url]
    end

    def fetch_chapter_urls
      doc = Nokogiri::HTML(open(manga_root_url))

      self.manga_title  = doc.css(site.manga_title).first.text
      self.chapter_list = doc.css(site.chapter_list).map do |l|
        print "."
        site.chapter_list_parse(l['href'])
      end

      current_state :chapter_urls
    end

    def fetch_page_urls
      hydra = Typhoeus::Hydra.new(max_concurrency: hydra_concurrency)
      chapter_list.each do |chapter_link|
        begin
          request = Typhoeus::Request.new "#{chapter_link}"
          request.on_complete do |response|
            if response.success?
              chapter_doc = Nokogiri::HTML(response.body)
              pages = chapter_doc.css(site.page_list)
              chapter_pages.merge!(chapter_link => pages.map { |p| site.page_list_parse(p['value']) })
              print '.'
            else
              self.fetch_page_urls_errors << { url: chapter_link, error: response.code, body: response.body }
              print "e"
              hydra.queue response.request
            end
          end
          hydra.queue request
        rescue => e
          puts e
        end
      end
      hydra.run
      unless fetch_page_urls_errors.empty?
        print "\n"
        print "Errors fetching page urls:"
        print fetch_page_urls_errors
        print "\n"
      end

      self.chapter_pages_count = chapter_pages.values.inject(0) { |total, list| total += list.size }
      current_state :page_urls
    end

    def fetch_image_urls
      hydra = Typhoeus::Hydra.new(max_concurrency: hydra_concurrency)
      chapter_list.each do |chapter_key|
        chapter_pages[chapter_key].each do |page_link|
          begin
            request = Typhoeus::Request.new "#{page_link}"
            request.on_complete do |response|
              if response.success?
                chapter_doc = Nokogiri::HTML(response.body)
                image       = chapter_doc.css(site.image).first
                next if image.nil?
                tokens      = site.image_alt(image['alt'])
                extension   = File.extname(URI.parse(image['src']).path)

                chapter_images.merge!(chapter_key => []) if chapter_images[chapter_key].nil?
                chapter_images[chapter_key] << ImageData.new( tokens[1], "#{tokens[2]}#{extension}", image['src'] )
                print '.'
              else
                self.fetch_image_urls_errors << { url: page_link, error: response.code }
                print "e"
                hydra.queue response.request
              end
            end
            hydra.queue request
          rescue => e
            puts e
          end
        end
      end
      hydra.run
      unless fetch_image_urls_errors.empty?
        print "\n"
        print "Errors fetching image urls:"
        print fetch_image_urls_errors
        print "\n"
      end

      current_state :image_urls
    end

    def fetch_images
      hydra = Typhoeus::Hydra.new(max_concurrency: hydra_concurrency)
      chapter_list.each_with_index do |chapter_key, chapter_index|
        chapter_images[chapter_key].each do |file|
          begin
            downloaded_filename = File.join(manga_root_folder, file.folder, file.filename)
            if File.exists?(downloaded_filename) # effectively resumes the download list without re-downloading everything
              print "x"
              next
            end
            request = Typhoeus::Request.new file.url
            request.on_complete do |response|
              if response.success?
                # download
                FileUtils.mkdir_p(File.join(manga_root_folder, file.folder))
                File.open(downloaded_filename, "wb+") { |f| f.write response.body }
                print "."
              else
                self.fetch_images_errors << { url: file.url, error: response.code }
                print "e"
                hydra.queue response.request
              end

              GC.start # to avoid a leak too big (ImageMagick is notorious for that, specially on resizes)
            end
            hydra.queue request
          rescue => e
            puts e
          end
        end
      end
      hydra.run
      unless fetch_images_errors.empty?
        print "\n"
        print "Errors downloading images:"
        print "\n"
        print fetch_images_errors
        print "\n"
      end

      current_state :images
    end

    def check folder
      if folder.nil?
        folders = Dir[manga_root_folder + "*"].sort_by { |element| ary = element.split(" ").last.to_i }
      else
        folders = [folder]
      end

      folders.each do |folder|
        next if !File.directory?(folder)
        print "\tChecking #{folder}: "
        files = Dir[File.join(folder, "*.*")].sort_by { |element| ary = element.split(" ").last.to_i }
        files_count = files.count
        file_last = files.last.split(" ").last.to_i
        if files.count == file_last
          print "correct"
        else
          print "failed"
        end
        files.each do |file|
          if File.zero?(file)
            FileUtils.rm(file)
            print "\n\t\t file #{File.basename(file)} was removed"
          end
        end
        print "\n"
      end
    end

    def clear_cache folder
      if folder.nil?
        folders = Dir[manga_root_folder + "*"].sort_by { |element| ary = element.split(" ").last.to_i }
      else
        folders = [folder]
      end

      removed = 0
      folders.each do |folder|
        next if folder == "." || folder == ".." || !File.directory?(folder)
        folder_sanitized = folder.gsub(/^\.\//, "")
        folder_destination = ".#{folder_sanitized}"
        if File.directory? folder_destination
          FileUtils.rm_r(folder_destination, :force => true)
          removed += 1
          print "\tCleaning cache for #{folder_sanitized}"
        end
      end
      print "\n"
      print "\t#{removed} directory removed"
    end

    def compile_cbz folder
      Dir.chdir(manga_root_folder)

      if folder.nil?
        folders = Dir[".*"].sort_by { |element| ary = element.split(" ").last.to_i }
      else
        folders = [folder]
      end

      folders.each do |folder|
        next if folder == "." || folder == ".." || !File.directory?(folder)
        print "\tCompiling volume #{folder}"
        folder_sanitized = folder.gsub(/^\./, "")
        cbz_path = File.join("." + folder_sanitized)
        cbz_name = File.join(manga_root_folder, folder_sanitized + ".cbz")
        %x[zip -jr '#{cbz_name}' '#{cbz_path}']
      end
    end

    def compile_pdf folder
      Dir.chdir(manga_root_folder)

      if folder.nil?
        folders = Dir[".*"].sort_by { |element| ary = element.split(" ").last.to_i }
      else
        folders = [folder]
      end

      folders.each do |folder|
        next if folder == "." || folder == ".."
        print "\tCompiling volume #{folder}: "
        print 'd'
        folder_sanitized = folder.gsub(/^\./, "")
        files = Dir[File.join("." + folder_sanitized, "*.*")].sort_by { |element| ary = element.split(" ").last.to_i }
        # concatenating PDF files
        if !files.empty?
          pdf_file = File.join(manga_root_folder, folder_sanitized + ".pdf")
          Prawn::Document.generate(pdf_file, page_size: page_size) do |pdf|
            files.each do |image_file|
              begin
                pdf.image image_file, position: :center, vposition: :center
              rescue => e
                puts "Error in #{image_file} - #{e}"
              end
              print '.'
            end
          end
        end
      end
    end

    def resize_images folder
      if folder.nil?
        folders = Dir[manga_root_folder + "*"].sort_by { |element| ary = element.split(" ").last.to_i }
      else
        folders = [folder]
      end

      folders.each do |folder|
        print "\tCompiling volume #{folder}: "
        folder_resize = File.join(manga_root_folder, "." + File.basename(folder))
        if File.directory?(folder)
          if File.exists?(folder_resize) && File.directory?(folder_resize)
            print 'd'
          else
            print 'r'
            FileUtils.rm_r(folder_resize, :force => true)
            Dir.mkdir(folder_resize);
          end
        else
          print 'do not exist'
          next
        end
        Dir[File.join(folder,"*.*")].each do |file_raw|
          image = Magick::Image.read( file_raw ).first
          resized = image.resize(page_size[0], page_size[1])
          # resized = image.resize_to_fit(page_size[0], page_size[1])
          # resized.trim!
          filename_zerofill = "Page " + ("%03d" % file_raw.split(" ").last.to_i) + "." + (file_raw.gsub(/.*\./, ""))
          resized.write( File.join(folder_resize, File.basename(filename_zerofill)) ) { self.quality = 50 }
          print "."
        end
        GC.start # to avoid a leak too big (ImageMagick is notorious for that, specially on resizes)
      end
    end

    def state?(state)
      self.processing_state.include?(state)
    end

    private def current_state(state)
      self.processing_state << state
    end
  end
end
