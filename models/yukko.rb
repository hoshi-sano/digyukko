module DigYukko
  class Yukko < ::DXRuby::Sprite
    include HelperMethods

    WIDTH = DefaultCostume::IMAGES.first.width
    HEIGHT = DefaultCostume::IMAGES.first.height
    ANIMATION_SPEED = 0.25
    X_MOVE_UNIT = 5
    TEMPORARY_INVINCIBLE_COUNT_MAX = 120
    DIR = {
      left: -1,
      right: 1,
    }

    attr_reader :x_dir, :max_life, :life, :animation_frame, :extra_power

    # 足の衝突判定用クラス
    class FootCollision < ::DXRuby::Sprite
      include HelperMethods

      IMAGE = Image.new(Yukko::WIDTH, 1, debug_color)

      def initialize(yukko)
        @yukko = yukko
        @land_object = nil
        super(@yukko.x, @yukko.foot_y, IMAGE)
      end

      def shot(obj)
        @land_object = obj
      end

      def yukko_y_compensate
        @yukko.foot_y = @land_object.y if @land_object
        @land_object = nil
      end
    end

    class PowerChargedEffect < ::DXRuby::Sprite
      FRAME_NUM = 8
      WIDTH = Yukko::WIDTH * 3
      HEIGHT = Yukko::HEIGHT * 3
      IMAGES = (0..FRAME_NUM).to_a.map do |n|
        ::DXRuby::Image.new(WIDTH, HEIGHT).tap do |img|
          img.circle_fill(img.width / 2, img.height / 2, img.width / 2, ::DXRuby::C_WHITE)
          img.circle_fill(img.width / 2, img.height / 2, (img.width / 2 / FRAME_NUM) * n, [0, 0, 0, 0])
        end
      end

      def initialize(yukko)
        @yukko = yukko
        @count = 0
        dx = (WIDTH - @yukko.width) / 2
        dy = (HEIGHT - @yukko.height) / 2
        super(@yukko.x - dx, @yukko.y - dy, IMAGES.first)
        self.z = 255
      end

      def update
        @count += 1
        self.image = IMAGES[@count]
        vanish if finished?
      end

      def finished?
        @count > FRAME_NUM
      end
    end

    def initialize
      @costume = DefaultCostume.new(self)
      @max_life = 100
      @life = 100
      @extra_power = 0
      @x_dir = DIR[:right]
      @animation_frame = 0
      super(Config['window.width'] / 2, 0, @costume.current_image)
      @foot_collision = FootCollision.new(self)
      # 縦方向の移動速度
      @y_speed = 0
      # 滞空時間(frame)
      @aerial_time = 0
      @temporary_invincible_count = 0
      @realtime_effects = []
      self.z = 1
    end

    def map=(map)
      @map = map
      @map.yukko = self
      self.y = 0
      [self, @foot_collision, current_weapon, current_extra_weapon].each { |s| s.target = @map.field }
    end

    def costume=(new_costume)
      return if @costume.class == new_costume
      ActionManager.push_cut_in_effect(CostumeChangeEffect.new(self, new_costume))
      @costume = new_costume.new(self)
      ActionManager.change_costume
    end

    def x=(val)
      super
      @foot_collision.x = val
    end

    def y=(val)
      super
      @foot_collision.y = foot_y
    end

    def draw
      super
      @foot_collision.draw
      current_weapon.draw
      current_extra_weapon.draw
      @realtime_effects.each(&:draw)
    end

    def width
      @costume.width
    end

    def height
      @costume.height
    end

    # 身体の中心のX座標
    def mid_x
      self.x + width / 2
    end

    # 身体の中心のY座標
    def mid_y
      self.y + height / 2
    end

    # 足元下端の座標
    def foot_y
      self.y + height
    end

    # 足元下端の座標セット
    def foot_y=(val)
      self.y = val - height
    end

    def damage(val)
      return if invincible?
      @life -= val
      temporary_invincible!
      @map.shake!
      if failed?
        @life = 0
        ActionManager.failed
      end
    end

    def temporary_invincible!(count = TEMPORARY_INVINCIBLE_COUNT_MAX)
       @temporary_invincible_count = count
    end

    def failed?
      @life <= 0
    end

    def invincible?
      @temporary_invincible_count > 0
    end

    def update_invincible_count
      @temporary_invincible_count -= 1 if invincible?
    end

    def recover(val)
      # TODO: 回復エフェクト
      @life += val
      @life = @max_life if @life > @max_life
    end

    def move(dx)
      if dx.zero?
        @animation_frame = 0
        return
      else
        @animation_frame = (@animation_frame + ANIMATION_SPEED) % @costume.class::IMAGE_SPLIT_X
        dx > 0 ? move_right : move_left
      end
    end

    def move_left(force = false)
      @x_dir = DIR[:left]
      return if !force && (attacking? || extra_skill_using? || self.x <= 0)
      if block = @map.find_block(self.x, self.y + self.height / 4, -X_MOVE_UNIT)
        self.x = block.x + block.width
      else
        self.x -= X_MOVE_UNIT
      end
      self.x = 0 if self.x < 0
    end

    def move_right(force = false)
      @x_dir = DIR[:right]
      return if !force && (attacking? || extra_skill_using? || self.x >= x_right_edge)
      if block = @map.find_block(self.x + width, self.y, X_MOVE_UNIT)
        self.x = block.x - width
      else
        self.x += X_MOVE_UNIT
      end
      self.x = x_right_edge if (self.x > x_right_edge)
    end

    def x_right_edge
      @right_edge ||= @map.field.width - self.width
    end

    def current_weapon
      @costume.weapon
    end

    def current_extra_weapon
      @costume.extra_weapon
    end

    def current_attacking_time
      @costume.attacking_time
    end

    # 攻撃アクションの処理
    def attack(key_x, key_y)
      current_weapon.enable(key_x, key_y) &&
      start_attack_animation
    end

    def start_attack_animation
      @attacking_time = 0
    end

    def finish_attack_animation
      @attacking_time = nil
      current_weapon.disable
    end

    def update_attacking_time
      return unless @attacking_time
      @attacking_time += 1
      finish_attack_animation if @attacking_time > current_attacking_time
    end

    def attacking?
      !!@attacking_time
    end

    # 攻撃アクションの衝突判定
    def check_attack(objects)
      ::DXRuby::Sprite.check(current_weapon.check_target, objects)
    end

    # 特殊行動アクションの処理
    def extra_skill(key_x, key_y, counter)
      return unless counter.skill_available?
      if current_extra_weapon.enable(key_x, key_y)
        counter.zero!
        fire_extra_skill_effect
        start_extra_skill_animation
      end
    end

    def push_realtime_effect(effect)
      effect.target = self.target
      @realtime_effects << effect
    end

    def fire_extra_skill_effect
      SE.play(:extra)
      push_realtime_effect(FlashEffect.new(self, -@map.field_y, 150))
    end

    def fire_extra_power_charged_effect
      SE.play(:charged)
      push_realtime_effect(PowerChargedEffect.new(self))
    end

    def start_extra_skill_animation
      @extra_skill_time = 0
    end

    def finish_extra_skill_animation
      @extra_skill_time = nil
      current_extra_weapon.disable
    end

    def update_extra_skill_time
      return unless @extra_skill_time
      @extra_skill_time += 1
      finish_extra_skill_animation if @extra_skill_time > current_attacking_time
    end

    def extra_skill_using?
      !!@extra_skill_time
    end

    # 特殊行動アクションの衝突判定
    def check_extra_skill(objects)
      ::DXRuby::Sprite.check(current_extra_weapon.check_target, objects)
    end

    # ジャンプ処理
    # TODO: 整理する
    def jump
      @jump_button_down_time ||= 0
      if @jump_button_down_time.zero? && @aerial_time.zero?
        # ジャンプボタンプッシュ上方向への速度追加
        @y_speed = -5
        self.y -= height / 2
        SE.play(:jump) if @life > 0
      elsif @jump_button_down_time == 5 && @aerial_time <= 5
        # ジャンプボタン長押しによる上方向への速度の更なる追加
        @y_speed = -8
      elsif @jump_button_down_time > 5 && landing?
        # do_nothing
      end
      @jump_button_down_time += 1
    end

    def nojump
      @jump_button_down_time = nil
    end

    # 毎フレーム呼ばれる処理
    # 以下を実施する
    #   * 着地状態でない場合
    #     * 滞空時間のインクリメント
    #     * 重力によるY方向移動距離計算
    #   * Y方向移動距離の加算
    #   * めりこみ回避の位置調整
    #   * エフェクトの更新
    #   * 攻撃中時間の更新
    #   * アイテムの取得チェック
    def update
      if landing?
        update_image
      else
        update_aerial_params
      end
      self.y = self.y + @y_speed
      @costume.update_weapon
      position_compensate
      @realtime_effects.each(&:update)
      @realtime_effects.delete_if(&:finished?)
      update_attacking_time
      update_extra_skill_time
      update_invincible_count
      check_item_collision
    end

    def update_aerial_params
      @aerial_time += 1
      if air_brake?
        @y_speed = @costume.y_speed || @y_speed
      else
        # TODO: 落下速度計算は見直しの余地あり
        @y_speed = @y_speed + (@aerial_time * 9.8) / 300
        @y_speed = height if @y_speed > height
      end
      @y_speed
    end

    def air_brake?
      !failed? && @costume.air_brake?
    end

    def update_image
      self.image = @costume.current_image
    end

    # めりこみ回避の位置調整
    # 縦方向のめりこみチェックと回避のみ実施
    # 横方向はそもそもめりこまないようmove_left,move_rightで制御している
    def position_compensate
      res = ::DXRuby::Sprite.check(self, @map.blocks, :y_compensate, nil)
      @foot_collision.yukko_y_compensate
    end

    def y_compensate(block)
      # 自身より下のブロックに対する位置調整は
      # FootCollision#yukko_y_compensateで処理するためスキップ
      return if block.foot_y > foot_y
      self.y = block.y + block.height if block.y < self.y
    end

    # 着地状態か否か
    def landing?
      # 上昇中は足が地面と触れていても着地とみなさない
      return false if @y_speed < 0
      # 足の衝突判定用オブジェクトと地面が衝突していたら着地
      res = ::DXRuby::Sprite.check(@foot_collision, @map.blocks)
      # 着地状態の場合、Y方向への速度や滞空時間を0にする
      if res
        @y_speed = 0
        @aerial_time = 0
      end
      res
    end

    # ステージの最後のブロックを越えたかどうか
    def over_last_row?
      self.y > @map.last_block.foot_y
    end

    # ステージの末端(底)まで到達したかどうか
    def at_bottom?
      self.y > @map.field.height
    end

    def check_item_collision
      ::DXRuby::Sprite.check(self, @map.items)
    end

    def shot(obj)
      return unless obj.item?
      obj.effect(self)
    end

    # yukkoの状態を考慮したアイテム排出率のハッシュを返す
    # * lifeが少ないほど回復アイテムの排出率上昇
    # * 現在のコスチュームと同じコスチュームアイテムは排出しない
    # * 現在のコスチュームの上位コスチュームアイテムを排出する
    def current_item_table
      {
        LowRecoverItem => ((@max_life - @life) / 10),
        FullRecoverItem => (@life <= 30) ? 5 : 0,
      }.merge(@costume.item_table)
    end

    def max_extra_power
      @costume.max_extra_power
    end
  end
end
