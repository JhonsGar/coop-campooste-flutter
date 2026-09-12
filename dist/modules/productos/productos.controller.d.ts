import { ProductosService } from './productos.service';
export declare class ProductosController {
    private readonly productosService;
    constructor(productosService: ProductosService);
    findAll(): Promise<import("./entities/producto.entity").Producto[]>;
    findOne(id: string): Promise<import("./entities/producto.entity").Producto>;
}
