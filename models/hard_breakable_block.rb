module DigYukko
  class HardBreakableBlock < BreakableBlock
    set_image load_image('hard_breakable_block')
    set_score 100
    fragment(BreakableBlock.image)

    def initialize(*args)
      super
      @cracked = false
    end

    def break
      if @cracked
        super
      else
        SE.play(:break)
        self.image = BreakableBlock.image
        @cracked = true
        temporary_unbreakable
      end
    end
  end
end
