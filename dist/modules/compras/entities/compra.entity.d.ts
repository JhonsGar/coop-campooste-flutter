import { Socio } from '../../socios/entities/socio.entity';
export declare class Compra {
    id: number;
    socioId: number;
    socio: Socio;
    total: number;
    metodo_pago: string;
    estado: string;
    created_at: Date;
}
