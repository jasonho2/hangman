require 'json'

dictionary = File.readlines("google-10000-english-no-swears.txt", chomp: true)
FILTERED_WORDS = dictionary.select { |word| word.length.between?(5, 12) }

class Hangman
  LETTERS = ('A'..'Z').to_a
  SAVE_DIR = "saves" # Folder to store save files

  def initialize
    Dir.mkdir(SAVE_DIR) unless Dir.exist?(SAVE_DIR) # Create folder if missing
    if has_saves?
      puts "Do you want to load a saved game? (Y/N)"
      answer = gets.chomp.upcase
      if answer == "Y"
        load_game
        return
      end
    end

    

    @secret_word = FILTERED_WORDS.sample.upcase.chars
    @mistakes = 0
    @secret_word_spaces = Array.new(@secret_word.length, '_')
    @incorrect_guesses = []

    puts "Welcome to Hangman. Try to guess the secret word."
    display_word
    puts "Enter your letter guess. You are allowed 6 total mistakes."
  end

  def play
    while @mistakes < 7 && @secret_word_spaces.include?('_')
      print "\nTotal mistakes: #{@mistakes}\n"
      puts "Incorrect guesses: #{@incorrect_guesses.join(', ')}" unless @incorrect_guesses.empty?
      puts "Enter a letter or type 'SAVE' to save and exit: "
      guess = gets.chomp.upcase

      if guess == "SAVE"
        save_game
        puts "Game saved. You can load it next time!"
        return
      end

      if valid_guess?(guess)
        process_guess(guess)
      else
        puts "Invalid input. Please enter a single letter."
      end

      display_word
    end

    conclude_game
  end

  private

  def valid_guess?(guess)
    guess.match?(/^[A-Z]$/)
  end

  def process_guess(guess)
    if @secret_word.include?(guess)
      update_display(guess)
      puts "Yes! '#{guess}' is part of the secret word."
    else
      puts "No - '#{guess}' is not part of the secret word."
      @incorrect_guesses << guess
      @mistakes += 1
    end
  end

  def update_display(guess)
    @secret_word.each_with_index do |char, index|
      @secret_word_spaces[index] = guess if char == guess
    end
  end

  def display_word
    puts "\nWord Progress: " + @secret_word_spaces.join(' ')
  end

  def conclude_game
    if @secret_word_spaces.include?('_')
      puts "You lose. The secret word was #{@secret_word.join}."
    else
      puts "Congratulations! You guessed the word: #{@secret_word.join}."
    end

    delete_save if has_saves?
  end

  def save_game
    puts "Enter a name for your save file (e.g., 'player1', 'game2'):"
    filename = gets.chomp.strip
    save_file = "#{SAVE_DIR}/#{filename}.json"

    game_state = {
      secret_word: @secret_word,
      mistakes: @mistakes,
      secret_word_spaces: @secret_word_spaces,
      incorrect_guesses: @incorrect_guesses
    }

    File.open(save_file, "w") { |file| file.write(JSON.dump(game_state)) }
    puts "Game saved as '#{filename}'."
  end

  def load_game
    saves = list_saves
    if saves.empty?
      puts "No saved games available."
      return
    end

    puts "Available saves:"
    saves.each_with_index { |file, index| puts "#{index + 1}. #{file}" }

    print "Enter the number of the save you want to load: "
    choice = gets.chomp.to_i - 1

    if choice.between?(0, saves.length - 1)
      save_file = "#{SAVE_DIR}/#{saves[choice]}"
      game_state = JSON.parse(File.read(save_file), symbolize_names: true)

      @secret_word = game_state[:secret_word]
      @mistakes = game_state[:mistakes]
      @secret_word_spaces = game_state[:secret_word_spaces]
      @incorrect_guesses = game_state[:incorrect_guesses] || []

      puts "Game '#{saves[choice]}' loaded. Continue guessing!"
      display_word
    else
      puts "Invalid choice. Starting a new game instead."
    end
  end

  def has_saves?
    !Dir.empty?(SAVE_DIR)
  end

  def list_saves
    Dir.entries(SAVE_DIR).select { |file| file.end_with?(".json") }
  end

  def delete_save
    saves = list_saves
    saves.each { |file| File.delete("#{SAVE_DIR}/#{file}") }
  end
end

game = Hangman.new
game.play