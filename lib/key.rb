module CFDI
  
  require 'openssl'
  
  class Key < OpenSSL::PKey::RSA
   
    def initialize file, password
      if file.is_a? String
        file = File.read(file)
      end
      super file, password
    end
    
    # sella una factura
    def sella factura
      cadena_original = factura.cadena_original
      factura.sello = Base64::encode64(self.sign(OpenSSL::Digest::SHA1.new, cadena_original)).gsub(/\n/, '')
    end
    
  end
  
end