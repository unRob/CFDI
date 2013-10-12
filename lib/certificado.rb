module CFDI
  
  require 'openssl'
  
  class Certificado < OpenSSL::X509::Certificate
    
    attr_reader :noCertificado, :data
    
    def initialize (file)
      
      if file.is_a? String
        file = File.read(file)
      end
            
      super file
      
      @noCertificado = '';
      # Normalmente son strings de tipo:
      # 3230303031303030303030323030303030323933
      # por eso sólo tomamos cada segundo dígito
      self.serial.to_s(16).scan(/.{2}/).each {|v| @noCertificado += v[1]; }
      @data = self.to_s.gsub(/^-.+/, '').gsub(/\n/, '')
      
    end
    
    def certifica factura
      
      factura.noCertificado = @noCertificado
      factura.certificado = @data
      
    end
  
    
  end
  
end
