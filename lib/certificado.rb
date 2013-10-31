module CFDI
  
  require 'openssl'
  
  # Certificados en formato X590
  # 
  # En español, el archivo `.cer`
  class Certificado < OpenSSL::X509::Certificate
    
    # el número de certificado
    attr_reader :noCertificado
    # el certificado en Base64
    attr_reader :data

        # Importar un certificado de sellado
        # @param  file [IO, String] El `path` del certificado o un objeto #IO
        # 
        # @return [CFDI::Certificado] Un certificado
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
    

    # Certifica una factura
    # @param  factura [CFDI::Comprobante] El comprobante a certificar
    # 
    # @return [CFDI::Comprobante] El comprobante certificado (con `#noCertificado` y `#certificado`)
    def certifica factura
      
      factura.noCertificado = @noCertificado
      factura.certificado = @data
      
    end
  
    
  end
  
end
