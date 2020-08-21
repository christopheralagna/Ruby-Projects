
class Game
attr_accessor :board, :a1, :a2, :a3, :b1, :b2, :b3, :c1, :c2, :c3, :current_display_board, :player1, :player2

  CODED_DISPLAY_BOARD = {
    row_one:    "\n_a1_|_a2_|_a3_",
    row_two:    "_b1_|_b2_|_b3_",
    row_three:  " c1 | c2 | c3 \n\n",
  }

  def initialize()
    @board = {a1:'_', a2:'_', a3:'_', b1:'_', b2:'_', b3:'_', c1:' ', c2:' ', c3:' '}
    @a1 = board[:a1]
    @a2 = board[:a2]
    @a3 = board[:a3]
    @b1 = board[:b1]
    @b2 = board[:b2]
    @b3 = board[:b3]
    @c1 = board[:c1]
    @c2 = board[:c2]
    @c3 = board[:c3]
    @current_display_board = {
      row_one:   "_#{a1}_|_#{a2}_|_#{a3}_",
      row_two:   "_#{b1}_|_#{b2}_|_#{b3}_",
      row_three: " #{c1} | #{c2} | #{c3} \n",
    }
    @player1 = ''
    @player2 = ''
  end

  def new_game
    make_players()
    display_board()
    puts "\nType one of the codes displayed above to put your symbol in that position\n"
    your_turn(@player1)
  end

  def make_players
    puts "\nPlayer 1: type your name..."
    player1_name = gets.chomp
    puts "welcome #{player1_name}!\n\nPlayer 2: type your name..."
    player2_name = gets.chomp
    puts "welcome #{player2_name}!\n\n#{player1_name} will be X's\n#{player2_name} will be O's\n\n"

    @player1 = Player.new(player1_name, "X", true)
    @player2 = Player.new(player2_name, "O", false)
  end

  def your_turn(player)
    puts "\n#{player.name}: place your symbol"
    position = gets.chomp
    check_if_spot_available(position, player)
  end

  def update_player_status(position, player)
    position_codes = position.to_s.split('')
    if @player1.turn == true
      position_codes.each do |code|
        code = code.to_sym
        @player1.spaces_occupied[code] += 1
        if @player1.spaces_occupied[code] == 1
          @player1.total_collected_char += 1
        end
      end
    elsif @player2.turn == true
      position_codes.each do |code|
        code = code.to_sym 
        @player2.spaces_occupied[code] += 1
        if @player2.spaces_occupied[code] == 1
          @player2.total_collected_char += 1
        end
      end
    end
    check_game_status(player)
  end

  def check_if_spot_available(position, player)
    position = position.to_sym
    until board[position] == ' ' || board[position] == '_' do
      if board[position] == nil
        puts "\nplease enter a valid code"
        position = gets.chomp
        position = position.to_sym
      else
        puts "\nThat spot is not available, try again"
        position = gets.chomp 
        position = position.to_sym
      end
    end
    update_board(position, player)
  end

  def update_board(position, player)
    board[position] = player.symbol
    update_positions()
    display_board()
    puts "\nHere's the new board"
    update_player_status(position, player)
  end

  def update_positions
    @a1 = board[:a1]
    @a2 = board[:a2]
    @a3 = board[:a3]
    @b1 = board[:b1]
    @b2 = board[:b2]
    @b3 = board[:b3]
    @c1 = board[:c1]
    @c2 = board[:c2]
    @c3 = board[:c3]
    @current_display_board = {
      row_one:   "_#{a1}_|_#{a2}_|_#{a3}_",
      row_two:   "_#{b1}_|_#{b2}_|_#{b3}_",
      row_three: " #{c1} | #{c2} | #{c3} ",
    }
  end

  def display_board
    CODED_DISPLAY_BOARD.each { |row, content| puts content }
    @current_display_board.each { |row, content| puts content }
  end

  def check_game_status(player)
    if player.spaces_occupied.any? { |code, number| number == 3 } || player.total_collected_char == 6 
      display_winner(player)
    elsif @player1.turn == true
      @player1.turn = false
      @player2.turn = true
      your_turn(@player2)
    elsif @player2.turn == true
      @player2.turn = false
      @player1.turn = true
      your_turn(@player1)
    end
  end

  def display_winner(player)
    puts "\nYou Win #{player.name}! Congratulations!"
    puts "\nPlay again?"
    response = gets.chomp
    until response == 'yes' || response == 'no' do
      puts "\nplease type 'yes' or 'no'"
      response = gets.chomp
    end
    if response == 'yes'
      puts "\nAlright, New Game!\n"
      game = Game.new()
      game.new_game()
    else
      puts "\nThank you!"
    end
  end
end

class Player
  attr_accessor :name, :symbol, :turn, :spaces_occupied, :total_collected_char
	
  def initialize(name, symbol, turn)
    @name = name
    @symbol = symbol
    @turn = turn
    #If either player has 3 of any letter or number: then they win
    @spaces_occupied = {a:0, b:0, c:0, "1":0, "2":0, "3":0}
    #If either player has at least one of each a,b,c,1,2,3: then they win (cross win)
    @total_collected_char = 0
  end
end

game = Game.new()
game.new_game()
