module TAC
  class Simulator
    class Simulation
      attr_reader :robots, :show_paths, :simulation_time

      def initialize(source_code:, field_container:)
        @source_code = source_code
        @field_container = field_container

        @robots = []
        @field = Field.new(simulation: self, season: :freight_frenzy, container: @field_container)
        @show_paths = false

        @last_milliseconds = Gosu.milliseconds
        @simulation_step = 1.0 / 60.0
        @accumulator = 0.0
        @simulation_time = 0.0
      end

      def start
        self.instance_eval(@source_code)
        @robots.each { |robot| robot.queue.first.start unless robot.queue.empty? }
      end

      def draw
        @field.draw
      end

      def update
        @accumulator += (Gosu.milliseconds - @last_milliseconds) / 1000.0

        while(@accumulator > @simulation_step)
          @field.update
          @robots.each { |robot| robot.update(@simulation_step) }

          @accumulator -= @simulation_step
          @simulation_time += @simulation_step
        end

        @last_milliseconds = Gosu.milliseconds
      end

      def create_robot(alliance:, width:, depth:)
        robot = Simulator::Robot.new(alliance: alliance, width: width, depth: depth)
        @robots << robot

        return robot
      end

      def set_show_paths(boolean)
        @show_paths = boolean
      end
    end
  end
end