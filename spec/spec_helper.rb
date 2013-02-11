$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'require_all'
require 'academico'

require_all File.expand_path(__FILE__ + "/../../lib")

