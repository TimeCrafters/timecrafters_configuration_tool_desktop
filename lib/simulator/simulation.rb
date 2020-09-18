module TAC
  class Simulator
    class Simulation
      attr_reader :robots, :show_paths
      def initialize(source_code:, field_container:)
        @source_code = source_code
        @field_container = field_container

        @robots = []
        @field = Field.new(simulation: self, season: :ultimate_goal, container: @field_container)
        @show_paths = false

        @last_milliseconds = Gosu.milliseconds
      end

      def start
        self.instance_eval(@source_code)
        @robots.each { |robot| robot.queue.first.start unless robot.queue.empty? }
      end

      def draw
        @field.draw
      end

      def update
        @field.update
        @robots.each { |robot| robot.update((Gosu.milliseconds - @last_milliseconds) / 1000.0) }

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