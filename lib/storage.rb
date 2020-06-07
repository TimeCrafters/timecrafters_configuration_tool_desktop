module TAC
  module Storage
    Group = Struct.new(:id, :name)
    Action = Struct.new(:id, :group_id, :name, :enabled)
    Value = Struct.new(:id, :action_id, :name, :type, :value)

    def self.groups
      @@_g ||= Array.new(15) { |i| Group.new(i, Faker::Book.title) }
    end

    def self.actions(group_id)
      @@_a ||= Array.new(100) { |i| Action.new(i, groups.sample.id, Faker::Space.meteorite, true) }
      @@_a.select { |a| a.group_id == group_id }
    end

    def self.values(action_id)
      types = [:double, :float, :string, :boolean, :integer]

      @@_v ||= Array.new(500) do |i|
        v = Value.new(i, rand(100), Faker::Space.meteorite, types.sample)

        v.value = case v.type
        when :double, :float
          rand(-1.0..1.0)
        when :integer
          rand(-1024..1024)
        when :string
          Faker::Quotes::Shakespeare.hamlet_quote
        when :boolean
          rand > 0.5
        end

        v
      end

      @@_v.select { |a| a.action_id == action_id }
    end
  end
end