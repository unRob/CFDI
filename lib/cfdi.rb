# encoding: utf-8
gem 'nokogiri', '< 1.6', '>= 1.4.0'

require_relative 'comun.rb'
require_relative 'comprobante.rb'
require_relative 'entidad.rb'
require_relative 'concepto.rb'
require_relative 'complemento.rb'
require_relative 'xml.rb'
require_relative 'certificado.rb'
require_relative 'key.rb'

# Comprobantes fiscales digitales por los internets
# 
# El sistema de generación y sellado de facturas es una patada en los genitales. Este gem pretende ser una bolsa de hielos. Igual va a doler, pero espero que al menos no quede moretón.
module CFDI
  
  require 'nokogiri'
  require 'time'
  require 'base64'
  
  # La versión de este gem
  VERSION = '0.1.2'
  
end