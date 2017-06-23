#!/usr/bin/env ruby
require 'HTTParty'
require 'Nokogiri'
require 'JSON'
require 'fileutils'
require_relative 'helpers'

class ScrapeLOC
  def initialize
    # Default to all Japanese wood blocks. But you can use the filters on
    # this page to refine.
    @base_url = 'https://www.loc.gov/collections/japanese-fine-prints-pre-1915/'

    # find an image type to download
    # since the options vary for each image we'll choose the and option that
    # contains @img_type
    @img_type = 'JPEG' # JPEG, GIF, TIFF

    # the first @img_type found will be the smallest, the last will be largest
    @img_size = 'large' # large, small

    # output folder (will be created if it doesn't exist
    # NOTE: if you keep downloads it's been added to .gitignore
    @output_path = 'downloads'

    # @cache pages - if true we'll save the pages and if this is run again, parse
    # the file instead of downloading it.
    @cache = true # false
    @cache_dir = 'cached_urls'

    # if you haven't changed options and are just rerunning - don't replace images
    @always_replace_images = false # true

    @counter = 0

    # You need to modify base user if you want more images per page
    @page_size = 25

    @start_page = 65
    if @start_page.to_i > 0
      @base_url = "https://www.loc.gov/collections/" \
                  "japanese-fine-prints-pre-1915/?sp=#{@start_page}"
      @counter = @start_page * @page_size
    end

    FileUtils::mkdir_p @output_path
    FileUtils::mkdir_p @cache_dir if @cache
  end

  def run
    download_page_images(@base_url)
  end

  def download_page_images(url)
    parsed = get_url(url, @cache, @cache_dir)

    next_page_url = parsed.css('.next').attribute('href').to_s

    # get all links to images on page
=begin
    <span class="item-description-title">
      <a href="https://www.loc.gov/item/2002700113/"
        rel="http://www.loc.gov/item/2002700113/ ">
        [Village scene in Japan showing people engaged in various activities]
      </a>
    </span>
=end
    parsed.css('.item-description-title').each do |span|
      a = span.css('a')
      url = a.attribute('href').to_s
      next if blank?(url)

      puts url
      parsed_detail_page = get_url(url, @cache, @cache_dir)

      # get download link
=begin
    <div class="select-wrapper">
      <select class="select-default" id="select-resource0">
        <option value="https://cdn.loc.gov/service/pnp/cph/3g10000/3g10000/3g10300/3g10372_150px.jpg" data-file-download="JPEG">JPEG&nbsp;(6.5 KB)
        </option>
        <option value="https://cdn.loc.gov/service/pnp/cph/3g10000/3g10000/3g10300/3g10372t.gif" data-file-download="GIF">GIF&nbsp;(16.9 KB)
        </option>
        <option value="https://cdn.loc.gov/service/pnp/cph/3g10000/3g10000/3g10300/3g10372r.jpg" data-file-download="JPEG">JPEG&nbsp;(84.2 KB)
        </option>
        <option value="https://cdn.loc.gov/service/pnp/cph/3g10000/3g10000/3g10300/3g10372v.jpg" data-file-download="JPEG">JPEG&nbsp;(184.2 KB)
        </option>
        <option value="https://cdn.loc.gov/master/pnp/cph/3g10000/3g10000/3g10300/3g10372u.tif" data-file-download="TIFF">TIFF&nbsp;(47.5 MB)
        </option>
      </select>
    </div>
=end
      @counter += 1

      counter_str = @counter.to_s.rjust(5, '0')
      next if !Dir.glob("#{@output_path}/#{counter_str}*.*")

      puts '*' * 40
      puts "#{@counter} page: #{@counter/@page_size}"

      title = parsed_detail_page.css('.item-title').css('cite').text
      puts title
      options = parsed_detail_page.css('.select-default').css('option')
      opts = options.select do |o|
        o.text.include?(@img_type)
      end
      next if opts.empty?
      img_url = (@img_size == 'large' ? opts.last : opts.first).attribute('value').to_s
      puts img_url
      fname = "#{@output_path}/#{to_filename(title, img_url, @counter)}"
      if @always_replace_images
        save_image(img_url, fname)
      else
        unless File.exists?(fname)
          save_image(img_url, fname)
        end
      end
      puts '*' * 40
      puts ''
    end

    download_page_images(next_page_url) unless blank?(next_page_url)
  end

  def blank?(s)
    s.to_s.strip == ''
  end
end
ScrapeLOC.new.run
