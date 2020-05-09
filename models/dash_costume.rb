module DigYukko
  # ダッシュコスチューム
  class DashCostume < Costume
    IMAGE_SPLIT_X = 8
    IMAGE_SPLIT_Y = 2
    IMAGES = load_image_tiles('dash_yukko', IMAGE_SPLIT_X, IMAGE_SPLIT_Y)
    CUT_IN_IMAGE = load_image('dash_costume_cut_in')

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
      X_IMAGE = Image.new(Yukko::WIDTH + 10, Yukko::HEIGHT + 5, [0, 0, 0, 0])
      INTERVAL = 3

      def initialize(yukko)
        @afterimages = []
        super
        @landed = false
        @count = 0
      end

      def draw
        super
        @afterimages.each(&:draw)
      end

      def enable(_key_x, _key_y)
        return false unless available?
        @action = @yukko.x_dir == Yukko::DIR[:left] ? :move_left : :move_right
        @x_yukko_diff = (@yukko.width - self.image.width) / 2
        self.visible = true
        self.collision_enable = true
        @landed = false
        set_position
        @afterimages << generate_afterimage
        true
      end

      def disable
        super
        @afterimages.reject! { |_| true }
      end

      def available?
        @landed && !enabled?
      end

      def update
        @landed = @landed || @yukko.landing?
        return unless enabled?
        @yukko.send(@action, true)
        set_position
        @count += 1
        @afterimages << generate_afterimage if (@count % INTERVAL) == 0
        @afterimages.each(&:update)
      end

      def set_position
        self.x = @yukko.x + @x_yukko_diff
        self.y = @yukko.y
      end

      def generate_afterimage
        AfterImage.new(@yukko).tap do |ai|
          ai.target = @yukko.target
        end
      end

      # ダッシュ時の残像を表現するクラス
      # あたり判定などは持たず、表示用のみ
      class AfterImage < ::DXRuby::Sprite
        HUE = 180
        IMAGES = {
          left: [
            DashCostume::IMAGES[0].change_hls(HUE, -20, 0),
            DashCostume::IMAGES[0].change_hls(HUE, -30, 0),
            DashCostume::IMAGES[0].change_hls(HUE, -40, 0),
            DashCostume::IMAGES[0].change_hls(HUE, -50, 0)
          ],
          right: [
            DashCostume::IMAGES[DashCostume::IMAGE_SPLIT_X].change_hls(HUE, -20, 0),
            DashCostume::IMAGES[DashCostume::IMAGE_SPLIT_X].change_hls(HUE, -30, 0),
            DashCostume::IMAGES[DashCostume::IMAGE_SPLIT_X].change_hls(HUE, -40, 0),
            DashCostume::IMAGES[DashCostume::IMAGE_SPLIT_X].change_hls(HUE, -50, 0)
          ]
        }
        Z_INDEX = -100
        INTERVAL = 3

        def initialize(yukko)
          @dir = Yukko::DIR.invert[yukko.x_dir]
          @count = 0
          super(yukko.x + 0, yukko.y + 0, IMAGES[@dir][@count])
        end

        def update
          @count += 1
          return unless current_image
          self.image = current_image
          super
        end

        def current_image
          IMAGES[@dir][@count / INTERVAL]
        end

        def set_z_index
          self.z = Z_INDEX + @count
        end
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
