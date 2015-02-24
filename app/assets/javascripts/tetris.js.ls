import prelude

class Tetris
  ->
    @canvas = document.getElementById "tetris" .getContext "2d"
    @numRows = 18
    @numCols = 10
    @grid = [[false for i from 1 to @numCols] for j from 1 to @numRows]
    @curPiece = @randomPiece!
    @piecePos = { r: 0, c: @numCols/2 - 1 }
    setInterval @step, 1000
    @bindKeys!
  pieces:
      [[1 1]
       [1 1]]
      [[1 0 0]
       [1 1 1]]
      [[0 1 1]
       [1 1 0]]
      [[0 1 0]
       [1 1 1]]
      [[1 1 1 1]]
  step: ~>
    @piecePos.r += 1
    if @is-colliding!
      @moveUp!
      @gluePiece!
    @draw!
  bindKeys: ->
    $ document .keydown (e) ~>
      switch e.which
        | 37 => @moveLeft!
        | 39 => @moveRight!
        | 40 => @moveDown!
        | 32 => @drop!
        | 38 => @curPiece = @rotateRight @curPiece
        |  _ => noKey = true
      unless noKey
        e.preventDefault!
        @draw!
  moveRight: -> @move { dc: +1 }
  moveLeft:  -> @move { dc: -1 }
  moveDown:  -> @move { dr: +1 }
  moveUp:    -> @move { dr: -1 } /* Not bound to a key */
  move: ({ dr || 0, dc || 0 }) ->
    { r, c } = @piecePos
    newPos = { nr, nc } = { r: r + dr, c: c + dc }
    console.log newPos
    if @on-board(newPos) && ! @is-colliding newPos
      @piecePos = newPos
    else false
  on-board: ({ r, c }) ->
    width = @curPiece[0].length
    height = @curPiece.length
    maxRow = @numRows - height
    maxCol = @numCols - width
    console.log r, c, maxRow, maxCol
    r >= 0 && r <= maxRow && c >= 0 && c <= maxCol
  drop: ->
    while @moveDown!
      /* Keep moving down until failure */
    @gluePiece!
  clear-rows: ->
    rows-to-clear = []
    for row, r in @grid
      console.log row
      console.log and-list row
      if and-list row
        rows-to-clear.push r
    rows-to-clear
      |> each @clear-row
  clear-row: (r) ~>
    @grid.splice r, 1
    @grid.unshift [0 for r from 1 to @numCols]
  is-colliding: (pos ? @piecePos)->
    | pos.r + @curPiece.length > @numRows
      then true
    | _ then
      for row, r in @curPiece
        for val, c in row
          return true if val && @grid[r + pos.r][c + pos.c]
  gluePiece: ->
    for row, r in @curPiece
      for val, c in row
       @grid[r + @piecePos.r][c + @piecePos.c] ||= val
    @clear-rows!
    @newPiece!
  newPiece: ->
    @curPiece = @randomPiece!
    @piecePos = { r: 0, c: Math.floor (@numCols - @curPiece[0].length)/2 }
  randomPiece: ->
    return @pieces[Math.floor(Math.random! * @pieces.length)]
  rotateLeft: (piece) ->
    maxRow = piece.length - 1
    maxCol = piece[0].length - 1
    return [[piece[r][c] for r from 0 to maxRow] for c from maxCol to 0 by -1]
  rotateRight: (piece) ->
    maxRow = piece.length - 1
    maxCol = piece[0].length - 1
    return [[piece[r][c] for r from maxRow to 0 by -1] for c from 0 to maxCol]
  printPiece: (piece) ->
    console.log ["\n> " + [piece[r][c] for col, c in row].join("") for row, r in piece].join("")
  draw: ~>
    @canvas.clearRect(0,0,@canvas.width,@canvas.width)
    @drawGrid!
    @drawPiece!
  drawSquare: ({r, c}, color) ->
    @canvas.fillStyle = color
    @canvas.fillRect(c*20, r*20, 19, 19)
  drawGrid: ->
    for row, r in @grid
      for val, c in row
        color = switch
          | @grid[r][c]  => "red"
          | !@grid[r][c] => "lightgray"
        @drawSquare({r: r, c: c}, color)
  drawPiece: (piece ? @curPiece) ->
    for row, dr in piece
      for col, dc in row
        color = switch
          | piece[dr][dc]  => "blue"
          | !piece[dr][dc] => "transparent"
        r = dr + @piecePos.r
        c = dc + @piecePos.c
        @drawSquare({r: r, c: c}, color)

$ ->
  t = new Tetris
  Window.piece = p = t.randomPiece()
  /*t.printPiece(p)
  t.printPiece(t.rotateRight(p))
  t.printPiece(t.rotateLeft(p))*/
  t.draw!
