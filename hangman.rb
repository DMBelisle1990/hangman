require 'rubygems'
require 'sqlite3'

$db = SQLite3::Database.new("savedgames")
$db.results_as_hash = true

class Hangman

  attr_reader :word, :dictionary
  attr_accessor :turns_left, :guessed_letters, :board

  def initialize
  	puts "----Hangman----\n\n\n"
  	@turns_left = 10
  	@guessed_letters = []
  	puts %{Select an option:

  	  1. New game
  	  2. Load game}
  	selection = gets.chomp

	new_game  if selection == "1"
	load_game if selection == "2"
  end

  def create_table
  	puts "creating saved games database..."
  	$db.execute %q{
  	  CREATE TABLE games (
  	  id integer primary key,
  	  name varchar(50),
  	  board varchar(15),
  	  word varchar(15),
  	  turnsleft integer)
  	}
  end

  def new_game
    @dictionary = File.read("dictionary.txt").split
	@word = ""
	@word = dictionary[rand(dictionary.length)].downcase until word.length > 4 && word.length < 13
	@board = "_ " * word.length
	start
  end

  def load_game
  	games = $db.execute("SELECT name FROM games")
  	puts "Select a game"
  	games.each { |game| puts game['name'] }
  	selection = gets.chomp
  	load = $db.execute("SELECT * FROM games WHERE name = ?", selection)
  	load.each do |y| 
  	  @board = y["board"]
  	  @word = y["word"]
  	  @turns_left = y["turnsleft"]
  	end

  	start
  end

  def start
  	until game_over? || win? do
  	  print "\n\n\n\n#{board}\tGuessed letters: "
  	  guessed_letters.each { |guess| print "#{guess} " }
  	  puts "\nGuess a letter or enter 1 to save\tRemaining guesses: #{turns_left}\n"
  	  letter = gets.chomp

  	  save_game if letter == "1"

  	  letter.downcase!

  	  if word.include?(letter)
  	  	puts "\n\nYou got a match!"
  	    word.each_char.with_index { |char,idx| board[idx * 2] = letter if char == letter }
  	  else
  	  	puts "\n\nSorry, no #{letter}'s"
  	    @turns_left -= 1
  	    guessed_letters << letter
  	  end
  	end
  	end_game
  end

  def save_game
  	puts "Enter a name for your game:"
  	name = gets.chomp
  	$db.execute("INSERT INTO games (name, board, word, turnsleft) VALUES (?, ?, ?, ?)",name,@board,@word,@turns_left)
  	disconnect_and_quit
  end

  def end_game
  	puts "\n\n\n---------------Results---------------"
  	puts "#{board}"
  	puts "Answer: #{word}"
  	puts win? ? "You won!" : "You suck"
  	disconnect_and_quit
  end

  def win?
  	return true if board.gsub(" ","") == word
  end

  def game_over?
  	return true if turns_left == 0
  end

  def disconnect_and_quit
  	$db.close
  	puts "Thanks for playing!"
  	exit
  end



end

game = Hangman.new

#this game has a decent amount of bugs, but it does execute the basic requirements
#can save and load games, database needs a column to track guessed letters



