module TAC
  class Pages
    class DriveTeamRotationGenerator < Page
      FILENAME = "#{TAC::ROOT_PATH}/data/drive_team_rotation.csv"

      def setup
        header_bar("Drive Team Rotation Generator")

        @roster ||= [
          "Alexander",
          "Aubrey",
          "Cayden",
          "Gabe",
          "Spencer",
          "Olivia"
        ]

        @roles ||= [
          "Coach",
          "Driver A",
          "Driver B"
        ]

        menu_bar.clear do
          button get_image("#{TAC::ROOT_PATH}/media/icons/save.png"), image_height: 1.0, tip: "Export rotation as Comma-Seperated Values" do
            export_rotation

            @status_bar.clear do
              tagline "Saved to: #{FILENAME}"
            end
          end

          button get_image("#{TAC::ROOT_PATH}/media/icons/target.png"), margin_right: 10, image_height: 1.0, tip: "Generate rotation" do
            populate_rotation
          end
        end

        body.clear do
          flow(margin_left: 20, width: 1.0, height: 1.0) do
            stack(width: 0.25) do
              title "Roles", width: 1.0, margin_bottom: 4, text_align: :center

              flow(width: 1.0, margin_bottom: 20) do
                @role_name = edit_line "", placeholder: "Add role", width: 0.9
                button get_image("#{TAC::ROOT_PATH}/media/icons/plus.png"), image_width: 0.1 do
                  if @role_name.value.strip.length.positive?
                    @roles.push(@role_name.value.strip)
                    @role_name.value = ""

                    populate_roles
                  end
                end
              end

              @roles_container = stack(width: 1.0, height: 0.835, scroll: true) do
              end
            end

            stack(margin_left: 20, width: 0.25, height: 1.0) do
              title "Roster", width: 1.0, margin_bottom: 4, text_align: :center

              flow(width: 1.0, margin_bottom: 20) do
                @roster_name = edit_line "", placeholder: "Add name", width: 0.9
                button get_image("#{TAC::ROOT_PATH}/media/icons/plus.png"), image_width: 0.1 do
                  if @roster_name.value.strip.length.positive?
                    @roster.push(@roster_name.value.strip)
                    @roster_name.value = ""

                    populate_roster
                  end
                end
              end

              @roster_container = stack(width: 1.0, height: 0.835, scroll: true) do
              end
            end

            stack(margin_left: 20, margin_right: 20, width: 0.5, height: 1.0) do
              title "Rotation", width: 1.0, margin_bottom: 4, text_align: :center

              @rotation_container = stack(width: 1.0, height: 0.835, scroll: true) do
              end
            end
          end
        end

        populate_roles
        populate_roster
        populate_rotation
      end

      def populate_roles
        @roles_container.clear do
          @roles.each_with_index do |name, i|
            flow(width: 1.0, padding: 2) do
              background i.even? ? 0xff_007000 : 0xff_006000

              tagline name, width: 0.9
              button "<b>X</b>", width: 0.1, text_size: 18, **THEME_DANGER_BUTTON do
                @roles.delete(name)
                populate_roles
              end
            end
          end
        end
      end

      def populate_roster
        @roster_container.clear do
          @roster.each_with_index do |name, i|
            flow(width: 1.0, padding: 2) do
              background i.even? ? 0xff_007000 : 0xff_006000

              tagline name, width: 0.9
              button "<b>X</b>", width: 0.1, text_size: 18, **THEME_DANGER_BUTTON do
                @roster.delete(name)
                populate_roster
              end
            end
          end
        end
      end

      def populate_rotation
        @rotation = Generator.new(roster: @roster, team_size: @roles.count)

        @rotation_container.clear do
          fraction = (1.0 / @rotation.team_size) - 0.02

          flow(width: 1.0, padding: 2) do
            background Gosu::Color::BLACK

            @roles.each do |role|
            tagline "<b>#{role}</b>", width: fraction
            end
          end

          teams = @rotation.teams unless @shuffle_teams&.value
          teams = @rotation.teams.shuffle if @shuffle_teams&.value

          teams.each_with_index do |team, i|
            flow(width: 1.0, padding: 2) do
              background i.even? ? 0xff_007000 : 0xff_006000

              team.each do |player|
                tagline player, width: fraction
              end
            end
          end
        end
      end

      def export_rotation
        return unless @rotation

        buff = "#{@roles.join(',')}\n"

        @rotation.teams.each do |team|
          buff += "#{team.join(",")}\n"
        end

        buff.strip

        File.write(FILENAME, buff)
      end
    end

    class Generator
      attr_reader :roster, :team_size, :rounds, :teams, :schedule

      def initialize(roster:, team_size: 4, rounds: 6)
        @roster = roster.clone
        @roster.freeze
        @team_size = team_size
        @rounds = rounds

        @teams = []
        @schedule = []

        generate
      end

      def generate
        generate_teams
        generate_round_robin
      end

      def generate_teams
        return unless @roster.size >= @team_size

        list = @roster.dup

        list.size.times do
          list.rotate!

          @teams << list[0..@team_size - 1]
        end
      end

      def generate_round_robin
      end
    end
  end
end