module DigYukko
  class Cursor < ::DXRuby::Sprite
    def initialize(choices, color = ::DXRuby::C_WHITE)
      @choices = choices
      @position = 0
      image = ::DXRuby::Image.new(20, 20).tap do |img|
        img.triangle_fill(0,         0,
                          0,         img.height,
                          img.width, img.height / 2, color)
      end
      super(0, 0, image)
      move(0)
    end

    def move(dy)
      @position = (@position + dy) % @choices.size
      self.x = @choices[@position][:x]
      self.y = @choices[@position][:y]
    end

    def exec
      args = {
        scene:   ApplicationManager.current_scene,
        manager: ApplicationManager.current_scene.manager,
      }
      @choices[@position][:process].call(args)
    end
  end
end
