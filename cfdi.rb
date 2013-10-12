# encoding: utf-8
gem 'nokogiri', '< 1.6', '>= 1.4.0'

require_relative 'lib/comun.rb'
require_relative 'lib/comprobante.rb'
require_relative 'lib/entidad.rb'
require_relative 'lib/concepto.rb'
require_relative 'lib/certificado.rb'
require_relative 'lib/key.rb'

module CFDI
  
  require 'nokogiri'
  require 'time'
  require 'openssl'
  require 'base64'
  
  VERSION = '0.0.1'
  
end