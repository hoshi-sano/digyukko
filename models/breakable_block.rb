module DigYukko
  class BreakableBlock < Block
    set_image load_image('breakable_block')

    def break
      @map.push_fragments(
        %i[upper_left upper_right lower_left lower_right].map do |pos|
          Fragment.new(self, pos)
        end
      )
      vanish
    end
  end
end
