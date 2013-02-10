#encoding: utf-8
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
    Grade.new(self).printable_grade
  end
end

class Grade
  def initialize(agent)
    @agent = agent
    @grade_selector =  'table > tbody tr:nth-child(2) > td > table > tbody > tr.conteudoTexto'
  end

  def printable_grade
    go_to_page
    create_table extract
  end

  def create_table(info)
    info #TODO: Implement this method
  end

  def go_to_page
    @agent.visit '/qacademico/index.asp?t=2032'
  end

  def extract
    info = { 'line_0' => ['Matéria', '1ºBi', '2ºBi', '3ºBi', '4ºBi'] }
    line = 1
    @agent.all(@grade_selector).each do |tr|
      all_tds = tr.all('td')
      line_info = []
      [0, 5, 7, 13, 15] .each do |field|
         line_info << all_tds[field].text
      end
      info["line_#{line}"] = line_info
      line = line.next
    end
    info
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
