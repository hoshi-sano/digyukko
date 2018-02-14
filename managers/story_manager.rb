module DigYukko
  module StoryManager
    include HelperMethods

    STORY_DIR = File.join(DigYukko.app_root, 'data', 'stories')

    class << self
      def init(story_type)
        @slides = load_story(story_type)
        @slide_idx = 0
        @skip_message = SkipMessage.new
      end

      def update_components
        @slides[@slide_idx].update
        if @slides[@slide_idx].finished?
          if @slides[@slide_idx + 1]
            @slide_idx += 1
          else
            unless ApplicationManager.scene_changing?
              ApplicationManager.change_scene(TitleScene.new)
            end
          end
        end
        @skip_message.update
      end

      def draw_components
        @slides[@slide_idx].draw
        @skip_message.draw if @slides[@slide_idx].skip?
      end

      def check_keys
        return if ApplicationManager.scene_changing?
        if KEY.pushed_keys.any? && @slides[@slide_idx].skip?
          ApplicationManager.change_scene(TitleScene.new)
        end
      end

      def load_story(story_type)
        load_yaml(STORY_DIR, story_type).map do |slide_info|
          Slide.new(slide_info)
        end
      end
    end

    class Slide
      include HelperMethods

      ALPHA_MIN = 0
      ALPHA_MAX = 255

      def initialize(info)
        if info[:image_file_name]
          @image = load_image(info[:image_file_name])
        else
          @image = ::DXRuby::Image.new(1, 1)
        end
        @messages = Array(info[:messages])
        @message_idx = 0
        @skip = info[:skip]
        @fade_in = info[:fade_in]
        @fade_out = info[:fade_out]
        @state = @fade_in ? :fade_in : :appeared
        @alpha = @fade_in ? ALPHA_MIN : ALPHA_MAX
        @alpha_diff = info[:alpha_diff] || 3
        @r_target = ::DXRuby::RenderTarget
                    .new(Config['window.width'],
                         Config['window.height'])
        @image_x = info[:image_x] || @r_target.width / 2 - @image.width / 2
        @image_y = info[:image_y] || @r_target.height / 2 - @image.height / 2
        @message_x = info[:message_x] || @image_x
        @message_y = info[:message_y] || @image_y + @image.height + 20
        @message_speed = info[:message_speed] || 5
        @keep_duration = info[:keep_duration] || @message_speed * 30
        @display_message = ''
        @display_message_counter = 0
        @keep_counter = 0
      end

      def skip?
        @skip
      end

      def hidden?
        @alpha <= ALPHA_MIN
      end

      def showed?
        @alpha >= ALPHA_MAX
      end

      def finished?
        @state == :finished
      end

      def current_message
        @messages[@message_idx]
      end

      def update
        case @state
        when :fade_in
          @alpha += @alpha_diff
          if showed?
            @alpha = ALPHA_MAX
            @state = :display_message
          end
        when :fade_out
          @alpha -= @alpha_diff
          if hidden?
            @alpha = ALPHA_MIN
            @state = :finished
          end
        when :appeared
          @state = current_message ? :display_message : :keep
        when :display_message
          if !current_message || !current_message[@display_message.length]
            @state = :keep
            @keep_counter = 0
            return
          end
          if (@display_message_counter % @message_speed).zero?
            @display_message.concat(current_message[@display_message.length])
          end
          @display_message_counter += 1
        when :keep
          @keep_counter += 1
          if (@keep_counter % @keep_duration).zero?
            @display_message = ''
            @display_message_counter = 0
            @message_idx += 1
            if current_message
              @state = :display_message
            else
              @message_idx = 0
              @state = @fade_out ? :fade_out : :finished
            end
          end
        end
      end

      def draw
        @r_target.draw(@image_x, @image_y, @image)
        @r_target.draw_font(@message_x, @message_y, @display_message, FONT[:regular])
        ::DXRuby::Window.draw_ex(0, 0, @r_target, alpha: @alpha)
      end
    end

    class SkipMessage
      MESSAGE = 'PUSH ANY BUTTON'
      TOGGLE_INTERVAL = 45

      def initialize
        @show = true
        @counter = 0
        @font = FONT[:small]
        @x = (Config['window.width'] / 2) - (@font.get_width(MESSAGE) / 2)
      end

      def update
        @counter += 1
        if (@counter % TOGGLE_INTERVAL).zero?
          @show = !@show
          @counter = 0
        end
      end

      def draw
        ::DXRuby::Window.draw_font(@x, 0, MESSAGE, @font) if @show
      end
    end
  end
end