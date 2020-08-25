
=begin

CONTENTS...

module SharedGameMethods; end

module Mastermind
  class GameType1; end
  class GameType2; end
end

module Player
  class PlayerGuesser; end
  class PlayerSetter; end
end

module Computer
  class ComputerSetter; end
  class ComputerGuesser; end
end

=end

require 'pry'

module SharedGameMethods

  def new_round(guesser, setter_selection)
    guessed_colors = guesser.get_guesses(@possible_colors)
    determine_guess_accuracy(guessed_colors, setter_selection)
    update_score(guesser)
    unless @correct_guesses.all? { |guess| guess == 'O' }
      update_guess_count()
      if @player1.role == "guesser"
        return_hints(guessed_colors)
      end
    end
    game_status(guesser, setter_selection)
  end

  def determine_guess_accuracy(guessed_colors, colors_selected_by_setter) 
    guessed_colors.each_with_index do |color, i| 
      if color == colors_selected_by_setter[i]
        @correct_guesses[i] = 'O'
      else
        @remaining_colors.push(colors_selected_by_setter[i])
      end
    end
    puts "\nHere are the results for this round:"
    puts "#{@correct_guesses.join(' ')}   <-- 'O' represents a correct guess\n\n"
    sleep(2)
  end

  def update_score(guesser) 
    guesser.number_of_correct_guesses =  @correct_guesses.reduce(0) do |score, guess|
      if guess == 'O'
        score + 1
      else score
      end
    end
  end

  def update_guess_count()
    @current_number_of_guesses += 1
  end

  def game_status(guesser, setter_selection)
    if @current_number_of_guesses == @allowed_number_of_guesses && @player1.role == "guesser"
      puts "\nYou are out of guesses..."
      winner(false)
    elsif @current_number_of_guesses == @allowed_number_of_guesses && @player1.role == "setter"
      puts "\nThe computer is out of guesses..."
      winner(true)
    elsif @correct_guesses.all? { |guess| guess == 'O'} && @player1.role == "guesser"
      puts "\nYou have guessed all colors correctly within #{@allowed_number_of_guesses} attempts..."
      winner(true)
    elsif @correct_guesses.all? { |guess| guess == 'O'} && @player1.role == "setter"
      puts "\nThe computer has guessed all colors correctly within #{@allowed_number_of_guesses} attempts..."
      winner(false)
    else
      puts "\nThere are #{@allowed_number_of_guesses - @current_number_of_guesses} guesses left..."
      @correct_guesses = Array.new(@possible_colors.length, '_')
      sleep(1)
      new_round(guesser, setter_selection)
    end
  end

  def winner(outcome)
    puts outcome ? "\nYou Win!\n" : "\nYou Lose!\n"
  end

end

module Mastermind
  class GameType1
  include SharedGameMethods
  attr_accessor :current_number_of_guesses, :allowed_number_of_guesses, :possible_colors, :colors_selected_by_computer, :correct_guesses, :colors_in_wrong_position, :remaining_colors, :player1, :computer

    def initialize(allowed_number_of_guesses, possible_colors)
      @current_number_of_guesses = 0
      @allowed_number_of_guesses = allowed_number_of_guesses
      @possible_colors = possible_colors
      @colors_selected_by_computer = []
      @correct_guesses = Array.new(@possible_colors.length, '_')
      @colors_in_wrong_position = 0
      @remaining_colors = []
      @player1 = Player::PlayerGuesser.new()
      @computer = Computer::ComputerSetter.new()
    end

    def start_game_type_one()
      puts "\nIn this instance, you will be the guesser, and the computer will be the setter"
      sleep(3)
      puts "\nThere are #{@possible_colors.length} possible colors: #{@possible_colors.join(' ')}"
      puts "The computer will set #{@possible_colors.length} colors in a particular order, which you will have to guess!"
      puts "#{@correct_guesses.join(' ')}   <-- 'O' represents a correct guess"
      sleep(3)
      puts "\nYou have #{@allowed_number_of_guesses} tries to guess the secret color code!"
      @colors_selected_by_computer = @computer.set_computer_colors(@possible_colors)
      new_round(@player1, @colors_selected_by_computer)
    end
  
    def return_hints(guessed_colors)
      puts "Here are your following hints..."
      sleep(2)
      @correct_guesses.each_with_index do |guess, i|
        if guess == "_" && @remaining_colors.include?(@player1.guessed_colors[i])
          puts "\tYour guess of Position #{i + 1} (#{@player1.guessed_colors[i]}) is in the wrong position"
          @colors_in_wrong_position += 1
        end
      end
      if @colors_in_wrong_position == 0
        puts "\tNone of your other selected colors were present in the computer's list"
      end
      @colors_in_wrong_position = 0
      @player1.guessed_colors = []
      @remaining_colors = []
      sleep(2)
    end

  end

  class GameType2
  include SharedGameMethods
  attr_accessor :current_number_of_guesses, :allowed_number_of_guesses, :possible_colors, :colors_selected_by_player, :correct_guesses, :colors_in_wrong_position, :remaining_colors, :player1, :computer

    def initialize(allowed_number_of_guesses, possible_colors)
      @current_number_of_guesses = 0
      @allowed_number_of_guesses = allowed_number_of_guesses
      @possible_colors = possible_colors
      @colors_selected_by_player = []
      @correct_guesses = Array.new(@possible_colors.length, '_')
      @colors_in_wrong_position = 0
      @remaining_colors = []
      @player1 = Player::PlayerSetter.new()
      @computer = Computer::ComputerGuesser.new()
    end

    def start_game_type_two()
      puts "\nIn this instance, you will be the setter, and the computer will be the guesser"
      sleep(3)
      puts "\nThere are #{@possible_colors.length} possible colors: #{@possible_colors.join(' ')}"
      puts "You will set #{@possible_colors.length} colors in a particular order, which the computer will have to guess!"
      sleep(3)
      puts "\nThe computer will have #{@allowed_number_of_guesses} tries to guess the secret color code!"
      @colors_selected_by_player = @player1.set_player_colors(@possible_colors)
      new_round(@computer, @colors_selected_by_player)
    end

  end
