module DigYukko
  class DashCostumeItem < Item
    set_image load_image('dash_item')
    set_score 10
    set_power 0
    fragment(image)

    def effect(yukko)
      yukko.costume = DashCostume
      vanish
    end
  end
end
