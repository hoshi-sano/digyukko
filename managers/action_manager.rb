module DigYukko
  module ActionManager
    class << self
      def init(yukko = nil, combo_counter = nil, depth_counter = nil, extra_counter = nil, score = 0, map = nil)
        LevelManager.init if yukko.nil?
        @yukko = yukko || Yukko.new
        @map = map || Map.new(@yukko, score)
        @combo_counter = combo_counter || ComboCounter.new
        @depth_counter = depth_counter || DepthCounter.new
        @extra_power_counter = extra_counter || ExtraPowerCounter.new(@yukko)
        @score_counter = ScoreCounter.new(@combo_counter, @depth_counter, score)
        @life_counter = LifeCounter.new(@yukko)
        @level_counter = Config['debug'] ? LevelCounter.new : LevelCounterDummy.new
        @cut_in_effects = []
      end

      def combo
        @combo_counter.count_up
        @extra_power_counter.count_up(@combo_counter.count)
      end

      def failed
        @depth_counter.stop!
        push_cut_in_effect(FailedEffect.new(@yukko, @map))
      end

      def add_depth(val)
        @depth_counter.count_up(val)
      end

      def add_score(obj)
        @score_counter.add(obj)
      end

      def change_costume
        @extra_power_counter.reset_max
      end

      def push_cut_in_effect(effect)
        @cut_in_effects << effect
      end

      def update_components
        if @cut_in_effects.any?
          @cut_in_effects.each(&:update)
          @cut_in_effects.delete_if(&:finished?)
          return
        end
        @yukko.update
        @yukko.check_attack(@map.field_objects)
        @yukko.check_extra_skill(@map.field_objects)
        @map.update
        @combo_counter.update
        @score_counter.update
        @life_counter.update
        @extra_power_counter.update
        @combo_counter.stop if @yukko.over_last_row?
        go_to_next_stage if @yukko.at_bottom?
      end

      def draw_components
        @yukko.draw
        @map.draw
        @combo_counter.draw
        @depth_counter.draw
        @score_counter.draw
        @life_counter.draw
        @extra_power_counter.draw
        @level_counter.draw
        @cut_in_effects.each(&:draw)
      end

      def check_keys
        return if @cut_in_effects.any?
        @yukko.move(KEY.x)
        @yukko.jump if KEY.down?(KEY.jump)
        if KEY.push?(KEY.attack)
          @yukko.attack(KEY.x, KEY.y)
        elsif KEY.push?(KEY.extra)
          @yukko.extra_skill(KEY.x, KEY.y, @extra_power_counter)
        end
        @yukko.nojump unless KEY.down?(KEY.jump)
      end

      def next_scene
        if clear?
          FinishActionScene.new(@yukko, @combo_counter, @depth_counter, @extra_power_counter, @score_counter.score)
        else
          ActionScene.new(@yukko, @combo_counter, @depth_counter, @extra_power_counter, @score_counter.score)
        end
      end

      def progress_score
        (@depth_counter.count / 3).to_i + @combo_counter.score
      end

      def clear?
        current_level = LevelManager.calc_level(progress_score)
        DigYukko.log(:debug, "check clear condition: #{Config['clear_condition']} <= #{current_level}")
        Config['clear_condition'] <= current_level
      end

      def result
        {
          yukko: @yukko,
          combo: @combo_counter.max_combo.to_i,
          depth: @depth_counter.count.to_i,
          score: @score_counter.score.to_i,
        }
      end

      def go_to_next_stage
        ApplicationManager.change_scene(next_scene)
      end
    end
  end
end
