class CodebreakerGame
  def initialize
    @human = HumanPlayer.new
    @clues = []
    @secret_code = Utils.generate_random_code
    @round_counter = 1
  end

  def check_guess
    @secret_code_copy = @secret_code.clone
    @secret_code_copy.each_with_index do |char, index|
      next unless char == @human.guess[index]

      @clues.push(1)
      @human.guess[index] = 0
      @secret_code_copy[index] = 0
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
      puts @clues.sort.reverse.join(',')
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
    @secret_code = Utils.generate_random_code
    @round_counter = 1
  end
end

class CodemakerGame
  def initialize
    puts 'Please insert the secret code'
    @secret_code = gets.chomp.chars.map(&:to_i)
    @combinations = generate_combinations
    @combinations_filter = @combinations.clone
    @round_counter = 1
    reset_all_clues_hash
  end

  def play(computer_guess = [1, 1, 2, 2])
    puts "Computer's guess is #{computer_guess.join.to_i}."
    if compare_arrays(@secret_code, computer_guess)
      puts 'The computer won!'
      return end_game
    end

    if @round_counter == 13
      puts 'The computer lost. You won!'
      return end_game
    end

    clues = find_clues(@secret_code, computer_guess)
    @combinations_filter = @combinations_filter.filter do |combination|
      compare_arrays(find_clues(computer_guess, combination), clues)
    end
    @combinations.delete(computer_guess)

    new_guess = find_best_guess
    @round_counter += 1

    play(new_guess)
  end

  def generate_combinations
    combinations = []
    1111.upto(6666) do |i|
      i = i.to_s
      combinations.push(i) unless i.include?('7') || i.include?('8') || i.include?('9') || i.include?('0')
    end
    combinations.map do |combination|
      combination = combination.split('')
      combination.map(&:to_i)
    end
  end

  def find_clues(secret_code, guess)
    secret_code_clone = secret_code.clone
    guess_clone = guess.clone
    clues = []
    secret_code_clone.each_with_index do |char, index|
      next unless char == guess_clone[index]

      clues.push(1)
      guess_clone[index] = 0
      secret_code_clone[index] = 0
    end
    secret_code_clone.delete(0)
    guess_clone.delete(0)
    secret_code_clone.each do |char|
      if guess_clone.include?(char)
        clues.push(0)
        guess_clone.delete_at(guess_clone.index(char))
      end
    end
    clues.sort
  end

  def find_best_guess
    best_score = 1000
    best_guess = 0
    @combinations.each do |guess|
      reset_all_clues_hash
      @combinations_filter.each do |code|
        score = find_clues(code, guess)
        zero_count = 0
        one_count = 0
        score.each do |i|
          if i.zero?
            zero_count += 1
          elsif i == 1
            one_count += 1
          end
        end
        cumulated_clues = "#{one_count},#{zero_count}"
        @all_clues[cumulated_clues] = @all_clues[cumulated_clues] + 1
      end
      max_value = @all_clues.values.max

      if max_value < best_score
        best_score = max_value
        best_guess = guess
      elsif max_value == best_score
        if @combinations_filter.include?(guess)
          if @combinations_filter.include?(best_guess)
            best_guess = guess if guess.join.to_i < best_guess.join.to_i
          else
            best_guess = guess
          end
        end
      end
    end
    best_guess
  end

  def compare_arrays(array1, array2)
    return false if array1.count != array2.count

    array1.each_with_index do |elem, index|
      return false if elem != array2[index]
    end
    true
  end

  def end_game
    puts 'Do you want to play again? y/n'
    answer = gets.chomp
    if answer == 'y'
      play_again
    else
      puts 'Okay! Maybe next time.'
    end
  end

  def play_again
    puts 'Please insert the secret code'
    @secret_code = gets.chomp.chars.map(&:to_i)
    @combinations = generate_combinations
    @combinations_filter = @combinations.clone
    @round_counter = 1
    play
  end

  def reset_all_clues_hash
    @all_clues = {}
    0.upto(4) do |i|
      0.upto(4) do |j|
        @all_clues["#{i},#{j}"] = 0 if i + j <= 4
      end
    end
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

class Utils
  def self.generate_random_code
    [1, 2, 3, 4, 5, 6].sample(4)
  end
end

puts 'Hello! Do you wanna play a game of Mastermind? y/n'
choice = gets.chomp
if choice == 'y'
  puts 'Do you want to play as a codebreaker(1) or as a codemaker(2)?'
  role = gets.chomp.to_i
  new_game = if role == 1
               CodebreakerGame.new
             else
               CodemakerGame.new
             end
  new_game.play
else
  puts 'Maybe next time!'
end
