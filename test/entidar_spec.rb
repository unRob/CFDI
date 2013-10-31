require_relative '../lib/cfdi.rb'

describe CFDI::Entidad do

  it 'debe de crear domicilios desde hashes' do
    entidad = CFDI::Entidad.new({
      rfc: 'XAXX010101000',
      nombre: 'Mira un Salmón S.A. de C.V.',
      domicilioFiscal: {
        referencia: 'Sin Referencia',
        pais: 'México',
        estado: 'Nutopia'
      }
    })

    entidad.domicilioFiscal.should be_a CFDI::Domicilio
  end


end