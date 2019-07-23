module DigYukko
  class BombEffect < ::DXRuby::Sprite
    FRAME_NUM = 12
    IMAGES = (0..FRAME_NUM).to_a.map do |n|
      ::DXRuby::Image.new(Bomb.image.width, Bomb.image.height).tap do |img|
        img.circle_fill(img.width / 2, img.height / 2, img.width / 2, ::DXRuby::C_YELLOW)
        img.circle_fill(img.width / 3, img.height / 1.5, n, [0, 0, 0, 0])
      end
    end

    # 爆発範囲アラート用画像
    RANGE_ALERT_IMAGE = ::DXRuby::Image.new(Bomb.image.width, Bomb.image.height, ::DXRuby::C_RED)

    # 爆発範囲アラートはアルファ値で爆発までのリミットを表現する
    # アルファ値がLIMITに達したら爆発処理に遷移する
    ALPHA_LIMIT = 100

    # 1フレームあたりにアルファ値に加算する数
    ALPHA_UPDATE_UNIT = 3

    STATUS = {
      alert: 1,
      wait_ignition: 2,
      ignition: 3,
      explosion: 4,
    }

    # 爆弾からの距離(単位: セル)
    attr_reader :dx, :dy

    def initialize(bomb, dx, dy, distance = 0)
      @bomb = bomb
      @power = bomb.power
      @dx = dx
      @dy = dy
      @state = STATUS[:alert]
      @distance = distance
      @delay = @distance.zero? ? 0 : (FRAME_NUM / 3)
      @count = -1
      super(@bomb.x + @dx * @bomb.width, @bomb.y + @dy * @bomb.height, RANGE_ALERT_IMAGE)
      self.alpha = 0
      self.z = 300
      self.target = @bomb.target
      self.collision = [1, 1, @bomb.width - 1, @bomb.height - 1]
      self.collision_enable = false
      check_overlap_object
    end

    def update
      case @state
      when STATUS[:alert]
        self.alpha += ALPHA_UPDATE_UNIT
      when STATUS[:ignition]
        @delay -= 1
        return if @delay > 0
        explosion!
      when STATUS[:explosion]
        @count += 1
        self.image = IMAGES[@count]
        self.vanish if finished?
      else
        # do nothing
      end
    end

    def draw
      return if overlap?
      super
    end

    def wait_ignition!
      @state = STATUS[:wait_ignition]
    end

    # 爆発の前段階の状態にする
    # これが呼ばれた場合、@delayのフレーム数だけ待ったのちexplosion!が呼ばれる
    def ignition!
      @state = STATUS[:ignition]
      check_overlap_object
    end

    # 爆発を起こし当たり判定が生じる
    # 他のオブジェクトと重なりがない場合は隣接する爆破エフェクトに対して
    # ignition!を呼ぶ
    def explosion!
      check_overlap_object
      @state = STATUS[:explosion]
      self.alpha = 255
      self.collision_enable = true
      next_action = overlap? ? :recursive_vanish : :ignition!
      @next_effects.each(&next_action)
    end

    def limit?
      @state == STATUS[:alert] && self.alpha >= ALPHA_LIMIT
    end

    def overlap?
      @overlap_object && !@overlap_object.vanished?
    end

    def finished?
      @count > FRAME_NUM
    end

    def generate_next_effects
      @next_effects = []
      next_y_range.each do |effect_y|
        next_x_range.each do |effect_x|
          next if effect_x.zero? && effect_y.zero?
          effect = @bomb.set_bomb_effect(@dx + effect_x, @dy + effect_y, @distance + 1)
          next if effect.nil?
          @next_effects << effect
        end
      end
      @next_effects
    end

    def next_y_range
      @dy.zero? ? [0, -1, 1] : [0, (@dy / @dy.abs)]
    end

    def next_x_range
      @dx.zero? ? [0, -1, 1] : [0, (@dx / @dx.abs)].sort
    end

    def recursive_vanish
      @next_effects.each(&:recursive_vanish)
      self.vanish
    end

    def check_overlap_object
      self.collision_enable = true
      bomb_collision_enabled = @bomb.collision_enable
      @bomb.collision_enable = false
      ::DXRuby::Sprite.check(self, @bomb.map.field_objects, :set_overlap_object, nil)
      @bomb.collision_enable = bomb_collision_enabled
      self.collision_enable = false
    end

    def set_overlap_object(obj)
      @overlap_object = obj
    end

    def shot(obj)
      if obj.is_a?(Yukko)
        obj.damage(@power)
      else
        obj.break
      end
    end
  end
end
