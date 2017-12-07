module DigYukko
  class LifeRecoverItem < Item
    CODE = 3

    # TODO: 専用の画像を用意する
    set_image ::DXRuby::Image.new(32, 32).tap { |img|
                img.circle_fill(16, 16, 16, ::DXRuby::C_GREEN)
              }
    set_score 10
    set_power 25
    fragment(image)

    def effect(yukko)
      yukko.recover(power)
      vanish
    end
  end
end
