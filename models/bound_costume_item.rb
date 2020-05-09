module DigYukko
  class BoundCostumeItem < Item
    set_image load_image('bound_item')
    set_score 10
    set_power 0
    fragment(image)

    def effect(yukko)
      yukko.costume = BoundCostume
      vanish
    end
  end
end
