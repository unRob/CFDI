require_relative 'cfdi'
require 'json'
require 'time'

# el archivo .cer, tal cual
certificado = CFDI::Certificado.new './cfdi/examples/data/cert.cer'
# la llave en formato pem, porque no encontré como usar OpenSSL con llaves tipo PKCS8
# Esta se convierte de un archivo .key con:
# openssl pkcs8 -inform DER -in someKey.key -passin pass:somePassword -out key.pem
llave = CFDI::Key.new './cfdi/examples/data/key.pem', 'somePassword'

# Así instanciamos el comprobante nuevo
factura = CFDI::Comprobante.new ({
  folio: 1,
  serie: 'A',
  fecha: Time.now,
  formaDePago: 'PAGO EN UNA SOLA EXHIBICION',
  condicionesDePago: 'Sera marcada como pagada en cuanto el receptor haya cubierto el pago.',
  metodoDePago: 'Transferencia Bancaria',
  lugarExpedicion: 'Nutopia, Nutopia'
})

# Esto es un domicilio casi completo
domicilioEmisor = CFDI::Domicilio.new({
  calle: 'Calle Feliz',
  noExterior: '42',
  noInterior: '314',
  colonia: 'Centro',
  localidad: 'No se que sea esto, pero va',
  referencia: 'Sin Referencia',
  municipio: 'Nutopía',
  estado: 'Nutopía',
  pais: 'Nutopía',
  codigoPostal: '31415'
})

# y esto es una persona fiscal
factura.emisor = CFDI::Entidad.new({
  rfc: 'XAXX010101000',
  nombre: 'Me cago en sus estándares S.A. de C.V.',
  domicilioFiscal: domicilioEmisor,
  expedidoEn: domicilioEmisor,
  regimenFiscal: 'Pruebas Fiscales'
})

# misma mierda
domicilioReceptor = CFDI::Domicilio.new({
  referencia: 'Sin Referencia',
  estado: 'Nutopía',
  pais: 'Nutopía'
})
factura.receptor = CFDI::Entidad.new({rfc: 'XAXX010101000', nombre: 'El SAT apesta S. de R.L.', domicilioFiscal: domicilioReceptor})


# Así agregamos conceptos, en este caso, 2 Kg de Verga
factura.conceptos << CFDI::Concepto.new({
  cantidad: 2,
  unidad: 'Kilos',
  noIdentificacion: 'KDV',
  descripcion: 'Verga',
  valorUnitario:5500.00 #el importe se calcula solo
})

# Todavía no agarro bien el pedo sobre como salen los impuestos, pull request?
factura.impuestos << {impuesto: 'IVA'}

# Esto hace que se le agregue al comprobante el certificado y su número de serie (noCertificado)
certificado.certifica factura

# Para mandarla a un PAC, necesitamos sellarla, y esto lo hace agregando el sello
# La cadena original que generamos sólo tiene los datos que u
llave.sella factura

# Esto genera la factura como xml
puts factura.to_xml

# Esto nos da un hash con todo lo que pusimos
puts JSON.pretty_generate factura.to_h