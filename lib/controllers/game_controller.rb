module CodebreakerRack
  class GameController

    STATUS_WIN = 1.freeze
    STATUS_LOST = 2.freeze
    STATUS_PLAYING = 3.freeze

    STATUS_MAP = {
        1 => 'You win!',
        2 => 'Game over!',
        3 => 'Playing',
    }

    def initialize(request)
      @request = request
      @menu = (@request.session[:menu].present?)? @request.session[:menu]: nil
      @current_game = @menu.send(:current_game) unless @menu.nil?
    end

    def new_action
      init_menu
      @menu.send(:init_game)
      @request.session[:menu] = @menu
      @request.session[:game] = {}
      @request.session[:game][:answers] = []
      @request.session[:game][:status] = STATUS_PLAYING
      @request.session[:game][:hint_available] = true
      @request.session[:valid] = true
      @request.session[:game][:user_message] = ''
      generate_response false
    end

    def play_action
      if @current_game.present?
        game_status = @request.session[:game][:status]
        if @current_game.attempt_available? && STATUS_PLAYING == game_status

          take_hint if @request.session[:game][:use_hint]
          if @request.post?   
            if @request.params['answer'].present? && (valid_answer? @request.params['answer'])
              answer = @request.params['answer'].dup
              game_result = guess
              game_status = check_game_status(game_result, game_status)
              finalize_game game_status
              add_answer(answer, game_result)
              reset_user_message
            else
              update_user_message 'You have to enter four digits from 1 till 6'
            end
          end
        end

        update_game_status game_status
      end
      disable_hint_with_condition game_status
      generate_response
    end

    def hint_action
      @request.session[:game][:hint_available] = false
      @request.session[:game][:use_hint] = true
      generate_response false
    end

    def save_action
      if @request.post?
        if ( @current_game.present? ) && ( STATUS_WIN == @request.session[:game][:status] ) &&
            ( @request.params['user_name'].present? ) && ( valid_username? @request.params['user_name'] )
          save_game_result
          reset_user_message
          @request.session[:valid] = true
          Rack::Response.new do |response|
            response.redirect('/results')
          end
        else
          @request.session[:valid] = false
          update_user_message 'Name cannot contain less, then 3 symbols!'
        end
      end
      generate_response false
    end

    def load_action
      init_menu unless @menu.present?
      @request.session[:game][:user_message] = ''
      data = { saved_data: @menu.send(:run_manager).return_all_data }
      (generate_response(false, false)).merge data
    end

    private

    def valid_answer?(answer)
      answer = @menu.send(:correct_answer)
    end

    def valid_username?(username)
      username.strip.length > 2
    end

    def init_menu
      @menu = Codebreaker::Menu.new
    end

    def take_hint
      @request.session[:game][:hint_value] = @current_game.take_hint
      @request.session[:game][:use_hint] = false
    end

    def guess
      @current_game.send(:use_attempt)
      @current_game.send(:check_attempt, @request.params['answer'])
    end

    def check_game_status(game_result, current_status)
      return STATUS_WIN if game_result == Array.new(4, '+')
      return STATUS_LOST if !@current_game.attempt_available? && STATUS_PLAYING == current_status
      STATUS_PLAYING
    end

    def finalize_game(game_status)
      @current_game.game_win if STATUS_WIN == game_status
      @current_game.game_lost if STATUS_LOST == game_status
    end

    def disable_hint_with_condition(game_status)
      @request.session[:game][:hint_available] = false if @request.session[:game][:hint_available] && STATUS_PLAYING != game_status
    end

    def update_game_status(game_status)
      @request.session[:game][:status] = game_status if @request.session[:game][:status] != game_status
    end

    def add_answer(answer, game_result)
      @request.session[:game][:answers] << {
        answer: answer,
        result: game_result,
      }
    end

    def update_user_message(message)
      @request.session[:game][:user_message] = message
    end

    def reset_user_message
      update_user_message '' unless @request.session[:game][:user_message].empty?
    end

    def save_game_result
      @menu.send(:run_manager).add_game(
        @request.params['user_name'],
        @current_game.game_win?,
        @current_game.attempts,
        !@current_game.hint_available?
      )
    end

    def generate_response(all_fields = true, message = true)
      response = {
        valid: @request.session[:valid],
      }
      response[:user_message] = @request.session[:game][:user_message] if message
      response.merge! generate_other_fields if all_fields
      response
    end

    def generate_other_fields
      game_status = @request.session[:game][:status]
      {
        game_status_text: STATUS_MAP[game_status],
        game_active: game_status == STATUS_PLAYING,
        hint_available: @request.session[:game][:hint_available],
        hint_value: @request.session[:game][:hint_value],
        save_game_enabled: game_status == STATUS_WIN,
        secret_code: @current_game.send(:code),
        attemps_amount: Codebreaker::Game::ATTEMPTS_AMOUNT,
        answers: @request.session[:game][:answers],
      }
    end
  end
end
