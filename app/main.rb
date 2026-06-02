require 'lib/simple_ldtk/level'
require 'app/camera'

module Main
  def tick(args)
    args.state.level ||= ::SimpleLdtk::Level.load('maps/level_one') do |config|
      config.tile_size = 16

      #
      # This allows you to map your integer grid values so that you can handle
      # collisions differently. For example if you have a ladder you may want to detect
      # when the player is on top of it and allow them to climb it, but with a solid you may
      # want to block movement entirely.
      #
      # The name will need to match the name of the corresponding intgrid csv
      config.int_grid 'Collisions' do |grid|
        grid.value 1, as: :solid
        grid.value 2, as: :ladder
        grid.value 3, as: :solid
      end
    end

    level = args.state.level

    args.state.camera ||= Camera.new

    camera = args.state.camera

    camera.handle_camera_inputs(args)

    args.state.player ||= { x: 0, y: 0, w: 12, h: 12 }
    player = args.state.player

    if args.inputs.directional_angle
      dx = args.inputs.directional_angle.vector_x * 2
      dy = args.inputs.directional_angle.vector_y * 2

      next_player = player.merge(x: player.x + dx)
      player.x += dx unless level.collides?(next_player)

      next_player = player.merge(y: player.y + dy)
      player.y += dy unless level.collides?(next_player)

      player.x = player.x.clamp(0, level.width - player.w)
      player.y = player.y.clamp(0, level.height - player.h)
    end

    args.state.camera.follow(player, level)

    scene = args.outputs[:scene]
    scene.w = level.width
    scene.h = level.height

    # Should make a better name than world, maybe.
    scene.sprites << level.world

    scene.debug << level.debug_int_grid(
      'Collisions',
      type: :solid,
      color: [255, 0, 0]
    )

    scene.debug << level.debug_int_grid(
      'Collisions',
      type: :ladder,
      color: [0, 255, 255]
    )

    scene.sprites << {
      x: player.x,
      y: player.y,
      w: player.w,
      h: player.h,
      path: :solid,
      r: 0,
      g: 0,
      b: 255
    }

    # I don't really like viewport_for, find a better way than the camera owning the scene render
    args.outputs.sprites << camera.viewport_for(:scene)
  end
end
