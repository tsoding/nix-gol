rec {
  inherit (builtins) length elemAt filter elem genList concatStringsSep trace;

  core = rec {
    nil = [];
    
    cons = first: second: {
      first = first;
      second = second;
    };

    drop = n : list :
      if n <= 0 || list == []
      then list
      else drop (n - 1) list.second;

    take = n : list :
      if n <= 0 || list == []
      then []
      else cons list.first (take (n - 1) list.second);

    fromNixList = nixList: let
      fromNixListImpl = i:
        if i < length nixList
          then cons (elemAt nixList i) (fromNixListImpl (i + 1))
          else nil;
      in fromNixListImpl 0;

    toNixList = list:
      if list == []
      then []
      else [ list.first ] ++ toNixList list.second;
  };

  initialState = [
    [0 1 0 0 0]
    [0 0 1 0 0]
    [1 1 1 0 0]
    [0 0 0 0 0]
    [0 0 0 0 0]
  ];
  
  insideOfState = state : { row, col } : let
    rowCount = length state;
    colCount = length (elemAt state 0);
  in 0 <= row && row < rowCount && 0 <= col && col < colCount;

  isCellAlive = state : { row, col } :
    elemAt (elemAt state row) col > 0;

  neighbors = state : { row, col }: let
    neighborCells = [
      { row = row - 1; col = col - 1; }
      { row = row - 1; col = col; }
      { row = row - 1; col = col + 1; }
      { row = row + 1; col = col - 1; }
      { row = row + 1; col = col; }
      { row = row + 1; col = col + 1; }
      { row = row; col = col + 1; }
      { row = row; col = col - 1; }
    ];
  in length (
    filter (isCellAlive state) (
      filter (insideOfState state) neighborCells
    )
  );

  nextCell = state : cell : let aliveNeighbors = neighbors state cell; in
    if isCellAlive state cell 
    then (if elem (neighbors state cell) [2 3] then 1 else 0)
    else (if neighbors state cell == 3 then 1 else 0);

  genState = state : f : let
    rowCount = length state;
    colCount = length (elemAt state 0);
  in map (row : genList (col : f { row = row; col = col; }) colCount) (genList (x : x) rowCount);

  stateAsString = state: "\n" +
    concatStringsSep "\n" (
      map (row : concatStringsSep "" (map toString row)) state
    );

  nextState = state : genState state (nextCell state);

  allStates = state : core.cons (stateAsString state) (allStates (nextState state));

  nStates = state : n : concatStringsSep "\n" (core.toNixList (core.take 10 (allStates state)));
}
