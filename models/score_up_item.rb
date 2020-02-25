module DigYukko
  class ScoreUpItem < Item
    def initialize(map, x, y)
      super
      @breaked = false
    end

    def effect(yukko)
      SE.play(:got_item)
      ActionManager.add_score(self)
      vanish
    end

    def break
      @breaked = true
      super
    end

    def score
      @breaked ? (super / 10) : super
    end
  end

  class SmallScoreUpItem < ScoreUpItem
    set_image load_image('heart_s')
    set_score 300
    fragment(image)
  end

  class MiddleScoreUpItem < ScoreUpItem
    set_image load_image('heart_m')
    set_score 2000
    fragment(image)
  end

  class LargeScoreUpItem < ScoreUpItem
    set_image load_image('heart_l')
    set_score 10000
    fragment(image)
  end
end
