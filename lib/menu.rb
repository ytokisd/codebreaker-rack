require_relative 'game.rb'
require_relative 'data_manager.rb'
require_relative 'interface.rb'
# comment
class Menu
  include Interface
  def initialize
    @game = Game.new
    @manager = DataManager.new
  end

  def game_menu
    loop do
      main_menu_message
      choice = gets.chomp
      choice_processor(choice)
    end
    rescue
      puts 'Please give a valid command'
      retry
  end

  def start_game
    @game.new_game
  end

  def exit_game
    exit
  end

  def read_results
    @manager.view_results
  end

  def commands
    {
      p: -> { start_game },
      q: -> { exit_game },
      r: -> { read_results }
    }
  end

  def choice_processor(command_name)
    commands.dig(command_name.to_sym).call
  end
end