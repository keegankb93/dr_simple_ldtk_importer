require 'lib/simple_ldtk/configs/int_grid'

module SimpleLdtk
  class Config
    attr_accessor :tile_size

    attr_reader :int_grid_configs

    def initialize
      @tile_size = 16
      @int_grid_configs = {}
    end

    def int_grid(name)
      grid_config = Configs::IntGrid.new(name)
      yield grid_config if block_given?

      int_grid_configs[name] = grid_config
    end
  end
end
