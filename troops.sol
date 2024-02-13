pragma solidity ^0.8.0;

contract Troops {
    struct Location {
        uint64 r;
        uint64 c;
    }
    struct Tile {
        uint64 numTroops;
        Location loc;
        address owner;
    }

    function move(
        Tile from,
        Tile to,
        uint64 amount
    ) 
        external 
        isOwnedBySender(from)
        sufficientTroops(from, amount) 
    {
        Tile memory updatedFrom = from;
        Tile memory updatedTo = to;
        if (to.owner == address(0)) {
            // Moving onto an unowned tile captures it
            updatedTo.owner = msg.sender;
            updatedTo.numTroops = amount;
        } else if (to.owner != msg.sender) {
            // Moving onto an enemy tile leads to a battle
            if (amount > to.numTroops) {
                // You conquer the enemy tile if you bring more troops than 
                // they currently have on there
                updatedTo.owner = msg.sender;
                updatedTo.numTroops = amount - to.numTroops;
            } else {
                // You do not conquer the enemy tile if you have less
                updatedTo.numTroops -= amount;
            }
        } else {
            // Moving onto an owned tile is additive
            updatedTo.numTroops += amount;
        }
        updatedFrom.numTroops -= amount;
        
        tiles.insert(updatedFrom);
        tiles.insert(updatedTo);
    }

    modifier isNeighbor(
        suint r1,
        suint c1,
        suint r2,
        suint c2
    ) {
        bool isVertNeighbor = (c1 == c2 && (r1 == r2 + 1 || r1 == r2 - 1));
        bool isHorizNeighbor = (r1 == r2 && (c1 == c2 + 1 || c1 == c2 - 1));
        require(
            isVertNeighbor || isHorizNeighbor,
            "Given points are not neighbors"
        );
        _;
    }

    modifier sufficientTroops(
        Tile memory t,
        uint64 amount
    ) {
        require(
            amount <= t.numTroops,
            "Insufficient number of troops at the tile"
        );
        _;
    }
}
}
