module DigYukko
  class ProjectileCostumeItem < Item
    CODE = 7

    # TODO: 専用の画像を用意する
    set_image ::DXRuby::Image.new(32, 32).tap { |img|
      img.circle_fill(16, 16, 16, ::DXRuby::C_YELLOW)
    }
    set_score 10
    set_power 0
    fragment(image)

    def effect(yukko)
      yukko.costume = ProjectileCostume
      vanish
    end
  end
end
