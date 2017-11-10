module DigYukko
  class Yukko < ::DXRuby::Sprite
    IMAGE = ::DXRuby::Image.new(32, 32, ::DXRuby::C_YELLOW)
    X_MOVE_UNIT = 5
    DIR = {
      left: -1,
      right: 1,
    }

    attr_reader :x_dir

    # 足の衝突判定用クラス
    class FootCollisoin < ::DXRuby::Sprite
      IMAGE = Image.new(IMAGE.width, 1, ::DXRuby::C_BLUE)

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

    # 通常武器スプーン
    class Spoon < ::DXRuby::Sprite
      IMAGE = Image.new(5, 30, ::DXRuby::C_BLUE)

      def initialize(yukko)
        @yukko = yukko
        super(@yukko.x, @yukko.y, IMAGE)
        disable
      end

      def enabled?
        self.visible && self.collision_enable
      end

      def enable
        if @yukko.x_dir > 0
          self.x = @yukko.x + @yukko.width
        else
          self.x = @yukko.x - 5
        end
        self.y = @yukko.y + 15
        self.visible = true
        self.collision_enable = true
      end

      def disable
        self.visible = false
        self.collision_enable = false
      end

      def shot(obj)
        obj.break
      end
    end

    def initialize(map)
      super(0, 0, IMAGE)
      @x_dir = DIR[:right]
      @map = map
      @foot_collision = FootCollisoin.new(self)
      @spoon = Spoon.new(self)
      # 縦方向の移動速度
      @y_speed = 0
      # 滞空時間(frame)
      @aerial_time = 0
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
    end

    def width
      self.image.width
    end

    def height
      self.image.height
    end

    # 足元下端の座標
    def foot_y
      self.y + height
    end

    # 足元下端の座標セット
    def foot_y=(val)
      self.y = val - height
    end

    def move_left
      @x_dir = DIR[:left]
      return if attacking?
      return if @map.has_block?(self.x, self.y, -X_MOVE_UNIT, height)
      self.x -= X_MOVE_UNIT
    end

    def move_right
      @x_dir = DIR[:right]
      return if attacking?
      return if @map.has_block?(self.x + width, self.y, X_MOVE_UNIT, height)
      self.x += X_MOVE_UNIT
    end

    # TODO: 状態によって別の武器も利用可能にする
    def current_weapon
      @spoon
    end

    # 攻撃アクションの処理
    def attack
      current_weapon.enable
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
      finish_attack_animation if @attacking_time > 5
    end

    def attacking?
      !!@attacking_time
    end

    # 攻撃アクションの衝突判定
    def check_attack(objects)
      ::DXRuby::Sprite.check(current_weapon, objects)
    end

    # ジャンプ処理
    # TODO: 整理する
    def jump
      @jump_button_down_time ||= 0
      if @jump_button_down_time.zero? && @aerial_time.zero?
        # ジャンプボタンプッシュ上方向への速度追加
        @y_speed = -5
        self.y -= height / 2
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
    #   * 攻撃中時間の更新
    def update
      unless landing?
        @aerial_time += 1
        @y_speed = @y_speed + (@aerial_time * 9.8) / 300
      end
      self.y = self.y + @y_speed
      position_compensate
      update_attacking_time
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
  end
end
