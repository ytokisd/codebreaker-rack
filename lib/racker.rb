require_relative 'game.rb'
class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @game = Game.new
  end

  def response
    case @request.path
    when '/' then Rack::Response.new(render('index.html.erb'))
    when '/play_game' then Rack::Response.new(render('play_game.html.erb'))
    when '/view_results' then Rack::Response.new(render('view_results.html.erb'))
    when '/update_word'
      Rack::Response.new do |response|
        response.set_cookie('word', @request.params['word'])
        response.redirect('/')
      end
    when '/play_game/turn_processor'
        Rack::Response.new do |response|
        @game.rack_turn(guess)
        response.set_cookie('guess', @request.params['guess'])
        response.redirect('/play_game')
      end
    else Rack::Response.new('Not Found', 404)
    end
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def guess
     @request.cookies['guess']
  end

  def word
    @request.cookies['word']
  end
end