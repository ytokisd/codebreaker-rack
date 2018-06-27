require_relative 'processor.rb'
require_relative 'data_manager.rb'
require_relative 'interface.rb'

# Comment
class Game
  include Interface

  def initialize
    @processor = Processor.new
    @manager = DataManager.new
    @code = generator
  end

  def secret_code
    @code
  end

  def generator
    Array.new(4) { rand(1..6) }
  end

  def game_preparations
    @code = generator
    @attempts = 3
    @game_end = false
    @hint_avaliable = true
  end

  def new_game
    game_preparations
    turn_start_message
    loop do
      result = choice_processor
      attempts
      win(result)
      break if @game_end
      lost
      break if @game_end
    end
    save_results_message
    save_results?
  end

  def attempts
    @attempts = @processor.attempts_left
  end

  def rack_turn (command)
    @processor.turn_processor(secret_code, command)
  end

  def win(result)
    win_condition = Array.new(4, '+')
    return unless result == win_condition
    win_game_message
    @game_end = true
  end

  def lost
    return unless @attempts.zero?
    lost_game_message
    @game_end = true
  end

  def choice_processor
    command = gets.chomp
    commands.dig(command.to_sym).call unless command =~ /^[1-6]{4}$/
    @processor.turn_processor(@code, command)
  rescue
    puts 'Please give a valid command'
    retry
  end

  def check_hint
    return have_no_hints_message unless @hint_avaliable == true
    @processor.hint_processor(@code)
    @hint_avaliable = false
  end

  def exit_game
    exit
  end

  def save_results?
    choice = gets.chomp.downcase
    choice == 'yes' ? @manager.write_results(@attempts, @hint_avaliable) : ' '
  end

  def commands
    {
      h: -> { check_hint },
      q: -> { exit_game }
    }
  end
end