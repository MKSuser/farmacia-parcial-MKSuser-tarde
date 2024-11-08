
object farmaceutico{}
object farmacia{

	var property importeSolvencia = 300000
	const property medicamentos = []
	const property prepagasAceptadas = #{}
	const property nuevaOferta = true
	const property clientes = #{}

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

	method aceptarPrepaga(prepaga){
		prepagasAceptadas.add(prepaga)
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

	method prepagaClienteConveniente(cliente){
		return ((cliente.prepagaObraSocial().descuento()) >= 0.4) && (prepagasAceptadas.contains(cliente.prepagaObraSocial()))
	}

	method descuentoPrepagaObraSocial(cliente, medicamento){
		if (self.prepagaClienteConveniente(cliente)){
			return (cliente.prepagaObraSocial().calculoDescuento(medicamento))
		}else return 0
	}

	//No está en los cálculos, está comentado. Pero está.
	method calculoNuevaOferta(cliente, medicamento){
		if (nuevaOferta){
			return medicamento.precio() * 0.13
		}else return 0
	}

	method calculoDeVentaDeMedicamento(cliente, medicamento){
		return medicamento.precioVenta(cliente) - self.descuentoPrepagaObraSocial(cliente, medicamento) //- self.calculoNuevaOferta(cliente, medicamento)
	}

	method calculoDescuentoDeMedicamento(cliente, medicamento){
		return medicamento.sumaDescuentos(cliente) + self.descuentoPrepagaObraSocial(cliente, medicamento)// + self.calculoNuevaOferta(cliente, medicamento)
	}

	method aceptarTodasLasPrepagasDeLosClientes(){
		clientes.forEach({cliente => self.aceptarPrepaga(cliente.prepagaObraSocial())})
		
	}

}

class Medicamento{
	var property nombre
	var property generico
	var property precio
	var property oferta
	var property descuento
	var property ventaLibre

	method barato(){
		return true
	}

	method condicionDeVenta(cliente){
		if (cliente.className() == "farmacia.Cheto"){
			return (not cliente.aceptaOfertas() && (not oferta))
		}else return true
	}

	method descuento10(cliente){
		if (cliente.tieneMedioElectronico()){
			return precio * 0.1
		}else return 0
	}

	method sumaDescuentos(cliente){
		return self.descuento10(cliente)
	}

	method precioVenta(cliente){
		if (self.condicionDeVenta(cliente)){
			return precio - self.sumaDescuentos(cliente)
		}else self.error("No se le puede vender")
		
	}

	method nuevoPrecio(importe){
		precio = importe
	}
/*


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
	*/
}

class Potente inherits Medicamento(
	
	generico = false,
	oferta = false,
	descuento = false,
	ventaLibre = false){
	
	override method barato(){
		return false
	}

	method condicionDeVenta2(cliente){
		return farmacia.clienteSolvente(cliente)
	}

	override method sumaDescuentos(cliente){
		return super(cliente) * 0
	}

	override method precioVenta(cliente){
		if (self.condicionDeVenta(cliente) && self.condicionDeVenta2(cliente)){
			return precio - self.sumaDescuentos(cliente)
		}else self.error("No se le puede vender")
		
	}

/*
	override method puedeVenderseleA(cliente){
		return farmacia.clienteSolvente(cliente)
	}
	*/

}
class Comun inherits Medicamento(
	//generico se declara en al const
	oferta = true,
	descuento = true,
	ventaLibre = false){

	override method barato(){
		return generico
	}

	method descuento20generico(cliente){
		if ((farmacia.clienteModerno(cliente)) && (not farmacia.clienteSolvente(cliente) )){
			return precio * 0.2
		} else return 0
	}

	override method sumaDescuentos(cliente){
		return super(cliente) + self.descuento20generico(cliente)
	}

}

class Libre inherits Medicamento(
	//generico se declara en al const
	oferta = false,
	descuento = true,
	ventaLibre = true){
		
	override method barato(){
		return precio < 50000
	}

	method descuento15precio(cliente){
		if (precio >= 25000){
			return precio * 0.15
		} else return 0
	}

	override method sumaDescuentos(cliente){
		return super(cliente) + self.descuento15precio(cliente)
	}
	
}

class Cliente{

	var property nombre
	var property edad
	var property mediosDePago = []
	var property prepagaObraSocial
	var property aceptaOfertas
	var property aceptaGenericos

	method agregarMedioDePago(medio){
		mediosDePago.add(medio)
	}

	method sacartMedioDePago(medio){
		mediosDePago.remove(medio)
	}

	method dinero(){
		return mediosDePago.sum({medio => medio.importe()})
	}

	method tieneMedioElectronico(){
		return mediosDePago.any({medio => medio.electronico()})
	}

	method puntajeComercial(){
	}
}

class Cheto inherits Cliente(
	aceptaOfertas = false,
	aceptaGenericos = false){

	override method puntajeComercial(){
		return 1000
	}

}
class Rustico inherits Cliente(
	aceptaOfertas = true,
	aceptaGenericos = true){

	override method puntajeComercial(){
		return 10
	}
	
}
class JubiladoComun inherits Cliente(
	aceptaOfertas = true,
	aceptaGenericos = true){
	
	override method puntajeComercial(){
		return 30
	}
	//Atento con las ofertas

}

class JubiladoMinima inherits JubiladoComun(){

	override method puntajeComercial(){
		return (super() / 2) + 5
	} 

	method cambiaOferta(){
		return (self.puntajeComercial() < 25)

	}
}


class Prepaga{
	var property descuento

	method calculoDescuento(medicamento){
		if (not medicamento.ventaLibre()){
			return medicamento.precio() * descuento
		}else return 0

	}

}

class ObraSocial inherits Prepaga{

}
object omint inherits Prepaga(
	descuento = 0.42){}
object osde inherits Prepaga(
	descuento = 0.4){}
object pami inherits ObraSocial(
	descuento = 0.3){}


class MedioDePago{
	var property electronico
	var property importe
}
class Efectivo inherits MedioDePago(
	electronico = false){}

class Debito inherits MedioDePago(
	electronico = true){}
class Credito inherits MedioDePago(
	electronico = true){}