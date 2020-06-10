module TAC
  class Config
    attr_reader :configuration, :groups
    def initialize
      @configuration = nil
      @groups = nil

      parse(File.read(TAC::CONFIG_PATH))
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
    end

    def to_json(*args)
      {
        config: @configuration,
        data: {
          groups: @groups
        }
      }.to_json(*args)
    end

    class Configuration
      attr_accessor :created_at, :updated_at, :spec_version, :hostname, :port
      attr_reader :presets
      def initialize(created_at:, updated_at:, spec_version:, hostname:, port:, presets:)
        @created_at, @updated_at = created_at, updated_at
        @spec_version = spec_version
        @hostname, @port = hostname, port
        @presets = presets
      end

      def to_json(*args)
        {
          created_at: @created_at,
          updated_at: @updated_at,
          spec_version: @spec_version,
          hostname: @hostname,
          port: @port,
          presets: @presets
        }.to_json(*args)
      end

      def self.from_json(hash)
        Configuration.new(
          created_at: hash[:created_at], updated_at: hash[:updated_at],
          spec_version: hash[:spec_version], hostname: hash[:hostname],
          port: hash[:port], presets: hash[:presets].map { |ps| Preset.from_json(ps) }
        )
      end
    end

    class Preset
      def initialize()
      end

      def to_json(*args)
      end

      def self.from_json(hash)
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