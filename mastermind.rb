#colours: white, green, red, orange, yellow, blue, grey, pink
#classes: Computer, Player, Game

class Computer
  attr_reader :name

  def initialize
    @name = "CPU"
    @guess = 0
    @code = []
  end

  def get_code(exact_matches, color_matches)
    @guess += 1
    if @guess == 1
      @best_score = -1 
      @last_exacts = []
      @last_colors = []
      return @code[@guess] = generate_code
    end
    cpu_guess(exact_matches, color_matches)
  end

  def cpu_big_brain(secret)
    @secret = secret
  end
 
  private

  def cpu_guess(exact_matches, color_matches)
    # if better_score?(exact_matches, color_matches)
    #   @code[@guess - 1] = @code[@best]
    #   exact_matches = @last_exacts[@best]
    #   color_matches = @last_colors[@best]
    # end
    
    # @last_exacts[@guess - 1] = exact_matches
    # @last_colors[@guess - 1] = color_matches

    kept = cpu_exact_matches_cheating(exact_matches)
    cpu_color_matches(color_matches, kept)
  end

  def better_score?(exact_matches, color_matches)
    rv = true
    score = exact_matches + color_matches
    if score > @best_score
      rv = false
      @best_score = score
      @best = @guess - 1
    end
    rv
  end
  
  def cpu_exact_matches(exact_matches)
    kept = Array.new(4)
    exact_matches.times do
      used = true
      while used
        rando = rand(0..3)
        keep = @code[@guess - 1][rando]
        used = false unless kept.include?(keep)
      end
      kept[rando] = keep
    end
    p kept
  end
  
  def cpu_exact_matches_cheating(_exact_matches)
    kept = Array.new(4)
    @code[@guess - 1].each_with_index do |_elm, idx|
      if @code[@guess - 1][idx] == @secret[idx]
        kept[idx] = @secret[idx]
      end
    end
    p kept
  end

  def cpu_color_matches(color_matches, kept)
    keep_color = []

    color_matches.times do
      loop do
        @rando = rand(0..3)
        @choice = @code[@guess - 1][@rando]
        break unless kept.include?(@choice) || keep_color.include?(@choice)
      end
      keep_color[@rando] = @choice
    end

    keep_color = remove_nil_values(keep_color)
    keep_color = left_shift(keep_color, 1)
    kept = replace_nil_values(kept, keep_color)
    p tossed = @code[@guess - 1] - kept

    @code[@guess] = generate_code(kept, tossed)
  end
  
  def left_shift(array, shift)
    shifted_array = []

    array.each_with_index do |_elm, idx|
      if idx - shift < 0
        shifted_array[array.length - 1] = array[idx]
      else
        shifted_array[idx - shift] = array[idx]
      end
    end

    shifted_array
  end

  def replace_nil_values(to_replace, full_array)
    full_array.each do |element|
      to_replace[to_replace.index(nil)] = element
    end

    to_replace
  end
  
  def remove_nil_values(array)
    array.select { |elm| elm != nil }
  end

  def generate_code(array = Array.new(4), tossed = [])
    array.each_with_index do |element, idx|
      next unless element == nil
      used = true
      while used
        color = choose_random_color(element)
        used = false unless array.include?(color) || tossed.include?(color)
      end
      array[idx] = color
    end
    array
  end
  
  def choose_random_color(elm)
    if elm == nil
      elm = rand(1..8)
      convert_to_color(elm)
    else
      elm = elm
    end
  end

  def convert_to_color(num)
    num_to_color = {
      1 => "grey",
      2 => "yellow",
      3 => "green",
      4 => "red",
      5 => "blue",
      6 => "pink",
      7 => "orange",
      8 => "white"
    }
    num_to_color[num]
  end
end

class Player
  attr_reader :name
  attr_reader :code

  def initialize(name)
    @name = name
  end

  def get_code(_exact_matches, _color_matches)
    code_string_to_array(gets.chomp)
  end

  private

  def code_string_to_array(code)
    code.split
  end
end

class Game
  def initialize(num_of_guesses, codebreaker, codemaker)
    @num_of_guesses = num_of_guesses
    @codebreaker = codebreaker
    @codemaker = codemaker
  end

  def get_secret
    puts "enter secret: " unless @codemaker.name == "CPU"
    @secret = @codemaker.get_code(@exact_matches, @color_matches)
    puts
  end

  def get_guess
    puts "enter guess: "
    @guess = @codebreaker.get_code(@exact_matches, @color_matches)
  end

  def show_info
    if @codebreaker.name == "CPU"
      puts "CPU guess: #{@guess}"
    end
  end

  def check_for_match
    return true if @guess == @secret
    false
  end

  def correct_colors
    @exact_matches = 0
    @color_matches = 0

    @guess.each_with_index do |_color, idx|
      @color_matches += 1 if @guess.include?(@secret[idx])
    end
    @guess.each_with_index do |_color, idx|
      @exact_matches += 1 if @guess[idx] == @secret[idx]
    end

    @color_matches -= @exact_matches
    puts "#{@color_matches} correct colours"
    puts "#{@exact_matches} exact matches\n\n"
  end

  def game_results
    if check_for_match
      puts "\ncodebreaker wins!\n\n"
    else
      puts "\ncodemaker wins!\n\n"
    end
    puts "the secret was: #{@secret} by #{@codemaker.name}"
  end

  def play_game
    get_secret
    if @codebreaker.name == "CPU"
      @codebreaker.cpu_big_brain(@secret)
    end
    @num_of_guesses.times do
      get_guess
      show_info
      correct_colors
      break if check_for_match
    end
    game_results
  end
end

class GameSetup
  attr_reader :game
  attr_reader :human

  def initialize
    @human = Player.new("human player")
    @cpu = Computer.new
  end

  def choose_roles
    puts "enter code to be the codemaker or"
    puts "enter guess to be the codebreaker."
    choice = gets.chomp

    if choice == "code"
      @game = Game.new(12, @cpu, @human)
    else
      @game = Game.new(12, @human, @cpu)
    end
    @game.play_game
  end
end

start = GameSetup.new
start.choose_roles
