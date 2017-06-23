# Libray of Congress Scraper

The LOC recently release [2,500+ Japanese Woodblock Prints](https://www.loc.gov/collections/japanese-fine-prints-pre-1915/). I thought it'd be fun to use as a screen-saver so I wrote this script. 

This is pretty straight forward to use

```
git clone https://github.com/wiseleyb/library-of-congress-scraper
cd library-of-congress-scraper
bundle
chmod 755 loc-scraper.rb
./loc-scraper.rb
```

Take a look at at `initialize` in `loc-scraper.rb` for config options. This isn't some master code achievement - it's a quick hack but, it does caching, etc. 

I've only tested this on [https://www.loc.gov/collections/japanese-fine-prints-pre-1915/](https://www.loc.gov/collections/japanese-fine-prints-pre-1915/) but, in theory it should work on other content, on filters on that page, etc.

Ping me with questions or PR requests.

Here's the JPG-Large set if you want to save time downloading... 400MB, 2600+ photos. [https://www.idrive.com/idrive/sh/sh?k=i6a3s8p0h5](https://www.idrive.com/idrive/sh/sh?k=i6a3s8p0h5)