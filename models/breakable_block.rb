module DigYukko
  class BreakableBlock < Block
    CODE = 0

    set_image load_image('breakable_block')
    set_score 10
    fragment(image)

    def break
      @map.push_fragments(
        %i[upper_left upper_right lower_left lower_right].map do |pos|
          self.class::Fragment.new(self, pos)
        end
      )
      ActionManager.combo
      ActionManager.add_score(self)
      vanish
    end
  end
end
