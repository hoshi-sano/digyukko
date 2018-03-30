module DigYukko
  class ClearItem < Item
    # TODO: 専用の画像を用意する
    set_image ::DXRuby::Image.new(64, 64).tap { |img|
      img.circle_fill(32, 32, 32, ::DXRuby::C_GREEN)
    }
    set_score 100000
    set_power 0

    def effect(yukko)
      # TODO: clear effect
      puts 'GAME CLEAR !'
    end
  end
end
