module Helpers

  # from https://stackoverflow.com/posts/10823131/revisions
  def sanitize_filename(filename)
    # Split the name when finding a period which is preceded by some
    # character, and is followed by some character other than a period,
    # if there is no following period that is followed by something
    # other than a period (yeah, confusing, I know)
    fn = filename.split /(?<=.)\.(?=[^.])(?!.*\.[^.])/m

    # We now have one or two parts (depending on whether we could find
    # a suitable period). For each of these parts, replace any unwanted
    # sequence of characters with an underscore
    fn.map! { |s| s.gsub /[^a-z0-9\-]+/i, '_' }

    # Finally, join the parts with a period and return the result
    return fn.join '.'
  end

  def url_to_filename(url)
    "#{sanitize_filename(url)}.html"
  end

  def to_filename(title, url, count)
    format = url.split('.').last
    fname = sanitize_filename(title)
    res = "#{count.to_s.rjust(5, '0')}_#{fname}.#{format}"
    res.gsub('__','_').gsub('_.', '.')
  end

  def get_url(url, cache, cache_dir)
    fname = url_to_filename(url)
    if cache and File.exist?(fname)
      html = File.read(fname)
    else
      html = HTTParty.get(url, { timeout: 15 })
      if cache
        File.open("#{cache_dir}/#{fname}", 'w') { |f| f.write(html) }
      end
    end
    Nokogiri::HTML(html)
  end

  def save_image(url, fname)
    File.open(fname, 'wb') do |f|
      f.write HTTParty.get(url).body
    end
  end
end
include Helpers
