require "lib/simple_ldtk/debugger"
require "lib/simple_ldtk/config"
require "lib/simple_ldtk/level_data"

module SimpleLdtk
  module Level
    extend self

    DATA_FILE = "data.json"
    INT_GRID_FILE = "Collisions.csv"

    #
    # Loads a level from the given directory.
    # LDTK simple export exports multiple files into a folder
    # The only files we need are `data.json` and the Collisions.csv file
    # Since these are constant we can make it easier and just grab them by default
    def load(dir)
      config = Config.new
      yield config if block_given?

      data = DR.parse_json_file("#{dir}/#{DATA_FILE}")

      level = LevelData.new(
        dir: dir,
        data: data,
        composite_path: "#{dir}/_composite.png",
        int_grids: load_int_grids(dir, data, config)
      )

      level.extend(Debugger) unless DR.production? # Not sure if this is like the best idea, but it's ok right now

      level
    end

    private

    def load_int_grids(dir, data, config)
      config.int_grid_configs.each_with_object({}) do |(name, grid_config), result|
        path = "#{dir}/#{INT_GRID_FILE}"

        result[name] = load_int_grid_csv(
          path: path,
          level_height: data['height'],
          tile_size: config.tile_size,
          grid_config: grid_config
        )
      end
    end

    def load_int_grid_csv(path:, level_height:, tile_size:, grid_config:)
      rows = parse_csv(DR.read_file(path))
      cells = []

      rows.each_with_index do |row, row_index|
        row.each_with_index do |raw_value, col_index|
          next if raw_value.nil? || raw_value == ''

          value = raw_value.to_i
          type = grid_config.type_for(value)

          # Skips anything not explicitly mapped in the grid config.
          # This means 0 (usually no collision) is ignored unless explicitly mapped.
          next unless type

          cells << {
            col: col_index,
            row: row_index,

            # LDtk CSV row 0 is top.
            # DragonRuby y=0 is bottom.
            x: col_index * tile_size,
            y: level_height - ((row_index + 1) * tile_size),

            w: tile_size,
            h: tile_size,

            value: value,
            type: type
          }
        end
      end

      cells
    end

    def parse_csv(text)
      text
        .split("\n")
        .map { |line| line.strip.split(",") }
    end
  end
end
