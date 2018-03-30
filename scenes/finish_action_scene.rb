module DigYukko
  class FinishActionScene < ActionScene
    manager_module ActionManager

    def initialize(*args)
      args << BottomMap.new
      super(*args)
    end
  end
end
