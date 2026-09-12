import { Compra } from './compra.entity';
import { Producto } from '../../productos/entities/producto.entity';
export declare class DetalleCompra {
    id: number;
    compraId: number;
    compra: Compra;
    productoId: number;
    producto: Producto;
    cantidad: number;
    precioUnitario: number;
    subtotal: number;
}
