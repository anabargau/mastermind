require "pry-byebug"
class Game

  def initialize
    @human = HumanPlayer.new
    @computer = ComputerPlayer.new
    @clues = []
    @secret_code = @computer.generate_random_code
    @round_counter = 1
  end

  def check_guess
    @secret_code_copy = @secret_code.clone
    @secret_code_copy.each_with_index do |char, index|
      if char == @human.guess[index]
        @clues.push(1)
        @human.guess[index] = 0
        @secret_code_copy[index] = 0
      end
    end
    @secret_code_copy.delete(0)
    @human.guess.delete(0)
    @secret_code_copy.each do |char|
      if @human.guess.include?(char)
        @clues.push(0)
        @human.guess.delete_at(@human.guess.index(char))
      end
    end
  end

  def play
    puts "The computer has made its choice. Let's start!"
    while @round_counter <= 12
      @human.ask_for_guess
      if @secret_code == @human.guess
        puts 'Cograts! You won!'
        play_again
      end
      check_guess
      puts 'The clues are:'
      puts @clues.sort.reverse.join(",")
      reset_clues
      @round_counter += 1  
    end
    puts "Sorry, Computer wins! The code was #{@secret_code.join}."
    play_again
  end

  def play_again
    puts 'Do you wanna play again? y/n'
    player_choice = gets.chomp
    if player_choice == 'y'
      reset_game
      play
    else
      puts 'Okay, maybe next time!'
    end
  end

  def reset_clues
    @clues = []
  end

  def reset_game
    reset_clues
    @secret_code = @computer.generate_random_code
    @round_counter = 1
  end
end

class HumanPlayer

  attr_accessor :guess

  def ask_for_guess
    puts 'Please write your guess'
    @guess = gets.chomp.chars
    @guess = @guess.map(&:to_i)
  end
end

class ComputerPlayer

  def generate_random_code
    [1, 2, 3, 4, 5, 6].sample(4)
  end
end

puts 'Hello! Do you wanna play a game of Mastermind? y/n'
choice = gets.chomp
if choice == 'y'
  new_game = Game.new
  new_game.play
else
  puts 'Maybe next time!'
end
