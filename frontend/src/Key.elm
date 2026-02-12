module Key exposing (Key(..), keyDecoder)

import Json.Decode as Decode

type Key
  = Spacebar
  | Backspace
  | N
  | B
  | D
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
    "Backspace" ->
      Backspace
    "n" ->
      N
    "b" ->
      B
    "d" ->
      D
    _ ->
      Other
