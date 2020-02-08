//
//  Game.swift
//  Zombies
//
//  Created by Adrian Tineo on 05.02.20.
//  Copyright © 2020 Adrian Tineo. All rights reserved.
//

import Foundation

enum Direction {
    case up
    case down
    case left
    case right
}

struct Game {
    private var grid: [[String]]
    
    // available chars are:
    // ⬜️ = ground
    // ⬛️ = darkness
    // 🚶‍♂️ = player
    // 🧟 = zombie
    // 🆘 = exit
    // 🚧 = obstacle (optional)
    // 🔦 = flashlight (optional)
    
    // MARK : initializer
    init() {
        grid = [["🆘", "⬜️", "⬜️", "⬜️", "⬜️"],
                ["⬜️", "⬜️", "⬜️", "⬜️", "⬜️"],
                ["⬜️", "⬜️", "⬜️", "⬜️", "⬜️"],
                ["⬜️", "⬜️", "⬜️", "⬜️", "⬜️"],
                ["⬜️", "⬜️", "⬜️", "⬜️", "🚶‍♂️"]]
        
        placeZombies()
    }
    
    // MARK: private methods
    private mutating func placeZombies() {
        // TODO: place zombies according to given rules
        
        // Creo una variable para llevar la cuenta de los zombies que coloco
        var numberOfZombies = 0
        
        // Hasta que no tenga dos zombies colocados sigo repitiendo el bucle
        while numberOfZombies < 2 {
            // Genero un numero x e y aleatorio para calcular la posicion en la que coloco el zombie dentro de la matriz
            let x = Int.random(in: 0...4)
            let y = Int.random(in: 0...4)
            
            // Compruebo de que las posiciones x e y no es una posicion contigua a las casillas de salida y meta, en el caso de que no esten, llamo la funcion updateSquare para colocar al zombie e incremento el numero de zombies colocados en uno
            if !((x == 0 || x == 1) && (y == 0 || y == 1)) && !((x == 3 || x == 4) && (y == 3 || y == 4)) {
                // Compruebo que la posicion del zombie no es la misma que la del primer zombie colocado
                if grid[x][y] != "🧟" {
                    updateSquare(x, y, "🧟")
                    numberOfZombies += 1
                }
            }
            
        }
        
    }
    
    private var playerPosition: (Int, Int) {
        for (x, row) in grid.enumerated() {
            for (y, square) in row.enumerated() {
                if square == "🚶‍♂️" {
                    return (x, y)
                }
            }
        }
        fatalError("We lost the player!")
    }
    
    private mutating func updateSquare(_ x: Int, _ y: Int, _ content: String) {
        // FIXME: this can crash
        // Comprobamos que x e y esten en un rango valido
        guard x >= 0 && x <= 4 && y >= 0 && y <= 4 else { return }
        grid[x][y] = content
    }

    // MARK: public API
    mutating func movePlayer(_ direction: Direction) {
        precondition(canPlayerMove(direction))
        
        // move player
        let (x, y) = playerPosition
        updateSquare(x, y, "⬜️")
        switch direction {
        case .up:
            updateSquare(x-1, y, "🚶‍♂️")
        case .down:
            updateSquare(x+1, y, "🚶‍♂️")
        case .left:
            updateSquare(x, y-1, "🚶‍♂️")
        case .right:
            updateSquare(x, y+1, "🚶‍♂️")
        }
     }
    
    func canPlayerMove(_ direction: Direction) -> Bool {
        // FIXME: this is buggy
        let (x, y) = playerPosition
        // El error es debido a que las comprobaciones de los cases son erroneas
        switch direction {
        case .up: return x != 0
        case .left: return y != 0
        case .right: return y != 4
        case .down: return x != 4
        }
    }
    
    var visibleGrid: [[String]] {
        // TODO: give a grid where only visible squares are copied, the rest
        // should be seen as ⬛️
        
        // Creo el array que va a ser visible en la pantalla del ipad
        var visibleGrid: [[String]] = grid
        
        // Calculo las posiciones contiguas al jugador
        let upPosition = (playerPosition.0 + 1, playerPosition.1)
        let downPosition = (playerPosition.0 - 1, playerPosition.1)
        let rightPosition = (playerPosition.0, playerPosition.1 + 1)
        let leftPosition = (playerPosition.0, playerPosition.1 - 1)
        
        // Recorro con un bucle el array grid para generar un array de la misma longitud, que es el que va a mostrarse en la pantalla del ipad
        for (x, row) in grid.enumerated() {
            for (y, _) in row.enumerated() {
                // En la primera poscion del array que genero coloco el simbolo de la salida
                if  (x, y) == (0, 0) {
                    visibleGrid[x][y] = "🆘"
                }
                // En la misma posicion en la que se encuentra el jugador en el array grid, coloco el simbolo del jugador
                else if (x, y) == playerPosition {
                    visibleGrid[x][y] = "🚶‍♂️"
                }
                // En las posiciones contiguas al jugador, coloco el simbolo de una casilla iluminada, en el caso de que en esa posicion en el array grid no haya un zombie, si hay un zombie, coloco el simbolo del zombie
                else if (x, y) == upPosition ||
                    (x, y) == downPosition ||
                    (x, y) == rightPosition ||
                    (x, y) == leftPosition {
                    if grid[x][y] == "🧟" {
                      visibleGrid[x][y] = "🧟"
                    } else {
                       visibleGrid[x][y] = "⬜️"
                    }
                }
                // Para todos los demas casos, coloco el simbolo de que la casilla no esta iluminada
                else {
                    visibleGrid[x][y] = "⬛️"
                }
            }
        }

        return visibleGrid
    }
    
    var hasWon: Bool {
        // FIXME: player cannot win, why?
        // El error es debido a que la condicion de victoria es que el jugador tiene que estar en las dos casillas contiguas a la salida ya que se utiliza && cuando debe de utilizarse || para que el jugador gane cuando este en una de las casillas contiguas a la salida
        return grid[0][1] == "🚶‍♂️" || grid[1][0] == "🚶‍♂️"
    }
    
    var hasLost: Bool {
        // TODO: calculate when player has lost (when revealing a zombie)
        
        // Genero una variable que voy a devolver true si me encuentro un zombie y false en el caso contrario
        var isLost = false
        
        // Recorro el array visibleGrid que es el que se muestra en la pantalla del ipad, en el caso que que el valor de alguna posicion del array sea el icono del zombie, pongo el valor de la variable isLost a true
        for (_, row) in visibleGrid.enumerated() {
            for (_, square) in row.enumerated() {
                if square == "🧟" {
                    isLost = true
                }
            }
        }
        
        // Devuelvo el valor de isLost
        return isLost
    }

}
