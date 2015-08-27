# encoding: utf-8
require_relative '../lib/cfdi.rb'

describe CFDI::Comprobante do

  it "debe de poder instanciar sin datos" do
    comprobante = CFDI::Comprobante.new
    defaults = {
      :version=>"3.2",
      :fecha=>nil,
      :tipoDeComprobante=>"ingreso",
      :formaDePago=>nil,
      :condicionesDePago=>nil,
      :subTotal=>0,
      :TipoCambio=>1,
      :moneda=>"pesos",
      :total=>0.0,
      :metodoDePago=>nil,
      :lugarExpedicion=>nil,
      :NumCtaPago=>nil,
      :emisor=>nil,
      :receptor=>nil,
      :conceptos=>[],
      :serie=>nil,
      :folio=>nil,
      :sello=>nil,
      :noCertificado=>nil,
      :certificado=>nil,
      :complemento=>nil,
      :cancelada=>nil,
      :impuestos=>[]
    }
    puts comprobante.to_h
    expect(comprobante.to_h).to be_eql(defaults)
  end

  it "debe de poder settear defaults" do
    CFDI::Comprobante.configure({defaults: {version: '2.0'}})
    comprobante = CFDI::Comprobante.new
    expect(comprobante.version).to eq '2.0'
  end

  it "debe de generar un comprobante desde XML" do
    comprobante = CFDI.from_xml(File.read('./examples/data/cfdi.xml'))
    returns = {:version=>"3.2", :fecha=>"2013-10-15T01:33:32", :tipoDeComprobante=>"ingreso", :formaDePago=>"PAGO EN UNA SOLA EXHIBICION", :condicionesDePago=>"Sera marcada como pagada en cuanto el receptor haya cubierto el pago.", :subTotal=>11000.0, :TipoCambio=>1, :moneda=>"pesos", :total=>12760.0, :metodoDePago=>"Transferencia Bancaria", :lugarExpedicion=>"Nutopia, Nutopia", :NumCtaPago=>nil, :emisor=>{:rfc=>"XAXX010101000", :nombre=>"Me cago en sus estándares S.A. de C.V.", :domicilioFiscal=>{:calle=>"Calle Feliz", :noExterior=>"42", :noInterior=>"314", :colonia=>"Centro", :localidad=>"No se que sea esto, pero va", :referencia=>"Sin Referencia", :municipio=>"Nutopía", :estado=>"Nutopía", :pais=>"Nutopía", :codigoPostal=>"31415"}, :expedidoEn=>{:calle=>"Calle Feliz", :noExterior=>"42", :noInterior=>nil, :colonia=>"Centro", :localidad=>"No se que sea esto, pero va", :referencia=>"Sin Referencia", :municipio=>"Nutopía", :estado=>"Nutopía", :pais=>"Nutopía", :codigoPostal=>"31415"}, :regimenFiscal=>"Pruebas Fiscales"}, :receptor=>{:rfc=>"XAXX010101000", :nombre=>"El SAT apesta S. de R.L.", :domicilioFiscal=>{:calle=>nil, :noExterior=>nil, :noInterior=>nil, :colonia=>nil, :localidad=>nil, :referencia=>"Sin Referencia", :municipio=>nil, :estado=>"Nutopía", :pais=>"Nutopía", :codigoPostal=>nil}, :expedidoEn=>nil, :regimenFiscal=>nil}, :conceptos=>[{:cantidad=>2, :unidad=>"Kilos", :noIdentificacion=>"KDV", :descripcion=>"Verga Ción", :valorUnitario=>5500.0, :importe=>11000.0}], :serie=>nil, :folio=>"1", :sello=>"igFu7Q9Z98n6xFSLMv7a2y8ZlJCO+pgTX3xDAUt5xSpX3dHOKXkTHBAf4P/oHHDm3xkYkaNBfPEzpVFDrRVjL2rvkR5T9rsFqb4cl6DOo4RrRIpSR9vojLp7mFWiON9H6OFPi2b9PVAnyIx1Skb5iGIAmSQIhVYyt2DSauObY2c=", :noCertificado=>"20001000000200000293", :certificado=>"MIIE2jCCA8KgAwIBAgIUMjAwMDEwMDAwMDAyMDAwMDAyOTMwDQYJKoZIhvcNAQEFBQAwggFcMRowGAYDVQQDDBFBLkMuIDIgZGUgcHJ1ZWJhczEvMC0GA1UECgwmU2VydmljaW8gZGUgQWRtaW5pc3RyYWNpw7NuIFRyaWJ1dGFyaWExODA2BgNVBAsML0FkbWluaXN0cmFjacOzbiBkZSBTZWd1cmlkYWQgZGUgbGEgSW5mb3JtYWNpw7NuMSkwJwYJKoZIhvcNAQkBFhphc2lzbmV0QHBydWViYXMuc2F0LmdvYi5teDEmMCQGA1UECQwdQXYuIEhpZGFsZ28gNzcsIENvbC4gR3VlcnJlcm8xDjAMBgNVBBEMBTA2MzAwMQswCQYDVQQGEwJNWDEZMBcGA1UECAwQRGlzdHJpdG8gRmVkZXJhbDESMBAGA1UEBwwJQ295b2Fjw6FuMTQwMgYJKoZIhvcNAQkCDCVSZXNwb25zYWJsZTogQXJhY2VsaSBHYW5kYXJhIEJhdXRpc3RhMB4XDTEyMTAyNjE5MjI0M1oXDTE2MTAyNjE5MjI0M1owggFTMUkwRwYDVQQDE0BBU09DSUFDSU9OIERFIEFHUklDVUxUT1JFUyBERUwgRElTVFJJVE8gREUgUklFR08gMDA0IERPTiBNQVJUSU4gMWEwXwYDVQQpE1hBU09DSUFDSU9OIERFIEFHUklDVUxUT1JFUyBERUwgRElTVFJJVE8gREUgUklFR08gMDA0IERPTiBNQVJUSU4gQ09BSFVJTEEgWSBOVUVWTyBMRU9OIEFDMUkwRwYDVQQKE0BBU09DSUFDSU9OIERFIEFHUklDVUxUT1JFUyBERUwgRElTVFJJVE8gREUgUklFR08gMDA0IERPTiBNQVJUSU4gMSUwIwYDVQQtExxBQUQ5OTA4MTRCUDcgLyBIRUdUNzYxMDAzNFMyMR4wHAYDVQQFExUgLyBIRUdUNzYxMDAzTURGUk5OMDkxETAPBgNVBAsTCFNlcnZpZG9yMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDlrI9loozd+UcW7YHtqJimQjzX9wHIUcc1KZyBBB8/5fZsgZ/smWS4Sd6HnPs9GSTtnTmM4bEgx28N3ulUshaaBEtZo3tsjwkBV/yVQ3SRyMDkqBA2NEjbcum+e/MdCMHiPI1eSGHEpdESt55a0S6N24PW732Xm3ZbGgOp1tht1wIDAQABox0wGzAMBgNVHRMBAf8EAjAAMAsGA1UdDwQEAwIGwDANBgkqhkiG9w0BAQUFAAOCAQEAuoPXe+BBIrmJn+IGeI+m97OlP3RC4Ct3amjGmZICbvhI9BTBLCL/PzQjjWBwU0MG8uK6e/gcB9f+klPiXhQTeI1YKzFtWrzctpNEJYo0KXMgvDiputKphQ324dP0nzkKUfXlRIzScJJCSgRw9ZifKWN0D9qTdkNkjk83ToPgwnldg5lzU62woXo4AKbcuabAYOVoC7owM5bfNuWJe566UzD6i5PFY15jYMzi1+ICriDItCv3S+JdqyrBrX3RloZhdyXqs2Htxfw4b1OcYboPCu4+9qM3OV02wyGKlGQMhfrXNwYyj8huxS1pHghEROM2Zs0paZUOy+6ajM+Xh0LX2w==", :complemento=>nil, :cancelada=>nil, :impuestos=>{:totalImpuestosTrasladados=>1760.0, :traslados=>[{:impuesto=>"IVA", :tasa=>16.0, :importe=>1760.0}]}}
    expect(comprobante.to_h).to eq returns
  end

  it "no debe de generar atributos vacios" do
    comprobante = CFDI.from_xml(File.read('./examples/data/cfdi.xml'))
    #el comprobante de XML no tiene numero de cuenta de pago
    expect(comprobante.to_xml).not_to match(/NumCtaPago/)

    #si quitamos referencia
    comprobante.emisor.domicilioFiscal.referencia = nil
    expect(comprobante.to_xml).not_to match(/DomicilioFiscal.+referencia/)
  end

  it "debe validar un Timbre Fiscal Digital" do
    comprobante = CFDI.from_xml(File.read('./examples/data/timbrado.xml'))
    cert = File.read('./examples/data/certPAC.cer')
    expect(comprobante.timbre_valido? cert).to be false
  end

end
