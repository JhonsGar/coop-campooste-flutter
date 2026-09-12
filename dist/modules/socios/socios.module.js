"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SociosModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const socio_entity_1 = require("./entities/socio.entity");
const socios_service_1 = require("./socios.service");
const socios_controller_1 = require("./socios.controller");
let SociosModule = class SociosModule {
};
exports.SociosModule = SociosModule;
exports.SociosModule = SociosModule = __decorate([
    (0, common_1.Module)({
        imports: [typeorm_1.TypeOrmModule.forFeature([socio_entity_1.Socio])],
        controllers: [socios_controller_1.SociosController],
        providers: [socios_service_1.SociosService],
        exports: [socios_service_1.SociosService],
    })
], SociosModule);
//# sourceMappingURL=socios.module.js.map