module DigYukko
  class TitleScene < BaseScene
    manager_module TitleManager

    def initialize(*args)
      super
    end

    def pre_process
      BGM.play(:title)
    end

    def post_process
      super
      BGM.stop
    end
  end
end
