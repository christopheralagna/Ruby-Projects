
require 'pry'

class Mastermind
  attr_accessor :current_number_of_guesses, :allowed_number_of_guesses, :possible_colors, :colors_selected_by_computer, :correct_guesses, :colors_in_wrong_position, :remaining_colors, :game_types
  @@current_number_of_guesses = 0

  def initialize(allowed_number_of_guesses)
    @allowed_number_of_guesses = allowed_number_of_guesses
    @possible_colors = ['red', 'blue', 'yellow', 'green', 'orange', 'pink']
    @colors_selected_by_computer = []
    @correct_guesses = Array.new(@possible_colors.length, '_')
    @colors_in_wrong_position = 0
    @remaining_colors = []
    @player1 = Player.new()
    @game_types = ["guesser", "setter"]
  end

  def choose_game_type()
    puts "\n\n\nWelcome to Mastermind!"
    puts "\nWould you prefer to be the guesser or the master?"
    response = gets.chomp()
    until @game_types.any? == response
      puts "\nPlease select a valid game type..."
      response = gets.chomp()
    end
    if response == "guesser"
      return "guesser"
    elsif response == "setter"
      return "setter"
    end
  end

  def welcome_game_type_one()
    puts "\nIn this instance, you will be the guesser, and the computer will be the creator"
    sleep(3)
    puts "\nThere are #{@possible_colors.length} possible colors, and #{@possible_colors.length} colors to guess in the right order"
    puts "#{@correct_guesses.join(' ')}   <-- 'O' represents a correct guess"
    sleep(3)
    puts "\nYou have #{@allowed_number_of_guesses} tries to guess the secret color code!"
    new_round()
  end

  def new_round()
    guessed_colors = guess_colors()
    determine_guess_accuracy(guessed_colors)
    update_score()
    unless @correct_guesses.all? { |guess| guess == 'O' }
      update_guess_count()
      return_hints(guessed_colors)
      game_status()
    else winner(true)
    end
  end
  
  def get_computer_colors() 
    computer = Computer.new(@possible_colors)
    @colors_selected_by_computer = computer.random_color_select()
  end

  def guess_colors()
    @possible_colors.length.times do
      puts "\nPlease select a color..."
      selection = gets.chomp
      until @possible_colors.any? { |color| color == selection }
        puts "\nPlease select a VALID color"
        selection = gets.chomp
      end
      @player1.guessed_colors.push(selection)
    end
    guessed_colors = @player1.guessed_colors
    puts "\nHere are the colors you guessed: [#{guessed_colors.join(' ')}]"
    sleep(3)
    return guessed_colors
  end

  def determine_guess_accuracy(guessed_colors) 
    guessed_colors.each_with_index do |color, i| 
      if color == @colors_selected_by_computer[i]
        @correct_guesses[i] = 'O'
      else
        @remaining_colors.push(@colors_selected_by_computer[i])
      end
    end
    puts "\nHere are your results for this round:"
    puts "#{@correct_guesses.join(' ')}   <-- 'O' represents a correct guess\n\n"
    sleep(3)
  end
  
  def update_score() 
    @player1.number_of_correct_guesses =  @correct_guesses.reduce(0) do |score, guess|
      if guess == 'O'
        score + 1
      else score
      end
    end
  end

  def update_guess_count()
    @@current_number_of_guesses += 1
  end

  def return_hints(guessed_colors)
    puts "Here are your following hints..."
    sleep(2)
    correct_guesses.each_with_index do |guess, i|
      if guess == "_" && @remaining_colors.include?(@player1.guessed_colors[i])
        puts "\tYour guess for Position #{i + 1} (#{@player1.guessed_colors[i]}) is in the wrong position"
        @colors_in_wrong_position += 1
        sleep(2)
      end
    end
    if @colors_in_wrong_position == 0
      puts "\tNone of your other selected colors were present in the computer's list"
      sleep(3)
    end
    @colors_in_wrong_position = 0
    @player1.guessed_colors = []
    @remaining_colors = []
  end

  def game_status()
    if @@current_number_of_guesses == @allowed_number_of_guesses 
      winner(false)
    else
      puts "\nYou have #{@allowed_number_of_guesses - @@current_number_of_guesses} guesses left..."
      @correct_guesses = Array.new(@possible_colors.length, '_')
      sleep(1)
      new_round()
    end
  end

  def winner(outcome)
    puts outcome ? "You Win!" : "\nYou are out of tries! You Lose!\n"
  end

end


class Player
attr_accessor :number_of_correct_guesses, :guessed_colors, :incorrect_guesses

  def initialize()
    @number_of_correct_guesses = 0
    @guessed_colors = []
    @incorrect_guesses = []
  end

end


class Computer
attr_accessor :possible_colors

  def initialize(possible_colors)
    @possible_colors = possible_colors
    @new_guesses = Array.new(@possible_colors.length, '_')
  end

  def random_color_select() 
    random_colors = []
    @possible_colors.length.times do
      random_colors.push(@possible_colors[rand(@possible_colors.length)])
    end
    return random_colors
  end

  def get_random_color()
    return @possible_colors[rand(@possible_colors.length)]
  end

  def get_computer_guesses()
    @new_guesses.each_with_index do |guess, i|
      if @correct_guesses[i] == 'O'
        guess = 'O'
      elsif @correct_guesses[i] == '_'
        guess = get_random_color()
      end
    return @new_guesses
  end

end

module GameTypeComputerGuess
  
end

new_game = Mastermind.new(12)
game_type = new_game.choose_game_type
if game_type == "guesser"
  new_game.get_computer_colors
  new_game.welcome_game_type_one
elsif game_type == "setter"

end

#MasterMind method - def choose_game_type --> choose guesser or master
#computer variable --> @new_guesses = Array.new(@possible_colors.length, "_")

#Computer method - get_random_color() --> creates a random color

#Computer method - random_color_guess()

  #iterates through @new_guesses.each_with_index |guess, i|
  #if @correct_guesses[i] == 'O'
    #guess = 'O'
  #elsif @correct_guesses[i] == '_'
    #guess = get_random_color()
  #return array like "[red, "O", blue, "O"]" where the colors listed are the new random guesses

#
