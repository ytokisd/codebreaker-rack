module Interface
  def turn_start_message
    puts "Enter 4 1-6 digits or:
h - get a hint
q - exit game"
  end

  def attempts_left(attempts)
    puts "Number of attempts left: #{attempts}"
  end

  def your_name
    puts 'Enter your name'
  end

  def hint_message(code_number_value, code_number_index)
    puts "Number #{code_number_value} is on position #{code_number_index + 1}"
  end

  def have_no_hints_message
    puts 'You dont have hints'
  end

  def save_results_message
    puts 'Save results? [yes/no]'
  end

  def win_game_message
    puts 'Congratulations! You won the game!'
  end

  def incorrect_entry_message
    puts 'Please enter correct command'
  end

  def lost_game_message
    puts 'Sorry, you lost'
  end

  def main_menu_message
    puts "Welcome to a game
Please select action:
p - play a game
r - view results
q - exit game"
  end

  def result_save_message(username, attempts, hint)
    message =  "#{Time.now}: #{username} finished game with #{attempts} attempts left. Hint used: #{hint} \n"
    message
  end
end