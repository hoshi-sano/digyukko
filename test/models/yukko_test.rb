require 'test-unit'
require_relative '../setup'

class YukkoTest < Test::Unit::TestCase
  test 'TEST for TEST' do
    yukko = ::DigYukko::Yukko.new
    assert yukko
  end
end
