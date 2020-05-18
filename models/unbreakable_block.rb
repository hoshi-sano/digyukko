module DigYukko
  class UnbreakableBlock < Block
    BASE_IMAGE = load_image('unbreakable_block')
    BG_IMAGE = BASE_IMAGE.change_hls(0, -60, 0)
    COLORED_IMAGE = load_image('colored_unbreakable_block')
    HUE_INTERVAL = 20

    set_image BASE_IMAGE

    class << self
      def change_color(level)
        seed = (level / 3)
        if seed == 0
          reset_color
        else
          @image = COLORED_IMAGE.change_hls(HUE_INTERVAL * seed - 1, 0, 0)
        end
      end

      def reset_color
        @image = BASE_IMAGE
      end
    end

    def break
    end

    def force_break
    end
  end
end
