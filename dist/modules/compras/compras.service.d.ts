import { Repository } from 'typeorm';
import { Compra } from './entities/compra.entity';
import { DetalleCompra } from './entities/detalle-compra.entity';
import { ProductosService } from '../productos/productos.service';
export declare class ComprasService {
    private compraRepository;
    private detalleRepository;
    private productosService;
    constructor(compraRepository: Repository<Compra>, detalleRepository: Repository<DetalleCompra>, productosService: ProductosService);
    create(socioId: number, items: any[], metodoPago: string): Promise<Compra>;
    findMisCompras(socioId: number): Promise<Compra[]>;
}
