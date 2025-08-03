// Licencia
// SPDX-License-Identifier: GPL-3.0-or-later

// Version solidity

pragma solidity 0.8.24;

//Contrato

contract ControlDeAccesoEdificio {
    address public administrador;

    struct Persona {
        bool autorizada;
        string puesto;
    }

    struct RegistroAcceso {
        uint256 timestamp;
        bool esEntrada; // true = entrada, false = salida
    }

    mapping(address => Persona) public autorizados;
    mapping(address => RegistroAcceso[]) public historialAccesos;

    event AccesoRegistrado(address indexed persona, bool esEntrada, uint256 timestamp);
    event AutorizacionCambiada(address indexed persona, bool autorizada);

    constructor() {
        administrador = msg.sender;
    }

    modifier soloAdmin() {
        require(msg.sender == administrador, "Solo el administrador puede hacer esto");
        _;
    }

    modifier soloAutorizados() {
        require(autorizados[msg.sender].autorizada, "No estas autorizado");
        _;
    }

    function autorizarPersona(address _persona, string memory _oficio) public soloAdmin {
        autorizados[_persona] = Persona(true,_oficio);
        emit AutorizacionCambiada(_persona, true);
    }

    function revocarAutorizacion(address _persona, string memory _oficio) public soloAdmin {
        autorizados[_persona] = Persona(false, _oficio);
        emit AutorizacionCambiada(_persona, false);
    }

    function registrarEntrada() public soloAutorizados {
        historialAccesos[msg.sender].push(RegistroAcceso(block.timestamp, true));
        emit AccesoRegistrado(msg.sender, true, block.timestamp);
    }

    function registrarSalida() public soloAutorizados {
        historialAccesos[msg.sender].push(RegistroAcceso(block.timestamp, false));
        emit AccesoRegistrado(msg.sender, false, block.timestamp);
    }

    function obtenerHistorial(address _persona) public view returns (RegistroAcceso[] memory) {
        return historialAccesos[_persona];
    }
}