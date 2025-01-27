dictionary = File.readlines("google-10000-english-no-swears.txt", chomp: true)
FILTERED_WORDS = dictionary.select { |word| word.length.between?(5, 12) }

class Hangman
  LETTERS = ('A'..'Z').to_a

  def initialize
    @secret_word = FILTERED_WORDS.sample.upcase.chars
    @mistakes = 0
    @secret_word_spaces = Array.new(@secret_word.length, '_')

    puts "Welcome to Hangman. Try to guess the secret word."
    display_word
    puts "Enter your letter guess. You are allowed 6 total mistakes."
  end

  def play
    while @mistakes < 6 && @secret_word_spaces.include?('_')
      print "\nTotal mistakes: #{@mistakes}\n"
      guess = get_valid_guess

      if @secret_word.include?(guess)
        update_display(guess)
        puts "Yes! '#{guess}' is part of the secret word."
      else
        puts "No - '#{guess}' is not part of the secret word."
        @mistakes += 1
      end

      display_word
    end

    if @secret_word_spaces.include?('_')
      puts "You lose. The secret word was #{@secret_word.join}."
    else
      puts "Congratulations! You guessed the word: #{@secret_word.join}."
    end
  end

  private

  def get_valid_guess
    loop do
      print "Enter a letter: "
      guess = gets.chomp.upcase

      if guess.match?(/^[A-Z]$/)
        return guess
      else
        puts "Invalid input. Please enter a single letter from A-Z."
      end
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
end

game = Hangman.new
game.play