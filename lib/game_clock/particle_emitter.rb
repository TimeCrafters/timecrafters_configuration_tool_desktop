module TAC
  class PracticeGameClock
    class ParticleEmitter
      def initialize(max_particles: 50, time_to_live: 30_000, interval: 1_500, z: -2)
        @max_particles = max_particles
        @time_to_live = time_to_live
        @interval = interval
        @z = -2

        @particles = []
        @image_options = Dir.glob("#{ROOT_PATH}/media/particles/*.*")
        @last_spawned = 0
        @clock_active = false
      end

      def draw
        @particles.each(&:draw)
      end

      def update
        @particles.each { |part| part.update($window.dt) }
        @particles.delete_if { |part| part.die? }

        spawn_particles
      end

      def spawn_particles
        # !clock_active? &&
        if @particles.count < @max_particles && Gosu.milliseconds - @last_spawned >= @interval
          screen_midpoint = CyberarmEngine::Vector.new($window.width / 2, $window.height / 2)
          scale = rand(0.25..1.0)
          image_name = @image_options.sample

          return unless image_name

          image = $window.current_state.get_image(image_name)
          position = CyberarmEngine::Vector.new(0, 0)

          r = rand
          if r < 0.25 # LEFT
            position.x = -image.width * scale
            position.y = rand(0..($window.height - image.height * scale))
          elsif r < 0.5 # RIGHT
            position.x = $window.width + (image.width * scale)
            position.y = rand(0..($window.height - image.height * scale))
          elsif r < 0.75 # TOP
            position.x = rand(0..($window.width - image.width * scale))
            position.y = -image.height * scale
          else #BOTTOM
            position.x = rand(0..($window.width - image.width * scale))
            position.y = $window.height + image.height * scale
          end

          position.x ||= 0
          position.y ||= 0

          velocity = (screen_midpoint - position)

          @particles << Particle.new(
            image: image,
            position: position,
            velocity: velocity,
            time_to_live: @time_to_live,
            speed: rand(24..128),
            scale: scale,
            clock_active: @clock_active,
            z: @z
          )

          @last_spawned = Gosu.milliseconds
        end
      end

      def clock_active!
        @clock_active = true
        @particles.each(&:clock_active!)
      end

      def clock_inactive!
        @clock_active = false
        @particles.each(&:clock_inactive!)
      end

      def clock_active?
        @clock_active
      end

      class Particle
        def initialize(image:, position:, velocity:, time_to_live:, speed:, z:, scale: 1.0, clock_active: false)
          @image = image
          @position = position
          @velocity = velocity.normalized
          @time_to_live = time_to_live
          @speed = speed
          @z = z
          @scale = scale

          @born_at = Gosu.milliseconds
          @born_time_to_live = time_to_live
          @color = Gosu::Color.new(0xff_ffffff)
          @clock_active = clock_active
        end

        def draw
          @image.draw(@position.x, @position.y, @z, @scale, @scale, @color)
        end

        def update(dt)
          @position += @velocity * @speed * dt

          @color.alpha = (255.0 * ratio).to_i.clamp(0, 255)
        end

        def ratio
          r = 1.0 - ((Gosu.milliseconds - @born_at) / @time_to_live.to_f)
          @clock_active ? r.clamp(0.0, 0.5) : r
        end

        def die?
          ratio <= 0
        end

        def clock_active!
          @clock_active = true
          # @time_to_live = (Gosu.milliseconds - @born_at) + 1_000
        end

        def clock_inactive!
          @clock_active = false
          # @time_to_live = @born_time_to_live unless Gosu.milliseconds - @born_at < @time_to_live
        end
      end
    end
  end
end
