"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ComprasService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const compra_entity_1 = require("./entities/compra.entity");
const detalle_compra_entity_1 = require("./entities/detalle-compra.entity");
const productos_service_1 = require("../productos/productos.service");
let ComprasService = class ComprasService {
    constructor(compraRepository, detalleRepository, productosService) {
        this.compraRepository = compraRepository;
        this.detalleRepository = detalleRepository;
        this.productosService = productosService;
    }
    async create(socioId, items, metodoPago) {
        let total = 0;
        const detalles = [];
        for (const item of items) {
            const producto = await this.productosService.findOne(item.productoId);
            if (producto.stock < item.cantidad) {
                throw new Error(`Stock insuficiente para ${producto.nombre}`);
            }
            const subtotal = producto.precio * item.cantidad;
            total += subtotal;
            detalles.push({
                productoId: producto.id,
                cantidad: item.cantidad,
                precioUnitario: producto.precio,
                subtotal,
            });
            await this.productosService.updateStock(producto.id, item.cantidad);
        }
        const compra = this.compraRepository.create({
            socioId,
            total,
            metodo_pago: metodoPago,
            estado: 'pendiente',
        });
        await this.compraRepository.save(compra);
        for (const detalle of detalles) {
            const detalleEntity = this.detalleRepository.create({
                compraId: compra.id,
                ...detalle,
            });
            await this.detalleRepository.save(detalleEntity);
        }
        return this.compraRepository.findOne({
            where: { id: compra.id },
            relations: ['socio'],
        });
    }
    async findMisCompras(socioId) {
        return this.compraRepository.find({
            where: { socioId },
            order: { created_at: 'DESC' },
        });
    }
};
exports.ComprasService = ComprasService;
exports.ComprasService = ComprasService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(compra_entity_1.Compra)),
    __param(1, (0, typeorm_1.InjectRepository)(detalle_compra_entity_1.DetalleCompra)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        productos_service_1.ProductosService])
], ComprasService);
//# sourceMappingURL=compras.service.js.map