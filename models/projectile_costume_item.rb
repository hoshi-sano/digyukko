module DigYukko
  class ProjectileCostumeItem < Item
    set_image load_image('projectile_item')
    set_score 10
    set_power 0
    fragment(image)

    def effect(yukko)
      yukko.costume = ProjectileCostume
      vanish
    end
  end
end
