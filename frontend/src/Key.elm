module Key exposing (Key(..), keyDecoder)

import Json.Decode as Decode

type Key
  = Spacebar
  | Backspace
  | Escape
  | Enter
  | N
  | B
  | D
  | H
  | Other

keyDecoder : Decode.Decoder Key
keyDecoder =
  Decode.map toDirection (Decode.field "key" Decode.string)

toDirection : String -> Key
toDirection string =
  case string of
    " " ->
      Spacebar
    "Spacebar" ->
      Spacebar
    "Enter" ->
      Enter
    "Escape" ->
      Escape
    "Backspace" ->
      Backspace
    "n" ->
      N
    "b" ->
      B
    "d" ->
      D
    "h" ->
      H
    _ ->
      Other
