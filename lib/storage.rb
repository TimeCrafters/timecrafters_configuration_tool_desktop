module TAC
  module Storage
    Group = Struct.new(:id, :name)
    Action = Struct.new(:id, :group_id, :name, :enabled)
    Value = Struct.new(:id, :action_id, :name, :type, :value)

    def self.groups
      $window.backend.config[:data][:groups].map do |g|
        Group.new(g[:id], g[:name])
      end
    end

    def self.actions(group_id)
      $window.backend.config[:data][:actions].map{ |a| Action.new(a[:id], a[:group_id], a[:name], a[:enabled]) }.select { |a| a.group_id == group_id }
    end

    def self.values(action_id)
      types = [:double, :float, :string, :boolean, :integer]

      $window.backend.config[:data][:values].map { |v| Value.new(v[:id], v[:action_id], v[:name], v[:type].to_sym, v[:value]) }.select { |a| a.action_id == action_id }
    end
  end
end