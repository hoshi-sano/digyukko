module DigYukko
  class TitleScene < BaseScene
    manager_module TitleManager

    def initialize(*args)
      super
      BGM.play(:title)
    end

    def post_process
      super
      BGM.stop
    end
  end
end
