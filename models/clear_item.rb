module DigYukko
  class ClearItem < Item
    # TODO: 専用の画像を用意する
    set_image ::DXRuby::Image.new(64, 64).tap { |img|
      img.circle_fill(32, 32, 32, ::DXRuby::C_GREEN)
    }
    # TODO: 適切な値を検討する
    set_score 100000
    set_power 0

    def effect(yukko)
      ActionManager.add_score(self)
      ActionManager.push_cut_in_effect(ClearEffect.new)
      self.collision_enable = false
    end

    def break
    end
  end
end
