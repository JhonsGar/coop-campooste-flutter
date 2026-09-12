import { ComprasService } from './compras.service';
export declare class ComprasController {
    private readonly comprasService;
    constructor(comprasService: ComprasService);
    create(req: any, body: {
        items: any[];
        metodo_pago: string;
    }): Promise<import("./entities/compra.entity").Compra>;
    misCompras(req: any): Promise<import("./entities/compra.entity").Compra[]>;
}
