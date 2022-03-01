require "pry-byebug"

class CodebreakerGame

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
    puts 'The computer has made its choice. Let\'s start!'
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

class CodeMaker

  def initialize
    puts 'Please insert the secret code'
    @secret_code = gets.chomp.chars.map(&:to_i)
    @clues = []
    @computer = ComputerPlayer.new
    @combinations = []
    @computer_guess = [1, 1, 2, 2]
  end

  def play
    won = false
    @combinations = generate_@combinations
    puts "Computer's guess is #{@computer_guess}"
    @clues = check_guess(@secret_code, @computer_guess)
    @combinations_filter = @combinations.filter do |combination|
      compare_arrays(combination, @clues)
    end
    @combinations.delete(computer_guess)
    while won == false
      computer_guess = find_best_guess
      check_guess(secret_code, computer_guess)
      @combinations.delete(computer_guess)
    end  
  end

  def generate_combinations
    1111.upto(6666) do |i|
      i = i.to_s
      unless i.include?('7') || i.include?('8') || i.include?('9') || i.include?('0')
        @@combinations.push(i)
      end
    end
    @combinations = @combinations.map do |combination|
      combination = combination.split('')
      combination.map(&:to_i)
    end  
  end
  
  def check_guess(secret_code, guess)

    if compare_arrays(secret_code, guess)
      won = true
      game_won
      return
    end

    clues = []
    secret_code.each_with_index do |char, index|
      if char == computer_guess[index]
        clues.push(1)
        guess[index] = 0
        secret_code[index] = 0
      end
    end
    secret_code.delete(0)
    guess.delete(0)
    secret_code.each do |char|
      if guess.include?(char)
        clues.push(0)
        guess.delete_at(guess.index(char))
      end
    end
    clues.sort
  end

    def find_best_guess
      best_score = 1000
      best_guess = 0
      
      @combinations.each do |guess|
         all_clues = {
          '0,0' => 0,
          '0,1' => 0,
          '0,2' => 0,
          '0,3' => 0,
          '0,4' => 0,
          '1,1' => 0,
          '1,2' => 0,
          '1,3' => 0,
          '2,0' => 0,
          '2,1' => 0,
          '2,2' => 0,
          '3,0' => 0,
          '4,0' => 0
        }
        @combinations_filter.each do |code|
          score = check_guess(code, guess)
          zero_count = 0
          one_count = 0
          for i in score
            if i == 0
              zero_count += 1
            elsif i == 1
              one_count += 1
            end
          end
          @all_clues["#{one_count},#{zero_count}"] += 1
        end
        max_value = @all_clues.values.sort[0]
        if max_value < best_score
           best_score = max_value
           best_guess = guess 
         end
      end
      best_guess
    end
        
    def compare_arrays(array1, array2) 
      
      if array1.count != array2.count 
        false
      end
    
      array1.each_with_index do |elem, index| 
        if elem != array2[index]
          false
        end
      end
      true
    end

  def game_won
    puts 'The computer won!'
    puts 'Do you want to play again? y/n'
    answer = gets.chomp
    if answer == 'y'
      play_again
    else
      'Okay! Maybe next time.'
    end
  end

  def play_again
    puts 'Please insert the secret code'
    @secret_code = gets.chomp.chars.map(&:to_i)
    @clues = []
    @combinations = []
    @computer_guess = [1, 1, 2, 2]
    play
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
  puts 'Do you want to play as a codebreaker(1) or as a codemaker(2)?'
  role = gets.chomp.to_i
  if role == 1
    new_game = CodebreakerGame.new
  else
    new_game = CodeMaker.new
  end
  new_game.play
else
  puts 'Maybe next time!'
end



