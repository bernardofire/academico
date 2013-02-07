## Script to print my IFF report card on terminal
## TODO: implement features to tell if I passed, etc.
require 'mechanize'
require 'logger'

class Agent
  def initialize
    start_mech
  end

  def start_mech
    @mech = Mechanize.new
    @mech.log = Logger.new $stderr
    @mech.agent.http.debug_output = $stderr
  end

  def login
    page = @mech.get 'http://www.academico.iff.edu.br/qacademico/index.asp?t=1001'
    user = User.new
    form = page.form_with name: 'frmLogin'
    form.set_fields('LOGIN' => user.id, 'SENHA' => user.pass)
    form.submit
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
    File.open('/home/bernardo/.iffudeu').each_line { |l| info << l.delete("\n") }
    info
  end
end
