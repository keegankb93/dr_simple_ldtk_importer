module SimpleLdtk
  module Debugger
    #
    # Draws a border around the cells of the given type in the int_grid.
    def debug_int_grid(name, type:, color: [255, 0, 0])
      r, g, b = color

      cells_for(name, type).map do |cell|
        {
          x: cell[:x],
          y: cell[:y],
          w: cell[:w],
          h: cell[:h],
          r: r,
          g: g,
          b: b,
          primitive_marker: :border
        }
      end
    end
  end
end
