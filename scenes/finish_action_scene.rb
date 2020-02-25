module DigYukko
  class FinishActionScene < ActionScene
    manager_module ActionManager

    def initialize(*args)
      yukko = args[0]
      score = args[-1]
      args << BottomMap.new(yukko, score)
      super(*args)
    end
  end
end
