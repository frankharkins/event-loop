module Utils.Modal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Carbon.Icons exposing (..)

view : Bool -> msg -> List (Html msg) -> Html msg
view isOpen closeMsg children =
  div
    [ classList
      [ ("opacity-0 invisible", not isOpen)
      , ("absolute z-100 transition-all duration-250 top-0 left-0 w-screen h-screen bg-muted/50 flex justify-center items-center p-8", True)
      ]
    , onClick closeMsg
    ]
    [ div
      [ class "border-px border-title bg-bg p-8 rounded-[4px] max-w-[800px] max-h-full overflow-auto shadow-lg" ]
      children
    ]
