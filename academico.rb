## Script to print my IFF report card on terminal
## TODO: implement features to tell if I passed, etc.
require "rubygems"
require "bundler/setup"
require "capybara"
require "capybara/dsl"
require "capybara-webkit"

class Agent
  include Capybara::DSL

  def initialize
    start
  end

  def start
    Capybara.run_server = false
    Capybara.current_driver = :webkit
    Capybara.app_host = 'http://www.academico.iff.edu.br/'
  end

  def login
    visit '/qacademico/index.asp?t=1001'
    user = User.new
    fill_in 'LOGIN', with: user.id
    fill_in 'SENHA', with: user.pass
    click_button 'OK'
  end

  def grade
    visit '/qacademico/index.asp?t=2032'
  end
end

class User
  attr_accessor :id, :pass
  def initialize
    info = get_info
    @id = get_info[0]
    @pass = get_info[1]
  end

  def get_info
    info = []
    File.open('/home/bernardo/.academico').each_line { |l| info << l.delete("\n") }
    info
  end
end
