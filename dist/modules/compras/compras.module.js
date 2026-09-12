"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ComprasModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const compra_entity_1 = require("./entities/compra.entity");
const detalle_compra_entity_1 = require("./entities/detalle-compra.entity");
const compras_service_1 = require("./compras.service");
const compras_controller_1 = require("./compras.controller");
const productos_module_1 = require("../productos/productos.module");
let ComprasModule = class ComprasModule {
};
exports.ComprasModule = ComprasModule;
exports.ComprasModule = ComprasModule = __decorate([
    (0, common_1.Module)({
        imports: [typeorm_1.TypeOrmModule.forFeature([compra_entity_1.Compra, detalle_compra_entity_1.DetalleCompra]), productos_module_1.ProductosModule],
        controllers: [compras_controller_1.ComprasController],
        providers: [compras_service_1.ComprasService],
    })
], ComprasModule);
//# sourceMappingURL=compras.module.js.map