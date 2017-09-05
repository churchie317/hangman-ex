defmodule Hangman.Game do

  defstruct turns_left: 7, game_state: :initializing, letters: [], used: MapSet.new()


  ############################
  ## PUBLIC API 
  ############################


  ## implemented for testing purposes
  def new(word) when is_binary(word) do
    %Hangman.Game{ letters: String.codepoints(word) }
  end

  def new() do
    new(Dictionary.random_word)
  end

  def make_move(%{ game_state: state } = game, _guess) when state in [ :won, :lost ] do
    game
  end

  def make_move(game, guess) do
    accept_move(game, guess, guess in game.used)
  end

  def tally(game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters: game.letters |> reveal_guessed(game.used)
    }
  end


  ############################
  ## PRIVATE API 
  ############################


  defp accept_move(game, _guess, _already_guessed? = true) do
    game |> Map.put(:game_state, :already_used)
  end

  ## when new guess
  defp accept_move(game, guess, _already_guessed?) do
    game
      |> Map.put(:used, MapSet.put(game.used, guess))
      |> score_guess(Enum.member?(game.letters, guess))
  end


  defp score_guess(game, _correct_guess = true) do
    new_state = MapSet.new(game.letters)
      |> MapSet.subset?(game.used)
      |> maybe_won()

    Map.put(game, :game_state, new_state)
  end

  defp score_guess(%{ turns_left: 1 } = game, _incorrect_guess) do
    game
      |> Map.put(:game_state, :lost)
  end


  defp score_guess(%{ turns_left: turns_left } = game, _incorrect_guess) do
    %{ game | game_state: :bad_guess, turns_left: turns_left - 1 }
  end

  defp reveal_guessed(letters, used) do
    letters
    |> Enum.map(fn letter -> reveal_letter(letter, MapSet.member?(used, letter)) end)
  end


  defp reveal_letter(letter, _in_word = true), do: letter
  defp reveal_letter(_letter, _not_in_word), do: "_"

defp maybe_won(true), do: :won
  defp maybe_won(_), do: :good_guess

end
