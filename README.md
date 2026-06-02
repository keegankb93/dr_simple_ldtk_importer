# dr_simple_ldtk_importer

This is a simple importer for the [LDtk](https://ldtk.io/) level editor.

>[!NOTE]
> This ONLY supports the simple export option from LDtk.

The goal of this project is to provide a simple and painless way to get your LDtk projects
into DragonRuby. Ideally, this gives you everything you need to import LDtk levels and tries to remain unopinionated about how you structure your game. Essentially, this is going to give you the exported data in a friendly format. Some helpers will be provided to get you up and running quickly, but you may find you want better collision detection, more granular control over rendering, etc. That is all possible!

## Todo:

- [] Register entities with the importer to load them into the game
- [] Polish, document and look for potentialy performance improvements

## Installation

Clone the repository and copy the lib/simple_ldtk folder into your project

## Usage

Check out `app/main.rb` for a quick and dirty example of a "functioning" level.

```ruby
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
      # The name will need to match the name of the corresponding intgrid csv file name
      config.int_grid 'Collisions' do |grid|
        grid.value 1, as: :solid
        grid.value 2, as: :ladder
        grid.value 3, as: :solid
      end
    end

    level = args.state.level

    scene = args.outputs[:scene]
    scene.w = level.width
    scene.h = level.height
    scene.sprites << level.world

    # Debugs the int grid 'Collisions' and highlights the solid tiles in red
    scene.debug << level.debug_int_grid(
      'Collisions',
      type: :solid,
      color: [255, 0, 0]
    )

    # Debugs the int grid 'Collisions' and highlights the ladder tiles in cyan
    scene.debug << level.debug_int_grid(
      'Collisions',
      type: :ladder,
      color: [0, 255, 255]
    )
  end
end
```
