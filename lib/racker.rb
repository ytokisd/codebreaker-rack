require 'codebreaker'
require './lib/controllers/game_controller'
require 'slim'
 
class Racker
  def self.call(env)
    new(env).response.finish
  end
   
  attr_reader :template

  def initialize(env)
    @template = 'index'
    @request = Rack::Request.new(env)
  end
   
   def response
     @controller = CodebreakerRack::GameController.new(@request)
     return not_found unless routes.dig(@request.path).present?
     choice_processor(@request.path) 
     end    
  #   case @request.path
  #   when '/'
  #     rack_response(nil, nil, 'index', nil, false)

  #   when '/game/new'
  #     rack_response(controller, 'new_action', nil, '/play', false)

  #   when '/play'
  #     rack_response(controller, 'play_action', 'game')

  #   when '/game/save'
  #     if @request.get?
  #       rack_response(nil, nil, 'save_results', nil, false)
  #     else
  #       rack_response(controller, 'save_action', 'save_results', '/results')
  #     end

  #   when '/game/hint'
  #     rack_response(controller, 'hint_action', nil, '/play', false)
    
  #   when '/results'
  #     rack_response(controller, 'load_action', 'load_results')
    
  #   else Rack::Response.new('Not Found', 404)
  #   end
  # end

  def choice_processor(route_name)
    routes.dig(route_name).call
  end

  def routes
    {
      '/' => -> { resolve_index },
      '/game/new'=> (-> { resolve_game_new }),
      '/play' => (-> { resolve_play }),
      '/game/save' => (-> { resolve_game_save }),
      '/game/hint' => (-> { resolve_game_hint }),
      '/results' => (-> { resolve_results })
    }
  end

  def resolve_index
    rack_response(nil, nil, 'index', nil, false)
  end

  def resolve_game_new
    rack_response(@controller, 'new_action', nil, '/play', false)
  end

  def resolve_play
    rack_response(@controller, 'play_action', 'game')
  end

  def resolve_game_save
    if @request.get?
      rack_response(nil, nil, 'save_results', nil, false)
    else
      rack_response(@controller, 'save_action', 'save_results', '/results')
    end
  end

  def resolve_game_hint
    rack_response(@controller, 'hint_action', nil, '/play', false)
  end

  def resolve_results
    rack_response(@controller, 'load_action', 'load_results')
  end

  def not_found
    Rack::Response.new('Not Found', 404)
  end
  
  private 

  def rack_response(controller = nil, action = nil, template = nil, redirect_url = nil, bind_data = true)
    @controller_result = controller.public_send(action) unless controller.nil?
    bind_results @controller_result if bind_data
    response_handler(controller, template, redirect_url)
  end

  def response_handler(controller, template, redirect_url)
    if redirect_url.nil? || !@controller_result[:valid]
      to_rendered_view(template)
    elsif controller.nil? || @controller_result[:valid]
      redirect_to(redirect_url)
    end
  end

  def to_rendered_view(template)
    @template = template
    Rack::Response.new(view_render)
  end

  def redirect_to(redirect_url)
    Rack::Response.new do |response|
      response.redirect(redirect_url)
    end
  end

  def bind_results(data)
    data.each do |key, value|
      self.class.send(:attr_accessor, key)
      send("#{key}=", value)
    end
  end
   
  def view_render(view = 'layout')
    abs_path = File.expand_path("../views/#{view}.html.slim", __FILE__)
      Slim::Template.new(abs_path).render(self)
  end
end
