module CFDI
  
  require 'openssl'
  
  # Una llave privada, en formato X509 no PKCS7
  # 
  # Para convertirlos, nomás hacemos 
  #     openssl pkcs8 -inform DER -in nombreGiganteDelSAT.key -passin pass:miFIELCreo >> certX509.pem
  class Key < OpenSSL::PKey::RSA


    # Crea una llave privada
    # @param  file [IO, String] El `path` de esta llave o los bytes de la misma
    # @param  password=nil [String, nil] El password de esta llave
    # 
    # @return [CFDI::Key] La llave privada
    def initialize file, password=nil
      if file.is_a? String
        file = File.read(file)
      end
      super file, password
    end
    
    # sella una factura
    # 
    # @param factura [CFDI::Comprobante] El comprobante a sellar
    # 
    # @return [CFDI::comprobante] El comprobante con el `sello`
    def sella factura
      cadena_original = factura.cadena_original
      factura.sello = Base64::encode64(self.sign(OpenSSL::Digest::SHA1.new, cadena_original)).gsub(/\n/, '')
    end
    
  end
  
end