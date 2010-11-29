$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

$: << File.join(File.dirname(__FILE__),File.basename(__FILE__,File.extname(__FILE__)))

require 'fasta_qual_file'
require 'fasta_file'


module ScbiFasta
  VERSION = '0.1.3'
end
