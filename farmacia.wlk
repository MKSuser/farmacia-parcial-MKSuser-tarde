
object farmaceutico{}
object farmacia{
	const property clientes = []
	const property importeSolvencia = 300000
	const property medicamentos = []
	const property prepagasAceptadas = [osde,pami]

	method agregarCliente(cliente){
		clientes.add(cliente)
	}
	
	method borrarCliente(cliente){
		clientes.remove(cliente)
	}

	method agregarMedicamento(medicamento){
		medicamentos.add(medicamento)
	}
	
	method borrarMedicamento(medicamento){
		medicamentos.remove(medicamento)
	}


	method clienteSolvente(cliente){
		return ((cliente.dinero() > importeSolvencia) || (cliente.puntajeComercial() > 500))
	}

	method clienteModerno(cliente){
		return ((cliente.edad() < 40) && (cliente.tieneMedioElectronico()))
	}

	method imprimirClientes(){
		return clientes
	}

	method hayClientesModernos(){
		return clientes.any({cliente => self.clienteModerno(cliente)})

	}

	method obtenerClientesSegunPuntaje(puntaje){
		return clientes.filter({cliente => cliente.puntajeComercial() > puntaje}) // Ej1 --> 25
	}

	method listaClientesModernos(){
		return clientes.filter({cliente => self.clienteModerno(cliente)})
	}

	method obtenerPromedioEdad(){
		if (self.hayClientesModernos()){
		return (self.listaClientesModernos().map({cliente => cliente.edad()})).sum() / self.listaClientesModernos().size()
		}else self.error("No hay clientes modernos")
	}

	method clienteEsModernoYSolvente(cliente){
		return (self.clienteModerno(cliente) && self.clienteSolvente(cliente))
	}

	method listarMordenosYSolventes(){
		return clientes.filter({cliente => self.clienteEsModernoYSolvente(cliente)})
	}

	method nombresDeNodernosYSolventes(){
		return self.listarMordenosYSolventes().map({cliente => cliente.nombre()})
	}

	method medicamentosGenericos(){
		return medicamentos.filter({medicamento => medicamento.generico()})
	}

	method medicamentosEnOfertaYVentaLibre(){
		return medicamentos.filter({medicamento => ((medicamento.oferta()) && (medicamento.ventaLibre()))})
	}


	method todosLosMedicamentosGenericosSonBaratos(){
		return self.medicamentosGenericos().all({medicamento => medicamento.barato()})
	}

	method modosDePago(cliente){
		return cliente.mediosDePago()
	}

	method cuantoTieneCliente(cliente){
		return self.modosDePago(cliente).map({medio => medio.importe()}).sum()
	}

	method medicamentoEnOferta(medicamento){
		if (medicamentos.contains(medicamento)){
			return medicamento.oferta()
		} else self.error("No tenemos ese medicamento actualmente")
	}

	method medicamentoEsGenerico(medicamento){
				if (medicamentos.contains(medicamento)){
			return medicamento.generico()
		} else self.error("No tenemos ese medicamento actualmente")
	
	}
	method medicamentoEsBarato(medicamento){
				if (medicamentos.contains(medicamento)){
			return medicamento.barato()
		} else self.error("No tenemos ese medicamento actualmente")
	
	}

	//Dejo de poner el error
	method cuantoSaleSinDescuento(medicamento){
		return medicamento.precio()
	}

	//PENDIENTE
	method cambiarPrecioMedicamento(medicamento,importe){
		medicamento.nuevoPrecio(importe)
	}

	method prepagaAceptada(prepaga){
		return prepagasAceptadas.contains(prepaga)

	}

	method quitarPrepaga(prepaga){
		prepagasAceptadas.remove(prepaga)
	}

	method aceptaPrepagaCliente(cliente){
		return self.prepagasAceptadas().contains(cliente.prepagaObraSocial())
	}
}

class Medicamento{
	var property nombre = 0
	var property generico = false
	var property precio = 0
	var property oferta
	var property barato = true
	var property descuento = false
	var property ventaLibre = true

	method esBarato(){
		return barato
	}
	
	method nuevoPrecio(importe){
		precio = importe
	}

	method puedeVenderseleA(cliente){
		if (cliente.aceptaOfertas() && oferta){
			return true
		}else if ((not cliente.aceptaOfertas()) && (not oferta)) {
			return true
		} else return true
	}


	method ventaConOSinDescuento(cliente){ 
		if (cliente.tieneMedioElectronico()){
			return precio * 0.9
		}else return precio
	}

	method procedemosALaVenta(cliente){
		if (self.puedeVenderseleA(cliente)){
			self.ventaConOSinDescuento(cliente)
		} //else self.error ("No puede vendersele a cliente")
	}
}

class Potente inherits Medicamento(
	generico = false,
	barato = false,
	descuento = false,
	ventaLibre = false

){
	override method puedeVenderseleA(cliente){
		return farmacia.clienteSolvente(cliente)
	}


}
class Comun inherits Medicamento(
	ventaLibre = false
	){
	override method esBarato(){
		return generico
	}

	override method ventaConDescuento(cliente){ //VER ESTO POR LO DEL DESCUENTO
		if ((farmacia.clienteModerno(cliente)) && (not farmacia.clienteSolvente(cliente) )){
			precio *= 0.8
		}
	}
}

class Libre inherits Medicamento(
	ventaLibre = true
){
		
	override method esBarato(){
		return precio < 50000
	}

	override method ventaConDescuento(cliente){ //VER ESTO POR LO DEL DESCUENTO
		if (precio <=25000 ){
			precio *= 0.85
		}
	}

	
}

class Cliente{

	var property nombre = jorge
	var property edad = 23
	var property dinero = 0
	var property mediosDePago = []
	var property prepagaObraSocial
	var property puntajeComercial
	var property aceptaOfertas = false

	method agregarMedioDePago(medio){
		mediosDePago.add(medio)
	}

	method sacartMedioDePago(medio){
		mediosDePago.remove(medio)
	}

	method dineroDisponible(){
		dinero = mediosDePago.sum({medio => medio.importe()})
	}

	method tieneMedioElectronico(){
		return mediosDePago.any({medio => medio.electronico()})
	}
}

class Cheto inherits Cliente(
	puntajeComercial = 1000,
	aceptaOfertas = false

){

}
class Rustico inherits Cliente(
	puntajeComercial = 10,
	aceptaOfertas = true
){
	

}
class JubiladoComun inherits Cliente(
	puntajeComercial = 30,
	aceptaOfertas = false
){
	//Atento con las ofertas

}

class JubiladoMinima inherits JubiladoComun(
	puntajeComercial = (30 / 2) + 5

){
	method cambiaOferta(){
		return (puntajeComercial < 25)

	}
}



class PrepagaObraSocial{
	var property esConveniente = false
	var property descuento = 0

	method esConvenieteParaFarmacia(){
		esConveniente = (descuento >= 40)
	}


}
object osde inherits PrepagaObraSocial(
	descuento = 0.4
){
}
object pami inherits PrepagaObraSocial(){
}
class MedioDePago{
	var property electronico = false
	var property importe
}

class Efectivo inherits MedioDePago(){

}

class Debito inherits MedioDePago(
	electronico = true
){

}
class Credito inherits MedioDePago(
	electronico = true
){}