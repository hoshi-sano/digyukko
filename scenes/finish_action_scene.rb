module DigYukko
  class FinishActionScene < ActionScene
    manager_module ActionManager

    def initialize(*args)
      args << BottomMap.new(args[0])
      super(*args)
    end
  end
end
