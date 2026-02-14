module Event exposing (Event, view, Msg(..))

import Html exposing (..)
import Html.Attributes exposing (..)
import Svg.Attributes as SvgAttr
import Html.Keyed
import Time
import Html.Events exposing (onClick)

import Carbon.Icons exposing (..)


type Msg
  = Delete String
  | ToggleBlocked String
  | NextItem
  | BumpToTop String

type alias Event =
  { name: String
  , id: String
  , createdAt: Time.Posix
  , isBlocked: Bool
  }

view : List Event -> Html Msg
view events =
  let
    canSkip = (List.length events) > 1
  in
  Html.Keyed.node "div" [] (
    case events of
        first::rest -> (firstEvent first canSkip)::(rest |> List.indexedMap (backlogEvent ((List.length events) - 2)))
        _ -> []
    )

-- Shared between firstEvent and backlogEvent
sharedClasses : String
sharedClasses = "group w-full p-2 my-2 -mx-2 transition-all rounded-[4px] transform-gpu border-1 border-transparent hover:border-muted-extra"

firstEvent : Event -> Bool -> (String, Html Msg)
firstEvent event canSkip =
  let
    instruction = if event.isBlocked then "Is this still blocked?" else "You're working on..."
    allowedAction = if canSkip then Skip else None
  in
    ("Don't remount me"
    , Html.Keyed.node "div" [ class "my-[3lh]" ]
      [ ("keep me", div [] [ text instruction ])
      , (event.id, div [
          class (String.join " "
            [ "p-2 my-0 text-title font-bold animate-main-task flex justify-between"
            , sharedClasses
            , if event.isBlocked then stripedBackground else ""
            ]
          )
        ](List.concat
        [ [ span [ class "bg-bg" ] [ text event.name ] ]
        , [ controlPanel allowedAction event.id ]
        ])
        )
     ]
    )

stripedBackground : String
stripedBackground =
  "bg-[repeating-linear-gradient(45deg,transparent,transparent_4px,var(--color-muted-extra)_5px,var(--color-muted-extra)_5px,transparent_6px)]"

backlogEvent : Int -> Int -> Event -> (String, Html Msg)
backlogEvent lastItem index event =
  let
    animation = if index == lastItem then
        "animate-float-in"
      else if (modBy 2 index) == 0 then
          "animate-float"
        else "animate-float-2"
    background = if event.isBlocked then
        stripedBackground
      else
        ""
  in
    ( event.id
    , div [ class (String.join " " [background, animation, sharedClasses]) ]
      [ span [ class "flex justify-between" ]
        ( List.concat
        [ [ span [ class "bg-bg" ] [ text event.name ] ]
        , [ controlPanel Bump event.id ]
        ]
        )
      ]
    )

controlPanelButton : String -> Msg -> (String -> List (Attribute Msg) -> Html Msg) -> Html Msg
controlPanelButton name action icon =
  button
    [ onClick action
    , class "accent-cursor opacity-0 group-hover:opacity-100 focus:opacity-100 cursor-pointer duration-100 bg-bg hover:bg-muted-extra text-muted hover:text-body rounded-[2px] w-[calc(1lh_+_.5rem)] h-full p-1"
    , title name
    ]
    [ icon name [ SvgAttr.class "w-full h-full" ]
    ]

type AllowedAction
  = Skip
  | Bump
  | None

controlPanel : AllowedAction -> String -> Html Msg
controlPanel allowedAction eventId =
  div [ class "h-[calc(1lh_+_.5rem)] -m-1 flex gap-1" ] (
    [ case allowedAction of
      Skip -> [ controlPanelButton "Skip" NextItem Carbon.Icons.chevronDownOutline ]
      Bump -> [ controlPanelButton "Bump to top" (BumpToTop eventId) Carbon.Icons.chevronUpOutline ]
      None -> []
    , [ controlPanelButton "Toggle blocked" (ToggleBlocked eventId) Carbon.Icons.errorOutline ]
    , [ controlPanelButton "Delete item" (Delete eventId) Carbon.Icons.trashCan ]
    ] |> List.concat)
