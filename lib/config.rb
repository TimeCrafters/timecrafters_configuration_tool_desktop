module TAC
  class Config
    attr_reader :configuration, :groups, :presets
    def initialize(name)
      @configuration = nil
      @groups = nil
      @presets = nil

      parse(File.read("#{TAC::CONFIGS_PATH}/#{name}.json"))
    end

    def parse(json)
      data = JSON.parse(json, symbolize_names: true)

      if data.is_a?(Array)
        parse_original_config(data)
      elsif data.is_a?(Hash) && data.dig(:config, :spec_version) == TAC::CONFIG_SPEC_VERSION
        parse_spec_current(data)
      else
        raise "Unable to load config."
      end
    end

    def parse_original_config(data)
    end

    def parse_spec_current(data)
      @configuration = Configuration.from_json(data[:config])
      @groups = data.dig(:data, :groups).map { |g| Group.from_json(g) }
      @presets = Presets.from_json(data.dig(:data, :presets))
    end

    def to_json(*args)
      {
        config: @configuration,
        data: {
          groups: @groups,
          presets: @presets,
        }
      }.to_json(*args)
    end

    class Configuration
      attr_accessor :created_at, :updated_at, :spec_version, :revision
      def initialize(created_at:, updated_at:, spec_version:, revision:)
        @created_at, @updated_at = created_at, updated_at
        @spec_version = spec_version
        @revision = revision
      end

      def to_json(*args)
        {
          created_at: @created_at,
          updated_at: @updated_at,
          spec_version: @spec_version,
          revision: @revision,
        }.to_json(*args)
      end

      def self.from_json(hash)
        Configuration.new(
          created_at: hash[:created_at],
          updated_at: hash[:updated_at],
          spec_version: hash[:spec_version],
          revision: hash[:revision],
        )
      end
    end

    class Presets
      attr_reader :groups, :actions
      def initialize(groups:, actions:)
        @groups, @actions = groups, actions
      end

      def to_json(*args)
        {
          groups: @groups,
          actions: @actions,
        }.to_json(*args)
      end

      def self.from_json(hash)
        Presets.new(
          groups: hash[:groups].map { |group| Group.from_json(group) },
          actions: hash[:actions].map { |action| Action.from_json(action) },
        )
      end
    end

    class Group
      attr_accessor :name
      attr_reader :actions
      def initialize(name:, actions:)
        @name = name
        @actions = actions
      end

      def to_json(*args)
        {
          name: @name,
          actions: @actions
        }.to_json(*args)
      end

      def self.from_json(hash)
        Group.new(name: hash[:name], actions: hash[:actions].map { |a| Action.from_json(a) })
      end
    end

    class Action
      attr_accessor :name, :enabled
      attr_reader :variables
      def initialize(name:, enabled:, variables:)
        @name, @enabled = name, enabled
        @variables = variables
      end

      def to_json(*args)
        {
          name: @name,
          enabled: @enabled,
          variables: @variables
        }.to_json(*args)
      end

      def self.from_json(hash)
        Action.new(name: hash[:name], enabled: hash[:enabled], variables: hash[:variables].map { |h| Variable.from_json(h) })
      end
    end

    class Variable
      attr_accessor :name, :type, :value
      def initialize(name:, type:, value:)
        @name, @type, @value = name, type, value
      end

      def to_json(*args)
        {
          name: @name,
          type: @type,
          value: @value
        }.to_json(*args)
      end

      def self.from_json(hash)
        Variable.new(name: hash[:name], type: hash[:type].to_sym, value: hash[:value])
      end
    end
  end
end