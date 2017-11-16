module DigYukko
  module FontManager
    DEFAULT = {
      regular: ::DXRuby::Font.new(22, 'ＭＳ Ｐゴシック'),
    }

    class << self
      def load
        loaded = (Config['font'] || {}).map { |key, attr|
          if path = attr[:path]
            DigYukko.log(:debug, "try install: #{path}")
            ::DXRuby::Font.install(path)
            DigYukko.log(:debug, "installed: #{path}")
          end
          name = attr[:name] || File.basename(path, File.extname(path))
          DigYukko.log(:debug,
                       "register font, key: #{key}, size: #{attr[:size]}, name: #{name}")
          [key, ::DXRuby::Font.new(attr[:size], name)]
        }.to_h
        @list = DEFAULT.merge(loaded)
      end

      def [](key)
        @list[key]
      end
    end
  end

  FONT = FontManager # alias
end
