# encoding: utf-8
gem 'nokogiri', '< 1.6', '>= 1.4.0'

require_relative 'comun.rb'
require_relative 'comprobante.rb'
require_relative 'entidad.rb'
require_relative 'concepto.rb'
require_relative 'certificado.rb'
require_relative 'key.rb'

module CFDI
  
  require 'nokogiri'
  require 'time'
  require 'base64'
  
  VERSION = '0.0.2'
  
end