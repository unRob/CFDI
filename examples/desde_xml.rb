require 'cfdi'
require 'json'

file_name = './data/cfdi.xml'

factura = CFDI.from_xml(File.read(file_name))

puts JSON::pretty_generate(factura.to_h)

#puts factura.to_xml