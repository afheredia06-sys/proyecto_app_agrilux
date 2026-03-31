// lib/config/constants.dart — Equivalente a src/lib/constants.js

const String kWhatsApp = '51935211605';

class Cultivo {
  final String id, nombre, emoji, categoria;
  final List<String> variedades;
  const Cultivo({required this.id, required this.nombre, required this.emoji, required this.categoria, required this.variedades});
}

const kCultivos = [
  Cultivo(id:'papa',    nombre:'Papa',    emoji:'🥔', categoria:'basico',    variedades:['Yungay','Perricholi','Única','Canchán','Huayro','Peruanita']),
  Cultivo(id:'maiz',    nombre:'Maíz',    emoji:'🌽', categoria:'basico',    variedades:['Amarillo Duro','Blanco Urubamba','Morado','Choclo']),
  Cultivo(id:'arroz',   nombre:'Arroz',   emoji:'🌾', categoria:'basico',    variedades:['La Conquista','NIR','Ferrón','Superior','Extra']),
  Cultivo(id:'tomate',  nombre:'Tomate',  emoji:'🍅', categoria:'hortaliza', variedades:['Río Grande','Daniela','Cherry','Híbrido']),
  Cultivo(id:'cebolla', nombre:'Cebolla', emoji:'🧅', categoria:'hortaliza', variedades:['Roja Arequipeña','Blanca','Amarilla']),
  Cultivo(id:'lechuga', nombre:'Lechuga', emoji:'🥬', categoria:'hortaliza', variedades:['Saladinah','Batavia','Romana','Crespa']),
  Cultivo(id:'zanahoria',nombre:'Zanahoria',emoji:'🥕',categoria:'hortaliza',variedades:['Chantenay','Nantes','Danvers']),
  Cultivo(id:'palta',   nombre:'Palta',   emoji:'🥑', categoria:'frutal',    variedades:['Hass','Fuerte','Criolla','Ettinger']),
  Cultivo(id:'platano', nombre:'Plátano', emoji:'🍌', categoria:'frutal',    variedades:['Isla','Seda','Bellaco','Manzano']),
  Cultivo(id:'mango',   nombre:'Mango',   emoji:'🥭', categoria:'frutal',    variedades:['Kent','Edward','Haden','Tommy']),
  Cultivo(id:'naranja', nombre:'Naranja', emoji:'🍊', categoria:'frutal',    variedades:['Valencia','Navel','Criolla']),
  Cultivo(id:'cafe',    nombre:'Café',    emoji:'☕', categoria:'comercial', variedades:['Arábica','Catimor','Typica','Bourbon']),
  Cultivo(id:'cacao',   nombre:'Cacao',   emoji:'🍫', categoria:'comercial', variedades:['CCN-51','Criollo','Forastero','Trinitario']),
  Cultivo(id:'quinua',  nombre:'Quinua',  emoji:'🌱', categoria:'comercial', variedades:['Salcedo INIA','Blanca Junín','Pasankalla','Negra']),
  Cultivo(id:'aji',     nombre:'Ají',     emoji:'🌶️',categoria:'extra',     variedades:['Panca','Amarillo','Mirasol','Rocoto','Limo']),
];

class PrecioBase {
  final double min, max;
  final String unidad;
  const PrecioBase({required this.min, required this.max, required this.unidad});
}

const Map<String, PrecioBase> kPreciosBase = {
  'papa':      PrecioBase(min:0.80, max:1.50, unidad:'kg'),
  'maiz':      PrecioBase(min:0.60, max:1.20, unidad:'kg'),
  'arroz':     PrecioBase(min:1.80, max:2.80, unidad:'kg'),
  'tomate':    PrecioBase(min:0.80, max:2.00, unidad:'kg'),
  'cebolla':   PrecioBase(min:0.60, max:1.50, unidad:'kg'),
  'lechuga':   PrecioBase(min:0.50, max:1.20, unidad:'unidad'),
  'zanahoria': PrecioBase(min:0.70, max:1.50, unidad:'kg'),
  'palta':     PrecioBase(min:2.00, max:5.00, unidad:'kg'),
  'platano':   PrecioBase(min:0.80, max:2.00, unidad:'kg'),
  'mango':     PrecioBase(min:1.00, max:3.00, unidad:'kg'),
  'naranja':   PrecioBase(min:0.50, max:1.50, unidad:'kg'),
  'cafe':      PrecioBase(min:8.00, max:15.0, unidad:'kg'),
  'cacao':     PrecioBase(min:6.00, max:12.0, unidad:'kg'),
  'quinua':    PrecioBase(min:4.00, max:8.00, unidad:'kg'),
  'aji':       PrecioBase(min:1.50, max:5.00, unidad:'kg'),
};

class Insumo {
  final int id;
  final String cultivo, tipo, nombre;
  final bool certificada, disponible;
  final List<String> ubicaciones;
  const Insumo({required this.id, required this.cultivo, required this.tipo, required this.nombre, required this.certificada, required this.disponible, required this.ubicaciones});
}

const kInsumosDisponibles = [
  Insumo(id:1, cultivo:'papa',   tipo:'semilla',      nombre:'Semilla Papa Yungay',          certificada:true, disponible:true,  ubicaciones:['Cutervo','Cajamarca','Lima']),
  Insumo(id:2, cultivo:'papa',   tipo:'semilla',      nombre:'Semilla Papa Canchán',         certificada:true, disponible:true,  ubicaciones:['Cutervo','Cajamarca']),
  Insumo(id:3, cultivo:'maiz',   tipo:'semilla',      nombre:'Semilla Maíz Amarillo Duro',   certificada:true, disponible:true,  ubicaciones:['Cutervo','Lima']),
  Insumo(id:4, cultivo:'arroz',  tipo:'semilla',      nombre:'Semilla Arroz La Conquista',   certificada:true, disponible:false, ubicaciones:[]),
  Insumo(id:5, cultivo:'papa',   tipo:'fertilizante', nombre:'Guano de Isla',                certificada:true, disponible:true,  ubicaciones:['Cutervo','Cajamarca','Lima']),
  Insumo(id:6, cultivo:'papa',   tipo:'fungicida',    nombre:'Fungicida Cúprico',            certificada:true, disponible:true,  ubicaciones:['Cutervo','Lima']),
  Insumo(id:7, cultivo:'tomate', tipo:'semilla',      nombre:'Semilla Tomate Río Grande',    certificada:true, disponible:true,  ubicaciones:['Lima','Cajamarca']),
  Insumo(id:8, cultivo:'palta',  tipo:'semilla',      nombre:'Plantón Palta Hass',           certificada:true, disponible:true,  ubicaciones:['Lima']),
];
