defmodule GameTest do
  use ExUnit.Case
  alias Hangman.Game

  test "new game returns correct structure" do
    game = Game.new()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
    assert game.letters |> is_list 
    assert game.letters |> Enum.all?(fn << cp :: utf8 >> -> ?a <= cp and cp <= ?z end)
  end

  test "should not update state for :won or :lost games" do
    for state <- [ :won, :lost ] do
      game = Game.new() |> Map.put(:game_state, state)

      ## assert left-hand game is same as right-hand game
      assert { ^game, _ } = Game.make_move(game, "x")
    end
  end

  test "should handle first occurrence of guessed letter" do
    game = Game.new()

    { game, _ } = Game.make_move(game, "x")
    assert game.game_state != :already_used
    assert "x" in game.used
  end

  test "should handle subsequent occurrences of guessed letter" do
    game = Game.new()

    { game, _ } = Game.make_move(game, "x")
    assert game.game_state != :already_used
    { game, _ } = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "should recognize good guess" do
    game = Game.new("wibble")

    { game, _ } = Game.make_move(game, "w")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "should handle won game" do
    game = Game.new("wibble")
    moves = [
      { "w", :good_guess },
      { "i", :good_guess },
      { "b", :good_guess },
      { "l", :good_guess },
      { "e", :won },
    ]

    Enum.reduce(moves, game, fn ({ guess, game_state } = _move, state) ->
      { next_state, _ } = Game.make_move(state, guess)
      assert game_state == next_state.game_state
      next_state
    end)

  end

  test "should handle incorrect guess" do
    game = Game.new("wibble")

    { game, _ } = Game.make_move(game, "x")
    assert game.turns_left == 6
    assert game.game_state == :bad_guess
  end

  test "should handle lost game" do
    game = Game.new("wibble")
    moves = [
      { "x", :bad_guess },
      { "y", :bad_guess },
      { "z", :bad_guess },
      { "v", :bad_guess },
      { "u", :bad_guess },
      { "r", :bad_guess },
      { "n", :lost },
    ]

    Enum.reduce(moves, game, fn ({ guess, game_state } = _move, state) ->
      { next_state, _ } = Game.make_move(state, guess)
      assert game_state == next_state.game_state
      next_state
    end)
  end

end
