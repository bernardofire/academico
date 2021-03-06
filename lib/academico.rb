#encoding: utf-8
require "capybara"
require "terminal-table"

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
    user = User.info
    fill_in 'LOGIN', with: user[:id]
    fill_in 'SENHA', with: user[:pass]
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

  def create_table(rows)
    Terminal::Table.new :rows => rows,
                        :headings =>['Matéria', '1ºBi', '2ºBi', 'MS1', '3ºBi', '4ºBi', 'MS2', 'Final']
  end

  def go_to_page
    @agent.visit '/qacademico/index.asp?t=2032'
  end

  def extract
    rows = []
    line = 1
    @agent.all(@grade_selector).each do |tr|
      all_tds = tr.all('td')
      info = []
      [0, 5, 7, 9, 12, 14, 18, 22].each do |field|
        n = all_tds[field].text
        if field != 0
          if n.to_f >= 6.0
            n = "\033[32m#{n}\033[m"
          else
            n = "\033[31m#{n}\033[m"
          end
        end
        info << n
      end
      rows << info
      line = line.next
    end
    rows
  end
end

class User
  class << self
    @@file_path = "#{Dir.home}/.academico"

    def new(id, pass)
      File.open(@@file_path, 'w') { |f| f.write("#{id}\n#{pass}") }
    end

    def info
      info = []
      File.open(@@file_path).each_line { |l| info << l.delete("\n") }
      { id: info[0], pass: info[1] }
    end
  end
end

USAGE = <<-EOF
Academico is a tool to help IF students with the academical system.

  Usage:
    aca  # show your grades
    aca new ID PASS  # configure your user

  Examples:
    aca new 2012092390 secret_password
  EOF
