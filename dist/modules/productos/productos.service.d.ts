import { Repository } from 'typeorm';
import { Producto } from './entities/producto.entity';
export declare class ProductosService {
    private productoRepository;
    constructor(productoRepository: Repository<Producto>);
    findAll(): Promise<Producto[]>;
    findOne(id: number): Promise<Producto>;
    updateStock(id: number, cantidad: number): Promise<void>;
}
