defmodule Identicon do
  @moduledoc """
  Provides methods for creating an Identicon like you can find one your github profile
  """

    @doc """
  This the main method who call another methods to send the input and generate png image.
   
    ## Examples

    iex> Identicon.main("test")
    :ok
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)    
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal , vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) -> 
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end
  
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid = 
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
    end

    def mirror_row(row) do
      [first, second | _tail] = row

      row ++ [second, first]
    end

  @doc """
  This method take the first 3 values of hex struct. It will be used as RGB value
  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
  This method hash the string input in MD5
   
    ## Examples

    iex> input = Identicon.hash_input("fred")
    %Identicon.Image
    {     color: nil,
    grid: nil,
    hex: [87, 10, 144, 191, 191, 140, 126, 171, 93, 197, 212, 226, 104, 50, 213, 177],
    pixel_map: nil
    }
  """
  def hash_input(input) do
   hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end
end
