module Utils.HeaderIconButton exposing (view)

import Html exposing (Html)
import Html.Events exposing (onClick)
import Svg.Attributes

import Carbon.Icons exposing (Icon)

iconClass : String
iconClass = "w-[1lh] h-[1lh] cursor-pointer text-muted hover:text-body transition duration-100"

view : String -> msg -> Icon msg -> Html msg
view name action icon =
  icon name [ Svg.Attributes.class iconClass, onClick action ]
