import { Repository } from 'typeorm';
import { Socio } from './entities/socio.entity';
export declare class SociosService {
    private socioRepository;
    constructor(socioRepository: Repository<Socio>);
    findAll(): Promise<Socio[]>;
    findByCedula(cedula: string): Promise<Socio | null>;
    create(data: Partial<Socio>): Promise<Socio>;
}
