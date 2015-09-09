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
    expect(comprobante.to_h).to be_eql(defaults)
  end

  it "debe de poder settear defaults" do
    CFDI::Comprobante.configure({defaults: {version: '2.0'}})
    comprobante = CFDI::Comprobante.new
    expect(comprobante.version).to eq '2.0'
  end

  context 'conceptos' do
    it "empieza con una lista vacía e conceptos" do
      comprobante = CFDI::Comprobante.new
      expect(comprobante.conceptos).to be_empty
    end

    it "acepta un arreglo de hashes y agrega un concepto por cada hash a la lista de conceptos" do
      conceptos = [
        {cantidad: 1, unidad: 'Pieza', noIdentificacion: nil, descripcion: 'Un producto', valorUnitario: 432.23, importe: 432.23},
        {cantidad: 1, unidad: 'Pieza', noIdentificacion: nil, descripcion: 'Otro producto', valorUnitario: 234.43, importe: 324.43}
      ]
      comprobante = CFDI::Comprobante.new
      comprobante.conceptos = conceptos
      expect(comprobante.conceptos.size).to eq 2
      expect(comprobante.conceptos[0]).to be_a CFDI::Concepto
      expect(comprobante.conceptos[1]).to be_a CFDI::Concepto
    end

    it "acepta un arreglo de objetos Concepto y los agrega la lista de conceptos" do
      conceptos = [
        CFDI::Concepto.new(cantidad: 1, unidad: 'Pieza', noIdentificacion: nil, descripcion: 'Un producto', valorUnitario: 432.23, importe: 432.23),
        CFDI::Concepto.new(cantidad: 1, unidad: 'Pieza', noIdentificacion: nil, descripcion: 'Otro producto', valorUnitario: 234.43, importe: 324.43)
      ]
      comprobante = CFDI::Comprobante.new
      comprobante.conceptos = conceptos
      expect(comprobante.conceptos.size).to eq 2
      expect(comprobante.conceptos).to match_array conceptos
    end

    it "acepta un hash, construye un objeto Concepto con esa inforamación y lo agrega la lista de conceptos" do
      comprobante = CFDI::Comprobante.new
      comprobante.conceptos = {cantidad: 1, unidad: 'Pieza', noIdentificacion: nil, descripcion: 'Un producto', valorUnitario: 432.23, importe: 432.23}
      expect(comprobante.conceptos.size).to eq 1
      expect(comprobante.conceptos.first).to be_a CFDI::Concepto
    end

    it "acepta un objeto Concepto y lo agrega a la lista de conceptos" do
      concepto = CFDI::Concepto.new(cantidad: 1, unidad: 'Pieza', noIdentificacion: nil, descripcion: 'Un producto', valorUnitario: 432.23, importe: 432.23)
      comprobante = CFDI::Comprobante.new
      comprobante.conceptos = concepto
      expect(comprobante.conceptos).to include(concepto)
    end
  end # context conceptos

  describe '#cadena_original' do
    it "genera la cadena con domicilio fiscal" do
      comprobante = CFDI::Comprobante.new
      comprobante.version = '2.0'
      comprobante.fecha = Date.today
      comprobante.tipoDeComprobante = 'ingreso'
      comprobante.formaDePago = 'contado'
      comprobante.condicionesDePago = 'sd'
      comprobante.subTotal = 100.0
      comprobante.TipoCambio = 1
      comprobante.moneda = 'mxn'
      comprobante.total = 116.00
      comprobante.metodoDePago = 'efectivo'
      comprobante.lugarExpedicion = 'una ciudad'
      comprobante.NumCtaPago = '1234'
      comprobante.emisor = CFDI::Entidad.new rfc: 'AAAA111111AAA', domicilioFiscal: { calle: "Calle emisor", noExterior: "123", colonia: "Colonia receptor", localidad: "localidad receptor", municipio: "Municipio receptor", estado: "Estado receptor", pais: "Pais receptor", codigoPostal: "12345"}
      comprobante.receptor = CFDI::Entidad.new rfc: 'AAAA111111BBB', domicilioFiscal: { calle: "Calle receptor", noExterior: "123", colonia: "Colonia receptor", localidad: "localidad receptor", municipio: "Municipio receptor", estado: "Estado receptor", pais: "Pais receptor", codigoPostal: "12345" }
      comprobante.conceptos = [
        {cantidad: 1, unidad: 'Pieza', noIdentificacion: nil, descripcion: 'Un producto', valorUnitario: 432.23, importe: 432.23},
        {cantidad: 1, unidad: 'Pieza', noIdentificacion: nil, descripcion: 'Otro producto', valorUnitario: 234.43, importe: 324.43}
      ]
      comprobante.impuestos = [ { impuesto: "IVA" } ]

      expect(comprobante.cadena_original).to eq "||2.0|2015-09-09T00:00:00|ingreso|contado|sd|666.66|1|mxn|773.33|efectivo|una ciudad|1234|AAAA111111AAA|Calle emisor|123|Colonia receptor|localidad receptor|Municipio receptor|Estado receptor|Pais receptor|12345|AAAA111111BBB|Calle receptor|123|Colonia receptor|localidad receptor|Municipio receptor|Estado receptor|Pais receptor|12345|1|Pieza|Un producto|432.23|432.23|1|Pieza|Otro producto|234.43|234.43|IVA|16|106.67|106.67||"
    end

    it "genera la cadena sin domicilio fiscal si éste no existe" do
      comprobante = CFDI::Comprobante.new
      comprobante.version = '2.0'
      comprobante.fecha = Date.today
      comprobante.tipoDeComprobante = 'ingreso'
      comprobante.formaDePago = 'contado'
      comprobante.condicionesDePago = 'sd'
      comprobante.subTotal = 100.0
      comprobante.TipoCambio = 1
      comprobante.moneda = 'mxn'
      comprobante.total = 116.00
      comprobante.metodoDePago = 'efectivo'
      comprobante.lugarExpedicion = 'una ciudad'
      comprobante.NumCtaPago = '1234'
      comprobante.emisor = CFDI::Entidad.new rfc: 'AAAA111111AAA'
      comprobante.receptor = CFDI::Entidad.new rfc: 'AAAA111111BBB'
      comprobante.conceptos = [
        {cantidad: 1, unidad: 'Pieza', noIdentificacion: nil, descripcion: 'Un producto', valorUnitario: 432.23, importe: 432.23},
        {cantidad: 1, unidad: 'Pieza', noIdentificacion: nil, descripcion: 'Otro producto', valorUnitario: 234.43, importe: 324.43}
      ]
      comprobante.impuestos = [ { impuesto: "IVA" } ]

      expect(comprobante.cadena_original).to eq "||2.0|2015-09-09T00:00:00|ingreso|contado|sd|666.66|1|mxn|773.33|efectivo|una ciudad|1234|AAAA111111AAA|AAAA111111BBB|1|Pieza|Un producto|432.23|432.23|1|Pieza|Otro producto|234.43|234.43|IVA|16|106.67|106.67||"
    end

  end # describe #cadena_original

  it "debe de generar un comprobante desde XML" do
    comprobante = CFDI.from_xml(File.read('./examples/data/cfdi.xml'))
    returns = {:version=>"3.2", :fecha=>"2013-10-15T01:33:32", :tipoDeComprobante=>"ingreso", :formaDePago=>"PAGO EN UNA SOLA EXHIBICION", :condicionesDePago=>"Sera marcada como pagada en cuanto el receptor haya cubierto el pago.", :subTotal=>11000.0, :TipoCambio=>1, :moneda=>"pesos", :total=>12760.0, :metodoDePago=>"Transferencia Bancaria", :lugarExpedicion=>"Nutopia, Nutopia", :NumCtaPago=>nil, :emisor=>{:rfc=>"XAXX010101000", :nombre=>"Me cago en sus estándares S.A. de C.V.", :domicilioFiscal=>{:calle=>"Calle Feliz", :noExterior=>"42", :noInterior=>"314", :colonia=>"Centro", :localidad=>"No se que sea esto, pero va", :referencia=>"Sin Referencia", :municipio=>"Nutopía", :estado=>"Nutopía", :pais=>"Nutopía", :codigoPostal=>"31415"}, :expedidoEn=>{:calle=>"Calle Feliz", :noExterior=>"42", :noInterior=>nil, :colonia=>"Centro", :localidad=>"No se que sea esto, pero va", :referencia=>"Sin Referencia", :municipio=>"Nutopía", :estado=>"Nutopía", :pais=>"Nutopía", :codigoPostal=>"31415"}, :regimenFiscal=>"Pruebas Fiscales"}, :receptor=>{:rfc=>"XAXX010101000", :nombre=>"El SAT apesta S. de R.L.", :domicilioFiscal=>{:calle=>nil, :noExterior=>nil, :noInterior=>nil, :colonia=>nil, :localidad=>nil, :referencia=>"Sin Referencia", :municipio=>nil, :estado=>"Nutopía", :pais=>"Nutopía", :codigoPostal=>nil}, :expedidoEn=>nil, :regimenFiscal=>nil}, :conceptos=>[{:cantidad=>2, :unidad=>"Kilos", :noIdentificacion=>"KDV", :descripcion=>"Verga Ción", :valorUnitario=>5500.0, :importe=>11000.0}], :serie=>nil, :folio=>"1", :sello=>"igFu7Q9Z98n6xFSLMv7a2y8ZlJCO+pgTX3xDAUt5xSpX3dHOKXkTHBAf4P/oHHDm3xkYkaNBfPEzpVFDrRVjL2rvkR5T9rsFqb4cl6DOo4RrRIpSR9vojLp7mFWiON9H6OFPi2b9PVAnyIx1Skb5iGIAmSQIhVYyt2DSauObY2c=", :noCertificado=>"20001000000200000293", :certificado=>"MIIE2jCCA8KgAwIBAgIUMjAwMDEwMDAwMDAyMDAwMDAyOTMwDQYJKoZIhvcNAQEFBQAwggFcMRowGAYDVQQDDBFBLkMuIDIgZGUgcHJ1ZWJhczEvMC0GA1UECgwmU2VydmljaW8gZGUgQWRtaW5pc3RyYWNpw7NuIFRyaWJ1dGFyaWExODA2BgNVBAsML0FkbWluaXN0cmFjacOzbiBkZSBTZWd1cmlkYWQgZGUgbGEgSW5mb3JtYWNpw7NuMSkwJwYJKoZIhvcNAQkBFhphc2lzbmV0QHBydWViYXMuc2F0LmdvYi5teDEmMCQGA1UECQwdQXYuIEhpZGFsZ28gNzcsIENvbC4gR3VlcnJlcm8xDjAMBgNVBBEMBTA2MzAwMQswCQYDVQQGEwJNWDEZMBcGA1UECAwQRGlzdHJpdG8gRmVkZXJhbDESMBAGA1UEBwwJQ295b2Fjw6FuMTQwMgYJKoZIhvcNAQkCDCVSZXNwb25zYWJsZTogQXJhY2VsaSBHYW5kYXJhIEJhdXRpc3RhMB4XDTEyMTAyNjE5MjI0M1oXDTE2MTAyNjE5MjI0M1owggFTMUkwRwYDVQQDE0BBU09DSUFDSU9OIERFIEFHUklDVUxUT1JFUyBERUwgRElTVFJJVE8gREUgUklFR08gMDA0IERPTiBNQVJUSU4gMWEwXwYDVQQpE1hBU09DSUFDSU9OIERFIEFHUklDVUxUT1JFUyBERUwgRElTVFJJVE8gREUgUklFR08gMDA0IERPTiBNQVJUSU4gQ09BSFVJTEEgWSBOVUVWTyBMRU9OIEFDMUkwRwYDVQQKE0BBU09DSUFDSU9OIERFIEFHUklDVUxUT1JFUyBERUwgRElTVFJJVE8gREUgUklFR08gMDA0IERPTiBNQVJUSU4gMSUwIwYDVQQtExxBQUQ5OTA4MTRCUDcgLyBIRUdUNzYxMDAzNFMyMR4wHAYDVQQFExUgLyBIRUdUNzYxMDAzTURGUk5OMDkxETAPBgNVBAsTCFNlcnZpZG9yMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDlrI9loozd+UcW7YHtqJimQjzX9wHIUcc1KZyBBB8/5fZsgZ/smWS4Sd6HnPs9GSTtnTmM4bEgx28N3ulUshaaBEtZo3tsjwkBV/yVQ3SRyMDkqBA2NEjbcum+e/MdCMHiPI1eSGHEpdESt55a0S6N24PW732Xm3ZbGgOp1tht1wIDAQABox0wGzAMBgNVHRMBAf8EAjAAMAsGA1UdDwQEAwIGwDANBgkqhkiG9w0BAQUFAAOCAQEAuoPXe+BBIrmJn+IGeI+m97OlP3RC4Ct3amjGmZICbvhI9BTBLCL/PzQjjWBwU0MG8uK6e/gcB9f+klPiXhQTeI1YKzFtWrzctpNEJYo0KXMgvDiputKphQ324dP0nzkKUfXlRIzScJJCSgRw9ZifKWN0D9qTdkNkjk83ToPgwnldg5lzU62woXo4AKbcuabAYOVoC7owM5bfNuWJe566UzD6i5PFY15jYMzi1+ICriDItCv3S+JdqyrBrX3RloZhdyXqs2Htxfw4b1OcYboPCu4+9qM3OV02wyGKlGQMhfrXNwYyj8huxS1pHghEROM2Zs0paZUOy+6ajM+Xh0LX2w==", :complemento=>nil, :cancelada=>nil, :impuestos=>[{:impuesto=>"IVA"}]}
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
