import { SociosService } from './socios.service';
import { Socio } from './entities/socio.entity';
export declare class SociosController {
    private readonly sociosService;
    constructor(sociosService: SociosService);
    findAll(): Promise<Socio[]>;
    create(data: Partial<Socio>): Promise<Socio>;
    testDb(): Promise<{
        success: boolean;
        message: string;
        sociosCount: number;
        error?: undefined;
    } | {
        success: boolean;
        message: string;
        error: any;
        sociosCount?: undefined;
    }>;
}
