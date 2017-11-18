module DigYukko
  class KeyConfig
    DEFAULT = {
      jump:   ::DXRuby::K_Z,
      attack: ::DXRuby::K_X,
      extra:  ::DXRuby::K_C,
    }

    KEYS = (:A..:Z).map { |char| :"K_#{char}" }
    PAD_BUTTONS = [:P_UP, :P_DOWN, :P_LEFT, :P_RIGHT, *(0..15).map { |n| :"P_BUTTON#{n}" }]
    TABLE = (KEYS + PAD_BUTTONS).map { |sym|
      [sym, ::DXRuby.const_get(sym)]
    }.to_h
    REVERSE_TABLE = TABLE.invert

    attr_reader :jump, :attack, :extra

    class InvalidConfigError < ::StandardError; end

    class << self
      def load_user_settings
        DigYukko.log(:debug, 'try load user setting', self)
        begin
          config = Config.load_user_settings[:key_config].map do |label, value|
            value = TABLE[value.to_sym] unless value.is_a?(Integer)
            [label.to_sym, value]
          end.to_h
        rescue => e
          DigYukko.log(:error, e.message)
          config = DEFAULT
        end
        DigYukko.log(:info, "use key config: #{config}", self)
        new(config)
      end
    end

    def initialize(hash)
      assign(hash)
    end

    def assign(hash)
      %i[jump attack extra].each do |key|
        instance_variable_set("@#{key}", hash[key])
      end
    end

    def usable?(val)
      TABLE.values.include?(val)
    end

    def jump=(val)
      return unless usable?(val)
      @attack = nil if @attack == val
      @extra = nil if @extra == val
      @jump = val
    end

    def attack=(val)
      return unless usable?(val)
      @jump = nil if @jump == val
      @extra = nil if @extra == val
      @attack = val
    end

    def extra=(val)
      return unless usable?(val)
      @jump = nil if @jump == val
      @attack = nil if @attack == val
      @extra = val
    end

    def to_h
      {
        jump:   @jump,
        attack: @attack,
        extra:  @extra,
      }
    end

    def to_human_readable_hash
      {
        jump:   human_readable(@jump).to_s,
        attack: human_readable(@attack).to_s,
        extra:  human_readable(@extra).to_s,
      }
    end

    def human_readable(val)
      val = instance_variable_get("@#{val}") if val.is_a?(Symbol)
      REVERSE_TABLE[val]
    end

    def valid?(raise_error = true)
      valid = to_h.values.none? { |v| v.nil? || !TABLE.values.include?(v) }
      return true if valid
      return false unless raise_error
      raise InvalidConfigError, "invalid key config - #{to_human_readable_hash}"
    end

    def dump
      DigYukko.log(:info, "dump key config: #{to_human_readable_hash}", self.class)
      Config.dump_user_settings({ key_config: to_human_readable_hash })
    end
  end
end
