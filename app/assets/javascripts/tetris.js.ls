import prelude

class Tetris
  ->
    @canvas = document.getElementById "tetris" .getContext "2d"
    @numRows = 18
    @numCols = 10
    @grid = [[0 for i from 1 to @numCols] for j from 1 to @numRows]
    @curPiece = @randomPiece!
    @piece-pos = { r: 0, c: @numCols/2 - 1 }
  start: ->
    setInterval @step, 1000
    @bindKeys!
    @draw!
  pieces:
      [[1 1]
       [1 1]]
      [[0 0 1]
       [1 1 1]]
      [[1 0 0]
       [1 1 1]]
      [[1 1 0]
       [0 1 1]]
      [[0 1 1]
       [1 1 0]]
      [[0 1 0]
       [1 1 1]]
      [[1 1 1 1]]
  step: ~>
    @piece-pos.r += 1
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
  moveRight: -> if @move { dc: +1 } => @piece-pos = that
  moveLeft:  -> if @move { dc: -1 } => @piece-pos = that
  moveDown:  -> if @move { dr: +1 } => @piece-pos = that
  moveUp:    -> if @move { dr: -1 } => @piece-pos = that /* Not bound to a key */
  move: ({ dr || 0, dc || 0 }, { r, c } = @piece-pos) ->
    newPos = { r: r + dr, c: c + dc }
    if @on-board(newPos) && ! @is-colliding newPos
      newPos
    else false
  on-board: ({ r, c }) ->
    width = @curPiece[0].length
    height = @curPiece.length
    maxRow = @numRows - height
    maxCol = @numCols - width
    r >= 0 && r <= maxRow && c >= 0 && c <= maxCol
  drop: ->
    while @moveDown! then;
    /* Loop until error is thrown */
    @gluePiece!
  clear-rows: ->
    rows-to-clear = []
    for row, r in @grid
      if and-list row
        rows-to-clear.push r
    rows-to-clear
      |> each @clear-row
  clear-row: (r) ~>
    @grid.splice r, 1
    @grid.unshift [0 for r from 1 to @numCols]
  is-colliding: (pos ? @piece-pos)->
    | pos.r + @curPiece.length > @numRows
      then true
    | _ then
      for row, r in @curPiece
        for val, c in row
          return true if val && @grid[r + pos.r][c + pos.c]
  gluePiece: ->
    for row, r in @curPiece
      for val, c in row
       @grid[r + @piece-pos.r][c + @piece-pos.c] ||= val
    @clear-rows!
    @newPiece!
    @checkLose!
  newPiece: ->
    @curPiece = @randomPiece!
    @piece-pos = { r: 0, c: Math.floor (@numCols - @curPiece[0].length)/2 }
  randomPiece: ->
    return @pieces[Math.floor(Math.random! * @pieces.length)]
  rotateLeft: (piece) ->
    maxRow = piece.length - 1
    maxCol = piece[0].length - 1
    return [[piece[r][c] for r from 0 to maxRow] for c from maxCol to 0 by -1]
  rotateRight: (piece) ->
    maxRow = piece.length - 1
    maxCol = piece[0].length - 1
    while piece.length + @piece-pos.c > @numCols
      @moveLeft!
    return [[piece[r][c] for r from maxRow to 0 by -1] for c from 0 to maxCol]
  draw: ~>
    @canvas.clearRect(0,0,@canvas.width,@canvas.width)
    @drawGrid!
    @drawPrediction!
    @drawPiece!
  drawSquare: ({r, c}, color) ->
    @canvas.fillStyle = color
    @canvas.fillRect(c*20, r*20, 20, 20)
  drawGrid: ->
    for row, r in @grid
      for val, c in row
        color = switch
          | @grid[r][c]  => "red"
          | !@grid[r][c] => "lightgray"
        @drawSquare({ r: r, c: c }, color)
  drawPiece: (pos ? @piece-pos, piece ? @curPiece, pieceColor ? "blue") ->
    for row, dr in piece
      for col, dc in row
        color = switch
          | piece[dr][dc]  => pieceColor
          | !piece[dr][dc] => "transparent"
        r = dr + pos.r
        c = dc + pos.c
        @drawSquare({r: r, c: c}, color)
  drawPrediction: ->
    pos = ^^@piece-pos
    while @move { dr: +1 }, pos
      pos = that
    @drawPiece pos, @curPiece, "orange"
  check-lose: ->
    if @is-lost!
      console.log("You lose :(")
  is-lost: ->
    @piecePos.r == 0 && @is-colliding!


$ ->
  t = new Tetris
  t.start!
