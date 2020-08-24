
require 'pry'

class Mastermind
  attr_accessor :current_number_of_guesses, :allowed_number_of_guesses, :possible_colors, :colors_selected_by_computer, :correct_guesses, :colors_in_wrong_position, :remaining_colors
  @@current_number_of_guesses = 0

  def initialize(allowed_number_of_guesses)
    @allowed_number_of_guesses = allowed_number_of_guesses
    @possible_colors = ['red', 'blue', 'yellow', 'green']
    @colors_selected_by_computer = []
    @correct_guesses = ['_', '_', '_', '_']
    @colors_in_wrong_position = 0
    @remaining_colors = []
    @player1 = Player.new()
  end

  def welcome()
    puts "\n\n\nWelcome to Mastermind!" 
    sleep(1)
    puts "\nIn this instance, you will be the guesser, and the computer will be the creator"
    sleep(3)
    puts "\nYou have #{@allowed_number_of_guesses} tries to guess the secret color code!"
    sleep(3)
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
    4.times do
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
      @correct_guesses = ['_', '_', '_', '_']
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
  end

  def random_color_select() 
    random_colors = []
    4.times do
      random_colors.push(@possible_colors[rand(4)])
    end
    return random_colors
  end

end

new_game = Mastermind.new(1)
new_game.welcome
new_game.get_computer_colors
new_game.new_round