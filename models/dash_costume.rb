module DigYukko
  # ダッシュコスチューム
  class DashCostume < Costume
    IMAGE_SPLIT_X = 8
    IMAGE_SPLIT_Y = 2
    # TODO: 画像は暫定
    IMAGES = load_image_tiles('projectile_yukko', IMAGE_SPLIT_X, IMAGE_SPLIT_Y)
    CUT_IN_IMAGE = load_image('projectile_costume_cut_in')

    set_max_extra_power 300
    set_attacking_time 10

    def update_weapon
      super
      @weapon.update
      @extra_weapon.update
    end

    def item_table
      {
        ProjectileCostumeItem => :zero,
        BoundCostumeItem => :zero,
        # TODO: 上位コスチューム
      }
    end

    # ダッシュ中は重力が働かせないよう、trueを返す
    def air_brake?
      @weapon.enabled?
    end

    # ダッシュ中は重力が働かない
    def y_speed
      0
    end

    class Weapon < ::DigYukko::Costume::Weapon
      # TODO: 画像は暫定
      X_IMAGE = Image.new(Yukko::WIDTH + 10, Yukko::HEIGHT + 5, ::DXRuby::C_BLUE)

      def initialize(yukko)
        super
        @landed = false
      end

      def enable(_key_x, _key_y)
        return false unless available?
        @action = @yukko.x_dir == Yukko::DIR[:left] ? :move_left : :move_right
        @x_yukko_diff = (@yukko.width - self.image.width) / 2
        self.visible = true
        self.collision_enable = true
        @landed = false
        set_position
        true
      end

      def available?
        @landed && !enabled?
      end

      def update
        @landed = @landed || @yukko.landing?
        return unless enabled?
        @yukko.send(@action, true)
        set_position
      end

      def set_position
        self.x = @yukko.x + @x_yukko_diff
        self.y = @yukko.y
      end
    end

    class ExtraWeapon < DashCostume::Weapon
      def shot(obj)
        obj.force_break
      end

      def update
        @landed = @landed || @yukko.landing?
        return unless enabled?
        5.times { @yukko.send(@action, true) }
        set_position
      end
    end
  end
end
