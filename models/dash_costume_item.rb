module DigYukko
  class DashCostumeItem < Item
    set_image load_image('projectile_item') # TODO: 暫定
    set_score 10
    set_power 0
    fragment(image)

    def effect(yukko)
      yukko.costume = DashCostume
      vanish
    end
  end
end
