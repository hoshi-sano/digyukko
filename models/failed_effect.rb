module DigYukko
  # ライフがゼロになったときのやられエフェクト
  class FailedEffect
    EFFECT_LENGTH = 60

    def initialize(yukko, map)
      @yukko = yukko
      @map = map
      BGM.stop
      @yukko.z = 999
      @yukko.nojump
      @yukko.jump
      @dir = @yukko.x_dir * -1
      @count = 0
      SE.play(:fatal)
    end

    def update
      if @yukko.at_bottom?
        @count += 1
        return
      end
      y_speed = @yukko.update_aerial_params
      @yukko.y = @yukko.y + (y_speed / 2)
      @yukko.x += 3 * @dir
      @map.update
    end

    def draw
    end

    def finished?
      if @count > EFFECT_LENGTH
        ApplicationManager.change_scene(ResultScene.new(:failed))
        true
      else
        false
      end
    end
  end
end