end

module Player
  class PlayerGuesser
  attr_accessor :number_of_correct_guesses, :guessed_colors, :incorrect_guesses, :role

    def initialize()
      @number_of_correct_guesses = 0
      @guessed_colors = []
      @incorrect_guesses = []
      @role = "guesser"
    end

    def get_guesses(possible_colors)
      puts "\nSelect #{possible_colors.length} colors, one at a time..."
      possible_colors.length.times do
        puts "\nPlease select a color..."
        selection = gets.chomp
        until possible_colors.any? { |color| color == selection }
          puts "\nPlease select a VALID color"
          selection = gets.chomp
        end
        @guessed_colors.push(selection)
      end
      puts "\nHere are the colors you guessed: [#{@guessed_colors.join(' ')}]"
      sleep(3)
      return @guessed_colors
    end

  end

  class PlayerSetter
  attr_accessor :set_colors, :role

    def initialize()
      @set_colors = []
      role = "setter"
    end

    def set_player_colors(possible_colors)
      puts "Select #{possible_colors.length} colors, one at a time..."
      possible_colors.length.times do
        puts "\nPlease select a color..."
        selection = gets.chomp
        until possible_colors.any? { |color| color == selection }
          puts "\nPlease select a VALID color"
          selection = gets.chomp
        end
        @set_colors.push(selection)
      end
      puts "\nHere are the colors you selected: [#{@set_colors.join(' ')}]"
      sleep(3)
      return @set_colors
    end
  end
end

module Computer
  class ComputerSetter
  attr_accessor :set_colors

    def initialize()
      @set_colors = []
    end

    def set_computer_colors(possible_colors) 
      possible_colors.length.times do
        @set_colors.push(possible_colors[rand(possible_colors.length)])
      end
      return @set_colors
    end

  end

  class ComputerGuesser
  attr_accessor :number_of_correct_guesses, :guessed_colors, :incorrect_guesses

    def initialize()
      @number_of_correct_guesses = 0
      @guessed_colors = []
      @incorrect_guesses = []
    end

    def get_guesses(correct_guesses)
      puts "The computer is thinking..."
      sleep(2)
      correct_guesses.each_with_index do |guess, i|
        if guess == 'O'
          @guessed_colors.push('O')
        elsif guess == '_'
          @guessed_colors.push(get_random_color())
        end
      end
    end

    def get_random_color()
      return @possible_colors[rand(@possible_colors.length)]
    end

  end
end

def choose_game_type()
  puts "\n\n\nWelcome to Mastermind!"
  puts "\nWould you prefer to be the guesser or the setter?"
  response = gets.chomp()
  until response == "guesser" || response == "setter"
    puts "\nPlease select a valid game type..."
    response = gets.chomp()
  end
  if response == "guesser"
    return "guesser"
  elsif response == "setter"
    return "setter"
  end
end

possible_colors = ['red', 'blue', 'yellow', 'green', 'orange', 'pink']
allowed_number_of_guesses = 5

game_type = choose_game_type()
if game_type == "guesser"
  new_game = Mastermind::GameType1.new(allowed_number_of_guesses, possible_colors)
  new_game.start_game_type_one()
elsif game_type == "setter"
  new_game = Mastermind::GameType2.new(allowed_number_of_guesses, possible_colors)
  new_game.start_game_type_two()
end
