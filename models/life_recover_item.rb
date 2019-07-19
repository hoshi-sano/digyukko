module DigYukko
  class LifeRecoverItem < Item
    def effect(yukko)
      SE.play(:got_item)
      yukko.recover(power)
      vanish
    end
  end

  class LowRecoverItem < LifeRecoverItem
    set_image load_image('recover_item')
    set_score 10
    set_power 25
    fragment(image)
  end

  class FullRecoverItem < LifeRecoverItem
    set_image load_image('full_recover_item')
    set_score 100
    set_power 100
    fragment(image)
  end
end
