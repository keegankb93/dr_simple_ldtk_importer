require 'lib/simple_ldtk/level'
require 'app/camera'
require 'app/player'

module Main
  def tick(args)
    args.state.level ||= ::SimpleLdtk::Level.load('maps/level_one') do |config|
      # If using the city example, tile_size should be set to 8
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

      config.entity 'Player' do |e|
        # This needs to be an "entity" or object that responds to x, y, w, h (rect)
        # The data that is returned from the entity is:
        # id:
        # iid:
        # type:
        # layer:
        # x:
        # y:
        # w:
        # h:
        # color:
        # fields:
        # raw_entity:
        Player.new(x: e.x, y: e.y, w: e.w, h: e.h, path: :solid, r: 0, g: 0, b: 255)
      end
    end

    level = args.state.level

    args.state.camera ||= Camera.new

    camera = args.state.camera
    camera.handle_camera_inputs(args)

    args.state.player ||= level.entity('Player')

    player = args.state.player
    player.tick(args)

    camera.follow(player, level)

    scene = args.outputs[:scene]
    scene.w = level.width
    scene.h = level.height

    scene.sprites << level.tilemap
    scene.sprites << player

    scene.debug << level.debug_int_grid do |debug|
      debug.int_grid 'Collisions', type: :solid, color: [255, 0, 0]
      debug.int_grid 'Collisions', type: :ladder, color: [0, 255, 255]
    end

    # I don't really like viewport_for, find a better way than the camera owning the scene render
    args.outputs.sprites << camera.viewport_for(:scene)
  end
end
